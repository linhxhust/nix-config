local _, nixCats_extra = pcall(function() return require('nixCats').extra end)

local function setup_lsp_rust()
end

local function resolve_bin(bin)
  if vim.fn.executable(bin) == 1 then
    return bin
  end

  if vim.fn.getenv('HOME') ~= vim.NIL then
    local nix_profile_bin = vim.fn.expand(('$HOME/.nix-profile/bin/%s'):format(bin))
    if vim.fn.executable(nix_profile_bin) == 1 then
      return nix_profile_bin
    end
  end

  return nil
end

local function terraform_definition_handler(err, result, ctx, config)
  if err and err.code == -32098 and err.message == 'no reference origin found' then
    return
  end

  return vim.lsp.handlers.definition(err, result, ctx, config)
end

local function setup_lsp_terraform()
  local cmd = resolve_bin('terraform-ls')
  if not cmd then
    return
  end

  vim.lsp.config('terraform-ls', {
    cmd = { cmd, 'serve' },
    filetypes = { 'terraform', 'tf' },
    root_markers = {
      '.terraform.lock.hcl',
      '.terraform',
      'versions.tf',
      'providers.tf',
      'main.tf',
    },
    handlers = {
      ['textDocument/definition'] = terraform_definition_handler,
    },
    settings = {
      terraform = {
        experimentalFeatures = {
          prefillRequiredFields = true,
          validateOnSave = true,
        },
      },
    },
  })

  vim.lsp.enable('terraform-ls')
end

local function setup_lsp_go()
  local cmd
  if vim.fn.executable('gopls') == 1 then
    cmd = 'gopls'
  elseif vim.fn.getenv('GOPATH') ~= vim.NIL then
    cmd = vim.fn.expand('$GOPATH/bin/gopls')
  else
    cmd = vim.fn.expand('$HOME/go/bin/gopls')
  end

  vim.lsp.config('gopls', {
    inlay_hints = { enable = true },
    cmd = { cmd },
  })
  vim.lsp.enable('gopls')
end

local function setup_lsp_python()
  local cmd = resolve_bin('pyright-langserver')
  if not cmd then
    return
  end

  vim.lsp.config('pyright', {
    cmd = { cmd, '--stdio' },
    filetypes = { 'python' },
    root_markers = {
      'pyproject.toml',
      'setup.py',
      'setup.cfg',
      'requirements.txt',
      'Pipfile',
      'pyrightconfig.json',
      '.git',
    },
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = 'workspace',
          useLibraryCodeForTypes = true,
        },
      },
    },
  })

  vim.lsp.enable('pyright')
end

local function setup_lsp_lua()
  require 'lazydev'.setup {}
  vim.lsp.enable('lua_ls')
end

local function setup_lsp_nix()
  vim.lsp.config('nixd', {
    settings = {
      nixd = {
        nixpkgs = {
          expr = nixCats_extra('nixdExtras.nixpkgs'),
        },
        formatting = {
          command = { 'nixfmt' },
        },
        options = {
          nixos = {
            expr = nixCats_extra('nixdExtras.nixos_options'),
          },
          ['home-manager'] = {
            expr = nixCats_extra('nixdExtras.home_manager_options'),
          },
        },
      },
    },
  })
  vim.lsp.enable('nixd')
end

local function setup_lsp()
  setup_lsp_rust()
  setup_lsp_go()
  setup_lsp_lua()
  setup_lsp_nix()
  setup_lsp_terraform()
  setup_lsp_python()

  vim.lsp.enable('ts_ls')
end

return {
  setup = setup_lsp,
}
