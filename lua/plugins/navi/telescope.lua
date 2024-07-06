return {
	{
		"nvim-telescope/telescope.nvim",
		event = "VeryLazy",
		branch = "0.1.x",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons",            enabled = vim.g.have_nerd_font },
			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				"nvim-telescope/telescope-fzf-native.nvim",

				-- `build` is used to run some command when the plugin is installed/updated.
				-- This is only run then, not every time Neovim starts up.
				build = "make",

				-- `cond` is a condition used to determine whether this plugin should be
				-- installed and loaded.
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
		config = function()
			-- [[ Configure Telescope ]]
			-- See `:help telescope` and `:help telescope.setup()`
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
				defaults = {
					layout_config = {
						horizontal = {
							preview_cutoff = 0,
						},
					},
					mappings = {
						i = {
							["<C-u>"] = false,
							["<C-d>"] = false,
							["<C-p>"] = require("telescope.actions.layout").toggle_preview,
						},
					},
				},
			})
			local builtin = require("telescope.builtin")

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			-- Telescope live_grep in git root
			-- Function to find the git root directory based on the current buffer's path
			local function find_git_root()
				-- Use the current buffer's path as the starting point for the git search
				local current_file = vim.api.nvim_buf_get_name(0)
				local current_dir
				local cwd = vim.fn.getcwd()
				-- If the buffer is not associated with a file, return nil
				if current_file == "" then
					current_dir = cwd
				else
					-- Extract the directory from the current file's path
					current_dir = vim.fn.fnamemodify(current_file, ":h")
				end

				-- Find the Git root directory from the current file's path
				local git_root =
						vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
				if vim.v.shell_error ~= 0 then
					print("Not a git repository. Searching on current working directory")
					return cwd
				end
				return git_root
			end

			-- Custom live_grep function to search in git root
			local function live_grep_git_root()
				local git_root = find_git_root()
				if git_root then
					builtin.live_grep({
						search_dirs = { git_root },
					})
				end
			end

			vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})

			local function telescope_live_grep_open_files()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end

			local function telescope_buffers()
				builtin.buffers({
					sort_mru = true,
					ignore_current_buffer = true,
				})
			end

			-- See `:help telescope.builtin`

			-- Buffers and Files
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
			vim.keymap.set("n", "<leader>?", builtin.oldfiles, { desc = "[?] Find recently opened files" })
			vim.keymap.set("n", "<leader><space>", telescope_buffers, { desc = "[ ] Find existing buffers" })
			vim.keymap.set("n", "<leader>bb", telescope_buffers, { desc = "[B]uffers [b]rowse" })

			-- Grep
			vim.keymap.set("n", "<leader>f/", telescope_live_grep_open_files, { desc = "[F]ind [/] in Open Files" })
			vim.keymap.set("n", "<leader>/", function()
				-- You can pass additional configuration to telescope to change theme, layout, etc.
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })
			vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })

			-- Git
			vim.keymap.set("n", "<leader>fhf", builtin.git_files, { desc = "Find git files" })
			vim.keymap.set("n", "<leader>fhc", builtin.git_commits, { desc = "Find git commits" })
			vim.keymap.set("n", "<leader>fhr", ":LiveGrepGitRoot<cr>", { desc = "[F]ind by [G]rep on Git Root" })

			-- Lsp
			vim.keymap.set("n", "<leader>gr", builtin.lsp_references, { desc = "Go References" })
			vim.keymap.set("n", "<leader>gd", builtin.lsp_definitions, { desc = "Go Definitions" })
			vim.keymap.set("n", "<leader>gD", builtin.lsp_type_definitions, { desc = "Go Type Definitions" })
			vim.keymap.set("n", "<leader>gi", builtin.lsp_implementations, { desc = "Go Implementations" })
			vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find Document Symbols" })
			vim.keymap.set("n", "<leader>fS", builtin.lsp_dynamic_workspace_symbols, { desc = "Workspace [S]ymbols" })

			vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })
			vim.keymap.set("n", "<leader>fq", builtin.quickfix, { desc = "[F]ind quickfix" })
			vim.keymap.set("n", "<leader>ft", builtin.treesitter, { desc = "Find treesitter" })

			vim.keymap.set("n", "<leader>fln", builtin.lsp_incoming_calls, { desc = "Find Incoming" })
			vim.keymap.set("n", "<leader>flo", builtin.lsp_outgoing_calls, { desc = "Find Outgoing" })

			-- Marks
			vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "Find marks" })

			-- Misc
			vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
			vim.keymap.set("n", "<leader>fx", builtin.builtin, { desc = "[F]ind Select Telescope" })
			vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
			vim.keymap.set("n", "<leader>fH", builtin.help_tags, { desc = "[F]ind [H]elp" })
			vim.keymap.set("n", "<leader>fc", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[F]ind [C]onfig" })
			vim.keymap.set("n", "<leader>fp", function()
				builtin.planets({ show_pluto = true, show_moon = true })
			end, { desc = "[F]ind [P]lanets" })
		end,
	},
}
