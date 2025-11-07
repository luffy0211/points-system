# Supabase账号商城集成指南

本指南将帮助您将账号商城系统与Supabase数据库集成，实现账号数据的持久化存储和查询。

## 1. Supabase设置步骤

### 1.1 创建Supabase项目
1. 访问 [Supabase官网](https://supabase.com/)
2. 注册/登录账号
3. 创建新的项目
4. 记录项目URL和匿名密钥(anon key)，稍后将在前端配置中使用

### 1.2 运行SQL脚本
1. 在Supabase控制台中，导航到"SQL Editor"部分
2. 复制并粘贴 `create_account_table.sql` 文件中的内容
3. 点击"RUN"执行脚本
4. 脚本将自动创建所需的表结构、触发器、索引和示例数据

### 1.3 配置Row Level Security (RLS)策略
1. 在Supabase控制台中，导航到"Authentication"部分，启用身份验证
2. 导航到"Database" > "Tables"，找到 `game_accounts` 表
3. 点击"Edit Table"，然后切换到"Policies"标签页
4. 创建两个策略：

   **策略1: 允许所有人读取账号数据**
   - 策略名称: `allow_read_all`
   - 允许操作: `SELECT`
   - 目标角色: `anon`, `authenticated`
   - 策略定义: `(true)`

   **策略2: 只允许登录用户插入账号数据**
   - 策略名称: `allow_insert_authenticated`
   - 允许操作: `INSERT`
   - 目标角色: `authenticated`
   - 策略定义: `(true)`

## 2. 前端配置

### 2.1 修改Supabase连接信息
打开 `test.html` 文件，找到以下代码部分：

```javascript
// Supabase配置 - 请根据实际情况修改这些配置
const supabaseUrl = 'https://YOUR_SUPABASE_URL.supabase.co';
const supabaseKey = 'YOUR_ANON_KEY';
const supabase = supabase.createClient(supabaseUrl, supabaseKey);
```

将 `YOUR_SUPABASE_URL` 和 `YOUR_ANON_KEY` 替换为您在步骤1.1中获取的实际值。

## 3. 功能说明

### 3.1 账号查看
- 无需登录即可浏览和查看所有账号
- 支持按等级、金币、体力、负重和价格进行筛选
- 点击账号卡片可查看详情

### 3.2 账号发布
- 需要登录后才能发布账号
- 点击导航栏中的"发布账号"按钮
- 填写账号信息表单并提交
- 账号信息将自动保存到Supabase数据库

### 3.3 账号详情
- 显示账号的所有详细信息
- 显示发布者和发布时间信息
- 提供淘宝链接快速访问购买页面

## 4. 技术说明

### 4.1 数据结构
账号数据包含以下字段：
- `id`: 唯一标识符（自动生成）
- `account_name`: 账号名称
- `account_level`: 账号等级
- `haf_coin`: HAF金币数量
- `stamina_level`: 体力等级
- `weight_level`: 负重等级
- `price`: 价格
- `description`: 描述
- `image_url`: 图片链接
- `taobao_link`: 淘宝链接
- `published_by`: 发布者
- `published_at`: 发布时间
- `created_at`: 创建时间（数据库自动记录）
- `updated_at`: 更新时间（数据库自动记录）

### 4.2 安全考虑
- 查看账号数据无需认证
- 发布账号需要认证
- 数据验证在前端进行，生产环境建议同时在后端进行验证
- 所有输入都进行了基本的格式验证，防止无效数据

## 5. 故障排除

### 5.1 连接问题
- 检查Supabase URL和密钥是否正确
- 确认项目是否已在Supabase中正确创建
- 检查网络连接是否正常

### 5.2 权限问题
- 确保已正确设置RLS策略
- 检查用户是否已登录（发布账号时）

### 5.3 数据问题
- 检查SQL脚本是否成功执行
- 确认表结构和示例数据是否已正确创建