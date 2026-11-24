-- Cole tudo isto no Supabase: SQL Editor > New query > Run

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  date date not null,
  barber text not null,
  start_time text not null,
  minutes int not null,
  service text not null,
  price int not null,
  name text not null,
  phone text not null,
  created_at timestamptz not null default now()
);

-- Um registro por bloco de 30 min ocupado, por barbeiro. A chave primária impede dois clientes no mesmo horário.
create table if not exists public.slots (
  slot_key text primary key,
  date date not null,
  barber text not null,
  t text not null,
  booking_id uuid not null references public.bookings(id) on delete cascade
);
create index if not exists slots_date_idx on public.slots(date);

alter table public.bookings enable row level security;
alter table public.slots enable row level security;

-- Cliente (anônimo): só vê quais horários estão ocupados. Não vê nomes nem telefones.
create policy "todos veem horarios ocupados" on public.slots for select to anon, authenticated using (true);

-- Barbeiro (logado): vê e cancela tudo.
create policy "barbeiro le agendamentos" on public.bookings for select to authenticated using (true);
create policy "barbeiro cancela agendamentos" on public.bookings for delete to authenticated using (true);

-- Único caminho do cliente para agendar. Tudo ou nada: se um horário já estiver ocupado, nada é gravado.
create or replace function public.book(p_name text, p_phone text, p_items jsonb)
returns int
language plpgsql security definer set search_path = public as $$
declare it jsonb; bid uuid; t text; n int := 0;
begin
  if length(trim(p_name)) < 2 or length(regexp_replace(p_phone,'\D','','g')) < 10 then raise exception 'dados invalidos'; end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) not between 1 and 6 then raise exception 'itens invalidos'; end if;
  for it in select value from jsonb_array_elements(p_items) loop
    if (it->>'date')::date < current_date then raise exception 'data passada'; end if;
    if jsonb_array_length(it->'times') not between 1 and 4 then raise exception 'horarios invalidos'; end if;
    bid := gen_random_uuid();
    insert into bookings(id,date,barber,start_time,minutes,service,price,name,phone)
      values (bid,(it->>'date')::date,left(it->>'barber',40),it->'times'->>0,(it->>'minutes')::int,
              left(it->>'service',80),(it->>'price')::int,left(trim(p_name),80),left(p_phone,20));
    for t in select jsonb_array_elements_text(it->'times') loop
      insert into slots(slot_key,date,barber,t,booking_id)
        values ((it->>'barber')||'_'||(it->>'date')||'_'||replace(t,':',''),(it->>'date')::date,it->>'barber',t,bid);
    end loop;
    n := n + 1;
  end loop;
  return n;
end $$;

revoke all on function public.book(text,text,jsonb) from public;
grant execute on function public.book(text,text,jsonb) to anon, authenticated;
