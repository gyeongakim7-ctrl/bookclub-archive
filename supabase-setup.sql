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

create policy "delete_own_entries"
on entries for delete
using (true);

create policy "update_own_entries"
on entries for update
using (true)
with check (true);

-- ======================================================
-- 이미 entries 테이블이 있다면 (기존 서비스 운영 중이라면),
-- 아래 내용만 SQL Editor에 추가로 붙여넣고 실행하세요.
-- ======================================================

-- "읽은 날짜"를 저장해서 연도별로 책을 모아볼 수 있게 해줘요.
alter table entries add column if not exists read_date date;

-- "이름 일치 시 삭제 버튼" 기능을 쓰려면 삭제 권한도 열어줘야 해요.
-- 주의: 이름은 로그인 없이 그냥 텍스트라서, 이 정책은 "이름이 같으면 지울 수 있다"를
-- DB 차원에서 강제하지 못해요. 앱에서는 내 이름과 일치할 때만 삭제 버튼을 보여주지만,
-- 이 정책 자체는 누구나(익명 키로) 어떤 행이든 지울 수 있게 허용하는 것입니다.
-- 이미 같은 이름의 정책이 있다면 아래 drop 줄의 주석을 해제하고 먼저 실행하세요.
-- drop policy "delete_own_entries" on entries;
create policy "delete_own_entries"
on entries for delete
using (true);

-- "수정하기" 기능을 쓰려면 수정(update) 권한도 열어줘야 해요. 삭제 정책과 같은 이유로,
-- 이것도 "이름이 같으면 고칠 수 있다"를 DB가 강제하는 게 아니라 앱 UI에서만 막는 거예요.
-- drop policy "update_own_entries" on entries;
create policy "update_own_entries"
on entries for update
using (true)
with check (true);
