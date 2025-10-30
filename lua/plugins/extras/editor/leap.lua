-- Leap：快速跳转到屏幕上的任意位置
-- 通过输入2个字符快速定位，比鼠标点击更高效
return {
  -- 禁用 flash 以使用 leap
  { "folke/flash.nvim", enabled = false, optional = true },

  -- flit：增强的 f/t 跳转，配合 Leap 使用
  {
    "ggandor/flit.nvim",
    enabled = true,
    keys = function()
      ---@type LazyKeysSpec[]
      local ret = {}
      for _, key in ipairs({ "f", "F", "t", "T" }) do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" } }
      end
      return ret
    end,
    opts = { labeled_modes = "nx" },
  },
  -- Leap：快速跳转插件，输入2个字符即可跳转到任意位置
  -- 比传统的 w/b 导航更快，适合在可见区域内快速移动
  {
    "ggandor/leap.nvim",
    enabled = true,
    keys = {
      { "s", mode = { "n", "x", "o" }, desc = "Leap Forward to" },
      { "S", mode = { "n", "x", "o" }, desc = "Leap Backward to" },
      { "gs", mode = { "n", "x", "o" }, desc = "Leap from Windows" },
    },
    config = function(_, opts)
      local leap = require("leap")
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      leap.add_default_mappings(true)
      vim.keymap.del({ "x", "o" }, "x")
      vim.keymap.del({ "x", "o" }, "X")
    end,
  },

  -- 将 surround 快捷键从 gs 改为 gz，避免与 leap 冲突
  {
    "nvim-mini/mini.surround",
    optional = true,
    opts = {
      mappings = {
        add = "gza", -- Add surrounding in Normal and Visual modes
        delete = "gzd", -- Delete surrounding
        find = "gzf", -- Find surrounding (to the right)
        find_left = "gzF", -- Find surrounding (to the left)
        highlight = "gzh", -- Highlight surrounding
        replace = "gzr", -- Replace surrounding
        update_n_lines = "gzn", -- Update `n_lines`
      },
    },
    keys = {
      { "gz", "", desc = "+surround" },
    },
  },

  -- vim-repeat：让 leap 等插件支持 . 命令重复操作
  { "tpope/vim-repeat", event = "VeryLazy" },
}
