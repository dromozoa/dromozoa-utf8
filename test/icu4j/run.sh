#! /bin/sh -e

# Copyright (C) 2018,2023 Tomoyuki Fujimori <moyu@dromozoa.com>
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

jar=target/icu4j-1.0-jar-with-dependencies.jar

java -jar "$jar" EAST_ASIAN_WIDTH >../test_east_asian_width.txt
java -jar "$jar" WHITE_SPACE >../test_is_white_space.txt
java -jar "$jar" GENERAL_CATEGORY >../test_general_category.txt
