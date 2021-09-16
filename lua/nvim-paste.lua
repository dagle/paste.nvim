local curl = require("plenary.curl")
local path = require("plenary.path")

local floating_win = require'popfix.floating_win'

local M = {}

local function get_reg(char)
	return vim.api.nvim_exec([[echo getreg(']]..char..[[')]], true)
end

local function get_visual_selection()
	local visual_modes = {
		v = true,
		V = true,
	}
	if visual_modes[vim.api.nvim_get_mode().mode] == nil then return end

	local bufnr = 0

	local pos1 = vim.fn.getpos("'<")
	local pos2 = vim.fn.getpos("'>")

	local start = { pos1[2] - 1, pos1[3] - 1 + pos1[4] }
	local finish = { pos2[2] - 1, pos2[3] - 1 + pos2[4] }

	if start[2] < 0 or finish[1] < start[1] then return end

	local region =
		vim.region(
			bufnr,
			start,
			finish,
			vim.fn.visualmode(),
			(vim.o.selection ~= 'exclusive')
		)
	local lines =
		vim.api.nvim_buf_get_lines(bufnr, start[1], finish[1] + 1, false)
	lines[1] = lines[1]:sub(region[start[1]][1] + 1, region[start[1]][2])
	if start[1] ~= finish[1] then
		lines[#lines] =
			lines[#lines]:sub(region[finish[1]][1] + 1, region[finish[1]][2])
	end
	return table.concat(lines, '\n')
end

local default_config = {
	host = "https://paste.rs",
	callback = function (response)
		print("Pasted at: " .. response.body)
	end,
}

local user_config = default_config

function M.setup(config)
	user_config = vim.tbl_extend("keep", config or {}, default_config)
end

function M.paste(fname)
	fname = fname or vim.fn.expand("%")
	local fid = path:new(fname)
	if not fid:is_file() then
		print("File doesn't exist: " .. fname)
		return
	end
	local f = io.open(fname, "r")
	local buf = f:read("*all")
	curl.post(user_config.host, {
		body = buf,
		callback = user_config.callback,
	})
end

function M.pastebuf()
	local text_tbl = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local text = table.concat(text_tbl, '\n')
	curl.post(user_config.host, {
		body = text,
		callback = user_config.callback,
	})
end

function M.pastesel()
	local text = get_visual_selection()
	curl.post(user_config.host, {
		body = text,
		callback = user_config.callback,
	})
end

function M.pasteyank()
	local text = get_reg('0')
	curl.post(user_config.host, {
		body = text,
		callback = user_config.callback,
	})
end


function M.getPaste(url)
	local api = vim.api
	-- make this async etc
	-- use pure curl instead of the wrapper?
	local ret = curl.get(url, {})

	local editorWidth = api.nvim_get_option('columns')
	local editorHeight = api.nvim_get_option("lines")
	local opts = {
		height = math.ceil(editorHeight * 0.8 - 4),
		width = math.ceil(editorWidth * 0.8),
		border = true,
		title = 'Paste',
	}
	opts.row = math.ceil((editorHeight - opts.height) /2 - 1)
	opts.col = math.ceil((editorWidth - opts.width) /2)
	local win_buf = floating_win.create_win(opts)
	vim.api.nvim_buf_set_lines(win_buf.buf, 0, -1, false, vim.split(ret.body, '\n'))
	api.nvim_buf_set_keymap(win_buf.buf, 'n', 'q', '<cmd>lua vim.api.nvim_win_close(' .. win_buf.win ..', true)<CR>', {noremap=true, silent=true})
	api.nvim_buf_set_option(win_buf.buf, 'bufhidden', 'wipe')
	api.nvim_win_set_option(win_buf.win, 'winhl', 'Normal:Normal')
	api.nvim_win_set_option(win_buf.win, 'number', true)
	api.nvim_set_current_win(win_buf.win)
	return win_buf
end

return M
