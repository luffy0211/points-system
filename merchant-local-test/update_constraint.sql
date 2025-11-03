-- 创建账号表结构（优化后）
drop table if exists accounts;
create table accounts (
  id uuid primary key default uuid_generate_v4(),
  account_name text not null,
  account_level integer not null check (account_level >= 1),
  haf_coin integer not null check (haf_coin >= 0),
  stamina_level integer not null check (stamina_level >= 1 and stamina_level <= 10),
  weight_level integer not null check (weight_level >= 1 and weight_level <= 10),
  price integer not null check (price >= 1),
  description text not null,
  username text not null,
  password text not null,
  other_info text,
  created_at timestamptz not null default now(),  -- 补充默认值
  status text not null default 'available',
  merchant_id uuid not null  -- 改为 uuid 类型
);

-- 创建账号图片表
drop table if exists account_images;
create table account_images (
  id uuid primary key default uuid_generate_v4(),
  account_id uuid not null references accounts(id) on delete cascade,
  image_url text not null,
  uploaded_at timestamptz not null default now()
);

-- 为账号表创建索引
create index idx_accounts_status on accounts(status);
create index idx_accounts_merchant_id on accounts(merchant_id);
create index idx_accounts_price on accounts(price);
create index idx_account_images_account_id on account_images(account_id);

-- 设置Row Level Security (RLS)
alter table accounts enable row level security;
alter table account_images enable row level security;

-- 创建策略：允许所有用户查看可用状态的账号
create policy "Public read access for available accounts" 
  on accounts 
  for select 
  using (status = 'available');

-- 商户插入自己的账号（优化类型比较）
create policy "Merchant insert access"
  on accounts
  for insert
  with check (auth.uid() = merchant_id);

-- 商户更新/删除自己的账号（优化类型比较）
create policy "Merchant update delete access"
  on accounts
  for all
  using (auth.uid() = merchant_id);

-- 创建策略：允许所有用户查看与账号关联的图片
create policy "Public read access for account images" 
  on account_images 
  for select 
  using (true);

-- 创建策略：允许商户只插入与自己账号关联的图片
create policy "Merchant insert account images"
  on account_images
  for insert
  with check (
    exists (
      select 1 from accounts
      where accounts.id = account_images.account_id
      and accounts.merchant_id = auth.uid()  -- 优化类型比较
    )
  );

-- 创建视图：用于用户查询可用账号信息（不包含密码等敏感信息）
drop view if exists public.available_accounts_view;
create view public.available_accounts_view as
select 
  a.id,
  a.account_name,
  a.account_level,
  a.haf_coin,
  a.stamina_level,
  a.weight_level,
  a.price,
  a.description,
  a.created_at,
  a.merchant_id,
  array_agg(ai.image_url) as image_urls
from 
  accounts a
left join 
  account_images ai on a.id = ai.account_id
where 
  a.status = 'available'
group by 
  a.id;

-- 授予视图查询权限（替代视图的RLS策略）
grant select on public.available_accounts_view to anon, authenticated;