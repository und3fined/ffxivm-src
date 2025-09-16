--[[
Author: v_hggzhang
Date: 2021-04-06 14:24
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-09-14 16:18:50
FilePath: \Script\Game\Team\Abs\ATeamVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local TeamMemberVM = require("Game/Team/VM/TeamMemberVM")
local TeamMemberSimpleVM = require("Game/Team/VM/TeamMemberSimpleVM")
local TeamModuleItemVM = require("Game/Team/VM/TeamModuleItemVM")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local ProtoCommon = require("Protocol/ProtoCommon")
local TeamDefine = require("Game/Team/TeamDefine")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local Json = require("Core/Json")
local VoiceMgr = require("Game/Voice/VoiceMgr")

local RollMgr
local MaxMemberNum = TeamDefine.MaxMemberNum

local function PredicateFindByRoleID(RoleID)
	local function Pred(Value)
		return RoleID ~= nil and Value.RoleID == RoleID and RoleID ~= 0
	end
	return Pred
end

---@class ATeamVM : UIViewModel
local ATeamVM = LuaClass(UIViewModel)
local ClassTy = ProtoCommon.class_type
---Ctor
---@field BindableListMember UIBindableList
---@field JoinRedDotVisible boolean
---@field FunctionBarVisible boolean
function ATeamVM:Ctor()
    self.BindableListMember = UIBindableList.New(TeamMemberVM) --小队界面(主界面)
    self.MemberSimpleVMList = UIBindableList.New(TeamMemberSimpleVM) --队伍界面
	self.ModuleVMList = UIBindableList.New(TeamModuleItemVM)

	-- 语音
    self:ResetVoice()

    self.JoinRedDotVisible = false

	self:SetFunctionBarVisible(true)
	-- 整个FunctionBar
	self.IsShowBtnBar = true

    self.MemberNumber = 0
	self.CaptainID = 0

    self.ClassTypeNum = 0
	self.ClassTypeTank = false
	self.ClassTypeNear = false
	self.ClassTypeFar = false
	self.ClassTypeMagic = false
	self.ClassTypeHealth = false
	self.ClassTypeList = {}

	self.TeamProfList = {}

	self.IsTeam = false

    --self.TeamPanelVisible = true            --显示队员信息 或 队伍伤害
	-- 组队Roll点动画播放次数
	self.UnitAnimPlayCount = 5
	self.DecadeAnimPlayCount = 3
	self.SmoothAnimPlayCount = 1
	self.IsSwitch = false

end

function ATeamVM:OnInit()
	self.TeamMemberSet = {}
	self.ModuleVMList:UpdateByValues(TeamDefine.ModuleList)
end

function ATeamVM:OnBegin()
	RollMgr = require("Game/Roll/RollMgr")

	if _G.TeamVoiceMgr then
		self:SetVoice(_G.TeamVoiceMgr:IsCurVoiceOn())
		self:SetMic(_G.TeamVoiceMgr:IsCurMicOn())
	end

	self.BindableListMember:RegisterUpdateListCallback(self, self.OnMemListUpdate)
end

function ATeamVM:OnEnd()
	self.ShowResults = nil
	self:ResetVoice()
	self.BindableListMember:UnRegisterUpdateListCallback(self, self.OnMemListUpdate)
end

---@private
function ATeamVM:ResetVoice()
	self.IsOnVoice = false
	self.IsOnMic = false
end

---@param Mgr ATeamMgr
function ATeamVM:InitSetUp(Mgr)
	self.OwnedMgr = Mgr
	if self.OwnedMgr then
		self:SetIsTeam(Mgr:IsInTeam())
	end
end

---@return ATeamMgr | nil
function ATeamVM:GetOwnerMgr()
	return self.OwnedMgr
end

function ATeamVM:SetIsTeam(IsTeam)
	if self.IsTeam ~= IsTeam then
		self.IsTeam = IsTeam
		_G.EventMgr:SendEvent(EventID.TeamInTeamChanged, IsTeam)
	end
end


---@class ProtoTeamMember
---@field RoleID number | nil
---@field EntityID number | nil
---@field JoinTime number | nil
---@field CliData string | nil
---@field ResID number | nil
---@field Type number | nil
local ProtoTeamMember = nil

-------------------------------------------------------------------------------------------------------
---@see 队员显示更新等相关
--Update
--- UpdateTeamMembers
---@param TeamMembers ProtoTeamMember[]
function ATeamVM:UpdateTeamMembers(TeamMembers)
	do
		local Values = {}
		for _, V in ipairs(TeamMembers or {}) do
			local E = table.clone(V)
			E.OwnerTeamVM = self
			table.insert(Values, E)
		end
		self.BindableListMember:UpdateByValues(Values, self:GetMainTeamMemSort())
	end
   
	local Data = {}
	local MemNum = 0

	for i = 1, MaxMemberNum do
		local Info = { SortID = i }
		local Member = TeamMembers[i]
		if Member then
			Info.RoleID = Member.RoleID
			Info.JoinTime = Member.JoinTime
			Info.TeamMgr = self:GetOwnerMgr()
			local CliData = Member.CliData
			if not string.isnilorempty(CliData) then
				local TransData = Json.decode(CliData)
				Info.VoiceMemberID = TransData.VoiceMemberID or 0
			end

			MemNum = MemNum + 1
		end

		table.insert(Data, Info)
	end

	local MajorRoleID = MajorUtil.GetMajorRoleID()
	if MemNum <= 0 then
		Data[1] = { SortID = 1, RoleID = MajorRoleID, TeamMgr = self:GetOwnerMgr() }
		MemNum = 1
	end

    local SimpleSort = self:GetSimpleMemSort()
    self.MemberSimpleVMList:UpdateByValues(Data, SimpleSort)

	self:UpdateTeamMemberClassTypeInfo()

	_G.EventMgr:PostEvent(_G.EventID.TeamUpdateMember, self)

	if self.OwnedMgr then
		self.OwnedMgr:RefreshOnlineStatus()
	end

	---loiafeng: 有一些模块（如HUD、VisionMesh、主界面等）需要在其他玩家的队友身份变化时，处理一些显示逻辑。
	do
    	local OldSet = self.TeamMemberSet or {}
		local AddTeammateInfos = {} -- 新增的队友

		local NewSet = {}
		for k, Member in ipairs(TeamMembers) do
			local RoleID = (Member or {}).RoleID
			if RoleID and RoleID > 0 then
				NewSet[RoleID] = k
			end
		end
		self.TeamMemberSet = NewSet

		local UpdatedRoleIDs = {}

		for k, v in pairs(NewSet) do
			if OldSet[k] then
				OldSet[k] = nil
			else -- 新增的RoleID
				table.insert(UpdatedRoleIDs, k)

				if k ~= MajorRoleID then
					table.insert(AddTeammateInfos, {RoleID = k, SortID = k})
				end
			end
		end

		for RoleID, _ in pairs(OldSet) do
			table.insert(UpdatedRoleIDs, RoleID)  -- 移除的RoleID
		end

		if #UpdatedRoleIDs > 0 then
			_G.EventMgr:SendEvent(_G.EventID.TeamIdentityChanged, UpdatedRoleIDs)
		end

		if #AddTeammateInfos > 0 then
			table.sort(AddTeammateInfos, function(lhs, rhs)
				return lhs.SortID < rhs.SortID
			end)

			_G.FriendMgr:AddRecentTeamPlayer(table.extract(AddTeammateInfos, "RoleID"))
		end
	end

	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.TeamRollPanel) then
		--- 刷新队伍成员的Result，因为这里更新完之后，之前绑定的VM对不上了，需要刷新Roll点数据
		self:UpdateTeamRollResult(_G.TeamRollItemVM.CurrentSelectedAwardID, true, false, nil, _G.TeamRollItemVM.CurrentSelectedTeamID)
	end
end

local function DefaultSort()
	return false
end

function ATeamVM:GetMainTeamMemSort()
	return DefaultSort
end

function ATeamVM:GetSimpleMemSort()
	return DefaultSort
end

function ATeamVM:UpdateMemberSimpleVMLisRoleInfo( )
	self:UpdateTeamMemberClassTypeInfo()
end

function ATeamVM:UpdateTeamMemberClassTypeInfo()
	self.ClassTypeList = {}
	local ProfList = {}
	local FilterClassType = TeamDefine.TeamAttrAddClassType

	local Items = self.MemberSimpleVMList:GetItems() or {}

	for _, v in ipairs(Items) do
		local ProfID = v.ProfID
		if ProfID then
			ProfList[ProfID] = true

			local ClassID = RoleInitCfg:FindProfClass(ProfID)
			if ClassID and table.contain(FilterClassType, ClassID) then
				self.ClassTypeList[ClassID] = true
			end
		end
	end

	--只有当前玩家不计算属性
	if table.size(ProfList) <= 1 then
		ProfList = {}
		self.ClassTypeList = {}
	end

	self.TeamProfList = ProfList

	local TypeList = self.ClassTypeList
	self.ClassTypeTank = TypeList[ClassTy.CLASS_TYPE_TANK]
	self.ClassTypeNear = TypeList[ClassTy.CLASS_TYPE_NEAR]
	self.ClassTypeFar = TypeList[ClassTy.CLASS_TYPE_FAR]
	self.ClassTypeMagic = TypeList[ClassTy.CLASS_TYPE_MAGIC]
	self.ClassTypeHealth = TypeList[ClassTy.CLASS_TYPE_HEALTH]

	self.ClassTypeNum = table.size(TypeList)
end

-- Members query
function ATeamVM:GetMemberNum()
	return self.BindableListMember:Length()
end

function ATeamVM:GetTeamMemberList()
	return self.BindableListMember
end

function ATeamVM:GetTeamMemberVMs()
	return self.BindableListMember:GetItems()
end

function ATeamVM:UpdateTarget(EntityID)
	local BindableListMember = self.BindableListMember
	for i = 1, BindableListMember:Length() do
		local ViewModel = BindableListMember:Get(i)
		ViewModel:UpdateSelected(EntityID)
	end
end

---@deprecated #TODO UNSAFE! REMOVE IN THE FUTURE!
function ATeamVM:FindMemberVM(RoleID)
	if nil == RoleID or RoleID == 0 then
		return
	end

	local function Predicate(ViewModel)
		if ViewModel.RoleID == RoleID then
			return true
		end
	end

	return self.BindableListMember:Find(Predicate)
end

---@deprecated #TODO UNSAFE! REMVOE IN THE FUTURE!
function ATeamVM:FindMemberSimpleVM( RoleID )
	if nil == RoleID or RoleID == 0 then
		return
	end

	return self.MemberSimpleVMList:Find(function ( VM )
		return VM.RoleID == RoleID
	end)
end

---@deprecated #TODO UNSAFE! REMVOE IN THE FUTURE!
function ATeamVM:FindMemberVMByEntityID(EntityID)
	local function Predicate(ViewModel)
		local EID = ViewModel.EntityID or ActorUtil.GetEntityIDByRoleID(ViewModel.RoleID)
		if EID == EntityID and EID and EID ~= 0 then
			return true
		end
	end

	return self.BindableListMember:Find(Predicate)
end

function ATeamVM:IsFullMember()
	return self.MemberNumber >= MaxMemberNum
end

-- ETC.
function ATeamVM:SetFunctionBarVisible(Visible)
	self.FunctionBarVisible = Visible
end

function ATeamVM:ToggleFunctionBar()
	self:SetFunctionBarVisible(not self.FunctionBarVisible)
end

-------------------------------------------------------------------------------------------------------
---@see 语音相关
---

function ATeamVM:SetVoice(V)
	self.IsOnVoice = V
end

function ATeamVM:SetMic(V)
	self.IsOnMic = V
end

function ATeamVM:OnQuitTeamVoiceRoom( )
	local CloseSayingState = function ( VMList )
		local Items = VMList:GetItems() or  {}

		for _, v in ipairs(Items) do
			v:SetIsSaying(false)
		end
	end

	CloseSayingState(self.BindableListMember)
	CloseSayingState(self.MemberSimpleVMList)
end

function ATeamVM:UpdateMemberVoiceMemberID( RoleID, MemberID )
	if nil == RoleID then
		return
	end

	local bUpdated
	local MemberVM = self:FindMemberVM(RoleID)
	if MemberVM then
		MemberVM:SetVoiceMemberID(MemberID)
		bUpdated = true
	end

	local MemberSimpleVM = self:FindMemberSimpleVM( RoleID )
	if MemberSimpleVM then
		MemberSimpleVM:SetVoiceMemberID(MemberID)
	end

	return bUpdated
end

function ATeamVM:UpdateMemberVoiceState( MemberID, IsSaying )
	if nil == MemberID or MemberID <= 0 then
		return
	end

	local bUpdated
	local MemberVM = self.BindableListMember:Find(function ( VM ) return VM.VoiceMemberID == MemberID end)
	if MemberVM then
		MemberVM:SetIsSaying(IsSaying)
		bUpdated = true
	end

	local MemberSimpleVM = self.MemberSimpleVMList:Find(function ( VM ) return VM.VoiceMemberID == MemberID end)
	if MemberSimpleVM then
		MemberSimpleVM:SetIsSaying(IsSaying)
	end

	return bUpdated
end

function ATeamVM:UpdateMajorMicState()
	local MID = MajorUtil.GetMajorRoleID()
	local bMicActive = _G.TeamVoiceMgr and _G.TeamVoiceMgr:IsCurMicOn() and (VoiceMgr:GetMicVolume() or 0) > 0
	local MemberVM = self.BindableListMember:Find(function ( VM ) return VM.RoleID == MID end)
	if MemberVM then
		MemberVM:SetIsSaying(bMicActive)
	end

	local MemberSimpleVM = self.MemberSimpleVMList:Find(function ( VM ) return VM.RoleID == MID end)
	if MemberSimpleVM then
		MemberSimpleVM:SetIsSaying(bMicActive)
	end
end

function ATeamVM:FindMemberVoiceID(RoleID)
	return self:GetMemberVMAttr(PredicateFindByRoleID(RoleID), "VoiceMemberID")
end

function ATeamVM:GetMemberVMAttr(Pred, AttrKey)
	if AttrKey then
		local VM = self.BindableListMember:Find(Pred)
		return VM and VM[AttrKey] or nil
	end
end

function ATeamVM:OnMemListUpdate()
	self.MemberNumber = self:GetMemberNum()
end

function ATeamVM:UpdateProfInfo()
	for _, Item in ipairs(self.MemberSimpleVMList:GetItems()) do
		Item:UpdateProfInfo(self:GetOwnerMgr())
	end
	self:UpdateTeamMemberClassTypeInfo()
end

function ATeamVM:OnTimerUpdate()
	for _, Item in ipairs(self:GetTeamMemberVMs()) do
		Item:TimerUpdate()
	end
end

-------------------------------------------------------------------------------------------------------
---@see Roll点
-- AwardNotifyReslut 此变量用于判断是否是本玩家结果下发
function ATeamVM:UpdateTeamRollResult(AwardID, IsSwitch, IsClear, AwardNotifyReslut, TeamID)

	-- 用于初始化奖励增量Item
	if IsClear then
		for index = 1, self:GetMemberNum() do
			local TempTeamMemberVM = self.BindableListMember:Get(index) --队伍成员VM
			TempTeamMemberVM.RollResult = 0
			TempTeamMemberVM.NotRollResultNotify = true
			TempTeamMemberVM.IsHasShowAnimShowResult = true
			TempTeamMemberVM.IsWin = false --计时器创建状态
			TempTeamMemberVM.IsUpdateRoll = true
			TempTeamMemberVM.IsHasShowAnimShowResult = false
			TempTeamMemberVM.IsHasShowRollResult = false
		end
		return
	end
	if self.ShowResults == nil then --用于记录奖励品是否翻牌滚动过
		self.ShowResults = {}
	end
	self.IsSwitch = IsSwitch
	-- 下发Roll点结果时 --> IsSwitch == false
	if not IsSwitch then
		self.ShowResults[AwardID] = true
	end
	local AwardBelong = RollMgr:GetAwardBelong(AwardID, TeamID)
	for index = 1, self:GetMemberNum() do
		-- 设置每个Item的Roll点Result
		local TeamMemberItemVM = self.BindableListMember:Get(index) -- 队伍成员VM
		TeamMemberItemVM.IsSwitch = IsSwitch
		if IsSwitch then
			TeamMemberItemVM.IsHasShowRollResult = false
			self.CurrentTeamID = TeamID
			TeamMemberItemVM.IsWin = false
		end
		local PlayerAwardRollResult = RollMgr:GetPlayerAwardRollResult(TeamMemberItemVM.RoleID, AwardID, TeamID)
		local BelongPermissions = RollMgr:GetIsHavePermissions(TeamMemberItemVM.RoleID, AwardID, TeamID)
		if PlayerAwardRollResult == nil or PlayerAwardRollResult.Result == 0 or PlayerAwardRollResult.Result == -2 then
			TeamMemberItemVM.RollResult = 0
			if BelongPermissions then
				--- 未选择
				TeamMemberItemVM.NotRollResultNotify = true
			end
			--- 无资格玩家在有资格-无资格来回切换时，这里赋默认值
			if PlayerAwardRollResult == nil and not BelongPermissions then
				TeamMemberItemVM.NotRollResultNotify = false
			end
		else
			TeamMemberItemVM.NotRollResultNotify = false
			if PlayerAwardRollResult.Result == -1 then -- 放弃奖励操作
				TeamMemberItemVM.RollResult = 0
			else
				TeamMemberItemVM.RollResult = PlayerAwardRollResult.Result
			end
		end
		-- 设置Item主角状态
		local RoleSimple = MajorUtil.GetMajorRoleSimple()
		if TeamMemberItemVM.RoleID == RoleSimple.RoleID then
			TeamMemberItemVM.IsMajor = true
			self.MajorVM = TeamMemberItemVM
		else
			TeamMemberItemVM.IsMajor = false
		end
		-- 是否播放过滚动动画
		if TeamMemberItemVM.IsHasShowRollResult and not TeamMemberItemVM.NotRollResultNotify then
			TeamMemberItemVM.IsSmooth = true
		else
			TeamMemberItemVM.IsSmooth = false
		end
		-- 设置Item是否获胜(底色区别)
		if AwardBelong ~= nil then
			TeamMemberItemVM.IsBelong = true
			if TeamMemberItemVM.RoleID == AwardBelong.RoleID then
				TeamMemberItemVM.IsWin = true
			else
				TeamMemberItemVM.IsWin = false
			end
		else
			TeamMemberItemVM.IsBelong = false
		end
		if IsSwitch then
			TeamMemberItemVM.IsUpdateRoll = true
		else
			-- if AwardNotifyReslut ~= nil then
				-- if AwardID == AwardNotifyReslut.ID and TeamID == self.CurrentTeamID then
				if TeamID == self.CurrentTeamID then
					TeamMemberItemVM.IsUpdateRoll = true
				end
			-- end
		end
	end
end

return ATeamVM