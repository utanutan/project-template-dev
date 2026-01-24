# Code Review Checklist

**Reviewer:** Review-Guardian
**Date:** [YYYY-MM-DD]
**PR/Commit:** [リンク or ID]
**Author:** [実装者]

---

## 1. Security Check
- [ ] 入力バリデーションが適切
- [ ] SQLインジェクション対策
- [ ] XSS対策
- [ ] 機密情報がハードコードされていない
- [ ] 認証・認可の実装が正しい

## 2. Code Quality
- [ ] DRY原則を遵守
- [ ] 関数・メソッドが単一責任
- [ ] 命名が明確で一貫性がある
- [ ] マジックナンバーがない
- [ ] 適切なコメント・ドキュメント

## 3. Error Handling
- [ ] エラーハンドリングが適切
- [ ] エッジケースを考慮
- [ ] ログ出力が適切

## 4. Testing
- [ ] ユニットテストが存在
- [ ] テストカバレッジが十分
- [ ] 境界値テストを含む

## 5. Performance
- [ ] 不要なループ・計算がない
- [ ] N+1問題がない
- [ ] メモリリークの懸念がない

---

## Review Result
- [ ] **Approved** - マージ可
- [ ] **Request Changes** - 修正必要
- [ ] **Comment** - コメントのみ

### Feedback
[具体的なフィードバック]

### Required Changes (if any)
1. [修正点1]
2. [修正点2]
