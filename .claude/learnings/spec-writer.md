# spec-writer - 知見ファイル

過去のプロジェクトで得た知見を蓄積するファイル。

---

## 知見一覧

### OpenClaw セットアップドキュメント設計 (2026-02-07)

**ドキュメント構成:**
- `setup-guide.md` - ユーザー向けセットアップ手順（Phase 1-A～1-E）
- `operations.md` - 日常運用・メンテナンスチェックリスト
- `troubleshooting.md` - エラー対処ガイド（症状→原因→対処のフォーマット）

**設計ポイント:**
- Phase に沿った段階的な説明（実装プランとの対応関係を明示）
- 「外部サービス設定」と「ローカル環境構築」を明確に分離
- 複数の技術ステップ（Cloudflare, Slack, Docker）を並行実行可能に構成
- bash/PowerShell コマンドはコピペ実行可能な形で提供
- トラブルシューティングは「症状 → 診断コマンド → 対処」フォーマットで統一

**表記法:**
- プレースホルダーは明示的に `yourdomain.com`, `C...` 形式で記載
- Windows/WSL2 の両方のコマンドを記載
- 環境変数は `.env` から参照する設計で統一
- `docker-compose.yml` はインライン記載（完全性確保）

**フェーズ2以降への対応:**
- Cron Jobs は Phase 2 以降として明示
- Tool Policy 詳細設定はフェーズ2の項として区別
- 現在の制限事項（sandbox mode: all など）を明記

**ドキュメント間の相互参照:**
- setup-guide.md → docs/operations.md で日常運用に引き継ぎ
- operations.md → docs/troubleshooting.md でエラー対処に引き継ぎ
