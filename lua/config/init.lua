_G.LazyVim = require("util")

---@class LazyVimConfig: LazyVimOptions
local M = {}

M.version = "15.12.2"
LazyVim.config = M

---@class LazyVimOptions
local defaults = {
  -- 主题可以是字符串如 `catppuccin` 或加载主题的函数
  ---@type string|fun()
  colorscheme = function()
    require("tokyonight").load({ style = "day" })
  end,
  -- 新闻配置
  news = {
    -- 启用时，NEWS.md 文件变化时会显示
    -- 仅包含主要新功能和破坏性更改
    -- 本地配置需在配置目录创建 NEWS.md
    lazyvim = false,
    -- Neovim 自身的新闻文件
    neovim = false,
  },
  -- 其他插件使用的图标
  -- stylua: ignore
  icons = {
    misc = {
      dots = "󰇘",
    },
    ft = {
      octo = "",
    },
    dap = {
      Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint          = " ",
      BreakpointCondition = " ",
      BreakpointRejected  = { " ", "DiagnosticError" },
      LogPoint            = ".>",
    },
    diagnostics = {
      Error = " ",
      Warn  = " ",
      Hint  = " ",
      Info  = " ",
    },
    git = {
      added    = " ",
      modified = " ",
      removed  = " ",
    },
    kinds = {
      Array         = " ",
      Boolean       = "󰨙 ",
      Class         = " ",
      Codeium       = "󰘦 ",
      Color         = " ",
      Control       = " ",
      Collapsed     = " ",
      Constant      = "󰏿 ",
      Constructor   = " ",
      Copilot       = " ",
      Enum          = " ",
      EnumMember    = " ",
      Event         = " ",
      Field         = " ",
      File          = " ",
      Folder        = " ",
      Function      = "󰊕 ",
      Interface     = " ",
      Key           = " ",
      Keyword       = " ",
      Method        = "󰊕 ",
      Module        = " ",
      Namespace     = "󰦮 ",
      Null          = " ",
      Number        = "󰎠 ",
      Object        = " ",
      Operator      = " ",
      Package       = " ",
      Property      = " ",
      Reference     = " ",
      Snippet       = "󱄽 ",
      String        = " ",
      Struct        = "󰆼 ",
      Supermaven    = " ",
      TabNine       = "󰏚 ",
      Text          = " ",
      TypeParameter = " ",
      Unit          = " ",
      Value         = " ",
      Variable      = "󰀫 ",
    },
  },
  ---@type table<string, string[]|boolean>?
  -- 符号种类过滤配置
  kind_filter = {
    default = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      "Package",
      "Property",
      "Struct",
      "Trait",
    },
    -- markdown、help 文件不显示任何符号
    markdown = false,
    help = false,
    -- Lua文件的自定义过滤规则
    lua = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      -- "Package", -- 移除 Package 因为 luals 用它表示控制流结构
      "Property",
      "Struct",
      "Trait",
    },
  },
}

M.json = {
  version = 8,
  loaded = false,
  -- lazyvim.json 配置文件路径
  path = vim.g.lazyvim_json or vim.fn.stdpath("config") .. "/lazyvim.json",
  -- 数据结构定义
  data = {
    version = nil, ---@type number?
    install_version = nil, ---@type number?
    news = {}, ---@type table<string, string>
    extras = {}, ---@type string[]
  },
}

-- 加载并解析 JSON 配置文件
function M.json.load()
  M.json.loaded = true
  local f = io.open(M.json.path, "r")
  if f then
    local data = f:read("*a")
    f:close()
    local ok, json = pcall(vim.json.decode, data, { luanil = { object = true, array = true } })
    if ok then
      M.json.data = vim.tbl_deep_extend("force", M.json.data, json or {})
      -- 版本不匹配时触发迁移
      if M.json.data.version ~= M.json.version then
        LazyVim.json.migrate()
      end
    end
  else
    -- 首次运行时记录安装版本
    M.json.data.install_version = M.json.version
  end
end

---@type LazyVimOptions
local options
-- 延迟加载系统剪贴板（某些程序可能很慢）
local lazy_clipboard

---@param opts? LazyVimOptions
function M.setup(opts)
  -- 合并用户选项与默认配置
  options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

  -- 未打开文件时延迟加载 autocmds
  local lazy_autocmds = vim.fn.argc(-1) == 0
  if not lazy_autocmds then
    M.load("autocmds")
  end

  local group = vim.api.nvim_create_augroup("LazyVim", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = function()
      -- 加载延迟的自动命令
      if lazy_autocmds then
        M.load("autocmds")
      end
      -- 加载快捷键映射
      M.load("keymaps")
      -- 应用延迟加载的剪贴板设置
      if lazy_clipboard ~= nil then
        vim.opt.clipboard = lazy_clipboard
      end

      LazyVim.format.setup()
      LazyVim.news.setup()
      LazyVim.root.setup()

      -- 定义 LazyExtras 命令
      vim.api.nvim_create_user_command("LazyExtras", function()
        LazyVim.extras.show()
      end, { desc = "Manage LazyVim extras" })

      -- 定义 LazyHealth 命令
      vim.api.nvim_create_user_command("LazyHealth", function()
        vim.cmd([[Lazy! load all]])
        vim.cmd([[checkhealth]])
      end, { desc = "Load all plugins and run :checkhealth" })

      local health = require("lazy.health")
      -- 扩展健康检查的有效字段
      vim.list_extend(health.valid, {
        "recommended",
        "desc",
        "vscode",
      })

      if vim.g.lazyvim_check_order == false then
        return
      end

      -- 检查 lazy.nvim 导入顺序
      local imports = require("lazy.core.config").spec.modules
      local function find(pat, last)
        for i = last and #imports or 1, last and 1 or #imports, last and -1 or 1 do
          if imports[i]:find(pat) then
            return i
          end
        end
      end
      -- 确保插件按正确顺序加载（本地插件需要检查）
      local plugins_base = find("^plugins$")
      local extras = find("^plugins%.extras%.", true) or plugins_base
      if plugins_base and extras and extras < plugins_base then
        local msg = {
          "The order of your `lazy.nvim` imports is incorrect:",
          "- `plugins` should be loaded first",
          "- followed by any `plugins.extras`",
          "",
          "If you think you know what you're doing, you can disable this check with:",
          "```lua",
          "vim.g.lazyvim_check_order = false",
          "```",
        }
        vim.notify(table.concat(msg, "\n"), "warn", { title = "LazyVim" })
      end
    end,
  })

  -- 加载配色方案
  LazyVim.track("colorscheme")
  LazyVim.try(function()
    if type(M.colorscheme) == "function" then
      M.colorscheme()
    else
      vim.cmd.colorscheme(M.colorscheme)
    end
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      LazyVim.error(msg)
      -- 回退到默认主题
      vim.cmd.colorscheme("habamax")
    end,
  })
  LazyVim.track()
end

---@param buf? number
---@return string[]?
-- 获取指定缓冲区的符号种类过滤规则
function M.get_kind_filter(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local ft = vim.bo[buf].filetype
  if M.kind_filter == false then
    return
  end
  if M.kind_filter[ft] == false then
    return
  end
  if type(M.kind_filter[ft]) == "table" then
    return M.kind_filter[ft]
  end
  ---@diagnostic disable-next-line: return-type-mismatch
  return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

---@param name "autocmds" | "options" | "keymaps"
-- 加载指定的配置模块
function M.load(name)
  local mod = "config." .. name
  -- 仅在模块存在时加载
  if require("lazy.core.cache").find(mod)[1] then
    LazyVim.try(function()
      require(mod)
    end, { msg = "Failed loading " .. mod })
  end

  -- 触发自动命令事件，供插件挂接
  local pattern = "LazyVim" .. name:sub(1, 1):upper() .. name:sub(2)
  vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })

  if vim.bo.filetype == "lazy" then
    -- HACK: 重置可能被覆盖的 Lazy UI 选项
    vim.cmd([[do VimResized]])
  end
end

M.did_init = false
M._options = {} ---@type vim.wo|vim.bo

-- 初始化配置
function M.init()
  if M.did_init then
    return
  end
  M.did_init = true
  -- 无需追加 LazyVim 插件目录（已使用本地代码）
  -- local plugin = require("lazy.core.config").spec.plugins.LazyVim
  -- if plugin then
  --   vim.opt.rtp:append(plugin.dir)
  -- end

  -- 为 require("plugins.lsp.format") 提供兼容包装
  package.preload["plugins.lsp.format"] = function()
    LazyVim.deprecate([[require("plugins.lsp.format")]], [[LazyVim.format]])
    return LazyVim.format
  end

  -- 延迟通知直到 vim.notify 被替换或500ms后
  LazyVim.lazy_notify()

  -- 在 lazy 初始化前加载选项（确保安装缺失插件后选项生效）
  M.load("options")

  -- 加载 Neovide GUI 配置
  M.load("neovide")

  -- 保存一些选项以追踪默认值
  M._options.indentexpr = vim.o.indentexpr
  M._options.foldmethod = vim.o.foldmethod
  M._options.foldexpr = vim.o.foldexpr

  -- 延迟加载系统剪贴板：xsel 和 pbcopy 可能很慢
  lazy_clipboard = vim.opt.clipboard:get()
  vim.opt.clipboard = ""

  if vim.g.deprecation_warnings == false then
    vim.deprecate = function() end
  end

  LazyVim.plugin.setup()
  M.json.load()
end

---@alias LazyVimDefault {name: string, extra: string, enabled?: boolean, origin?: "global" | "default" | "extra" }

local default_extras ---@type table<string, LazyVimDefault>
-- 获取默认extras配置
function M.get_defaults()
  if default_extras then
    return default_extras
  end
  ---@type table<string, LazyVimDefault[]>
  -- 定义各类组件的检测规则
  local checks = {
    -- 文件选择器
    picker = {
      { name = "snacks", extra = "editor.snacks_picker" },
      { name = "fzf", extra = "editor.fzf" },
      { name = "telescope", extra = "editor.telescope" },
    },
    -- 补全引擎
    cmp = {
      { name = "blink.cmp", extra = "coding.blink" },
      { name = "nvim-cmp", extra = "coding.nvim-cmp" },
    },
    -- 文件浏览器
    explorer = {
      { name = "snacks", extra = "editor.snacks_explorer" },
      { name = "neo-tree", extra = "editor.neo-tree" },
    },
  }

  -- 旧版本安装保持原有默认值
  if (LazyVim.config.json.data.install_version or 7) < 8 then
    table.insert(checks.picker, 1, table.remove(checks.picker, 2))
    table.insert(checks.explorer, 1, table.remove(checks.explorer, 2))
  end

  default_extras = {}
  for name, check in pairs(checks) do
    local valid = {} ---@type string[]
    for _, extra in ipairs(check) do
      if extra.enabled ~= false then
        valid[#valid + 1] = extra.name
      end
    end
    -- 尝试从全局变量读取用户设置
    local origin = "default"
    local use = vim.g["lazyvim_" .. name]
    use = vim.tbl_contains(valid, use or "auto") and use or nil
    origin = use and "global" or origin
    -- 如果未指定，从已启用的extras中检测
    for _, extra in ipairs(use and {} or check) do
      if extra.enabled ~= false and LazyVim.has_extra(extra.extra) then
        use = extra.name
        break
      end
    end
    origin = use and "extra" or origin
    -- 使用检测到的值或默认的第一项
    use = use or valid[1]
    -- 为所有检查项添加配置并标记启用的
    for _, extra in ipairs(check) do
      local import = "plugins.extras." .. extra.extra
      extra = vim.deepcopy(extra)
      extra.enabled = extra.name == use
      if extra.enabled then
        extra.origin = origin
      end
      default_extras[import] = extra
    end
  end
  return default_extras
end

-- 元表使 M 行为类似于选项对象
setmetatable(M, {
  __index = function(_, key)
    -- 未初始化时返回默认值的深拷贝
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    ---@cast options LazyVimConfig
    return options[key]
  end,
})

return M
