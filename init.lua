-- LazyVim 配置入口文件
-- 负责引导 lazy.nvim 插件管理器并加载所有插件配置

-- 设置 lazy.nvim 插件管理器的安装路径
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- 如果 lazy.nvim 未安装，自动克隆仓库进行安装
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  -- 克隆失败时显示错误信息并退出
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
-- 将 lazy.nvim 添加到 Neovim 的运行时路径
vim.opt.rtp:prepend(lazypath)

-- 配置并启动 lazy.nvim 插件管理器
require("lazy").setup({
  spec = {
    -- 导入 lua/plugins/ 目录下的所有插件配置
    { import = "plugins" },
  },
  defaults = {
    -- 默认情况下，只有 LazyVim 插件会延迟加载，自定义插件在启动时加载
    -- 如果你了解延迟加载的机制，可以设为 true 让所有自定义插件也延迟加载
    lazy = false,
    -- 不建议固定版本号，因为很多支持版本控制的插件的发布版本较旧，可能导致问题
    version = false, -- 始终使用最新的 git commit
    -- version = "*", -- 尝试安装支持语义化版本的插件的最新稳定版
  },
  -- 安装插件时使用的默认配色方案
  install = { colorscheme = { "tokyonight-light" } },
  -- 自动检查插件更新
  checker = {
    enabled = true, -- 定期检查插件更新
    notify = false, -- 不显示更新通知（避免打扰）
  },
  -- 性能优化：禁用一些不常用的内置插件
  performance = {
    rtp = {
      -- 禁用一些不常用的内置 rtp 插件以加快启动速度
      disabled_plugins = {
        "gzip",        -- gzip 文件支持
        "matchit",     -- 扩展 % 匹配
        "matchparen",  -- 括号匹配高亮
        "netrwPlugin", -- 内置文件浏览器（使用 neo-tree 替代）
        "tarPlugin",   -- tar 归档文件支持
        "tohtml",      -- 转换为 HTML
        "tutor",       -- Neovim 教程
        "zipPlugin",   -- zip 文件支持
      },
    },
  },
})

-- Setup LazyVim configuration
require("config").setup()
