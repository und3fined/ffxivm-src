local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local SkillUtil = require("Utils/SkillUtil")
local CommonUtil = require("Utils/CommonUtil")
local SkillSystemReplaceCfg = require("TableCfg/SkillSystemReplaceCfg")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillSystemAdvancedSkillListCfg = require("TableCfg/SkillSystemAdvancedSkillListCfg")
local SkillSystemBlacklistCfg = require("TableCfg/SkillSystemBlacklistCfg")
local SkillSystemRedDotNode = require("Game/Skill/SkillSystem/SkillSystemRedDotNode")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")



---@class SkillSystemRedDotUtil
local SkillSystemRedDotUtil = {
}

--region 红点相关功能

local ENodeType = SkillSystemRedDotNode.ENodeType
local ETabType = SkillSystemRedDotNode.ETabType
local ENodeState = SkillSystemRedDotNode.ENodeState
local SkillLearnStatus = SkillUtil.SkillLearnStatus

local USaveMgr = _G.UE.USaveMgr
local FBase64 = _G.UE.FBase64
local TArray = _G.UE.TArray
local U8Array = TArray(_G.UE.uint8)
local SaveKey = require("Define/SaveKey")

local pbslice = require("pb.slice")
local pb = require("pb")

-- BuildTree刚开始查询一次，避免后面的操作中每次都去查询
local CachedMajorProfID
local CachedMajorLevel
local SkillSystemMgr


--region 红点相关功能 - 建立树状结构

local function GetReplacedSkillID(SkillID)
	local Cfg = SkillSystemReplaceCfg:FindCfgByKey(SkillID)
	if Cfg then
		return Cfg.ReplaceSkillID
	end
	return SkillID
end

local BuildSkillNode

local function BuildMultiChoiceNode(BaseSkillID, SelectSkillList)
	local MultiChoiceNode = SkillSystemRedDotNode.New(ENodeType.MultiChoice, BaseSkillID)
	for _, SkillID in ipairs(SelectSkillList) do
		SkillID = GetReplacedSkillID(SkillID)
		if SkillID > 0 then
			local MultiChoiceButtonNode = SkillSystemRedDotNode.New(ENodeType.MultiChoiceButton, SkillID)
			local SkillNode = BuildSkillNode(SkillID)
			MultiChoiceButtonNode:AddChildNode(SkillNode)
			MultiChoiceNode:AddChildNode(MultiChoiceButtonNode)
		end
	end
	return MultiChoiceNode
end

local function GetSelectSkillList(BaseSkillID)
	local FilteredList = {}
	local SelectIdList = SkillMainCfg:FindValue(BaseSkillID, "SelectIdList") or FilteredList
	for _, SkillInfo in ipairs(SelectIdList) do
		local SkillID = SkillInfo.ID
		if SkillID > 0 then
			table.insert(FilteredList, SkillID)
		end
	end
	if #FilteredList > 0 then
		return FilteredList
	end
	return nil
end

BuildSkillNode = function(SkillID, bNotReplace)
	if not SkillID or SkillID <= 0 or SkillSystemBlacklistCfg:FindCfgByKey(SkillID) then
		return
	end

	local ReplacedSkillID
	if bNotReplace then
		ReplacedSkillID = SkillID
	else
		ReplacedSkillID = GetReplacedSkillID(SkillID)
	end
	local SelectSkillList = GetSelectSkillList(ReplacedSkillID)
	if SelectSkillList then
		return BuildMultiChoiceNode(ReplacedSkillID, SelectSkillList)
	end
	local SkillNode = SkillSystemRedDotNode.New(ENodeType.Skill, ReplacedSkillID)
	local Status = SkillUtil.GetSkillLearnValid(ReplacedSkillID, CachedMajorProfID, CachedMajorLevel)

	local NodeState
	if Status == SkillLearnStatus.Learned or Status == SkillLearnStatus.Unknown then
		NodeState = ENodeState.Checked
	else
		NodeState = ENodeState.Unlearned
	end
	SkillNode.NodeState = NodeState
	return SkillNode
end

local function BuildAdvancedPanelNode(Index, SkillList)
	local Num = #SkillList
	if Num <= 1 then
		return nil
	end

	local AdvancedPanelNode = SkillSystemRedDotNode.New(ENodeType.AdvancedPanel, Index)
	for i = 2, Num do
		local SkillNode = BuildSkillNode(SkillList[i], true)
		AdvancedPanelNode:AddChildNode(SkillNode)
	end
	return AdvancedPanelNode
end

local ButtonIndex_Normal <const> = SkillCommonDefine.SkillButtonIndexRange.Normal
local ButtonIndex_Limit_Start <const> = SkillCommonDefine.SkillButtonIndexRange.Limit_Start
-- local ButtonIndex_Limit_End <const> = SkillCommonDefine.SkillButtonIndexRange.Limit_End
-- local ButtonIndex_Spectrum_Start <const> = SkillCommonDefine.SkillButtonIndexRange.Spectrum_Start
local ButtonIndex_Spectrum_End <const> = SkillCommonDefine.SkillButtonIndexRange.Spectrum_End

local function BuildSkillButtonNode(EntityID, SkillInfo)
	local BaseSkillID = SkillInfo.ID
	local SkillIndex = SkillInfo.Index
	if BaseSkillID <= 0 then
		return
	end

	local ButtonNode = SkillSystemRedDotNode.New(ENodeType.Button, SkillInfo.Index)
	if SkillIndex >= ButtonIndex_Limit_Start and
	   SkillIndex <= ButtonIndex_Spectrum_End or
	   SkillIndex == ButtonIndex_Normal then
		-- 16 ~ 18为极限技, 19 ~ 21 为量谱技能, 暂不处理; 0为普攻, 不处理
		return nil
	end

	-- 高级技能
	local SkillLogicMgr = _G.SkillLogicMgr
	local LogicData = SkillLogicMgr:GetSkillLogicData(EntityID)
	if LogicData then
		local SkillID = LogicData:GetBtnSkillID(SkillIndex)
		SkillID = GetReplacedSkillID(SkillID)
		local AdvancedSkillListCfg = SkillSystemAdvancedSkillListCfg:FindCfgByKey(SkillID)
		if AdvancedSkillListCfg then
			local SkillNode = BuildSkillNode(SkillID, true)
			ButtonNode:AddChildNode(SkillNode)
			local AdvancedPanelNode = BuildAdvancedPanelNode(SkillIndex, AdvancedSkillListCfg.SkillIDList)
			ButtonNode:AddChildNode(AdvancedPanelNode)
			return ButtonNode
		end
	end

	-- 连招
	local SeriesList = SkillLogicMgr:GetPlayerSeriesList(EntityID, SkillIndex)
	if SeriesList and #SeriesList > 0 then
		for _, SkillID in ipairs(SeriesList) do
			local SkillNode = BuildSkillNode(SkillID)
			ButtonNode:AddChildNode(SkillNode)
		end
	else
		local SkillNode = BuildSkillNode(BaseSkillID)
		ButtonNode:AddChildNode(SkillNode)
	end

	return ButtonNode
end

local function BuildActiveTabNode(EntityID, SkillInitCfg)
	local ActiveTabNode = SkillSystemRedDotNode.New(ENodeType.Tab, ETabType.Active)
	local SkillList = SkillInitCfg.SkillList
	for _, SkillInfo in ipairs(SkillList) do
		local ButtonNode = BuildSkillButtonNode(EntityID, SkillInfo)
		if ButtonNode then
			ActiveTabNode:AddChildNode(ButtonNode)
		end
	end
	return ActiveTabNode
end

local function BuildPassiveTabNode(_, SkillInitCfg)
	local PassiveTabNode = SkillSystemRedDotNode.New(ENodeType.Tab, ETabType.Passive)
	local PassiveSkillList = SkillInitCfg.PassiveList
	for _, SkillID in ipairs(PassiveSkillList) do
		if SkillID > 0 then
			local SkillNode = BuildSkillNode(SkillID)
			PassiveTabNode:AddChildNode(SkillNode)
		end
	end
	return PassiveTabNode
end

--endregion


--region 红点相关功能 - 遍历树状结构, 调整树状结构

local NodeTypeMask_All = ~0  -- ~0 == -1, 即所有位都置1

local function MakeNodeTypeMask(NodeType, ...)
	if not NodeType then
		return 0
	end
	return (1 << NodeType) | MakeNodeTypeMask(...)
end

--- 遍历树上的节点
---@field RootNode SkillSystemRedDotNode 根节点
---@field NodeTypeMask number 需要遍历的节点的类型
---@field Func function 需要对节点进行的操作
local function TraverseTreeNode(RootNode, NodeTypeMask, Func)
	if not RootNode then
		return
	end

	if ((1 << RootNode.Type) & NodeTypeMask) > 0 then
		Func(RootNode)
	end

	local ChildNodeList = RootNode.ChildNodeList
	for _, ChildNode in ipairs(ChildNodeList) do
		TraverseTreeNode(ChildNode, NodeTypeMask, Func)
	end
end

local function BubbleUpInternal(Node, DeltaNum, bChangeVisibility)
	local LastUncheckedNum = Node.UncheckedNum
	local CurrentUncheckedNum = LastUncheckedNum + DeltaNum
	Node.UncheckedNum = CurrentUncheckedNum

    local ParentNode = Node.ParentNode
    if ParentNode then
        BubbleUpInternal(ParentNode, DeltaNum, bChangeVisibility)
    end
	if not bChangeVisibility then
		return
	end

	if LastUncheckedNum > 0 and CurrentUncheckedNum == 0 then
		SkillSystemMgr:SetNodeVisibility(Node, false)
	elseif LastUncheckedNum == 0 and CurrentUncheckedNum > 0 then
		SkillSystemMgr:SetNodeVisibility(Node, true)
	end
end

--- 将叶子节点的状态传递上去
---@field Node SkillSystemRedDotNode 叶子节点
---@field bChangeVisibility boolean 更新状态后，是否同步更新对应Widget的可见性
local function BubbleUp(Node, bChangeVisibility)
	-- 只有叶子节点可以Bubble
	if Node.Type ~= ENodeType.Skill then
		return
	end

	if Node.NodeState == ENodeState.Unchecked and Node.UncheckedNum == 0 then
		BubbleUpInternal(Node, 1, bChangeVisibility)
	elseif Node.NodeState == ENodeState.Checked and Node.UncheckedNum == 1 then
		BubbleUpInternal(Node, -1, bChangeVisibility)
	end
end

--endregion


--region 红点相关功能 - SaveGame

local SkillSystemConfig = require("Game/Skill/SkillSystem/SkillSystemConfig")

local PROF_ID_MAX <const>      = 100  -- 计算SaveKey用，假设ProfID永远不会超过100个
local UncheckedNumBit <const>  = 16
local UncheckedNumMask <const> = (1 << UncheckedNumBit) - 1
local VersionMask <const>      = ~UncheckedNumMask
local function GetSaveKey(CurrentMapType, ProfID)
	ProfID = ProfUtil.GetAdvancedProf(ProfID)  -- 基职和特职需要在一个Slot里面
	return SaveKey.SkillSystemRedDot + (CurrentMapType - 1) * PROF_ID_MAX + ProfID
end

local function CheckVersion(SaveKeySlot)
	local Flag = USaveMgr.GetInt(SaveKeySlot, -1, true)
	if Flag == -1 then
		return false
	end

	local Version = (Flag & VersionMask) >> UncheckedNumBit
	-- 版本不一致, 清除数据
	if Version ~= SkillSystemConfig.RedDotVersion then
		USaveMgr.SetInt(SaveKeySlot, -1, true)
		USaveMgr.SetString(SaveKeySlot, "", true)
		return false
	end
	return true
end

local RedDotMessageType = "skillaction.SkillSystemRedDotNode"

local function GetSavedRootNode(CurrentMapType, ProfID)
	local SaveKeySlot = GetSaveKey(CurrentMapType, ProfID)
	if not CheckVersion(SaveKeySlot) then
		return nil
	end

	local EncodedString = USaveMgr.GetString(SaveKeySlot, "", true)

	if EncodedString ~= "" then
		local bSuccess
		bSuccess = FBase64.DecodeU8Array(EncodedString, U8Array)
		if not bSuccess then
			return nil
		end
		local Slice = pbslice.new_with_raw_pointer(U8Array:GetData(), U8Array:Length())
		local RootNode = pb.decode(RedDotMessageType, Slice)
		TraverseTreeNode(RootNode, NodeTypeMask_All, function(Node)
			setmetatable(Node, {__index = SkillSystemRedDotNode})
		end)

		return RootNode
	end

	return nil
end

local function SaveRootNode(CurrentMapType, ProfID, RootNode)
	if not CurrentMapType or not ProfID or not RootNode then
		return
	end

	local SaveKeySlot = GetSaveKey(CurrentMapType, ProfID)
	local BinaryData = pb.encode(RedDotMessageType, RootNode)
	local EncodedString = FBase64.Encode(BinaryData, #BinaryData)
	USaveMgr.SetString(SaveKeySlot, EncodedString, true)
end

local function SaveFlagInternal(SaveKeySlot, UncheckedNum)
	local Version = SkillSystemConfig.RedDotVersion
	USaveMgr.SetInt(SaveKeySlot, (Version << 16) | UncheckedNum, true)
end

--- 处理老号设备上的无效节点缓存，重新构建ButtonIndex类型的节点
---@param EntityID any
---@param RootNode any
---@param ReBuildIndexData table 经过技能替换的Index列表
local function RebuildLocalSavedButtonType(EntityID, RootNode, ReBuildIndexData)
	if table.is_nil_empty(ReBuildIndexData) then
		return
	end

	local SkillLogicMgr = _G.SkillLogicMgr
	local LogicData = SkillLogicMgr:GetSkillLogicData(EntityID)
	if not LogicData then
		return	
	end

	--找出对应的index节点
	local ButtonTypeMask = MakeNodeTypeMask(ENodeType.Button)
	TraverseTreeNode(RootNode, ButtonTypeMask, function(ButtonNode)
		local RebuildSkillData = ReBuildIndexData[ButtonNode.ID]
		if RebuildSkillData then
			local Index = RebuildSkillData.SkillInfo.Index
			local SkillID = LogicData:GetBtnSkillID(Index)
			local ChildNodeList = ButtonNode.ChildNodeList
			for _, ChildNode in ipairs(ChildNodeList) do
				if SkillID == ChildNode.ID then
					SkillID = 0
					break
				end
			end
			-- 重新构建
			if SkillID > 0 then
				local NewButtonNode = BuildSkillButtonNode(EntityID, RebuildSkillData.SkillInfo)
				SkillSystemRedDotNode.SetDataByNode(ButtonNode, NewButtonNode)
			end
		end
	end)
end

function SkillSystemRedDotUtil.GetRedDotNum(CurrentMapType, ProfID)
	local SaveKeySlot = GetSaveKey(CurrentMapType, ProfID)
	if not CheckVersion(SaveKeySlot) then
		return 0
	end

	local Flag = USaveMgr.GetInt(SaveKeySlot, -1, true)
	if Flag == -1 then
		return 0
	end
	return Flag & UncheckedNumMask
end

--- 保存Flag
--- Flag前16位为对应职业对应地图的UncheckedNum, 后16位为当前的版本号
function SkillSystemRedDotUtil.SaveFlag(CurrentMapType, ProfID, UncheckedNum)
	if not CurrentMapType or not ProfID or not UncheckedNum then
		return
	end
	local SaveKeySlot = GetSaveKey(CurrentMapType, ProfID)
	if SaveKeySlot then
		SaveFlagInternal(SaveKeySlot, UncheckedNum)
	end
end

function SkillSystemRedDotUtil.InitRedDotSaveData(CurrentMapType, _, SaveKeySlot)
	
	local RootNode = SkillSystemRedDotUtil.BuildRedDotTree(CurrentMapType, SaveKeySlot)
	if RootNode then
		local UncheckedNum = RootNode.UncheckedNum
		-- 第一次BuildRedDotTree会自行SaveRootNode, 这里不需要重复调用
		SaveFlagInternal(SaveKeySlot, UncheckedNum)
	end
end

function SkillSystemRedDotUtil.RefreshRedDotSaveData(CurrentMapType, ProfID, SaveKeySlot)
	local _ <close> = CommonUtil.MakeProfileTag("BuildRedDotTree")
	local RootNode = SkillSystemRedDotUtil.BuildRedDotTree(CurrentMapType, SaveKeySlot)
	if RootNode then
		SkillSystemRedDotUtil.InitAllNodes(RootNode, false)
		SaveRootNode(CurrentMapType, ProfID, RootNode)
		SaveFlagInternal(SaveKeySlot, RootNode.UncheckedNum)
	end
end

--endregion


--region 红点相关功能 - 可视性
--endregion


--- 构建红点的树形结构，优先尝试从SaveGame中读取
---@field EntityID number
---@return SkillSystemRedDotNode RootNode
function SkillSystemRedDotUtil.BuildRedDotTree(CurrentMapType, EntityID)
	local ProfID = MajorUtil.GetMajorProfID()
	local MajorLevel = MajorUtil.GetMajorLevelByProf(ProfID) or 0
	CachedMajorProfID = ProfID
	CachedMajorLevel = MajorLevel
    if not SkillSystemMgr then
        SkillSystemMgr = _G.SkillSystemMgr
    end

	-- 先从SaveGame里面找有没有数据
	local RootNode = GetSavedRootNode(CurrentMapType, ProfID)
	if RootNode then
		RebuildLocalSavedButtonType(EntityID, RootNode, SkillSystemMgr:GetRebuildRedData())
		SkillSystemMgr:SetRebuildRedData(nil)
		return RootNode
	end
	SkillSystemMgr:SetRebuildRedData(nil)
	
	-- 无缓存数据，重新构建
	RootNode = SkillSystemRedDotNode.New(ENodeType.Prof, ProfID)
	local LabelNode = SkillSystemRedDotNode.New(ENodeType.Label)
	RootNode:AddChildNode(LabelNode)

	local Level = SkillUtil.GetGlobalConfigMaxLevel()
	-- # TODO - 红点需要区分PVP和PVE
	local SkillInitCfg = SkillUtil.GetBaseSkillListForInit(CurrentMapType, ProfID, Level)
	if not SkillInitCfg then
		return nil
	end

	-- 战斗职业主动和被动都支持红点，生产职业只有被动技能支持红点
	if ProfUtil.IsCombatProf(ProfID) then
		local ActiveTabNode = BuildActiveTabNode(EntityID, SkillInitCfg)
		LabelNode:AddChildNode(ActiveTabNode)
	end

	local PassiveTabNode = BuildPassiveTabNode(EntityID, SkillInitCfg)
	LabelNode:AddChildNode(PassiveTabNode)

	-- 存储数据
	SaveRootNode(CurrentMapType, ProfID, RootNode)

	return RootNode
end

function SkillSystemRedDotUtil.InitAllNodes(RootNode, bChangeVisibility)
	-- 标记各个节点的ParentNode, 重新计算叶节点的State
	TraverseTreeNode(RootNode, NodeTypeMask_All, function(Node)
		if Node.Type == ENodeType.Skill then
			local SkillID = Node.ID
			local Status = SkillUtil.GetSkillLearnValid(SkillID, CachedMajorProfID, CachedMajorLevel)

			-- 这里只需要关注之前是Unlearned, 但是现在学会了的节点
			if Node.NodeState ~= ENodeState.Unlearned then
				return
			end
			if Status == SkillLearnStatus.Learned then
				Node.NodeState = ENodeState.Unchecked
				BubbleUp(Node, false)
			end
		else
			local ChildNodeList = Node.ChildNodeList
			for _, ChildNode in ipairs(ChildNodeList) do
				ChildNode.ParentNode = Node
			end
		end
	end)

	if not bChangeVisibility then
		return
	end
    TraverseTreeNode(RootNode, NodeTypeMask_All, function(Node)
        local bVisible = Node.UncheckedNum > 0
        SkillSystemMgr:SetNodeVisibility(Node, bVisible)
    end)
end

function SkillSystemRedDotUtil.Reset()
    CachedMajorLevel = nil
    CachedMajorProfID = nil
end

SkillSystemRedDotUtil.NodeTypeMask_All = NodeTypeMask_All
SkillSystemRedDotUtil.TraverseTreeNode = TraverseTreeNode
SkillSystemRedDotUtil.GetSaveKey = GetSaveKey
SkillSystemRedDotUtil.SaveRootNode = SaveRootNode
SkillSystemRedDotUtil.BubbleUp = BubbleUp

--endregion

return SkillSystemRedDotUtil