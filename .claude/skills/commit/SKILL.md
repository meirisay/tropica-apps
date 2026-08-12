---
name: commit
description: Commit changes to the Tropica Farm app (tropica-apps repo) following project conventions. Use when the user asks to commit, save to git, or before deploying.
---

# Commit — Tropica Farm

Active work branch is **`cadangan-17jul`** (all development happens here; `main` mirrors it for
deploys — see the `deploy` skill). The whole app is a single file: **`index.html`**.

## Steps

1. **Review the change first:** `git status` then `git diff` (or `git diff --stat`). Understand what changed before writing the message — don't commit blind.
2. **Confirm the branch:** `git branch --show-current` should be `cadangan-17jul`. If it's `main`, switch back (`git checkout cadangan-17jul`) — never develop directly on `main`.
3. **Stage and commit** with a clear message:
   - First line: concise summary (Indonesian is fine — it matches the repo history).
   - Body: short bullet points of what & why when the change is non-trivial.
   - **End every commit message with:**
     ```
     Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
     ```
4. **Do not push or deploy from here** unless the user asks — pushing to `main` auto-deploys to the live site. Use the `deploy` skill when they want it live.

## Conventions & guardrails
- Commit only when the user asks.
- No secrets: the Supabase **anon** key in `index.html` is safe; **never** commit a `service_role` key.
- `.gitignore` already covers `.DS_Store` and `*.log`.
- Signature images and other personal media are stored in Supabase (`kv_store`), not committed to the repo.
