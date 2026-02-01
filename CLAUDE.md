# Antigravity Life OS - オペレーション手順

## 新規プロジェクト開始手順

### Step 1: プロジェクト作成

```bash
./projects/scripts/init-project.sh <project-name> --type dev
```

### Step 2: PRP作成

`projects/<project-name>/docs/PRP.md` に要件を記載する。

### Step 3: PMエージェントをtmuxで起動

**重要**: `launch-agents.sh` はtmuxセッション外から実行するとnohupフォールバックになる。
tmuxセッションを直接作成して起動すること。

```bash
tmux new-session -d -s <session-name> -n pm \
  -c /home/serveruser/workspace/project-template-dev/projects/<project-name> \
  "claude --dangerously-skip-permissions 'あなたは Project-Manager です。docs/PRP.md を読み、プロジェクトを完遂してください。'; exec bash"
```

確認:
```bash
tmux ls
```

### Step 4: ユーザー確認の監視

PMエージェント起動後、10秒間隔でtmux画面をキャプチャし、ユーザー確認要求を検知する。

```bash
for i in $(seq 1 60); do
  sleep 10
  output=$(tmux capture-pane -t <session-name>:pm -p -S -20 2>&1)
  echo "=== Check $i ($(date +%H:%M:%S)) ==="
  echo "$output" | tail -15
  if echo "$output" | grep -qiE '(Yes/No|confirm|確認|approve|選択|どちらを|よろしいですか|待機中|waiting for|user input|Question)'; then
    echo "*** USER CONFIRMATION DETECTED ***"
    break
  fi
done
```

このコマンドはバックグラウンドで実行し、確認が検出されたらユーザーに報告する。

### Step 5: 完了後のプッシュ

`projects/` ディレクトリは親リポジトリの `.gitignore` で除外されている。
各プロジェクトは独立リポジトリとして管理する。

```bash
cd projects/<project-name>
git init
git config user.name "carpediem"
git config user.email "nakanisi.yuuta@gmail.com"
echo "agent-pm.log" >> .gitignore
git add -A
git commit -m "feat: Initial implementation of <project-name>"
gh repo create <project-name> --private --source=. --push
```

## 注意事項

- 新規プロジェクト開始時は必ず `QUICKSTART.md` の手順に従う
- PMエージェントはtmuxセッション内で起動する（launch-agents.sh のnohupフォールバックを避ける）
- ユーザー確認の監視はバックグラウンドで10秒間隔ポーリング
- `projects/` 配下は親リポジトリから除外されるため、独立リポジトリとして `gh repo create` する
