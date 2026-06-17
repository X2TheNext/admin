-- ============================================================
-- ATCHÉ · Monet Howell Admin Operations Database
-- Supabase SQL Schema
-- ============================================================

-- ── PIPELINE STAGES ────────────────────────────────────────
CREATE TABLE pipeline_stages (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT UNIQUE NOT NULL,        -- "New Lead", "Contacted", "Interested", etc.
  sort_order  INT NOT NULL DEFAULT 0,
  description TEXT,
  created_at  TIMESTAMPTZ DEFAULT now()
);

INSERT INTO pipeline_stages (name, sort_order, description) VALUES
  ('New Lead',        1, 'Just found or just reached out for the first time. No response yet. Schedule a first follow-up in 3–5 days.'),
  ('Contacted',       2, 'First message sent. Waiting on a reply. Follow up after 5–7 days of silence.'),
  ('Interested',      3, 'They responded positively or asked for more info. Move quickly — schedule a meeting or send the ATCHÉ pitch.'),
  ('Meeting Set',     4, 'Call or in-person meeting is booked. Confirm the day before. Add to Google Calendar.'),
  ('Proposal Sent',   5, 'Sent the ATCHÉ deck or rate sheet. Follow up in 3–5 days if no response.'),
  ('Negotiating',     6, 'In active discussion on rates, dates, or terms. Keep momentum.'),
  ('Active / Signed', 7, 'They are in. Switch from outreach to logistics coordination.'),
  ('On Hold',         8, 'Interested but not the right time. Check back in 4–6 weeks.'),
  ('Inactive',        9, 'No response after 3+ attempts, or they passed. Deprioritize but do not delete.');

-- ── CONTACT TYPES ─────────────────────────────────────────
CREATE TABLE contact_types (
  id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL              -- "Talent", "Venue Owner", "Photographer", "DJ", etc.
);

INSERT INTO contact_types (name) VALUES
  ('Talent / Model'),
  ('Photographer'),
  ('DJ'),
  ('Venue Owner'),
  ('Creative Partner');

-- ── CONTACTS (the roster) ──────────────────────────────────
CREATE TABLE contacts (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name      TEXT NOT NULL,
  ig_handle      TEXT,
  email          TEXT,
  phone          TEXT,
  city           TEXT,
  category       TEXT,                    -- e.g. "Model", "Venue", "Photographer"
  photo_url      TEXT,
  rating_notes   TEXT,                    -- collab impressions / rating
  notes          TEXT,                    -- general notes, context, referrals
  stage_id       UUID REFERENCES pipeline_stages(id),
  contact_type_id UUID REFERENCES contact_types(id),

  -- tracking
  source         TEXT,                    -- how they found ATCHÉ or who referred them
  date_added     TIMESTAMPTZ DEFAULT now(),
  last_contacted TIMESTAMPTZ,
  is_active      BOOLEAN DEFAULT true,    -- soft archive

  created_at     TIMESTAMPTZ DEFAULT now(),
  updated_at     TIMESTAMPTZ DEFAULT now()
);

-- Index for quick lookups
CREATE INDEX idx_contacts_stage ON contacts(stage_id);
CREATE INDEX idx_contacts_ig ON contacts(ig_handle);
CREATE INDEX idx_contacts_email ON contacts(email);

-- ── FOLLOW-UPS ─────────────────────────────────────────────
CREATE TABLE follow_ups (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contact_id    UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
  template_used TEXT,                     -- which message template was sent
  message_type  TEXT,                     -- "IG DM", "Text", "Email"
  status        TEXT DEFAULT 'pending',   -- "pending", "sent", "snoozed", "replied"
  due_date      DATE NOT NULL,
  sent_at       TIMESTAMPTZ,
  snoozed_until DATE,                     -- when +3d snooze should re-surface
  notes         TEXT,                     -- any reply context

  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_followups_due ON follow_ups(due_date) WHERE status = 'pending';
CREATE INDEX idx_followups_contact ON follow_ups(contact_id);

-- ── OUTREACH LOG (history of every message sent) ──────────
CREATE TABLE outreach_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contact_id  UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
  channel     TEXT NOT NULL,              -- "IG DM", "Email", "Text"
  template    TEXT,                       -- template name used
  message     TEXT,                       -- the actual message sent (optional log)
  sent_at     TIMESTAMPTZ DEFAULT now(),
  outcome     TEXT                        -- "no response", "replied", "bounced"
);

CREATE INDEX idx_outreach_contact ON outreach_log(contact_id);

-- ── EMAIL TEMPLATES ────────────────────────────────────────
CREATE TABLE email_templates (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT UNIQUE NOT NULL,       -- "First Outreach", "Follow-Up Check-in", etc.
  subject     TEXT,
  body        TEXT NOT NULL,
  when_to_use TEXT,                       -- usage guidance
  tip         TEXT,                       -- customization tip
  sort_order  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now()
);

INSERT INTO email_templates (name, when_to_use, tip, sort_order) VALUES
  ('👋 First Outreach',        'First time contacting someone cold — model, DJ, photographer, or venue owner.',                                    'Do not customize too much. The simple, direct version converts better than a long pitch.',              1),
  ('🔁 Follow-Up Check-in',   'They have not responded after 5–7 days.',                                                                        'One follow-up maximum before moving on. Keep it short and low-pressure.',                               2),
  ('📸 Booking Confirmation', 'A shoot or event is confirmed and you need to send logistics.',                                                    'Include date, time, location, and what they should bring or prepare.',                                   3),
  ('✦ Collab Pitch',          'Pitching a venue partnership or creative collaboration.',                                                           'Personalize the venue name and what specifically makes ATCHÉ the right fit for them.',                   4),
  ('💬 Relationship Check-in','Someone you have worked with who is going quiet. Keep the relationship warm.',                                       'Not a sales pitch. Just a genuine check-in. Makes a big difference long-term.',                          5),
  ('💵 Rate Inquiry',         'Asking about rates for a shoot, set, or service.',                                                                 'Keep it simple and professional. Do not over-explain ATCHÉ upfront — just ask the rate.',               6);

-- ── SHOOTS / PHOTOGRAPHY CALENDAR ──────────────────────────
CREATE TABLE shoots (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           TEXT NOT NULL,
  shoot_date      DATE NOT NULL,
  shoot_time      TIME,
  shoot_end       TIME,
  location        TEXT,
  address         TEXT,
  contact_id      UUID REFERENCES contacts(id),
  status          TEXT DEFAULT 'confirmed',  -- "confirmed", "tentative", "cancelled", "completed"
  google_cal_url  TEXT,                      -- link to event in Google Calendar
  notes           TEXT,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_shoots_date ON shoots(shoot_date);
CREATE INDEX idx_shoots_status ON shoots(status);

-- ── WEEKLY RECAPS (sent to Xavier) ────────────────────────
CREATE TABLE weekly_recaps (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  week_start      DATE NOT NULL,
  week_end        DATE NOT NULL,
  new_leads_added INT DEFAULT 0,
  follow_ups_sent INT DEFAULT 0,
  shoots_confirmed INT DEFAULT 0,
  shoots_discussing INT DEFAULT 0,
  venue_owners_priority TEXT,              -- venue owners worth prioritizing
  tools_issues     TEXT,                   -- anything broken or missing in the tools
  notes            TEXT,                   -- freeform recap
  sent_to_xavier   BOOLEAN DEFAULT false,
  sent_at          TIMESTAMPTZ,
  created_at       TIMESTAMPTZ DEFAULT now()
);

-- ── AUTOMATIC UPDATED_AT TRIGGER ──────────────────────────
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_contacts_updated
  BEFORE UPDATE ON contacts
  FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_follow_ups_updated
  BEFORE UPDATE ON follow_ups
  FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_shoots_updated
  BEFORE UPDATE ON shoots
  FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- ── USEFUL VIEWS ──────────────────────────────────────────

-- View: Overdue & Today's follow-ups (for Monet's daily queue)
CREATE VIEW followup_dashboard AS
SELECT
  f.id,
  f.contact_id,
  c.full_name,
  c.ig_handle,
  c.email,
  c.phone,
  ps.name          AS pipeline_stage,
  f.due_date,
  f.message_type,
  f.template_used,
  f.status,
  f.snoozed_until,
  CASE
    WHEN f.due_date < CURRENT_DATE AND f.status = 'pending' THEN 'overdue'
    WHEN f.due_date = CURRENT_DATE AND f.status = 'pending' THEN 'due_today'
    WHEN f.due_date <= CURRENT_DATE + INTERVAL '7 days' AND f.status = 'pending' THEN 'this_week'
    ELSE 'upcoming'
  END AS urgency
FROM follow_ups f
JOIN contacts c ON c.id = f.contact_id
LEFT JOIN pipeline_stages ps ON ps.id = c.stage_id
WHERE f.status IN ('pending', 'snoozed')
ORDER BY f.due_date ASC;

-- View: Contacts stuck in the same stage (for weekly pipeline review)
CREATE VIEW stuck_contacts AS
SELECT
  c.id,
  c.full_name,
  c.ig_handle,
  c.email,
  ps.name        AS stage,
  c.updated_at,
  EXTRACT(DAY FROM now() - c.updated_at)::INT AS days_since_updated
FROM contacts c
JOIN pipeline_stages ps ON ps.id = c.stage_id
WHERE c.is_active = true
  AND c.updated_at < now() - INTERVAL '14 days'
  AND ps.name NOT IN ('Active / Signed', 'Inactive')
ORDER BY c.updated_at ASC;

-- View: Contacts who went from Interested to silent
CREATE VIEW interested_gone_quiet AS
SELECT
  c.id,
  c.full_name,
  c.ig_handle,
  c.email,
  c.last_contacted,
  EXTRACT(DAY FROM now() - c.last_contacted)::INT AS days_since_contact
FROM contacts c
WHERE c.stage_id = (SELECT id FROM pipeline_stages WHERE name = 'Interested')
  AND c.last_contacted IS NOT NULL
  AND c.last_contacted < now() - INTERVAL '7 days'
  AND c.is_active = true
ORDER BY c.last_contacted ASC;

-- View: Upcoming shoots (next 14 days for calendar sync)
CREATE VIEW upcoming_shoots AS
SELECT
  s.id,
  s.title,
  s.shoot_date,
  s.shoot_time,
  s.shoot_end,
  s.location,
  s.address,
  c.full_name     AS contact_name,
  c.ig_handle,
  c.phone,
  s.status,
  s.google_cal_url
FROM shoots s
LEFT JOIN contacts c ON c.id = s.contact_id
WHERE s.shoot_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '14 days'
  AND s.status IN ('confirmed', 'tentative')
ORDER BY s.shoot_date, s.shoot_time;

-- ── ROW LEVEL SECURITY ────────────────────────────────────
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE follow_ups ENABLE ROW LEVEL SECURITY;
ALTER TABLE outreach_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE shoots ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_recaps ENABLE ROW LEVEL SECURITY;
ALTER TABLE pipeline_stages ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_types ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can do everything
CREATE POLICY "Allow all for authenticated users" ON contacts        FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON follow_ups      FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON outreach_log    FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON shoots          FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON email_templates FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON weekly_recaps   FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON pipeline_stages FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated users" ON contact_types   FOR ALL TO authenticated USING (true) WITH CHECK (true);