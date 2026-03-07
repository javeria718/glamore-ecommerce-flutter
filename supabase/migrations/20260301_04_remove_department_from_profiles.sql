-- 20260301_04_remove_department_from_profiles.sql
alter table if exists public.profiles
drop column if exists department;
