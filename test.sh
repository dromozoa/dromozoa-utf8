#! /bin/sh -e

# Copyright (C) 2017 Tomoyuki Fujimori <moyu@dromozoa.com>
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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dromozoa-utf8.  If not, see <http://www.gnu.org/licenses/>.

case x$1 in
  x) lua=lua;;
  *) lua=$1;;
esac

LUA_PATH="?.lua;;"
export LUA_PATH

for i in test/test*.lua
do
  "$lua" "$i"
done

mkdir -p out

for i in test/table*.md
do
  name=`expr "x$i" : 'xtest/\(.*\)\.md$'`
  "$lua" dromozoa-markdown-table <"$i" >"out/$name-01.md"
  "$lua" dromozoa-markdown-table <"out/$name-01.md" >"out/$name-02.md"
  diff -u "test/$name.exp" "out/$name-01.md"
  diff -u "test/$name.exp" "out/$name-02.md"
done

rm -f -r out
