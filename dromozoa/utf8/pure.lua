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

local unpack = table.unpack or unpack

local function compile()
  local data = {
    { 0x00, 0x7F };
    { 0xC2, 0xDF, 0x80, 0xBF };
    { 0xE0, 0xE0, 0xA0, 0xBF, 0x80, 0xBF };
    { 0xE1, 0xEC, 0x80, 0xBF, 0x80, 0xBF };
    { 0xED, 0xED, 0x80, 0x9F, 0x80, 0xBF };
    { 0xEE, 0xEF, 0x80, 0xBF, 0x80, 0xBF };
    { 0xF0, 0xF0, 0x90, 0xBF, 0x80, 0xBF, 0x80, 0xBF };
    { 0xF1, 0xF3, 0x80, 0xBF, 0x80, 0xBF, 0x80, 0xBF };
    { 0xF4, 0xF4, 0x80, 0x8F, 0x80, 0xBF, 0x80, 0xBF };
  }

  local code = {}
  for i = 1, #data do
    local x = { #data[i] / 2, unpack(data[i], 3) }
    for j = data[i][1], data[i][2] do
      code[j] = x
    end
  end

  local function len(s, i, j)
    local code = code
    if i == nil then
      i = 1
    end
    if j == nil then
      j = -1
    end
    if j < 0 then
      j = #s + j + 1
    end
    local result = 0
    while i <= j do
      local a, b, c, d = string.byte(s, i, i + 3)
      if a == nil then return nil, i end
      local x = code[a]
      if x == nil then return nil, i end
      -- local n, bmin, bmax, cmin, cmax, dmin, dmax = unpack(x)
      local n = x[1]
      if n == 1 then
        i = i + 1
      elseif n == 2 then
        -- if b == nil or b < bmin or bmax < b then return nil, i end
        i = i + 2
      elseif n == 3 then
        -- if b == nil or b < bmin or bmax < b then return nil, i end
        -- if c == nil or c < cmin or cmax < c then return nil, i end
        i = i + 3
      else
        -- if b == nil or b < bmin or bmax < b then return nil, i end
        -- if c == nil or c < cmin or cmax < c then return nil, i end
        -- if d == nil or d < dmin or dmax < d then return nil, i end
        i = i + 4
      end
      result = result + 1
    end
    return result
  end

  return len
end

local len = compile()

local function len(s, i, j)
  if i == nil then
    i = 1
  end
  if j == nil then
    j = -1
  end
  if j < 0 then
    j = #s + j + 1
  end
  local result = 0
  while i <= j do
    local a, b, c, d = string.byte(s, i, i + 3)
    if a == nil then
      return nil, i
    end
    if 0x00 <= a and a <= 0x7F then
      i = i + 1
    elseif 0xC2 <= a and a <= 0xDF then
      if b == nil or b < 0x80 or 0xBF < b then return nil, i end
      i = i + 2
    elseif 0xE0 == a then
      if b == nil or b < 0xA0 or 0xBF < b then return nil, i end
      if c == nil or c < 0x80 or 0xBF < c then return nil, i end
      i = i + 3
    elseif 0xE1 <= a and a <= 0xEC then
      if b == nil or b < 0x80 or 0xBF < b then return nil, i end
      if c == nil or c < 0x80 or 0xBF < c then return nil, i end
      i = i + 3
    elseif 0xED == a then
      if b == nil or b < 0x80 or 0x9F < b then return nil, i end
      if c == nil or c < 0x80 or 0xBF < c then return nil, i end
      i = i + 3
    elseif 0xEE == a or 0xEF == a then
      if b == nil or b < 0x80 or 0xBF < b then return nil, i end
      if c == nil or c < 0x80 or 0xBF < c then return nil, i end
      i = i + 3
    elseif 0xF0 == a then
      if b == nil or b < 0x90 or 0xBF < b then return nil, i end
      if c == nil or c < 0x80 or 0xBF < c then return nil, i end
      if d == nil or d < 0x80 or 0xBF < d then return nil, i end
      i = i + 4
    elseif 0xF1 <= a and a <= 0xF3 then
      if b == nil or b < 0x80 or 0xBF < b then return nil, i end
      if c == nil or c < 0x80 or 0xBF < c then return nil, i end
      if d == nil or d < 0x80 or 0xBF < d then return nil, i end
      i = i + 4
    elseif 0xF4 == a then
      if b == nil or b < 0x80 or 0x8F < b then return nil, i end
      if c == nil or c < 0x80 or 0xBF < c then return nil, i end
      if d == nil or d < 0x80 or 0xBF < d then return nil, i end
      i = i + 4
    else
      return nil, i
    end
    result = result + 1
  end
  return result
end

local function len(s, i, j)
  if i == nil then
    i = 1
  end
  if j == nil then
    j = -1
  end
  if j < 0 then
    j = #s + j + 1
  end
  local result = 0
  while i <= j do
    local a, b, c, d = string.byte(s, i, i + 3)
    if a == nil then
      return nil, i
    end
    if 0x00 <= a and a <= 0x7F then
      i = i + 1
    elseif 0xC2 <= a and a <= 0xDF then
      if b == nil or b < 0x80 or 0xBF < b then return nil, i
      else i = i + 2 end
    elseif 0xE0 == a then
      if b == nil or b < 0xA0 or 0xBF < b then return nil, i
      elseif c == nil or c < 0x80 or 0xBF < c then return nil, i
      else i = i + 3 end
    elseif 0xE1 <= a and a <= 0xEC then
      if b == nil or b < 0x80 or 0xBF < b then return nil, i
      elseif c == nil or c < 0x80 or 0xBF < c then return nil, i
      else i = i + 3 end
    elseif 0xED == a then
      if b == nil or b < 0x80 or 0x9F < b then return nil, i
      elseif c == nil or c < 0x80 or 0xBF < c then return nil, i
      else i = i + 3 end
    elseif 0xEE == a or 0xEF == a then
      if b == nil or b < 0x80 or 0xBF < b then return nil, i
      elseif c == nil or c < 0x80 or 0xBF < c then return nil, i
      else i = i + 3 end
    elseif 0xF0 == a then
      if b == nil or b < 0x90 or 0xBF < b then return nil, i
      elseif c == nil or c < 0x80 or 0xBF < c then return nil, i
      elseif d == nil or d < 0x80 or 0xBF < d then return nil, i
      else i = i + 4 end
    elseif 0xF1 <= a and a <= 0xF3 then
      if b == nil or b < 0x80 or 0xBF < b then return nil, i
      elseif c == nil or c < 0x80 or 0xBF < c then return nil, i
      elseif d == nil or d < 0x80 or 0xBF < d then return nil, i
      else i = i + 4 end
    elseif 0xF4 == a then
      if b == nil or b < 0x80 or 0x8F < b then return nil, i
      elseif c == nil or c < 0x80 or 0xBF < c then return nil, i
      elseif d == nil or d < 0x80 or 0xBF < d then return nil, i
      else i = i + 4 end
    else
      return nil, i
    end
    result = result + 1
  end
  return result
end

local function len_(s, i, j)
  if i == nil then
    i = 1
  end
  if j == nil then
    j = -1
  end
  if j < 0 then
    j = #s + j + 1
  end
  local result = 0
  while i <= j do
    -- local a, b, c, d = string.byte(s, i, i + 3)
    local a = string.byte(s, i)
    if a == nil then
      return nil, i
    end
    if 0x00 <= a and a <= 0x7F then
      i = i + 1
    elseif 0xC2 <= a and a <= 0xDF then
      -- [\x80-\xBF]
      if not s:match("^[\128-\191]", i + 1) then return nil, i end
      i = i + 2
    elseif 0xE0 == a then
      -- [\xA0-\xBF][\x80-\xBF]
      if not s:match("^[\160-\191][\128-\191]", i + 1) then return nil, i end
      i = i + 3
    elseif 0xE1 <= a and a <= 0xEC then
      -- [\x80-\xBF][\x80-\xBF]
      if not s:match("^[\128-\191][\128-\191]", i + 1) then return nil, i end
      i = i + 3
    elseif 0xED == a then
      -- [\x80-\x9F][\x80-\xBF]
      if not s:match("^[\128-\159][\128-\191]", i + 1) then return nil, i end
      i = i + 3
    elseif 0xEE == a or 0xEF == a then
      -- [\x80-\xBF][\x80-\xBF]
      if not s:match("^[\128-\191][\128-\191]", i + 1) then return nil, i end
      i = i + 3
    elseif 0xF0 == a then
      -- [\x90-\xBF][\x80-\xBF][\x80-\xBF]
      if not s:match("^[\144-\191][\128-\191][\128-\191]", i + 1) then return nil, i end
      i = i + 4
    elseif 0xF1 <= a and a <= 0xF3 then
      -- [\x80-\xBF][\x80-\xBF][\x80-\xBF]
      if not s:match("^[\128-\191][\128-\191][\128-\191]", i + 1) then return nil, i end
      i = i + 4
    elseif 0xF4 == a then
      -- [\x80-\x8F][\x80-\xBF][\x80-\xBF]
      if not s:match("^[\128-\143][\128-\191][\128-\191]", i + 1) then return nil, i end
      i = i + 4
    else
      return nil, i
    end
    result = result + 1
  end
  return result
end

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
