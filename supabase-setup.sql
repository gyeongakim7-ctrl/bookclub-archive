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

-- ======================================================
-- 이미 entries 테이블이 있다면 (기존 서비스 운영 중이라면),
-- 아래 한 줄만 SQL Editor에 추가로 붙여넣고 실행하세요.
-- "읽은 날짜"를 저장해서 연도별로 책을 모아볼 수 있게 해줘요.
-- ======================================================
alter table entries add column if not exists read_date date;
