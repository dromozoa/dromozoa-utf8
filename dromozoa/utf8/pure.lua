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

local function char(...)
  local result = {}
  for i = 1, select("#", ...) do
    local a = encode(select(i, ...))
    if a == nil then
      error("bad argument #" .. i)
    end
    result[#result + 1] = a
  end
  return concat(result)
end

local function codes(s)
  local i = 1
  return function (s)
    if i <= #s then
      local j = i
      local c
      i, c = decode(s, i)
      if i == nil then
        error "invalid UTF-8 code"
      else
        return j, c
      end
    else
      return nil
    end
  end, s
end

local function codepoint(s, i, j)
  if i == nil then
    i = 1
  else
    if i < 0 then
      i = #s + 1 + i
    end
    if i < 1 then
      error "bad argument #2"
    end
  end

  if j == nil then
    j = i
  elseif j < 0 then
    j = #s + 1 + j
  end
  if #s < j then
    error "bad argument #3"
  end

  local result = {}
  while i <= j do
    i, result[#result + 1] = decode(s, i)
    if i == nil then
      error "invalid UTF-8 code"
    end
  end
  return unpack(result)
end

local function len(s, i, j)
  local t = type(s)
  if t ~= "string" then
    if t == "number" then
      s = tostring(s)
    else
      error("bad argument #1 (string expected, got " .. t .. ")")
    end
  end

  local n = #s
  local m = n + 1

  if i == nil then
    i = 1
  else
    local t = type(i)
    if t ~= "number" then
      if t == "string" then
        i = tonumber(i)
      else
        error("bad argument #2 (number expected, got " .. t .. ")")
      end
    end
    if i % 1 ~= 0 then
      error "bad argument #2 (number has no integer representation)"
    end
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
    local t = type(j)
    if t ~= "number" then
      if t == "string" then
        j = tonumber(j)
      else
        error("bad argument #3 (number expected, got " .. t .. ")")
      end
    end
    if j % 1 ~= 0 then
      error "bad argument #3 (number has no integer representation)"
    end
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
