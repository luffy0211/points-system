-- 创建游戏账号表
begin;

-- 如果表已存在，先删除（生产环境请谨慎使用）
drop table if exists game_accounts;

-- 创建游戏账号表
create table game_accounts (
  id uuid primary key default uuid_generate_v4(),
  account_name varchar(255) not null,
  account_level integer not null,
  haf_coin numeric(10,2) not null,
  stamina_level integer not null,
  weight_level integer not null,
  price numeric(10,2) not null,
  description text,
  image_url text not null,
  taobao_link text not null,
  published_by varchar(255) not null,
  published_at varchar(50) not null,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- 创建更新时间触发器函数
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language 'plpgsql';

-- 创建更新时间触发器
create trigger update_game_accounts_updated_at 
bbefore update on game_accounts 
for each row execute function update_updated_at_column();

-- 添加索引以提高查询性能
create index idx_game_accounts_created_at on game_accounts(created_at);
create index idx_game_accounts_price on game_accounts(price);
create index idx_game_accounts_account_level on game_accounts(account_level);

-- 插入一些示例数据
insert into game_accounts (
  account_name, 
  account_level, 
  haf_coin, 
  stamina_level, 
  weight_level, 
  price, 
  description, 
  image_url, 
  taobao_link, 
  published_by, 
  published_at
) values 
('法师账号', 85, 25.5, 160, 350, 1280, '高级法师账号，全身史诗装备，拥有稀有坐骑和宠物。账号已解锁全部地图和任务，金币充足，适合喜欢法师职业的玩家。', 'https://placehold.co/600x400?text=法师账号', 'https://detail.tmall.com/item.htm?id=6789012345', 'admin', '2023-10-15 10:30:00'),
('战士账号', 80, 18.3, 150, 300, 980, '强力战士账号，高防御高血量，适合喜欢近战战斗的玩家。账号拥有多套装备，可以应对不同战斗场景。', 'https://placehold.co/600x400?text=战士账号', 'https://detail.tmall.com/item.htm?id=6789012346', 'merchant1', '2023-10-16 14:45:00'),
('弓箭手账号', 75, 12.7, 140, 180, 750, '敏捷弓箭手账号，高暴击高命中，远程输出能力极强。账号拥有稀有箭矢和特殊技能，适合喜欢远程战斗的玩家。', 'https://placehold.co/600x400?text=弓箭手账号', 'https://detail.tmall.com/item.htm?id=6789012347', 'merchant2', '2023-10-17 09:15:00'),
('刺客账号', 82, 22.1, 135, 200, 1100, '隐身刺客账号，高爆发高机动性，适合喜欢潜行和暗杀的玩家。账号拥有独特的暗杀技能和装备。', 'https://placehold.co/600x400?text=刺客账号', 'https://detail.tmall.com/item.htm?id=6789012348', 'admin', '2023-10-18 16:20:00');

commit;

-- 设置安全策略（在Supabase控制台中执行以下操作）
-- 1. 允许任何人查看账号（无需登录）
-- 2. 只允许登录用户发布账号
--
-- 在Supabase控制台中，为game_accounts表创建以下Row Level Security策略：
--
-- 策略名称：allow_read_all
-- 允许操作：SELECT
-- 目标角色：anon, authenticated
-- 策略定义：(true)
--
-- 策略名称：allow_insert_authenticated
-- 允许操作：INSERT
-- 目标角色：authenticated
-- 策略定义：(true)