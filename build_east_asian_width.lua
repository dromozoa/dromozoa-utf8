-- Copyright (C) 2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local filename = "doc/EastAsianWidth-10.0.0.txt"
local code_filename = "dromozoa/ucd/east_asian_width.lua"

local properties = {
  ["N"]  = true; -- neutral
  ["Na"] = true; -- narrow
  ["H"]  = true; -- halfwidth
  ["A"]  = true; -- ambiguous
  ["W"]  = true; -- wide
  ["F"]  = true; -- fullwidth
}

local _ = builder("N")

for line in io.lines(filename) do
  local first, last, property = line:match("^(%x+)%.%.(%x+);(%a+)")
  if not first then
    first, property = line:match("^(%x+);(%a+)")
    last = first
  end
  if first then
    local first = tonumber(first, 16)
    local last = tonumber(last, 16)
    assert(first <= last)
    assert(not prev or prev < first)
    assert(properties[property])
    _:range(first, last, property)
    prev = last
  end
end

local code = _.compile(_:build())

local out = assert(io.open(code_filename, "w"))
out:write(unpack(code))
out:close()
