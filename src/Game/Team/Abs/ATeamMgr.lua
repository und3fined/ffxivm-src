--[[
Author: v_hggzhang
Date: 2020-11-04 16:57:14
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-08-08 15:03:49
FilePath: \Script\Game\Team\Abs\ATeamMgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local ProtoCS = require("Protocol/ProtoCS")
local TeamDefine = require("Game/Team/TeamDefine")
local UIViewMgr = require("UI/UIViewMgr")

local OnlineStatusRes = ProtoRes.OnlineStatus

local Json = require("Core/Json")
local LogableMgr = require("Common/LogableMgr")

-------------------------------------------------------------------------------------------------------
---@class MemOLStatProxy
---@field Context ATeamMgr
local MemOLStatProxy = LuaClass()

function MemOLStatProxy:Init(Context)
	self.Context = Context
	self.OnlineStatMap = {
		[OnlineStatusRes.OnlineStatusCutscene] = Context.UpdateMovieState,
		[OnlineStatusRes.OnlineStatusElectrocardiogram] = Context.UpdateNetUnstable
	}
end

function MemOLStatProxy:UpdateMemberOnlineStatus(RoleID, Bitset)
	if self.Context:IsTeamMemberByRoleID(RoleID) and tonumber(Bitset) then
		for Flag, Func in pairs(self.OnlineStatMap) do
			Func(self.Context, RoleID, OnlineStatusUtil.CheckBit(Bitset, Flag))
		end
	end
end


local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Team.Team.CS_SUBMSGID_TEAM

---@class ATeamMgr : LogableMgr
---@field TeamVM ATeamVM | nil
---@field TeamID number               @队伍ID
---@field CaptainRoleID number        @队长RoleID
---@field MemberList table            @队伍成员列表 包含自己
---@field OnlineProxyObject MemOLStatProxy
local ATeamMgr = LuaClass(LogableMgr)

ATeamMgr._MemberPosInfoList = {}

function ATeamMgr:OnInit()
    self.OnlineProxyObject = MemOLStatProxy.New()
	self.OnlineProxyObject:Init(self)
	self.CaptainRoleID = nil
	self.MemberList = nil
	self:SetTeamID(nil)
end

function ATeamMgr:OnRegisterNetMsg()
	if not ATeamMgr.bRegMemLocUpdate then
		self:RegisterGameNetMsg(CS_CMD.CS_CMD_TEAM, SUB_MSG_ID.CsQueryTeamMemberLocation, self.OnNetMsgTeamMemberPos)
		ATeamMgr.bRegMemLocUpdate = true
	end
end

function ATeamMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes,                        self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.CombatGetEnmityList,                 self.OnGameEventCombatGetEnmityList)
	self:RegisterGameEvent(EventID.TargetChangeMajor,                   self.OnGameEventTargetChangeMajor)
	self:RegisterGameEvent(EventID.WorldPreLoad,                        self.OnGameEventWorldPreLoad)
	self:RegisterGameEvent(EventID.PWorldExit,                          self.OnGameEventPWorldExit)
	self:RegisterGameEvent(EventID.WorldPostLoad,                       self.OnGameEventWorldPostLoad)
	self:RegisterGameEvent(EventID.VisionEnter,                         self.OnGameEventVisionEnter)
	self:RegisterGameEvent(EventID.VisionLeave,                         self.OnGameEventVisionLeave)
	self:RegisterGameEvent(EventID.ActorVMCreate,                       self.OnGameEventActorVMCreate)
	self:RegisterGameEvent(EventID.ActorVMDestroy,                      self.OnGameEventActorVMDestroy)
	self:RegisterGameEvent(EventID.Attr_Change_HP,                      self.OnGameEventAttrChangeHP)
	self:RegisterGameEvent(EventID.Attr_Change_Shield,                  self.OnGameEventAttrChangeShield)
	self:RegisterGameEvent(EventID.UnSteadyAttrChangeMaxHP,             self.OnGameEventUnSteadyAttrChangeHP)
	self:RegisterGameEvent(EventID.MajorDead,                           self.OnGameEventMajorDead)
	self:RegisterGameEvent(EventID.OtherCharacterDead,                  self.OnGameEventCharacterDead)
	self:RegisterGameEvent(EventID.ActorReviveNotify,                   self.OnGameEventActorRevive)
	self:RegisterGameEvent(EventID.PWorldMapEnter,                      self.OnGameEventPWorldMapEnter)
	self:RegisterGameEvent(EventID.OnlineStatusChangedInVision,        	self.OnGameEventOnlineStatus)
	self:RegisterGameEvent(EventID.OnlineStatusMajorChanged,        	self.OnGameEventMajorOnlineStatus)
	self:RegisterGameEvent(EventID.OnRescureInfo,        	self.OnRescure)
	self:RegisterGameEvent(EventID.SkillSpectrumUpdate, 				self.OnGameEventSkillSpectrumUpdate)
	self:RegisterGameEvent(EventID.SkillSpectrumUpdateThirdPlayer, 		self.OnGameEventSkillSpectrumUpdateThirdPlayer)

	self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnMajorProfChanged)
	self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)

	-- #TODO A TEMP SOLUTION
	self:RegisterGameEvent(EventID.TeamUpdateMember, self.OnTeamVMUpdate)
	self:RegisterGameEvent(EventID.ChaneNameNotify, 	 self.TeamMembernNameChange)

	self:RegisterGameEvent(EventID.TeamMemberOnUpdateValue, self.OnTeamMemberVMUpdate)
	self:RegisterGameEvent(EventID.OnRescrueNotify, self.OnRescrueNotify)
	self:RegisterGameEvent(EventID.UpdateBuff, self.OnGameEventUpdateBuff)
	self:RegisterGameEvent(EventID.TeamMemberOnlineStatus, self.InnerUpdateOnlineStatus)
end

function ATeamMgr:OnRegisterTimer()
	self:RegisterTimer(self.SendQueryTeamMemberPosition, 0, 1, 0, nil)
end

-------------------------------------------------------------------------------------------------------
---@see EventHandles

function ATeamMgr:OnGameEventLoginRes(Params)
end

function ATeamMgr:OnGameEventWorldPreLoad(Params)
end

function ATeamMgr:OnGameEventWorldPostLoad(Params)
end

function ATeamMgr:OnGameEventPWorldMapEnter(Params)
end

function ATeamMgr:OnGameEventOnlineStatus(Params)
	self:InnerUpdateOnlineStatus(ActorUtil.GetRoleIDByEntityID(Params.EntityID), Params.OnlineStatus)
end

function ATeamMgr:OnGameEventMajorOnlineStatus()
	self:UpdateOnlineStatus(MajorUtil.GetMajorRoleID())
end

function ATeamMgr:OnRescure(Info)
	local Deadline = Info.RescueDeadline
	if Deadline == nil then
		return
	end

	if Deadline <= 0 then
		Deadline = 0
	end

	local function CancelUpdate()
		if self.TimerIDUpdateRescure then
			self:UnRegisterTimer(self.TimerIDUpdateRescure)
			self.TimerIDUpdateRescure = nil
		end
	end

	if Deadline > (self.RescureDeadline or 0) then
		self.RescureDeadline = Deadline
		if self.TimerIDCancelUpdateRescure then
			self:UnRegisterTimer(self.TimerIDCancelUpdateRescure)
			self.TimerIDCancelUpdateRescure = nil
		end
		local RemainTime = Deadline - _G.TimeUtil.GetServerTime()
		if RemainTime > 0 then
			self.TimerIDCancelUpdateRescure = self:RegisterTimer(function()
				CancelUpdate()
			end, math.max(RemainTime, 60) + 1)
		else
			self:UpdateRescureInfo()
		end
	end

	local VM = self:GetTeamMemberVMByRoleID(Info.RoleID)
	if VM then
		if Deadline <= 0 then
			VM:SetReviving(VM.bDead)
		end
		VM:SetRescureDeadline(Deadline)
		self:UpdateRescureInfo()
		if Deadline > 0 then
			CancelUpdate()
			self.TimerIDUpdateRescure = self:RegisterTimer(function()
				self:UpdateRescureInfo()
			end, 0, 1, 0)
		end
	end
end

function ATeamMgr:UpdateRescureInfo()
	if self.TeamVM then
		for _, ItemVM in ipairs(self.TeamVM.BindableListMember:GetItems()) do
			ItemVM:UpdateRescureRemainTime()
		end
	end
end

function ATeamMgr.GetRescureSkillCfg(ProfID)
	local ProfReviveSkillCfg = require("TableCfg/ProfReviveSkillCfg")
	return ProfReviveSkillCfg:FindCfgByKey(ProfID)
end

function ATeamMgr:OnEnd()
	self:QutiVoiceRoom()
	ATeamMgr.bRegMemLocUpdate = nil
end

function ATeamMgr:IsUsing()
	return require("Game/Team/TeamHelper").GetTeamMgr() == self
end

---@param RoleID number
---@param bUseCache boolean | nil
---@return RoleVM | nil
function ATeamMgr.FindRoleVM(RoleID, bUseCache)
	return _G.RoleInfoMgr:FindRoleVM(RoleID, bUseCache)
end

local CachedMajorProf = nil
local function SingeUpdateProf(ProfID)
	if ProfID == CachedMajorProf then
		return
	end

	CachedMajorProf = ProfID
	local Cfg = _G.TeamMgr.GetRescureSkillCfg(ProfID)
	if Cfg == nil then
		return
	end

	local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	if LogicData == nil then
		_G.FLOG_ERROR("missing major skill logic data when prof changed")
		return
	end

	local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
	LogicData:InitSkillMap(SkillCommonDefine.SkillButtonIndexRange.TeamRescure, Cfg.SkillID)
end

function ATeamMgr.InitMajorTeamSkills()
	SingeUpdateProf(MajorUtil.GetMajorProfID())
end

---@private
function ATeamMgr:OnMajorProfChanged(Params)
	SingeUpdateProf(Params.ProfID)

	local MajorRoleID = MajorUtil.GetMajorRoleID()
	do
		local VM = self:GetTeamMemberVMByRoleID(MajorRoleID)
		if VM then
			VM:SetProfID(Params.ProfID)
		end
	end

	if self.TeamVM then
		for _, VM in ipairs(self.TeamVM.BindableListMember:GetItems()) do
			VM:UpdateShowRevivePanel()
		end
		for _, VM in ipairs(self.TeamVM.MemberSimpleVMList:GetItems()) do
			if VM.RoleID == MajorRoleID then
				VM:UpdateProfInfo(self)
				break
			end
		end
	end
end

---@private
function ATeamMgr:OnMajorLevelUpdate()
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	do
		local VM = self:GetTeamMemberVMByRoleID(MajorRoleID)
		if VM then
			VM:SetLevel(MajorUtil.GetMajorLevel())
		end
	end
	if self.TeamVM then
		for _, VM in ipairs(self.TeamVM.MemberSimpleVMList:GetItems()) do
			if VM.RoleID == MajorRoleID then
				VM:UpdateProfInfo(self)
				break
			end
		end
	end
end

--- @private
---@param InTeamVM ATeamVM
function ATeamMgr:OnTeamVMUpdate(InTeamVM)
	if self.TeamVM == InTeamVM then
		self:UpdateEnmityOrders()
	end
end

ATeamMgr._MonsterEnmityList = {}
ATeamMgr.GetEnmityList = function(EID)
	return (EID and _G.ActorMgr:FindActorVM(EID)) and ATeamMgr._MonsterEnmityList[EID] or {}
end

function ATeamMgr:OnGameEventCombatGetEnmityList(Params)
	local EntityID = Params.EntityID
	if not ActorUtil.IsMonster(EntityID) then
		return
	end

	ATeamMgr._MonsterEnmityList[EntityID] = Params.List or {}

	if self:IsInTeam() and EntityID == self.TargetID then
		self:UpdateEnmityOrders()
	end
end

function ATeamMgr:OnGameEventTargetChangeMajor(InTargetID)
	self.TargetID = InTargetID
	if ActorUtil.IsMonster(self.TargetID) then
		self:UpdateEnmityOrders()
	else
		self:ClearEnmityOrder()
	end
end

function ATeamMgr:OnGameEventPWorldExit(Params)
	self:ClearEnmityOrder()
end

---OnGameEventVisionEnter
---@param Params FEventParams
function ATeamMgr:OnGameEventVisionEnter(Params)
	local EntityID = Params.ULongParam1
	self:UpdateEntityID(EntityID)

	if self.TargetID == EntityID then
		self:UpdateEnmityOrders()
	end
end

---OnGameEventVisionLeave
---@param Params FEventParams
function ATeamMgr:OnGameEventVisionLeave(Params)
	local EntityID = Params.ULongParam1

	local VM = self:GetTeamMemberVMByEntityID(EntityID)
	if VM then
		VM:SetEntityID(0)
	end

	if EntityID and self._MonsterEnmityList[EntityID] then
		self._MonsterEnmityList[EntityID] = nil
	end

	if self.TargetID == EntityID then
		self:UpdateEnmityOrders()
	end
end

---OnGameEventActorVMCreate
---@param Params ActorVM
function ATeamMgr:OnGameEventActorVMCreate(Params)
	if Params then
		self:UpdateEntityData(Params.RoleID, Params.EntityID)
	end
end

function ATeamMgr:OnGameEventActorVMDestroy(RoleID, EntityID)
	self:UpdateEntityData(RoleID, EntityID)
end

function ATeamMgr:UpdateEntityData(RoleID, EntityID)
	local VM = self:TryFindTeamMemberVM(RoleID, EntityID)
	if VM then
		VM:UpdateEntityData()
	end
end

---@protected
---@return TeamMemberVM
function ATeamMgr:TryFindTeamMemberVM(RoleID, EntityID)
	local VM = self:GetTeamMemberVMByRoleID(RoleID)
	if VM == nil then
		VM = self:GetTeamMemberVMByEntityID(EntityID)
	end

	return VM
end

function ATeamMgr:OnGameEventAttrChangeHP(Params)
	self:UpdateHPAndColor(Params.ULongParam1)
end

function ATeamMgr:OnGameEventAttrChangeShield(Params)
	self:UpdateHPAndColor(Params.ULongParam1)
end

function ATeamMgr:OnGameEventUnSteadyAttrChangeHP(Params)
	self:UpdateHPAndColor(Params.ULongParam1)
end

function ATeamMgr:OnGameEventMajorDead()
	self:UpdateTeamMemberAliveStats(MajorUtil.GetMajorEntityID(), false)
end

function ATeamMgr:OnGameEventCharacterDead(Params)
	self:UpdateTeamMemberAliveStats(Params and Params.ULongParam1 or nil, false)
end

function ATeamMgr:OnGameEventActorRevive(Params)
	self:UpdateTeamMemberAliveStats(Params and Params.ULongParam1, true)
end

function ATeamMgr:OnGameEventSkillSpectrumUpdate(Params)
	local VM = self:GetTeamMemberVMByRoleID(MajorUtil.GetMajorRoleID())
	if VM then
		VM:UpdateLB()
	end
end

function ATeamMgr:OnGameEventSkillSpectrumUpdateThirdPlayer(Params)
	if Params == nil then
		return
	end
	local VM = self:GetTeamMemberVMByRoleID(Params.RoleID)
	if VM then
		VM:UpdateLB()
	end
end

---@private
function ATeamMgr:UpdateTeamMemberAliveStats(EntityID, bAlive)
	local VM = self:GetTeamMemberVMByEntityID(EntityID)
	if VM then
		VM:UpdateAliveStats(bAlive)
		-- 
		local bCancel = true
		if self.TimerIDUpdateRescure and self.TeamVM then
			for _, ItemVM in ipairs(self.TeamVM.BindableListMember:GetItems()) do
				if ItemVM.bDead then
					bCancel = false
					break
				end
			end
		end
		bCancel = bCancel and not self:IsInTeam()
		if bCancel and self.TimerIDUpdateRescure then
			self:UnRegisterTimer(self.TimerIDUpdateRescure)
			self.TimerIDUpdateRescure = nil
		end
	end
end

---@private
function ATeamMgr:SetTeamVM(V)
	self.TeamVM = V
	self.TeamVM:InitSetUp(self)
end

-------------------------------------------------------------------------------------------------------
---@see TeamMemberVM属性相关更新
-- MemberVM Function

function ATeamMgr:UpdateHP(EntityID)
	local VM = self:GetTeamMemberVMByEntityID(EntityID)
	if VM then
		VM:UpdateHP()
	end
end

--- 队员存在改名
function ATeamMgr:TeamMembernNameChange(RoleID, EntityID, NewName)
	if self:IsInTeam() then
		for _, MemberRoleID in self:IterTeamMembers() do
			if RoleID == MemberRoleID then
				local VM = self:GetTeamMemberVMByEntityID(EntityID)
				if VM then
					VM:SetName(NewName)
				end

				break
			end
		end
	end
end

---@private
---@param VM TeamMemberVM
function ATeamMgr:OnTeamMemberVMUpdate(VM)
	if self:IsTeamMemberByRoleID(VM.RoleID) then
		VM:SetIsCaptain(self:IsCaptainByRoleID(VM.RoleID))
	end
end

---@private
function ATeamMgr:OnRescrueNotify(Data)
	local EntityID = Data.EntityID
	if EntityID == nil or EntityID == 0 then
		return
	end

	local VM = self:GetTeamMemberVMByEntityID(EntityID)
	if not VM then
		return
	end

	local RuleID = Data.RuleID
	local ReviveCfg = require("TableCfg/ReviveCfg")
	local Cfg = ReviveCfg:FindCfgByKey(RuleID)
	if Cfg then
		VM:SetRevivingBuffID(Cfg.ReadyBuffID)
	end
end

function ATeamMgr:OnGameEventUpdateBuff(Params)
	local EntityID = Params.ULongParam1
	local VM = self:GetTeamMemberVMByEntityID(EntityID)
	if VM == nil then
		return
	end

	local BuffID = Params.IntParam1
	if VM.RevivingBuffID == BuffID and BuffID then
		local ExpdTime = (Params.ULongParam3 or 0) / 1000
		local Secs = ExpdTime - os.time()
		VM:SetReviving(VM.bDead and Secs > 0)
		-- self:LogInfo("onrevivingbuff %s, dead: %s, secs: %s", VM.Name, VM.bDead, Secs)
		if Secs > 0 then
			self:RegisterTimer(function()
				local AVM = self:GetTeamMemberVMByEntityID(EntityID)
				if AVM then
					AVM:SetReviving(VM.bDead and AVM:ContainBuff(BuffID))
				end
			end, Secs + 0.5)
		end
	end
end

function ATeamMgr:UpdateHPAndColor(EntityID)
	local VM = self:GetTeamMemberVMByEntityID(EntityID)
	if VM then
		VM:UpdateHP()
		VM:UpdateColor()
	end
end

---@private
function ATeamMgr:UpdateEntityID(EntityID)
	local VM = self:GetTeamMemberVMByEntityID(EntityID)
	-- if the role change entity id
	if VM == nil then
		VM = self:GetTeamMemberVMByRoleID(ActorUtil.GetRoleIDByEntityID(EntityID))
	end
	-- update entity
	if VM then
		VM:SetEntityID(EntityID, true)
	end
end

function ATeamMgr:UpdateRenderOpacity(EntityID)
	local VM = self:GetTeamMemberVMByEntityID(EntityID)
	if VM then
		VM:UpdateRenderOpacity()
	end
end

function ATeamMgr:UpdateMovieState(RoleID, V)
	local VM = self:GetTeamMemberVMByRoleID(RoleID)
	if VM then
		VM:SetOLStatMovie(V)
	end
end

function ATeamMgr:UpdateNetUnstable(RoleID, IsNetUnstable)
	local VM = self:GetTeamMemberVMByRoleID(RoleID)
	if VM then
		VM:SetOLStatNetUnstable(IsNetUnstable)
	end
end

function ATeamMgr:UpdateEnmityOrders()
	self:UpdateVMEnmityOrders({List= self.GetEnmityList(self.TargetID)})
end

---@private
function ATeamMgr:UpdateVMEnmityOrders(Params)
	local TmpList = {}
	for _, __, EntityID in self:IterTeamMembers() do
		table.insert(TmpList, { EntityID = EntityID or -1, Value = 0 })
	end

	for _, v in ipairs(Params.List or {}) do
		local Item = table.find_item(TmpList, v.ID, "EntityID")
		if nil ~= Item then
			Item.Value = v.Value
		end
	end
	local BindableListMember = self.TeamVM and self.TeamVM.BindableListMember or nil
	if nil == BindableListMember then
		return
	end

	local function SortComparison(left, right)
		if left.Value ~= right.Value then
			return left.Value > right.Value
		end

		return left.EntityID < right.EntityID
	end
	table.sort(TmpList, SortComparison)

	for i = 1, BindableListMember:Length() do
		local ViewModel = BindableListMember:Get(i)
		local Value, Index = table.find_item(TmpList, ViewModel.EntityID, "EntityID")
		if nil ~= Index then
			ViewModel:SetEnmityOrder(Value.Value > 0 and Index or 0)
		else
			ViewModel:SetEnmityOrder(0)
		end
	end
end

function ATeamMgr:ClearEnmityOrder()
	self:UpdateVMEnmityOrders({List= {}})
end

-------------------------------------------------------------------------------------------------------
---@see Public
function ATeamMgr:IsInMovieState(RoleID)
	local VM = self:GetTeamMemberVMByRoleID(RoleID)
	if VM then
		return VM:GetOLStatMovie() == true
	end
end

function ATeamMgr:IsCaptain()
	return self.CaptainRoleID == MajorUtil.GetMajorRoleID() and self.CaptainRoleID ~= nil
end

function ATeamMgr:IsCaptainByRoleID( RoleID )
	return RoleID == self:GetCaptainID() and RoleID ~= nil
end

function ATeamMgr:GetCaptainID()
	return self.CaptainRoleID
end

function ATeamMgr:SetCaptainByRoleID(InRoleID, bForce)
	local bChanged = self.CaptainRoleID ~= InRoleID
	self.CaptainRoleID = InRoleID
	if bChanged or bForce then
		-- log anyway
		if bChanged then
			self:LogInfo("captain changed to %s %s", self.CaptainRoleID, (self.FindRoleVM(self.CaptainRoleID, true) or {}).Name)
		end

		-- in case of views that has not been registered the event
		if self.TeamVM then
			do
				for _, Item in ipairs(self.TeamVM.BindableListMember:GetItems()) do
					Item:SetIsCaptain(self:IsCaptainByRoleID(Item.RoleID))
				end
			end
			-- #TODO refine only use one set of data
			local SimpleVMList = self.TeamVM.MemberSimpleVMList
			for i = 1, SimpleVMList:Length() do
				local VM = SimpleVMList:Get(i)
				if VM then
					VM:UpdateCaptain()
				end
			end
		end
		self:OnCaptainChanged(self:GetCaptainID())
		-- fire  captain changed event
		_G.EventMgr:SendEvent(EventID.TeamCaptainChanged, self)
	end

	if self.TeamVM then
		self.TeamVM.CaptainID = self.CaptainRoleID
	end
end

---@protected
function ATeamMgr:OnCaptainChanged(NewCaptainID)
	-- left emtpy yet
end

function ATeamMgr:SetTeamID(V)
	local bChanged =  V ~= self.TeamID
	if bChanged then
		self:LogInfo("team id change %s => %s", self.TeamID, V)
		self:QutiVoiceRoom()
	end
	-- set team id
	self.TeamID = V
	-- set team status
	if self.TeamVM then
		self.TeamVM:SetIsTeam(self:IsInTeam())
	end
	-- Major
	local MjVM = MajorUtil.GetMajorRoleVM(true)
	if MjVM then
		MjVM:SetTeamID(self.TeamID)
	end
	-- if changed
	if bChanged then
		if self:IsInTeam() and _G.TeamVoiceMgr:GetCurTeamMgr() == self and _G.TeamVoiceMgr:IsVoiceNeedOn(self) then
			_G.TeamVoiceMgr:TryJoinRoom(self)
		end
		_G.EventMgr:SendEvent(EventID.TeamIDUpdate, self, self.TeamID)
	end
end

function ATeamMgr:GetTeamID()
	return self.TeamID
end

function ATeamMgr:GetTeamMemberCount()
	local Count = 0
	if self:IsInTeam() then
		for _ in self:IterTeamMembers() do
			Count = Count + 1
		end
	end
	
	return Count
end

function ATeamMgr:GetTeamMemberProf(RoleID)
	if RoleID == MajorUtil.GetMajorRoleID() then
		return MajorUtil.GetMajorProfID()
	end

	local VM = self:GetTeamMemberVMByRoleID(RoleID)
	return VM and VM.ProfID or 0
end

function ATeamMgr:GetTeamMemberLevel(RoleID)
	if RoleID == MajorUtil.GetMajorRoleID() then
		return MajorUtil.GetMajorLevel()
	end

	local VM = self:GetTeamMemberVMByRoleID(RoleID)
	return VM and VM.Level or 0
end

---@private
---@param RoleID any
---@return TeamMemberVM | nil a team member vm if exists
function ATeamMgr:GetTeamMemberVMByRoleID(RoleID)
	return self.TeamVM and self.TeamVM:FindMemberVM(RoleID) or nil
end

---@private
---@param EntityID any
---@return TeamMemberVM | nil a team member vm if exists
function ATeamMgr:GetTeamMemberVMByEntityID(EntityID)
	if EntityID and EntityID ~= 0 then
		return self.TeamVM and self.TeamVM:FindMemberVMByEntityID(EntityID) or nil
	end
end

---@return table list of role id
function ATeamMgr:GetTeamMemberRoleIDList()
	local RoleIDList = {}
	for _, RoleID in self:IterTeamMembers() do
		if RoleID and RoleID ~= 0 then
			table.insert(RoleIDList, RoleID)
		end
	end

	return RoleIDList
end

--- Is a valid team.
---@return boolean|nil
function ATeamMgr:IsInTeam()
	return self:GetTeamID() ~= nil and self:GetTeamID() ~= 0
end

--- IsTeamMemberByRoleID
---@param InRoleID any
---@return boolean | nil true if he/she is a team member
function ATeamMgr:IsTeamMemberByRoleID(InRoleID)
	if self:IsInTeam() then
		for _, RoleID in self:IterTeamMembers() do
			if RoleID == InRoleID and RoleID ~= nil then
				return true
			end
		end
	end
end

--- IsTeamMemberByEntityID
---@param EntityID any
---@return boolean | nil true if he/she is a team member
function ATeamMgr:IsTeamMemberByEntityID(EntityID)
	if self:IsInTeam() then
		for _, __, EID in self:IterTeamMembers() do
			if EID == EntityID and EID ~= nil and EID ~= 0 then
				return true
			end
		end
	end
end

function ATeamMgr:UpdateOnlineStatus(RoleID)
	if self:IsTeamMemberByRoleID(RoleID) then
		self:InnerUpdateOnlineStatus(RoleID)
	end
end

function ATeamMgr:RefreshOnlineStatus()
	for _, RoleID in self:IterTeamMembers() do
		if RoleID then
			self:InnerUpdateOnlineStatus(RoleID)
		end
	end
end

---@protected
function ATeamMgr:InnerUpdateOnlineStatus(RoleID, Status)
	local FinalStatus = Status or _G.OnlineStatusMgr:GetStatusByRoleID(RoleID)
	self.OnlineProxyObject:UpdateMemberOnlineStatus(RoleID, FinalStatus)

	local VM = self:GetTeamMemberVMByRoleID(RoleID)
	if VM then
		if Status then
			local bOnline = not OnlineStatusUtil.CheckBit(Status, OnlineStatusRes.OnlineStatusOffline)
			VM:SetIsOnline(bOnline)
		end

		VM:UpdOLStat()
		self:LogInfo("ATeamMgr:InnerUpdateOnlineStatus %s %s %s", RoleID, FinalStatus, VM.Name)
		return true
	end
end

local RoleInfoMetaTable = {
	__index = function (t, k)
		if k then
			local Info = rawget(t, 'Info')
			return Info and rawget(Info, k) or nil
		end
	end
}

---@param SceneTeamMember table
---@return ProtoTeamMember
function ATeamMgr.SceneTeamMemberToProtoTeamMember(SceneTeamMember)
	local Data = table.shallowcopy(SceneTeamMember, true)
	if Data.Type ~= ProtoCS.SceneTeamEntityType.SceneTeamEntityTypePlayer then
		Data.ResID = Data.RoleID
		Data.RoleID = nil
	end
	return setmetatable(Data, RoleInfoMetaTable)
end

local function ModifyMemberProp(DataList, RoleID, Keys, Values)
	for _, Item in ipairs(DataList) do
		if Item.RoleID == RoleID and RoleID and RoleID ~= 0 then
			for i, k in ipairs(Keys) do
				Item[k] = Values[i]
			end
			break
		end
	end
end

local function ModifyMemberByFuncProp(DataList, RoleID, Keys, Values)
	for _, Item in ipairs(DataList) do
		if Item.RoleID == RoleID and RoleID and RoleID ~= 0 then
			for i, k in ipairs(Keys) do
				Item["Set" .. k](Item, Values[i])
			end
			break
		end
	end
end

---@param RoleID number
---@param Keys table
---@param Values table
function ATeamMgr:UpdateMemberProps( RoleID, Keys, Values)
	ModifyMemberProp(self.MemberList or {}, RoleID, Keys, Values)
	if self.TeamVM then
		ModifyMemberByFuncProp(self.TeamVM.BindableListMember:GetItems(), RoleID, Keys, Values)
	end
end

-------------------------------------------------------------------------------------------------------
---@see 副本小队语音

function ATeamMgr:IsVoiceEnabled()
end

-- 同步消息

function ATeamMgr:SendSelfTeamData( Data )
	--
end

function ATeamMgr:SendSetSelfVoiceMemberID( MemberID )
	local RoleID = MajorUtil.GetMajorRoleID()
	if nil == RoleID then
		return
	end

	local Member = self:GetTeamMemberVMByRoleID(RoleID)
	if nil == Member then
		return
	end

	MemberID = MemberID or 0

	local TransData
	local CliData = Member.CliData
	if not string.isnilorempty(CliData) then
		local OK
		OK, TransData = pcall(Json.decode, Member.CliData)
		if not OK then
			self:LogErr("failed to decode CliData %s: %s", CliData, TransData)
		end
	end

	self:SendSyncVoiceData(MemberID, TransData)
end

function ATeamMgr:SendSyncVoiceData(MemberID, TransData)
	TransData = TransData or {}

	if MemberID == 0 and TransData.VoiceMemberID ~= MemberID and TransData.VoiceMemberID then
		self:LogErr("attemp to upload an invalid voice id for major %s, trace:\n%s", MajorUtil.GetMajorRoleID(), debug.traceback())
		return
	end

	TransData.VoiceMemberID = MemberID
	TransData.MicSyncState = _G.TeamVoiceMgr:ConvertCurrentState()

	-- print('sound value for [set]efwe', TransData.MicSyncState)

	self:SendSelfTeamData(Json.encode(TransData))
	_G.TeamVoiceMgr:OnVoiceMemberIDUpdate(self, MajorUtil.GetMajorRoleID(), MemberID)
end

function ATeamMgr:OnMemDataNtf(Mem)
	if not Mem then
		return
	end

	local CliData = Mem.CliData
	if string.isnilorempty(CliData) then
		return
	end

	local OK, TransData = pcall(Json.decode,CliData)
	if not OK then
		local TeamInfoStr = self:ToDebugStr()
		self:LogErr("failed to decode CliData %s, mem id: %s, err: %s, team info: %s", CliData, Mem.RoleID, TransData, TeamInfoStr)
		return
	end

	for _, v in ipairs(self.MemberList or {}) do
		if v.RoleID == Mem.RoleID then
			v.CliData = CliData
			local VM = self:GetTeamMemberVMByRoleID(Mem.RoleID)
			if VM and not VM:IsMajorRole() then
				VM:SetMicSyncState(TransData.MicSyncState)
			end
			if v.RoleID == MajorUtil.GetMajorRoleID() and TransData.MicSyncState ~= _G.TeamVoiceMgr:ConvertCurrentState() and TransData.VoiceMemberID ~= 0 and TransData.VoiceMemberID then
				self:SendSetSelfVoiceMemberID(TransData.VoiceMemberID)
			end
			break
		end
	end

	_G.TeamVoiceMgr:OnVoiceMemberIDUpdate(self, Mem.RoleID, TransData.VoiceMemberID)
end

function ATeamMgr:ToDebugStr()
	local StrArr = {}
	table.insert(StrArr, string.sformat("major: %s, team id: %s", MajorUtil.GetMajorRoleID(), self:GetTeamID()))
	for i, RoleID in self:IterTeamMembers() do
		table.insert(StrArr, string.sformat("Mem[%d]: %s", i, RoleID))
	end
	return table.concat(StrArr, " ")
end

function ATeamMgr:GetTeamVoiceRoomNameToJoin()
	return nil
end

---退出队伍语音房间
function ATeamMgr:OnQuitTeamVoiceRoom()
	self.TeamVM:OnQuitTeamVoiceRoom()
end

---@param Params FEventParams
---Params.StringParam1, room name
function ATeamMgr:OnQuitTeamRoom( Params )
	self:OnQuitTeamVoiceRoom()
end

function ATeamMgr:QutiVoiceRoom()
	_G.TeamVoiceMgr:QuitRoom(self)
end

function ATeamMgr:NeedsUpdateTeamMemberPosition()
	for _, v in ipairs(TeamDefine.ViewsToUpdateTeamPos) do
		if UIViewMgr:IsViewVisible(v) then
			return true
		end
	end

	return false
end

function ATeamMgr:SendQueryTeamMemberPosition()
	if not self:NeedsUpdateTeamMemberPosition() then
		return
	end

	local RoleIDList = {}
	local CurTime = os.time()
	for _, RoleID in self:IterTeamMembers() do
		if RoleID ~= nil and RoleID ~= MajorUtil.GetMajorRoleID() and (ATeamMgr._MemberPosInfoList[RoleID] == nil or (CurTime - ATeamMgr._MemberPosInfoList[RoleID].t) >= TeamDefine.TeamPosUpdateInterval) then
			table.insert(RoleIDList, RoleID)
		end
	end

	if #RoleIDList > 0 then
		self:_SendQueryTeamMemberPosition(RoleIDList)
	end
end

--- Private
function ATeamMgr:_SendQueryTeamMemberPosition(RoleIDList)
	local MsgID = ProtoCS.CS_CMD.CS_CMD_TEAM
	local SubMsgID = ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CsQueryTeamMemberLocation
	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.TeamID = self:GetTeamID()
	MsgBody.Location = { RoleIDs = RoleIDList }
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- Private
function ATeamMgr:OnNetMsgTeamMemberPos(Msg)
	local MsgBody = Msg.Location
	if MsgBody then
		local t = os.time()
		for _, v in ipairs(MsgBody.Locations) do
			ATeamMgr._MemberPosInfoList[v.RoleID] = {Data = table.deepcopy(v), t = t}
		end
	end
end

function ATeamMgr.TemplateMemberIterFunc(t, i)
	i = i + 1
	local v = t[i]
	if v then
		local EntityID = v.EntityID
		if v.RoleID then
			local EID = ActorUtil.GetEntityIDByRoleID(v.RoleID)
			if EID and EID ~= 0 then
				EntityID = EID
			end
		end
		return i, v.RoleID, EntityID
	end
end

--- IterTeamMembers
---@return any iterator of (index, RoleID, EntityID). If RoleID is nil, it may be a robot.
function ATeamMgr:IterTeamMembers()
	return self.TemplateMemberIterFunc, self.MemberList or {}, 0
end

--- GetTeamMemberNetPositionInfoByRoleID
---@param RoleID any
---@return MemberLocation nil if not a team member, local position if he/she is major/robot.
function ATeamMgr:GetTeamMemberNetPositionInfoByRoleID(RoleID)
	return (RoleID and ATeamMgr._MemberPosInfoList[RoleID]) and ATeamMgr._MemberPosInfoList[RoleID].Data or nil
end

--- GetTeamMemberNetPositionInfoByEntitiyID
---@param EntityID any
---@return MemberLocation nil if not a team member, local position if he/she is major/robot.
function ATeamMgr:GetTeamMemberNetPositionInfoByEntitiyID(EntityID)
	local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID)
	if RoleID and RoleID > 0 then
		return self:GetTeamMemberNetPositionInfoByRoleID(RoleID)
	end
end

function ATeamMgr:QueryTeamMemberCounters(CounterID, Callback, Timeout, TimeoutCallback)
	if not self:IsInTeam() then
		self:LogErr("can not queryt team member data while not in team!")
		return
	end

	local TeamHelperMgr = require("Game/Team/Abs/TeamHelperMgr")
	TeamHelperMgr:QueryTeamMemberData(self:GetTeamID(), ProtoCS.Team.Team.TeamMemberDataQueryType.TeamMemberDataQueryTypeCounter, {CounterID}, Callback, Timeout, TimeoutCallback)
end

return ATeamMgr