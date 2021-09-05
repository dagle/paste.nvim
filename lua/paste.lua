local curl = require("plenary.curl")
local path = require("plenary.path")

local function get_reg(char)
	return vim.api.nvim_exec([[echo getreg(']]..char..[[')]], true)
end

local M = {}

local default_config = {
	host = "https://paste.rs",
	callback = function (response)
		print("Pasted at: " .. response.body)
	end,
}

local user_config = default_config

function M.Setup(config)
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

-- function pastesel()
-- end

function M.pasteyank()
	local text = get_reg('0')
	curl.post(user_config.host, {
		body = text,
		callback = user_config.callback,
	})
end

-- maybe have a callback function to this?
function M.getPaste(url)
	-- Get the raw data
	-- (check if paste is <id>.<ext>)
	local ret = curl.get(url, {})
	-- check the return value
	-- maybe true/true?
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, ret)
	-- fill the buffer with the new data
	-- add the buffer
end

return M
