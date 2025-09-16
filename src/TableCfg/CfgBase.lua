---
--- Author: anypkvcai
--- DateTime: 2021-03-30 22:05
--- Description:
---

local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR

local DBUtil = require("Utils/DBUtil")
local CommonUtil = require("Utils/CommonUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local CfgUtil = require("TableCfg/CfgUtil")
local CfgLruCacheConfig = require("Define/CfgLruCacheConfig")
local DefaultLruSize = CfgLruCacheConfig.DefaultSize

local FLuaLruCache = _G.UE.FLuaLruCache
local FLuaLruCache_StrKey = _G.UE.FLuaLruCache_StrKey
local UDBMgr = _G.UE.UDBMgr

--数据库中不存在的数据
local NotExist = {}

---@class CfgBase
---@field TableName string
---@field LruKeyType string
---@field bLruEnabled boolean
---@field KeyName string
---@field DBData table<number, table> @查询DB后缓存的数据
---@field Localization table @本地化相关配置
---@field DefaultValues table @Lua表默认值，次数最多的值会作为默认值
---@field LuaData table<table> @lua数据，对于要遍历或特别小的表，转表会生成lua表（数据库默认也会生成，但不不会读取）
---@field KeyToDataIndex table<number, number> @通过key值获取Index
local CfgBase = {
}

---FindValue    @通过KeyName的值查找ColumnName的值
---@param Key number
---@param ColumnName string
---@return any | nil
function CfgBase:FindValue(Key, ColumnName)
	local Cfg = self:FindCfgByKey(Key)
	if nil == Cfg then
		return
	end

	return Cfg[ColumnName]
end

---FindCfgByKey    @通过KeyName的值查找整行的值 推荐使用这个函数 查找后数据会缓存
---@param Key number
---@return table<string,table> | nil
function CfgBase:FindCfgByKey(Key)
	if nil == Key then
		return
	end

	local LuaData = CfgUtil.GetLuaData(self)
	local KeyToDataIndex = rawget(self, "KeyToDataIndex")
	if LuaData then
		if nil == KeyToDataIndex then
			local KeyName = self.KeyName
			KeyToDataIndex = {}
			for i = 1, #LuaData do
				local KeyValue = LuaData[i][KeyName]
				if nil ~= KeyValue then
					KeyToDataIndex[KeyValue] = i
				else
					FLOG_ERROR(string.format("CfgBase:FindCfgByKey Error, KeyName=%s", KeyName))
				end
			end
			self.KeyToDataIndex = KeyToDataIndex
		end

		return LuaData[KeyToDataIndex[Key]]
	end

	return self:FindDBCfgByKey(Key)
end

---FindCfg    @通过SQL条件查找整行的值,如果是通过Key值查找，推荐用FindCfgByKey, 非Key值或组合条件查找时才用这个函数
---@param SearchConditions string @ 后面需要遍历或比较小的表，会改用lua表，为了兼容之前的逻辑，支持了简单的比较SQL语句，例如："A = 1 and B = 2"，对ORDER BY、LIKE等特殊的SQL语句只能在数据库里使用
---@return table<string,table> | nil
function CfgBase:FindCfg(SearchConditions)
	local LuaData = CfgUtil.GetLuaData(self)
	if LuaData then
		--if "function" == type(SearchConditions) then
		--	return table.find_by_predicate(LuaData, SearchConditions)
		--end

		return CfgUtil.GetMatchedData(LuaData, SearchConditions)
	end

	local Cfg
	do
		local _ <close> = CommonUtil.MakeProfileTag(string.format("FindCfg_%s", self.TableName))
		Cfg = DBUtil.FindCfg(self.TableName, SearchConditions)
	end
	if nil == Cfg then
		return
	end

	self:UpdateDBCfgLocalizationInfo(Cfg)

	local Key = Cfg[self.KeyName]

	self:CacheDBCfg(Key, Cfg)

	return Cfg
end

---FindAllCfg @通过SQL条件查找所有符合条件的值 如果SearchConditions为nil 则获取表格所有内容 能不用尽量不要用!!!
---@param SearchConditions string | nil @ 后面需要遍历或比较小的表，会改用lua表，为了兼容之前的逻辑，支持了简单的比较SQL语句，例如："A = 1 and B = 2"，对ORDER BY、LIKE等特殊的SQL语句只能在数据库里使用
---@return table<number,table> | nil
function CfgBase:FindAllCfg(SearchConditions)
	local bSearchAll = false
	if nil == SearchConditions or "1=1" == SearchConditions or "true" == SearchConditions then
		SearchConditions = "1=1"
		bSearchAll = true
	end

	local LuaData = CfgUtil.GetLuaData(self)
	if LuaData then
		if bSearchAll then
			return LuaData
		end

		--if "function" == type(SearchConditions) then
		--	return table.find_all_by_predicate(LuaData, SearchConditions)
		--end

		return CfgUtil.GetAllMatchedData(LuaData, SearchConditions)
	end

	local AllCfg = DBUtil.FindAllCfg(self.TableName, SearchConditions)
	if nil == AllCfg then
		return {}
	end

	if bSearchAll then
		--需要遍历的表，先看下有其他方式避免不，如果无法避免，把需要遍历的数据拆出来, 在tablecfg.json里配置成lua表，会自动生成lua表性能更好
		FLOG_WARNING("CfgBase:FindAllCfg TableName=%s Count=%d, Designer/Table/config/tablecfg.json needs to be configured!", self.TableName, #AllCfg)
	end

	self:UpdateCfgListLocalizationInfo(AllCfg, true)

	local KeyName = self.KeyName
	for _, v in pairs(AllCfg) do
		local Key = v[KeyName]
		self:CacheDBCfg(Key, v)
	end

	return AllCfg
end

---FindDBCfgByKey    @通过KeyDB中查找整行的值
---@param Key number @ 一般是proto定义里有 org.xresloader.ue.key_tag 标记的那一列
---@return table<string,table> | nil
---@private
function CfgBase:FindDBCfgByKey(Key)
	local Cfg
	if self.bLruEnabled then
		Cfg = self.DBData:FindAndTouch(Key)
	else
		Cfg = self.DBData[Key]
	end
	if Cfg then
		return Cfg ~= NotExist and Cfg or nil
	end

	local _ <close> = CommonUtil.MakeProfileTag(string.format("FindDBCfgByKey_%s", self.TableName))
	local SearchConditions = string.format("%s = %s", self.KeyName, Key)
	Cfg = DBUtil.FindCfg(self.TableName, SearchConditions)
	self:UpdateDBCfgLocalizationInfo(Cfg)

	self:CacheDBCfg(Key, Cfg or NotExist)

	return Cfg
end

---CacheDBCfg
---@param Key number
---@param Value table
---@private
function CfgBase:CacheDBCfg(Key, Value)
	if nil == Key or nil == Value then
		return
	end

	if self.bLruEnabled then
		self.DBData:Add(Key, Value)
	else
		self.DBData[Key] = Value
	end
end

---ClearCache
---@private
function CfgBase:ClearDBCache()
	if self.bLruEnabled then
		self.DBData:Clear()
	else
		self.DBData = {}
	end
end

---Readonly
---@private
local function Readonly()
	FLOG_WARNING("Attempt to modify readonly data!")
	local Traceback = debug.traceback()
	FLOG_WARNING(Traceback)
	--CommonUtil.ReportCustomError("Attempt to modify readonly data!", Traceback, Traceback, true)
end

local function GetValue(t, k)
	local Config = getmetatable(t)
	if not Config then
		return
	end

	local Owner = rawget(Config, "Owner")
	if not Owner then
		return
	end

	local KeyName = Owner.KeyName
	local TableName = Owner.TableName

	local DefaultValues = CfgUtil.GetDefaultValues(Owner)
	local DefaultValue = DefaultValues and DefaultValues[k] or nil
	if DefaultValue then
		return DefaultValue
	end

	local Name
	local Value

	if rawget(Owner, "bEncrypted") then
		Name = k .. "_E"
		Value = rawget(t, Name) or (nil ~= DefaultValues and DefaultValues[Name] or nil)
		if Value then
			Value = tonumber(UDBMgr.ConvertValue(Value))
			rawset(t, k, Value)
			return Value
		end

		Name = k .. "_ES"
		Value = rawget(t, Name) or (nil ~= DefaultValues and DefaultValues[Name] or nil)
		if Value then
			Value = UDBMgr.ConvertValue(Value)
			rawset(t, k, Value)
			return Value
		end

		Name = "_" .. k .. "_E"
		Value = rawget(t, Name) or (nil ~= DefaultValues and DefaultValues[Name] or nil)
		if Value then
			Value = Owner:ParseDBStr(t[KeyName], k, UDBMgr.ConvertValue(Value))
			rawset(t, k, Value)
			--rawset(t, Name, nil)
			return Value
		end
	end

	Name = "_" .. k
	Value = rawget(t, Name) or (nil ~= DefaultValues and DefaultValues[Name] or nil)
	if Value then
		Value = Owner:ParseDBStr(t[KeyName], k, Value)
		rawset(t, k, Value)
		rawset(t, Name, nil)
		return Value
	end

	Name = "_" .. k .. "Num"
	Value = rawget(t, Name) or (nil ~= DefaultValues and DefaultValues[Name] or nil)
	if Value then
		local RepeatedStr = {}
		local KeyValue = t[KeyName]
		for i = 1, Value do
			local UKey = string.format("%s_%s_%d", KeyValue, k, i - 1)
			RepeatedStr[i] = LocalizationUtil.GetLocalString(UKey, UKey, TableName, true)
		end

		return RepeatedStr
	end

	for i = 1, #Config do
		local Item = Config[i]
		if Item.Name == k then
			local UKey = string.format("%s_%s", t[KeyName], k)
			return LocalizationUtil.GetLocalString(UKey, UKey, TableName, true)
		end
	end
end

---GetChildValue
---@param t table
---@param k string
---@private
function GetChildValue(t, k)
	local Config = getmetatable(t)
	if not Config then
		return
	end

	local Owner = rawget(Config, "Owner")
	if not Owner then
		return
	end

	local ID = t._ID
	local Index = t._Index
	local ParentName = Config.ParentName
	local TableName = Owner.TableName

	local Num = rawget(t, string.format("_%sNum", k))
	if Num then
		local RepeatedStr = {}
		for i = 1, Num do
			local UKey = string.format("%s_%s_%d_%s_%d", ID, ParentName, Index, k, i - 1)
			RepeatedStr[i] = LocalizationUtil.GetLocalString(UKey, UKey, TableName, true)
		end

		return RepeatedStr
	end

	for i = 1, #Config do
		local Item = Config[i]
		if Item.Name == k then
			local UKey = string.format("%s_%s_%d_%s", ID, ParentName, Index, k)
			return LocalizationUtil.GetLocalString(UKey, UKey, TableName, true)
		end
	end
end

---InitChildLocalizationConfig
---@param Config table
---@param ParentName string
---@private
function CfgBase:InitChildLocalizationConfig(Config, ParentName)
	if not Config then
		return
	end

	Config.Owner = self
	Config.__index = GetChildValue

	Config.ParentName = ParentName
end

---InitLocalizationConfig
---@param Config table
---@private
function CfgBase:InitLocalizationConfig(Config)
	if not Config then
		return
	end

	Config.Owner = self
	Config.__index = GetValue
	--Config.__newindex = Readonly

	for i = 1, #Config do
		local Item = Config[i]
		local Children = Item.Children
		if nil ~= Children then
			self:InitChildLocalizationConfig(Children, Item.Name)
		end
	end
end

---InitLocalization
---@private
function CfgBase:InitLocalization()
	local Localization = rawget(self, "Localization")
	if nil == Localization then
		return
	end

	local Config = Localization.Config
	if nil == Config then
		return
	end

	self:InitLocalizationConfig(Config)
end

---UpdateChildLocalizationInfo
---@param ID number | string
---@param CfgItems table
---@param Config table
---@private
function CfgBase:UpdateChildLocalizationInfo(ID, CfgItems, Config)
	if not CfgItems or not Config then
		return
	end

	for i = 1, #CfgItems do
		local Item = CfgItems[i]
		Item._ID = ID
		Item._Index = i - 1
		setmetatable(Item, Config)
	end
end

---UpdateLocalizationInfo
---@param Cfg table
---@param Config table
---@private
function CfgBase:UpdateLocalizationInfo(Cfg, Config, bDB)
	if not Config or not Cfg then
		return
	end

	setmetatable(Cfg, Config)

	--if bDB then
	--	return
	--end
	--
	--local KeyName = self.KeyName
	--local KeyValue = Cfg[KeyName]
	--
	--for i = 1, #Config do
	--	local Item = Config[i]
	--	local Children = Item.Children
	--	if nil ~= Children then
	--		local CfgItems = rawget(Cfg, Item.Name)
	--		if nil ~= CfgItems then
	--			self:UpdateChildLocalizationInfo(KeyValue, CfgItems, Children)
	--		end
	--	end
	--end
end

---UpdateDBCfgLocalizationInfo
---@param Cfg table
---@private
function CfgBase:UpdateDBCfgLocalizationInfo(Cfg)
	if not Cfg then
		return
	end

	local Localization = rawget(self, "Localization")
	if nil == Localization then
		return
	end

	local Config = Localization.Config
	if nil == Config then
		return
	end

	local _ <close> = CommonUtil.MakeProfileTag(string.format("UpdateDBCfgLocalizationInfo_%s", self.TableName))
	self:UpdateLocalizationInfo(Cfg, Config, true)
end

function CfgBase:UpdateCfgListLocalizationInfo(CfgList, bDB)
	local Localization = rawget(self, "Localization")
	if nil == Localization then
		return
	end

	local Config = Localization.Config
	if nil == Config then
		return
	end

	local _ <close> = CommonUtil.MakeProfileTag(string.format("UpdateCfgListLocalizationInfo_%s", self.TableName))
	for i = 1, #CfgList do
		self:UpdateLocalizationInfo(CfgList[i], Config, bDB)
	end
end

---ParseDBStr
---@param ID number|string
---@param ColName string
---@param Str string
function CfgBase:ParseDBStr(ID, ColName, Str)
	local Value = DBUtil.ParseStr(Str)

	local Localization = rawget(self, "Localization")
	if nil == Localization then
		return Value
	end

	local Config = Localization.Config
	if nil == Config then
		return Value
	end

	for i = 1, #Config do
		local Item = Config[i]
		if Item.Name == ColName then
			local Children = Item.Children
			if nil ~= Children then
				self:UpdateChildLocalizationInfo(ID, Value, Children)
			end
			break
		end
	end

	return Value
end

---InitCfg
---@private
function CfgBase:InitCfg()
	local _ <close> = CommonUtil.MakeProfileTag(string.format("InitCfg_%s", self.TableName))

	self:InitLocalization()

	local LuaData = CfgUtil.GetLuaData(self)
	if LuaData then
		setmetatable(LuaData, { __newindex = Readonly })
		self:UpdateCfgListLocalizationInfo(LuaData, false)
	else
		local LruConfig = CfgLruCacheConfig[self.TableName]
		local LruKeyType = self.LruKeyType
		local LruSize = DefaultLruSize
		if LruConfig then
			LruKeyType = LruConfig.KeyType
			LruSize = LruConfig.Size
		end

		self.DBData = nil
		if LruKeyType == "integer" then
			self.DBData = FLuaLruCache()
		elseif LruKeyType == "string" then
			self.DBData = FLuaLruCache_StrKey()
		end

		if self.DBData then
			self.DBData:Init(LruSize)
			self.bLruEnabled = true
		else
			self.DBData = {}
		end
	end
end

---GetCachedData 不要直接访问self.DBData 或 self.LuaData
function CfgBase:GetCachedData()
	return CfgUtil.GetLuaData(self) or self.DBData
end

return CfgBase