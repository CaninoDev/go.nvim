local M = {}
function M.list(mod, args)
  local cmd = {'go', 'list', '-json'}

  local out
  if mod == false then
    table.insert(cmd, 1, 'GO111MODULE=off')
  end

  vim.list_extend(cmd, args or {'.'})
  out = vim.fn.systemlist(table.concat(cmd, ' '))
  if vim.v.shell_error ~= 0 then
    return false
  end
  for i, e in ipairs(out) do
    if e == '}' and out[i + 1] == '{' then
      out[i] = '},'
    end
  end
  return true, vim.json.decode('[' .. table.concat(out, '') .. ']')
end

return M
