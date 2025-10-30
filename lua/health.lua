-- LazyVim 健康检查模块
-- 用于检查 Neovim 版本、依赖工具和 Treesitter 解析器是否正确安装
-- 运行 :checkhealth lazyvim 来使用此模块
local M = {}

-- 兼容不同版本的健康检查 API
local start = vim.health.start or vim.health.report_start
local ok = vim.health.ok or vim.health.report_ok
local warn = vim.health.warn or vim.health.report_warn
local error = vim.health.error or vim.health.report_error
local info = vim.health.info or vim.health.report_info

function M.check()
  start("LazyVim")

  -- 检查 Neovim 版本
  if vim.fn.has("nvim-0.11.2") == 1 then
    ok("Using Neovim >= 0.11.2")
  else
    error("Neovim >= 0.11.2 is required")
  end

  -- 检查必要的外部工具是否已安装
  -- git: 版本控制, rg: 文本搜索, fd/fdfind: 文件查找, lazygit: Git TUI, fzf: 模糊查找, curl: 文件下载
  for _, cmd in ipairs({ "git", "rg", { "fd", "fdfind" }, "lazygit", "fzf", "curl" }) do
    local name = type(cmd) == "string" and cmd or vim.inspect(cmd)
    local commands = type(cmd) == "string" and { cmd } or cmd
    ---@cast commands string[]
    local found = false

    for _, c in ipairs(commands) do
      if vim.fn.executable(c) == 1 then
        name = c
        found = true
      end
    end

    if found then
      ok(("`%s` is installed"):format(name))
    else
      warn(("`%s` is not installed"):format(name))
    end
  end

  -- 检查 Treesitter 解析器和编译器
  start("LazyVim nvim-treesitter")
  local tsok, health = LazyVim.treesitter.check()
  local keys = vim.tbl_keys(health) ---@type string[]
  table.sort(keys)
  -- 逐个检查 Treesitter 相关组件（解析器、C 编译器等）
  for _, k in pairs(keys) do
    (health[k] and ok or error)(("`%s` is %s"):format(k, health[k] and "installed" or "not installed"))
  end
  -- 如果 Treesitter 检查失败，提供帮助信息
  if not tsok then
    info(
      "See the requirements at [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter/tree/main?tab=readme-ov-file#requirements)"
    )
    info("Run `:checkhealth nvim-treesitter` for more information.")
    -- Windows 用户特别提示：如何安装 C 编译器
    if vim.fn.has("win32") == 1 and not health["C compiler"] then
      info("Install a C compiler with `winget install --id=BrechtSanders.WinLibs.POSIX.UCRT -e`")
    end
  end
end

return M
