-- Mini.indentscope：高亮显示当前缩进作用域，并提供动画效果
return {
  -- Mini.indentscope：高亮显示当前光标所在的缩进作用域
  -- 通过动画高亮，清晰展示当前代码块的范围，方便理解代码结构
  {
    "nvim-mini/mini.indentscope",
    version = false,
    event = "LazyFile",
    opts = {
      -- symbol = "▏",
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "Trouble",
          "alpha",
          "dashboard",
          "fzf",
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "notify",
          "sidekick_terminal",
          "snacks_dashboard",
          "snacks_notif",
          "snacks_terminal",
          "snacks_win",
          "toggleterm",
          "trouble",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "SnacksDashboardOpened",
        callback = function(data)
          vim.b[data.buf].miniindentscope_disable = true
        end,
      })
    end,
  },

  -- 启用 mini-indentscope 时禁用 indent-blankline 的 scope 功能
  {
    "lukas-reineke/indent-blankline.nvim",
    optional = true,
    event = "LazyFile",
    opts = {
      scope = { enabled = false },
    },
  },

  -- 启用 mini-indentscope 时禁用 snacks indent scope
  {
    "snacks.nvim",
    opts = {
      indent = {
        scope = { enabled = false },
      },
    },
  },
}
