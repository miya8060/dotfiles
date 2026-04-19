if vim.loader then
	vim.loader.enable()
end

local dpp_src = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp.vim"

vim.opt.runtimepath:prepend(dpp_src)
local dpp = require("dpp")

local dppBase = "~/.cache/dpp/"
local dpp_config = "~/.config/nvim/dpp.ts"

local denops_src = "$HOME/.cache/dpp/repos/github.com/vim-denops/denops.vim"

local ext_toml = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp-ext-toml"
local ext_lazy = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp-ext-lazy"
local ext_installer = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp-ext-installer"
local ext_git = "$HOME/.cache/dpp/repos/github.com/Shougo/dpp-protocol-git"

vim.opt.runtimepath:append(ext_toml)
vim.opt.runtimepath:append(ext_git)
vim.opt.runtimepath:append(ext_lazy)
vim.opt.runtimepath:append(ext_installer)

if dpp.load_state(dppBase) then
	vim.opt.runtimepath:prepend(denops_src)

	vim.api.nvim_create_autocmd("User", {
		pattern = "DenopsReady",
		callback = function()
			vim.notify("vim load_state is failed")
			dpp.make_state(dppBase, dpp_config)
		end
	})
end

-- dpp_alias
vim.api.nvim_create_user_command("DppInstall", "call dpp#async_ext_action('installer', 'install')", { nargs = 0 })
vim.api.nvim_create_user_command("DppUpdate", "call dpp#async_ext_action('installer', 'update')", { nargs = 0 })
vim.api.nvim_create_user_command("DppMakestate", function(val)
	dpp.make_state(dppBase, dpp_config)
end, { nargs = 0 })

-- autocmd
vim.api.nvim_create_autocmd({ "BufRead", "CursorHold", "InsertEnter" }, {
	callback = function()
		vim.opt.clipboard = "unnamedplus"
		require("config/keymaps")
		require("config/options")
		require("config/autocmd")
	end,
})
