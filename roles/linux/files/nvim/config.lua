vim.lsp.config('pylsp', {
  cmd = { 'pylsp' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', '.git' },
})
vim.lsp.enable('pylsp')

-- LSP replaces ALE where attached
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function()
    pcall(vim.cmd, 'ALEDisableBuffer')
  end,
})
