
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ActorUtil = require("Utils/ActorUtil")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local BuddySkillCfg = require("TableCfg/BuddySkillCfg")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local BuddyEquipCfg = require("TableCfg/BuddyEquipCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local BuddyAiCfg = require("TableCfg/BuddyAiCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local AudioUtil = require("Utils/AudioUtil")
local BuddyGlobalCfg = require("TableCfg/BuddyGlobalCfg")
local BuddySkillLevelCfg = require("TableCfg/BuddySkillLevelCfg")
local BuddyDefine = require("Game/Buddy/BuddyDefine")
local SaveKey = require("Define/SaveKey")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local ChocoboArmorPos = ProtoCS.ChocoboArmorPos

local EquipPart = ProtoCommon.equip_part
local CS_CMD = ProtoCS.CS_CMD

local EventMgr
local GameNetworkMgr
local LSTR
local ModuleOpenMgr
local RedDotMgr
local USaveMgr

local CS_CMD_BUDDY = CS_CMD.CS_CMD_BUDDY
local BUDDY_SUB_MSG_ID = ProtoCS.BuddyCmd
local CS_CMD_CHOCOBO = CS_CMD.CS_CMD_CHOCOBO
local CHOCOBO_SUB_MSG_ID = ProtoCS.ChocoboCmd

local BuddyMgr = LuaClass(MgrBase)

BuddyMgr.SkillType = {DefenceSkill = 1, HealthSkill = 2, AttackSkill = 3}
BuddyMgr.BuddyID = -1

function BuddyMgr:OnBegin()
	EventMgr = _G.EventMgr
	GameNetworkMgr = _G.GameNetworkMgr
	LSTR = _G.LSTR
	ModuleOpenMgr = _G.ModuleOpenMgr
	RedDotMgr = _G.RedDotMgr
	USaveMgr = _G.UE.USaveMgr

	self:ReadSaveKeyData()
end

function BuddyMgr:OnInit()
	self.MasterBuddyMap = {}
	self.BuddyInfoMap = {}	--记录当前视野里所有的陆行鸟的距离，用来控制哪些显示哪些隐藏
	self.CDTime = nil

	self.DyeCDTable = {}
    self.ColorTable = {} --记录搭档和陆行鸟的颜色
    self.ArmorTable = {} --记录搭档和陆行鸟的装备
    self.SurfaceViewCurID = nil

    local Cfg = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_BUDDY_DYE_CD, "Value")
	if Cfg then
		self.DyeCDTime =  Cfg[1] or 21600
	end

	local GlobalCfg = BuddyGlobalCfg:FindValue(ProtoRes.BuddyGlobalCfgID.BuddyGlobalCfgIDDigestiveFruit, "Value")
	if GlobalCfg then
		self.AccelerateItemID = GlobalCfg[1] or 61000018
	end

	GlobalCfg = BuddyGlobalCfg:FindValue(ProtoRes.BuddyGlobalCfgID.BuddyGlobalCfgIDVegetable, "Value")
	if GlobalCfg then
		self.CallTimeItemID = GlobalCfg[1] or 61000008
	end

	GlobalCfg = BuddyGlobalCfg:FindValue(ProtoRes.BuddyGlobalCfgID.BuddyGlobalCfgIDBreakThrough, "Value")
	if GlobalCfg then
		self.BreakThroughItemID = GlobalCfg[1] or 61000016
	end

	GlobalCfg = BuddyGlobalCfg:FindValue(ProtoRes.BuddyGlobalCfgID.BuddyGlobalCfgIDOutTimeLimit, "Value")
	if GlobalCfg then
		self.BuddyTotalTime = GlobalCfg[1] or 3600
	end
end

function BuddyMgr:OnEnd()
	self.BuddyEntityID = nil
	self.QueryInfo = nil

	if self.BuddyTimeID then
		self:UnRegisterTimer(self.BuddyTimeID)
		self.BuddyTimeID = nil
	end
end

function BuddyMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD_BUDDY, BUDDY_SUB_MSG_ID.BuddyCmdCall, self.OnNetMsgBuddyCall)
	self:RegisterGameNetMsg(CS_CMD_BUDDY, BUDDY_SUB_MSG_ID.BuddyCmdQuery, self.OnNetMsgBuddyQuery)
	self:RegisterGameNetMsg(CS_CMD_BUDDY, BUDDY_SUB_MSG_ID.BuddyCmdTrain, self.OnNetMsgBuddyTrain)
	self:RegisterGameNetMsg(CS_CMD_BUDDY, BUDDY_SUB_MSG_ID.BuddyCmdAIOn, self.OnNetMsgBuddyUseAI)
	self:RegisterGameNetMsg(CS_CMD_BUDDY, BUDDY_SUB_MSG_ID.BuddyCmdLearnSkill, self.OnNetMsgBuddyLearnSkill)

	self:RegisterGameNetMsg(CS_CMD_BUDDY, BUDDY_SUB_MSG_ID.BuddyLevelExpUpdate, self.OnNetMsgBuddyLevelExpUpdate)
	self:RegisterGameNetMsg(CS_CMD_BUDDY, BUDDY_SUB_MSG_ID.BuddyCmdSkillReset, self.OnNetMsgSkillReset)
	self:RegisterGameNetMsg(CS_CMD_BUDDY, BUDDY_SUB_MSG_ID.BuddyArmorRepoUpdate, self.OnNetMsgArmorRepoUpdate)
	self:RegisterGameNetMsg(CS_CMD_BUDDY, BUDDY_SUB_MSG_ID.BuddyTimeUpdate, self.OnNetMsgBuddyTimeUpdate)
	self:RegisterGameNetMsg(CS_CMD_BUDDY, BUDDY_SUB_MSG_ID.BuddyBuffUpdate, self.OnNetMsgBuddyBuffUpdate)

	self:RegisterGameNetMsg(CS_CMD_BUDDY, BUDDY_SUB_MSG_ID.BuddyCmdRename, self.OnNetMsgBuddyRename)

	-----装甲，染色
	self:RegisterGameNetMsg(CS_CMD_CHOCOBO, CHOCOBO_SUB_MSG_ID.ChocoboCmdUsedColor, self.OnNetMsgUsedColor)   --查询染色库
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO, CHOCOBO_SUB_MSG_ID.ChocoboCmdUsedArmor, self.OnNetMsgUsedArmor)  --查询装甲库
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO, CHOCOBO_SUB_MSG_ID.ChocoboCmdArmorRepoUpdate, self.OnNetMsgArmorRepoUpdate)--装甲库更新

    self:RegisterGameNetMsg(CS_CMD_CHOCOBO, CHOCOBO_SUB_MSG_ID.ChocoboCmdDyeColor, self.OnNetMsgDyeColor)   --染色
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO, CHOCOBO_SUB_MSG_ID.ChocoboCmdArmor, self.OnNetMsgArmor)  --鸟甲
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO, CHOCOBO_SUB_MSG_ID.ChocoboCmdReduceCD, self.OnNetMsgReduceCD)--减少染色CD
	
end

function BuddyMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify) --系统解锁

	self:RegisterGameEvent(EventID.BuddyCreate, self.OnGameEventBuddyCreate)
	self:RegisterGameEvent(EventID.ActorDestroyed, self.OnGameEventActorDestroyed)
	self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnGameEventMajorLevelUpdate)
	self:RegisterGameEvent(EventID.VisionLevelChange, self.OnGameEventOtherLevelUpdate)

	--self:RegisterGameEvent(EventID.BuddyDestroy, self.OnGameEventBuddyDestroy)
	self:RegisterGameEvent(EventID.OtherCharacterDead, self.OnGameEventCharacterDead)
end

---搭档召唤或者解散
function BuddyMgr:SendBuddyCallMessage(CallOut)
	local MsgID = CS_CMD_BUDDY
	local SubMsgID = BUDDY_SUB_MSG_ID.BuddyCmdCall
	local MsgBody = {
		Cmd = BUDDY_SUB_MSG_ID.BuddyCmdCall,
		Call = { CallOut = CallOut },
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BuddyMgr:OnGameEventCharacterDead(Params)
	local EntityID = Params.ULongParam1
	if self.BuddyEntityID == EntityID then
		self.BuddyEntityID = nil

		self:SendBuddyQueryMessage()
		self.DestoryBuddyTimeId = _G.TimerMgr:AddTimer(self, self.DestoryBuddy, 4, 4, 1)
	end
end

function BuddyMgr:DestoryBuddy()
	_G.TimerMgr:CancelTimer(self.DestoryBuddyTimeId)
	self.DestoryBuddyTimeId = nil
	EventMgr:SendEvent(EventID.BuddyQueryInfo)
end


function BuddyMgr:OnNetMsgBuddyCall(MsgBody)
	if nil == MsgBody.Call then
		return
	end

	if MsgBody.Call.CallOut == true then
		if MajorUtil.IsMajor(MsgBody.Call.MasterEntityID) then
			self.BuddyEntityID = MsgBody.Call.BuddyEntityID
			self:SetBuddyOuting(true)
		else
			self.BuddyEntityID = nil
			self:SetBuddyOuting(false)
		end
	else
		if MajorUtil.IsMajor(MsgBody.Call.MasterEntityID) then
			self.BuddyEntityID = nil
			self:SetBuddyOuting(false)
			self:SendBuddyQueryMessage()
		end
	end
	
	local Buddy = ActorUtil.GetActorByEntityID(MsgBody.Call.BuddyEntityID)
	if nil ~= Buddy and MsgBody.Call.CallOut == false then
		Buddy:Leave()
	end

	EventMgr:SendEvent(EventID.BuddyQueryInfo)
end

---查询搭档信息
function BuddyMgr:SendBuddyQueryMessage()
	local MsgID = CS_CMD_BUDDY
	local SubMsgID = BUDDY_SUB_MSG_ID.BuddyCmdQuery
	local MsgBody = {
		Cmd = BUDDY_SUB_MSG_ID.BuddyCmdQuery,
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BuddyMgr:OnNetMsgBuddyQuery(MsgBody)
	if nil == MsgBody.Info then
		return
	end

	local Info = MsgBody.Info

	local Color = Info.Color
	if Color ~= nil then
		self:SetChocoboColor(BuddyMgr.BuddyID, Color)
	end

	local Armor = Info.Armor
	if Armor ~= nil then
		self:SetChocoboArmor(BuddyMgr.BuddyID, Armor)
	end
	
	self.QueryInfo = Info
	self:SetBuddyTime()
	
	EventMgr:SendEvent(EventID.BuddyQueryInfo)

	self:UpdateBuddyUpLevelRedDot()
end


-----染色,装甲相关请求
function BuddyMgr:ReqUsedColor()
    local MsgID = CS_CMD_CHOCOBO
	local SubMsgID = CHOCOBO_SUB_MSG_ID.ChocoboCmdUsedColor
	local MsgBody = {
		Cmd = CHOCOBO_SUB_MSG_ID.ChocoboCmdUsedColor,
		UsedColor = {},
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BuddyMgr:ReqUsedArmor()
    local MsgID = CS_CMD_CHOCOBO
	local SubMsgID = CHOCOBO_SUB_MSG_ID.ChocoboCmdUsedArmor
	local MsgBody = {
		Cmd = CHOCOBO_SUB_MSG_ID.ChocoboCmdUsedArmor,
		UsedArmor = {},
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BuddyMgr:ReqArmor(ID, Armor, Pos)
	local MsgID = CS_CMD_CHOCOBO
	local SubMsgID = CHOCOBO_SUB_MSG_ID.ChocoboCmdArmor
	local MsgBody = {
		Cmd = CHOCOBO_SUB_MSG_ID.ChocoboCmdArmor,
		Armor = {ID = ID, Armor =  Armor, Pos = Pos},
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BuddyMgr:ReqDyeColor(ID, DyeType, TargetColorID, DyeLists)
    local MsgID = CS_CMD_CHOCOBO
	local SubMsgID = CHOCOBO_SUB_MSG_ID.ChocoboCmdDyeColor
	local MsgBody = {
		Cmd = CHOCOBO_SUB_MSG_ID.ChocoboCmdDyeColor,
		DyeColor = {ID = ID, Type =  DyeType, TargetColorID = TargetColorID, Dyestuffs = DyeLists},
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

end

function BuddyMgr:ReqReduceCD(ID, ConsumeCoin, ReduceItemID)
	local MsgID = CS_CMD_CHOCOBO
	local SubMsgID = CHOCOBO_SUB_MSG_ID.ChocoboCmdReduceCD
	local MsgBody = {
		Cmd = CHOCOBO_SUB_MSG_ID.ChocoboCmdReduceCD,
		ReduceCD = {ID = ID, Consume =  ConsumeCoin, ItemID = ReduceItemID},
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


-------染色,装甲相关请求 end
---------染色,装甲相关回包
---
function BuddyMgr:OnNetMsgUsedArmor(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("BuddyMgr:OnNetMsgUsedArmor: MsgBody is nil")
        return
    end
    local UsedArmor = MsgBody.UsedArmor
    if nil == UsedArmor then
        return
    end

    self.UsedArmors = UsedArmor.UsedArmors
end

function BuddyMgr:OnNetMsgArmor(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("BuddyMgr:OnNetMsgArmor: MsgBody is nil")
        return
    end

    local Armor = MsgBody.Armor
    if nil == Armor then
        return
    end
    self:UpdateChocoboArmor(Armor.ID, Armor.Armor, Armor.Pos)

	local Params = {}
	Params.ID = Armor.ID
    EventMgr:SendEvent(EventID.BuddyEquipmentUpdate, Params)
end

function BuddyMgr:OnNetMsgArmorRepoUpdate(MsgBody)
	if nil == MsgBody then
        FLOG_ERROR("BuddyMgr:OnNetMsgArmorRepoUpdate: MsgBody is nil")
        return
    end
    if nil == MsgBody.ArmorUnlock then
		return
	end

	if nil == self.UsedArmors then
		self.UsedArmors = {}
	end
	table.insert(self.UsedArmors, MsgBody.ArmorUnlock.Armor)
end

function BuddyMgr:OnNetMsgUsedColor(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("BuddyMgr:OnNetMsgUsedColor: MsgBody is nil")
        return
    end
    local UsedColor = MsgBody.UsedColor
    if nil == UsedColor then
        return
    end
    
    self.UsedColors = UsedColor.UsedColors
end

function BuddyMgr:OnNetMsgDyeColor(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("BuddyMgr:OnNetMsgDyeColor: MsgBody is nil")
        return
    end

    local DyeColor = MsgBody.DyeColor
    if nil == DyeColor then
        return
    end

    if self.ColorTable[DyeColor.ID] == nil then
        self.ColorTable[DyeColor.ID] = {}
    end
    self.ColorTable[DyeColor.ID].CD = DyeColor.CDTime
    self.ColorTable[DyeColor.ID].TargetRGB = DyeColor.TargetColorID

    self:CheckInDyeCD(DyeColor.ID ,DyeColor.CDTime ,DyeColor.TargetColorID)
    if DyeColor.CDTime <= TimeUtil.GetServerLogicTime() then
        self.ColorTable[DyeColor.ID].RGB = DyeColor.TargetColorID
		MsgTipsUtil.ShowTips(_G.LSTR(1000001)) 
    end

	local Params = {}
	Params.ID = DyeColor.ID
    EventMgr:SendEvent(EventID.BuddyDyeUpdate, Params)
end

function BuddyMgr:OnNetMsgReduceCD(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("BuddyMgr:OnNetMsgReduceCD: MsgBody is nil")
        return
    end

    local ReduceCD = MsgBody.ReduceCD
    if nil == ReduceCD then
        return
    end

    if self.ColorTable[ReduceCD.ID] == nil then
        return
    end

    self.ColorTable[ReduceCD.ID].CD = ReduceCD.CD
	self:UpdateDyeCD({ID = ReduceCD.ID})
	
	local Params = {}
	Params.ID = ReduceCD.ID
	EventMgr:SendEvent(EventID.BuddyDyeUpdate, Params)
end

-----染色,装甲相关回包 end

function BuddyMgr:SendBuddyTrainMessage(ItemID)
	local MsgID = CS_CMD_BUDDY
	local SubMsgID = BUDDY_SUB_MSG_ID.BuddyCmdTrain
	local MsgBody = {
		Cmd = BUDDY_SUB_MSG_ID.BuddyCmdTrain,
		Train = { Food =  ItemID},
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BuddyMgr:OnNetMsgBuddyTrain(MsgBody)
	if nil == MsgBody.Train then
		return
	end
	if nil == self.QueryInfo then
		return
	end
	self.QueryInfo.Accomplish.FavFood = MsgBody.Train.FavFood

	EventMgr:SendEvent(EventID.BuddyUpdateStatus)
end

function BuddyMgr:OnNetMsgBuddyBuffUpdate(MsgBody)
	if nil == MsgBody.Buff then
		return
	end
	if nil == self.QueryInfo then
		return
	end

	self.QueryInfo.Status.Buff = MsgBody.Buff.BuffID 
	EventMgr:SendEvent(EventID.BuddyUpdateStatus)
end

function BuddyMgr:SendBuddyUseAIMessage(AIStrategy)
	local MsgID = CS_CMD_BUDDY
	local SubMsgID = BUDDY_SUB_MSG_ID.BuddyCmdAIOn
	local MsgBody = {
		Cmd = BUDDY_SUB_MSG_ID.BuddyCmdAIOn,
		AI = { AI =  AIStrategy},
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BuddyMgr:OnNetMsgBuddyUseAI(MsgBody)
	if nil == MsgBody.AI then
		return
	end

	if nil == self.QueryInfo then
		return
	end

	self.QueryInfo.Ability.AI = MsgBody.AI.AI
	EventMgr:SendEvent(EventID.BuddyQueryInfo)

	local CfgSearchCond = string.format("Strategy == %d", MsgBody.AI.AI)
	local AiCfg = BuddyAiCfg:FindCfg(CfgSearchCond)
	if AiCfg == nil then
		return
	end
	
	_G.MsgTipsUtil.ShowTips(string.format(_G.LSTR(1000002), RichTextUtil.GetText(AiCfg.Name, "d1ba8e")))

	local TacticsSound = AiCfg.TacticsSound
	if not string.isnilorempty(TacticsSound) then
		AudioUtil.LoadAndPlayUISound(TacticsSound)
	end
end

function BuddyMgr:SendBuddyLearnSkillMessage(ID)
	local MsgID = CS_CMD_BUDDY
	local SubMsgID = BUDDY_SUB_MSG_ID.BuddyCmdLearnSkill
	local MsgBody = {
		Cmd = BUDDY_SUB_MSG_ID.BuddyCmdLearnSkill,
		LearnSkill = { SkillID =  ID},
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BuddyMgr:OnNetMsgBuddyLearnSkill(MsgBody)
	if nil == MsgBody.LearnSkill then
		return
	end

	if nil == self.QueryInfo then
		return
	end
	
	local LearnSkill = BuddySkillCfg:FindCfgByKey(MsgBody.LearnSkill.SkillID)
	if LearnSkill.Type == BuddyMgr.SkillType.DefenceSkill then
		table.insert(self.QueryInfo.Ability.DefenceSkill, MsgBody.LearnSkill.SkillID)
	 elseif LearnSkill.Type == BuddyMgr.SkillType.HealthSkill then
		table.insert(self.QueryInfo.Ability.HealthSkill, MsgBody.LearnSkill.SkillID)
	 elseif LearnSkill.Type == BuddyMgr.SkillType.AttackSkill  then
		table.insert(self.QueryInfo.Ability.AttackSkill, MsgBody.LearnSkill.SkillID)
	 end

	 _G.MsgTipsUtil.ShowTips(string.format(_G.LSTR(1000003), RichTextUtil.GetText(string.format("“%s”", LearnSkill.Name) , "d1ba8e")))

	self.QueryInfo.LevelExp.Unassigned = MsgBody.LearnSkill.Unassigned
	EventMgr:SendEvent(EventID.BuddyUpdateAbility)
end

function BuddyMgr:CanBreakThrough()
	if BuddyMgr.QueryInfo == nil or BuddyMgr.QueryInfo.LevelExp == nil then
		return false
	end

	local BuddyLevelExp = BuddyMgr.QueryInfo.LevelExp
	local SkillLevelCfg = BuddySkillLevelCfg:FindCfgByKey(BuddyLevelExp.Level)
	local NextLevelCfg = BuddySkillLevelCfg:FindCfgByKey(BuddyLevelExp.Level + 1)
	if SkillLevelCfg == nil or NextLevelCfg == nil then
		return false
	end

	local CurExp = BuddyLevelExp.Exp
	local MaxExp = SkillLevelCfg.Exp
	return NextLevelCfg.NeedBreak == 1 and CurExp == MaxExp
end

function BuddyMgr:IsMaxLevel()
	if BuddyMgr.QueryInfo == nil or BuddyMgr.QueryInfo.LevelExp == nil then
		return false
	end

	local BuddyLevelExp = BuddyMgr.QueryInfo.LevelExp
	local SkillLevelCfg = BuddySkillLevelCfg:FindCfgByKey(BuddyLevelExp.Level + 1)
	if SkillLevelCfg == nil then
		return true
	end

	return false
end

function BuddyMgr:OnNetMsgBuddyLevelExpUpdate(MsgBody)
	if nil == MsgBody.LevelExp then
		return
	end
	if nil == self.QueryInfo then
		return
	end
	self.QueryInfo.LevelExp.Level = MsgBody.LevelExp.Level
	self.QueryInfo.LevelExp.Exp = MsgBody.LevelExp.Exp
	EventMgr:SendEvent(EventID.BuddyUpdateAbility)
	self:UpdateBuddyUpLevelRedDot()
end

function BuddyMgr:OnNetMsgSkillReset(MsgBody)
	if nil == MsgBody.ResetSkill then
		return
	end

	if nil == self.QueryInfo then
		return
	end

	self.QueryInfo.LevelExp.Unassigned = MsgBody.ResetSkill.Unassigned
end

function BuddyMgr:OnGameEventLoginRes(Params)
	if not ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBuddy) then
        return
    end
	self:SendBuddyQueryMessage()
end

function BuddyMgr:OnModuleOpenNotify(InModuleID)
    if InModuleID == ProtoCommon.ModuleID.ModuleIDBuddy then
        self:SendBuddyQueryMessage()
    end
end

function BuddyMgr:OnGameEventBuddyCreate(Params)
    local BuddyEntityID = Params.ULongParam1
	local MasterEntityID = Params.ULongParam2
	local IsMajorBuddy = false
	if MajorUtil.IsMajor(MasterEntityID) then
		self.BuddyEntityID = BuddyEntityID
		self:SetBuddyOuting(true)
		EventMgr:SendEvent(EventID.BuddyQueryInfo)
		IsMajorBuddy = true
	else
		-- 记录非主角的陆行鸟搭档，用于根据距离更新显隐
		-- 这个事件会重复抛，而且MasterEntityID可能为0，分不清是否是主角...
		self.BuddyInfoMap = self.BuddyInfoMap or {}
		if not table.containAttr(self.BuddyInfoMap, BuddyEntityID, "ID") then
			table.insert(self.BuddyInfoMap, {ID = BuddyEntityID, Dist = 0, IsHide = false})
		end
	end

	if nil ~= MasterEntityID and MasterEntityID ~= 0 then
		self.MasterBuddyMap[MasterEntityID] = BuddyEntityID

		--当非主角陆行鸟搭档创建时，且Master更新了，更新下显隐性
		if not IsMajorBuddy then
			self:UpdateBuddyVisibility()
		end
	end
end

function BuddyMgr:OnGameEventActorDestroyed(Params)
    local BuddyEntityID = Params.ULongParam1
	local result = table.remove_item(self.BuddyInfoMap, BuddyEntityID, "ID")
	if result ~= nil then
		self:UpdateBuddyVisibility()
	end
end

-- 更新陆行鸟搭档的显隐，主角的一定显示，其余只显示最近的2个
function BuddyMgr:UpdateBuddyVisibility()
	local CommonDefine = require("Define/CommonDefine")
	if not CommonDefine.bVisionEnableBuddyControl then return end

	local Major = MajorUtil.GetMajor()
	if not _G.CommonUtil.IsObjectValid(Major) then
		return
	end
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	local MajorBuddyEntityID = (self.MasterBuddyMap or {})[MajorEntityID]
	local FindMajorBuddy = false
	local MajorPos = Major:K2_GetActorLocation()
	-- 更新距离的同时，全部默认隐藏
	for _, info in ipairs(self.BuddyInfoMap) do
		local Buddy = ActorUtil.GetExistActorByEntityID(info.ID)
		if Buddy ~= nil then
			--如果发现主角的陆行鸟，直接显示，之后会从BuddyInfoMap中移除
			--向BuddyInfoMap添加时很难判断是否是主角的，因此需要在这里处理
			if MajorBuddyEntityID == info.ID then
				Buddy:SetVisibility(true, _G.UE.EHideReason.Settings, true)
				FindMajorBuddy = true
			else
				local BuddyPos = Buddy:K2_GetActorLocation()
				info.Dist = _G.UE.FVector.Dist2D(MajorPos, BuddyPos)
			end
		end
	end
	if FindMajorBuddy then
		-- 这里面可能有主角的陆行鸟，排序前移除
		table.remove_item(self.BuddyInfoMap, MajorBuddyEntityID, "ID")
	end
	table.sort(self.BuddyInfoMap, function(a, b)
		return a.Dist < b.Dist;
	end)
	for i = 1, #self.BuddyInfoMap do
		local Buddy = ActorUtil.GetExistActorByEntityID(self.BuddyInfoMap[i].ID)
		if Buddy ~= nil then
			if i <= CommonDefine.VisionBuddyShowNum then
				if self.BuddyInfoMap[i].IsHide then
					Buddy:SetVisibility(true, _G.UE.EHideReason.Settings, true)
					self.BuddyInfoMap[i].IsHide = false
				end
			elseif not self.BuddyInfoMap[i].IsHide then
				Buddy:SetVisibility(false, _G.UE.EHideReason.Settings, true)
				self.BuddyInfoMap[i].IsHide = true
			end
		end
	end
end

function BuddyMgr:OnGameEventMajorLevelUpdate(Params)
	self:OnBuddyLevelUpdate(self.BuddyEntityID, MajorUtil.GetMajorLevel())
end

function BuddyMgr:OnGameEventOtherLevelUpdate(Params)
	if nil == Params or nil == Params.ULongParam1 then
		return
	end
	local BuddyEntityID = self.MasterBuddyMap[Params.ULongParam1]
	local Master = ActorUtil.GetActorByEntityID(Params.ULongParam1)
	self:OnBuddyLevelUpdate(BuddyEntityID, Master:GetAttributeComponent().Level)
end

function BuddyMgr:OnBuddyLevelUpdate(BuddyEntityID, NewLevel)
	if self:IsBuddyOuting() == false or nil == NewLevel then
		return
	end

	local Buddy = ActorUtil.GetActorByEntityID(BuddyEntityID)
	if nil == Buddy then
		return
	end

	local OldLevel = Buddy:GetAttributeComponent().Level
	Buddy:GetAttributeComponent().Level = NewLevel

	local EventParams = {}
	EventParams.ULongParam1 = BuddyEntityID
	EventParams.ULongParam2 = ProtoCS.LevelUpReason.LevelUpReasonScene
	EventParams.ULongParam4 = OldLevel
	EventMgr:SendEvent(EventID.VisionLevelChange, EventParams)
end

function BuddyMgr:GetBuddyUseAI()
	if self:IsBuddyOuting() == false then
		return nil
	end

	if self.QueryInfo == nil or self.QueryInfo.Ability == nil then
		return nil
	end
	return self.QueryInfo.Ability.AI
end

function BuddyMgr:GetBuddyFavFood()
	if self:IsBuddyOuting() == false then
		return nil
	end

	if self.QueryInfo == nil or self.QueryInfo.Accomplish == nil or self.QueryInfo.Accomplish.FavFood == nil then
		return nil
	end

	return self.QueryInfo.Accomplish.FavFood.Favorite
end

function BuddyMgr:IsBuddyOuting()
	if self.QueryInfo == nil or self.QueryInfo.Status == nil then
		return false
	end

	return self.QueryInfo.Status.Outing == true
end

function BuddyMgr:SetBuddyOuting(Outing)
	if nil == self.QueryInfo then
		return
	end

	if self.QueryInfo == nil or self.QueryInfo.Status == nil then
		return
	end

	self.QueryInfo.Status.Outing = Outing
end

function BuddyMgr:GetBuddyBuff()
	if self:IsBuddyOuting() == false then
		return nil
	end

	if self.QueryInfo == nil or self.QueryInfo.Status == nil then
		return nil
	end

	return self.QueryInfo.Status.Buff
end

function BuddyMgr:GetAbilitySkills(Type)
	if self.QueryInfo == nil then
		return nil
	end
	if Type == BuddyMgr.SkillType.DefenceSkill then
       return self.QueryInfo.Ability.DefenceSkill
    elseif Type == BuddyMgr.SkillType.HealthSkill then
        return self.QueryInfo.Ability.HealthSkill
    elseif Type == BuddyMgr.SkillType.AttackSkill  then
        return self.QueryInfo.Ability.AttackSkill
    end
end

function BuddyMgr:GetSkillUnassigned()
	if self.QueryInfo == nil or self.QueryInfo.LevelExp == nil then
		return 0
	end

	return self.QueryInfo.LevelExp.Unassigned
end

function BuddyMgr:CanCallBuddy()
	local CurMapID = _G.PWorldMgr:GetCurrMapResID()
	local CurrMapCfg = _G.PWorldMgr:GetMapTableCfg(CurMapID)
	if CurrMapCfg then
		return CurrMapCfg.SummonBuddy == 1 and self.DestoryBuddyTimeId == nil
	end

	return false
end


--装甲染色相关
function BuddyMgr:GetUsedArmors()
	return self.UsedArmors
end

function BuddyMgr:GetSurfaceArmor()
    if self.SurfaceViewCurID  == nil then
        return nil
    end
    
    return self.ArmorTable[self.SurfaceViewCurID]
end

function BuddyMgr:SetChocoboArmor(ID, Armor)
    self.ArmorTable[ID] = Armor
end

function BuddyMgr:UpdateChocoboArmor(ID, Armor, Pos)
    if self.ArmorTable[ID] == nil then
        return
    end

    local ArmorID = Armor
	if ArmorID == 0 then
		if Pos == ChocoboArmorPos.ChocoboArmorPosHead then
            self.ArmorTable[ID].Head = 0
		elseif Pos == ChocoboArmorPos.ChocoboArmorPosBody then
            self.ArmorTable[ID].Body = 0
		elseif Pos == ChocoboArmorPos.ChocoboArmorPosLeg then
            self.ArmorTable[ID].Feet = 0
		end	
	else
		local BuddyEquip = BuddyEquipCfg:FindCfgByKey(ArmorID)
		if BuddyEquip then
			if BuddyEquip.Part == EquipPart.EQUIP_PART_HEAD then
                self.ArmorTable[ID].Head = ArmorID
			elseif BuddyEquip.Part == EquipPart.EQUIP_PART_BODY then
				self.ArmorTable[ID].Body = ArmorID
			elseif BuddyEquip.Part == EquipPart.EQUIP_PART_LEG then
				self.ArmorTable[ID].Feet = ArmorID
			end
		end
	end
end

function BuddyMgr:GetSurfaceColor()
    if self.SurfaceViewCurID  == nil then
        return nil
    end
	return self.ColorTable[self.SurfaceViewCurID]
end

function BuddyMgr:BLockColor(ColorID)
	local Colors = self.UsedColors
	if Colors == nil then
		return true
	end

	for i = 1, #Colors do
		if ColorID == Colors[i] then
			return false
		end
	end
	
	return true
end


function BuddyMgr:SetChocoboColor(ID, Color)
    self.ColorTable[ID] = Color
    self:CheckInDyeCD(ID, Color.CD, Color.TargetRGB)
end

function BuddyMgr:GetChocoboColor(ID)
	local ColorID =  self.ColorTable[ID]
	return ColorID
end 

function BuddyMgr:SurfaceBInDyeCD()
    if self.SurfaceViewCurID == nil then
        return false
    end

	if self.ColorTable == nil then
		return false
	end

    local Color = self.ColorTable[self.SurfaceViewCurID]
	if nil == Color then
		return false
	end
	
	return Color.CD > TimeUtil.GetServerLogicTime()
end

function BuddyMgr:GetSurfaceCDTime()
	if self.SurfaceViewCurID  == nil then
        return 0
    end

    local Color = self.ColorTable[self.SurfaceViewCurID]
	if nil == Color then
		return 0
	end
	local CurTime = TimeUtil.GetServerLogicTime()
	if Color.CD > CurTime then
		return Color.CD - CurTime 
	end

	return 0
end


function BuddyMgr:CheckInDyeCD(ID, CD, TargetRGB)
    if CD > TimeUtil.GetServerLogicTime() then
        if self.DyeCDTable[ID] == nil then
            self.DyeCDTable[ID] = {}
		    local TimeId = _G.TimerMgr:AddTimer(self, self.UpdateDyeCD, 0, 0.1, 0, {ID = ID})
		    self.DyeCDTable[ID].TimeId = TimeId
        end
        self.DyeCDTable[ID].TargetRGB = TargetRGB
	end
end

function BuddyMgr:UpdateDyeCD(Params)
	local ID = Params.ID
	local DyeCDData = self.DyeCDTable[ID]
    local Color = self.ColorTable[ID]
	if DyeCDData == nil or Color == nil then
		return
	end

	if Color.CD <= TimeUtil.GetServerLogicTime() then -- 关闭组计时器时间
        local TargetRGB = DyeCDData.TargetRGB
        self:EndDyeCDTime(ID, TargetRGB)
        
        table.insert(self.UsedColors, TargetRGB)
		self.DyeCDTable[ID] = nil
        EventMgr:SendEvent(EventID.BuddyCDOnTime, ID)
		_G.TimerMgr:CancelTimer(DyeCDData.TimeId)
        MsgTipsUtil.ShowTips(_G.LSTR(1000004)) 
        return
	end

	EventMgr:SendEvent(EventID.BuddyCDOnTime, ID)

end

function BuddyMgr:EndDyeCDTime(ID, TargetRGB)
    if self.ColorTable[ID] == nil then
        return
    end

    self.ColorTable[ID].RGB = TargetRGB
end

--搭档存在时间相关

function BuddyMgr:GetBuddyTotalTime()
	return self.BuddyTotalTime
end

function BuddyMgr:GetBuddyRemainTime()
	if self.QueryInfo == nil or self.QueryInfo.Time == nil then
		return 0
	end

	return self.QueryInfo.Time.Remain or 0
end

function BuddyMgr:TickBuddyTime(IntervalTime)
	if self.QueryInfo == nil or self.QueryInfo.Time == nil then
		return
	end

	self.QueryInfo.Time.Remain = self.QueryInfo.Time.Remain - IntervalTime
end


local BuddyIntervalTime = 1
function BuddyMgr:SetBuddyTime()
	local BuddyLeftTime = self:GetBuddyRemainTime()
	if BuddyLeftTime > 0 and nil == self.BuddyTimeID then
		self.BuddyTimeID = self:RegisterTimer(self.UpdateBuddyTimeID, 0, BuddyIntervalTime, 0)
	end
end


function BuddyMgr:UpdateBuddyTimeID()
	if self:IsBuddyOuting() and self:CanBuddyActivity() then
		self:TickBuddyTime(BuddyIntervalTime)
	end

	local BuddyLeftTime = self:GetBuddyRemainTime()
	if BuddyLeftTime  <= 0 then
		if self.BuddyTimeID then
			self:UnRegisterTimer(self.BuddyTimeID)
			self.BuddyTimeID = nil
			BuddyMgr:SendBuddyCallMessage(false)
		end
	end

	EventMgr:SendEvent(EventID.BuddyTickTime)
end

function BuddyMgr:CanBuddyActivity()
	if self:CanCallBuddy() == false then
		return false
	end
	
	if _G.MountMgr:IsInRide() then
		return false
	end

	local Major = MajorUtil.GetMajor()
	if Major and Major:IsSwimming()	 then
		return false
	end

	local MajorID = MajorUtil.GetMajorEntityID()
	local IsSit,_ = _G.EmotionMgr:IsSitState(MajorID) 
	if IsSit then	--坐下
		return false
	end
	
	return true
end

function BuddyMgr:OnCallBuddy()
	if self:CanCallBuddy() == false then
		_G.MsgTipsUtil.ShowTipsByID(BuddyDefine.ErrorTipsId_NotCallBuddy)
		return false
	end

	if self:CanBuddyActivity() == false then
		_G.MsgTipsUtil.ShowTipsByID(308007)
		return
	end

	if _G.SingBarMgr:GetMajorIsSinging() then
		MsgTipsUtil.ShowTips(LSTR(1000005))
		return
	end

	local GID = _G.BagMgr:GetItemGIDByResID(self.CallTimeItemID)
	local Item = _G.BagMgr:GetItemDataByGID(GID)
	local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
	if Cfg == nil or Item == nil then
		return
	end

	local CfgItem = InteractivedescCfg:FindCfgByKey(Cfg.InteractiveID)
	if CfgItem then
		self.TempUseInteractiveItemParam = {}
		self.TempUseInteractiveItemParam.SingStateID = CfgItem.SingStateID[1]
		self.TempUseInteractiveItemParam.Item = Item
		self:RegisterGameEvent(EventID.MajorSingBarOver, self.OnMajorSingBarOverHandleOnce)
		_G.InteractiveMgr:SendInteractiveStartReqWithoutObj(Cfg.InteractiveID)
	end
end

function BuddyMgr:OnMajorSingBarOverHandleOnce(EntityID, IsBreak, SingStateID)
	if EntityID == MajorUtil.GetMajorEntityID() then
		local Param = self.TempUseInteractiveItemParam or {}
		if Param.SingStateID == SingStateID then
			if not IsBreak then
				self:SendBuddyCallMessage(true)
			end
		end
		self.TempUseInteractiveItemParam = nil
		self:UnRegisterGameEvent(EventID.MajorSingBarOver, self.OnMajorSingBarOverHandleOnce)
	end
end

function BuddyMgr:OnNetMsgBuddyTimeUpdate(MsgBody)
	if nil == MsgBody then
        return
    end
    if nil == MsgBody.Time then
		return
	end
	
	if self.QueryInfo == nil then
		return
	end

	self.QueryInfo.Time = MsgBody.Time.Time
	self:SetBuddyTime()
end

--改名
function BuddyMgr:SendBuddyRenameMessage(NewName)
	local MsgID = CS_CMD_BUDDY
	local SubMsgID = BUDDY_SUB_MSG_ID.BuddyCmdRename
	local MsgBody = {
		Cmd = BUDDY_SUB_MSG_ID.BuddyCmdRename,
		Rename = { Name =  NewName},
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BuddyMgr:OnNetMsgBuddyRename(MsgBody)
	if nil == MsgBody.Rename then
		return
	end

	if self.QueryInfo and self.QueryInfo.Status then
		self.QueryInfo.Status.Name = MsgBody.Rename.Name
	end

	EventMgr:SendEvent(EventID.BuddyRenameSuccess)
end

function BuddyMgr:GetBuddyName()
	if self.QueryInfo == nil or self.QueryInfo.Status == nil then
		return ""
	end

	return self.QueryInfo.Status.Name
end

---@return number EntityID
function BuddyMgr:GetBuddyByMaster(EntityID)
	return (self.MasterBuddyMap or {})[EntityID] or 0
end

function BuddyMgr:OpenRenamePanel()
    local PopInputParams = {
        Title = LSTR(1000006),
        HintText = LSTR(1000007),
        MaxTextLength = 12,
		Desc = LSTR(1000008),
        SureCallback = function(NewName)
			if string.isnilorempty(NewName) then
				MsgTipsUtil.ShowTipsByID(308018)
				return
			end

			if string.match(NewName, "%s") then
				MsgTipsUtil.ShowTipsByID(308017)
				return
			end 
			local function OkCallback()
				BuddyMgr:SendBuddyRenameMessage(NewName)
			end

			local function CancelCallback()
				BuddyMgr:OpenRenamePanel()
			end
		
			local _finalStr = string.format(
								  LSTR(1000009), NewName)
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(self ,LSTR(10004), _finalStr, OkCallback, CancelCallback, LSTR(10003), LSTR(10002))
        end
    }

    _G.UIViewMgr:ShowView(_G.UIViewID.CommonPopupInput, PopInputParams)
end


-----------------------红点相关

function BuddyMgr:UpdateBuddyUpLevelRedDot()
	local RedDotName = self:GetBuddyUpLevelRedDotName()
	if self:IsHasBuddyUpLevelRedDot() == true then
		RedDotMgr:AddRedDotByName(RedDotName)
	else
		RedDotMgr:DelRedDotByName(RedDotName)
	end
end

function BuddyMgr:GetBuddyUpLevelRedDotName()
	return "Root/BuddyUpLevel"
end


function BuddyMgr:IsHasBuddyUpLevelRedDot()
	if self.QueryInfo == nil or self.QueryInfo.LevelExp == nil or self.QueryInfo.LevelExp.Level == nil then
		return false
	end

	return self.QueryInfo.LevelExp.Level > self.RecordRedDotLevel
end


function BuddyMgr:ReadSaveKeyData()
    self.RecordRedDotLevel = USaveMgr.GetInt(SaveKey.BuddyUpLevel, 0, true) or 0
end

function BuddyMgr:RecordRedDotClicked()
	if self.QueryInfo == nil or self.QueryInfo.LevelExp == nil then
		return
	end
	self.RecordRedDotLevel = self.QueryInfo.LevelExp.Level
	self:UpdateBuddyUpLevelRedDot()

	self:WriteSaveKeyData()
end

function BuddyMgr:WriteSaveKeyData()
    USaveMgr.SetInt(SaveKey.BuddyUpLevel, self.RecordRedDotLevel, true)
end


return BuddyMgr