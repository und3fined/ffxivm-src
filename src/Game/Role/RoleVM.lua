---
--- Author: anypkvcai
--- DateTime: 2021-11-22 19:55
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")
local MapCfg = require("TableCfg/MapCfg")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local HeadPortraitCfg = require("TableCfg/HeadPortraitCfg")
local PortraitCfg = require("TableCfg/PortraitCfg")
local RaceCfg = require("TableCfg/RaceCfg")
local ProfUtil = require("Game/Profession/ProfUtil")
local PersonPortraitHeadHelper = require("Game/PersonPortraitHead/PersonPortraitHeadHelper")

---@class RoleVM : UIViewModel
---@field OnlineStatus Bitset 玩家在线状态，按位保存
---@field OnlineStatusCustomID number 玩家主动设置的在线状态ID
---@field Identity Bitset 玩家身份（指导者、新人），按位保存
---@field OnlineStatusIcon string 默认情况下的在线状态图标
---@field OnlineStatusName string 默认情况下的在线状态名称
local RoleVM = LuaClass(UIViewModel)

---Ctor
function RoleVM:Ctor()
	self.RoleSimple = nil
	self.CacheTime = 0
	self.RoleID = 0
	self.IsMajor = nil
	self.WorldID = 0 			-- 玩家原始注册服务器ID
	self.CrossZoneWorldID = 0 	-- 玩家跨服服务器ID
	self.CurWorldID = 0 		-- 玩家当前所在服务器ID
	self.OpenID = ""
	self.Name = ""
	self.Prof = 0
	self.Level = 0
	self.LevelColor = "D5D5D5FF"
	self.PWorldLevel = 0 -- 副本同步的等级
	self.Gender = 0
	self.Race = 0
	self.Tribe = 0
	self:SetIsOnline(false)
	self.HeadIcon = nil
	self.PortraitDefaultIcon = nil
	self.MapResName = ""
	self.MapResID = 0
	self.EquipScore = 0
	self.LoginTime = 0
	self.LogoutTime = 0

	self.OnlineStatus = 0x00
	self.OnlineStatusCustomID = 1
	self.Identity = 0x00

	self.OnlineStatusIcon = ""
	self.OnlineStatusName = ""

	self.PortraitID = 0 ---肖像ID
	self.PortraitUrl = "" ---肖像Url
	self.PortraitUrlHashEx = "" ---肖像Url 扩展
	self.PortraitUrlID = "" 
	self.TitleID = 0 ---称号ID
	self.ProfSimpleDataList = nil ---职业数据信息 { common.ProfDataSimple ... }
	self.PersonSetInfos = {}

	self.IsJoinedNewbieChannel = nil -- 是否加入了新人频道

	self.TeamID = nil

	-- 是否死亡
	self.IsDie = false

	--- 角色部队简称，没有就是没加入部队
	self.ArmyAlias = nil

	self.HeadInfo = nil
	self.HeadFrameID = nil

	self.MVPTimes = 0

	-- 
	self.GrandCompID = 0
	self.GrandCompRank = 0

	self.LaunchType = 0

	self.IsCancellation = false
end

function RoleVM:SetTeamMemberMapData(Data)
	if self.IsMajor then
		return
	end

	local InMapResID = Data and Data.MapResID or nil
	local InSceneResID =  Data and Data.SceneResID or nil
	if InMapResID ~= nil then
		self:SetMapResID(InMapResID)
	end
	if InMapResID ~= nil and InSceneResID ~= nil and self.RoleSimple then
		local Location = self.RoleSimple.Location
		if Location then
			Location.MapResID = InMapResID
			Location.SceneResID = InSceneResID
		end
	end
end

function RoleVM:SetIsOnline(Value)
	self.IsOnline = Value
	if self.RoleSimple then
		self.RoleSimple.Online = Value
	end
end

function RoleVM:SetTeamMemberOnline(Value)
	-- never set a major's online status
	if self.IsMajor then
		return
	end

	self:SetIsOnline(Value)
end

function RoleVM:SetTeamID(InTeamID)
	self.TeamID = InTeamID
end

---@param Value table @simple.SimpleRsp
function RoleVM:UpdateVMBySimple(Value)
	if nil == Value then return end

	self.CacheTime = TimeUtil.GetServerTime()

	-- 职业
	local Prof = Value.Prof
	self.Prof = Prof

	-- 等级
	local Lv = Value.Level
	self.Level = Lv 
	self.LevelColor = ProfUtil.GetLevelUniformColor(Lv or 0)
 
	local ProfSimpleList = self.ProfSimpleDataList
	if ProfSimpleList then
		local ProfSimple = table.find_item(ProfSimpleList, Prof, "ProfID")
		if ProfSimple then
			ProfSimple.Level = Lv
		end
	end

	-- 位置
	local MapResID = Value.Map
	self:SetMapResID(MapResID)

	-- 是否在线
	self:SetIsOnline(Value.Online)

	self:SetHeadInfo(nil, nil, nil, self.Race)


	local RoleSimple = self.RoleSimple
	if RoleSimple then
		RoleSimple.Prof = Prof
		RoleSimple.Level = Lv 

		local Location = RoleSimple.Location
		if Location then
			Location.MapResID = MapResID
			Location.SceneResID = Value.Scene
		end
	end
end

---@param Value table @common.RoleSimple
function RoleVM:UpdateVM(Value, IsForceUpdMajor)
	if nil == Value then return end

	self.RoleSimple = Value
	self.CacheTime = TimeUtil.GetServerTime()

	local RoleID = Value.RoleID
	self.RoleID = RoleID

	local IsMajor = MajorUtil.IsMajorByRoleID(RoleID)
	self.IsMajor = IsMajor 

	self.OpenID = Value.OpenID
	self.Name = Value.Name
	self.Prof = Value.Prof
	self.Level = Value.Level
	self.LevelColor = ProfUtil.GetLevelUniformColor(Value.Level or 0)
	self.Gender = Value.Gender
	self.Race = Value.Race
	self.Tribe = Value.Tribe
	self:SetIsOnline(Value.Online)
	self.LoginTime = Value.LoginTime
	self.LogoutTime = Value.LogoutTime
	self.LaunchType = Value.LoginChannel or 0

	local WorldID = Value.WorldID
	self.WorldID = WorldID

	--设置跨服服务器ID
	if not IsMajor then
		self:SetCrossZoneWorldID(Value.CrossZoneID)
	end

	self.IsCancellation = Value.IsAccountCancellation

	local Display = Value.Display
	if Display then
		local InVisionStatus = _G.OnlineStatusMgr:GetVisionStatusByRoleID(self.RoleID)
		if nil ~= InVisionStatus then
			Display.Status = InVisionStatus 
		end
		self:SetOnlineStatus(Display.Status)
		self:SetOnlineStatusCustomID(Display.Set)
		self:SetIdentity(Display.Identify)
	end

	self:SetTitleID(Value.Title)

	local Portrait = Value.Portrait or {}
	self:SetPortraitUrl(Portrait.HeaderUrl, Portrait.CreatedTime)

	local Location = Value.Location
	if Location then
		self:SetMapResID(Location.MapResID)
	end

	--职业数据信息 { common.ProfDataSimple ... }
	self.ProfSimpleDataList = (Value.ProfSimple or {}).Profs 


	self:SetPortraitID()

	local HeadInfo = Value.HeadData or {}
	self:SeMvpInfo(Value.SceneMVPTimes)
	---个人设置信息(名片信息), map<int32,string>
	self.PersonSetInfos = (Value.Card or {}).Cards or {}
	self:SetTeamID(Value.TeamID)
	--- 是否加入了新人频道
	self.IsJoinedNewbieChannel = Value.IsJoinNewbieChannel == true 
	self:SeGrandCompInfo(Value.GrandCompanyID, Value.GrandCompanyMilitaryRank)

	
	self:SetHeadFrameID(Value.HeaderFrame)
	self:SetHeadInfo(HeadInfo.HeadID, HeadInfo.HeadType, HeadInfo.HeadUrl, self.Race)

	local IsInPvp = _G.PWorldMgr:CurrIsInPVPColosseum()
	self.BtnSwitchVisible = not IsInPvp
	-- print('testinfo name = ' .. tostring(self.Name))
	-- print('testinfo GrandCompID = ' .. tostring(Value.GrandCompanyID))
	-- print('testinfo GrandCompRank = ' .. tostring(Value.GrandCompanyMilitaryRank))
end

function RoleVM:SetHeadFrameID( FrameID )
	self.HeadFrameID = FrameID
end

function RoleVM:SeGrandCompInfo(GrandCompID, GrandCompRank)
	self.GrandCompID = GrandCompID
	self.GrandCompRank = GrandCompRank
end

function RoleVM:SeMvpInfo(SceneMVPTimes)
	self.MVPTimes = SceneMVPTimes
end

function RoleVM:SetHeadInfo( HeadIdx, HeadType, HeadUrl, Race )
	local Info = self.HeadInfo or {}
	-- vm
	local New = {}
	New.HeadIdx = HeadIdx or Info.HeadIdx or 1
	--@todo 先兼容后台
	if New.HeadIdx == 0 then
		New.HeadIdx = 1
	end
	New.HeadType = HeadType or Info.HeadType or 0
	New.HeadUrl = HeadUrl or Info.HeadUrl or ""

	Race = Race or self.Race
	Race = PersonPortraitHeadHelper.GetHeadRace(self.Race, self.Gender, self.Tribe)

	New.Race = Race
	self.HeadInfo = New
end

---更新在线状态
---@param Status Bitset @状态位集
function RoleVM:SetOnlineStatus( Status )
	self.OnlineStatus = Status or 0x00
	self.OnlineStatusIcon, self.OnlineStatusName = OnlineStatusUtil.GetDefaultStatusRes(self.OnlineStatus)
end

---更新在线状态设置
---@param StatusID number @状态ID
function RoleVM:SetOnlineStatusCustomID( StatusID )
	self.OnlineStatusCustomID = StatusID or 1
end

---更新身份数据
---@param StatusID number @状态ID
function RoleVM:SetIdentity( Identity )
	self.Identity = Identity or 0x00
end

---设置头像ID
---@param ID number @头像ID
function RoleVM:SetHeadPortraitID( ID )
    local Race = RoleVM.Race or 1
	local Icon = HeadPortraitCfg:GetHeadIconByRaceID(Race, 1)

	self.HeadIcon = Icon
end

---设置肖像ID
---@param ID number @肖像ID
function RoleVM:SetPortraitID( ID )
	if nil == ID or ID <= 0 then --使用种族默认肖像ID
		ID = RaceCfg:GetRacePortraitIDByRaceIDGenderAndTribe(self.Race, self.Gender, self.Tribe)
	end

	if ID ~= self.PortraitID then
		self.PortraitDefaultIcon = PortraitCfg:GetPortraitIcon(ID)
	end

	self.PortraitID = ID
end

---设置肖像Url
---@param Url stirng @肖像Url
---@param UrlHashEx stirng @肖像Url 扩展，用于和Url一起生成Hash作为图片的名字
function RoleVM:SetPortraitUrl( Url, UrlHashEx )
	local HashEx = UrlHashEx and tostring(UrlHashEx) or ""
	Url = Url or ""

	self.PortraitUrl = Url 
	self.PortraitUrlHashEx = HashEx
	self.PortraitUrlID = Url .. HashEx
end

---设置所在地图ID
function RoleVM:SetMapResID( MapID )
	self.MapResID = MapID
	self.MapResName = MapCfg:FindValue(MapID, "DisplayName")
end

---设置称号ID
---@param ID number @称号ID
function RoleVM:SetTitleID( ID )
	self.TitleID = ID or 0
end

function RoleVM:SetProf(Prof)
	self.Prof = Prof
end

---更新指定类型的个人设置信息(名片信息)
---@param Key ProtoCS.ClientSetupKey @设置key
---@param Value string @设置值
function RoleVM:UpdatePersonSetInfo( Key, Value )
	if nil == Key then
		return
	end

	if nil == self.PersonSetInfos then
		self.PersonSetInfos = {}
	end

	self.PersonSetInfos[Key] = Value
end

---Set等级
function RoleVM:SetLevel(Level)
	self.Level = Level

	self:SetProfLevel(self.Prof, Level)
end

---Set副本同步等级
function RoleVM:SetPWorldLevel(PWorldLevel)
	-- print('zhg SetPWorldLevel' .. 'Name ' .. self.Name .. ' Level = '  .. tostring(PWorldLevel) .. ' trace = ' .. debug.traceback())
	self.PWorldLevel = PWorldLevel
end

---Set名字
function RoleVM:SetName(Name)
	self.Name = Name
	if self.RoleSimple then
		self.RoleSimple.Name = Name
	end
end

function RoleVM:SetEquipScore(EquipScore)
	self.EquipScore = EquipScore
end

function RoleVM:SetIsDie(V)
	self.IsDie = V
end

function RoleVM:SetArmyAlias(InArmyAlias)
	self.ArmyAlias = InArmyAlias
end

function RoleVM:SetProfLevel(ProfID, Level)
	if nil == ProfID then
		return
	end

	local ProfSimpleList = self.ProfSimpleDataList
	if ProfSimpleList then
		local ProfSimple = table.find_item(ProfSimpleList, ProfID, "ProfID")
		if ProfSimple then
			ProfSimple.Level = Level 
		else
			table.insert(ProfSimpleList, {ProfID = ProfID, Level = Level})
		end
	end
end

function RoleVM:GetProfLevel(ProfID)
	if nil == ProfID then
		return
	end

	local ProfSimpleList = self.ProfSimpleDataList
	if ProfSimpleList then
		local ProfSimple = table.find_item(ProfSimpleList, ProfID, "ProfID") or {}
		return ProfSimple.Level
	end
end

function RoleVM:GetMaxProfLevel()
	local ProfSimpleList = self.ProfSimpleDataList
	if table.is_nil_empty(ProfSimpleList) then
		return 0
	end

	local Ret = 0

	for _, v in ipairs(ProfSimpleList) do
		local Level = v.Level
		if Level and Level > Ret then
			Ret = Level
		end
	end

	return Ret
end

---设置跨服服务器ID
---@param CrossZoneWorldID number @跨服服务器ID
function RoleVM:SetCrossZoneWorldID(CrossZoneWorldID)
	CrossZoneWorldID = CrossZoneWorldID or 0
	self.CrossZoneWorldID = CrossZoneWorldID
	self.CurWorldID = CrossZoneWorldID > 0 and CrossZoneWorldID or (self.WorldID or 0)
end

return RoleVM