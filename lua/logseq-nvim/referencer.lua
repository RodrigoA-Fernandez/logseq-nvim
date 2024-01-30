local random = math.random

local function uuid()
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	return string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
		return string.format("%x", v)
	end)
end

local function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function aniadir_referencia(file, line)
	local archivo = io.open(file, "r")
	local lineas = {}
	if archivo == nil then
		print("[Logseq-nvim] El archivo no existe.")
		return 0
	end

	local contador = 1
	for linea in archivo:lines() do
		lineas[contador] = linea
		contador = contador + 1
	end
	io.close(archivo)

	local cursor = line
	while string.sub(trim(lineas[cursor]), 1, 1) ~= "-" do
		cursor = cursor - 1
	end

	cursor = cursor + 1

	while string.sub(trim(lineas[cursor]), 1, 1) ~= "-" and string.sub(trim(lineas[cursor]), 1, 1) ~= ":" do
		cursor = cursor + 1
	end
	local lin_ant = lineas[cursor - 1]

	local padding = ""
	for c in string.gmatch(lin_ant:gsub("-", " "), ".") do
		if c ~= " " then
			break
		end
		padding = padding .. " "
	end

	local id = uuid()
	local id_string = padding .. "id:: " .. id

	archivo = io.open(file, "w")
	if archivo == nil then
		print("[Logseq-nvim] El archivo no existe.")
		return 0
	end
	for i, l in pairs(lineas) do
		if i == cursor then
			archivo:write(id_string .. "\n")
		end
		archivo:write(l .. "\n")
	end
	io.close(archivo)
	return id
end

local function copiar_referencia_bloque_actual()
	vim.cmd(":sil w")
	local archivo = vim.fs.normalize(vim.fn.expand("%"))
	local linea = vim.api.nvim_win_get_cursor(0)[1]
	local id = aniadir_referencia(archivo, linea)
	vim.cmd(":e")
	local referencia = "((" .. id .. "))"
	vim.cmd("norm! o") -- Añade linea
	vim.api.nvim_set_current_line(referencia) --Pega la referencia a la linea
	vim.cmd("norm! v_$d") --Copia la referencia
	print("[Logseq-nvim] Referencia copiada al registro.")
end

return {
	aniadir_referencia = aniadir_referencia,
	copiar_referencia_bloque_actual = copiar_referencia_bloque_actual,
}
