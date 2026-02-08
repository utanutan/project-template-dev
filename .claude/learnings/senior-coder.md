# senior-coder - 知見ファイル

過去のプロジェクトで得た知見を蓄積するファイル。

---

## 知見一覧

### OpenClaw インフラ構築 (2026-02-07)

**プロジェクト**: OpenClaw Self-Host Infrastructure Setup

**実装したもの**:
- Docker Compose構成（Gateway + Cloudflare Tunnel）
- 環境変数テンプレート（.env.example）
- OpenClaw設定ファイル（config.json - pure JSON形式）
- Windows自動起動スクリプト（start.bat + setup-task-scheduler.ps1）
- ヘルスチェックスクリプト（WSL2用）

**技術的知見**:

1. **JSON5 vs Pure JSON**
   - OpenClaw config.jsonは純粋なJSON形式（JSON5コメント非対応）
   - 環境変数参照は `${VAR}` 形式でサポート
   - コメントはREADMEに記載し、設定ファイル本体はコメントなし

2. **Docker Compose ネットワーク分離**
   - プロジェクト名が異なれば自動的にネットワーク名にプレフィックス
   - `openclaw_openclaw-internal` のように名前空間が分離される
   - 既存環境との完全分離を実現

3. **Windows バッチスクリプトのエラーハンドリング**
   - `if %errorlevel% neq 0` でエラー検出
   - ログファイルへの記録と画面表示を両立
   - Docker Desktop起動待機にタイムアウト実装（5分、30回試行）

4. **PowerShell Task Scheduler API**
   - `New-ScheduledTaskTrigger -AtLogOn` でログオン時実行
   - `.Delay = "PT30S"` で遅延実行（Docker Desktop初期化待ち）
   - `-RunLevel Highest` で管理者権限実行

5. **健康性チェックの実装パターン**
   - Docker healthcheck: `curl -sf http://localhost:18789/health`
   - `start_period` で初期化猶予時間を設定（30秒）
   - `depends_on: condition: service_healthy` で起動順序制御

6. **セキュリティベストプラクティス**
   - Gateway bind: `loopback`（コンテナ内は0.0.0.0、ホスト側で127.0.0.1バインド）
   - Sandbox mode: `all`, scope: `session` で最大隔離
   - Tool Policy: browser/processを deny、最小権限の原則
   - .envファイルパーミッション: 600（読み書き所有者のみ）

7. **Windows + WSL2 ハイブリッド環境**
   - バッチスクリプト: Windows側で実行（タスクスケジューラ用）
   - シェルスクリプト: WSL2で実行（Docker CLI操作用）
   - パス表記: `%USERPROFILE%\openclaw` (Windows) vs `~/openclaw` (WSL2)

**ディレクトリ構造設計**:
```
src/
├── docker-compose.yml       # P0: コンテナオーケストレーション
├── .env.example             # P0: 環境変数テンプレート
├── .gitignore               # P0: Git除外設定
├── config/
│   └── config.json          # P0: OpenClaw設定（pure JSON）
├── workspace/               # P0: エージェント作業領域
├── scripts/
│   ├── start.bat            # P1: Windows起動スクリプト
│   ├── setup-task-scheduler.ps1  # P1: 自動起動設定
│   └── health-check.sh      # P1: ヘルスチェック
└── logs/                    # P1: 起動ログ
```

**注意点**:
- `docker-compose.yml` の環境変数参照は `${VAR}` 形式
- Windows Task Scheduler は管理者権限必須
- Docker socket マウント（`/var/run/docker.sock`）はsandbox機能に必須
- Cloudflare Tunnel token は長文なので環境変数経由必須

### Slack Interactive Notification System (2026-02-08)

**プロジェクト**: slack-interactive-notify

**実装したもの** (Phase 2-5):
- 環境変数管理モジュール (config.py)
- セッションマッピングストレージ (session_store.py)
- Slack chat.postMessage 通知送信 (notify.py)
- Hook スクリプト改修 (claude-notify.sh)
- Socket Mode デーモン (responder.py) - Phase 4
- プロセス管理スクリプト (start/stop-responder.sh) - Phase 5
- セットアップドキュメント (docs/setup-slack-app.md) - Phase 5

**技術的知見**:

1. **Python 環境変数の優先順位管理**
   - 優先度: 環境変数 > プロジェクト .env > テンプレート notification.env
   - python-dotenv を使わず自前パース（依存なしで軽量）
   - 単純な `KEY=VALUE` 形式のパース、クォート除去対応

2. **fcntl.flock による並行アクセス制御**
   - JSON ファイルへの書き込みは `fcntl.LOCK_EX` (排他ロック)
   - 読み取りは `fcntl.LOCK_SH` (共有ロック)
   - ロック取得・解放を try-finally で確実に実行

3. **Slack SDK の使い分け**
   - `slack_sdk.WebClient`: chat.postMessage, reactions.add
   - `slack_bolt`: Socket Mode デーモン (次フェーズで使用)
   - Bot Token (xoxb-) と App Token (xapp-) は別物

4. **Hook スクリプトの段階的移行パターン**
   - 既存の Incoming Webhook ロジックをフォールバックとして残す
   - Bot Token 検出時のみ Python に分岐
   - TMUX 情報は環境変数でエクスポート (`TMUX_SESSION`, `TMUX_WINDOW`)
   - `uv run python` で仮想環境を意識せずPython実行

5. **Claude Code Hook JSON の構造**
   - stdin から JSON を受け取る
   - `transcript_path` から実際の確認内容を抽出可能
   - JSONL 形式、`type: "assistant"` の `tool_use` を抽出
   - notification_type: `permission_prompt`, `idle_prompt`, `elicitation_dialog`

6. **Slack Block Kit メッセージ構成**
   - `text` フィールド（必須）: 通知プレビュー用フォールバック
   - `blocks` フィールド（推奨）: リッチなメッセージ表示
   - `chat.postMessage` のレスポンスから `ts` を取得 → thread_ts として使用

7. **エラーハンドリングポリシー**
   - 通知スクリプトは常に exit 0 で終了
   - Hook 失敗が Claude Code のワークフローを中断させない
   - 警告は stderr に出力、通知送信失敗でも処理継続

**ディレクトリ構造**:
```
slack-interactive-notify/
├── src/
│   ├── config.py           # 環境変数管理
│   ├── session_store.py    # マッピング管理
│   ├── notify.py           # 通知送信
│   └── responder.py        # Socket Mode デーモン
├── scripts/
│   ├── claude-notify.sh    # Hook エントリポイント
│   ├── start-responder.sh  # デーモン起動
│   └── stop-responder.sh   # デーモン停止
├── docs/
│   ├── PRP.md              # 要件定義
│   └── setup-slack-app.md  # Slack App セットアップ手順
├── pyproject.toml          # uv 依存管理
└── .env.example            # 設定テンプレート
```

8. **slack_bolt Socket Mode デーモンの実装パターン** (Phase 4):
   - `App(token=bot_token)` + `SocketModeHandler(app, app_token)`
   - イベントハンドラは `@app.event("message")` デコレータで登録
   - bot_id 存在チェックで自分のメッセージを除外
   - thread_ts 存在チェックでスレッド返信のみ処理
   - SessionStore でマッピング検索 → tmux send-keys で入力送信
   - Slack リアクション追加で応答確認（✅ 成功、❌ 失敗）

9. **tmux send-keys の安全な呼び出し方** (Phase 4):
   - subprocess.run のリスト形式を使用（シェルインジェクション防止）
   - テキストはそのまま引数として渡す（エスケープ不要）
   - `"Enter"` を最後の引数として渡す（改行送信）
   - サニタイゼーション: 改行除去、1000文字制限
   - セッション存在確認: `tmux has-session -t <session>`

10. **プロセス管理スクリプトのパターン** (Phase 5):
    - PIDファイル (`/tmp/slack-responder.pid`) で二重起動防止
    - `.env` 読み込み: `set -a; source .env; set +a`
    - 必須環境変数チェック（SLACK_BOT_TOKEN, SLACK_APP_TOKEN）
    - nohup によるバックグラウンド実行 + PIDファイル保存
    - Graceful shutdown: SIGTERM/SIGINT ハンドラで SocketModeHandler.close()

11. **構造化ログ出力パターン** (Phase 4):
    - JSON lines 形式で標準出力に出力
    - フィールド: `ts` (ISO 8601), `level`, `msg`, 追加コンテキスト
    - `flush=True` で即座にバッファフラッシュ
    - nohup のログファイルでそのまま解析可能

12. **Slack App セットアップの前提知識** (Phase 5):
    - Socket Mode 有効化で App-Level Token (xapp-) 取得
    - Bot Token Scopes: `chat:write`, `reactions:write`
    - Event Subscriptions: `message.channels`
    - チャンネルに Bot を招待必須（/invite）
    - Channel ID は URL またはチャンネル詳細から取得（C... 形式）

13. **pytest によるユニットテスト実装パターン** (Phase 6):
    - pytest + pytest-mock を dev 依存に追加
    - `pyproject.toml` に testpaths, pythonpath 設定
    - `tmp_path` fixture でテンポラリファイル作成（自動クリーンアップ）
    - `monkeypatch` fixture で環境変数モック
    - `@patch` デコレータで外部依存（Slack API, subprocess）をモック
    - テストクラスで機能ごとにグルーピング（Test〇〇）
    - 65テストケースで全モジュールをカバー

14. **Slack Bolt App のテストパターン** (Phase 6):
    - `App` クラス自体をモックし、token 検証をスキップ
    - イベントハンドラのユニットテストは複雑すぎるため、create_app の結果のみ検証
    - send_to_tmux など個別関数をテスト対象にする
    - 実際のハンドラロジックは統合テストで確認

15. **datetime.utcnow() 非推奨対応** (Phase 6):
    - `datetime.utcnow()` は Python 3.12+ で非推奨
    - `datetime.now(timezone.utc)` を使用
    - `from datetime import timezone` を明示的にインポート

**テスト構成**:
```
tests/
├── test_config.py           # 20テスト: 環境変数読み込み・検証
├── test_session_store.py    # 10テスト: マッピングの保存・取得・クリーンアップ
├── test_notify.py           # 24テスト: 通知送信・フォールバック
└── test_responder.py        # 11テスト: サニタイゼーション・tmux送信
```

**実行コマンド**:
```bash
uv add --dev "pytest>=8.0.0" "pytest-mock>=3.12.0"
uv run pytest -v
```

**次フェーズの注意点**:
- 統合テスト: 実際の Slack App とtmuxセッションで動作確認
- ドキュメント整備: README.md にセットアップ手順を記載

16. **Slack リアクション応答機能の実装パターン** (2026-02-08):
    - `@app.event("reaction_added")` でリアクションイベントを購読
    - `event.item.ts` が通知メッセージの ts（SessionStore のキー）に対応
    - リアクション名（`white_check_mark`, `x` 等）を定数マッピングで応答テキストに変換
    - Bot自身のリアクションを除外: `app.client.auth_test()` で bot_user_id を取得し、`event.user` と比較
    - 応答済みフラグ (`responded: true`) で重複応答を防止
    - permission_prompt には "yes"/"no"、idle_prompt にはスレッド返信を使い分ける
    - Slack App Event Subscriptions に `reaction_added` を追加する必要がある（手動設定）

**リアクション応答マッピング**:
```python
REACTION_RESPONSES = {
    "white_check_mark": "yes",
    "heavy_check_mark": "yes",
    "x": "no",
    "no_entry_sign": "no",
}
```

**テストケース**:
- ✅ リアクションで "yes" 送信
- ❌ リアクションで "no" 送信
- ☑️ リアクションでも "yes" 送信
- 未定義リアクション（thumbsup 等）は無視
- マッピング未存在のメッセージへのリアクションは無視
- 応答済みメッセージへのリアクションは無視
- Bot自身のリアクションは無視
