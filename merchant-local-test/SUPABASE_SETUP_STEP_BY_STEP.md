# Supabase账号商场设置指南

## 问题修复说明

已修复示例文件中的Supabase连接错误（`createClient is not defined`），主要修改了：
- 正确引用Supabase库中的createClient函数
- 优化了客户端初始化流程
- 提供了更清晰的错误处理

## 完整设置步骤

### 步骤1：Supabase控制台设置

1. **登录Supabase控制台**：访问 https://app.supabase.com
2. **选择您的项目**：`tdwwcqaxlwqrnjrjhsmn`
3. **创建数据库表**：
   - 进入SQL Editor
   - 复制并执行 `supabase_account_shop.sql` 中的SQL语句
   - 点击「运行」按钮执行
4. **启用Row Level Security**：
   - 进入Table Editor → 选择 `game_accounts` 表 → Edit Table
   - 启用「Row Level Security」选项
5. **创建安全策略**：
   - 点击「Create a policy」创建以下策略：
     
     **策略1：允许所有人查看账号**
     - 名称：`allow_read_all`
     - 允许操作：`SELECT`
     - 目标角色：`public`
     - 策略定义：`(true)`
     
     **策略2：允许已认证用户发布账号**
     - 名称：`allow_insert_authenticated`
     - 允许操作：`INSERT`
     - 目标角色：`authenticated`
     - 策略定义：`(true)`

### 步骤2：测试连接

1. **使用测试文件**：
   - 打开 `simple-supabase-test.html` 文件
   - 点击「测试连接」按钮
   - 点击「测试表访问」按钮验证数据库连接

2. **使用账号商场示例**：
   - 打开 `supabase_account_shop_example.html` 文件
   - 输入您的Supabase URL和Key（已默认填充）
   - 点击「连接到Supabase」按钮
   - 点击「获取账号」查看已发布的账号
   - 尝试使用表单发布新账号

### 步骤3：可能的问题排查

1. **连接失败**：
   - 检查URL和Key是否正确
   - 确保网络连接正常
   - 确认Supabase项目已启动

2. **表访问失败**：
   - 确认已执行SQL脚本创建表
   - 检查RLS策略是否正确设置
   - 查看Supabase控制台的错误日志

3. **发布账号失败**：
   - 确保已登录（对于需要认证的操作）
   - 检查表单字段是否填写完整
   - 验证数据类型是否正确

## 客户端文件说明

1. **simple-supabase-test.html**：
   - 简单的连接测试工具
   - 帮助验证Supabase连接和表访问
   - 包含详细的错误信息输出

2. **supabase_account_shop_example.html**：
   - 完整的账号商场示例
   - 支持账号列表查看和发布功能
   - 包含美观的UI和用户友好的交互

## 安全提示

- 请妥善保管您的Supabase密钥
- 在生产环境中，建议不要在前端代码中直接使用服务端密钥
- 确保正确配置RLS策略以保护数据安全

## 联系信息

如果遇到问题，请参考Supabase官方文档或联系技术支持。