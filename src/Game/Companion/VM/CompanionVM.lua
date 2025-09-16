local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

local EventID
local CompanionMgr
local LSTR

---@class CompanionVM : UIViewModel
local CompanionVM = LuaClass(UIViewModel)

---Ctor
function CompanionVM:Ctor()
	
end

function CompanionVM:OnInit()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnInit函数
	--只初始化自身模块的数据，不能引用其他的同级模块
	self:ClearData()
end

function CompanionVM:OnBegin()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnBegin函数
	--可以引用其他同级模块的数据，这里初始化的数据，同级模块的OnInit中是不能访问的（相当于模块的私有数据）

	--其他Mgr、全局对象 建议在OnBegin函数里初始化
	LSTR = _G.LSTR
	EventID = _G.EventID
	CompanionMgr = _G.CompanionMgr

	--为了实现国际化，除日志外的需要翻译的字符串要通过"LSTR"函数获取
	--富文本的标签不用翻译，建议用RichTextUtil中封装的接口获取。
	-- self.LocalString = LSTR("中文")
	-- self.TextColor = "ff0000ff"
	-- self.ProfID = ProfType.PROF_TYPE_PALADIN
end

function CompanionVM:OnEnd()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnEnd函数
	--和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
	LSTR = nil
	EventID = nil
	CompanionMgr = nil
end

function CompanionVM:OnShutdown()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnShutdown函数
	--和OnInit对应 在OnInit中模块自身的数据，需要在这里清除
	self:ClearData()
end

local function GetListFromMap(Map)
	local ResultList = {}
	if Map ~= nil then
		for Key, Value in pairs(Map) do
			if Value == 1 then 
				table.insert(ResultList, Key)
			end
		end
	end
	return ResultList
end

local function GetCountFromList(List)
	local GroupIDList = {}
	local Count = 0
	for _, ID in pairs(List) do
		local IsInGroup, GroupID = CompanionMgr:IsCompanionInMergeGroup(ID)
		if not IsInGroup then
			Count = Count + 1
		else
			if not table.contain(GroupIDList, GroupID) then
				table.insert(GroupIDList, GroupID)
				Count = Count + 1
			end
		end
	end

	return Count
end

function CompanionVM:ClearData()
	self.CallingOutCompanion = 0	-- 已召出的宠物
	self.LastCallOutCompanion = 0	-- 上次召唤的宠物
	self.CompanionList = nil	-- 宠物列表，存储宠物的服务器数据，和OwnMap作用不一样
	self.CompanionOwnMap = nil	-- 已拥有的宠物Map，只存ID，用于快捷获取数量和判断是否拥有宠物
	self.CompanionFavouriteMap = nil	-- 最爱的宠物列表
	self.CompanionNewMap = nil	-- 宠物列表最新N只宠物
	self.CompanionArchiveNewMap = nil	-- 宠物图鉴最新N只宠物
	self.OnlineAutoCalling = nil	-- 上线自动召唤宠物
	self.OnlineAutoCallingType = nil	-- 自动召唤宠物方式
end

--- 获取服务器下发的已拥有宠物列表(已按实际展示排序)
function CompanionVM:GetCompanionList()
	return self.CompanionList
end

--- 获取某宠物的服务器数据
---@param ID uint32 宠物ID
function CompanionVM:GetCompanionByID(ID)
	local CompanionList = self:GetCompanionList()
	if CompanionList == nil then return nil end
	for _, Companion in pairs(CompanionList) do
		if Companion.ID == ID then
			return Companion
		end
	end

	return nil
end

--- 获取排序后某索引的数据
---@param Index int32 索引
function CompanionVM:GetCompanionByIndex(Index)
	local CompanionList = self:GetCompanionList()
	if CompanionList == nil then return nil end
	return CompanionList[Index]
end

--- 设置已拥有宠物列表
function CompanionVM:SetCompanionList(List)
	self.CompanionList = List
end

--- 获取是否上线自动召唤
function CompanionVM:GetOnlineAutoCalling()
	return self.OnlineAutoCalling
end

--- 设置是否上线自动召唤
---@param OnlineAutoCalling boolean 是否上线自动召唤
function CompanionVM:SetOnlineAutoCalling(OnlineAutoCalling)
	self.OnlineAutoCalling = OnlineAutoCalling
end

--- 获取上线自动召唤类型
function CompanionVM:GetOnlineAutoCallingType()
	return self.OnlineAutoCallingType
end

--- 设置上线自动召唤类型
---@param CallingType ProtoCS.CompanionAuto 枚举类型
function CompanionVM:SetOnlineAutoCallingType(CallingType)
	self:SetOnlineAutoCalling(CallingType ~= 0)
	self.OnlineAutoCallingType = CallingType
end

--- 获取召唤中的宠物ID
function CompanionVM:GetCallingOutCompanion()
	return self.CallingOutCompanion
end

--- 设置召唤中的宠物ID
---@param ID uint32 宠物ID
function CompanionVM:SetCallingOutCompanion(ID)
	self.CallingOutCompanion = ID
end

--- 获取上次召唤的宠物ID
function CompanionVM:GetLastCallOutCompanion()
	return self.LastCallOutCompanion
end

--- 设置上次召唤的宠物ID
---@param ID uint32 宠物ID
function CompanionVM:SetLastCallOutCompanion(ID)
	self.LastCallOutCompanion = ID
end

--- 清除未读宠物列表
function CompanionVM:ClearCompanionNewMap()
	self.CompanionNewMap = {}
end

--- 获取未读宠物ID列表
function CompanionVM:GetCompanionNewList()
	return GetListFromMap(self.CompanionNewMap)
end

--- 获取未读宠物数量
function CompanionVM:GetCompanionNewCount()
	return GetCountFromList(self:GetCompanionNewList())
end

--- 是否有未读宠物
function CompanionVM:HasCompanionNew()
	return self:GetCompanionNewCount() > 0
end

--- 是否为未读宠物
---@param ID uint32 宠物ID
function CompanionVM:IsCompanionNew(ID)
	if self.CompanionNewMap == nil then
		return false
	else
		return self.CompanionNewMap[ID] == 1
	end
end

--- 新增未读宠物
---@param ID uint32 宠物ID
function CompanionVM:AddCompanionNew(ID)
	if self.CompanionNewMap == nil then
		return
	else
		self.CompanionNewMap[ID] = 1
	end
end

--- 刪除未读宠物
---@param ID uint32 宠物ID
function CompanionVM:RemoveCompanionNew(ID)
	if self.CompanionNewMap == nil then
		return
	else
		self.CompanionNewMap[ID] = 0
	end
end

--- 清除偏好宠物列表
function CompanionVM:ClearCompanionFavouriteMap()
	self.CompanionFavouriteMap = {}
end

--- 获取偏好宠物ID列表
function CompanionVM:GetCompanionFavouriteList()
	return GetListFromMap(self.CompanionFavouriteMap)
end

--- 获取偏好宠物数量
function CompanionVM:GetCompanionFavouriteCount()
	return GetCountFromList(self:GetCompanionFavouriteList())
end

--- 是否有偏好宠物
function CompanionVM:HasCompanionFavourite()
	return self:GetCompanionFavouriteCount() > 0
end

--- 是否为偏好宠物
---@param ID uint32 宠物ID
function CompanionVM:IsCompanionFavourite(ID)
	if self.CompanionFavouriteMap == nil then
		return false
	else
		return self.CompanionFavouriteMap[ID] == 1
	end
end

--- 新增偏好宠物
---@param ID uint32 宠物ID
function CompanionVM:AddCompanionFavourite(ID)
	if self.CompanionFavouriteMap == nil then
		return
	else
		self.CompanionFavouriteMap[ID] = 1
	end
end

--- 刪除偏好宠物
---@param ID uint32 宠物ID
function CompanionVM:RemoveCompanionFavourite(ID)
	if self.CompanionFavouriteMap == nil then
		return
	else
		self.CompanionFavouriteMap[ID] = 0
	end
end

--- 清除已拥有宠物Map
function CompanionVM:ClearCompanionOwnMap()
	self.CompanionOwnMap = {}
end

--- 获取已拥有宠物ID列表
function CompanionVM:GetOwnCompanionList()
	return GetListFromMap(self.CompanionOwnMap)
end

--- 获取已拥有宠物数量
function CompanionVM:GetOwnCompanionCount()
	return GetCountFromList(self:GetOwnCompanionList())
end

--- 是否拥有宠物
function CompanionVM:HasOwnCompanion()
	return self:GetOwnCompanionCount() > 0
end

--- 是否拥有某宠物
---@param ID uint32 宠物ID
function CompanionVM:IsOwnCompanion(ID)
	if self.CompanionOwnMap == nil then
		return false
	else
		return self.CompanionOwnMap[ID] == 1
	end
end

--- 新增拥有宠物
---@param ID uint32 宠物ID
function CompanionVM:AddOwnCompanion(ID)
	if self.CompanionOwnMap == nil then
		return
	else
		self.CompanionOwnMap[ID] = 1
	end
end

--- 刪除拥有宠物
---@param ID uint32 宠物ID
function CompanionVM:RemoveOwnCompanion(ID)
	if self.CompanionOwnMap == nil then
		return
	else
		self.CompanionOwnMap[ID] = 0
	end
end

--- 清除图鉴未读宠物列表
function CompanionVM:ClearCompanionArchiveNewMap()
	self.CompanionArchiveNewMap = {}
end

--- 获取图鉴未读宠物ID列表
function CompanionVM:GetCompanionArchiveNewList()
	return GetListFromMap(self.CompanionArchiveNewMap)
end

--- 获取图鉴未读宠物数量
function CompanionVM:GetCompanionArchiveNewCount()
	return GetCountFromList(self:GetCompanionArchiveNewList())
end

--- 是否有图鉴未读宠物
function CompanionVM:HasCompanionArchiveNew()
	return self:GetCompanionArchiveNewCount() > 0
end

--- 是否为图鉴未读宠物
---@param ID uint32 宠物ID
function CompanionVM:IsCompanionArchiveNew(ID)
	if self.CompanionArchiveNewMap == nil then
		return false
	else
		return self.CompanionArchiveNewMap[ID] == 1
	end
end

--- 新增图鉴未读宠物
---@param ID uint32 宠物ID
function CompanionVM:AddCompanionArchiveNew(ID)
	if self.CompanionArchiveNewMap == nil then
		return
	else
		self.CompanionArchiveNewMap[ID] = 1
	end
end

--- 刪除图鉴未读宠物
---@param ID uint32 宠物ID
function CompanionVM:RemoveCompanionArchiveNew(ID)
	if self.CompanionArchiveNewMap == nil then
		return
	else
		self.CompanionArchiveNewMap[ID] = 0
	end
end

--- 获取宠物已解锁动作
---@param ID uint32 宠物ID
function CompanionVM:GetCompanionAction(ID)
	local Companion = self:GetCompanionByID(ID)
	if Companion == nil then return {} end
	
	return Companion.Action
end

--- 新增宠物已解锁动作
---@param ID uint32 宠物ID
---@param ActionID number 动作ID
function CompanionVM:AddCompanionAction(ID, ActionID)
	local Companion = self:GetCompanionByID(ID)
	if Companion == nil then return end

	local Action = Companion.Action
	table.insert(Action, ActionID)
end

--要返回当前类
return CompanionVM