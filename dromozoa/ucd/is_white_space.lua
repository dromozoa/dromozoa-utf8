return function (c)
  c = c + 0
  if c < 8232 then
    if c < 161 then
      if c < 33 then
        if c < 14 then
          return c >= 9
        else
          return c >= 32
        end
      else
        if c < 134 then
          return c >= 133
        else
          return c >= 160
        end
      end
    else
      if c < 8192 then
        if c < 5761 then
          return c >= 5760
        else
          return false
        end
      else
        return c < 8203
      end
    end
  else
    if c < 8287 then
      if c < 8239 then
        return c < 8234
      else
        return c < 8240
      end
    else
      if c < 12288 then
        return c < 8288
      else
        return c < 12289
      end
    end
  end
end
