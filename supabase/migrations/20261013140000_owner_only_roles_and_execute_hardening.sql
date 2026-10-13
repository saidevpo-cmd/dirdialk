-- =====================================================================
-- DIALI — OWNER-ONLY ROLE CHANGES & EXECUTE HARDENING
-- =====================================================================
-- Additive migration. Applied after:
--   20261008000000_initial_schema.sql
--   20261008120000_templates_and_settings.sql
--   20261008130000_storage.sql
--   20261013120000_security_hardening.sql
--   20261013130000_least_privilege_and_storage.sql
--
-- Goals (from the security review verification pass):
--   1. Only an `owner` may change `profiles.role`. The previous update
--      policy allowed any `admin` to change roles, so an admin could
--      promote themselves (or anyone) to owner.
--   2. `place_order` was granted to `authenticated`, but `anon` could still
--      hold EXECUTE via Supabase's default function privileges (`anon` is in
--      the default-privileges grant set). Revoke it explicitly as defence in
--      depth; the in-function `is_staff()` guard remains the primary control.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. is_owner() helper
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_owner()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.current_user_role() = 'owner';
$$;

REVOKE ALL ON FUNCTION public.is_owner() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_owner() TO anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. profiles — role changes require owner
-- ---------------------------------------------------------------------
-- RLS policies cannot compare the OLD and NEW row values, so a BEFORE
-- UPDATE trigger enforces that `role` only changes when the actor is an
-- owner. Non-role columns (full_name, avatar_url) stay self-editable.
--
-- The check applies ONLY when the statement runs as a client role
-- (`anon`/`authenticated`). Privileged contexts — the SQL editor / migrations
-- (`postgres`), and `service_role` — must remain able to bootstrap the first
-- owner and repair roles. For that reason the function is SECURITY INVOKER:
-- under SECURITY DEFINER, `current_user` would always report the function
-- owner and the guard could never see the real caller.
CREATE OR REPLACE FUNCTION public.enforce_profile_role_change()
RETURNS trigger
LANGUAGE plpgsql SECURITY INVOKER SET search_path = public AS $$
BEGIN
  IF NEW.role IS DISTINCT FROM OLD.role
     AND current_user IN ('anon', 'authenticated')
     AND NOT public.is_owner() THEN
    RAISE EXCEPTION 'only an owner may change profile roles'
      USING ERRCODE = 'insufficient_privilege';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_enforce_profile_role_change ON public.profiles;
CREATE TRIGGER trg_enforce_profile_role_change
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.enforce_profile_role_change();

REVOKE ALL ON FUNCTION public.enforce_profile_role_change() FROM PUBLIC;

-- The trigger is now the authority for role changes, so the update policy
-- only needs to scope *which rows* a user may touch.
DROP POLICY IF EXISTS profiles_update_self ON public.profiles;
CREATE POLICY profiles_update_self ON public.profiles
  FOR UPDATE
  USING (id = auth.uid() OR public.is_admin())
  WITH CHECK (id = auth.uid() OR public.is_admin());

-- ---------------------------------------------------------------------
-- 3. place_order — not executable by anon
-- ---------------------------------------------------------------------
REVOKE EXECUTE ON FUNCTION public.place_order(jsonb, jsonb) FROM anon;
