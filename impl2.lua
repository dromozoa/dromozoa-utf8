local unpack = table.unpack or unpack

local decode1
local decode2
local decode3

do
  local function compile(expr)
    local result = {}

    for i = 1, #expr do
      local length = #expr[i] / 2
      local bmin, bmax, cmin, cmax, dmin, dmax = unpack(expr[i], 3)
      local code
      if length == 1 then
        code = function (a)
          return 1, a
        end
      elseif length == 2 then
        code = function (a, b)
          if b == nil or b < bmin or bmax < b then return nil end
          local a = a % 0x20 * 0x40
          local b = b % 0x40
          return 2, a + b
        end
      elseif length == 3 then
        code = function (a, b, c)
          if b == nil or b < bmin or bmax < b then return nil end
          if c == nil or c < cmin or cmax < c then return nil end
          local a = a % 0x20 * 0x1000
          local b = b % 0x40 * 0x40
          local c = c % 0x40
          return 3, a + b + c
        end
      elseif length == 4 then
        code = function (a, b, c, d)
          if b == nil or b < bmin or bmax < b then return nil end
          if c == nil or c < cmin or cmax < c then return nil end
          if d == nil or d < dmin or dmax < d then return nil end
          local a = a % 0x20 * 0x040000
          local b = b % 0x40 * 0x1000
          local c = c % 0x40 * 0x40
          local d = d % 0x40
          return 4, a + b + c
        end
      end

      for j = expr[i][1], expr[i][2] do
        result[j] = { length, code }
      end
    end

    return function (s, i)
      local a = s:byte(i)
      if a == nil then
        return nil
      end
      local item = result[a]
      if item == nil then
        return nil
      end
      return item[2](a, s:byte(i + 1, i + item[1]))
    end
  end

  decode1 = compile {
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
end

do
  decode2 = function (s, i)
    local a = s:byte(i)
    if a == nil then
      return nil, i
    end
    if a <= 0x7F then
      return 1
    elseif a <= 0xDF then
      return 2
    elseif a <= 0xEF then
      return 3
    else
      return 4
    end
  end
end

do
  local lpeg = require "lpeg"

  local function R(a, b)
    if b == nil then
      return lpeg.P(string.char(a))
    else
      return lpeg.R(string.char(a, b))
    end
  end
  local Cc = lpeg.Cc

  local UTF8_tail = R(0x80, 0xBF)
  local UTF8_1 = R(0x00, 0x7F)
  local UTF8_2 = R(0xC2, 0xDF) * UTF8_tail
  local UTF8_3
    = R(0xE0) * R(0xA0, 0xBF) * UTF8_tail + R(0xE1, 0xEC) * UTF8_tail * UTF8_tail
    + R(0xED) * R(0x80, 0x9F) * UTF8_tail + R(0xEE, 0xEF) * UTF8_tail * UTF8_tail
  local UTF8_4
    = R(0xF0) * R(0x90, 0xBF) * UTF8_tail * UTF8_tail
    + R(0xF1, 0xF3) * UTF8_tail * UTF8_tail * UTF8_tail
    + R(0xF4) * R(0x80, 0x8F) * UTF8_tail * UTF8_tail
  local UTF8_char
    = UTF8_1 * Cc(1)
    + UTF8_2 * Cc(2)
    + UTF8_3 * Cc(3)
    + UTF8_4 * Cc(4)

  local decoder3 = function (s, i)
    return UTF8_char:match(s, i)
  end
end

return function (name)
  if name == "native" then
    return utf8.len
  else
    local fn
    if name == "decode1" then
      fn = decode1
    elseif name == "decode2" then
      fn = decode2
    elseif name == "decode3" then
      fn = decode3
    end
    return function (s)
      local i = 1
      local j = #s
      local length = 0
      while i <= j do
        local k, c = decode1(s, i)
        if k == nil then
          return nil, i
        else
          i = i + k
          length = length + 1
        end
      end
      return length
    end
  end
end
