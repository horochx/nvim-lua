-- TabNine：本地运行的 AI 代码补全，注重隐私保护
return {
  {
    "tzachar/cmp-tabnine",
    -- 根据操作系统选择安装脚本
    build = LazyVim.is_win() and "pwsh -noni .\\install.ps1" or "./install.sh",
    opts = {
      -- 限制上下文行数以平衡性能和准确性
      max_lines = 1000,
      max_num_results = 3,
      sort = true,
    },
    config = function(_, opts)
      require("cmp_tabnine.config"):setup(opts)
    end,
  },

  -- 集成为高优先级补全源
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "tzachar/cmp-tabnine" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "cmp_tabnine",
        group_index = 1,
        priority = 100,
      })

      -- 隐藏百分比以简化菜单显示
      opts.formatting.format = LazyVim.inject.args(opts.formatting.format, function(entry, item)
        if entry.source.name == "cmp_tabnine" then
          item.menu = ""
        end
      end)
    end,
  },

  -- blink.cmp 通过兼容层支持 TabNine
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "tzachar/cmp-tabnine", "saghen/blink.compat" },
    opts = {
      sources = {
        compat = { "cmp_tabnine" },
        providers = {
          cmp_tabnine = {
            kind = "TabNine",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },

  -- 状态栏显示 TabNine 状态
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      local icon = LazyVim.config.icons.kinds.TabNine
      table.insert(opts.sections.lualine_x, 2, LazyVim.lualine.cmp_source("cmp_tabnine", icon))
    end,
  },
}
