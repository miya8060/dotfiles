vim.api.nvim_create_autocmd("FileType", {
	pattern = "deol",
	callback = function()
		local opts = { buffer = true, noremap = true, silent = true }
		local keymap = vim.keymap.set
		keymap('n', '<C-n>', '<Plug>(deol_next_prompt)', opts)
		keymap('n', '<C-p>', '<Plug>(deol_previous_prompt)', opts)
		keymap('n', '<CR>', '<Plug>(deol_execute_line)', opts)
		keymap('n', 'A', '<Plug>(deol_start_append_last)', opts)
		keymap('n', 'I', '<Plug>(deol_start_insert_first)', opts)
		keymap('n', 'a', '<Plug>(deol_start_append)', opts)
		keymap('n', 'e', '<Plug>(deol_edit)', opts)
		keymap('n', 'i', '<Plug>(deol_start_insert)', opts)
		keymap('n', 'q', '<Plug>(deol_quit)', opts)
		keymap('t', 'jj', [[<C-\><C-n>]], opts)
	end
})

vim.g['deol#floating_border'] = "rounded"
