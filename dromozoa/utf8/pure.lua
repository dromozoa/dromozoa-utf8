-- Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
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

--- Lua 5.3 compatible pure-Lua UTF-8 implementation.
-- @module dromozoa.utf8.purelua

local function length(s, i, j)
  if i == nil then
    i = 1
  elseif i < 0 then
    i = #s + 1 + i
  end
  if i < 1 or #s + 1 < i then
    error "bad argument #2"
  end
  if j == nil then
    j = #s
  elseif j < 0 then
    j = #s + 1 + j
  end
  local result = 0
  while i <= j do
    local a, b, c, d = string.byte(s, i, i + 3)
    if a == nil then
      return nil, i
    elseif a <= 0x7F then
      i = i + 1
    elseif 0xC2 <= a then
      if a <= 0xDF then
        if b == nil or b < 0x80 or 0xBF < b then return nil, i end
        i = i + 2
      elseif a <= 0xEF then
        if a <= 0xEC then
          if a == 0xE0 then
            if b == nil or b < 0xA0 or 0xBF < b then return nil, i end
          else
            if b == nil or b < 0x80 or 0xBF < b then return nil, i end
          end
        else
          if a == 0xED then
            if b == nil or b < 0x80 or 0x9F < b then return nil, i end
          else
            if b == nil or b < 0x80 or 0xBF < b then return nil, i end
          end
        end
        if c == nil or c < 0x80 or 0xBF < c then return nil, i end
        i = i + 3
      elseif a <= 0xF4 then
        if a == 0xF0 then
          if b == nil or b < 0x90 or 0xBF < b then return nil, i end
        elseif a <= 0xF3 then
          if b == nil or b < 0x80 or 0xBF < b then return nil, i end
        else
          if b == nil or b < 0x80 or 0x8F < b then return nil, i end
        end
        if c == nil or c < 0x80 or 0xBF < c then return nil, i end
        if d == nil or d < 0x80 or 0xBF < d then return nil, i end
        i = i + 4
      else
        return nil, i
      end
    else
      return nil, i
    end
    result = result + 1
  end
  return result
end

local function decode(s, i)
  local a, b, c, d = s:byte(i, i + 3)
  if a == nil then
    return nil
  elseif a <= 0x7F then
    return i + 1, a
  elseif 0xC2 <= a then
    if a <= 0xDF then
      if b == nil or b < 0x80 or 0xBF < b then return nil end
      local a = a % 0x20 * 0x40
      local b = b % 0x40
      return i + 2, a + b
    elseif a <= 0xEF then
      if a <= 0xEC then
        if a == 0xE0 then
          if b == nil or b < 0xA0 or 0xBF < b then return nil end
        else
          if b == nil or b < 0x80 or 0xBF < b then return nil end
        end
      else
        if a == 0xED then
          if b == nil or b < 0x80 or 0x9F < b then return nil end
        else
          if b == nil or b < 0x80 or 0xBF < b then return nil end
        end
      end
      if c == nil or c < 0x80 or 0xBF < c then return nil end
      local a = a % 0x10 * 0x1000
      local b = b % 0x40 * 0x40
      local c = c % 0x40
      return i + 3, a + b + c
    elseif a <= 0xF4 then
      if a == 0xF0 then
        if b == nil or b < 0x90 or 0xBF < b then return nil end
      elseif a <= 0xF3 then
        if b == nil or b < 0x80 or 0xBF < b then return nil end
      else
        if b == nil or b < 0x80 or 0x8F < b then return nil end
      end
      if c == nil or c < 0x80 or 0xBF < c then return nil end
      if d == nil or d < 0x80 or 0xBF < d then return nil end
      local a = a % 0x08 * 0x040000
      local b = b % 0x40 * 0x1000
      local c = c % 0x40 * 0x40
      local d = d % 0x40
      return i + 4, a + b + c + d
    end
  end
  return nil
end

local function encode(a)
  if 0x00 <= a then
    if a <= 0x7F then
      return string.char(a)
    elseif a <= 0x07FF then
      local b = a % 0x40
      local a = math.floor(a / 0x40)
      return string.char(a + 0xC0, b + 0x80)
    elseif a <= 0xFFFF then
      if 0xD800 <= a and a <= 0xDFFF then return nil end
      local c = a % 0x40
      local a = math.floor(a / 0x40)
      local b = a % 0x40
      local a = math.floor(a / 0x40)
      return string.char(a + 0xE0, b + 0x80, c + 0x80)
    elseif a <= 0x10FFFF then
      local d = a % 0x40
      local a = math.floor(a / 0x40)
      local c = a % 0x40
      local a = math.floor(a / 0x40)
      local b = a % 0x40
      local a = math.floor(a / 0x40)
      return string.char(a + 0xF0, b + 0x80, c + 0x80, d + 0x80)
    end
  end
  return nil
end

local unpack = table.unpack or unpack

local function char(...)
  local n = select("#", ...)
  local result = {}
  for i = 1, n do
    local s = encode(select(i, ...))
    if s == nil then
      error "bad argument #1"
    end
    result[#result + 1] = s
  end
  return table.concat(result)
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
  elseif i < 0 then
    i = #s + 1 + i
  end
  if i < 1 or #s < i then
    error "bad argument #2"
  end
  if j == nil then
    j = i
  elseif i < 0 then
    j = #s + 1 + j
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

local function offset(s, n, i)
  if n == nil then
    error "bad argument #2"
  elseif n == 0 then
    if i == nil then
      i = 1
    elseif i < 0 then
      i = #s + 1 + i
    end
    assert(1 <= i and i <= #s + 1)
    local b = s:byte(i)
    while b ~= nil and 0x80 <= b and b <= 0xBF do
      i = i - 1
      b = s:byte(i)
    end
    return i
  elseif n > 0 then
    if i == nil then
      i = 1
    elseif i < 0 then
      i = #s + 1 + i
    end
    assert(1 <= i and i <= #s + 1)
    local b = s:byte(i)
    if b ~= nil and 0x80 <= b and b <= 0xBF then
      error "initial position is a continuation byte"
    end
    while n > 1 do
      if b == nil then
        return nil
      end
      repeat
        i = i + 1
        b = s:byte(i)
      until b == nil or b < 0x80 or 0xBF < b
      n = n - 1
    end
    return i
  else
    if i == nil then
      i = #s + 1
    elseif i < 0 then
      i = #s + 1 + i
    end
    assert(1 <= i and i <= #s + 1)
    local b = s:byte(i)
    if b ~= nil and 0x80 <= b and b <= 0xBF then
      error "initial position is a continuation byte"
    end
    while n < 0 do
      repeat
        i = i - 1
        local b = s:byte(i)
        if b == nil then return nil end
      until b < 0x80 or 0xBF < b
      n = n + 1
    end
    return i
  end
end

--- @export
return {
  char = char;
  charpattern = "[\000-\127\194-\244][\128-\191]*";
  codes = codes;
  codepoint = codepoint;
  len = length;
  offset = offset;
}
