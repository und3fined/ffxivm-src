

--local math = _G.math

local M = {}

--- @return v ranges [min, max]
function M.clamp(v, min, max)
    if v < min then
        return min
    elseif v > max then
        return max
    else
        return v
    end
end

math.clamp = M.clamp

return M