# User Management Template

Node.js + Express によるユーザー認証・管理の再利用可能なテンプレート。

## 含まれるもの

| フォルダ | 内容 |
|----------|------|
| `src/` | 実装コード（Express + SQLite） |
| `spec/` | 設計・実装プラン |
| `research/` | 技術調査資料 |
| `learning/` | 技術解説ドキュメント |

## 技術スタック

- **Backend**: Node.js + Express
- **Database**: SQLite (better-sqlite3)
- **Auth**: bcrypt + express-session + Google OAuth

## 使用方法

```bash
./projects/scripts/init-project.sh my-app --template user-mgmt
```

## セットアップ後

```bash
cd projects/my-app/src
npm install
cp .env.example .env
node server.js
```
