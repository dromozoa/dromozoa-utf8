

local unpack = table.unpack or unpack

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
        return 3, a + b + c
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

local decode = compile {
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

print(decode("a", 1))
print(decode("あ", 1))
-- print(utf8.len(string.char(0xED, 0xA1, 0x8C)))
print(decode(string.char(0xED, 0xA1, 0x8C), 1))
print(decode(string.char(0xFF), 1))
print(decode(string.char(0xF0, 0x90, 0x80, 0x80), 1))
print(decode(string.char(0xF0, 0xA3, 0x8E, 0xB4), 1))
