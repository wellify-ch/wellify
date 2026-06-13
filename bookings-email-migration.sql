-- Booking email field hinzufügen
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS email TEXT;
