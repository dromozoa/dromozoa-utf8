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

local function quote(v)
  local t = type(v)
  if t == "nil" then
    return "nil"
  elseif t == "number" then
    return ("%.17g"):format(v)
  elseif t == "string" then
    return ("%q"):format(v)
  elseif t == "boolean" then
    if v then
      return "true"
    else
      return "false"
    end
  else
    error("nil/number/string/boolean expected, got " .. t)
  end
end

local function compile(out, tree_class, tree_value, i, depth)
  local u = tree_value[i]
  local j = i * 2
  local k = j + 1

  local indent = ("  "):rep(depth)
  local depth = depth + 1

  if tree_class[k] == "node" then
    out:write(indent, "if c < ", quote(u), " then\n")
    compile(out, tree_class, tree_value, j, depth)
    out:write(indent, "else\n")
    compile(out, tree_class, tree_value, k, depth)
    out:write(indent, "end\n")
  elseif tree_class[j] == "node" then
    local w = tree_value[k]
    out:write(indent, "if c < ", quote(u), " then\n")
    compile(out, tree_class, tree_value, j, depth)
    out:write(indent, "else\n")
    out:write(indent, "  return ", quote(w), "\n")
    out:write(indent, "end\n")
  else
    local v = tree_value[j]
    local w = tree_value[k]
    if type(v) == "boolean" and type(w) == "boolean" then
      if v then
        out:write(indent, "return c < ", quote(u), "\n")
      else
        out:write(indent, "return c >= ", quote(u), "\n")
      end
    else
      out:write(indent, "if c < ", quote(u), " then return ", quote(v), " else return ", quote(w), " end\n")
    end
  end
end

local class = {}
local metatable = { __index = class }

function class:range(first, last, value)
  local map = self.map
  for i = first, last do
    map[i] = value
  end
end

function class:build()
  local map = self.map
  local range_first = {}
  local range_value = {}
  local n = 0

  for i = 0, 0x10FFFF do
    local value = map[i]
    if value ~= range_value[n] then
      n = n + 1
      range_first[n] = i
      range_value[n] = value
    end
  end

  local m = n - 1
  local indice = {}
  for i = 1, m do
    indice[i] = i
  end

  local tree_class = {}
  local tree_value = {}

  local height = math.ceil(math.log(n) / math.log(2))
  for i = height, 0, -1 do
    local j = 2^i
    local k = 1
    local index = indice[k]
    while index and j <= m do
      tree_class[j] = "node"
      tree_value[j] = range_first[index + 1]
      table.remove(indice, k)
      j = j + 1
      k = k + 1
      index = indice[k]
    end
  end

  for i = 1, n do
    local first = range_first[i]
    local value = range_value[i]
    local j = 1
    while tree_class[j] == "node" do
      if first < tree_value[j] then
        j = j * 2
      else
        j = j * 2 + 1
      end
    end
    tree_class[j] = "leaf"
    tree_value[j] = value
  end

  return {
    range = {
      first = range_first;
      value = range_value;
    };
    tree = {
      class = tree_class;
      value = tree_value;
    };
  }
end

function class.compile(out, data)
  local tree = data.tree
  local buffer = {}
  out:write [[
return function (c)
  c = c + 0
]]
  compile(out, tree.class, tree.value, 1, 1)
  out:write "end\n"
  return out
end

return setmetatable(class, {
  __call = function (_, value)
    local map = {}
    for i = 0, 0x10FFFF do
      map[i] = value
    end
    return setmetatable({ map = map }, metatable)
  end;
})
