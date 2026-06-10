-- Wellify Member Platform — einmalig in Supabase SQL Editor ausführen
-- Danach: Authentication → Settings → "Enable email confirmations" → OFF

-- 1. Profile (wird automatisch bei Registrierung erstellt)
CREATE TABLE IF NOT EXISTS public.profiles (
  id         uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email      text,
  name       text,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Trigger: Profile auto-erstellen
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'name')
  ON CONFLICT (id) DO NOTHING;
  RETURN new;
END;
$$;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 2. Freigeschaltete Emails (Coach verwaltet diese)
CREATE TABLE IF NOT EXISTS public.approved_emails (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  email      text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE public.approved_emails ENABLE ROW LEVEL SECURITY;

-- 3. Nachrichten / Fortschritt
CREATE TABLE IF NOT EXISTS public.messages (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at  timestamptz DEFAULT now(),
  profile_id  uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content     text NOT NULL,
  sender      text NOT NULL CHECK (sender IN ('coach', 'client')),
  is_read     boolean DEFAULT false
);
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- RLS: profiles
CREATE POLICY "profile_own_read"   ON public.profiles FOR SELECT TO authenticated USING (auth.uid() = id);
CREATE POLICY "profile_own_insert" ON public.profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
CREATE POLICY "profile_coach_all"  ON public.profiles FOR ALL    TO anon
  USING ((current_setting('request.headers',true)::json)->>'x-coach-secret'='WellifyCoachAccess2026')
  WITH CHECK (true);

-- RLS: approved_emails
CREATE POLICY "approved_own_check" ON public.approved_emails FOR SELECT TO authenticated
  USING (email = auth.email());
CREATE POLICY "approved_coach_all" ON public.approved_emails FOR ALL TO anon
  USING ((current_setting('request.headers',true)::json)->>'x-coach-secret'='WellifyCoachAccess2026')
  WITH CHECK (true);

-- RLS: messages
CREATE POLICY "msg_client_read" ON public.messages FOR SELECT TO authenticated
  USING (profile_id = auth.uid()
    AND EXISTS (SELECT 1 FROM public.approved_emails WHERE email = auth.email()));
CREATE POLICY "msg_client_insert" ON public.messages FOR INSERT TO authenticated
  WITH CHECK (profile_id = auth.uid() AND sender = 'client'
    AND EXISTS (SELECT 1 FROM public.approved_emails WHERE email = auth.email()));
CREATE POLICY "msg_coach_all" ON public.messages FOR ALL TO anon
  USING ((current_setting('request.headers',true)::json)->>'x-coach-secret'='WellifyCoachAccess2026')
  WITH CHECK (true);

-- Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.approved_emails;
ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
