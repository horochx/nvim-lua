return {
  -- 代码检查工具
  -- 异步调用各种语言特定的代码检查工具，通过 vim.diagnostic 模块报告问题
  {
    "mfussenegger/nvim-lint",
    event = "LazyFile",
    opts = {
      -- 触发代码检查的事件
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        fish = { "fish" },
        -- 使用 "*" 文件类型可在所有文件类型上运行检查器
        -- ['*'] = { 'global linter' },
        -- 使用 "_" 文件类型可在没有配置其他检查器的文件类型上运行
        -- ['_'] = { 'fallback linter' },
        -- ["*"] = { "typos" },
      },
      -- LazyVim 扩展，用于轻松覆盖检查器选项或添加自定义检查器
      ---@type table<string,table>
      linters = {
        -- -- Example of using selene only when a selene.toml file is present
        -- selene = {
        --   -- `condition` is another LazyVim extension that allows you to
        --   -- dynamically enable/disable linters based on the context.
        --   condition = function(ctx)
        --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
      },
    },
    config = function(_, opts)
      local M = {}

      local lint = require("lint")
      for name, linter in pairs(opts.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
          if type(linter.prepend_args) == "table" then
            lint.linters[name].args = lint.linters[name].args or {}
            vim.list_extend(lint.linters[name].args, linter.prepend_args)
          end
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      function M.debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      function M.lint()
        -- 首先使用 nvim-lint 的逻辑：
        -- * 先检查完整文件类型是否存在检查器
        -- * 否则将按 "." 分割文件类型并添加所有这些检查器
        -- * 这与 conform.nvim 的行为不同，后者只使用第一个有格式化器的文件类型
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)

        -- 创建 names 表的副本以避免修改原始表
        names = vim.list_extend({}, names)

        -- 添加后备检查器
        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft["_"] or {})
        end

        -- 添加全局检查器
        vim.list_extend(names, lint.linters_by_ft["*"] or {})

        -- 过滤掉不存在或不匹配条件的检查器
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            LazyVim.warn("Linter not found: " .. name, { title = "nvim-lint" })
          end
          return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, names)

        -- 运行检查器
        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = M.debounce(100, M.lint),
      })
    end,
  },
}
