--
-- Author: anypkvcai
-- Date: 2020-11-03 09:51:17
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local ActorVM = require("Game/Actor/ActorVM")
local BuffCfg = require("TableCfg/BuffCfg")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local PreCreateConfig = require("Define/PreCreateConfig")
local CommonDefine = require("Define/CommonDefine")
local CampRelationCfg = require("TableCfg/CampRelationCfg")
local ProtoRes = require("Protocol/ProtoRes")
local BuffDefine = require("Game/Buff/BuffDefine")
local MainTargetBuffsVM = require("Game/Buff/VM/MainTargetBuffsVM")
local MajorBuffVM = require("Game/Buff/VM/MajorBuffVM")
local EActorType = _G.UE.EActorType
local EActorSubType = _G.UE.EActorSubType

local ObjectPoolMgr
local FLOG_INFO

local CS_CMD = ProtoCS.CS_CMD
local DelaySetMKTime = 0.7

---@class ActorMgr : MgrBase
local ActorMgr = LuaClass(MgrBase)

function ActorMgr:OnInit()
    _G.FLOG_INFO("ActorMgr:OnInit")
	self.MajorRoleID = nil
	self.MajorRoleDetail = nil
	self.ActorViewModels = {}
	self.CampRelationCfgMap = {}
end

function ActorMgr:OnBegin()
	ObjectPoolMgr = _G.ObjectPoolMgr
	FLOG_INFO = _G.FLOG_INFO
	local CfgList = CampRelationCfg:FindAllCfg()
	for _, CfgItem in ipairs(CfgList) do
		self.CampRelationCfgMap[CfgItem.Camp] = CfgItem.Relation
	end
	
	--记录生产和采集职业的工具：[EntityID, ToolID]
	self.EntityToolMap = {}
end

function ActorMgr:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function ActorMgr:OnEnd()
end

function ActorMgr:OnTimer()
	self:UpdateActorVM()
end

function ActorMgr:UpdateActorVM()
	for _, VM in pairs(self.ActorViewModels) do
		VM:OnTimer()
	end

	MajorBuffVM:OnTimer()

	if MainTargetBuffsVM:HasTarget() then
		MainTargetBuffsVM:OnTimer()
	end
end

function ActorMgr:OnShutdown()
	self.ActorViewModels = nil
end

function ActorMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOGIN, 0, self.OnNetMsgRoleLoginRes)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_SAMPLE, ProtoCS.SampleCmd.SampleCmdLogin, self.OnNetMsgDemoRoleLoginRes)

end

function ActorMgr:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.StateChange, self.OnActorStateChanged)

	self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
	self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
	self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnGameEventStartFadeIn)

	self:RegisterGameEvent(EventID.VisionLevelChange, self.OnGameEventVisionLevelChange)
    self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnGameEventMajorLevelUpdate)

	self:RegisterGameEvent(EventID.UpdateBuff, self.OnGameEventUpdateBuff)
	self:RegisterGameEvent(EventID.RemoveBuff, self.OnGameEventRemoveBuff)
	self:RegisterGameEvent(EventID.UpdateBuffEffectiveState, self.OnGameEventUpdateBuffEffectiveState)

	self:RegisterGameEvent(EventID.Attr_Change_HP, self.OnGameEventActorHPChange)
	self:RegisterGameEvent(EventID.Attr_Change_MP, self.OnGameEventActorMPChange)
	self:RegisterGameEvent(EventID.Attr_Change_GP, self.OnGameEventActorGPChange)
	self:RegisterGameEvent(EventID.Attr_Change_MK, self.OnGameEventActorMKChange)
	self:RegisterGameEvent(EventID.CrafterSkillRsp, self.OnCrafterSkillRsp)
	self:RegisterGameEvent(EventID.CrafterOnMakeComplete, self.OnCrafterSkillRsp)
	self:RegisterGameEvent(EventID.CrafterExitRecipeState, self.OnCrafterExitRecipeState)

	--self:RegisterGameEvent(EventID.WorldPreLoad, self.OnGameEventWorldPreLoad)
	self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)

	-- life buff
	self:RegisterGameEvent(EventID.AddLifeSkillBuff, self.AddOrUpdateLifeBuff)
	self:RegisterGameEvent(EventID.UpdateLifeSkillBuff, self.AddOrUpdateLifeBuff)
	self:RegisterGameEvent(EventID.RemoveLifeSkillBuff, self.RemoveLifeBuff)

	-- Bonus State
	self:RegisterGameEvent(EventID.AddOrUpdateBonusState, self.OnGameEventAddOrUpdateBonusState)
	self:RegisterGameEvent(EventID.RemoveBonusState, self.OnGameEventRemoveBonusState)

	self:RegisterGameEvent(EventID.BuddyCreate, self.OnGameEventBuddyCreate)
end

function ActorMgr:OnGameEventLoginRes(Params)
    if Params.bReconnect then
		self:SendCommStatQueryReq()
    end
end

function ActorMgr:OnNetMsgRoleLoginRes(MsgBody)
	if MsgBody.ErrorCode then
		return
	end
	self.MajorRoleID = MsgBody.RoleID
	if nil == MsgBody.RoleDetail then
		_G.FLOG_ERROR("ActorMgr:OnNetMsgRoleLoginRes: Role detail is nil")
		return
	end
	self:SetMajorRoleDetail(MsgBody.RoleDetail, true)
end

function ActorMgr:OnNetMsgDemoRoleLoginRes(MsgBody)
	if MsgBody.ErrorCode or not MsgBody.Login then
		return
	end
	
	local RoleDetail = MsgBody.Login.RoleDetail
	if nil == RoleDetail then
		_G.FLOG_ERROR("ActorMgr:OnNetMsgDemoRoleLoginRes: Role detail is nil")
		return
	end
	self.MajorRoleID = RoleDetail and RoleDetail.Simple.RoleID or 0
	self:SetMajorRoleDetail(RoleDetail, true)
end

---FindActorVM
---@param EntityID table
---@return ActorVM
function ActorMgr:FindActorVM(EntityID)
	return self.ActorViewModels[EntityID]
end

---FindActorVMByRoleID
---@param RoleID table
function ActorMgr:FindActorVMByRoleID(RoleID)
	for _, v in pairs(self.ActorViewModels) do
		if v.RoleID == RoleID then
			return v
		end
	end
end

---ClearActor
function ActorMgr:ClearActor()
	for _, v in pairs(self.ActorViewModels) do
		ObjectPoolMgr:FreeObject(ActorVM, v)
	end

	self.ActorViewModels = {}
end

---OnActorStateChanged
---@param Params FEventParams
function ActorMgr:OnActorStateChanged(Params)
	-- if MajorUtil.IsMajor(Params.ULongParam1) then
	-- 	local MajorStatComp = MajorUtil.GetMajorStateComponent()
	-- 	if Params.IntParam1 == ProtoCommon.CommStatID.COMM_STAT_QTE then
	-- 		if MajorStatComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_QTE) then
	-- 			UIViewMgr:ShowView(UIViewID.QTEMain)
	-- 		end
	-- 	end
	-- end
end

---OnGameEventVisionEnter
---@param Params FEventParams
function ActorMgr:OnGameEventVisionEnter(Params)
	if CommonDefine.IsShowVisionLog then
		FLOG_INFO("ActorMgr:OnGameEventVisionEnter %d", Params.ULongParam1)
	end

	local EntityID, ViewModel
	do
		local _ <close> = CommonUtil.MakeProfileTag("ActorMgr:VisionEnter")
		EntityID = Params.ULongParam1
		ViewModel = self:AddViewModel(EntityID)
	end

	_G.EventMgr:SendEvent(EventID.ActorVMCreate, ViewModel)

	self:UpdateActorCache(Params)

	local BuddyEntityID = _G.BuddyMgr:GetBuddyByMaster(EntityID)
	local BuddyVM = self:FindActorVM(BuddyEntityID)
	if nil ~= BuddyVM then
		BuddyVM:UpdateLevel()
	end
end

---OnGameEventVisionLeave
---@param Params FEventParams
function ActorMgr:OnGameEventVisionLeave(Params)
	if CommonDefine.IsShowVisionLog then
		FLOG_INFO("ActorMgr:OnGameEventVisionLeave %d", Params.ULongParam1)
	end
	local EntityID = Params.ULongParam1
	local ViewModel = self:FindActorVM(EntityID)
	if nil == ViewModel then
		return
	end

	ObjectPoolMgr:FreeObject(ActorVM, ViewModel)

	self.ActorViewModels[EntityID] = nil

	_G.EventMgr:SendEvent(EventID.ActorVMDestroy, ViewModel.RoleID, EntityID)
end

---OnGameEventMajorCreate
---@param Params FEventParams
function ActorMgr:OnGameEventMajorCreate(Params)
	FLOG_INFO("ActorMgr:OnGameEventMajorCreate")

	local ViewModel
	do
		local _ <close> = CommonUtil.MakeProfileTag("ActorMgr:MajorCreate")
		local EntityID = Params.ULongParam1
		ViewModel = self:AddViewModel(EntityID)
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("ActorMgr:MajorCreate2")
		_G.EventMgr:SendEvent(EventID.ActorVMCreate, ViewModel)
	end

	self:SendCommStatQueryReq()
end

function ActorMgr:OnGameEventStartFadeIn(Params)
	local EntityID = Params.ULongParam1

	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if Actor then
		Actor:StartFadeIn(0.7, false)
	end
end

function ActorMgr:OnGameEventVisionLevelChange(Params)
	local EntityID = Params.ULongParam1
	local VM = self:FindActorVM(EntityID)
	if nil ~= VM then VM:UpdateLevel() end
end

function ActorMgr:OnGameEventMajorLevelUpdate()
	local VM = self:FindActorVM(MajorUtil.GetMajorEntityID())
	if nil ~= VM then VM:UpdateLevel() end
end

---OnGameEventUpdateBuff
---@param Params FEventParams
function ActorMgr:OnGameEventUpdateBuff(Params)
	local BufferID = Params.IntParam1
	local EntityID = Params.ULongParam1

	---@type FCombatBuff
	local BuffInfo = {
		BuffID = Params.IntParam1,
		Giver = Params.ULongParam2,
		ExpdTime = Params.ULongParam3,
		Pile = Params.IntParam2,
        AddTime = Params.ULongParam4,
	}

	local ViewModel = self:FindActorVM(EntityID)
	if nil ~= ViewModel then
		ViewModel:AddOrUpdateBuff(BufferID, BuffDefine.BuffSkillType.Combat, BuffInfo)
	end

	if MainTargetBuffsVM:IsTarget(EntityID) then
		MainTargetBuffsVM:AddOrUpdateBuff(BufferID, BuffDefine.BuffSkillType.Combat, BuffInfo)
	end
end

---OnGameEventRemoveBuff
---@param Params FEventParams
function ActorMgr:OnGameEventRemoveBuff(Params)
	local BufferID = Params.IntParam1
	local Cfg = BuffCfg:FindCfgByKey(BufferID)
	if nil == Cfg then
		return
	end

	local EntityID = Params.ULongParam1
	local GiverID = (nil ~= Cfg.IsIndependent and Cfg.IsIndependent > 0) and Params.ULongParam2 or 0

	local ViewModel = self:FindActorVM(EntityID)
	if nil ~= ViewModel then
		ViewModel:RemoveBuff(BufferID, GiverID, BuffDefine.BuffSkillType.Combat)
	end

	if MainTargetBuffsVM:IsTarget(EntityID) then
		MainTargetBuffsVM:RemoveBuff(BufferID, GiverID, BuffDefine.BuffSkillType.Combat)
	end
end

function ActorMgr:OnGameEventUpdateBuffEffectiveState(Params)
	local EntityID = Params.ULongParam2
	local GiverID = Params.ULongParam2
	local BuffID = Params.IntParam1
	local Enable = Params.BoolParam1

	local ViewModel = self:FindActorVM(EntityID)
	if nil ~= ViewModel then
		ViewModel:SetBuffIsEffective(BuffID, GiverID, BuffDefine.BuffSkillType.Combat, Enable)
	end
end

function ActorMgr:AddOrUpdateLifeBuff(Buff, EntityID)
	EntityID = EntityID or Buff.EntityID
	
	local ViewModel = self:FindActorVM(EntityID)
	if nil ~= ViewModel then
		ViewModel:AddOrUpdateBuff(Buff.BuffID, BuffDefine.BuffSkillType.Life, Buff)
	end

	if MainTargetBuffsVM:IsTarget(EntityID) then
		MainTargetBuffsVM:AddOrUpdateBuff(Buff.BuffID, BuffDefine.BuffSkillType.Life, Buff)
	end
end

function ActorMgr:UpdateActorCache(Params)
	local EntityID = Params.ULongParam1
	local AttributeComp = ActorUtil.GetActorAttributeComponent(EntityID)
	local ObjType = AttributeComp and AttributeComp.ObjType or nil
	local SubType = AttributeComp and AttributeComp.SubType or nil
	if ObjType and SubType then
		local PWorldTableCfg = _G.PWorldMgr:GetCurrPWorldTableCfg()
		local PWorldType = (PWorldTableCfg ~= nil and PWorldTableCfg.Type or 0)
		local Config = PreCreateConfig:FindConfig(PWorldType, ObjType, SubType)

		-- 判断缓存池里的Actor数量是否需要进行填充，需要就开启分帧填充
		if Config then
			local VisionMgr = _G.UE.UVisionMgr.Get()
			local ActorAssetName = VisionMgr and VisionMgr:GetActorAssetName(ObjType, SubType) or nil
			local ObjectMgr = _G.UE.UObjectMgr.Get()
			local ActorManager = _G.UE.UActorManager.Get()
			local CacheCount = (ActorAssetName and ObjectMgr) and ObjectMgr:GetTotalCacheCount(ActorAssetName) or 0
			local FillToCount = Config.FillToCount or 0

			if CacheCount < (Config.MinFillThreshold or 0) and ActorManager and FillToCount > 0 then
				-- 分帧创建Actor入池
				-- MaxFillCount避免一次创建过多，多次Spawn会让数量越接近FillToCount
				ActorManager:SpawnCharactersToPool(ObjType, SubType, FillToCount, PreCreateConfig.MaxFillCount, true)
			end
		end
	end
end

function ActorMgr:RemoveLifeBuff(Buff, EntityID)
	EntityID = EntityID or Buff.EntityID

	local ViewModel = self:FindActorVM(EntityID)
	if nil ~= ViewModel then
		ViewModel:RemoveBuff(Buff.BuffID, Buff.GiverID, BuffDefine.BuffSkillType.Life)
	end

	if MainTargetBuffsVM:IsTarget(EntityID) then
		MainTargetBuffsVM:RemoveBuff(Buff.BuffID, Buff.GiverID, BuffDefine.BuffSkillType.Life)
	end
end

function ActorMgr:UpdateAllLifeBuff(EntityID)
	local ViewModel = self:FindActorVM(EntityID)
	if nil == ViewModel then
		return
	end

	ViewModel:UpdateBuffer()
end

function ActorMgr:OnGameEventAddOrUpdateBonusState(Params)
	if nil == Params then
		return
	end

	local ViewModel = self:FindActorVM(Params.EntityID)
	if nil == ViewModel then
		return
	end

	local State = Params.State
	ViewModel:AddOrUpdateBuff(State.ID, BuffDefine.BuffSkillType.BonusState, State)
end

function ActorMgr:OnGameEventRemoveBonusState(Params)
	if nil == Params then
		return
	end

	local ViewModel = self:FindActorVM(Params.EntityID)
	if nil == ViewModel then
		return
	end

	local State = Params.State
	ViewModel:RemoveBuff(State.ID, 0, BuffDefine.BuffSkillType.BonusState)
end

---OnGameEventActorHPChange
---@param Params FEventParams
function ActorMgr:OnGameEventActorHPChange(Params)
	local EntityID
	local CurHP
	local MaxHP

	if nil == Params then
		EntityID = MajorUtil.GetMajorEntityID()
		CurHP = MajorUtil.GetMajorCurHp()
		MaxHP = MajorUtil.GetMajorMaxHp()
	else
		EntityID = Params.ULongParam1
		CurHP = Params.ULongParam3
		MaxHP = Params.ULongParam4
	end

	local ViewModel = self:FindActorVM(EntityID)
	if nil == ViewModel then
		return
	end

	ViewModel:SetMaxHP(MaxHP)
	ViewModel:SetCurHP(CurHP)
end

---OnGameEventActorMPChange
---@param Params FEventParams
function ActorMgr:OnGameEventActorMPChange(Params)
	local EntityID
	local CurMP
	local MaxMP

	if nil == Params then
		EntityID = MajorUtil.GetMajorEntityID()
		CurMP = MajorUtil.GetMajorCurMp()
		MaxMP = MajorUtil.GetMajorMaxMp()
	else
		EntityID = Params.ULongParam1
		CurMP = Params.ULongParam3
		MaxMP = Params.ULongParam4
	end

	local ViewModel = self:FindActorVM(EntityID)
	if nil == ViewModel then
		return
	end

	ViewModel:SetMaxMP(MaxMP)
	ViewModel:SetCurMP(CurMP)
end

---OnGameEventActorGPChange
---@param Params FEventParams
function ActorMgr:OnGameEventActorGPChange(Params)
	local EntityID
	local CurGP
	local MaxGP

	if nil == Params then
		EntityID = MajorUtil.GetMajorEntityID()
		CurGP = MajorUtil.GetMajorCurGp()
		MaxGP = MajorUtil.GetMajorMaxGp()
	else
		EntityID = Params.ULongParam1
		CurGP = Params.ULongParam3
		MaxGP = Params.ULongParam4
	end

	local ViewModel = self:FindActorVM(EntityID)
	if nil == ViewModel then
		return
	end

	ViewModel:SetMaxGP(MaxGP)
	ViewModel:SetCurGP(CurGP)
end

function ActorMgr:OnCrafterExitRecipeState(EntityID)
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	if MajorEntityID == EntityID then
		local ViewModel = self:FindActorVM(MajorEntityID)
		if nil == ViewModel then
			return
		end

		local function DelaySetMK()
			if not self.MaxMK then
				self.MaxMK = MajorUtil.GetMajorMaxMk()
			end
			
			if not self.CurMK then
				self.CurMK = MajorUtil.GetMajorCurMk()
			end
			
			ViewModel:SetMaxMK(self.MaxMK)
			ViewModel:SetCurMK(self.CurMK)
		end

		_G.TimerMgr:AddTimer(nil, DelaySetMK, DelaySetMKTime, 1, 1)
	end
end

function ActorMgr:SendCommStatQueryReq()
    local MsgID = CS_CMD.CS_CMD_COMM_STAT
    local SubMsgID = ProtoCS.CS_COMM_STAT_CMD.CS_COMM_STAT_CMD_STATUS

    local MsgBody = {
        Cmd = SubMsgID,
        Leave = {}
    }

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function ActorMgr:OnCrafterSkillRsp(MsgBody)
    if MsgBody and MsgBody.CrafterSkill then
        local MajorEntityID = MajorUtil.GetMajorEntityID()
		if MajorEntityID == MsgBody.ObjID then
			local ViewModel = self:FindActorVM(MajorEntityID)
			if nil == ViewModel then
				return
			end

			local function DelaySetMK()
				if not self.MaxMK then
					self.MaxMK = MajorUtil.GetMajorMaxMk()
				end
				
				if not self.CurMK then
					self.CurMK = MajorUtil.GetMajorCurMk()
				end
				
				ViewModel:SetMaxMK(self.MaxMK)
				ViewModel:SetCurMK(self.CurMK)
			end
		
			if self.MaxMK == self.CurMK then
				_G.TimerMgr:AddTimer(nil, DelaySetMK, DelaySetMKTime, 1, 1)
			else
				DelaySetMK()
			end
		end
	end
end

---OnGameEventActorMKChange
---@param Params FEventParams
function ActorMgr:OnGameEventActorMKChange(Params)
	local EntityID
	local CurMK
	local MaxMK

	if nil == Params then
		EntityID = MajorUtil.GetMajorEntityID()
		CurMK = MajorUtil.GetMajorCurMk()
		MaxMK = MajorUtil.GetMajorMaxMk()
	else
		EntityID = Params.ULongParam1
		CurMK = Params.ULongParam3
		MaxMK = Params.ULongParam4
	end

	local ViewModel = self:FindActorVM(EntityID)
	if nil == ViewModel then
		return
	end

	if EntityID == MajorUtil.GetMajorEntityID() then
		self.CurMK = CurMK
		self.MaxMK = MaxMK

		if _G.CrafterMgr:GetIsMaking() then
			return
		end
	end

	ViewModel:SetMaxMK(MaxMK)
	ViewModel:SetCurMK(CurMK)
end

---OnGameEventPWorldExit
---@param Params FEventParams
function ActorMgr:OnGameEventPWorldExit(Params)
	print("ActorMgr:OnGameEventPWorldExit")
	self:ClearActor()
end

---OnGameEventBuddyCreate
---@param Params FEventParams
function ActorMgr:OnGameEventBuddyCreate(Params)
	local EntityID = Params.ULongParam1
	local VM = self:FindActorVM(EntityID)
	if nil ~= VM then
		VM:UpdateLevel()
	end
end

---AddViewModel
---@param EntityID number
---@private
function ActorMgr:AddViewModel(EntityID)
	-- added for performance tag, DO NOT REMOVE!
	local _ <close> = CommonUtil.MakeProfileTag("ActorMgr:AddViewModel")
	-- 目前因为ActorVM.New中有preload 4个item，所以会耗时占大头

	--注意return不要跳过FProfileTag.StaticEnd
	local Value, ViewModel
	do
		local _ <close> = CommonUtil.MakeProfileTag("ActorMgr:AddViewModel1")
		local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID)
		Value = { EntityID = EntityID, RoleID = RoleID }
		--local ViewModel = ActorVM.New()
		ViewModel = ObjectPoolMgr:AllocObject(ActorVM)
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("ActorMgr:AddViewModel2")
		ViewModel:UpdateVM(Value)
		self.ActorViewModels[EntityID] = ViewModel
	end

	return ViewModel
end

---只有后台更新了RoleSimple时，UpdateRoleVM才应该传true，否则可能导致旧数据覆盖RoleVM里的数据
---SetMajorRoleDetail
---@param RoleDetail table
function ActorMgr:SetMajorRoleDetail(RoleDetail, UpdateRoleVM)
	self.MajorRoleDetail = RoleDetail

	if nil ~= RoleDetail then
		_G.EquipmentMgr:OnEquipInfo(RoleDetail.Equip)
	end
	if UpdateRoleVM then
		_G.RoleInfoMgr:UpdateRoleVMByRoleDetail(RoleDetail)
	end
end

function ActorMgr:GetMajorRoleDetail()
	return self.MajorRoleDetail
end

---激活主角职业
---@param ProfData common.ProfData @职业数据 
function ActorMgr:ActiveMajorProf(ProfData)
	if nil == ProfData then
		return
	end

	local ProfID = ProfData.ProfID

	-- 更新主角详细信息
	local MajorRoleDetail = self.MajorRoleDetail
	if MajorRoleDetail then
		MajorRoleDetail.Prof.ProfList[ProfID] = ProfData
	end

	-- 更新主角RoleVM
	local RoleVM = MajorUtil.GetMajorRoleVM()
	if RoleVM then
		RoleVM:SetProfLevel(ProfID, ProfData.Level)
	end
end

--根据2个阵营和阵营关系表，获得阵营关系
function ActorMgr:GetActorCampRelation(ExecutorCamp, TargetCamp)
    -- 对自己施法，快速判定为友好的
    if (ExecutorCamp and TargetCamp) then
		local Relation = self.CampRelationCfgMap[ExecutorCamp]
		if Relation and Relation[TargetCamp] then
			return Relation[TargetCamp]
		end
    end

	return ProtoRes.camp_relation.camp_relation_enemy
end

function ActorMgr:GetTopOwner(Target)
    if (Target == nil) then
        return nil
    end

    local TargetOwner = Target
    while TargetOwner do
        local AttributeComp = TargetOwner:GetAttributeComponent()
        if AttributeComp and AttributeComp.Owner and AttributeComp.Owner > 0 then
            local OwnerActor = ActorUtil.GetActorByEntityID(AttributeComp.Owner)
            if OwnerActor then
                TargetOwner = OwnerActor
            else
                -- _G.FLOG_ERROR("GetTopOwner: Has Owner, but GetActor Failed" .. AttributeComp.Owner)
                break
            end
        else
            break
        end
    end

    return TargetOwner
end

function ActorMgr:ResetToolMap()
	self.EntityToolMap = {}
end

function ActorMgr:SetToolMap(EntityID, ToolID)
	self.EntityToolMap[EntityID] = ToolID
end

function ActorMgr:GetTool(EntityID)
    return self.EntityToolMap[EntityID]
end

function ActorMgr:GetPreloadResources()
	local List = {}
	-- 角色蓝图
	table.insert(List, "Class'/Game/BluePrint/Character/MajorBlueprint.MajorBlueprint_C'")
	table.insert(List, "Class'/Game/BluePrint/Character/PlayerBlueprint.PlayerBlueprint_C'")
	table.insert(List, "Class'/Game/BluePrint/Character/MonsterBlueprint.MonsterBlueprint_C'")
	table.insert(List, "Class'/Game/BluePrint/Character/NPCBlueprint.NPCBlueprint_C'")
	table.insert(List, "Class'/Game/BluePrint/Character/CompanionBlueprint.CompanionBlueprint_C'")
	table.insert(List, "Class'/Game/BluePrint/Character/GatherBlueprint.GatherBlueprint_C'")
	table.insert(List, "Class'/Game/BluePrint/Character/SummonBlueprint.SummonBlueprint_C'")
	table.insert(List, "Class'/Game/BluePrint/Character/EObjBlueprint.EObjBlueprint_C'")
	table.insert(List, "Class'/Game/BluePrint/Character/MonsterBlueprint.MonsterBlueprint_C'")
	table.insert(List, "Class'/Game/BluePrint/Character/BuddyBlueprint.BuddyBlueprint_C'")

	-- 动画蓝图
	table.insert(List, "Class'/Game/BluePrint/Animation/NpcAnimBlueprint.NpcAnimBlueprint_C'")
	table.insert(List, "Class'/Game/BluePrint/Animation/MonsterAnimBlueprint.MonsterAnimBlueprint_C'")
	table.insert(List, "Class'/Game/BluePrint/Animation/FaceAnimBlueprint.FaceAnimBlueprint_C'")
	table.insert(List, "AnimBlueprint'/Game/BluePrint/Animation/GeneralAnimBlueprint.GeneralAnimBlueprint_C'")

	-- Dither 材质
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Base_Combine_Dither.MI_Character_Base_Combine_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Base_Dither.MI_Character_Base_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_BentNormal_Dither.MI_Character_BentNormal_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Boss_Dither.MI_Character_Boss_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Combine_Dither.MI_Character_Combine_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Default_Dither.MI_Character_Default_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Equitment_Combine_Dither.MI_Character_Equitment_Combine_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Equitment_deferred_Dither.MI_Character_Equitment_deferred_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Equitment_Dither.MI_Character_Equitment_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Eyes_Dither.MI_Character_Eyes_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Hair_Dither.MI_Character_Hair_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_legacy_Hair_Dither.MI_Character_legacy_Hair_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Masked_Dither.MI_Character_Masked_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Skin_bake_Dither.MI_Character_Skin_bake_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Skin_Dither.MI_Character_Skin_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Skin_Combine_Dither.MI_Skin_Combine_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Base_Combine_NoEmissive_Dither.MI_Character_Base_Combine_NoEmissive_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Skin_Combine_Dither.MI_Character_Skin_Combine_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_Equitment_Combine_NoEmissive_Dither.MI_Character_Equitment_Combine_NoEmissive_Dither'")
	table.insert(List, "MaterialInstanceConstant'/Game/MaterialLibrary/MaterialInstanceTemplate/MI_Character_etc_Dither.MI_Character_etc_Dither'")

	-- 主mesh
	local RaceNum = 18
	for i = 1, RaceNum do
		table.insert(List, string.format("SkeletalMesh'/Game/Assets/Character/Human/Skeleton/c%02d01/Body/b0000/Model/SK_c%02d01b0000.SK_c%02d01b0000'", i, i, i))
	end

	-- 动画da
	for i = 1, RaceNum do
		table.insert(List, string.format("SeAnimDataAsset'/Game/Assets/Character/Human/Animation/DataAsset/SeDataAsset/c%02d01a0001.c%02d01a0001'", i, i))
	end

	table.insert(List, "Skeleton'/Game/Assets/Character/Human/Skeleton/c0101/face/f0001/Skeleton/SK_c0101f0001_Skeleton.SK_c0101f0001_Skeleton'")

	return List
end

function ActorMgr:PreCreateActors()
	local ActorManager = _G.UE.UActorManager.Get()
	local ObjectMgr = _G.UE.UObjectMgr.Get()
	local VisionMgr = _G.UE.UVisionMgr.Get()

	local PWorldTableCfg = _G.PWorldMgr:GetCurrPWorldTableCfg()
	local PWorldType = (PWorldTableCfg ~= nil and PWorldTableCfg.Type or 0)
	local WorldPreCreateConfig = PreCreateConfig[PWorldType]

	if WorldPreCreateConfig and ObjectMgr and ActorManager and VisionMgr then
		for _, Item in ipairs(WorldPreCreateConfig) do
			local ActorType = Item.ActorType
			local SubType = Item.SubType
			local Config = Item.Config
			local LimitCount = Config and Config.PoolLimitCount or nil
			local InitCount = Config and Config.InitCount or nil
			local ActorAssetName = (ActorType and SubType and VisionMgr) and VisionMgr:GetActorAssetName(ActorType, SubType) or nil

			if ActorAssetName and LimitCount and InitCount then
				ObjectMgr:ResizePool(ActorAssetName, 0, LimitCount)
				-- 同步创建角色
				ActorManager:SpawnCharactersToPool(ActorType, SubType, InitCount, InitCount, false)
			end
		end
	end
end

function ActorMgr:ForceShowNearbyNpcs(NearbyDistance)
	local ActorManager = _G.UE.UActorManager.Get()
	local MajorActor = MajorUtil.GetMajor()
	local MajorPos = MajorActor:FGetActorLocation()
	local NearbyDistanceSquare = NearbyDistance * NearbyDistance
	local EActorType = _G.UE.EActorType
	local AllNPCs = ActorManager:GetActorsByType(EActorType.Npc)
	local Length = AllNPCs:Length()
	for i = 1, Length do
		local NPC = AllNPCs:GetRef(i)
		local NPCPos = NPC:FGetActorLocation()
		local NPCDistanceSqure = ((NPCPos.X - MajorPos.X) ^ 2) + ((NPCPos.Y - MajorPos.Y) ^ 2) + ((NPCPos.Z - MajorPos.Z) ^ 2)
		if NPCDistanceSqure <= NearbyDistanceSquare then
			NPC:SetActorHiddenInGame(false)
		end
	end
end

return ActorMgr