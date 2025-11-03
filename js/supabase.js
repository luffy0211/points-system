// js/supabase.js - 使用配置文件中的凭据
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// 确保在引入此文件前已加载config.js
const supabaseUrl = window.SUPABASE_CONFIG?.url || 'https://ubxbdfkpneeibbylkdwo.supabase.co';
const supabaseKey = window.SUPABASE_CONFIG?.anonKey || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVieGJkZmtwbmVlaWJieWxrZHdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1OTc1NjQsImV4cCI6MjA3NjE3MzU2NH0.FsPXNLV9Ykd3jP8lfmCL1wIyhyZhx16glocadQ9eLMs';
export const supabase = createClient(supabaseUrl, supabaseKey);