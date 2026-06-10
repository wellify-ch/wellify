-- Wellify Booking System — einmalig in Supabase SQL Editor ausführen
-- Supabase → SQL Editor (links </>-Symbol) → New query → Paste → Run

CREATE TABLE IF NOT EXISTS public.bookings (
  id         uuid         DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamptz  DEFAULT now(),
  name       text         NOT NULL,
  phone      text,
  service    text         DEFAULT 'Nicht angegeben',
  message    text,
  status     text         DEFAULT 'neu'
);

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Jeder kann eine Buchung einreichen (Formular auf der Website)
CREATE POLICY "public_insert" ON public.bookings
  FOR INSERT TO anon WITH CHECK (true);

-- Coach-Dashboard kann alle Buchungen sehen
CREATE POLICY "coach_select" ON public.bookings
  FOR SELECT TO anon
  USING (
    (current_setting('request.headers', true)::json)->>'x-coach-secret'
    = 'WellifyCoachAccess2026'
  );

-- Coach-Dashboard kann Status aktualisieren
CREATE POLICY "coach_update" ON public.bookings
  FOR UPDATE TO anon
  USING (
    (current_setting('request.headers', true)::json)->>'x-coach-secret'
    = 'WellifyCoachAccess2026'
  )
  WITH CHECK (true);

-- Realtime aktivieren
ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;
