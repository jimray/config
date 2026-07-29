set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
source ~/.vimrc

" center markdown text, max-width 80
" when combined with the pencil plugin, keeps .md files legible
" at wide terminal windows
lua << EOF
require("no-neck-pain").setup({
  width = 96,
})

local prose_filetypes = {
  markdown = true,
  text = true,
}

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    vim.schedule(function()
      local buftype = vim.bo.buftype
      local ft = vim.bo.filetype

      if ft == "no-neck-pain" or buftype ~= "" then
        return
      end

      local nnp = require("no-neck-pain")
      local is_enabled = nnp.state ~= nil and nnp.state.enabled
      local is_prose = prose_filetypes[ft] or false

      if is_prose and not is_enabled then
        nnp.enable("prose_auto")
      elseif not is_prose and is_enabled then
        nnp.disable()
      end
    end)
  end,
})
EOF
