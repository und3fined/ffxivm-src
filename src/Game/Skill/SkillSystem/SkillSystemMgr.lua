--
-- Author: henghaoli
-- Date: 2024-07-17 09:34:00
-- Description: 管理技能系统相关 # TODO - 后面把SkillSystemVM的逻辑挪到这里
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local SkillUtil = require("Utils/SkillUtil")
local CommonUtil = require("Utils/CommonUtil")
local SkillSystemRedDotUtil = require("Game/Skill/SkillSystem/SkillSystemRedDotUtil")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local PassiveSkillVM = require("Game/Skill/View/PassiveSkillVM")
local SkillSystemGlobalCfg = require("TableCfg/SkillSystemGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local SkillSystemConfig = require("Game/Skill/SkillSystem/SkillSystemConfig")
local ObjectGCType = require("Define/ObjectGCType")
local SkillExpandConfig = SkillSystemConfig.SkillExpandConfig

local USaveMgr = _G.UE.USaveMgr
local UWorldMgr
local UFGameFXManager
local SkillLogicMgr, ProfMgr
local WorldOffset = UE.FVector(0, 0, 50000)



---@class SkillSystemMgr : MgrBase
local SkillSystemMgr = LuaClass(MgrBase)

function SkillSystemMgr:OnInit()
	UWorldMgr = _G.UE.UWorldMgr.Get()
	SkillLogicMgr = _G.SkillLogicMgr
	ProfMgr = _G.ProfMgr
	UFGameFXManager = UE.UFGameFXManager.Get()
	self.CasterResID = 20250001
    self.TargetResID = 20250000
	
    local Value = SkillSystemGlobalCfg:FindValue(ProtoRes.skill_system_global_cfg_id.SKILLSYSTEM_CFG_REDDOT_VERSION, "Value")
    if Value then
        local RedDotVersion = tonumber(Value[1])
		if RedDotVersion then
			SkillSystemConfig.RedDotVersion = RedDotVersion
		end
    end

	local Values = SkillSystemGlobalCfg:FindValue(ProtoRes.skill_system_global_cfg_id.SKILLSYSTEM_CFG_PVP_OPEN_VERSION, "Value")
	if Values and #Values > 0 then
		self.bPVPOpen = UE.UVersionMgr.IsBelowOrEqualGameVersion(Values[1])
	end
end

function SkillSystemMgr:OnBegin()
	-- self:SendPerformSkillNetMsg(ProtoCS.skill_perform_status.SKILL_PERFORM_STATUS_OFF)
	-- local _ <close> = CommonUtil.MakeProfileTag("UpdateRedDotSaveData")
	-- self:UpdateRedDotSaveData()
end

function SkillSystemMgr:OnEnd()
end

function SkillSystemMgr:OnShutdown()
end

function SkillSystemMgr:OnRegisterNetMsg()
end

function SkillSystemMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MajorProfSwitch, self.UpdateRedDotSaveData)
	self:RegisterGameEvent(EventID.MajorLevelUpdate, self.UpdateRedDotSaveData)
	self:RegisterGameEvent(EventID.WorldPostLoad, self.OnGameEventWorldPostLoad)
end

function SkillSystemMgr:OnLoad()
	self:RegisterGameEvent(EventID.LevelPostLoad, self.OnGameEventLevelPostLoad)
	UWorldMgr:LoadDynamicLevel(SkillSystemConfig.SkillSystemLevel, false)
end

function SkillSystemMgr:OnUnload()
	self:UnRegisterGameEvent(EventID.LevelPostLoad, self.OnGameEventLevelPostLoad)
	UWorldMgr:UnLoadLevel(SkillSystemConfig.SkillSystemLevel, true)
	self.VolumeActor = nil
end

function SkillSystemMgr:OnGameEventLevelPostLoad(Params)
	local LevelName = Params.StringParam1
	if LevelName ~= SkillSystemConfig.SkillSystemLevel then
		return
	end
	local LevelStreaming = UE.UGameplayStatics.GetStreamingLevel(FWORLD(), LevelName)
    if not LevelStreaming or not LevelStreaming:IsLevelLoaded() then
        return
    end
	local Level = LevelStreaming:GetLoadedLevel()
	if not Level then
		return
	end

	local Actors = UWorldMgr:GetActorsInLevel(Level)
	for i = 1, Actors:Length() do
		local Actor = Actors:GetRef(i)
		if Actor then
			local VolumeActor = Actor:Cast(UE.ACullDistanceVolume)
			if VolumeActor then
				VolumeActor.bEnabled = self.bIsActive
				self.VolumeActor = VolumeActor
				break
			end
		end
	end
end

function SkillSystemMgr:SetVolumeActorEnabled(bEnabled)
	local VolumeActor = self.VolumeActor
	if VolumeActor then
		VolumeActor.bEnabled = bEnabled
	end
end

function SkillSystemMgr:Enter(VM, ProfID, MapType)
	self:RegisterGameEvent(EventID.ThirdPlayerSkillSing, self.OnPlayerSing)
	self.CurrentMapType = MapType or self:GetCurrentMapType() or SkillUtil.MapType.PVE
	self.ProfID = ProfID
	self.bIsActive = true
	self.PressedButtonIndex = nil
	self.SkillSystemEntityMap = {}
	self.VM = VM
	self.bPreviewUnlockedProf = ProfID ~= MajorUtil.GetMajorProfID() or _G.DemoMajorType == 1
	self.ReBuildRedData = nil

	self:InitRedDotWidgetMap()
	self:SetVolumeActorEnabled(true)

	EventMgr:SendEvent(EventID.SkillSystemEnter)
end

function SkillSystemMgr:Leave()
	self:UnRegisterGameEvent(EventID.ThirdPlayerSkillSing, self.OnPlayerSing)
	EventMgr:SendEvent(EventID.SkillSystemLeave)

	if self.RedDotRootNode then
		-- 保存一下
		local CurrentMapType = self:GetCurrentMapType()
		SkillSystemRedDotUtil.SaveRootNode(CurrentMapType, self.ProfID, self.RedDotRootNode)
		SkillSystemRedDotUtil.SaveFlag(CurrentMapType, self.ProfID, self.RedDotRootNode.UncheckedNum)
	end

	if ProfMgr:CanChangeProf(self.ProfID, false, true) then
		UFGameFXManager:ClearCache(false, true, true)
	end

	self.ProfID = nil
	self.CurrentMapType = nil
	self.bPreviewUnlockedProf = nil
	self.SkillSystemEntityMap = nil
	self.bIsActive = false
	self.VM = nil
	self.RedDotRootNode = nil
	self.RedDotWidgetMap = nil
	self.RedDotNodeMap = nil
	self.bCasterAssembleEnd = false
	self.bTargetAssembleEnd = false
	self.ReBuildRedData = nil
	SkillSystemRedDotUtil.Reset()
	self:SetVolumeActorEnabled(false)
end

function SkillSystemMgr:PreLeave()
	self.PressedButtonIndex = nil
end

-- 这个接口考虑到了附加在怪物身上的召唤兽
function SkillSystemMgr:IsSkillSystem(EntityID)
	if SkillLogicMgr:IsSkillSystemInternal(EntityID) then
		return true
	end
	local SummonActor = ActorUtil.GetActorByEntityID(EntityID)
    if not SummonActor then
        return false
    end
    SummonActor = SummonActor:Cast(_G.UE.ASummonCharacter)
    if SummonActor then
        local FollowEntityID = SummonActor:GetFollowEntityID()
        return SkillLogicMgr:IsSkillSystemInternal(FollowEntityID)
    end
    return false
end

function SkillSystemMgr:CreateSkillExpandWidgetAsync(ParentView)
    local WeakRoot = _G.UE.FWeakObjectPtr(ParentView.Root)
	local function Callback(Widget)
        if not WeakRoot:IsValid() then
            return
        end

		WeakRoot:Get():AddChildToCanvas(Widget)
		UIUtil.CanvasSlotSetAutoSize(Widget, true)
		ParentView:AddSubView(Widget)
		ParentView.SkillExpand = Widget
		local Slot = Widget.Slot
		Slot:SetPosition(SkillExpandConfig.Position)
		Slot:SetSize(SkillExpandConfig.Size)
		Slot:SetAlignment(SkillExpandConfig.Alignment)
		Slot:SetZOrder(SkillExpandConfig.ZOrder)
		Slot:SetAnchors(SkillExpandConfig.Anchors)
		UIUtil.SetIsVisible(Widget, false)

		ParentView.AdapterSimulateReplace = UIAdapterTableView.CreateAdapter(ParentView, Widget.TableViewSkill)
		ParentView.AdapterSimulateReplace:SetOnClickedCallback(ParentView.OnSimulateReplaceClicked)
		ParentView.SimulateReplaceList = UIBindableList.New(PassiveSkillVM)
		ParentView.AdapterSimulateReplace:UpdateAll(ParentView.SimulateReplaceList)
	end
	WidgetPoolMgr:CreateWidgetAsyncByName(SkillExpandConfig.BPName, ObjectGCType.NoCache, Callback, true, false)
end

function SkillSystemMgr:ClearAllSkillSystemEffectWithoutFade()
	if self.VM then
		self.VM:ClearAllSkillSystemEffectWithoutFade()
	end
end

function SkillSystemMgr:ResetProfCamera()
	local VM = self.VM
	if VM then
		VM:ResetProfCamera(VM.ProfID, VM.RaceID)
	end
end

function SkillSystemMgr:SendPerformSkillNetMsg(Status, Caster, Target)
    local MsgID = ProtoCS.CS_CMD.CS_CMD_COMBAT
	local MsgBody = {}
	local SubMsgID = ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_PERFORM_SKILL
	MsgBody.Cmd = SubMsgID
	local SkillPerform = {Status = Status}
	if Status == ProtoCS.skill_perform_status.SKILL_PERFORM_STATUS_ON then
		local Monsters = {{Pos = SkillUtil.ConvertVector2Position(Caster.Location), Dir = Caster.Rotation.Yaw, Caster = 1, ResID = self.CasterResID}
						, {Pos = SkillUtil.ConvertVector2Position(Target.Location), Dir = Target.Rotation.Yaw, Caster = 0, ResID = self.TargetResID}}
		SkillPerform.Monsters = Monsters
	end
	MsgBody.SkillPerform = SkillPerform
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function SkillSystemMgr:SyncPlayerTransform(SkillID)
	local VM = self.VM
	if not VM then
		return
	end

	local ProfSkillData = VM:GetProfConfigData(VM.ProfID, VM.RaceID)
    if not ProfSkillData then
		return
	end
	local SingleSkillData = ProfSkillData.SkillConfig:Find(SkillID)
	if SingleSkillData then
		VM:SyncTransform(
			VM.CasterEntityID,
			SingleSkillData.Location + WorldOffset,
			SingleSkillData.Location + VM.WorldCompositionOffset,
			SingleSkillData.Rotation)
	end
end

function SkillSystemMgr:OnPlayerSing(Params)
	-- 这里没有用SkillSystemMgr:IsSkillSystem, 原因是这个接口对召唤兽也会返回true,
	-- 但是读条UI不应该响应召唤兽的吟唱
	if SkillLogicMgr:IsSkillSystemInternal(Params.EntityID) then
		EventMgr:SendEvent(EventID.SkillSystemSing, Params)
	end
end


--region 红点相关功能

local SkillSystemRedDotNode = require("Game/Skill/SkillSystem/SkillSystemRedDotNode")
local ENodeType = SkillSystemRedDotNode.ENodeType
local ENodeState = SkillSystemRedDotNode.ENodeState
local MapType_PVE <const> = SkillUtil.MapType.PVE

--region 红点相关功能 - 初始化

function SkillSystemMgr:RedDotTreeInit(EntityID)
	if not self.bIsActive then
		return
	end
	-- 预览未解锁的职业不启用红点
	if self.bPreviewUnlockedProf then
		return
	end
	self.RedDotRootNode = nil

	-- 因为PVP直接会了所有技能, 所以PVP不执行红点的逻辑
	local CurrentMapType = self:GetCurrentMapType()
	if CurrentMapType ~= MapType_PVE then
		return
	end

	local RedDotRootNode
	do
		local _ <close> = CommonUtil.MakeProfileTag("SkillSystem_BuildRedDotTree")
		RedDotRootNode = SkillSystemRedDotUtil.BuildRedDotTree(CurrentMapType, EntityID)
	end
	if not RedDotRootNode then
		return
	end

	self.RedDotRootNode = RedDotRootNode
	self:InitRedDotNodeMap()
	SkillSystemRedDotUtil.InitAllNodes(RedDotRootNode, true)
end

function SkillSystemMgr:InitRedDotWidgetMap()
	local RedDotWidgetMap = {}
	for _, NodeType in pairs(ENodeType) do
		RedDotWidgetMap[NodeType] = {}
	end

	-- 根节点变化时, 发事件(Root只有Label一个子节点, 注册到Label上也没区别)
	RedDotWidgetMap[ENodeType.Label][0] = function(bVisible)
		_G.EventMgr:PostEvent(_G.EventID.SkillSystemProfRedDotChange, {
			ProfID = self.ProfID,
			bRedDotVisible = bVisible
		})
	end

	self.RedDotWidgetMap = RedDotWidgetMap
end

function SkillSystemMgr:InitRedDotNodeMap()
	local RedDotNodeMap = {}
	for _, NodeType in pairs(ENodeType) do
		RedDotNodeMap[NodeType] = {}
	end
	SkillSystemRedDotUtil.TraverseTreeNode(
		self.RedDotRootNode, SkillSystemRedDotUtil.NodeTypeMask_All, function(Node)
			RedDotNodeMap[Node.Type][Node.ID] = Node
		end)
	self.RedDotNodeMap = RedDotNodeMap
end

-- 从SaveGame里获取数据后需要重重新生成的红点数据，目前默认技能index，后果可扩展
function SkillSystemMgr:SetRebuildRedData(ReBuildData)
	self.ReBuildRedData = ReBuildData
end

function SkillSystemMgr:GetRebuildRedData()
	return self.ReBuildRedData
end

--endregion


--region 红点相关功能 - 控件相关, 注册控件, 可视性更改等

local function SetWidgetVisibility(Widget, bVisible)
	if not Widget then
		return
	end

	if type(Widget) == "userdata" then
		Widget = Widget:Get()
		if Widget then
			UIUtil.SetIsVisible(Widget, bVisible)
			if type(Widget) == "table" then
				Widget:SetRedDotNumByNumber(bVisible and 1 or 0)
			end
		end
	else
		Widget(bVisible)
	end
end

function SkillSystemMgr:SetNodeVisibility(Node, bVisible)
	local RedDotWidgetMap = self.RedDotWidgetMap
    if not RedDotWidgetMap then
        return
    end
	local Widget = RedDotWidgetMap[Node.Type][Node.ID]
	SetWidgetVisibility(Widget, bVisible)
end

local FWeakObjectPtr = _G.UE.FWeakObjectPtr

--- 将某个Widget(一般是红点)和某个树上的节点绑定
---@param NodeType number 节点的类型
---@param ID number 节点的ID(不同类型的节点, ID的意义也不同)
---@param Widget UUserWidget | function 如果是Widget, 直接设置可视性; 也可以是一个function, 根据传入的可视性做一些自定义操作
function  SkillSystemMgr:RegisterRedDotWidget(NodeType, ID, Widget)
	if not self.bIsActive then
		return
	end
	if NodeType == nil or ID == nil or not self.RedDotWidgetMap then
		return
	end

	-- 用弱指针包一下
	local WrappedWidget = Widget
	local Type = type(Widget)
	if Type == "userdata" then
		WrappedWidget = FWeakObjectPtr(Widget)
	elseif Type == "table" then
		WrappedWidget = FWeakObjectPtr(Widget.Object)
	end

	self.RedDotWidgetMap[NodeType][ID] = WrappedWidget

	if self.RedDotNodeMap then
		local Node = self.RedDotNodeMap[NodeType][ID]
		if Node then
			local bVisible = Node.UncheckedNum > 0
			SetWidgetVisibility(WrappedWidget, bVisible)
			return
		end
	end
	SetWidgetVisibility(WrappedWidget, false)
end

local ENodeType_Button = ENodeType.Button
local NormalRedDotStyle = 1
local ButtonIndex_Multi_Start <const> = SkillCommonDefine.SkillButtonIndexRange.Multi_Start
local ButtonIndex_Multi_End <const> = SkillCommonDefine.SkillButtonIndexRange.Multi_End

function SkillSystemMgr:RegisterSkillButtonRedDotWidget(ButtonIndex, SkillID, CommonRedDot)
	if not ButtonIndex or not CommonRedDot then
		return
	end
	CommonRedDot:OnRedDotStyleChange(NormalRedDotStyle)
	if ButtonIndex >= ButtonIndex_Multi_Start and ButtonIndex <= ButtonIndex_Multi_End then
		self:RegisterRedDotWidget(ENodeType.MultiChoiceButton, SkillID, CommonRedDot)
	else
		self:RegisterRedDotWidget(ENodeType_Button, ButtonIndex, CommonRedDot)
	end
end

local ENodeType_Skill = ENodeType.Skill

function SkillSystemMgr:RegisterSkillRedDotWidget(SkillID, Func)
	if not SkillID or not Func then
		return
	end
	if not self.RedDotWidgetMap then
		return
	end
	local LastFunc = self.RedDotWidgetMap[ENodeType_Skill][SkillID]
	local NewFunc = Func
	if LastFunc then
		NewFunc = function(bVisible)
			LastFunc(bVisible)
			Func(bVisible)
		end
	end
	self:RegisterRedDotWidget(ENodeType_Skill, SkillID, NewFunc)
end

function SkillSystemMgr:UnRegisterSkillRedDotWidget(SkillID)
	self:RegisterRedDotWidget(ENodeType_Skill, SkillID, nil)
end

function SkillSystemMgr:RegisterAdvancedPanelRedDotWidget(SkillID, CommonRedDot)
	if not SkillID or not CommonRedDot then
		return
	end
	self:RegisterRedDotWidget(ENodeType.AdvancedPanel, SkillID, CommonRedDot)
end

function SkillSystemMgr:RegisterPassiveSkillRedDotWidget(SkillID, CommonRedDot)
	if not SkillID or not CommonRedDot then
		return
	end
	CommonRedDot:OnRedDotStyleChange(NormalRedDotStyle)
	self:RegisterRedDotWidget(ENodeType_Skill, SkillID, CommonRedDot)
end

function SkillSystemMgr:UnRegisterPassiveSkillRedDotWidget(SkillID)
	self:RegisterRedDotWidget(ENodeType_Skill, SkillID, nil)
end

--endregion


--region 红点相关功能 - 红点本地化保存数据的处理

function SkillSystemMgr:InitRedDotSaveData(CurrentMapType, ProfID, SaveKeySlot)
	local EntityID = SaveKeySlot  -- 这里的是一个伪EntityID, 对应LogicData用完即弃
    local LogicData = SkillLogicMgr:CreateSkillLogicData(EntityID, false)
    local Level = SkillUtil.GetGlobalConfigMaxLevel()
    local SkillGroupData = SkillUtil.GetBaseSkillListForInit(CurrentMapType, ProfID, Level)
    if SkillGroupData then
        LogicData:InitSkillList(SkillGroupData)
    end

	SkillSystemRedDotUtil.InitRedDotSaveData(CurrentMapType, ProfID, SaveKeySlot)

	SkillLogicMgr:RemoveSkillLogicData(EntityID)
end

function SkillSystemMgr:RefreshRedDotSaveData(CurrentMapType, ProfID, SaveKeySlot)
	local EntityID = SaveKeySlot
    local LogicData = SkillLogicMgr:CreateSkillLogicData(EntityID, false)
    local Level = SkillUtil.GetGlobalConfigMaxLevel()
    local SkillGroupData = SkillUtil.GetBaseSkillListForInit(CurrentMapType, ProfID, Level)
    if SkillGroupData then
        LogicData:InitSkillList(SkillGroupData)
    end

	SkillSystemRedDotUtil.RefreshRedDotSaveData(CurrentMapType, ProfID, SaveKeySlot)

	SkillLogicMgr:RemoveSkillLogicData(EntityID)
end

function SkillSystemMgr:UpdateRedDotSaveData()
	local ProfID = MajorUtil.GetMajorProfID()
	local GetSaveKey = SkillSystemRedDotUtil.GetSaveKey
	for _, CurrentMapType in pairs(SkillUtil.MapType) do
		-- PVP不存在技能学习的概念, 不需要构建红点树
		if CurrentMapType == SkillUtil.MapType.PVE then
			local SaveKeySlot = GetSaveKey(CurrentMapType, ProfID)
			local Value = USaveMgr.GetInt(SaveKeySlot, -1, true)
			if Value == -1 then
				-- 初始化红点相关数据, 然后保存
				local _ <close> = CommonUtil.MakeProfileTag("SkillSystemMgr_InitRedDotSaveData")
				self:InitRedDotSaveData(CurrentMapType, ProfID, SaveKeySlot)
			else
				-- 更新红点相关数据
				local _ <close> = CommonUtil.MakeProfileTag("SkillSystemMgr_RefreshRedDotSaveData")
				self:RefreshRedDotSaveData(CurrentMapType, ProfID, SaveKeySlot)
			end
		end
	end
end

--endregion


--region 红点相关功能 - 相应点击事件, 消去红点, 更新红点的状态

function SkillSystemMgr:UpdateSkillRedDotCheckState(SkillID)
	if not self.bIsActive or not self.RedDotRootNode or not self.RedDotNodeMap then
		return
	end

	local Node = self.RedDotNodeMap[ENodeType.Skill][SkillID]
	if Node and Node.NodeState == ENodeState.Unchecked then
		Node.NodeState = ENodeState.Checked
		SkillSystemRedDotUtil.BubbleUp(Node, true)
	end
end

function SkillSystemMgr:UpdateAdvancedPanelCheckState(Index)
	if not self.bIsActive or not self.RedDotRootNode or not self.RedDotNodeMap then
		return
	end

	local Node = self.RedDotNodeMap[ENodeType.AdvancedPanel][Index]
	if Node and Node.UncheckedNum > 0 then
		local ChildNodeList = Node.ChildNodeList
		for _, ChildNode in ipairs(ChildNodeList) do
			ChildNode.NodeState = ENodeState.Checked
			SkillSystemRedDotUtil.BubbleUp(ChildNode, true)
		end
	end
end

--endregion


function SkillSystemMgr:OnGameEventWorldPostLoad()
	self.CurrentMapType = nil
end

function SkillSystemMgr:GetCurrentMapType()
	local CurrentMapType = self.CurrentMapType
	if CurrentMapType then
		return CurrentMapType
	end
	CurrentMapType = MapType_PVE
	local MajorLogicData = _G.SkillLogicMgr.MajorLogicData
	if MajorLogicData then
		CurrentMapType = MajorLogicData:GetMapType()
	end
	
	self.CurrentMapType = CurrentMapType
	return CurrentMapType
end

function SkillSystemMgr:IsCurrentMapPVE()
	return self:GetCurrentMapType() == MapType_PVE
end

local GetRedDotNum = SkillSystemRedDotUtil.GetRedDotNum

function SkillSystemMgr:GetProfRedDotNum(ProfID)
	local CurrentMapType = self:GetCurrentMapType()
	if CurrentMapType == nil or ProfID == nil then
		return 0
	end

	return GetRedDotNum(CurrentMapType, ProfID)
end

--- 清除主角当前职业, 当前地图类型下的SaveData, 然后重新构建新的SaveData
function SkillSystemMgr:RecreateRedDotSaveData()
	local CurrentMapType = self:GetCurrentMapType()
	local ProfID = MajorUtil.GetMajorProfID()
	if not CurrentMapType or not ProfID then
		return
	end
	local SaveKeySlot = SkillSystemRedDotUtil.GetSaveKey(CurrentMapType, ProfID)
	USaveMgr.SetInt(SaveKeySlot, -1, true)
	USaveMgr.SetString(SaveKeySlot, "", true)

	self:UpdateRedDotSaveData()
end

--endregion

function SkillSystemMgr:ShouldOpenBagDrugSetPanel()
	return MajorUtil.GetMajorProfID() == self.ProfID and _G.DemoMajorType ~= 1
end

return SkillSystemMgr
