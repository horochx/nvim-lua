---@diagnostic disable: missing-fields
-- blink.cmp：用 Rust 编写的高性能补全引擎，比 nvim-cmp 更快
if lazyvim_docs then
  -- 设为 true 跟随主分支开发（需要 Rust 工具链编译）
  vim.g.lazyvim_blink_main = false
end

return {
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    -- 启用 blink 时禁用 nvim-cmp
    enabled = false,
  },
  {
    "saghen/blink.cmp",
    version = not vim.g.lazyvim_blink_main and "*",
    build = vim.g.lazyvim_blink_main and "cargo build --release",
    opts_extend = {
      "sources.completion.enabled_providers",
      "sources.compat",
      "sources.default",
    },
    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "saghen/blink.compat",
        -- 可选依赖，仅在需要兼容 nvim-cmp 源时启用
        optional = true,
        opts = {},
        version = not vim.g.lazyvim_blink_main and "*",
      },
    },
    event = { "InsertEnter", "CmdlineEnter" },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      snippets = {
        preset = "default",
      },

      appearance = {
        -- 主题未支持时回退到 nvim-cmp 高亮组
        use_nvim_cmp_as_default = false,
        -- mono 用于等宽图标字体，确保对齐
        nerd_font_variant = "mono",
      },

      completion = {
        accept = {
          -- 实验性自动括号功能
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          draw = {
            -- 为 LSP 项使用 treesitter 高亮
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          -- 延迟显示文档以避免频繁弹出
          auto_show_delay_ms = 200,
        },
        ghost_text = {
          -- 仅在 AI 补全模式下启用幽灵文本
          enabled = vim.g.ai_cmp,
        },
      },

      sources = {
        -- 通过 blink.compat 支持 nvim-cmp 源
        compat = {},
        default = { "lsp", "path", "snippets", "buffer" },
      },

      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
          -- 禁用左右箭头避免干扰命令行编辑
          ["<Right>"] = false,
          ["<Left>"] = false,
        },
        completion = {
          list = { selection = { preselect = false } },
          menu = {
            -- 仅在命令模式下自动显示
            auto_show = function(ctx)
              return vim.fn.getcmdtype() == ":"
            end,
          },
          ghost_text = { enabled = true },
        },
      },

      keymap = {
        preset = "enter",
        ["<C-y>"] = { "select_and_accept" },
      },
    },
    ---@param opts blink.cmp.Config | { sources: { compat: string[] } }
    config = function(_, opts)
      if opts.snippets and opts.snippets.preset == "default" then
        opts.snippets.expand = LazyVim.cmp.expand
      end
      -- 设置兼容源以支持 nvim-cmp 插件
      local enabled = opts.sources.default
      for _, source in ipairs(opts.sources.compat or {}) do
        opts.sources.providers[source] = vim.tbl_deep_extend(
          "force",
          { name = source, module = "blink.compat.source" },
          opts.sources.providers[source] or {}
        )
        if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
          table.insert(enabled, source)
        end
      end

      -- 添加 AI 接受功能到 Tab 键
      if not opts.keymap["<Tab>"] then
        if opts.keymap.preset == "super-tab" then
          opts.keymap["<Tab>"] = {
            require("blink.cmp.keymap.presets").get("super-tab")["<Tab>"][1],
            LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" }),
            "fallback",
          }
        else
          opts.keymap["<Tab>"] = {
            LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" }),
            "fallback",
          }
        end
      end

      -- 移除自定义属性以通过验证
      opts.sources.compat = nil

      -- 为自定义补全源注册图标类型
      for _, provider in pairs(opts.sources.providers or {}) do
        ---@cast provider blink.cmp.SourceProviderConfig|{kind?:string}
        if provider.kind then
          local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
          local kind_idx = #CompletionItemKind + 1

          CompletionItemKind[kind_idx] = provider.kind
          ---@diagnostic disable-next-line: no-unknown
          CompletionItemKind[provider.kind] = kind_idx

          ---@type fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[]
          local transform_items = provider.transform_items
          ---@param ctx blink.cmp.Context
          ---@param items blink.cmp.CompletionItem[]
          provider.transform_items = function(ctx, items)
            items = transform_items and transform_items(ctx, items) or items
            for _, item in ipairs(items) do
              item.kind = kind_idx or item.kind
              item.kind_icon = LazyVim.config.icons.kinds[item.kind_name] or item.kind_icon or nil
            end
            return items
          end

          provider.kind = nil
        end
      end

      require("blink.cmp").setup(opts)
    end,
  },

  -- 添加图标配置
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons = vim.tbl_extend("force", opts.appearance.kind_icons or {}, LazyVim.config.icons.kinds)
    end,
  },

  -- 集成 lazydev 以提供 Neovim Lua API 补全
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            -- 高优先级显示 Lua API
            score_offset = 100,
          },
        },
      },
    },
  },
  -- Catppuccin 主题集成
  {
    "catppuccin",
    optional = true,
    opts = {
      integrations = { blink_cmp = true },
    },
  },
}
