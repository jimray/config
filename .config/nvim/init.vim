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

" Separate lua << EOF block on purpose: an unhandled error partway through
" one heredoc aborts the rest of that SAME chunk (confirmed directly -- code
" placed after a failing `require` above never ran). This has no actual
" dependency on the no-neck-pain setup above succeeding, so it shouldn't be
" able to fail silently alongside it.
lua << EOF
-- Make vim-tmux-navigator skip over NoNeckPain's padding windows instead of
-- stopping in them.
--
-- NoNeckPain centers text by opening real vim window splits on the side(s)
-- of your buffer (filetype "no-neck-pain"). vim-tmux-navigator decides
-- whether to forward <C-h/j/k/l> to tmux by checking only whether `winnr()`
-- changed after a `wincmd` -- it has no concept of a window being empty
-- padding. So <C-l> at the edge of your content moves into NNP's padding
-- window (a real vim window, as far as navigator is concerned) and stops
-- there, instead of ever reaching vim's true edge and handing off to tmux.
--
-- Confirmed against the real plugin (christoomey/vim-tmux-navigator) in a
-- live tmux session: without this, <C-l> left the active tmux pane
-- unchanged (stuck in the fake padding window); with it, the active pane
-- correctly switched. A plain two-real-window move (no NNP involved) still
-- takes a single hop, unaffected.
--
-- Wrapped in VimEnter on purpose: vim8-style packages under
-- pack/*/start/*/plugin/ -- including vim-tmux-navigator's own default
-- <C-h/j/k/l> mappings -- load automatically AFTER this file finishes
-- being read, which would silently clobber a plain `vim.keymap.set` placed
-- here directly. Confirmed empirically: by the time VimEnter fires, the
-- plugin's own mapping is already active, and setting ours inside the
-- VimEnter callback is what makes ours win.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local function tmux_navigate(direction)
      local plug_direction = ({ h = "Left", j = "Down", k = "Up", l = "Right" })[direction]
      for _ = 1, 4 do
        local before = vim.fn.winnr()
        vim.cmd("TmuxNavigate" .. plug_direction)
        if vim.fn.winnr() == before then
          return -- forwarded to tmux, or genuinely nowhere left to go
        end
        if vim.bo.filetype ~= "no-neck-pain" then
          return -- landed on real content -- ordinary, successful navigation
        end
        -- else: moved, but into a padding window -- push through it
      end
    end

    for _, key in ipairs({ "h", "j", "k", "l" }) do
      vim.keymap.set("n", "<C-" .. key .. ">", function()
        tmux_navigate(key)
      end, { silent = true })
    end
  end,
})

-- Handle the return trip: coming back to vim FROM a plain tmux pane.
--
-- This is NOT a mirror-image of the fix above, and can't be fixed the same
-- way. Read from vim-tmux-navigator's own tmux-side script
-- (vim-tmux-navigator.tmux): when the CURRENT pane is a plain shell (not
-- vim), the tmux keybinding runs `select-pane` directly -- no keystroke is
-- ever sent into vim. There is no incoming <C-j> for a vim-side mapping to
-- intercept; tmux just changes which pane is active, and whatever window
-- vim's own cursor was last sitting in becomes visible again as-is.
--
-- That "last sitting in" window is exactly the problem: the fix above,
-- when it forwards out to tmux, does so with its *last* TmuxNavigate call
-- made from inside the padding window (that's the whole trick -- calling
-- it again from there is what lets the plugin's own edge-detection
-- correctly find the true edge). The plugin's forward-to-tmux path only
-- shells out to `tmux select-pane`; it never moves vim's own cursor back
-- to real content. So vim is left internally parked in the padding window
-- until something else changes its focus -- which nothing does, until you
-- come back.
--
-- FocusGained is the right hook (`focus-events on` in .tmux.conf makes
-- tmux relay real terminal focus in/out to whichever pane is active). If
-- we're back and sitting in a "no-neck-pain" window, hop onto the real
-- content next to it -- padding is always immediately adjacent to main on
-- one side or the other, never more than one window away.
--
-- Verified by injecting a raw xterm FocusIn escape sequence (ESC [ I)
-- directly into a real nvim instance: parked in a simulated padding
-- window, it correctly relocates to the real content; already-real content
-- is left untouched.
vim.api.nvim_create_autocmd("FocusGained", {
  callback = function()
    if vim.bo.filetype ~= "no-neck-pain" then
      return
    end
    for _, dir in ipairs({ "l", "h" }) do
      vim.cmd("wincmd " .. dir)
      if vim.bo.filetype ~= "no-neck-pain" then
        return
      end
    end
  end,
})
EOF
