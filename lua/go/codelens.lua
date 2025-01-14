local utils = require "go.utils"
local log = utils.log
local codelens = require "vim.lsp.codelens"
local api = vim.api

-- ONLY SUPPORT GOPLS

local function select(title, options, displayName)
  if #options == 0 then
    print('No code lenses available')
    return

  elseif #options == 1 then
    return options[1]
  end

  local options_strings = {title}
  for i, option in ipairs(options) do
    table.insert(options_strings, string.format('%d. %s', i, displayName(option)))
  end
  local choice = vim.fn.inputlist(options_strings)
  if choice < 1 or choice > #options then
    return
  end
  return options[choice]
end

local M = {}

function M.setup()

  vim.cmd('highlight default link LspCodeLens WarningMsg')
  vim.cmd('highlight default link LspCodeLensText WarningMsg')
  vim.cmd('highlight default link LspCodeLensTextSign LspCodeLensText')
  vim.cmd('highlight default link LspCodeLensTextSeparator Boolean')

  vim.cmd('augroup go.codelenses')
  vim.cmd('  autocmd!')
  vim.cmd('autocmd BufEnter,CursorHold,InsertLeave <buffer> lua require("go.codelens").refresh()')
  vim.cmd('augroup end')
end

function M.run_action()
  log("run code len action")
  local line = api.nvim_win_get_cursor(0)[1]
  local bufnr = api.nvim_get_current_buf()
  local options = {}

  local lenses = codelens.get(bufnr)
  for _, lens in pairs(lenses) do
    if lens.range.start.line == (line - 1) then
      table.insert(options, {lens = lens})
    end
  end

  log(options)
  local option = select('Code lenses:', options, function(option)
    return option.lens.command.title
  end)
  if option then
    log(option)
    vim.lsp.buf.execute_command(option.lens.command)
  end
end

function M.refresh()
  if _GO_NVIM_CFG.lsp_codelens == false then
    return
  end
  if not utils.check_capabilities("code_lens") then
    -- _GO_NVIM_CFG.lsp_codelens = false
    log("code lens not supported by your gopls")
    return
  end
  vim.lsp.codelens.refresh()
end

return M
