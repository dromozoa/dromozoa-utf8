-- Copyright (C) 2017-2019,2023,2024 Tomoyuki Fujimori <moyu@dromozoa.com>
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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-utf8. If not, see <https://www.gnu.org/licenses/>.

local builder = require "dromozoa.ucd.builder"
local build_config = require "build_config"

local source_filename = "docs/" .. build_config.ucd_version .. "/ucd/EastAsianWidth.txt"
local result_filename = "dromozoa/ucd/east_asian_width.lua"
local result_filename_half = "dromozoa/ucd/east_asian_width_ambiguous_half.lua"
local result_filename_full = "dromozoa/ucd/east_asian_width_ambiguous_full.lua"

local properties = {
  N  = true, -- neutral
  Na = true, -- narrow
  H  = true, -- halfwidth
  A  = true, -- ambiguous
  W  = true, -- wide
  F  = true, -- fullwidth
}

local widths_ambiguous_half = {
  N  = 1, -- neutral
  Na = 1, -- narrow
  H  = 1, -- halfwidth
  A  = 1, -- ambiguous
  W  = 2, -- wide
  F  = 2, -- fullwidth
}

local widths_ambiguous_full = {
  N  = 1, -- neutral
  Na = 1, -- narrow
  H  = 1, -- halfwidth
  A  = 2, -- ambiguous
  W  = 2, -- wide
  F  = 2, -- fullwidth
}

local b = builder "N"
local b_half = builder(1)
local b_full = builder(1)

for line in io.lines(source_filename) do
  local first, last, property = line:match "^(%x+)%.%.(%x+)%s*;%s*(%a+)"
  if not first then
    first, property = line:match "^(%x+)%s*;%s*(%a+)"
    last = first
  end
  if first then
    local first = tonumber(first, 16)
    local last = tonumber(last, 16)
    assert(first <= last)
    assert(not prev or prev < first)
    assert(properties[property])
    b:range(first, last, property)
    b_half:range(first, last, widths_ambiguous_half[property])
    b_full:range(first, last, widths_ambiguous_full[property])
    prev = last
  end
end

local function write(b, result_filename, value_type)
  local data = b:build()
  local out = assert(io.open(result_filename, "w"))
  b.compile(out, data, value_type):close()
end

write(b, result_filename, "string")
write(b_half, result_filename_half, "integer")
write(b_full, result_filename_full, "integer")
