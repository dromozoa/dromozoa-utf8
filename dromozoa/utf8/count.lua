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

local counter = require "dromozoa.utf8.counter"

local byte = string.byte

local S = counter.S
local E = counter.E

return function (s, i, j)
  local t = type(s)
  if t ~= "string" then
    if t == "number" then
      s = tostring(s)
    else
      error("bad argument #1 to 'dromozoa.utf8.count' (string expected, got " ..  t .. ")")
    end
  end

  local n = #s

  if not i then
    i = 1
  else
    local m = n + 1
    if i < 0 then
      i = m + i
    end
    if i < 1 or m < i then
      error "bad argument #2"
    end
  end

  if not j then
    j = n
  else
    if j < 0 then
      j = n + 1 + j
    end
    if n < j then
      error "bad argument #3"
    end
  end

  if i > j then
    return 0
  end

  local s1 = S
  local result = 0
  for i = i + 3, j, 4 do
    if s1 == S then result = result + 1 end
    local a, b, c, d = byte(s, i - 3, i)
    local s2 = s1[a]
    local s3 = s2[b]
    local s4 = s3[c]
    s1 = s4[d]
    if s1 == E then
      if s2 == E then return nil, i - 3 end
      if s3 == E then return nil, i - 2 end
      if s4 == E then return nil, i - 1 end
      return nil, i
    end
    if s2 == S then result = result + 1 end
    if s3 == S then result = result + 1 end
    if s4 == S then result = result + 1 end
  end

  local p = j + 1
  local m = p - (p - i) % 4
  if m < p then
    if s1 == S then result = result + 1 end
    local a, b, c = byte(s, m, j)
    if c then
      local s2 = s1[a]
      local s3 = s2[b]
      local s4 = s3[c]
      if s4 == E then
        if s2 == E then return nil, j - 2 end
        if s3 == E then return nil, j - 1 end
        return nil, j
      end
      if s2 == S then result = result + 1 end
      if s3 == S then result = result + 1 end
    elseif b then
      local s2 = s1[a]
      local s3 = s2[b]
      if s3 == E then
        if s2 == E then return nil, j - 1 end
        return nil, j
      end
      if s2 == S then result = result + 1 end
    else
      local s2 = s1[a]
      if s2 == E then return nil, j end
    end
  end

  return result
end
