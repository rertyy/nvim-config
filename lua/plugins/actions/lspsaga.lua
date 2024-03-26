return {
	"nvimdev/lspsaga.nvim",
	event = "LspAttach",
	config = function()
		require("lspsaga").setup({
			symbol_in_winbar = {
				enabled = false,
				show_file = false,
			},
			implement = {
				enable = false,
			},
			-- breadcrumb = {
			-- 	enable = false,
			-- },
			lightbulb = { enable = false },
			outline = {
				enable = false,
				-- keys = {
				-- 	toggle_or_jump = "<CR>",
				-- },
			},
			rename = {
				keys = {
					quit = "<esc>",
				},
			},
		})

		local map = function(keymap, cmd, desc)
			vim.keymap.set("n", "<leader>" .. keymap, "<cmd>Lspsaga " .. cmd .. "<CR>", { silent = true, desc = desc })
		end

		map("li", "incoming_calls<CR>", "Peek Incoming Calls")
		map("lo", "outgoing_calls<CR>", "Peek Outgoing Calls")
		map("la", "code_action<CR>", "Code action")
		map("ld", "peek_definition<CR>", "Peek Definition")
		map("lt", "peek_type_definition<CR>", "Peek Type Definition")
		map("lf", "finder ref+def+imp<CR>", "Finder")
		map("ln", "diagnostic_jump_next<CR>", "Next diagnostic")
		map("lb", "diagnostic_jump_prev<CR>", "Prev diagnostic")
		map("lh", "hover<CR>", "Hover")
		map("lO", "outline<CR>", "outline")
		map("lr", "rename<CR>", "Rename")

		vim.keymap.set({ "n", "t" }, "<A-d>", "<cmd>Lspsaga term_toggle")
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
}
