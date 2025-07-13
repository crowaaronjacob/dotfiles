return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/nvim-cmp",
  },
  config = function()
    local lspconfig = require("lspconfig")
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")

    mason.setup()
    mason_lspconfig.setup({
      ensure_installed = { 
        "ts_ls", 
        "eslint", 
        "pyright", 
        "tailwindcss", 
        "html", 
        "cssls", 
        "jsonls",
        "emmet_ls"
      },
      handlers = {
        function(server)
          local capabilities = require("cmp_nvim_lsp").default_capabilities()
          lspconfig[server].setup({
            capabilities = capabilities,
          })
        end,
        ["ts_ls"] = function()
          local capabilities = require("cmp_nvim_lsp").default_capabilities()
          lspconfig.ts_ls.setup({
            capabilities = capabilities,
          settings = {
            typescript = {
              preferences = {
                importModuleSpecifier = "relative"
              }
            }
          }
        })
      end,
        ["tailwindcss"] = function()
          local capabilities = require("cmp_nvim_lsp").default_capabilities()
          lspconfig.tailwindcss.setup({
            capabilities = capabilities,
          filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" }
        })
      end,
        ["emmet_ls"] = function()
          local capabilities = require("cmp_nvim_lsp").default_capabilities()
          lspconfig.emmet_ls.setup({
            capabilities = capabilities,
          filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" }
        })
        end
      }
    })

    -- Show diagnostics on cursor hold
    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = bufnr,
      callback = function()
        local opts = {
          focusable = false,
          close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          border = 'rounded',
          source = 'always',
          prefix = ' ',
          scope = 'cursor',
        }
        vim.diagnostic.open_float(nil, opts)
      end
    })

    -- Configure diagnostic display
    vim.diagnostic.config({
      virtual_text = false,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- Reduce updatetime for faster hover
    vim.opt.updatetime = 250
  end,
}

