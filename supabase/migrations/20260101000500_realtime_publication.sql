-- 006 - Realtime publication
--
--   The storefront and the admin gateway both watch tables with `.stream()`,
--   and Realtime only delivers events for tables that belong to the
--   `supabase_realtime` publication. Nothing ever added them, so every live
--   update silently never fired: the subscription opened, the queries
--   succeeded, and no change ever arrived. That is the one promise in the
--   README — "anything the owner changes is live on every customer device
--   without a restart" — which depended on this migration.
--
--   Every table streamed from Dart is listed below; a new `.stream()` call
--   needs its table added here too, and group 11 of the RLS suite fails when
--   it is not.
--
--   Idempotent: the publication is created when it is missing (on a hosted
--   project it already exists, created by the platform) and each table is
--   added only when it is not already a member, so re-applying is a no-op.

do $$
declare
  t text;
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    create publication supabase_realtime;
  end if;

  foreach t in array array[
       'categories', 'products', 'product_media',
       'contact_links', 'site_settings', 'inquiries'
     ]
  loop
    if not exists (
      select 1
        from pg_publication_tables
       where pubname = 'supabase_realtime'
         and schemaname = 'public'
         and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end;
$$;
