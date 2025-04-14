-- init.lua (minimal, no LSP, no telescope, no treesitter)

----------------------------------
-- 1. Install packer
----------------------------------
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
  vim.cmd [[packadd packer.nvim]]
end

----------------------------------
-- 2. Configure packer plugins
----------------------------------
require('packer').startup(function(use)
  -- Package manager
  use 'wbthomason/packer.nvim'

  -- Quick editing enhancements
  use "windwp/nvim-autopairs"       -- Auto-close brackets
  use 'numToStr/Comment.nvim'       -- Easy commenting
  use 'tpope/vim-sleuth'            -- Auto-detect indent settings
  use 'tpope/vim-rsi'               -- Readline-style bindings in insert mode

  -- Theming
  use 'navarasu/onedark.nvim'       -- OneDark color scheme
  use 'nvim-lualine/lualine.nvim'   -- Fancy statusline
  use 'lukas-reineke/indent-blankline.nvim' -- Optional indentation guides

  -- Clipboard over SSH
  use { 'ojroques/nvim-osc52' }

  -- If you have custom plugins
  local has_plugins, plugins = pcall(require, 'custom.plugins')
  if has_plugins then
    plugins(use)
  end

  if is_bootstrap then
    require('packer').sync()
  end
end)

-- If in bootstrap mode, stop after plugin install
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end

-- Automatically re-compile whenever you edit init.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | PackerCompile',
  group = packer_group,
  pattern = vim.fn.expand '$MYVIMRC',
})

----------------------------------
-- 3. Basic Options
----------------------------------
-- Built-in syntax highlighting
vim.cmd("syntax on")

-- Turn off search highlight by default
vim.o.hlsearch = false

-- Show line numbers
vim.wo.number = true

-- Enable mouse
vim.o.mouse = 'a'

-- Break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching unless capital used
vim.o.ignorecase = true
vim.o.smartcase = true

-- Faster updates
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

-- Tabs/indent
vim.bo.shiftwidth = 4
vim.o.tabstop = 4

-- Colors
vim.o.termguicolors = true
vim.cmd [[colorscheme onedark]]

-- Better completion menu behavior (for basic completions)
vim.o.completeopt = 'menuone,noselect'

-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Keymaps for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

----------------------------------
-- 4. Plugins Setup
----------------------------------
-- nvim-autopairs
require("nvim-autopairs").setup {}

-- Comment.nvim
require('Comment').setup()

-- Indent guides (optional)
require('ibl').setup()
g
-- nvim-osc52 (Clipboard)
require('osc52').setup {
  max_length = 0,
  silent = false,
  trim = false,
}

local function copy(lines, _)
  require('osc52').copy(table.concat(lines, '\n'))
end

local function paste()
  return {vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('')}
end

vim.g.clipboard = {
  name = 'osc52',
  copy = {['+'] = copy, ['*'] = copy},
  paste = {['+'] = paste, ['*'] = paste},
}

-- Yank to clipboard automatically
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    require('osc52').copy_register(vim.v.event.regname)
  end,
})

-- Lualine
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'onedark',
    component_separators = '|',
    section_separators = '',
  },
}

----------------------------------
-- 5. Misc. Keymaps
----------------------------------
-- Example: yank to system clipboard
vim.keymap.set('n', '<leader>c', '"+y', { desc = 'Copy to system clipboard' })
vim.keymap.set('n', '<leader>cc', '"+yy', { desc = 'Yank line -> system clipboard' })

-- Example: highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
  group = highlight_group,
  pattern = '*',
})

----------------------------------
-- END
----------------------------------
-- vim: ts=2 sts=2 sw=2 et
