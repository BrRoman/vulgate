local concat, remove = table.concat, table.remove

local html = {
  __index = function(self, k)
    return function(...)
      local ct, props = {}, {}
      for i = 1, select('#', ...) do
        local arg = select(i, ...)
        local arg_type = type(arg)
        if arg_type == "table" then
          while #arg > 0 do
            ct[#ct + 1] = remove(arg, 1)
          end
          for _k, _v in pairs(arg) do
            props[#props + 1] = " " .. tostring(_k) .. "=\"" .. tostring(_v) .. "\""
          end
        elseif arg_type == "function" then
          ct[#ct + 1] = arg()
        elseif arg_type == "string" or arg_type == "number" then
          ct[#ct + 1] = arg
        end
      end

      if #ct == 0 then
        return "<" .. tostring(k) .. tostring(concat(props)) .. "/>"
      else
        return "<" .. tostring(k) .. tostring(concat(props)) .. ">" ..
          tostring(concat(ct, '\n')) ..
          "</" .. tostring(k) .. ">"
      end
    end
  end
}

return setmetatable(html, html)
