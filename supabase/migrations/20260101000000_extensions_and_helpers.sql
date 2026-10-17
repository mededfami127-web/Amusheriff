-- 001 - Extensions and shared helpers
-- Amu Sharif Arabiyan Majlis (ASM)
--
-- pgcrypto  -> gen_random_uuid() for every primary key
-- pg_trgm   -> trigram search behind the `search_products` RPC

create extension if not exists pgcrypto;
create extension if not exists pg_trgm;

-- set_updated_at
-- Attached to every table that carries `updated_at`, so a client can never
-- forge a timestamp and the column is always server-authoritative.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

comment on function public.set_updated_at() is
  'BEFORE UPDATE trigger that stamps updated_at with the server clock.';
