return {
  -- 自动配对插件
  -- 提供智能的括号、引号等符号自动配对，避免手动输入闭合符号的重复劳动
  {
    "nvim-mini/mini.pairs",
    event = "VeryLazy",
    opts = {
      modes = { insert = true, command = true, terminal = false },
      -- 某些情况下不自动配对，防止干扰正常输入
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- 在字符串节点内不自动配对，避免破坏字符串结构
      skip_ts = { "string" },
      -- 检测配对平衡性，避免产生多余的闭合符号
      skip_unbalanced = true,
      -- 特殊处理 Markdown 代码块，因为其语法与通用规则不同
      markdown = true,
    },
    config = function(_, opts)
      LazyVim.mini.pairs(opts)
    end,
  },

  -- 增强的注释处理
  -- 让 Neovim 能够正确处理一个语言中的多种注释语法（如 tsx 文件中的 js 和 jsx 注释）
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- 扩展文本对象选择
  -- 支持选择函数参数、函数调用、引号内容、括号内容等更复杂的文本对象，提高编辑效率
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- 代码块
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- 函数
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- 类
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- 标签
          d = { "%f[%d]%d+" }, -- 数字
          e = { -- 带大小写的单词
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          g = LazyVim.mini.ai_buffer, -- 缓冲区
          u = ai.gen_spec.function_call(), -- u 表示用法（Usage）
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- 不包含点号的函数名
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      LazyVim.on_load("which-key.nvim", function()
        vim.schedule(function()
          LazyVim.mini.ai_whichkey(opts)
        end)
      end)
    end,
  },

  -- Lua 语言服务器配置
  -- 为编辑 Neovim 配置提供准确的自动补全和类型检查，因为需要特殊的库定义
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "LazyVim", words = { "LazyVim" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
      },
    },
  },
}
