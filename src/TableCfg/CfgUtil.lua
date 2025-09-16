--
-- Author: anypkvcai
-- Date: 2024-05-08 15:56
-- Description:
--


local PathMgr = require("Path/PathMgr")
local CommonUtil = require("Utils/CommonUtil")

local MatchedDataCode = '\
function _GetMatchedData(LuaData)\
    local Cfg\
    for i = 1, #LuaData do\
        Cfg = LuaData[i]\
        if %s then\
            return Cfg\
        end\
    end\
end'

local AllMatchedDataCode = '\
function _GetAllMatchedData(LuaData)\
    local AllCfg = {}\
    local Count = 1\
    local Cfg\
    for i = 1, #LuaData do\
        Cfg = LuaData[i]\
        if %s then\
            AllCfg[Count] = Cfg\
            Count = Count + 1\
        end\
    end\
    return AllCfg\
end'

local MatchPattern1 = '%s+AND%s+'
local MatchPattern2 = '%s+OR%s+'
local MatchPattern3 = '!='
local MatchPattern4 = '[^<>~=]=[^=]'
local MatchPattern5 = '[%w_]+%s*[<>~=]=?%s*[\'"]*%s*[%w%-_]*[\'"]*'

local MatchRepl1 = ' and '
local MatchRepl2 = ' or '
local MatchRepl3 = ' ~= '

--MatchRepl4
---@param Match string
---@private
local function MatchRepl4(Match)
	return string.gsub(Match, "=", "==")
end

--MatchRepl5
---@param Match string
---@private
local function MatchRepl5(Match)
	return string.format("Cfg.%s", Match)
end

local function GetLuaData(TableCfg)
	return rawget(TableCfg, "LuaData")
end

local function GetLuaDataBin()

end

local function GetDefaultValues(TableCfg)
	return rawget(TableCfg, "DefaultValues")
end

local function GetDefaultValuesBin()

end

---@class CfgUtil
local CfgUtil = {

}

local bEngineBin = false
if CommonUtil.IsWithEditor() then
	bEngineBin = nil ~= string.find(PathMgr.ContentDir(), "Engine_bin")
end

CfgUtil.GetLuaData = bEngineBin and GetLuaDataBin or GetLuaData
CfgUtil.GetDefaultValues = bEngineBin and GetDefaultValuesBin or GetDefaultValues

---GetAllMatchedData @查找和Table的中和表达式匹配的数据
---@param LuaData table @要判断的表 例如：{A = 1, B = 2, C = 3}
---@param Expression string @要判断的表达式 例如：“A = 1 and B = 2 and C > 0”, 表达式里不要有AND或OR命名的变量
function CfgUtil.GetMatchedData(LuaData, Expression)
	if type(Expression) ~= "string" then
		return
	end

	Expression = string.gsub(Expression, MatchPattern1, MatchRepl1)
	Expression = string.gsub(Expression, MatchPattern2, MatchRepl2)
	Expression = string.gsub(Expression, MatchPattern3, MatchRepl3)
	Expression = string.gsub(Expression, MatchPattern4, MatchRepl4)
	Expression = string.gsub(Expression, MatchPattern5, MatchRepl5)

	local Fun = load(string.format(MatchedDataCode, Expression), "GetMatchedData", "t", CfgUtil)
	if nil == Fun then
		return
	end

	Fun()

	return CfgUtil._GetMatchedData(LuaData)
end

---GetAllMatchedData @查找和Table的中所有和表达式匹配的数据
---@param LuaData table @要判断的表 例如：{A = 1, B = 2, C = 3}
---@param Expression string @要判断的表达式 例如：“A = 1 and B = 2 and C > 0”, 表达式里不要有AND或OR命名的变量
function CfgUtil.GetAllMatchedData(LuaData, Expression)
	if type(Expression) ~= "string" then
		return {}
	end

	Expression = string.gsub(Expression, MatchPattern1, MatchRepl1)
	Expression = string.gsub(Expression, MatchPattern2, MatchRepl2)
	Expression = string.gsub(Expression, MatchPattern3, MatchRepl3)
	Expression = string.gsub(Expression, MatchPattern4, MatchRepl4)
	Expression = string.gsub(Expression, MatchPattern5, MatchRepl5)

	local Fun = load(string.format(AllMatchedDataCode, Expression), "GetAllMatchedData", "t", CfgUtil)
	if nil == Fun then
		return {}
	end

	Fun()

	return CfgUtil._GetAllMatchedData(LuaData)
end

return CfgUtil