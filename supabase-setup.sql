-- Run this entire file once in Supabase Dashboard > SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 2 and 35),
  role text not null default 'user' check (role in ('user','staff','admin')),
  banned boolean not null default false,
  ban_reason text,
  created_at timestamptz not null default now()
);

create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  price numeric(12,2) not null default 0 check (price >= 0),
  category text not null,
  condition text not null,
  location text not null,
  trade text not null default 'No',
  description text not null,
  image_urls text[] not null default '{}',
  status text not null default 'active' check (status in ('active','sold','removed')),
  created_at timestamptz not null default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid references public.listings(id) on delete set null,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 500),
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid references public.listings(id) on delete set null,
  reporter_id uuid references public.profiles(id) on delete set null,
  reason text not null,
  details text,
  resolved boolean not null default false,
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(nullif(new.raw_user_meta_data->>'display_name',''), split_part(new.email,'@',1)));
  return new;
end; $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.is_staff(uid uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.profiles where id = uid and role in ('staff','admin') and banned = false);
$$;

alter table public.profiles enable row level security;
alter table public.listings enable row level security;
alter table public.messages enable row level security;
alter table public.reports enable row level security;

-- Profiles
create policy "profiles readable" on public.profiles for select using (true);
create policy "update own profile" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);
create policy "staff update profiles" on public.profiles for update using (public.is_staff(auth.uid())) with check (public.is_staff(auth.uid()));

-- Listings
create policy "active listings readable" on public.listings for select using (status = 'active' or auth.uid() = user_id or public.is_staff(auth.uid()));
create policy "nonbanned users create listings" on public.listings for insert with check (
  auth.uid() = user_id and exists(select 1 from public.profiles p where p.id=auth.uid() and p.banned=false)
);
create policy "owners update listings" on public.listings for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "owners delete listings" on public.listings for delete using (auth.uid() = user_id or public.is_staff(auth.uid()));

-- Messages are private to sender/recipient; staff do not read private messages.
create policy "message participants read" on public.messages for select using (auth.uid() in (sender_id, recipient_id));
create policy "nonbanned users send" on public.messages for insert with check (
  auth.uid() = sender_id and exists(select 1 from public.profiles p where p.id=auth.uid() and p.banned=false)
);
create policy "recipient marks read" on public.messages for update using (auth.uid() = recipient_id) with check (auth.uid() = recipient_id);

-- Reports
create policy "users create reports" on public.reports for insert with check (auth.uid() = reporter_id);
create policy "staff read reports" on public.reports for select using (public.is_staff(auth.uid()));
create policy "staff update reports" on public.reports for update using (public.is_staff(auth.uid())) with check (public.is_staff(auth.uid()));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('listing-images','listing-images',true,5242880,array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public=true;

create policy "public listing images" on storage.objects for select using (bucket_id='listing-images');
create policy "authenticated image upload" on storage.objects for insert to authenticated with check (
  bucket_id='listing-images' and (storage.foldername(name))[1] = auth.uid()::text
);
create policy "owners delete images" on storage.objects for delete to authenticated using (
  bucket_id='listing-images' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_staff(auth.uid()))
);

-- AFTER creating your own account, make yourself admin by replacing the email below:
-- update public.profiles set role='admin' where id=(select id from auth.users where email='YOUR_EMAIL@example.com');
