--
-- Author: anypkvcai
-- Date: 2020-11-20 09:40:22
-- Description: DB相关
-- Wiki: https://iwiki.woa.com/pages/viewpage.action?pageId=463586518
--

local DBMgr = require("DB/DBMgr")
local Json = require("Core/Json")

---@class DBUtil
local DBUtil = {

}

---FindValue                        @查找某个配置值
---@param TableName string          @TableName
---@param SearchConditions string   @SQL
---@return any                      @表里配置的值
function DBUtil.FindValue(TableName, SearchConditions, ColumnName)
	local Cfg = DBUtil.FindCfg(TableName, SearchConditions)
	if nil == Cfg then
		return
	end

	return Cfg[ColumnName]
end

---FindCfg                        @查找某行配置
---@param TableName string          @TableName
---@param SearchConditions string   @SQL
function DBUtil.FindCfg(TableName, SearchConditions)
	return DBMgr.SelectOneRow(TableName, SearchConditions)
end

---FindAllCfg                       @查找所有行配置
---@param TableName string          @TableName
---@param SearchConditions string   @SQL
---@return table                    @{{ColumnNameA=A, ColumnNameB=B},{ColumnNameA=A, ColumnNameB=B}, ...}
function DBUtil.FindAllCfg(TableName, SearchConditions)
	return DBMgr.SelectAllRow(TableName, SearchConditions)
end

---TranslateDBStr                    @把数组类型字符串转为table
---@param Cfg table
---@return table
function DBUtil.TranslateDBStr(Cfg)
	if nil == Cfg then
		return
	end

	for k, v in pairs(Cfg) do
		if type(v) == "string" then
			Cfg[k] = DBUtil.ParseStr(v)
		end
	end
end

---ParseStr
---@param Str string
---@return table | string
function DBUtil.ParseStr(Str)
	--if nil == string.find(Str, "^{[%S%s]*}$") and nil == string.find(Str, "^%[[%S%s]*%]$") then
	--	return Str
	--end

	if "[]" == Str or "{}" == Str or string.len(Str) <= 0 then
		return {}
	end

	local _ <close> = CommonUtil.MakeProfileTag("DBUtil.ParseStr")

	return Json.decode(Str)
end

return DBUtil
