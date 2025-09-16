
local CommonUtil = require("Utils/CommonUtil")

local ULocDBMgr = _G.UE.ULocDBMgr.Get()
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_WARNING = _G.FLOG_WARNING

local LocDBMgr = {}

function LocDBMgr.Init()
    ULocDBMgr = _G.UE.ULocDBMgr.Get()
end

---FindValue
---@param TableName string
---@param Key string
---@param ColumnName string
---@return string
function LocDBMgr.FindValue(TableName, Key, ColumnName)
    if nil == ULocDBMgr then
        FLOG_ERROR("LocDBMgr.FindValue, ULocDBMgr is nil")
        return Key
    end

    Key = string.gsub(Key, '"', '""')
	local SearchConditions = string.format('ukey="%s"', Key)

    local _ <close> = CommonUtil.MakeProfileTag(string.format("LocDBMgr.FindValue_%s", TableName))
    local LocStr = ULocDBMgr:FindValue(TableName, SearchConditions, ColumnName)
    if string.isnilorempty(LocStr) then
        FLOG_WARNING("LocDBMgr.FindValue, LocStr is nilorempty, TableName = %s, Key = %s, ColumnName = %s", TableName, Key, ColumnName)
    end

    return LocStr
end

return LocDBMgr