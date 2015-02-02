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

local function len(s, i, j)
  if i == nil then
    i = 1
  end
  if j == nil then
    j = #s
  elseif j < 0 then
    j = #s + j + 1
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
        return nil, 1
      end
    else
      return nil, 1
    end
    result = result + 1
  end
  return result
end

local unpack = table.unpack or unpack







local function range(s, v, d)
  local v = tonumber(v)
  if v == nil then
    v = d
  elseif v < 0 then
    v = #s + v + 1
  end
  return v
end

local function encode(a)
  assert(0 <= a and a < 0xD800 or 0xDFFF < a and a <= 0x10FFFF)
  if a <= 0x7F then
    return string.char(a)
  elseif a <= 0x07FF then
    local b = a % 0x40
    local a = math.floor(a / 0x40)
    return string.char(a + 0xC0, b + 0x80)
  elseif a <= 0xFFFF then
    local c = a % 0x40
    local a = math.floor(a / 0x40)
    local b = a % 0x40
    local a = math.floor(a / 0x40)
    return string.char(a + 0xE0, b + 0x80, c + 0x80)
  else
    local d = a % 0x40
    local a = math.floor(a / 0x40)
    local c = a % 0x40
    local a = math.floor(a / 0x40)
    local b = a % 0x40
    local a = math.floor(a / 0x40)
    return string.char(a + 0xF0, b + 0x80, c + 0x80, d + 0x80)
  end
end

local function each_codepoint(s, i)
  local a = s:byte(i)
  local i = i + 1
  if a <= 0x7F then
    return i, a
  elseif 0xC0 <= a and a <= 0xDF then
    local b = s:byte(i)
    local a = a % 0x20 * 0x40
    local b = b % 0x40
    return i + 1, a + b
  elseif a <= 0xEF then
    local b, c = s:byte(i, i + 1)
    local a = a % 0x10 * 0x1000
    local b = b % 0x40 * 0x40
    local c = c % 0x40
    return i + 2, a + b + c
  elseif a <= 0xF7 then
    local b, c, d = s:byte(i, i + 2)
    local a = a % 0x08 * 0x040000
    local b = b % 0x40 * 0x1000
    local c = c % 0x40 * 0x40
    local d = d % 0x40
    return i + 3, a + b + c + d
  else
    error(i)
  end
end

local function decode_tail(b, c, d)
  


  if 0x80 <= a and a <= 0xBF then
    if b == nil then
      return a % 0x40
    else
      return a % 0x40 * b
    end
  else
    return nil
  end
end

local function decode(s, i)
  local a = s:byte(i)
  if a == nil then
    return nil
  elseif 0x00 <= a and a <= 0x7F then
    return i + 1, a
  elseif 0xC2 <= a and a <= 0xDF then
    local a = a % 0x20 * 0x40
    local b = s:byte(i + 1)
    if b == nil then
      return nil
    end

    local b = decode_tail(b)
    return i + 2, a + b
  elseif 0xE0 <= a and a <= 0xEF then
    local b, c = s:byte(i + 1, i + 2)
    if 0xE0 == a then
      if 0xA0 <= b and b <= 0xBF then
        return decode_impl(a, b, c)
      else
        return nil
      end
    elseif 0xE1 <= a and a <= 0xEC then
    elseif 0xED == a then
      if 0x80 <= b and b <= 0x9f then
      else
        return nil
      end
    elseif 0xEE <= a and a <= 0xEF then
    end

  elseif 0xF0 <= a and a <= 0xF4 then
    local a = a % 0x20 * 0x040000
    local b, c, d = s:byte(i + 1, i + 3)
    if d == nil then
      return nil
    end

  else
    return nil
  end
end

local function char(...)
  local n = select("#", ...)
  if n == 0 then
    return ""
  elseif n == 1 then
    return encode(...)
  else
    local result = {}
    for i = 1, n do
      result[#result + 1] = encode(select(i, ...))
    end
    return table.concat(result)
  end
end

local function codes(s)
  local i = 1
  return function (s)
    if i <= #s then
      local j = i
      local c
      i, c = each_codepoint(s, i)
      return j, c
    else
      return nil
    end
  end, s, 0
end

local function codepoint(s, i, j)
  local i = range(s, i, 1)
  assert(1 <= i and i <= #s)
  local j = range(s, j, i)

  local result = {}
  while i <= j do
    i, result[#result + 1] = each_codepoint(s, i)
  end
  return unpack(result)
end

--- @export
return {
  char = char;
  codes = codes;
  codepoint = codepoint;
  len = len;
}
