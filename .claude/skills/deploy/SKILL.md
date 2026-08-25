---
name: deploy
description: Deploy the Tropica Farm app to the live site (tropicafarm.netlify.app) via Git. Use when the user asks to deploy, publish, "naikkan ke situs", "push live", or update the live app.
---

# Deploy — Tropica Farm (Git → Netlify auto-deploy)

**Hosting:** Netlify, site **https://tropicafarm.netlify.app**, connected to GitHub repo
`meirisay/tropica-apps` (remote `origin`, over **SSH**). **Every push to `main` auto-builds &
deploys** — `netlify.toml` publishes ONLY `index.html`. There is **no manual drag-drop anymore.**

## Branches — read this before touching git

**Work happens directly on `main`, and `main` is the deploy branch.** Commit there and push.

`cadangan-17jul` is a **stale snapshot from July 2026, not a work branch.** As of 24 Aug 2026 the
two have **diverged**: `main` is 23 commits ahead, and `cadangan-17jul` holds one commit `main`
never got (`6ba4952`, a gitignore chore). **`git merge --ff-only` between them fails.**

- Do **not** try to fast-forward or "mirror" `cadangan-17jul` as part of a deploy — it is not
  required and it will fail.
- Reconciling the two branches needs `git merge --no-ff` and is a **decision for the user**, not a
  deploy step. Ask first; never do it silently.

## Steps

1. **Commit pending changes on `main`** (see the `commit` skill). Do not commit stray untracked
   files — `git add` the specific files you changed. (`_dotest.html` in the working tree is the
   user's scratch file; leave it alone.)
2. **Bump the version badge** so the deploy is verifiable. In `index.html` there is exactly one
   line like `Versi: v4.5` (around line 476, inside `<p class="login-sub">`). Bump the minor
   number. Keep the format plain — just `Versi: vX.Y`, no date or note.
3. **Run any SQL the change needs, BEFORE pushing.** Frontend deploys instantly, so a feature that
   expects a new column will break the live site if the migration has not run yet. Migrations go
   through the Supabase SQL Editor (see the rekonsiliasi memory for how to drive it). Also check
   `transactions_jenis_check` if a new `jenis` value was introduced — the CHECK constraint must
   list it or every insert fails.
4. **Push:**
   ```bash
   git push origin main                # ← this triggers Netlify auto-deploy
   ```
5. **Netlify auto-deploys in ~1 minute** (no drag-drop).
6. **Verify** — poll the live badge until it matches the new version. Do NOT use a foreground
   `sleep`; the loop below is fine because it exits as soon as the version flips:
   ```bash
   for i in $(seq 1 12); do
     v=$(curl -s --max-time 15 https://tropicafarm.netlify.app | grep -o "Versi: [^<]*" | head -1)
     echo "$(date +%T) $v"; echo "$v" | grep -q "vX.Y" && { echo OK; break; }; sleep 20
   done
   ```
   Then grep the served HTML for a marker of the new code (a new function name works well) to
   confirm the real change shipped, not just the badge.

## Troubleshooting
- **Site unchanged after ~3 min:** open Netlify dashboard → Deploys, check for a failed/queued build; confirm production branch = `main` and that the build command comes from `netlify.toml` (`mkdir -p _site && cp index.html _site/index.html`, publish `_site`).
- **Push asks for a GitHub username/password:** the remote got reset to HTTPS. Fix:
  `git remote set-url origin git@github.com:meirisay/tropica-apps.git` (SSH key for user `meirisay` is already trusted).
- **Data safety:** all data is in Supabase; deploy only updates the frontend (`index.html`) and never touches data. The Supabase anon key in the file is safe to host publicly; never commit/publish a service_role key.
- **Docs/SQL stay private from the site:** `netlify.toml` publishes only `index.html`, so `*.md` and `database/*.sql` are NOT served publicly — but they ARE in the GitHub repo (keep the repo Private if that matters).
