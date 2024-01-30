local config = require("logseq-nvim.config")
local finder = require("logseq-nvim.finder")

local function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "}"
	else
		return tostring(o) .. ""
	end
end

local function create_source(id_grafo)
	local has_cmp, cmp = pcall(require, "cmp")

	if not has_cmp then
		return
	end

	local source = {}
	local sufijo
	if config.client_opts.autopairs then
		sufijo = "]"
	else
		sufijo = "]]"
	end

	source.new = function()
		return setmetatable({}, { __index = source })
	end

	source.get_trigger_characters = function()
		return { "[" }
	end

	function source:execute(completion_item, callback)
		callback(completion_item)
	end

	source.complete = function(self, request, callback)
		local input = string.sub(request.context.cursor_before_line, request.offset - 1)
		local items = {}
		local files = finder.get_files()
		if vim.startswith(input, "[") then
			for link, path in pairs(files) do
				local f = io.open(path, "r")
				local doc
				if f then
					doc = f:read("a")
				else
					doc = nil
				end

				table.insert(items, {
					label = link,
					tipo = "LogseqLink",
					textEdit = {
						newText = "[" .. link .. sufijo,
						range = {
							start = {
								line = request.context.cursor.row - 1,
								character = request.context.cursor.col - #input,
							},
							["end"] = {
								line = request.context.cursor.row - 1,
								character = request.context.cursor.col - 1,
							},
						},
					},
					documentation = doc,
				})
			end
			callback({
				items = items,
				isIncomplete = true,
			})
		else
			callback({ isIncomplete = true })
		end
	end
	return source
end

return {
	create_source = create_source,
}
