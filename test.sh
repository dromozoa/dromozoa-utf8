#! /bin/sh -e

# Copyright (C) 2017-2019,2023 Tomoyuki Fujimori <moyu@dromozoa.com>
#
# This file is part of dromozoa-utf8.
#
# dromozoa-utf8 is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# dromozoa-utf8 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dromozoa-utf8. If not, see <https://www.gnu.org/licenses/>.

LUA_PATH="?.lua;;"
export LUA_PATH

for i in test/test*.lua
do
  case X$# in
    X0) lua "$i";;
    *) "$@" "$i";;
  esac
done

mkdir -p out

for i in test/table*.exp
do
  name=`expr "X$i" : 'Xtest\(/.*\)\.exp$' | sed -e 's/^.//'`
  case X$# in
    X0)
      lua dromozoa-markdown-table <"test/$name.md" >"out/$name-01.md"
      lua dromozoa-markdown-table <"out/$name-01.md" >"out/$name-02.md";;
    *)
      "$@" dromozoa-markdown-table <"test/$name.md" >"out/$name-01.md"
      "$@" dromozoa-markdown-table <"out/$name-01.md" >"out/$name-02.md";;
  esac
  diff -u "test/$name.exp" "out/$name-01.md"
  diff -u "test/$name.exp" "out/$name-02.md"
done

for i in test/table*.[ct]sv
do
  name=`expr "X$i" : 'Xtest\(/.*\)\.[ct]sv$' | sed -e 's/^.//'`
  mode=`expr "X$i" : 'Xtest/.*.\([ct]sv\)$'`
  case X$# in
    X0)
      lua dromozoa-markdown-table "--$mode" <"test/$name.md" >"out/$name.$mode";;
    *)
      "$@" dromozoa-markdown-table "--mode" <"test/$name.md" >"out/$name.$mode";;
  esac
  diff -u "test/$name.csv" "out/$name.$mode"
done

rm -f -r out test.exp
