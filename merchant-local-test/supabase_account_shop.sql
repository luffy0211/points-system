-- Supabase账号商场数据库初始化脚本
-- 适用于新建的账号商场Supabase项目

-- 开始事务
begin;

-- 如果表已存在，先删除（首次使用时执行，后续使用请注释此行）
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

-- 创建更新时间触发器（修复了之前的拼写错误）
create trigger update_game_accounts_updated_at 
before update on game_accounts 
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
('高级法师账号', 85, 25.5, 160, 350, 1280, '全身史诗装备，拥有稀有坐骑和宠物。账号已解锁全部地图和任务，金币充足。', 'https://placehold.co/600x400?text=法师账号', 'https://detail.tmall.com/item.htm?id=111111', 'admin', '2023-11-15 10:30:00'),
('强力战士账号', 80, 18.3, 150, 300, 980, '高防御高血量，适合喜欢近战战斗。拥有多套装备，可以应对不同战斗场景。', 'https://placehold.co/600x400?text=战士账号', 'https://detail.tmall.com/item.htm?id=222222', 'merchant1', '2023-11-16 14:45:00'),
('敏捷弓箭手账号', 75, 12.7, 140, 180, 750, '高暴击高命中，远程输出能力极强。拥有稀有箭矢和特殊技能。', 'https://placehold.co/600x400?text=弓箭手账号', 'https://detail.tmall.com/item.htm?id=333333', 'merchant2', '2023-11-17 09:15:00'),
('隐身刺客账号', 82, 22.1, 135, 200, 1100, '高爆发高机动性，适合喜欢潜行和暗杀。拥有独特的暗杀技能和装备。', 'https://placehold.co/600x400?text=刺客账号', 'https://detail.tmall.com/item.htm?id=444444', 'admin', '2023-11-18 16:20:00'),
('全能圣骑士账号', 78, 15.9, 145, 250, 890, '平衡的攻防能力，多种光环技能增益队友。适合喜欢团队合作的玩家。', 'https://placehold.co/600x400?text=圣骑士账号', 'https://detail.tmall.com/item.htm?id=555555', 'merchant3', '2023-11-19 11:10:00');

-- 提交事务
commit;

-- Supabase Row Level Security策略设置指南
-- 在Supabase控制台中执行以下操作：
-- 1. 启用RLS（在Table Editor → 选择game_accounts表 → Edit Table → Enable Row Level Security）
-- 2. 创建以下安全策略：

-- 策略1：允许所有人查看账号（无需登录）
-- 策略名称：allow_read_all
-- 允许操作：SELECT
-- 目标角色：anon, authenticated
-- 策略定义：(true)

-- 策略2：只允许登录用户发布账号
-- 策略名称：allow_insert_authenticated
-- 允许操作：INSERT
-- 目标角色：authenticated
-- 策略定义：(true)

-- 策略3：允许用户更新和删除自己发布的账号
-- 策略名称：allow_update_delete_own_accounts
-- 允许操作：UPDATE, DELETE
-- 目标角色：authenticated
-- 策略定义：(published_by = auth.uid())