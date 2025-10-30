-- GitHub Copilot 代码补全插件：提供 AI 驱动的代码建议，加速开发流程
return {
  recommended = true,
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufReadPost",
    opts = {
      suggestion = {
        -- 使用独立的补全引擎时禁用内联建议，避免与 nvim-cmp/blink.cmp 冲突
        enabled = not vim.g.ai_cmp,
        auto_trigger = true,
        -- 在补全菜单显示时隐藏建议，防止界面混乱
        hide_during_completion = vim.g.ai_cmp,
        keymap = {
          -- 由补全插件统一处理接受操作，保持一致的用户体验
          accept = false,
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      -- 禁用面板以简化界面，主要通过内联建议使用
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- copilot.lua 有自己的实现，不需要额外的 LSP 服务器
        copilot = { enabled = false },
      },
    },
  },

  -- 注册 AI 接受动作以支持统一的补全接受快捷键
  {
    "zbirenbaum/copilot.lua",
    opts = function()
      LazyVim.cmp.actions.ai_accept = function()
        if require("copilot.suggestion").is_visible() then
          LazyVim.create_undo()
          require("copilot.suggestion").accept()
          return true
        end
      end
    end,
  },

  -- 在状态栏显示 Copilot 状态以便实时了解服务可用性
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(
        opts.sections.lualine_x,
        2,
        LazyVim.lualine.status(LazyVim.config.icons.kinds.Copilot, function()
          local clients = package.loaded["copilot"] and vim.lsp.get_clients({ name = "copilot", bufnr = 0 }) or {}
          if #clients > 0 then
            local status = require("copilot.status").data.status
            return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
          end
        end)
      )
    end,
  },

  -- 仅在启用补全插件时集成 Copilot 作为补全源
  vim.g.ai_cmp
      and {
        {
          "hrsh7th/nvim-cmp",
          optional = true,
          dependencies = {
            {
              "zbirenbaum/copilot-cmp",
              opts = {},
              config = function(_, opts)
                local copilot_cmp = require("copilot_cmp")
                copilot_cmp.setup(opts)
                -- 在 Copilot 附加时注册补全源，解决懒加载导致的源丢失问题
                Snacks.util.lsp.on({ name = "copilot" }, function()
                  copilot_cmp._on_insert_enter({})
                end)
              end,
              specs = {
                {
                  "hrsh7th/nvim-cmp",
                  optional = true,
                  ---@param opts cmp.ConfigSchema
                  opts = function(_, opts)
                    -- 将 Copilot 设为最高优先级源，优先显示 AI 建议
                    table.insert(opts.sources, 1, {
                      name = "copilot",
                      group_index = 1,
                      priority = 100,
                    })
                  end,
                },
              },
            },
          },
        },
        {
          "saghen/blink.cmp",
          optional = true,
          dependencies = { "fang2hou/blink-copilot" },
          opts = {
            sources = {
              default = { "copilot" },
              providers = {
                copilot = {
                  name = "copilot",
                  module = "blink-copilot",
                  -- 高分值确保 AI 建议排在前面
                  score_offset = 100,
                  async = true,
                },
              },
            },
          },
        },
      }
    or nil,
}
