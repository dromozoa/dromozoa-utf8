#! /usr/bin/env lua

io.write [[
-- This file was auto-generated.
]]

for i = 1, #arg do
  local path = arg[i]
  local name = arg[i]:gsub("/", "."):gsub("%.lua$", "")
  io.write(string.format([[
package.loaded[%q] = (function ()
-- ===========================================================================
-- %s
-- ===========================================================================
]], path, name))

  local handle = assert(io.open(path))
  io.write(handle:read("*a"))
  handle:close()
  io.write [[
-- ===========================================================================
end)()
]]
end
