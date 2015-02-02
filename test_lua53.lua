#! /usr/bin/env lua

assert(utf8)
local pure = require "dromozoa.utf8.pure"

local len
local codepoint
local codes
if arg[1] == "native" then
  len = utf8.len
  codes = utf8.codes
  codepoint = utf8.codepoint
else
  len = pure.len
  codes = pure.codes
  codepoint = pure.codepoint
end

local function print_result(result, ...)
  if result then
    print(true, ...)
  else
    print(false)
  end
end

local utf8_char = string.char(
  0x41,
  0xE2, 0x89, 0xA2,
  0xCE, 0x91,
  0x2E,
  0xED, 0x95, 0x9C,
  0xEA, 0xB5, 0xAD,
  0xEC, 0x96, 0xB4,
  0xE6, 0x97, 0xA5,
  0xE6, 0x9C, 0xAC,
  0xE8, 0xAA, 0x9E,
  0xEF, 0xBB, 0xBF,
  0xF0, 0xA3, 0x8E, 0xB4
)

local utf8_len = 12

print("--")
print_result(pcall(len, utf8_char, 0))
print_result(pcall(len, utf8_char, #utf8_char + 1))
print_result(pcall(len, utf8_char, #utf8_char + 2))
print_result(pcall(len, utf8_char, -#utf8_char - 1))

print("--")
for i = 1, #utf8_char + 1 do
  print(i, len(utf8_char, i))
end
print("--")
for i = -1, -#utf8_char, -1 do
  print(i, len(utf8_char, i))
end

print("--")
print(len(""))
print(len(string.char(0xE2)))
print(len(string.char(0xE2, 0x89)))
print(len(string.char(0xE2, 0x89, 0xA2)))
print(len(string.char(0xE2, 0x00)))
print(len(string.char(0xE2, 0x89, 0x00)))
print(len(string.char(0xE2, 0xFF)))
print(len(string.char(0xE2, 0x89, 0xFF)))

print("--")
for p, c in codes("") do
  print(p, c)
end
print("--")
for p, c in codes(utf8_char) do
  print(p, c)
end
print("--")
print_result(pcall(function()
  for p, c in codes(string.char(0x41, 0xE2)) do
    print(p, c)
  end
end))

print("--")
print(codepoint(utf8_char, 1, #utf8_char))

print("--")
print_result(pcall(codepoint, ""))
print_result(pcall(codepoint, utf8_char, 0))
print_result(pcall(codepoint, utf8_char, #utf8_char + 1))
print_result(pcall(codepoint, utf8_char, #utf8_char + 2))
print_result(pcall(codepoint, utf8_char, -#utf8_char - 1))

print("--")
for i = 1, #utf8_char do
  io.write(i, "\t")
  print_result(pcall(codepoint, utf8_char, i))
end

print("--")
for i = -1, -#utf8_char, -1 do
  io.write(i, "\t")
  print_result(pcall(codepoint, utf8_char, i))
end

