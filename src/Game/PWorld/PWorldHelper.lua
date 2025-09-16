

---@class PWorldHelper
local PWorldHelper = {}

---@deprecated
--- GetPWorldText
---@param Key string
---@return string
function PWorldHelper.GetPWorldText(Key)
    local FubenTextCfg = require("TableCfg/FubenTextCfg")
    return (FubenTextCfg:FindCfg(string.sformat("ID = '%s'", Key)) or {}).Content or ""
end

---@deprecated
---@param Key string
---@param ... any
---@return string
function PWorldHelper.pformat(Key, ...)
    return string.sformat(PWorldHelper.GetPWorldText(Key), ...)
end


return PWorldHelper