// Copyright (C) 2017,2018,2023 Tomoyuki Fujimori <moyu@dromozoa.com>
//
// This file is part of dromozoa-utf8.
//
// dromozoa-utf8 is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// dromozoa-utf8 is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with dromozoa-utf8. If not, see <https://www.gnu.org/licenses/>.

package com.dromozoa.utf8;

import java.util.*;
import com.ibm.icu.lang.*;

public class Application {
  private static class Range {
    public final int first;
    public int last;
    public final String property;

    public Range(int codePoint, String property) {
      first = codePoint;
      last = codePoint;
      this.property = property;
    }
  }

  private static String getPropertyString(int codePoint, String name) {
    if (name.equals("EAST_ASIAN_WIDTH")) {
      switch (UCharacter.getIntPropertyValue(codePoint, UProperty.EAST_ASIAN_WIDTH)) {
        case UCharacter.EastAsianWidth.AMBIGUOUS:
          return "A";
        case UCharacter.EastAsianWidth.FULLWIDTH:
          return "F";
        case UCharacter.EastAsianWidth.HALFWIDTH:
          return "H";
        case UCharacter.EastAsianWidth.NEUTRAL:
          return "N";
        case UCharacter.EastAsianWidth.NARROW:
          return "Na";
        case UCharacter.EastAsianWidth.WIDE:
          return "W";
      }
    } else if (name.equals("WHITE_SPACE")) {
      return Boolean.toString(UCharacter.hasBinaryProperty(codePoint, UProperty.WHITE_SPACE));
    } else if (name.equals("GENERAL_CATEGORY")) {
      switch (UCharacter.getType(codePoint)) {
        case UCharacterCategory.UNASSIGNED:
          return "Cn";
        case UCharacterCategory.UPPERCASE_LETTER:
          return "Lu";
        case UCharacterCategory.LOWERCASE_LETTER:
          return "Ll";
        case UCharacterCategory.TITLECASE_LETTER:
          return "Lt";
        case UCharacterCategory.MODIFIER_LETTER:
          return "Lm";
        case UCharacterCategory.OTHER_LETTER:
          return "Lo";
        case UCharacterCategory.NON_SPACING_MARK:
          return "Mn";
        case UCharacterCategory.ENCLOSING_MARK:
          return "Me";
        case UCharacterCategory.COMBINING_SPACING_MARK:
          return "Mc";
        case UCharacterCategory.DECIMAL_DIGIT_NUMBER:
          return "Nd";
        case UCharacterCategory.LETTER_NUMBER:
          return "Nl";
        case UCharacterCategory.OTHER_NUMBER:
          return "No";
        case UCharacterCategory.SPACE_SEPARATOR:
          return "Zs";
        case UCharacterCategory.LINE_SEPARATOR:
          return "Zl";
        case UCharacterCategory.PARAGRAPH_SEPARATOR:
          return "Zp";
        case UCharacterCategory.CONTROL:
          return "Cc";
        case UCharacterCategory.FORMAT:
          return "Cf";
        case UCharacterCategory.PRIVATE_USE:
          return "Co";
        case UCharacterCategory.SURROGATE:
          return "Cs";
        case UCharacterCategory.DASH_PUNCTUATION:
          return "Pd";
        case UCharacterCategory.START_PUNCTUATION:
          return "Ps";
        case UCharacterCategory.END_PUNCTUATION:
          return "Pe";
        case UCharacterCategory.CONNECTOR_PUNCTUATION:
          return "Pc";
        case UCharacterCategory.OTHER_PUNCTUATION:
          return "Po";
        case UCharacterCategory.MATH_SYMBOL:
          return "Sm";
        case UCharacterCategory.CURRENCY_SYMBOL:
          return "Sc";
        case UCharacterCategory.MODIFIER_SYMBOL:
          return "Sk";
        case UCharacterCategory.OTHER_SYMBOL:
          return "So";
        case UCharacterCategory.INITIAL_PUNCTUATION:
          return "Pi";
        case UCharacterCategory.FINAL_PUNCTUATION:
          return "Pf";
      }
      System.err.println("invalid code " + codePoint + " " + UCharacter.getType(codePoint));
    }
    throw new RuntimeException();
  }

  public static void main(String[] args) {
    String name = "EAST_ASIAN_WIDTH";
    int codePointFirst = 0;
    int codePointLast = 0x10FFFF;

    if (args != null) {
      if (args.length > 0) {
        name = args[0];
      }
      if (args.length > 1) {
        codePointFirst = Integer.parseInt(args[1], 16);
      }
      if (args.length > 2) {
        codePointLast = Integer.parseInt(args[2], 16);
      }
    }

    List<Range> ranges = new ArrayList<>();
    for (int codePoint = codePointFirst; codePoint <= codePointLast; ++codePoint) {
      String property = getPropertyString(codePoint, name);
      if (!ranges.isEmpty()) {
        Range range = ranges.get(ranges.size() - 1);
        if (range.property == property) {
          if (range.last != codePoint - 1) {
            throw new RuntimeException();
          }
          range.last = codePoint;
          continue;
        }
      }
      ranges.add(new Range(codePoint, property));
    }

    for (Range range : ranges) {
      System.out.println(range.first + "\t" + range.last + "\t" + range.property);
    }
  }
}
