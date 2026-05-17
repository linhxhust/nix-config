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
    local client = ctx and ctx.client_id and vim.lsp.get_client_by_id(ctx.client_id)
    local client_name = client and client.name or 'terraform-ls'

    vim.schedule(function()
      vim.notify(
        ('[%s] Definition not found. Run `terraform init` in project root and retry.'):format(client_name),
        vim.log.levels.INFO
      )
    end)

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
    filetypes = { 'terraform', 'terraform-vars' },
    root_dir = function(bufnr, on_dir)
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local root = vim.fs.root(bufname, { '.terraform', '.terraform.lock.hcl' })
        or vim.fs.root(bufname, { '.git' })

      on_dir(root or vim.fs.dirname(bufname))
    end,
    handlers = {
      ['textDocument/definition'] = terraform_definition_handler,
    },
    init_options = {
      terraform = {
        logFilePath = '/dev/null',
      },
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
        expr = nixCats_extra('nixdExtras.nixos_options'),
      },
      ['home-manager'] = {
        expr = nixCats_extra('nixdExtras.home_manager_options'),
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

  vim.lsp.enable('ts_ls')
end

return {
  setup = setup_lsp,
}
