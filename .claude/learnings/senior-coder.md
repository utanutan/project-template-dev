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
