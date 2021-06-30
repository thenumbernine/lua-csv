#!/usr/bin/env luajit
local fn = ...
local csv = require 'csv'.file(fn)
csv:setColumnNames(csv.rows:remove(1))
print(csv:toLua())
