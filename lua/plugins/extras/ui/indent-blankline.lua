-- Indent-blankline：显示缩进参考线，帮助识别代码层次结构
return {
  -- 启用 indent-blankline 时禁用 snacks indent 以避免冲突
  {
    "snacks.nvim",
    opts = {
      indent = { enabled = false },
    },
  },

  -- Indent-blankline：在代码中显示垂直缩进参考线
  -- 清晰展示代码块的嵌套层次，特别适合Python、YAML等依赖缩进的语言
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "LazyFile",
    opts = function()
      Snacks.toggle({
        name = "Indention Guides",
        get = function()
          return require("ibl.config").get_config(0).enabled
        end,
        set = function(state)
          require("ibl").setup_buffer(0, { enabled = state })
        end,
      }):map("<leader>ug")

      return {
        indent = {
          char = "│",
          tab_char = "│",
        },
        scope = { show_start = false, show_end = false },
        exclude = {
          filetypes = {
            "Trouble",
            "alpha",
            "dashboard",
            "help",
            "lazy",
            "mason",
            "neo-tree",
            "notify",
            "snacks_dashboard",
            "snacks_notif",
            "snacks_terminal",
            "snacks_win",
            "toggleterm",
            "trouble",
          },
        },
      }
    end,
    main = "ibl",
  },
}
