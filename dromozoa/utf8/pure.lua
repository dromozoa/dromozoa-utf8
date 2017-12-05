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
local decode = require "dromozoa.utf8.decode"
local encode = require "dromozoa.utf8.encode"

local error = error
local select = select
local tonumber = tonumber
local tostring = tostring
local type = type

local concat = table.concat
local unpack = table.unpack or unpack

local function check_integer(v, i)
  local t = type(v)
  if t ~= "number" then
    if t == "string" then
      v = tonumber(v)
    else
      error("bad argument #" .. i .. " (number expected, got " .. t .. ")")
    end
  end
  if v % 1 ~= 0 then
    error("bad argument #" .. i .. " (number has no integer representation)")
  end
  return v
end

local function check_string(v, i)
  local t = type(v)
  if t ~= "string" then
    if t == "number" then
      v = tostring(v)
    else
      error("bad argument #" .. i .. " (string expected, got " .. t .. ")")
    end
  end
  return v
end

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

local function len(s, i, j)
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
    if i < 1 or m < i then
      error "bad argument #2 (initial position out of string)"
    end
  end

  if j == nil then
    j = n
  else
    j = check_integer(j, 3)
    if j < 0 then
      j = j + m
    end
    if n < j then
      error "bad argument #3 (final position out of string)"
    end
  end

  if i > j then
    return 0
  end

  return count(s, i, j)
end

local function offset(s, n, i)
  if n == nil then
    error "bad argument #2"
  end

  if i == nil then
    if n < 0 then
      i = #s + 1
    else
      i = 1
    end
  else
    if i < 0 then
      i = #s + 1 + i
    end
    if i < 1 or #s + 1 < i then
      error "bad argument #3"
    end
  end

  local a = s:byte(i)
  if n == 0 then
    while a ~= nil and 0x80 <= a and a <= 0xBF do
      i = i - 1
      a = s:byte(i)
    end
  else
    if a ~= nil and 0x80 <= a and a <= 0xBF then
      error "initial position is a continuation byte"
    end
    if n < 0 then
      while n < 0 do
        repeat
          i = i - 1
          a = s:byte(i)
          if a == nil then return nil end
        until a < 0x80 or 0xBF < a
        n = n + 1
      end
    else
      while n > 1 do
        if a == nil then return nil end
        repeat
          i = i + 1
          a = s:byte(i)
        until a == nil or a < 0x80 or 0xBF < a
        n = n - 1
      end
    end
  end
  return i
end

return {
  char = char;
  charpattern = "[\000-\127\194-\244][\128-\191]*";
  codes = codes;
  codepoint = codepoint;
  len = len;
  offset = offset;
}
