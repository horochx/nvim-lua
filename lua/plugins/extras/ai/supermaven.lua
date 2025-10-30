-- Supermaven：高性能 AI 代码补全，号称比 Copilot 更快的响应速度
return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    cmd = {
      "SupermavenUseFree",
      "SupermavenUsePro",
    },
    opts = {
      keymaps = {
        -- 统一由补全插件处理接受操作
        accept_suggestion = nil,
      },
      -- 在补全模式下禁用内联以避免冲突
      disable_inline_completion = vim.g.ai_cmp,
      -- 排除不需要补全的特殊文件类型
      ignore_filetypes = { "bigfile", "snacks_input", "snacks_notif" },
    },
  },

  -- 配置统一的接受动作以支持全局快捷键
  {
    "supermaven-inc/supermaven-nvim",
    opts = function()
      require("supermaven-nvim.completion_preview").suggestion_group = "SupermavenSuggestion"
      LazyVim.cmp.actions.ai_accept = function()
        local suggestion = require("supermaven-nvim.completion_preview")
        if suggestion.has_suggestion() then
          LazyVim.create_undo()
          vim.schedule(function()
            suggestion.on_accept_suggestion()
          end)
          return true
        end
      end
    end,
  },

  -- 集成为 nvim-cmp 补全源
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "supermaven-nvim" },
    opts = function(_, opts)
      if vim.g.ai_cmp then
        table.insert(opts.sources, 1, {
          name = "supermaven",
          group_index = 1,
          priority = 100,
        })
      end
    end,
  },

  -- blink.cmp 通过兼容层支持 Supermaven
  vim.g.ai_cmp and {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "supermaven-nvim", "saghen/blink.compat" },
    opts = {
      sources = {
        compat = { "supermaven" },
        providers = {
          supermaven = {
            kind = "Supermaven",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  } or nil,

  -- 状态栏显示 Supermaven 状态
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 2, LazyVim.lualine.cmp_source("supermaven"))
    end,
  },

  -- 隐藏启动提示消息以减少干扰
  {
    "folke/noice.nvim",
    optional = true,
    opts = function(_, opts)
      vim.list_extend(opts.routes, {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "Starting Supermaven" },
              { find = "Supermaven Free Tier" },
            },
          },
          skip = true,
        },
      })
    end,
  },
}
