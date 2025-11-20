--
-- Author: ZhengJanChuan
-- Date: 2025-07-17 20:30
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local OpsReturnDefine = require("Game/Ops/View/OpsReturn/OpsReturnDefine")
local OpsReturnSigninItemVM = require("Game/Ops/VM/OpsReturn/Item/OpsReturnSigninItemVM")
local OpsReturnTaskListItemVM = require("Game/Ops/VM/OpsReturn/Item/OpsReturnTaskListItemVM")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local OpsReturnTagCfg = require("TableCfg/OpsReturnTagCfg")
local ProtoCS = require("Protocol/ProtoCS")
local OpsReturnMgr = require("Game/Ops/OpsReturn/OpsReturnMgr")

local SelectedColor = "#ffeebb"
local NormalColor = "#313131"

local LockedSelectedColor = "#ffeebb"
local LockedNormalColor = "#3630274C"

---@class OpsReturnTaskPanelVM : UIViewModel
local OpsReturnTaskPanelVM = LuaClass(UIViewModel)

---Ctor
function OpsReturnTaskPanelVM:Ctor()
	self.Title = ""
	self.TagName = ""
	self.Stage1Checked = true
	self.Stage2Checked = false
	self.Stage3Checked = false
	self.Stage2Locked = true
	self.Stage3Locked = true

	self.TaskList = UIBindableList.New(OpsReturnTaskListItemVM)
	self.SignList = UIBindableList.New(OpsReturnSigninItemVM)

	self.Stage1Color = NormalColor
	self.Stage2Color = NormalColor
	self.Stage3Color = NormalColor

	self.IsTaskEmpty = true

	self.StageUnlock2Color = LockedNormalColor
	self.StageUnlock3Color = LockedNormalColor

end

function OpsReturnTaskPanelVM:OnInit()
end

function OpsReturnTaskPanelVM:OnBegin()
end

function OpsReturnTaskPanelVM:OnEnd()
end

function OpsReturnTaskPanelVM:OnShutdown()
end

function OpsReturnTaskPanelVM:UpdateStageBtn(StageIndex)
	self.Stage1Checked = StageIndex == OpsReturnDefine.ReturnTaskStage.Frist
	self.Stage2Checked = StageIndex == OpsReturnDefine.ReturnTaskStage.Second
	self.Stage3Checked = StageIndex == OpsReturnDefine.ReturnTaskStage.Third

	self.Stage1Color = StageIndex == OpsReturnDefine.ReturnTaskStage.Frist and  SelectedColor or NormalColor
	self.Stage2Color = StageIndex == OpsReturnDefine.ReturnTaskStage.Second and SelectedColor or NormalColor
	self.Stage3Color = StageIndex == OpsReturnDefine.ReturnTaskStage.Third and SelectedColor  or NormalColor

	self.StageUnlock2Color = StageIndex == OpsReturnDefine.ReturnTaskStage.Second and LockedSelectedColor or LockedNormalColor
	self.StageUnlock3Color = StageIndex == OpsReturnDefine.ReturnTaskStage.Third and LockedSelectedColor  or LockedNormalColor
end

-- 更新标签名
function OpsReturnTaskPanelVM:UpdateTagName()
	local TagCfg = OpsReturnTagCfg:FindCfgByKey(OpsReturnMgr:GetCurTag())
	if TagCfg ~= nil then
		self.TagName = TagCfg.TagName or ""
	end
end

-- 更新任务阶段
function OpsReturnTaskPanelVM:UpdateTaskStage()
	local Stage = OpsReturnMgr:GetTaskStage()

	self.Stage2Locked = Stage >= OpsReturnDefine.ReturnTaskStage.Second
	self.Stage3Locked = Stage >= OpsReturnDefine.ReturnTaskStage.Third
end

-- 更新阶段的任务
function OpsReturnTaskPanelVM:UpdateTaskList(StageIndex)
	local CurTag = OpsReturnMgr:GetCurTag()

	local NodeID  = OpsReturnDefine.TagIDToNodeID[CurTag]
	if NodeID == nil then
		_G.FLOG_INFO("OpsReturnTaskPanelVM:UpdateTaskList NodeID == nil")
		return
	end

	local TaskIDList = OpsReturnMgr:GetTaskIDList()
	local CurStage = OpsReturnMgr:GetTaskStage()
	local ItemList = {}
	local NodeIDList = {}

	self.TaskList:Clear()
	-- 保存在服务器里的任务列表
	for _, id in ipairs(TaskIDList) do
		local Cfg = ActivityNodeCfg:FindCfgByKey(id)
		if Cfg ~= nil then
			if Cfg ~= nil then
				if Cfg.NodeSort == StageIndex and StageIndex <= CurStage then
					local Item = self:CreateTaskItemVM(id)
					if Item ~= nil and not table.contain(NodeIDList, id) then
						table.insert(NodeIDList, id)
						table.insert(ItemList, Item)
					end
				end
			end
		end
	end

	if  #ItemList <=  0 then
		-- 当前的任务列表
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
		if NodeCfg ~= nil then
			for index, id in ipairs(NodeCfg.Params or {}) do
				if index > 1 then
					local Cfg = ActivityNodeCfg:FindCfgByKey(id)
					if Cfg ~= nil then
						if Cfg.NodeSort == StageIndex and StageIndex <= CurStage  then
							local Item = self:CreateTaskItemVM(id)
							if Item ~= nil and not table.contain(NodeIDList,id) then
								table.insert(ItemList, Item)
								table.insert(NodeIDList, id)
							end
						end
					end
				end
			end
		end
	end

	self.TaskList:UpdateByValues(ItemList)
	self.IsTaskEmpty = #ItemList == 0
end

function OpsReturnTaskPanelVM:GetTaskList()
end

--Todo 还有2个任务的逻辑
function OpsReturnTaskPanelVM:CreateTaskItemVM(id)
	local Cfg = ActivityNodeCfg:FindCfgByKey(id)
	local Data =  _G.OpsReturnMgr:GetNodeHeadData(id)
	local Extra = _G.OpsActivityMgr:GetNodeExtraData(_G.OpsReturnMgr:GetActivityID(), id)
	if Cfg ~= nil then
		local Item = {}
		Item.NodeID = Cfg.NodeID
		Item.WidgetIndex = (Cfg.Params and table.length(Cfg.Params) > 2) and 2 or 1
		Item.TaskTitle = Cfg.NodeDesc
		Item.TaskProgressNum = (Extra and Extra.Progress )and Extra.Progress.Value or 0
		Item.AwardBtnState = Data.RewardStatus
		Item.TaskTarget = Cfg.Target
		Item.RewardList = Cfg.Rewards
		return Item
	end
end

function OpsReturnTaskPanelVM:UpdateSignList(SignList)
	self.SignList:Clear()
	local SelectedIndex = nil
	local ItemList = {}
	for i = 1, #SignList do
		local Item = {}
		Item.Index = i
		Item.NodeID =  SignList[i].NodeID
		Item.RewardList = SignList[i].Rewards
		Item.RewardsStatus = SignList[i].RewardsStatus
		if Item.RewardsStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet and SelectedIndex == nil then
			SelectedIndex = i
		end
		table.insert(ItemList, Item)
	end
	self.SignList:UpdateByValues(ItemList)
	return SelectedIndex or 1
end

--要返回当前类
return OpsReturnTaskPanelVM