---
--- Author: Administrator
--- DateTime: 2025-07-10 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local OpsReturnTaskPanelVM = require("Game/Ops/VM/OpsReturn/OpsReturnTaskPanelVM")
local OpsReturnDefine = require("Game/Ops/View/OpsReturn/OpsReturnDefine")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local LSTR = _G.LSTR
local RewardStatus = ProtoCS.Game.Activity.RewardStatus

---@class OpsReturnTaskPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChangelabel CommBtnSView
---@field BtnItem1 UFButton
---@field BtnItem2 UFButton
---@field BtnItem3 UFButton
---@field CommEmpty CommBackpackEmptyView
---@field CommonRedDot CommonRedDotView
---@field CommonRedDot_1 CommonRedDotView
---@field IconLock2 UFImage
---@field IconLock3 UFImage
---@field ImgBtnSelect1 UFImage
---@field ImgBtnSelect2 UFImage
---@field ImgBtnSelect3 UFImage
---@field PanelTab1 UFCanvasPanel
---@field PanelTab2 UFCanvasPanel
---@field PanelTab3 UFCanvasPanel
---@field TableViewSignin UTableView
---@field TableViewTask UTableView
---@field TextHint UFTextBlock
---@field TextSignin UFTextBlock
---@field TextTabName1 UFTextBlock
---@field TextTabName2 UFTextBlock
---@field TextTabName3 UFTextBlock
---@field TextTagName UFTextBlock
---@field TextTask UFTextBlock
---@field TypeToggleBtn UFCanvasPanel
---@field AnimChangeTab UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsReturnTaskPanelView = LuaClass(UIView, true)

function OpsReturnTaskPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChangelabel = nil
	--self.BtnItem1 = nil
	--self.BtnItem2 = nil
	--self.BtnItem3 = nil
	--self.CommEmpty = nil
	--self.CommonRedDot = nil
	--self.CommonRedDot_1 = nil
	--self.IconLock2 = nil
	--self.IconLock3 = nil
	--self.ImgBtnSelect1 = nil
	--self.ImgBtnSelect2 = nil
	--self.ImgBtnSelect3 = nil
	--self.PanelTab1 = nil
	--self.PanelTab2 = nil
	--self.PanelTab3 = nil
	--self.TableViewSignin = nil
	--self.TableViewTask = nil
	--self.TextHint = nil
	--self.TextSignin = nil
	--self.TextTabName1 = nil
	--self.TextTabName2 = nil
	--self.TextTabName3 = nil
	--self.TextTagName = nil
	--self.TextTask = nil
	--self.TypeToggleBtn = nil
	--self.AnimChangeTab = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsReturnTaskPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnChangelabel)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommonRedDot)
	self:AddSubView(self.CommonRedDot_1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsReturnTaskPanelView:OnInit()

	self.ViewModel = OpsReturnTaskPanelVM.New()
	self.TaskListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTask, nil, true)
	self.SignListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSignin, nil, true)

	self.Binders = {
		{"Title", UIBinderSetText.New(self, self.TextBubbleTitle)},
		{"TagName", UIBinderSetText.New(self, self.TextTagName)},
		{"Stage1Checked", UIBinderSetIsVisible.New(self, self.ImgBtnSelect1)},
		{"Stage2Checked", UIBinderSetIsVisible.New(self, self.ImgBtnSelect2)},
		{"Stage3Checked", UIBinderSetIsVisible.New(self, self.ImgBtnSelect3)},
		{"Stage2Locked", UIBinderSetIsVisible.New(self, self.IconLock2, true)},
		{"Stage3Locked", UIBinderSetIsVisible.New(self, self.IconLock3, true)},
		{"StageUnlock2Color", UIBinderSetColorAndOpacityHex.New(self, self.IconLock2)},
		{"StageUnlock3Color", UIBinderSetColorAndOpacityHex.New(self, self.IconLock3)},
		{"Stage1Color", UIBinderSetColorAndOpacityHex.New(self, self.TextTabName1)},
		{"Stage2Color", UIBinderSetColorAndOpacityHex.New(self, self.TextTabName2)},
		{"Stage3Color", UIBinderSetColorAndOpacityHex.New(self, self.TextTabName3)},
		{"TaskList", UIBinderUpdateBindableList.New(self, self.TaskListAdapter)},
		{"SignList", UIBinderUpdateBindableList.New(self, self.SignListAdapter)},
		{"IsTaskEmpty", UIBinderSetIsVisible.New(self, self.CommEmpty) },
	}

end

function OpsReturnTaskPanelView:OnDestroy()

end

function OpsReturnTaskPanelView:OnShow()
	self:InitText()
	_G.OpsReturnMgr:SetCurSignNodeID(nil)
	_G.OpsReturnMgr:SetCurStageTaskNodeID(nil)
	self.CommonRedDot:SetRedDotIDByID(OpsReturnDefine.RedDotID[OpsReturnDefine.RedDotType.Stage2])
	self.CommonRedDot_1:SetRedDotIDByID(OpsReturnDefine.RedDotID[OpsReturnDefine.RedDotType.Stage3])
	

	self:OnUpdateOpsReturn()

	--  更新当前的数据 选中可以领奖的阶段
	local SelectedStage = self:GetSelectedStage()
	self.Stage = _G.OpsReturnMgr:GetTaskStage()
	if SelectedStage == 1 then
	self:OnClickedStage1()
	elseif SelectedStage == 2 then
	self:OnClickedStage2()
	elseif SelectedStage == 3 then
	self:OnClickedStage3()
	end
	self.CurStage = SelectedStage
	if self.ViewModel then
		self.ViewModel:UpdateTagName()
		self.ViewModel:UpdateTaskStage()
	end

end

function OpsReturnTaskPanelView:OnHide()
end

function OpsReturnTaskPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnItem1, self.OnClickedStage1)
	UIUtil.AddOnClickedEvent(self, self.BtnItem2, self.OnClickedStage2)
	UIUtil.AddOnClickedEvent(self, self.BtnItem3, self.OnClickedStage3)
	UIUtil.AddOnClickedEvent(self, self.BtnChangelabel, self.OnClickedChangedLabel)
end

function OpsReturnTaskPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.UpdateOpsReturn, self.OnUpdateOpsReturn)
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.OnOpsActivityNodeGetReward) -- 领奖
end

function OpsReturnTaskPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsReturnTaskPanelView:InitText()
	self.TextTask:SetText(LSTR(1680010)) --回归挑战任务
	self.TextSignin:SetText(LSTR(1680011)) --回归签到任务
	self.BtnChangelabel:SetText(LSTR(1680012)) --更换标签
	self.TextTabName1:SetText(LSTR(1680013)) --阶段一
	self.TextTabName2:SetText(LSTR(1680014)) --阶段二
	self.TextTabName3:SetText(LSTR(1680015)) --阶段三
	self.TextHint:SetText(LSTR(1680016)) --每日解锁一阶段任务,每阶段奖励只能领取一次
end

function OpsReturnTaskPanelView:GetSelectedStage()
	local CurStage = _G.OpsReturnMgr:GetTaskStage()
    local ServerTaskID =  _G.OpsReturnMgr:GetTaskIDList()
    local CurTag = _G.OpsReturnMgr:GetCurTag()
    for i = 1, 3 do
        if CurStage >= i then
            if ServerTaskID[i] == nil then
                local TaskID = _G.OpsReturnMgr:GetStaskTaskByTag(CurTag, i)
                local Data = _G.OpsReturnMgr:GetNodeHeadData(TaskID)
                if Data ~= nil and Data.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
                    return i
                end
            end
        end
    end
	return 1
end

function OpsReturnTaskPanelView:OnClickedStage1()
	self.CurStage = OpsReturnDefine.ReturnTaskStage.Frist
	self.ViewModel:UpdateStageBtn(OpsReturnDefine.ReturnTaskStage.Frist)
	self.ViewModel:UpdateTaskList(OpsReturnDefine.ReturnTaskStage.Frist)
	self.ViewModel:UpdateTaskStage()
	UIUtil.TextBlockSetOutlineSize(self.TextTabName1, OpsReturnDefine.ReturnTaskStage.Frist and 0 or 2)
	UIUtil.TextBlockSetOutlineSize(self.TextTabName2, OpsReturnDefine.ReturnTaskStage.Second and 0 or 2)
	UIUtil.TextBlockSetOutlineSize(self.TextTabName3, OpsReturnDefine.ReturnTaskStage.Third and 0 or 2)
	self:PlayAnimation(self.AnimChangeTab)
	_G.OpsReturnMgr:SetStageOpenTimeStatus(1, _G.TimeUtil.GetServerLogicTime())
end

function OpsReturnTaskPanelView:OnClickedStage2()
	self.CurStage = OpsReturnDefine.ReturnTaskStage.Second
	self:UpdateStageTime(OpsReturnDefine.ReturnTaskStage.Second)
	self.ViewModel:UpdateStageBtn(OpsReturnDefine.ReturnTaskStage.Second)
	self.ViewModel:UpdateTaskList(OpsReturnDefine.ReturnTaskStage.Second)
	self.ViewModel:UpdateTaskStage()

	UIUtil.TextBlockSetOutlineSize(self.TextTabName1, OpsReturnDefine.ReturnTaskStage.Frist and 0 or 2)
	UIUtil.TextBlockSetOutlineSize(self.TextTabName2, OpsReturnDefine.ReturnTaskStage.Second and 0 or 2)
	UIUtil.TextBlockSetOutlineSize(self.TextTabName3, OpsReturnDefine.ReturnTaskStage.Third and 0 or 2)
	self:PlayAnimation(self.AnimChangeTab)
	_G.OpsReturnMgr:SetStageOpenTimeStatus(2, _G.TimeUtil.GetServerLogicTime())

end

function OpsReturnTaskPanelView:OnClickedStage3()
	self.CurStage = OpsReturnDefine.ReturnTaskStage.Third
	self:UpdateStageTime(OpsReturnDefine.ReturnTaskStage.Third)
	self.ViewModel:UpdateStageBtn(OpsReturnDefine.ReturnTaskStage.Third)
	self.ViewModel:UpdateTaskList(OpsReturnDefine.ReturnTaskStage.Third)
	self.ViewModel:UpdateTaskStage()
	UIUtil.TextBlockSetOutlineSize(self.TextTabName1, OpsReturnDefine.ReturnTaskStage.Frist and 0 or 2)
	UIUtil.TextBlockSetOutlineSize(self.TextTabName2, OpsReturnDefine.ReturnTaskStage.Second and 0 or 2)
	UIUtil.TextBlockSetOutlineSize(self.TextTabName3, OpsReturnDefine.ReturnTaskStage.Third and 0 or 2)
	self:PlayAnimation(self.AnimChangeTab)
	_G.OpsReturnMgr:SetStageOpenTimeStatus(3, _G.TimeUtil.GetServerLogicTime())
end

function OpsReturnTaskPanelView:OnClickedChangedLabel()
	local NextTag = _G.OpsReturnMgr:GetNextTagID()
	_G.OpsReturnMgr:UpdateReturnData(_G.OpsReturnMgr:GetTagList(), NextTag,  _G.OpsReturnMgr:GetTaskFinishedList())
end

function OpsReturnTaskPanelView:UpdateStageTime(Stage)
	local OpenTime = _G.OpsReturnMgr:GetStageOpenTime(Stage)
	local TimeStr = LocalizationUtil.LocalizeStringDate_Timestamp_YMDHMS(OpenTime)
	self.CommEmpty:SetTipsContent(string.format("%s 解锁", TimeStr))
end

function OpsReturnTaskPanelView:OnUpdateOpsReturn()
	local NodeData = OpsActivityMgr:GetActivtyNodeInfo(_G.OpsReturnMgr:GetActivityID())
	local SignList = {}
	if NodeData and NodeData.NodeList then
		local NodeList = NodeData.NodeList or {}
		for i = 1, #NodeList do
			if NodeList[i].Head and NodeList[i].Head.NodeID  then
				local CfgNode = ActivityNodeCfg:FindCfgByKey(NodeList[i].Head.NodeID)
				if CfgNode ~= nil then
					if CfgNode.NodeType == ProtoRes.Game.ActivityNodeType.ActivityNodeTypeAccumulativeLoginDay then
						if NodeList[i].Head.NodeID ~= OpsReturnDefine.ActivityNodeID[OpsReturnDefine.ActivityNodeType.MailNodeID] then
							local RewardsStatus = NodeList[i].Head.RewardStatus
							local Data = {NodeID = NodeList[i].Head.NodeID, Rewards = CfgNode.Rewards, RewardsStatus = RewardsStatus, NodeSort = CfgNode.NodeSort}
							table.insert(SignList, Data)
						end
					end
				end
			end
		end
	end

	table.sort(SignList, function(a, b)
		return a.NodeSort > b.NodeSort
	end)

	local SelectedIndex = self.ViewModel:UpdateSignList(SignList)
	self.SignListAdapter:ScrollToIndex(SelectedIndex)
	self.ViewModel:UpdateTagName()
	self.ViewModel:UpdateTaskList(self.CurStage)
end

function OpsReturnTaskPanelView:OnOpsActivityNodeGetReward(GetRewardMsg)
	if GetRewardMsg and GetRewardMsg.Reward then
        local Reward = GetRewardMsg.Reward
		---领奖表现展示
		local NodeList = Reward.Detail.Nodes

		local SignNodeID = _G.OpsReturnMgr:GetCurSignNodeID()
		local TaskNodeID = _G.OpsReturnMgr:GetCurStageTaskNodeID()
		local CurRewardID = SignNodeID ~= nil and SignNodeID or TaskNodeID
		for _, Node in ipairs(NodeList) do
			local NodeID = Node.Head.NodeID
			local NodeRewardStatus = Node.Head.RewardStatus
			if CurRewardID and NodeID and CurRewardID == NodeID and NodeRewardStatus == RewardStatus.RewardStatusDone then
				_G.LootMgr:SetDealyState(true) --屏蔽飘字，等关领取弹窗再打开
				_G.OpsReturnMgr:SetCurSignNodeID(nil)
				_G.OpsReturnMgr:SetCurStageTaskNodeID(nil)
				_G.OpsReturnMgr:SetRedDot()
				local CfgNode = ActivityNodeCfg:FindCfgByKey(CurRewardID)
				if CfgNode ~= nil and CfgNode.Rewards then
					local ItemList = {}
					for _, v in ipairs(CfgNode.Rewards) do
						if v.ItemID >0 then
							table.insert(ItemList, {ResID = v.ItemID, Num = v.Num or 1})
						end
					end
					if #ItemList > 0 then 
						_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, {ItemList = ItemList})
					end
				end
				break
			end
		end
	end
	self:OnUpdateOpsReturn()
	self.ViewModel:UpdateTaskList(self.CurStage)
end

return OpsReturnTaskPanelView