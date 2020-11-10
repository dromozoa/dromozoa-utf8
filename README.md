# dromozoa-utf8

Lua 5.3 compatible pure-Lua UTF-8 implementation.
Currently, `lax` optional argument introduced in Lua 5.4 is not supported.

## v1.16

* Unicode 13.0
* Lua 5.4 like error messages

## v1.15

* performance improvement

## v1.14

* Unicode 12.1

## v1.13

* Unicode 12.0

## v1.12

* Unicode 11.0

## v1.11

* maintenance release

## v1.10

* new function `dromozoa.ucd.general_category`

## v1.9

* new module `dromozoa.ucd`
* new module `dromozoa.utf16`

## v1.8

* new function `dromozoa.ucd.is_white_space`

## v1.7

* maintenance release

## v1.6

* new utility `dromozoa-markdown-table`
* new module `dromozoa.ucd.builder`

## v1.5

* new function `dromozoa.ucd.east_asian_width`
* new function `dromozoa.utf16.decode_surrogate_pair`

## v1.4

### Features

* table-based performance improvement
* almost compatible argument check
* strict UTF-8 encoding check (do not accept CESU-8)

### Performance Improvement

| Function                 | Improvement Ratio |
|--------------------------|------------------:|
| `utf8.char`              |               9.9 |
| `utf8.codes`             |               1.8 |
| `utf8.codepoint`         |               1.8 |
| `utf8.len`               |               1.5 |
| `utf8.offset` (positive) |               3.3 |
| `utf8.offset` (negative) |               2.3 |

### Memory Usage

| Version |  ILP32 | LP64/LLP64 |
|---------|-------:|-----------:|
| v1.3    |   9KiB |      10KiB |
| v1.4    | 232KiB |     274KiB |
