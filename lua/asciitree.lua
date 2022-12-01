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

local function sanitize(char)
	return string.gsub(char, "([\\-\\*\\+\\.\\?])", "\\%1")
end

--- Generates the tree and removes empty and unrelated content.
-- @param lines List of lines to generate the tree from
function M.parse(lines, delim)
	local list = {}
	local single_parent
	local i = 1
	local len = #lines

	::start::
	while i <= len do
		local delimiter =
			lines[i]:match("^[\t%s]*[" .. sanitize(delim) .. "]+")

		-- Remove empty lines or lines without delimiters and continue.
		if not delimiter then
			table.remove(lines, i)
			len = len - 1
			goto start
		end

		local item
		local name = lines[i]:sub(#delimiter + 1):gsub("^%s*(.-)%s*$", "%1")
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

	return list, single_parent
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

	local list, is_single = M.parse(lines, opts.delimiter)

	if #list == 0 then return end

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

		return table.concat(branch, "") .. item.name
	end, list)
end

--- Generate the tree.
-- @param depth Width of each branch segment
function M.generate(depth, delimiter)
	local line_start = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
	local line_end = vim.api.nvim_buf_get_mark(0, ">")[1]

	-- Do not run if the selection is empty or there is no previous selection.
	if line_start == -1 or line_end == 0 then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, line_start, line_end, false)
	local result = M.format_branches(lines, {
		depth = depth,
		delimiter = delimiter,
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
