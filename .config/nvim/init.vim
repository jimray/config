set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
source ~/.vimrc

" Setup No Neck Pain plugin
" Auto center prose text, max-width 96
" when combined with the pencil plugin, keeps .md
" and .txt files legible
" at wide terminal windows
" Use ,z to center any other text
lua << EOF
require("no-neck-pain").setup({
  width = 96,
})

local prose_filetypes = {
  markdown = true,
  text = true,
}

local function sync_nnp()
  local buftype = vim.bo.buftype
  local ft = vim.bo.filetype

  if ft == "no-neck-pain" or buftype ~= "" then
    return
  end

  local nnp = require("no-neck-pain")
  local is_enabled = nnp.state ~= nil and nnp.state.enabled
  local want_enabled = vim.b.nnp_manual or (prose_filetypes[ft] or false)

  if want_enabled and not is_enabled then
    nnp.enable("buffer_auto")
  elseif not want_enabled and is_enabled then
    nnp.disable()
  end
end

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    vim.schedule(sync_nnp)
  end,
})

vim.keymap.set("n", "<leader>z", function()
  vim.b.nnp_manual = not vim.b.nnp_manual
  sync_nnp()
end, { desc = "Toggle NoNeckPain manually for this buffer" })
EOF
