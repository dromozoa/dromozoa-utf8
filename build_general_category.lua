-- Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-utf8.
--
-- dromozoa-utf8 is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-utf8 is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-utf8.  If not, see <http://www.gnu.org/licenses/>.

local builder = require "dromozoa.ucd.builder"

local unpack = table.unpack or unpack

local source_filename = "docs/10.0.0/ucd/UnicodeData.txt"
local result_filename = "dromozoa/ucd/general_category.lua"

local _ = builder("Cn")

local prev_code
local prev_property

for line in io.lines(source_filename) do
  local code, name, property = assert(line:match "^(%x+);(.-);(.-);")
  code = tonumber(code, 16)
  if name:find ", First>$" then
    prev_code = code
    prev_property = property
  else
    if name:find ", Last>$" then
      assert(prev_code < code)
      assert(prev_property == property)
      _:range(prev_code, code, property)
      prev_code = nil
      prev_property = nil
    else
      assert(not prev_code)
      assert(not prev_property)
      _:range(code, code, property)
    end
  end
end

local data = _:build()
local out = assert(io.open(result_filename, "w"))
_.compile(out, data):close()
