[![Donate via Stripe](https://img.shields.io/badge/Donate-Stripe-green.svg)](https://buy.stripe.com/00gbJZ0OdcNs9zi288)<br>
[![Donate via Bitcoin](https://img.shields.io/badge/Donate-Bitcoin-green.svg)](bitcoin:37fsp7qQKU8XoHZGRQvVzQVP8FrEJ73cSJ)<br>

### CSV parser for Lua

Examples:

Reading CSV data:
```Lua
local CSV = require 'csv'
local d = CSV.file(filename)	-- read data from file
local d = CSV.string(string)	-- read data from string
```

Accessing data by row/column indexes:
```Lua
print(d.rows[i])	-- access the i'th row
print(d.rows[i][j])	-- access the j'th column of the i'th row
```

Accessing data by named columns:
```Lua
local names = {'id', 'rank', 'etc'}
d:setColumnNames(names) -- sets column names, then you can do this:
d.rows[1].rank			-- gets you cell 1,1
```

Accessing data by the first-commented-line:
```Lua
local string = require 'ext.string'
d:setColumnNames(string.split(d.comments[1],','))
```

### Dependencies:

- https://github.com/thenumbernine/lua-ext
