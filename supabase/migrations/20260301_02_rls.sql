-- 20260301_02_rls.sql
alter table public.roles enable row level security;
alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.carts enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;

create or replace function public.current_role_code()
returns text
language sql
stable
as $$
  select r.code
  from public.profiles p
  left join public.roles r on r.id = p.role_id
  where p.id = auth.uid()
  limit 1;
$$;

drop policy if exists "public read categories" on public.categories;
create policy "public read categories"
on public.categories
for select
using (is_active = true);

drop policy if exists "public read products" on public.products;
create policy "public read products"
on public.products
for select
using (is_active = true);

drop policy if exists "users read own profile" on public.profiles;
create policy "users read own profile"
on public.profiles
for select
using (id = auth.uid());

drop policy if exists "users upsert own profile" on public.profiles;
create policy "users upsert own profile"
on public.profiles
for all
using (id = auth.uid())
with check (id = auth.uid());

drop policy if exists "users manage own cart" on public.carts;
create policy "users manage own cart"
on public.carts
for all
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "users manage own cart items" on public.cart_items;
create policy "users manage own cart items"
on public.cart_items
for all
using (
  exists (
    select 1 from public.carts c
    where c.id = cart_id and c.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.carts c
    where c.id = cart_id and c.user_id = auth.uid()
  )
);

drop policy if exists "users manage own orders" on public.orders;
create policy "users manage own orders"
on public.orders
for all
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "admins full roles" on public.roles;
create policy "admins full roles"
on public.roles
for all
using (public.current_role_code() in ('admin', 'manager'))
with check (public.current_role_code() in ('admin', 'manager'));

drop policy if exists "admins full categories" on public.categories;
create policy "admins full categories"
on public.categories
for all
using (public.current_role_code() in ('admin', 'manager'))
with check (public.current_role_code() in ('admin', 'manager'));

drop policy if exists "admins full products" on public.products;
create policy "admins full products"
on public.products
for all
using (public.current_role_code() in ('admin', 'manager'))
with check (public.current_role_code() in ('admin', 'manager'));

drop policy if exists "admins full orders" on public.orders;
create policy "admins full orders"
on public.orders
for all
using (public.current_role_code() in ('admin', 'manager'))
with check (public.current_role_code() in ('admin', 'manager'));
