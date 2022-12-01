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

function M.parse(lines)
	local list = {}
	local i = 1
	local len = #lines

	::start::
	while i <= len do
		local delimiter =
			lines[i]:match("^[\t%s]*" .. M.settings.delimiter .. "+")

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

	return list
end

local function format_line(start, fill, size)
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

function M.generate(depth)
	depth = depth or M.settings.depth
	local line_start = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
	local line_end = vim.api.nvim_buf_get_mark(0, ">")[1]

	if line_start == -1 or line_end == 0 then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, line_start, line_end, false)
	local list = M.parse(lines)

	if #list == 0 then return end

	local result = vim.tbl_map(function(item)
		local texts = {}
		local parent = item.parent
		local line = format_line(
			item.is_last and M.settings.symbols.last or M.settings.symbols.child,
			M.settings.symbols.dash,
			depth
		)
		table.insert(texts, line)

		while parent do
			line = format_line(
				parent.is_last and M.settings.symbols.blank
					or M.settings.symbols.parent,
				M.settings.symbols.blank,
				depth
			)
			table.insert(texts, 1, line)
			parent = parent.parent
		end

		return table.concat(texts, "") .. item.name
	end, list)

	vim.api.nvim_buf_set_lines(0, line_start, line_end, false, result)
end

function M.setup(opts)
	opts = opts or {}
	M.settings = vim.tbl_deep_extend("force", M.settings, opts)
end

return M
