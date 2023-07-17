--[[
d = csv.file(filename)
d = csv.string(string)

d.rows[i] = i'th row
d.rows[i][j] = cell i,j

names = {'id', 'rank', 'etc'}
d:setColumnNames(names) --> sets column names, then you can do this:
d.rows[1].rank		--> gets you cell 1,1

also, d.comments is a table that has all the comments
--]]

local table = require 'ext.table'
local string = require 'ext.string'
local path = require 'ext.path'
local class = require 'ext.class'
local tolua = require 'ext.tolua'

local Row = class()

local function maxn(t)
	return table.keys(t):sup() or 0
end

function Row:init(csv, data)
	self.csv = csv
	for i=1,maxn(data) do
		self[i] = data[i]
	end
end

--assign after constructor so it can construct correctly
function Row:__index(key)
	-- if it's a number ... which it has ... then it will already be returned
	-- if it's a field (or a number that's not there) then it'll get here
	local csv = rawget(self, 'csv')
	if csv then 
		if csv.columnIndexForName then 
			local result = rawget(self, csv.columnIndexForName[key])
			if result then return result end
		end
	end

	return Row[key]
end

local CSV = class()

function CSV:readLine(l)
	local row = table()
	local state 
	local sofar = ''
	local states = {}
	states.default = function(c, c2)
		if c == ',' then
			row:insert(sofar)
			sofar = ''
		elseif c == '"' then
			state = states.readQuote
		else
			sofar = sofar .. c
		end
	end
	states.readQuote = function(c, c2)
		if c == '"' then
			if c2 == '"' then	-- two double quotes inside a quoted string is a quote symbol
				sofar = sofar .. c
				state = states.skipNextQuote
			else	-- single double-quote inside a quoted string is an end of quoted string 
				if c2 == ',' then
					state = states.skipNextComma
				else
					state = states.default
				end
				row:insert(sofar)
				sofar = ''
			end
		else
			sofar = sofar .. c
		end
	end
	states.skipNextComma = function(c, c2)
		assert(c == ',')
		state = states.default
	end
	states.skipNextQuote = function(c, c2)
		assert(c == '"')
		state = states.readQuote
	end
	state = states.default
	-- read column
	for i=1,#l do
		state(l:sub(i,i), l:sub(i+1, i+1))
	end
	row:insert(sofar)
	return row
end

function CSV:init(d)
	self.comments = table()
	self.rows = table()
	local ls = string.split(d, '\n')
	while #ls > 0 and #ls:last() == 0 do	-- remove trailing empty lines
		ls:remove()
	end
	for i,l in ipairs(ls) do
		if l:sub(1,1) == '#' then
			self.comments:insert(l:sub(2))
		else
			local row = Row(self, self:readLine(l))
			table.insert(self.rows, row)
		end
	end
end

function CSV:setColumnNames(columns)
	columns = table.mapi(columns, function(s) return tostring(s) end)
	self.columns = columns
	self.columnIndexForName = self.columns:mapi(function(name, k)
		return k, name
	end)
end

function CSV:toLua()
	local s = table()
	s:insert'{'
	for i,row in ipairs(self.rows) do
		if self.columns then
			local lrow = {}
			for j,col in ipairs(self.columns) do
				if row[j] ~= '' then
					lrow[col] = row[j]
				end
			end
			s:insert('\t'..tolua(lrow)..',')
		else
			-- does unpack have a size limit?
			s:insert('\t'..tolua{table.unpack(row)}..',')
		end
	end
	s:insert'}'
	return s:concat'\n'
end

-- TODO make this compatible with the CSV structure
-- until then, I'm just going to accept generic int-sequence-indexed tables of key'd tables
function CSV.save(data, keys)
	if not keys then
		local keyset = {}
		for i=1,#data do
			local row = data[i]
			for k,_ in pairs(row) do
				keyset[k] = true
			end
		end
		keys = table()
		for k,_ in pairs(keyset) do
			keys:insert(k)
		end
	else
		keys = table(keys)	-- make sure its metatable is setup
	end
	local lines = table()
	lines:insert('# '..keys:concat(',\t'))
	for i=1,#data do
		local row = data[i]
		lines:insert(keys:mapi(function(key)
			local value = row[key]
			if value == nil then value = '' end
			value = tostring(value)
			if value:find',' then value = ('%q'):format(value) end
			return value
		end):concat',\t')
	end
	return lines:concat'\n'
end

local csv = {
	file = function(fn)
		return CSV(path(fn):read())
	end,
	string = function(d)
		return CSV(d)
	end,
	save = CSV.save,
}

return csv
