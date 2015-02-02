#! /usr/bin/env lua

assert(utf8)
local pure = require "dromozoa.utf8.pure"
local unpack = table.unpack or unpack

local char
local charpattern
if arg[1] == "native" then
  char = utf8.char
  charpattern = utf8.charpattern
else
  char = pure.char
  charpattern = pure.charpattern
end

local function result(result, ...)
  if result then
    print(true, ...)
  else
    print(false)
    -- print(false, ...)
  end
end

local codepoint = {
  0x0041, 0x2262, 0x0391, 0x002E,
  0xD55C, 0xAD6D, 0xC5B4,
  0x65E5, 0x672C, 0x8A9E,
  0xFEFF, 0x0233B4,
}

result(pcall(char))
print "?"
result(pcall(char, unpack(codepoint)))
result(pcall(char, -1))
result(pcall(char, 0x110000))
result(pcall(char, nil))
result(pcall(char, "21"))
print(string.format("%q", charpattern))
