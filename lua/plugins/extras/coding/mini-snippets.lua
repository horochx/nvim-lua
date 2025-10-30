-- mini.snippets：轻量级代码片段引擎，作为 LuaSnip 的简洁替代方案
if lazyvim_docs then
  -- 设为 false 可防止片段出现在补全窗口中，减少干扰
  vim.g.lazyvim_mini_snippets_in_completion = true
end

local include_in_completion = vim.g.lazyvim_mini_snippets_in_completion == nil
  or vim.g.lazyvim_mini_snippets_in_completion

local function expand_from_lsp(snippet)
  local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
  insert({ body = snippet })
end

local function jump(direction)
  local is_active = MiniSnippets.session.get(false) ~= nil
  if is_active then
    MiniSnippets.session.jump(direction)
    return true
  end
end

---@type fun(snippets, insert) | nil
local expand_select_override = nil

return {
  -- 禁用其他片段引擎
  { "garymjr/nvim-snippets", optional = true, enabled = false },
  { "L3MON4D3/LuaSnip", optional = true, enabled = false },

  desc = "Manage and expand snippets (alternative to Luasnip)",
  {
    "nvim-mini/mini.snippets",
    event = "InsertEnter",
    dependencies = "rafamadriz/friendly-snippets",
    opts = function()
      -- 按设计 Esc 不应停止会话，而是用于临时编辑
      ---@diagnostic disable-next-line: duplicate-set-field
      LazyVim.cmp.actions.snippet_stop = function() end
      ---@diagnostic disable-next-line: duplicate-set-field
      LazyVim.cmp.actions.snippet_forward = function()
        return jump("next")
      end

      local mini_snippets = require("mini.snippets")
      return {
        -- 从 friendly-snippets 加载片段
        snippets = { mini_snippets.gen_loader.from_lang() },

        expand = {
          select = function(snippets, insert)
            -- 片段选择时关闭补全窗口，移除虚拟文本
            local select = expand_select_override or MiniSnippets.default_select
            select(snippets, insert)
          end,
        },
      }
    end,
  },

  -- nvim-cmp 集成
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = include_in_completion and { "abeldekat/cmp-mini-snippets" } or nil,
    opts = function(_, opts)
      local cmp = require("cmp")
      local cmp_config = require("cmp.config")

      opts.snippet = {
        expand = function(args)
          expand_from_lsp(args.body)
          -- 展开后重新订阅事件并临时禁用源以避免重复触发
          cmp.resubscribe({ "TextChangedI", "TextChangedP" })
          cmp_config.set_onetime({ sources = {} })
        end,
      }

      if include_in_completion then
        table.insert(opts.sources, { name = "mini_snippets" })
      else
        -- 独立模式：展开时关闭补全窗口
        expand_select_override = function(snippets, insert)
          -- stylua: ignore
          if cmp.visible() then cmp.close() end
          MiniSnippets.default_select(snippets, insert)
        end
      end
    end,
    -- stylua: ignore
    keys = include_in_completion and { { "<s-tab>", function() jump("prev") end, mode = "i" } } or nil,
  },

  -- blink.cmp 集成
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      -- 集成模式：作为补全源
      if include_in_completion then
        opts.snippets = { preset = "mini_snippets" }
        return
      end

      -- 独立模式：移除默认片段源
      local blink = require("blink.cmp")
      expand_select_override = function(snippets, insert)
        -- 延迟执行以确保虚拟文本被移除
        blink.cancel()
        vim.schedule(function()
          MiniSnippets.default_select(snippets, insert)
        end)
      end

      -- 移除 snippets 源
      opts.sources.default = vim.tbl_filter(function(source)
        return source ~= "snippets"
      end, opts.sources.default)

      opts.snippets = {
        expand = function(snippet)
          expand_from_lsp(snippet)
          blink.resubscribe()
        end,
        active = function()
          return MiniSnippets.session.get(false) ~= nil
        end,
        jump = function(direction)
          jump(direction == -1 and "prev" or "next")
        end,
      }
    end,
  },
}
