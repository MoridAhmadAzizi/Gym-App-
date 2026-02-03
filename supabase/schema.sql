create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  role text not null default 'user',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  "group" text not null,
  desc text not null,
  tool text[] not null default '{}'::text[],
  image_urls text[] not null default '{}'::text[],
  created_by uuid not null references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_products_created_at on public.products (created_at desc);
create or replace function public.set_updated_at() returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists tr_products_set_updated_at on public.products;
create trigger tr_products_set_updated_at
before update on public.products
for each row execute function public.set_updated_at();

drop trigger if exists tr_profiles_set_updated_at on public.profiles;
create trigger tr_profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.products enable row level security;

drop policy if exists "profiles_read_own" on public.profiles;
create policy "profiles_read_own" on public.profiles
for select using (auth.uid() = id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
for insert with check (auth.uid() = id);

drop policy if exists "products_read_all_active" on public.products;
create policy "products_read_all_active" on public.products
for select using (
  exists(
    select 1 from public.profiles p
    where p.id = auth.uid() and p.is_active = true
  )
);
drop policy if exists "products_write_admin" on public.products;
create policy "products_write_admin" on public.products
for all using (
  exists(
    select 1 from public.profiles p
    where p.id = auth.uid() and p.is_active = true and p.role in ('admin','super_admin')
  )
) with check (
  exists(
    select 1 from public.profiles p
    where p.id = auth.uid() and p.is_active = true and p.role in ('admin','super_admin')
  )
);

create or replace function public.is_super_admin() returns boolean as $$
  select exists(
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'super_admin' and p.is_active = true
  );
$$ language sql stable;

create or replace function public.admin_set_user_active(target_user uuid, is_active boolean)
returns void as $$
begin
  if not public.is_super_admin() then
    raise exception 'not allowed';
  end if;

  update public.profiles set is_active = admin_set_user_active.is_active
  where id = target_user;
end;
$$ language plpgsql security definer;

create or replace function public.admin_set_user_role(target_user uuid, new_role text)
returns void as $$
begin
  if not public.is_super_admin() then
    raise exception 'not allowed';
  end if;

  update public.profiles set role = new_role
  where id = target_user;
end;
$$ language plpgsql security definer;

grant execute on function public.admin_set_user_active(uuid, boolean) to authenticated;
grant execute on function public.admin_set_user_role(uuid, text) to authenticated;

alter table storage.objects enable row level security;

drop policy if exists "public_read_product_images" on storage.objects;
create policy "public_read_product_images" on storage.objects
for select
using (bucket_id = 'product-images');

drop policy if exists "admin_upload_product_images" on storage.objects;
create policy "admin_upload_product_images" on storage.objects
for insert
with check (
  bucket_id = 'product-images' and
  exists(
    select 1 from public.profiles p
    where p.id = auth.uid() and p.is_active = true and p.role in ('admin','super_admin')
  )
);

drop policy if exists "admin_update_product_images" on storage.objects;
create policy "admin_update_product_images" on storage.objects
for update
using (
  bucket_id = 'product-images' and
  exists(
    select 1 from public.profiles p
    where p.id = auth.uid() and p.is_active = true and p.role in ('admin','super_admin')
  )
);
