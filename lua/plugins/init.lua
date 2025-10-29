if vim.fn.has("nvim-0.11.2") == 0 then
  vim.api.nvim_echo({
    { "LazyVim requires Neovim >= 0.11.2\n", "ErrorMsg" },
    { "For more info, see: https://github.com/LazyVim/LazyVim/issues/6421\n", "Comment" },
    { "Press any key to exit", "MoreMsg" },
  }, true, {})
  vim.fn.getchar()
  vim.cmd([[quit]])
  return {}
end

require("config").init()

return {
  -- 插件管理器
  -- 用于管理所有 Neovim 插件的加载和更新
  { "folke/lazy.nvim", version = "*" },
  -- 核心工具集
  -- 提供通知、终端、大文件处理等基础功能，是 LazyVim 的核心依赖
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {},
    config = function(_, opts)
      local notify = vim.notify
      require("snacks").setup(opts)
      -- HACK: 在 snacks 设置后恢复 vim.notify，让 noice.nvim 接管
      -- 这是为了让早期通知能够显示在 noice 历史记录中
      if LazyVim.has("noice.nvim") then
        vim.notify = notify
      end
    end,
  },
}
