// js/supabase.js 示例内容
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabaseUrl = 'https://ubxbdfkpneeibbylkdwo.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVieGJkZmtwbmVlaWJieWxrZHdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1OTc1NjQsImV4cCI6MjA3NjE3MzU2NH0.FsPXNLV9Ykd3jP8lfmCL1wIyhyZhx16glocadQ9eLMs';
export const supabase = createClient(supabaseUrl, supabaseKey);