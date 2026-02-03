# Central Monitoring Infrastructure

プロジェクト横断のログ収集・監視基盤。

## コンポーネント

### Victoria Logs

軽量・高性能なログ収集サーバー。Loki互換APIを提供。

```bash
# 起動
./victoria-logs/start.sh start

# 停止
./victoria-logs/start.sh stop

# ステータス確認
./victoria-logs/start.sh status
```

**エンドポイント:**
- Web UI: http://localhost:9428
- Loki Push API: http://localhost:9428/insert/loki/api/v1/push
- Query API: http://localhost:9428/select/logsql/query

## プロジェクトからのログ送信

各プロジェクトは Promtail を使用してログを送信する。

### Promtail 設定例

```yaml
clients:
  - url: http://localhost:9428/insert/loki/api/v1/push

scrape_configs:
  - job_name: my-project
    static_configs:
      - targets: [localhost]
        labels:
          job: my-project
          __path__: /path/to/logs/*.log
```

## ディレクトリ構造

```
infra/monitoring/
├── README.md
└── victoria-logs/
    ├── start.sh          # 起動スクリプト
    ├── victoria-logs-prod # バイナリ
    ├── vlogs-data/       # ログデータ
    ├── vlogs.pid         # PIDファイル
    └── vlogs.log         # サーバーログ
```
