---
name: deploy
description: Deploy the Tropica Farm app to the live site (tropicafarm.netlify.app) via Git. Use when the user asks to deploy, publish, "naikkan ke situs", "push live", or update the live app.
---

# Deploy — Tropica Farm (Git → Netlify auto-deploy)

**Hosting:** Netlify, site **https://tropicafarm.netlify.app**, connected to GitHub repo
`meirisay/tropica-apps` (remote `origin`, over **SSH**). **Every push to `main` auto-builds &
deploys** — `netlify.toml` publishes ONLY `index.html`. There is **no manual drag-drop anymore.**

Branches: active work lives on **`cadangan-17jul`**; **`main`** mirrors it and is the deploy branch.

## Steps

1. **Commit pending changes** on `cadangan-17jul` first (see the `commit` skill). Working tree must be clean before merging.
2. **Bump the version badge** so the deploy is verifiable. In `index.html`, edit the login line:
   `Versi: Cetak vX.Y (tgl) — <ringkas>` → a new value (e.g. bump vX.Y and update the note). Commit it on `cadangan-17jul`.
3. **Merge to main and push:**
   ```bash
   git checkout main
   git merge cadangan-17jul            # fast-forward
   git push origin main                # ← this triggers Netlify auto-deploy
   git checkout cadangan-17jul
   git push origin cadangan-17jul
   ```
4. **Netlify auto-deploys in ~1–2 minutes** (no drag-drop).
5. **Verify** — poll until the live badge matches the new version (build takes ~1 min). Do NOT use a foreground `sleep`; run the poll in the background:
   ```bash
   for i in $(seq 1 12); do
     v=$(curl -s --max-time 15 https://tropicafarm.netlify.app | grep -o "Versi: [^<]*" | head -1)
     echo "$(date +%T) $v"; echo "$v" | grep -q "vX.Y" && { echo OK; break; }; sleep 20
   done
   ```
   Confirm it shows the new version (optionally also grep a code marker of the new feature).

## Troubleshooting
- **Site unchanged after ~3 min:** open Netlify dashboard → Deploys, check for a failed/queued build; confirm production branch = `main` and that the build command comes from `netlify.toml` (`mkdir -p _site && cp index.html _site/index.html`, publish `_site`).
- **Push asks for a GitHub username/password:** the remote got reset to HTTPS. Fix:
  `git remote set-url origin git@github.com:meirisay/tropica-apps.git` (SSH key for user `meirisay` is already trusted).
- **Data safety:** all data is in Supabase; deploy only updates the frontend (`index.html`) and never touches data. The Supabase anon key in the file is safe to host publicly; never commit/publish a service_role key.
- **Docs/SQL stay private from the site:** `netlify.toml` publishes only `index.html`, so `*.md` and `database/*.sql` are NOT served publicly — but they ARE in the GitHub repo (keep the repo Private if that matters).
