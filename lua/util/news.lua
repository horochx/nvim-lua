---@class lazyvim.util.news
local M = {}

function M.hash(file)
  local stat = vim.uv.fs_stat(file)
  if not stat then
    return
  end
  return stat.size .. ""
end

function M.setup()
  vim.schedule(function()
    if LazyVim.config.news.lazyvim then
      if not LazyVim.config.json.data.news["NEWS.md"] then
        M.welcome()
      end
      M.lazyvim(true)
    end
    if LazyVim.config.news.neovim then
      M.neovim(true)
    end
  end)
end

function M.welcome()
  LazyVim.info("Welcome to LazyVim!")
end

function M.changelog()
  -- Since we're using local LazyVim code, look for CHANGELOG.md in config root
  local changelog = vim.fn.stdpath("config") .. "/CHANGELOG.md"
  if vim.fn.filereadable(changelog) == 1 then
    M.open(changelog, {})
  else
    LazyVim.warn("CHANGELOG.md not found in config directory")
  end
end

function M.lazyvim(when_changed)
  -- Since we're using local LazyVim code, look for NEWS.md in config root
  local news = vim.fn.stdpath("config") .. "/NEWS.md"
  if vim.fn.filereadable(news) == 1 then
    M.open(news, { when_changed = when_changed })
  end
  -- Silently skip if NEWS.md doesn't exist (no need to warn on every startup)
end

function M.neovim(when_changed)
  M.open("doc/news.txt", { rtp = true, when_changed = when_changed })
end

---@param file string
---@param opts? {plugin?:string, rtp?:boolean, when_changed?:boolean}
function M.open(file, opts)
  local ref = file
  opts = opts or {}
  if opts.plugin then
    local plugin = require("lazy.core.config").plugins[opts.plugin] --[[@as LazyPlugin?]]
    if not plugin then
      return LazyVim.error("plugin not found: " .. opts.plugin)
    end
    file = plugin.dir .. "/" .. file
  elseif opts.rtp then
    file = vim.api.nvim_get_runtime_file(file, false)[1]
  end
  -- If file is already an absolute path, use it as-is

  if not file then
    return LazyVim.error("File not found")
  end

  if opts.when_changed then
    local is_new = not LazyVim.config.json.data.news[ref]
    local hash = M.hash(file)
    if hash == LazyVim.config.json.data.news[ref] then
      return
    end
    LazyVim.config.json.data.news[ref] = hash
    LazyVim.json.save()
    -- don't open if file has never been opened
    if is_new then
      return
    end
  end

  Snacks.config.style("news", {
    width = 0.6,
    height = 0.6,
    wo = {
      spell = false,
      wrap = false,
      signcolumn = "yes",
      statuscolumn = " ",
      conceallevel = 3,
    },
  })

  local float = Snacks.win({
    file = file,
    style = "news",
  })

  if vim.diagnostic.enable then
    pcall(vim.diagnostic.enable, false, { bufnr = float.buf })
  else
    pcall(vim.diagnostic.disable, float.buf)
  end
end

return M
