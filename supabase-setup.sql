-- Supabase 프로젝트의 SQL Editor에 이 내용을 그대로 붙여넣고 Run 버튼을 누르세요.

create table entries (
  id bigint generated always as identity primary key,
  title text not null,
  author text,
  thumbnail text,
  reviewer text not null,
  rating int not null,
  review text not null,
  created_at timestamptz default now()
);

alter table entries enable row level security;

create policy "누구나 읽기 가능"
on entries for select
using (true);

create policy "누구나 쓰기 가능"
on entries for insert
with check (true);
