# Global Learnings - テンプレートリポジトリ グローバル知見

過去のプロジェクトから得られた知見を蓄積するファイル。
`/retro` 実行時にグローバルに有用と判断された知見がここに追記される。

---

## 運用知見

- tmux セッション内で PM エージェントを起動すること（nohup フォールバック回避）
- `projects/` 配下は親リポジトリの `.gitignore` で除外されるため、各プロジェクトは独立リポジトリとして管理する

## 技術知見

- `.claude/rules/` を使用してプロジェクト固有の知見を蓄積する運用を開始
- `/retro` スキルを使用してプロジェクト完了時の振り返りを標準化
- `CLAUDE.md` に Context Discovery セクションを追加し、過去の知見を自動参照する仕組みを導入

### SSEストリーミング (FastAPI + Next.js)

外部CLI（Claude Code等）の出力をリアルタイムでフロントエンドに配信するパターン:

- FastAPI: `StreamingResponse` + `text/event-stream`
- フロントエンド: `EventSource` API
- 終了シグナル: `data: [DONE]\n\n`
- 注意: EventSourceはGETのみ対応、unmount時に `close()` 必須

### 外部CLI実行のグレースフルデグレード

依存CLI（pm2, claude等）が無い環境でもアプリが動作するようにする:

```python
async def check_cli_available(command: str) -> bool:
    try:
        proc = await asyncio.create_subprocess_exec(command, "--version", ...)
        return proc.returncode == 0
    except FileNotFoundError:
        return False
```

CLIが無い場合はモックレスポンスを返すフォールバック実装を用意する。

### ハイブリッド監視アーキテクチャ

プロジェクト監視は「ロジック駆動 + AI駆動」の組み合わせが効果的:

- **ロジック駆動**: Markdownパース、プロセス状態取得 → 高速・確定的
- **AI駆動**: ログ解釈、期待値との乖離分析 → 柔軟・文脈理解

### ログ基盤の中央集約化

複数プロジェクトでログを集約する場合、ログサーバー（VictoriaLogs等）はプロジェクト外で中央管理すべき:

```
infra/monitoring/           # 中央ログ基盤
└── victoria-logs/
    ├── start.sh            # 起動スクリプト
    └── vlogs-data/         # ログストレージ

projects/<project>/         # 各プロジェクト
└── monitoring/
    └── promtail-config.yml # ログシッパーの設定のみ
```

**理由**:
- プロジェクト削除時にログ基盤が消失しない
- ログ基盤のライフサイクルはプロジェクトより長い
- 複数プロジェクトからの集約が容易

### Claude Code Hooks 活用パターン

Claude Code の Hooks 機能を使ってイベント駆動で外部システムと連携:

```bash
# Hook スクリプトの基本構造
#!/bin/bash
set -euo pipefail

# JSON入力を読み取り
input=$(cat)
project_id="${CC_PROJECT_ID:-unknown}"

# jq で安全に JSON 構築（インジェクション対策）
payload=$(jq -n \
  --arg project_id "$project_id" \
  --argjson input "$input" \
  '{project_id: $project_id, data: $input}')

# API に送信
curl -s -X POST "$CC_API_URL/hooks/event" \
  -H "Content-Type: application/json" \
  -d "$payload"
```

**Hook タイプ別の使い分け**:
- `PermissionRequest`: 承認待機（exit 0=承認, exit 2=拒否）
- `PostToolUse`: fire-and-forget 通知
- `Notification (idle_prompt)`: ユーザー入力待ち検知
- `Stop/SessionEnd`: セッション終了処理

### Claude Code Notification Hook の実装知見 (2026-02-08)

**Notification Hook に渡される JSON 構造:**

```json
{
  "session_id": "uuid",
  "transcript_path": "/path/to/.jsonl",
  "cwd": "/project/dir",
  "hook_event_name": "Notification",
  "message": "Claude Code needs your attention",
  "notification_type": "permission_prompt"
}
```

**重要な注意点:**
- `message` フィールドは汎用メッセージ（`"Claude Code needs your attention"`）のみで、実際の確認内容は含まれない
- 実際の確認内容を取得するには `transcript_path` のJSONLから最新の assistant メッセージの `tool_use` を抽出する必要がある
- `CC_PROJECT_ID` 等の環境変数は設定されない。`CLAUDE_PROJECT_DIR` のみ利用可能

**Slack Incoming Webhook の制約:**
- bash 変数の `\n` は2文字のリテラル。jq `--arg` で渡すと `\\n` にエスケープされ、Slackで改行されない
- 改行は `printf` で実際の改行文字を生成してから jq に渡すこと
- Incoming Webhook は Block Kit (`blocks`) 非対応の場合がある。`text` フィールドで mrkdwn を使うのが確実

### Slack Socket Mode + リアクション応答パターン (2026-02-08)

Slack Bot Token + Socket Mode で双方向通知を実現するパターン:

```python
from slack_bolt import App
from slack_bolt.adapter.socket_mode import SocketModeHandler

app = App(token=bot_token)

# スレッド返信で応答
@app.event({"type": "message"})
def handle_message(event, say):
    thread_ts = event.get("thread_ts")  # 親メッセージのts
    text = event.get("text")
    # thread_ts → tmuxセッション検索 → send-keys

# リアクションで応答（✅=yes, ❌=no）
@app.event("reaction_added")
def handle_reaction(event, say):
    message_ts = event["item"]["ts"]  # リアクション対象メッセージのts
    reaction = event["reaction"]       # "white_check_mark", "x" 等
    # message_ts → tmuxセッション検索 → send-keys

handler = SocketModeHandler(app, app_token)
handler.start()
```

**必要なSlack App設定:**
- Bot Token Scopes: `chat:write`, `reactions:write`
- Event Subscriptions: `message.channels`, `reaction_added`
- App-Level Token: `connections:write`（Socket Mode用）
- `channels:history` スコープだけでは Event が届かない。Event Subscriptions に明示追加が必要

**Bot自身のリアクション除外:**
- `message` イベント: `event.get("bot_id")` で判定
- `reaction_added` イベント: `app.client.auth_test()["user_id"]` と `event["user"]` を比較

### Slack Interactive Components との連携

FastAPI で Slack のボタンクリックを処理する際の注意点:

```python
# payload は form-urlencoded の "payload" フィールドに JSON が入っている
form_data = await request.form()
payload = json.loads(form_data.get("payload", "{}"))

# 3秒以内に 200 を返さないとリトライされる
# 重い処理はバックグラウンドタスクで
```

### Claude Code CLI の subprocess 呼び出し (2026-02-03)

**stdin経由でプロンプトを渡す正しい方法:**

```python
# ❌ 動作しない（"command too long" エラー）
subprocess.run(
    [claude_cmd, "-p", "-", "--dangerously-skip-permissions"],
    input=prompt,
    ...
)

# ✅ 正しい方法（-p フラグなしでstdinを使用）
subprocess.run(
    [claude_cmd, "--dangerously-skip-permissions"],
    input=prompt,
    capture_output=True,
    text=True,
    timeout=120,
)
```

**注意点:**
- `-p` フラグは位置引数としてプロンプトを渡す用途
- stdin経由の場合は `-p` なしで `input=` パラメータを使用
- daemonプロセスからの実行時は `--dangerously-skip-permissions` が必須

### Claude Code によるファイル操作の制御 (2026-02-03)

Claude Code が `--dangerously-skip-permissions` でファイル操作可能な場合、プロンプトで保存先を明示しないと意図しない場所にファイルが作成される:

```markdown
# プロンプト内で保存先を明示する例
If `insight.generate` is true:
1. Create an Insight file at `30_Insight/{YYYY-MM-DD}_{title}_insight.md`
2. Add a link to the original note: `[[30_Insight/...]]`
```

**ポイント:**
- フォルダパスを絶対パスまたはvault相対パスで明示
- ファイル名パターンも具体的に指定
- 双方向リンクの形式も指定

### uvicorn のコード変更反映 (2026-02-03)

uvicorn はデフォルトで自動リロードしないため、コード変更後はサーバー再起動が必要:

```bash
# 強制終了して再起動
pkill -9 -f uvicorn
sleep 2

# キャッシュクリア（必要に応じて）
find src -name "__pycache__" -type d -exec rm -rf {} +

# 再起動
uv run uvicorn main:app --host 0.0.0.0 --port 8741 &
```

開発中は `--reload` オプションを検討（ただしproductionでは非推奨）

### OpenClaw Docker デプロイ知見 (2026-02-08)

**イメージ選定:**
- `openclaw/openclaw` は Docker Hub に存在しない。`alpine/openclaw:latest` を使用
- Debian bookworm ベース。`xfonts-cyrillic` 等 Ubuntu 固有パッケージは利用不可

**Gateway 設定:**
- `--bind` の有効値: `loopback`, `lan`, `tailnet`, `auto`, `custom` （`all` は無効）
- Docker 内で外部公開するには `--bind lan` を command で指定
- Gateway Token の環境変数名は `OPENCLAW_GATEWAY_TOKEN`

**ボリューム:**
- named volume は root 所有になるため、bind mount (`./data:/home/node/.openclaw`) を推奨
- config.json は bind mount のサブパスとして `:ro` マウント可能

**SSH 追加パターン:**
- entrypoint.sh で root → sshd 起動 → `su node` で降格 → gateway 起動
- authorized_keys のパーミッション修正は `|| true` でエラー無視（ro マウント対応）

**コンテナ構成:**
- Gateway + 開発ツール（claude-code, gh, git 等）はオールインワン1コンテナ構成
- CLI 用の別サービス分離は過剰。Gateway コンテナ内でツール実行するため純粋な役割分離は不可能
- CLI 対話は `docker exec -it <container> bash` で十分

### MoneyForward ME 手入力口座のスクレイピング (2026-02-08)

**ページ構造:**
- `/accounts/show_manual` は一覧ページではなく、個別口座のベースパス（`/accounts/show_manual/{hash_id}`）
- 口座URLは `/accounts` ページのリンクから取得する必要がある

**資産エントリの操作:**
- 初回登録: `#modal_asset_new` モーダルを `$().modal("show")` で開いてフォーム送信
- 更新: `a.btn-asset-action:not([data-method="delete"])` で変更モーダルを開いて金額更新
- 残高修正(rollover): エントリ0件時はエラーになるため、変更モーダル経由が確実

**Bootstrapモーダル操作:**
- MoneyForward MEはBootstrap 2-3系。jQuery `$().modal("show")` でモーダルを直接開ける
- 開いた状態のモーダルには `.modal.in` クラスが付く（Bootstrap 4+の `.modal.show` とは異なる）

**外貨建て口座のMCPツール化:**
- `open.er-api.com` で無料為替レート取得 → JPY換算 → MF更新のパイプラインが有効
- `accounts.yaml` で口座設定を外部化し、gitignoreで機密管理

### crontab 上書き事故の防止 (2026-02-08)

`crontab <file>` や `echo ... | crontab -` は既存エントリを**全置換**する。複数プロジェクトのcronを管理する場合:

- 新規追加時は必ず `crontab -l` で既存エントリを確認してから統合
- 統合crontabファイルを `/tmp/combined-cron.txt` 等で管理し、全エントリをまとめて登録
- 個別プロジェクトごとに `crontab` を叩くと他プロジェクトのジョブが消える

### Slack 通知の Webhook → Bot Token 移行 (2026-02-08)

Incoming Webhook は設定が簡単だが、URL管理が煩雑。複数プロジェクトで共通の通知先を使う場合は Bot Token + `chat.postMessage` API に統一すると管理が容易:

```bash
# Webhook 方式（プロジェクトごとにURL管理が必要）
curl -s -X POST "$SLACK_WEBHOOK_URL" -H 'Content-Type: application/json' -d "$payload"

# Bot Token 方式（token + channel_id を共有）
curl -s -X POST "https://slack.com/api/chat.postMessage" \
    -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
    -H 'Content-Type: application/json' \
    -d "$payload"
```

**利点**: Bot Token は1つで全チャンネルに投稿可能。Webhook は URL ごとにチャンネル固定。

### kaigai-bbs.com スクレイピング構造 (2026-02-08)

マレーシア掲示板の投稿リストの HTML セレクタ:

- タイトル: `a.thread-title` (href = `/mys/thread/sell/view/{ID}/`)
- 日付: `span.thread-date`
- 価格: `span.price`
- 都市: `span.cities`
- カテゴリ: `span.categories`
- 要約: `div.thread-summary`
- 受付終了: `img.close` の有無
- 広告: `li.ads-thread` → スキップ対象
- ページネーション: `/mys/thread/sell/{page_num}`

### GitHub プライベートリポジトリの検索 (2026-02-08)

GitHub MCP ツールで自分のプライベートリポジトリを検索する場合:

- `user:@me` を使うと認証済みユーザーのリポジトリを検索できる
- 例: `mcp__github__search_repositories(query="user:@me mac")`
- ユーザー名が分からなくてもOK
