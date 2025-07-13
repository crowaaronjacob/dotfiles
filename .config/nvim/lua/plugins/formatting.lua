return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.diagnostics.eslint,
				null_ls.builtins.code_actions.eslint,
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.isort,
				null_ls.builtins.diagnostics.flake8,
			},
		})
		-- Format on save for JS/TS and Python
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.py" },
			callback = function()
				vim.lsp.buf.format({
					filter = function(client)
						-- Only use null-ls or ESLint LSP, whichever you prefer
						return client.name == "null-ls" or client.name == "eslint"
					end,
					timeout_ms = 2000,
				})
			end,
		})
	end,
}
