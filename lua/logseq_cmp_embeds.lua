local config = require("logseq-nvim.config")
local has_cmp, cmp = pcall(require, "cmp")

if not has_cmp then
	return
end

local embeds = require("logseq-nvim.text.embeds")[config.client_opts.lang]

local sufijo
if config.client_opts.autopairs == true then
	sufijo = "}"
else
	sufijo = "}}"
end
local source = {}

source.new = function()
	return setmetatable({}, { __index = source })
end

source.get_trigger_characters = function()
	return { "{" }
end
function source:execute(completion_item, callback)
	vim.cmd("norm! 2h")
	callback(completion_item)
end
source.complete = function(self, request, callback)
	local input = string.sub(request.context.cursor_before_line, request.offset - 1)
	local prefix = string.sub(request.context.cursor_before_line, 1, request.offset - 1)

	local items = {}
	for label, embed in pairs(embeds) do
		if vim.startswith(input, "{") then
			table.insert(items, {
				label = label,
				tipo = embed[2],
				textEdit = {
					newText = embed[1] .. sufijo,
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
			})
			callback({
				items = items,
				isIncomplete = true,
			})
		else
			callback({ isIncomplete = true })
		end
	end
end

return source
