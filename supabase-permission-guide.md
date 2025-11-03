# Supabase 权限配置指南

## 商家页面插入账号功能失败问题分析

根据代码分析，商家页面插入账号功能失败很可能是由于 **Supabase 权限配置不当** 导致的。具体来说，当前系统使用了匿名公钥（anonKey），其默认权限不足以执行插入操作。

## 问题详情

1. **权限不足**：系统使用的 Supabase anonKey 具有 `anonymous` 角色，该角色默认没有数据表的写权限
2. **配置问题**：需要在 Supabase 控制台中正确配置 `steam_accounts` 表的安全策略
3. **前端改进**：已增强前端错误处理，现在可以更明确地显示权限相关错误

## 解决方案

请按照以下步骤在 Supabase 控制台中配置权限：

### 1. 登录 Supabase 控制台

访问 https://app.supabase.com 并登录您的账号

### 2. 配置安全策略

1. 进入项目 > 数据库 > 表编辑器 > 选择 `steam_accounts` 表
2. 点击 **权限** 选项卡
3. 为 **INSERT** 操作配置如下策略：

```sql
-- 允许已登录用户插入数据
CREATE POLICY "允许已认证用户插入账号" ON "public"."steam_accounts"
    FOR INSERT TO authenticated
    WITH CHECK (true);
```

### 3. 商家特定权限配置

为了更安全，您可以配置只允许商家角色插入数据：

```sql
-- 只允许商家用户插入数据
CREATE POLICY "只允许商家插入账号" ON "public"."steam_accounts"
    FOR INSERT TO authenticated
    WITH CHECK (
        -- 验证用户是否在 merchants 表中
        EXISTS (
            SELECT 1 FROM merchants 
            WHERE user_id = auth.uid()
        )
    );
```

### 4. 配置其他必要操作的权限

除了 INSERT，还需要确保 SELECT 和 UPDATE 权限正确配置：

```sql
-- 允许已认证用户查看账号
CREATE POLICY "允许已认证用户查看账号" ON "public"."steam_accounts"
    FOR SELECT TO authenticated
    USING (true);

-- 允许商家更新账号
CREATE POLICY "允许商家更新账号" ON "public"."steam_accounts"
    FOR UPDATE TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM merchants 
            WHERE user_id = auth.uid()
        )
    );
```

## 其他建议

1. **配置 merchant_id 列**：确保 `steam_accounts` 表中有 `merchant_id` 列，以便跟踪哪个商家添加了账号
2. **审核日志**：考虑添加审计列如 `created_at`、`updated_at` 等
3. **使用 supabase-js SDK**：考虑在商家页面中使用 supabase-js SDK 而非直接的 fetch API，以便更好地处理认证和错误

## 测试方法

1. 配置完权限后，刷新商家页面
2. 尝试批量插入几条账号记录
3. 查看控制台日志，检查是否有错误信息

如果仍然遇到问题，请检查浏览器控制台日志，查找更详细的错误信息。