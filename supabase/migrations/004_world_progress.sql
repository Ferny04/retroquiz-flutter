begin;

-- No requiere una tabla de mundos: este avance solo guarda el Volcánico.
create table public.world_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  world_id text not null check (world_id = 'volcanic'),
  best_score integer not null check (
    best_score between 0 and 1000 and best_score % 100 = 0
  ),
  completed boolean not null default true check (completed),
  primary key (user_id, world_id)
);

alter table public.world_progress enable row level security;
revoke all on public.world_progress from public, anon, authenticated;
grant select on public.world_progress to authenticated;

create policy "Read own progress" on public.world_progress
  for select to authenticated using ((select auth.uid()) = user_id);

-- Solo la RPC escribe con permisos de su propietario (postgres en SQL Editor).
-- El cliente no puede elegir user_id ni escribir directamente en la tabla.
create function public.complete_volcanic_world(p_score integer)
returns setof public.world_progress
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Se requiere una sesión autenticada.' using errcode = '28000';
  end if;

  if p_score is null or p_score < 0 or p_score > 1000 or p_score % 100 <> 0 then
    raise exception 'Los puntos deben ser múltiplos de 100 entre 0 y 1000.'
      using errcode = '22023';
  end if;

  -- Valida el rango, no las respuestas: el servidor confía en los puntos enviados.
  return query
  insert into public.world_progress as progress (user_id, world_id, best_score, completed)
  values (v_user_id, 'volcanic', p_score, true)
  on conflict (user_id, world_id) do update
    set best_score = greatest(progress.best_score, excluded.best_score),
        completed = true
  returning progress.*;
end;
$$;

revoke all on function public.complete_volcanic_world(integer) from public, anon, authenticated;
grant execute on function public.complete_volcanic_world(integer) to authenticated;

commit;
