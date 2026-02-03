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
