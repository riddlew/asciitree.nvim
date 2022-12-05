local M = {
	settings = {
		symbols = {
			child = "├",
			last = "└",
			parent = "│",
			dash = "─",
			blank = " ",
		},
		depth = 2,
		delimiter = "#",
	},
}

M.symbols = {}

local function tbl_copy(tbl)
	local n = {}
	for k, v in pairs(tbl) do
		n[k] = v
	end
	return n
end

local function sanitize(char)
	return string.gsub(char, "([\\-\\*\\+\\.\\?])", "\\%1")
end

--- Generates the tree and removes empty and unrelated content.
-- @param lines List of lines to generate the tree from
local function parse(lines, delim)
	local new_lines = tbl_copy(lines)
	local list = {}
	local single_parent
	local i = 1
	local len = #new_lines
	local indentation

	::start::
	if #new_lines == 0 then
		return {}
	end

	while i <= len do
		local delimiter = new_lines[i]:match("[" .. sanitize(delim) .. "]+")

		-- Remove empty lines or lines without delimiters and continue.
		if not delimiter then
			table.remove(new_lines, i)
			len = len - 1
			goto start
		end

		-- Get the indentation
		indentation = new_lines[i]:gsub("^([\t%s]*).-$", "%1")

		local item
		local name = new_lines[i]
			:sub(#delimiter + #indentation + 1)
			:gsub("^%s*(.-)%s*$", "%1")
		local depth = #delimiter
		local prev = list[i - 1]

		if prev then
			if depth > prev.depth then
				item = {
					name = name,
					is_last = false,
					depth = prev.depth + 1,
					parent = prev,
				}
			elseif depth == prev.depth then
				if depth == 1 then
					single_parent = false
				end

				item = {
					name = name,
					is_last = false,
					depth = prev.depth,
					parent = prev.parent,
				}
			else
				prev.is_last = true
				local sibling_index = i - 1
				local sibling = list[sibling_index]
				local last_map = {}

				-- This is not the first top level dir and is not a single parent.
				if depth == 1 then
					single_parent = false
				end

				while sibling_index >= 1 and sibling.depth ~= depth do
					if
						sibling.depth > depth and not last_map[sibling.depth]
					then
						sibling.is_last = true
						last_map[sibling.depth] = true
					end
					sibling_index = sibling_index - 1
					sibling = list[sibling_index]
				end

				item = {
					name = name,
					is_last = false,
					depth = sibling.depth,
					parent = sibling.parent,
				}
			end
		else
			single_parent = true
			item = {
				name = name,
				is_last = false,
				depth = 1,
			}
		end

		item.depth = depth
		table.insert(list, item)

		i = i + 1
	end

	local last = list[#list]
	while last do
		last.is_last = true
		last = last.parent
	end

	return list, single_parent, indentation
end

--- Convert an ASCII tree back to plain lines with delimiters.
-- @param lines Table of lines of the ASCII tree to be converted.
-- @param opts Table of params (depth and delimiter) to use to parse the tree.
local function parse_tree(lines, opts)
	local new_lines = tbl_copy(lines)
	local list = {}
	local i = 1

	-- Replacing strings instead of using regex because Lua doesn't handle
	-- unicode very well. I'm sure it's possible, but I spent too much time
	-- trying to make it work, so for now I'm using this.
	local convert = {
		-- │
		M.settings.symbols.parent
			.. string.rep(M.settings.symbols.blank, opts.depth - 1)
			.. " ",
		-- └─ (no space)
		M.settings.symbols.last
			.. string.rep(M.settings.symbols.dash, opts.depth - 1),
		-- ├─ (no space)
		M.settings.symbols.child
			.. string.rep(M.settings.symbols.dash, opts.depth - 1),
		-- n blanks and a space
		string.rep(M.settings.symbols.blank, opts.depth) .. " ",
	}

	-- Remove all empty lines
	local len = #new_lines
	while i <= len do
		local empty_line = new_lines[i]:match("^[\t%s]*$")

		if empty_line ~= nil then
			table.remove(new_lines, i)
			len = len - 1
		else
			i = i + 1
		end
	end

	-- Check the first line to see if it has unicode. If it does, it's not a
	-- single root tree.
	local single_parent = false
	local _, unicode_cnt =
		new_lines[1]:gsub("[%z\1-\127\194-\244][\128-\191]", "")
	if unicode_cnt == 0 then
		single_parent = true
	end

	-- Get the indentation of the first line
	local indentation = new_lines[1]:gsub("^([\t%s]*).-$", "%1")

	len = #new_lines
	i = 1
	while i <= len do
		-- Remove indentation first
		new_lines[i] = new_lines[i]:sub(#indentation + 1)

		local item = { depth = single_parent and 1 or 0 }

		-- Iterate over the pairs of symbols, increase depth amount for the
		-- item, and replace unicode with the delimiter.
		for _, entry in pairs(convert) do
			local cnt
			new_lines[i], cnt = new_lines[i]:gsub(entry, opts.delimiter)
			item.depth = item.depth + cnt
		end

		-- Now that unicode is replaced with the delimiter, it's a lot easier
		-- to use regex to find the name than with unicode.
		item.name = new_lines[i]:match(
			"[" .. sanitize(opts.delimiter) .. "]*%s*(.-)%s*$"
		)
		table.insert(list, item)

		i = i + 1
	end

	return list, indentation
end

--- Creates the tree branch segment with the correct symbols and padding.
-- @param start Character used for the start of the branch
-- @param fill  Character used for padding
-- @param size  Fill length
local function format_segment(start, fill, size)
	local result = ""
	for i = 1, size do
		if i == 1 then
			result = result .. start
		else
			result = result .. fill
		end
	end
	return result .. " "
end

function M.format_branches(lines, opts)
	opts = opts or {}
	opts.depth = opts.depth or M.settings.depth
	opts.delimiter = opts.delimiter or M.settings.delimiter

	local list, is_single, indentation = parse(lines, opts.delimiter)

	if #list == 0 then
		return lines
	end

	-- Format each branch with the correct tree characters.
	return vim.tbl_map(function(item)
		local branch = {}
		local parent = item.parent
		local line

		if item.depth ~= 1 or not is_single then
			local char
			if item.is_last then
				char = M.settings.symbols.last
			else
				char = M.settings.symbols.child
			end
			line = format_segment(char, M.settings.symbols.dash, opts.depth)
		end

		table.insert(branch, line)

		while parent and (parent.depth ~= 1 or not is_single) do
			line = format_segment(
				parent.is_last and M.settings.symbols.blank
					or M.settings.symbols.parent,
				M.settings.symbols.blank,
				opts.depth
			)
			table.insert(branch, 1, line)
			parent = parent.parent
		end

		return indentation .. table.concat(branch, "") .. item.name
	end, list)
end

function M.format_delimiter(lines, opts)
	opts = opts or {}
	opts.depth = opts.depth or M.settings.depth
	opts.delimiter = opts.delimiter or M.settings.delimiter

	local list, indentation = parse_tree(lines, opts)

	if #list == 0 then
		return lines
	end

	return vim.tbl_map(function(item)
		local line = string.format(
			"%s%s %s",
			indentation,
			string.rep(opts.delimiter, item.depth),
			item.name
		)

		return line
	end, list)
end

function M.get_args(...)
	local args = { ... }
	local depth = M.settings.depth
	local delimiter = M.settings.delimiter

	if #args == 1 then
		local num = tonumber(args[1])
		if num ~= nil then
			depth = num
		else
			delimiter = args[1]
		end
	elseif #args == 2 then
		local largs = { tonumber(args[1]), tonumber(args[2]) }
		if largs[1] ~= nil then
			depth = largs[1]
			delimiter = args[2]
		else
			delimiter = args[1]
			depth = largs[2]
		end
	end

	return {
		depth = depth,
		delimiter = delimiter,
	}
end

local function get_selected_lines()
	local line_start = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
	local line_end = vim.api.nvim_buf_get_mark(0, ">")[1]

	-- Do not run if the selection is empty or there is no previous selection.
	if line_start == -1 or line_end == 0 then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, line_start, line_end, false)
	return lines, line_start, line_end
end

--- Generate the tree.
-- @param depth Width of each branch segment
function M.generate(...)
	local args = M.get_args(...)
	local lines, line_start, line_end = get_selected_lines()

	local result = M.format_branches(lines, {
		depth = args.depth,
		delimiter = args.delimiter,
	})

	vim.api.nvim_buf_set_lines(0, line_start, line_end, false, result)
end

function M.undo(...)
	local args = M.get_args(...)
	local lines, line_start, line_end = get_selected_lines()

	local result = M.format_delimiter(lines, {
		depth = args.depth,
		delimiter = args.delimiter,
	})

	vim.api.nvim_buf_set_lines(0, line_start, line_end, false, result)
end

--- Setup custom options.
-- Accepted options (defaults shown):
-- {
--     symbols = {
--         child = "├",
--         last = "└",
--         parent = "│",
--         dash = "─",
--         blank = " ",
--     },
--     depth = 2,
--     delimiter = "#",
-- }
function M.setup(opts)
	opts = opts or {}
	M.settings = vim.tbl_deep_extend("force", M.settings, opts)
end

return M
