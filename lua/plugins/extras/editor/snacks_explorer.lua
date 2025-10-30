-- Snacks Explorer：Snacks 内置的文件浏览器
return {
  desc = "Snacks File Explorer",
  recommended = true,
  -- Snacks Explorer：轻量级文件浏览器，集成在 Snacks 插件中
  -- 提供简洁的文件管理功能，启动快速
  "folke/snacks.nvim",
  opts = { explorer = {} },
  keys = {
    {
      "<leader>fe",
      function()
        Snacks.explorer({ cwd = LazyVim.root() })
      end,
      desc = "Explorer Snacks (root dir)",
    },
    {
      "<leader>fE",
      function()
        Snacks.explorer()
      end,
      desc = "Explorer Snacks (cwd)",
    },
    { "<leader>e", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
    { "<leader>E", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
  },
}
