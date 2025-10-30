-- LuaSnip：功能强大的代码片段引擎，支持复杂的片段逻辑和动态内容
return {
  -- 禁用内置片段支持以使用 LuaSnip
  { "garymjr/nvim-snippets", optional = true, enabled = false },

  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    -- jsregexp 是可选的，构建失败不影响基本功能
    build = (not LazyVim.is_win())
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          -- 加载社区维护的片段集
          require("luasnip.loaders.from_vscode").lazy_load()
          -- 加载用户自定义片段
          require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
        end,
      },
    },
    opts = {
      -- 记住跳转历史以支持回退
      history = true,
      -- 文本改变时删除片段以避免状态不一致
      delete_check_events = "TextChanged",
    },
  },

  -- 注册片段跳转动作
  {
    "L3MON4D3/LuaSnip",
    opts = function()
      LazyVim.cmp.actions.snippet_forward = function()
        if require("luasnip").jumpable(1) then
          vim.schedule(function()
            require("luasnip").jump(1)
          end)
          return true
        end
      end
      -- 退出片段时取消链接
      LazyVim.cmp.actions.snippet_stop = function()
        if require("luasnip").expand_or_jumpable() then
          require("luasnip").unlink_current()
          return true
        end
      end
    end,
  },

  -- nvim-cmp 集成
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "saadparwaiz1/cmp_luasnip" },
    opts = function(_, opts)
      opts.snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      }
      table.insert(opts.sources, { name = "luasnip" })
    end,
    -- stylua: ignore
    keys = {
      { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
      { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
  },

  -- blink.cmp 集成
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      snippets = {
        preset = "luasnip",
      },
    },
  },
}
