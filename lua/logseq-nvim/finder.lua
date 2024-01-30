local config = require("logseq-nvim.config")

local function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

local M = {}
local function current_graph()
	for _, grafo in ipairs(config.client_opts.grafos) do
		if type(string.find(vim.fs.normalize(vim.api.nvim_buf_get_name(0)), grafo)) ~= "nil" then
			return grafo
		end
	end
end
local function parse_files(file_list)
	local mapa_meses = {
		[1] = "Jan",
		[2] = "Feb",
		[3] = "Mar",
		[4] = "Apr",
		[5] = "May",
		[6] = "Jun",
		[7] = "Jul",
		[8] = "Aug",
		[9] = "Sep",
		[10] = "Oct",
		[11] = "Nov",
		[12] = "Dic",
	}
	local mapa_sufijos = {
		[1] = "st",
		[2] = "nd",
		[3] = "rd",
	}
	local lista_util = {}
	for _, path in ipairs(file_list) do
		if path:find("journals/") then
			local y, m, d = path:match("[^/]*.md$"):match("(%d+)_(%d+)_(%d+)")
			local sufijo = mapa_sufijos[d]
			local mes = mapa_meses[tonumber(m)]
			if not sufijo then
				sufijo = "th"
			end
			print(type(m))

			if mes and d and sufijo then
				lista_util[mes .. " " .. d .. sufijo .. ", " .. y] = path
			end
		else
			local link = path:match("[^/]*.md$"):match("(.+)%..+$")
			lista_util[link] = path
		end
	end
	return lista_util
end

local function get_files()
	local archivos = vim.fs.find(function(name, path)
		return name:match(".*%.md$") and not path:find("/logseq")
	end, { limit = math.huge, type = "file", path = current_graph() })

	-- local f = io.open("/home/rodrigo/plugin.txt", "a")
	-- f:write(dump(a))
	-- f:close()

	return parse_files(archivos)
end
M["get_files"] = get_files

return M
