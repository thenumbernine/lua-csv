package = "ext"
version = "dev-1"
source = {
	url = "git+https://github.com/thenumbernine/lua-csv"
}
description = {
	summary = "CSV format class.",
	detailed = "CSV format class.",
	homepage = "https://github.com/thenumbernine/lua-csv",
	license = "MIT"
}
dependencies = {
	"lua >= 5.1",
}
build = {
	type = "builtin",
	modules = {
		["csv"] = "csv.lua",
		["csv.tolua"] = "tolua.lua",
	}
}
