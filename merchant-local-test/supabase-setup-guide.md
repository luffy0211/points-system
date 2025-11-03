# Supabase 账号管理系统配置指南（优化版）

本文档提供了使用 Supabase 构建账号管理系统的完整设置指南，包括优化后的表结构设计、权限配置和数据查询方法。

## 表结构设计（优化版）

### 1. accounts（账号表）
主要存储账号的基本信息和交易状态：
- **id**: UUID 主键，默认自动生成
- **account_name**: 账号名称（必填）
- **account_level**: 账号等级（必填，最小值为1）
- **haf_coin**: 哈夫币数量（必填，最小值为0）
- **stamina_level**: 体力等级（必填，1-10范围）
- **weight_level**: 负重等级（必填，1-10范围）
- **price**: 出售价格（必填，最小值为1）
- **description**: 账号描述（必填）
- **username**: Steam用户名（必填）
- **password**: Steam密码（必填）
- **other_info**: 其他信息（可选）
- **created_at**: 创建时间（必填，默认自动设置为当前时间）
- **status**: 状态（必填，默认为'available'）
- **merchant_id**: 商户ID（必填，改为UUID类型以匹配Supabase用户ID）

**优化说明**：
- **字段类型优化**：`merchant_id` 从文本类型改为 UUID 类型，更好地匹配 Supabase 的用户ID类型
- **默认值添加**：`created_at` 字段添加了默认值，简化插入操作
- **冗余移除**：删除了 `image_urls` 数组字段，改为通过 `account_images` 表进行关联查询

### 2. account_images（账号图片表）
存储账号的图片信息：
- **id**: UUID 主键，默认自动生成
- **account_id**: 关联的账号ID（必填，外键引用accounts表，级联删除）
- **image_url**: 图片URL（必填）
- **uploaded_at**: 上传时间（必填，默认自动设置为当前时间）

**数据一致性**：通过外键约束确保图片与账号的关联关系

### 3. available_accounts_view（可用账号视图）
为用户页面提供安全的数据查询接口，不包含密码等敏感信息。该视图聚合了可用账号的基本信息和图片URL，通过 `array_agg` 函数将多个图片URL聚合为数组。

**视图权限优化**：不再为视图设置RLS策略，而是直接使用GRANT语句授予权限，更高效且符合PostgreSQL最佳实践

## 如何在Supabase中应用配置

### 步骤1: 打开Supabase SQL编辑器
1. 登录到Supabase控制台
2. 选择你的项目
3. 点击左侧菜单中的「SQL编辑器」

### 步骤2: 执行SQL语句
1. 复制`update_constraint.sql`文件中的所有内容
2. 粘贴到Supabase的SQL编辑器中
3. 点击「执行」按钮

### 步骤3: 验证配置
1. 执行完成后，检查「数据库」>「表编辑器」中是否成功创建了表
2. 检查「数据库」>「视图」中是否成功创建了视图

## 权限说明（优化版）

### 商户权限
- **插入权限**: 商户可以插入自己的账号数据
- **更新/删除权限**: 商户只能更新和删除自己的账号数据
- **图片管理**: 商户可以为自己的账号上传图片
- **类型比较优化**: 移除了类型转换，直接使用UUID类型比较，提高性能

### 用户权限
- **查询权限**: 所有用户可以查询状态为"available"的账号信息
- **安全访问**: 通过视图访问，不会暴露密码等敏感信息
- **权限简化**: 通过直接授予视图SELECT权限，确保所有用户（匿名和已认证）都能访问可用账号信息

## 数据查询示例（更新版）

### 用户页面查询可用账号
```javascript
// 使用Supabase客户端查询可用账号
async function getAvailableAccounts() {
  const { data, error } = await supabase
    .from('available_accounts_view')
    .select('*')
    .order('created_at', { ascending: false });
    
  if (error) throw error;
  return data;
}
```

### 按条件筛选账号
```javascript
async function filterAccounts(minLevel, maxPrice) {
  const { data, error } = await supabase
    .from('available_accounts_view')
    .select('*')
    .gte('account_level', minLevel)
    .lte('price', maxPrice)
    .order('price', { ascending: true });
    
  if (error) throw error;
  return data;
}
```

### 商户页面插入账号
```javascript
// 插入新账号（不再需要手动设置created_at）
async function createAccount(accountData) {
  const { data, error } = await supabase
    .from('accounts')
    .insert([accountData])
    .single();
    
  if (error) throw error;
  return data;
}

// 调用示例
const newAccount = await createAccount({
  account_name: "高级账号",
  account_level: 50,
  haf_coin: 10000,
  stamina_level: 8,
  weight_level: 9,
  price: 500,
  description: "高等级账号，丰富游戏体验",
  username: "gameuser123",
  password: "securepassword",
  status: "available",
  merchant_id: "merchant_user_uuid"  // 需要确保是UUID格式
});
```

### 批量上传账号图片
```javascript
async function uploadAccountImages(accountId, imageUrls) {
  // 批量上传多个图片
  const imagesToInsert = imageUrls.map(url => ({
    account_id: accountId,
    image_url: url,
    // uploaded_at由数据库自动设置
  }));
  
  const { data, error } = await supabase
    .from('account_images')
    .insert(imagesToInsert);
    
  if (error) throw error;
  return data;
}","},{

## 注意事项与最佳实践

### 安全最佳实践
1. **安全提示**: 确保在前端代码中使用正确的API密钥，不要在前端暴露服务密钥
2. **权限验证**: 系统通过Row Level Security (RLS)确保数据安全，不同角色只能访问授权的数据
3. **类型安全**: 使用UUID类型存储用户ID，避免类型转换错误和潜在的安全风险
4. **敏感数据保护**: 确保在视图中过滤敏感信息，如Steam账号密码

### 性能与数据一致性
1. **数据一致性**: 账号状态变更时，需要同步更新相关数据
2. **性能优化**: 已为常用查询创建索引，确保查询性能
3. **避免不必要的转换**: 直接使用UUID类型比较，避免类型转换带来的性能开销
4. **批量操作**: 对于多个图片的上传，使用批量插入操作提高效率

## 后续扩展建议

1. **添加交易记录表**：跟踪账号购买历史
2. **实现评分系统**：允许用户对购买的账号进行评分
3. **增加搜索过滤**：基于账号属性添加高级搜索功能，考虑添加全文搜索支持
4. **添加推荐算法**：根据用户偏好推荐账号
5. **状态管理优化**：实现更完整的账号状态流转，如审核中、已售出、已下架等
6. **数据分析**：添加分析视图，帮助商户了解账号销售情况
7. **交易系统集成**：集成支付系统，实现账号购买的完整流程