-- Neovide GUI 配置
-- 仅在 Neovide 环境下加载

if not vim.g.neovide then
	return
end

-- ============================================
-- 基础窗口配置 - 简约风格
-- ============================================

-- 隐藏鼠标指针（输入时）
vim.g.neovide_hide_mouse_when_typing = true

-- 记住上次窗口大小和位置
vim.g.neovide_remember_window_size = true

-- 全屏设置（macOS 原生全屏）
vim.g.neovide_fullscreen = false

-- ============================================
-- 光标动画配置 - 简洁流畅
-- ============================================

-- 光标动画长度（毫秒，0 = 禁用动画）
vim.g.neovide_cursor_animation_length = 0.06

-- 光标轨迹长度（0.0-1.0，越小越简洁）
vim.g.neovide_cursor_trail_size = 0.3

-- 光标抗锯齿
vim.g.neovide_cursor_antialiasing = true

-- 光标粒子效果（留空或 ""，保持简约）
vim.g.neovide_cursor_vfx_mode = ""

-- ============================================
-- 滚动动画 - 平滑但不过度
-- ============================================

-- 滚动动画长度（毫秒）
vim.g.neovide_scroll_animation_length = 0.15

-- 滚动动画缓动函数（Far 更流畅）
vim.g.neovide_scroll_animation_far_lines = 1

-- ============================================
-- 透明度和模糊配置 - 简约干净
-- ============================================

-- 窗口透明度（0.0-1.0，1.0 = 不透明，推荐保持清晰）
vim.g.neovide_opacity = 1.0
vim.g.neovide_normal_opacity = 1.0

-- 背景模糊（macOS）
vim.g.neovide_window_blurred = false

-- ============================================
-- 浮动窗口配置
-- ============================================

-- 浮动窗口模糊（更现代的外观）
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0

-- 浮动窗口阴影
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_z_height = 10
vim.g.neovide_light_angle_degrees = 45
vim.g.neovide_light_radius = 5

-- ============================================
-- 性能优化
-- ============================================

-- 刷新率（设为 0 使用显示器刷新率）
vim.g.neovide_refresh_rate = 60

-- 空闲刷新率（降低功耗）
vim.g.neovide_refresh_rate_idle = 5

-- 无焦点时降低刷新率
vim.g.neovide_no_idle = false

-- ============================================
-- 字体配置 - 跨平台
-- ============================================

-- 检测操作系统
local is_mac = vim.fn.has("macunix") == 1
local is_windows = vim.fn.has("win32") == 1

-- 设置字体大小和字体族
-- 主字体：FiraCode Nerd Font（支持连字符）
-- 备选字体：等距更纱黑体 SC（中文显示）
vim.o.guifont = "FiraCode Nerd Font:h14"

-- 启用连字符（ligatures）- FiraCode 的核心特性
-- 连字符会自动将 ->, =>, !=, >= 等字符组合显示为特殊符号
-- vim.opt.guifont = vim.o.guifont -- 确保 guifont 生效

-- ============================================
-- 输入法配置 - macOS 优化
-- ============================================

vim.g.neovide_input_ime = true

if is_mac then
	-- macOS 输入法自动切换
	vim.g.neovide_input_macos_option_key_is_meta = "both"
end

-- 常用快捷键
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "保存文件" }) -- Cmd+S
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { desc = "保存文件" })
vim.keymap.set("n", "<C-v>", '"+p', { desc = "粘贴" }) -- Cmd+V
vim.keymap.set("i", "<C-v>", '<Esc>"+pa', { desc = "粘贴" })
vim.keymap.set("v", "<C-c>", '"+y', { desc = "复制" }) -- Cmd+C

-- ============================================
-- 清理 UI - 简约风格
-- ============================================

-- 禁用一些不必要的 UI 元素
-- vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- 更好的视觉效果
vim.g.neovide_confirm_quit = true -- 退出前确认
vim.g.neovide_padding_top = 0 -- 上边距
vim.g.neovide_padding_bottom = 0 -- 下边距
vim.g.neovide_padding_right = 0 -- 右边距
vim.g.neovide_padding_left = 0 -- 左边距

-- 触摸板手势支持（macOS）
if is_mac then
	vim.g.neovide_touch_deadzone = 6.0
	vim.g.neovide_touch_drag_timeout = 0.17
end

-- ============================================
-- 调试信息（可选）
-- ============================================

-- 取消注释以显示 Neovide 版本信息
-- vim.notify("Neovide 配置已加载 | 平台: " .. (is_mac and "macOS" or is_windows and "Windows" or "Linux"), vim.log.levels.INFO)
