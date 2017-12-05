-- Copyright (C) 2015,2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local count = require "dromozoa.utf8.count"
local check_integer = require "dromozoa.utf8.check_integer"
local check_string = require "dromozoa.utf8.check_string"
local decode = require "dromozoa.utf8.decode"
local encode = require "dromozoa.utf8.encode"
local offset = require "dromozoa.utf8.offset"

local error = error
local select = select
local type = type

local concat = table.concat
local unpack = table.unpack or unpack

local function char(...)
  local n = select("#", ...)
  if n == 1 then
    local v = encode(check_integer(..., 1))
    if not v then
      error "bad argument #1 (value out of range)"
    else
      return v
    end
  else
    local data = {...}
    for i = 1, n do
      local v = encode(check_integer(data[i], i))
      if not v then
        error("bad argument #" .. i .. " (value out of range)")
      else
        data[i] = v
      end
    end
    return concat(data)
  end
end

local function codes(s)
  local s = check_string(s, 1)
  local i = 1
  local c
  return function ()
    local j = i
    i, c = decode(s, i)
    if i then
      return j, c
    end
  end
end

local function codepoint(s, i, j)
  s = check_string(s, 1)

  local n = #s
  local m = n + 1

  if i == nil then
    i = 1
  else
    i = check_integer(i, 2)
    if i < 0 then
      i = i + m
    end
    if i < 1 then
      error "bad argument #2 (out of range)"
    end
  end

  if j == nil then
    j = i
  else
    j = check_integer(j, 3)
    if j < 0 then
      j = j + m
    end
  end
  if n < j then
    error "bad argument #3 (out of range)"
  end

  if i == j then
    local a, b = decode(s, i)
    return b
  else
    local result = {}
    local k = 0
    while i <= j do
      k = k + 1
      i, result[k] = decode(s, i)
    end
    return unpack(result)
  end
end

return {
  char = char;
  charpattern = "[\000-\127\194-\244][\128-\191]*";
  codes = codes;
  codepoint = codepoint;
  len = count;
  offset = offset;
}
