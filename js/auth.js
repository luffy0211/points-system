import { supabase } from './supabase.js';

class AuthService {
    // 用户注册
    static async registerUser(email, password, username) {
        try {
            showLoading('注册中...');
            
            const { data, error } = await supabase.auth.signUp({
                email: email,
                password: password,
                options: {
                    data: {
                        username: username
                    }
                }
            });

            if (error) throw error;
            
            // 创建用户记录
            if (data.user) {
                const { error: dbError } = await supabase
                    .from('users')
                    .insert([
                        {
                            id: data.user.id,
                            email: email,
                            username: username,
                            points: 0,
                            created_at: new Date().toISOString()
                        }
                    ]);
                
                if (dbError) throw dbError;
            }
            
            hideLoading();
            return { 
                success: true, 
                user: data.user,
                message: '注册成功！'
            };
            
        } catch (error) {
            hideLoading();
            return { 
                success: false, 
                error: this.getErrorMessage(error) 
            };
        }
    }
    
    // 用户登录
    static async loginUser(email, password) {
        try {
            showLoading('登录中...');
            
            const { data, error } = await supabase.auth.signInWithPassword({
                email: email,
                password: password
            });

            if (error) throw error;
            
            hideLoading();
            return { 
                success: true, 
                user: data.user,
                message: '登录成功！'
            };
            
        } catch (error) {
            hideLoading();
            return { 
                success: false, 
                error: this.getErrorMessage(error) 
            };
        }
    }
    
    // 获取当前用户
    static async getCurrentUser() {
        try {
            const { data, error } = await supabase.auth.getUser();
            if (error) throw error;
            return data.user;
        } catch (error) {
            return null;
        }
    }
    
    // 检查登录状态
    static async checkAuth() {
        const user = await this.getCurrentUser();
        return !!user;
    }
    
    // 退出登录
    static async logout() {
        try {
            const { error } = await supabase.auth.signOut();
            if (error) throw error;
            return { success: true };
        } catch (error) {
            return { success: false, error: error.message };
        }
    }
    
    // 获取友好的错误信息
    static getErrorMessage(error) {
        if (error.message.includes('User already registered')) {
            return '该邮箱已被注册';
        } else if (error.message.includes('Invalid login credentials')) {
            return '邮箱或密码错误';
        } else if (error.message.includes('Email not confirmed')) {
            return '请先验证邮箱';
        } else if (error.message.includes('Password should be at least 6 characters')) {
            return '密码长度至少6位';
        } else if (error.message.includes('Invalid email')) {
            return '邮箱格式不正确';
        } else {
            return error.message || '发生未知错误';
        }
    }
}