return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "javascript", "typescript", "lua", "json", "html", "css", "scss", 
        "python", "markdown", "yaml", "toml", "bash", "dockerfile", "gitignore"
      },
      highlight = { enable = true },
    })
  end,
}

