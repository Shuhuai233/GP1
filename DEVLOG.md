# GP1 Devlog

## 2026-04-22 — Project Bootstrap

### What was done
- Initialized git repository locally
- Created GitHub repo at https://github.com/Shuhuai233/GP1 (public)
- Pushed initial commit with README, .gitignore, and OpenCode agent configs

### Issues encountered
1. **GitHub CLI auth**: First two tokens lacked `read:org` scope, which `gh auth login --with-token` requires. Third token worked.
2. **Git identity not configured**: `git commit` failed because no `user.name`/`user.email` was set on this machine. Configured locally (repo-level) using GitHub username and noreply email.
3. **Push failures**: `gh repo create --push` hit a TLS error on first attempt. Subsequent `git push` timed out due to credential helper issues. Resolved by temporarily embedding the token in the remote URL, then cleaning it after push.

### Notes
- Remote is set to HTTPS. If SSH is preferred later, run: `git remote set-url origin git@github.com:Shuhuai233/GP1.git`
- **Security reminder**: Three personal access tokens were exposed in the chat session. All three should be revoked at https://github.com/settings/tokens and replaced if needed.
- The project has no `project.godot` yet — it will be created when the project is first opened in the Godot editor.

### Next steps
- Open project in Godot editor to generate `project.godot`
- Begin building the game
