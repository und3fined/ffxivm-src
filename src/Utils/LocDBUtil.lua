
local LocDBMgr = require("DB/LocDBMgr")

---@class LocDBUtil
local LocDBUtil = {

}

function LocDBUtil.FindValue(TableName, Key, ColumnName)
	return LocDBMgr.FindValue(TableName, Key, ColumnName)
end

return LocDBUtil
