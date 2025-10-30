-- Codeium：免费的 AI 代码补全服务，作为 Copilot 的替代方案
return {

  {
    "Exafunction/codeium.nvim",
    cmd = "Codeium",
    event = "InsertEnter",
    build = ":Codeium Auth",
    opts = {
      -- 根据补全模式决定是否启用 cmp 源
      enable_cmp_source = vim.g.ai_cmp,
      virtual_text = {
        -- 在独立模式下使用虚拟文本，补全模式下由 cmp 处理
        enabled = not vim.g.ai_cmp,
        key_bindings = {
          -- 统一由补全插件处理接受操作
          accept = false,
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
    },
  },

  -- 注册统一的 AI 接受动作供全局快捷键使用
  {
    "Exafunction/codeium.nvim",
    opts = function()
      LazyVim.cmp.actions.ai_accept = function()
        if require("codeium.virtual_text").get_current_completion_item() then
          LazyVim.create_undo()
          vim.api.nvim_input(require("codeium.virtual_text").accept())
          return true
        end
      end
    end,
  },

  -- 将 Codeium 作为高优先级补全源以优先展示 AI 建议
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "codeium.nvim" },
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "codeium",
        group_index = 1,
        priority = 100,
      })
    end,
  },

  -- 在状态栏展示 Codeium 连接状态
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 2, LazyVim.lualine.cmp_source("codeium"))
    end,
  },

  -- blink.cmp 通过兼容层集成 Codeium
  vim.g.ai_cmp and {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "codeium.nvim", "saghen/blink.compat" },
    opts = {
      sources = {
        compat = { "codeium" },
        providers = {
          codeium = {
            kind = "Codeium",
            -- 高分值确保排在前面
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  } or nil,
}
