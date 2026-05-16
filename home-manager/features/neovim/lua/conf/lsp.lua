local _, nixCats_extra = pcall(function() return require('nixCats').extra end)
local function setup_lsp_rust()
end

local function setup_lsp_terraform()
  local cmd

  if vim.fn.executable('terraform-ls') == 1 then
    cmd = 'terraform-ls'
  elseif vim.fn.getenv('HOME') ~= vim.NIL then
    cmd = vim.fn.expand('$HOME/.nix-profile/bin/terraform-ls')
  end

  vim.lsp.config('terraform-ls', {
    cmd = { cmd, "serve" },
    filetypes = { "terraform", "tf", "terraform-vars", "tfvars" },
    root_markers = {
      '.terraform',
      '.git',
      '*.tf',
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
  if vim.fn.executable('gopls') then
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

local function setup_lsp_lua()
  require 'lazydev'.setup {}
  vim.lsp.enable('lua_ls')
end

local function setup_lsp_nix()
  vim.lsp.config('nixd', {
    nixpkgs = {
      expr = nixCats_extra('nixdExtras.nixpkgs'),
    },
    options = {
      nixos = {
        -- nixdExtras.nixos_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").nixosConfigurations.configname.options''
        expr = nixCats_extra("nixdExtras.nixos_options")
      },
      ["home-manager"] = {
        -- nixdExtras.home_manager_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").homeConfigurations.configname.options''
        expr = nixCats_extra("nixdExtras.home_manager_options")
      }
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
  
  vim.lsp.enable('ts_ls')
end

return {
  setup = setup_lsp,
}
