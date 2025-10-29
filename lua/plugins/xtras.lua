-- 某些扩展需要在其他扩展之前加载，这里定义加载优先级
local prios = {
  ["plugins.extras.test.core"] = 1,
  ["plugins.extras.dap.core"] = 1,
  ["plugins.extras.coding.nvim-cmp"] = 2,
  ["plugins.extras.editor.neo-tree"] = 2,
  ["plugins.extras.ui.edgy"] = 3,
  ["plugins.extras.ai.copilot-native"] = 4,
  ["plugins.extras.coding.blink"] = 5,
  ["plugins.extras.lang.typescript"] = 5,
  ["plugins.extras.formatting.prettier"] = 10,
  -- default core extra priority is 20
  -- default priority is 50
  ["plugins.extras.editor.aerial"] = 100,
  ["plugins.extras.editor.outline"] = 100,
  ["plugins.extras.ui.alpha"] = 19,
  ["plugins.extras.ui.dashboard-nvim"] = 19,
  ["plugins.extras.ui.mini-starter"] = 19,
}

if vim.g.xtras_prios then
  prios = vim.tbl_deep_extend("force", prios, vim.g.xtras_prios or {})
end

local extras = {} ---@type string[]
local defaults = LazyVim.config.get_defaults()

local changed = false
local updated = {} ---@type string[]

-- 从 LazyExtras 添加未被禁用的扩展
for _, extra in ipairs(LazyVim.config.json.data.extras) do
  if LazyVim.plugin.renamed_extras[extra] then
    extra = LazyVim.plugin.renamed_extras[extra]
    changed = true
  end
  if LazyVim.plugin.deprecated_extras[extra] then
    changed = true
  else
    updated[#updated + 1] = extra
    local def = defaults[extra]
    if not (def and def.enabled == false) then
      extras[#extras + 1] = extra
    end
  end
end

if changed then
  LazyVim.config.json.data.extras = updated
  LazyVim.json.save()
end

-- 添加默认扩展
for name, extra in pairs(defaults) do
  if extra.enabled then
    prios[name] = prios[name] or 20
    extras[#extras + 1] = name
  end
end

---@type string[]
extras = LazyVim.dedup(extras)

LazyVim.plugin.save_core()
if vim.g.vscode then
  table.insert(extras, 1, "plugins.extras.vscode")
end

-- 按优先级排序扩展
table.sort(extras, function(a, b)
  local pa = prios[a] or 50
  local pb = prios[b] or 50
  if pa == pb then
    return a < b
  end
  return pa < pb
end)

---@param extra string
-- 将所有扩展映射为可导入的格式
return vim.tbl_map(function(extra)
  return { import = extra }
end, extras)
