local M = {}

local function V2K(T, V)
    return T._V2K[V]
end

function M.New()
    local Ret = {}
    Ret._K2V = {}
    Ret._V2K = {}

    local MT = {
        __index = Ret._K2V,

        __newindex = function(T, K, V)
            if T._V2K[V] then
                _G.FLOG_ERROR(string.format("ERROR: DoubleMap This Value exist! Value = %s, NewKey = %s, OldKey = %s", 
                    tostring(V), tostring(K), tostring(T._V2K[V])))
                return
            end

            local OldValue = T._K2V[K]
            if OldValue ~= nil then
                T._V2K[OldValue] = nil
            end

            T._K2V[K] = V
            T._V2K[V] = K
        end
    }

    setmetatable(Ret, MT)

    Ret.V2K = V2K

    return Ret
end

return M