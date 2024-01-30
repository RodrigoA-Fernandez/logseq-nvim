local config = require("logseq-nvim.config")
require("logseq-nvim.commands")

local function setup(opts)
	for _, value in pairs(opts.graphs) do
		table.insert(config.client_opts.grafos, vim.fs.normalize(value))
	end

	local has_cmp, cmp = pcall(require, "cmp")

	if opts.autopairs == true then
		config.client_opts.autopairs = true
	end

	if type(opts.lang) ~= "nil" then
		config.client_opts.lang = opts.lang
	end

	if has_cmp then
		for index, grafo in ipairs(config.client_opts.grafos) do
			cmp.register_source("logseq_links_" .. index, require("logseq_cmp_links").create_source(index))
		end
		cmp.register_source("logseq_embeds", require("logseq_cmp_embeds"))
	end
end

vim.api.nvim_create_autocmd({ "BufEnter" }, {
	callback = function()
		local has_cmp, cmp = pcall(require, "cmp")
		if has_cmp then
			local sources = {}
			for index, grafo in ipairs(config.client_opts.grafos) do
				if type(string.find(vim.fs.normalize(vim.api.nvim_buf_get_name(0)), grafo)) ~= "nil" then
					table.insert(sources, { name = "logseq_links_" .. index })
				end
			end
			for _, source in pairs(cmp.get_config().sources) do
				if type(source.name:find("logseq_links_")) ~= "nil" then
					table.insert(sources, source)
				end
			end
			table.insert(sources, { name = "logseq_embeds" })
			cmp.setup.buffer({ sources = sources })
		end
	end,
})

return {
	setup = setup,
}
