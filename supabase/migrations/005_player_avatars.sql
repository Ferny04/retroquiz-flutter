begin;

insert into storage.buckets (
  id, name, public, file_size_limit, allowed_mime_types
)
values (
  'player-avatars',
  'player-avatars',
  false,
  2097152,
  array['image/jpeg', 'image/png']
);

-- Refuerza la separación incluso si otro bucket usa
-- políticas permisivas generales.
create policy "Isolate player avatars"
on storage.objects
as restrictive
for all
to public
using (
  bucket_id is distinct from 'player-avatars'
  or name = ((select auth.uid())::text || '/avatar')
)
with check (
  bucket_id is distinct from 'player-avatars'
  or name = ((select auth.uid())::text || '/avatar')
);

-- Cada cuenta tiene un único objeto, incluso
-- cuando cambia el formato.
create policy "Read own avatar"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'player-avatars'
  and name = ((select auth.uid())::text || '/avatar')
);

create policy "Insert own avatar"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'player-avatars'
  and name = ((select auth.uid())::text || '/avatar')
);

create policy "Replace own avatar"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'player-avatars'
  and name = ((select auth.uid())::text || '/avatar')
)
with check (
  bucket_id = 'player-avatars'
  and name = ((select auth.uid())::text || '/avatar')
);

commit;
