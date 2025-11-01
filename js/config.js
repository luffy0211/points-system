// Supabase 配置 - 替换为你的实际项目信息
const SUPABASE_CONFIG = {
    url: 'https://你的项目ID.supabase.co',  // 替换为你的 URL
    anonKey: '你的anon公钥'  // 替换为你的 anon key
};

// 系统配置
const SYSTEM_CONFIG = {
    imageReviewTimeLimit: 24,  // 图片审核时间限制（小时）
    redeemCooldown: 48,        // 兑换冷却时间（小时）
    pointsPerUpload: 10        // 每次上传获得的积分
};