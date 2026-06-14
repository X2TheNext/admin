# ATCHÉ Visuals — What's Left To Run

Everything below is the only thing standing between tonight's code and live. Two steps: SQL (one-time, only if you haven't already run the AI Edit block) and a git push.

## 1. SQL — only if you haven't run this yet

If you already ran the **"AI-Enhanced Edit add-on (June 2026)"** SQL block from `ATCHE-Visuals-Setup.md` (the one that adds `ai_edit_*` columns and replaces `request_payment_confirmation`), **skip this** — nothing new is needed for tonight's fixes. The session-delete and AI-edit-upload features both reuse policies that are already in that file (`owner_all` for deleting rows, `auth_delete_visuals` for removing storage files, `auth_upload_visuals` for the AI edit upload).

If you haven't run it yet, open **Supabase → SQL Editor** (project `aayigsbmmdolvnicxacs`) and run the SQL block under "AI-Enhanced Edit add-on (June 2026)" in `ATCHE-Visuals-Setup.md`.

## 2. Push everything to GitHub → Vercel auto-deploys

From your ATCHÉ project folder in Terminal:

```
cd ~/Documents/Claude/Projects/ATCHÉ
git add .
git commit -m "AI-Enhanced Edit add-on + Studio fixes: payment scroll, thumbnail lightbox, session delete"
git push
```

Live in ~60 seconds. This one push covers:

- **Client gallery** (`atche-visuals.html`) — AI-Enhanced Edit add-on (theme picker, combined pricing/QR, pending + delivered result with download).
- **Studio** (`atche-visuals-studio.html`) — AI Edit fulfillment banner + upload, "Open →" now scrolls to/flashes the Confirm Paid banner when one's pending, scrollable thumbnail grid with click-to-enlarge lightbox (photos + reels), and a Delete action on closed sessions (wipes storage + row).

## After it's live — quick smoke test

- Open Studio, start a test session, upload a photo.
- On the client gallery, toggle the AI-Enhanced Edit add-on, confirm the total/QR updates, tap "I've sent payment."
- Back in Studio, tap **Open →** on that session — it should scroll straight to a flashing **Confirm Paid** banner, not the QR.
- Tap **Confirm Paid** — gold "AI Edit owed" banner should appear with the theme + base photo.
- Click a thumbnail — full-size lightbox should open; scroll the grid if there are more than ~8 items.
- Close the session, then use **Delete** to remove it — confirm it disappears from the list.
