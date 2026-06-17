# ATCHÉ Visuals — Photographer's Money Manual

The goal every night: zero unpaid sessions. This is how you run the app to maximize revenue per door.

---

## Before You Arrive

- **Charge your phone to 100%.** Studio runs in your browser — no app to install, but you need battery.
- **Open Studio** at your deployment URL and sign in while you're on Wi-Fi. The session loads fast; Cash App and Supabase both need signal.
- **Know your packages.** The client gallery shows:
  - Quick Shot — $10 (1 photo)
  - The Bundle — $30 (up to 8 photos)
  - Full Night — $60 (every photo + reel)

---

## The Session Flow (Every Client, Every Time)

### Step 1 — Create the session immediately after shooting

Don't wait until the end of the night. Create the session right after you finish their set.

1. Open Studio → tap **Create Session**
2. **Label**: use their name — "Jasmine" or "Tiffany + crew." This is what shows in their "Hey ___" message. A name converts better than nothing.
3. **Contact**: get their phone number or IG handle on the spot. This is your only way back to them if they walk away without paying. A phone number lets you text the link directly from Studio.
4. Hit **Create** — you get a 5-character code and QR instantly.

### Step 2 — Upload while they're standing there

Upload their photos immediately — don't batch uploads at the end of the night.

**Why:** if they see their gallery before they leave, conversion is 3–4x higher. They're still in the moment, still feel good about how they look.

1. Tap the drop zone → select their photos/video
2. Previews generate in ~10 seconds with the watermark
3. Upload and show them the QR right there

### Step 3 — Show them the QR in person

Don't just text the link. **Turn your phone screen toward them and let them scan the QR from Studio.** They see their gallery open instantly on their phone.

Say: *"Your photos are right there — pick your favorites and grab them before the night ends."*

Then text them the link as a backup: tap **Notify Client** in Studio (it sends a pre-written message with the link).

### Step 4 — Watch for Cash App

Keep Studio open on your phone throughout the night. When a client pays:

1. You get a Cash App notification
2. Studio shows that session as **Confirm $X** — pulsing green
3. Tap **Confirm Paid** — their download unlocks instantly, no refresh needed on their end

**Never skip this step.** Nothing unlocks until you confirm. The client flagging "I've sent payment" does NOT unlock their gallery — it only notifies you.

---

## The Situations You'll Hit & How to Handle Them

### Client paid Cash App but never tapped "I've sent payment"

This happens. They paid, walked off, and assumed it unlocked.

1. Find their session in Studio → tap **···** → this won't appear yet... actually tap the session row — if you see no Confirm button, use **Mark Paid** (the muted pill on their row)
2. Enter the package and amount → hit **Mark Paid**
3. Their gallery unlocks immediately

Text them: *"Hey, you're all set — your photos just unlocked, tap the link to download."*

### Client walked away without paying

1. Tap **···** on their session row → **Send Feedback**
2. This texts/emails them a 60-second pilot survey with a free juice offer for next time
3. It keeps ATCHÉ in their mind and turns a lost sale into a warm lead

Also follow up with the gallery link directly: *"Hey, your photos are still live — grab them tonight before the session closes."*

### Client says "I'll do it later"

Close the session (tap **Close Session** at the bottom of their card). It stays in the list — you can reopen it via **···** → **Reopen** if they come back. Closed sessions can't receive new payment requests, which keeps your active list clean.

---

## The AI Edit Showcase — Your Pre-Sell Tool

Before the night even starts, share the AI Edit page: **`atche-ai-edit.html`** (or your deployed URL). It shows a drag-to-reveal before/after slider, all 6 themes with real preview images, and the $20 CTA.

Post it to your story. DM it to people coming out. Show it on your phone when pitching clients in person. By the time they're scanning your QR at the venue, they already want the edit.

---

## The AI Edit Upsell — Your Highest-Margin Add-On

The AI-Enhanced Edit adds $20 to any order. You generate it after the night using Higgsfield — takes about 5 minutes per client.

**Themes (6 options, client picks at checkout):**
- Your Name in Lights — marquee billboard, neon, crowd
- Private Jet — tarmac, designer luggage, champagne
- Sports Car — supercar at golden hour, coastal road
- VIP Section — velvet ropes, bottle service, sparklers
- Penthouse Night — floor-to-ceiling windows, city skyline
- Red Carpet — step-and-repeat, paparazzi flashes

**How to pitch it in person:**
*"I also do an AI edit — puts you in a private jet, VIP section, red carpet, wherever you want. Pick your scene, add $20 to your order, and it drops into your gallery automatically."*

**Best candidates:** clients buying The Bundle or Full Night. Quick Shot buyers rarely convert on the add-on.

**After the night — delivering AI edits:**
1. Open Studio → open the session
2. The gold "AI Edit owed" banner shows the theme + which photo to use as the base
3. Tap **Copy Prompt** — paste it into Higgsfield
4. Generate, download the result
5. Tap **Upload AI Edit** in Studio — it drops into their gallery automatically and sends them nothing (they'll see it next time they open their link)

---

## Revenue Targets by Night

| Sessions | Avg package | AI edit attach rate | Target |
|----------|-------------|---------------------|--------|
| 5 | $30 | 0% | $150 |
| 5 | $30 | 40% | $190 |
| 8 | $45 | 40% | $432 |
| 10 | $45 | 50% | $550 |

The single biggest lever: **show them the gallery before they leave.** That one habit moves avg package from $30 to $60+.

---

## Package Pitch by Client Type

**Solo performer / artist** → Full Night ($60). They care about content for their brand. Lead with the reel and the AI edit upsell.

**Friend groups** → The Bundle ($30). Sell the shareable moment — "everyone in the group gets all the photos."

**Someone who seems price-sensitive** → Quick Shot ($10) to get them in. Once they see their photo full-res, they usually upgrade. Say: *"That's just one — for $20 more you get everything from tonight."*

**Someone in a rush** → QR scan, The Bundle or Full Night, done. Don't oversell. Fast and frictionless beats a pitch they walk out on.

---

## End of Night Checklist

- [ ] All sessions confirmed paid or closed
- [ ] Anyone unpaid → Send Feedback (tap ··· on their row)
- [ ] AI edits delivered for any add-on sessions (or queued for tomorrow morning)
- [ ] Revenue total showing correctly in the Tonight dashboard
- [ ] Sign out of Studio

---

## Quick Reference

| Action | Where |
|--------|-------|
| Create session | Studio → top card |
| Upload photos | Studio → active session → drop zone |
| Send gallery link | Studio → Notify Client |
| Confirm payment | Studio → session list → Confirm Paid (pulsing) |
| Client paid but no request | Studio → session row → Mark Paid |
| Deliver AI edit | Studio → active session → AI Edit banner → Upload |
| Follow up with non-buyer | Studio → ··· → Send Feedback |
| Close finished session | Studio → active session → Close Session (bottom) |
| Reopen closed session | Studio → ··· → Reopen |
| Client gallery URL | `atche-visuals.atcheofficial.com/?s=CODE` |
