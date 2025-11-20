---
--- Author: yutingzhan
--- DateTime: 2025-07-28 10:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local SweetChocoItemID = 60110149
local BitterChocoItemID = 60110150
---@class OpsLoverFestivalGuideWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnGetAll CommBtnSView
---@field BtnGo CommBtnSView
---@field BtnGo2 CommBtnSView
---@field BtnItemTips1 UFButton
---@field BtnItemTips2 UFButton
---@field FTextBlock_6 UFTextBlock
---@field PanelUnclaimed UFCanvasPanel
---@field RichTextTaskGive URichTextBox
---@field SkillHandleCloseBtn SkillHandleCloseBtnView
---@field TextReward1 UFTextBlock
---@field TextReward2 UFTextBlock
---@field TextShowReward UFTextBlock
---@field TextTask1 UFTextBlock
---@field TextTask2 UFTextBlock
---@field TextTaskContent1 UFTextBlock
---@field TextTaskContent2 UFTextBlock
---@field TextTaskGive UFTextBlock
---@field TextTaskTitle1 UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLoverFestivalGuideWinView = LuaClass(UIView, true)

function OpsLoverFestivalGuideWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnGetAll = nil
	--self.BtnGo = nil
	--self.BtnGo2 = nil
	--self.BtnItemTips1 = nil
	--self.BtnItemTips2 = nil
	--self.FTextBlock_6 = nil
	--self.PanelUnclaimed = nil
	--self.RichTextTaskGive = nil
	--self.SkillHandleCloseBtn = nil
	--self.TextReward1 = nil
	--self.TextReward2 = nil
	--self.TextShowReward = nil
	--self.TextTask1 = nil
	--self.TextTask2 = nil
	--self.TextTaskContent1 = nil
	--self.TextTaskContent2 = nil
	--self.TextTaskGive = nil
	--self.TextTaskTitle1 = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLoverFestivalGuideWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGetAll)
	self:AddSubView(self.BtnGo)
	self:AddSubView(self.BtnGo2)
	self:AddSubView(self.SkillHandleCloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsLoverFestivalGuideWinView:OnInit()
	self.TextTitle:SetText(LSTR(100151))
	self.TextShowReward:SetText(LSTR(100154))
	self.TextTaskTitle1:SetText(LSTR(100155))
	self.TextTaskGive:SetText(LSTR(100156))
	self.TextTaskContent2:SetText(LSTR(100158))
	self.TextReward1:SetText(LSTR(100160))
	self.TextReward2:SetText(LSTR(100159))
	self.RichTextTaskGive:SetText(LSTR(100161))
end

function OpsLoverFestivalGuideWinView:OnDestroy()

end

function OpsLoverFestivalGuideWinView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	local NodeDataList = self.Params.NodeList
	self:UpdateGetTaskState(NodeDataList)
end

function OpsLoverFestivalGuideWinView:OnHide()

end

function OpsLoverFestivalGuideWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnBtnGoClick)
	UIUtil.AddOnClickedEvent(self, self.BtnGo2, self.OnBtnGo2Click)
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnBtnCloseClick)
	UIUtil.AddOnClickedEvent(self, self.BtnGetAll, self.OnBtnGetAllClick)
	UIUtil.AddOnClickedEvent(self, self.BtnItemTips1, self.OnBtnItemTips1Click)
	UIUtil.AddOnClickedEvent(self, self.BtnItemTips2, self.OnBtnItemTips2Click)

end

function OpsLoverFestivalGuideWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.OnOpsActivityUpdate)
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeChanged, self.OnOpsActivityUpdate)
end

function OpsLoverFestivalGuideWinView:OnRegisterBinder()

end

function OpsLoverFestivalGuideWinView:OnBtnGoClick()
	if self.IsStatisticNodeAvailable then
		OpsActivityMgr:SendActivityNodeGetReward(self.StatisticNodeID)
	else
		OpsActivityMgr:Jump(self.JumpType, self.JumpParam)
	end
end

function OpsLoverFestivalGuideWinView:OnBtnCloseClick()
	self:Hide()
end

function OpsLoverFestivalGuideWinView:UpdateGetTaskState(NodeDataList)
	local WaitGetChocoNum = 0
	for _, Node in ipairs(NodeDataList) do
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(Node.Head.NodeID)
		if NodeCfg ~= nil then
			if NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeStatistic then
				self.TextTask1:SetText(NodeCfg.NodeDesc)
				self.JumpType = NodeCfg.JumpType
				self.JumpParam = NodeCfg.JumpParam
				self.StatisticNodeID = Node.Head.NodeID
				if Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
					self.BtnGo:SetText(LSTR(100036))
					self.BtnGo:SetIsRecommendState(true)
					self.IsStatisticNodeAvailable = true
				else
					self.BtnGo:SetText(NodeCfg.JumpButton)
					self.IsStatisticNodeAvailable = false
				end
				self.TextTaskContent1:SetText(string.format(LSTR(100157), Node.Head.CurrFinTimes))
			elseif NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeAccumulativeLoginDay then
				self.TextTask2:SetText(NodeCfg.NodeDesc)
				self.LoginDayNodeID = Node.Head.NodeID
				if Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
					self.BtnGo2:SetText(LSTR(100036))
					self.BtnGo2:SetIsRecommendState(true)
				elseif Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
					self.BtnGo2:SetIsDoneState(true, LSTR(100037))
				end
			end
		end
		WaitGetChocoNum = WaitGetChocoNum + (Node.Head.CurrFinTimes - Node.Head.AwardTimes)
	end
	if WaitGetChocoNum > 0 then
		UIUtil.SetIsVisible(self.PanelUnclaimed, true)
		self.FTextBlock_6:SetText(string.format(LSTR(100162), WaitGetChocoNum))
		self.BtnGetAll:SetText(LSTR(100163))
		self.BtnGetAll:SetIsRecommendState(true)
	else
		UIUtil.SetIsVisible(self.PanelUnclaimed, false)
	end
end

function OpsLoverFestivalGuideWinView:OnOpsActivityUpdate()
	local NodeInfo = OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID)
	if NodeInfo and NodeInfo.NodeList then
		self:UpdateGetTaskState(NodeInfo.NodeList)
	end
end

function OpsLoverFestivalGuideWinView:OnBtnGetAllClick()
	OpsActivityMgr:SendActivityGetReward(self.Params.ActivityID)
end

function OpsLoverFestivalGuideWinView:OnBtnGo2Click()
	OpsActivityMgr:SendActivityNodeGetReward(self.LoginDayNodeID)
end

function OpsLoverFestivalGuideWinView:OnBtnItemTips1Click()
	ItemTipsUtil.ShowTipsByResID(BitterChocoItemID , self.BtnItemTips1, nil, nil, 30)
end

function OpsLoverFestivalGuideWinView:OnBtnItemTips2Click()
	ItemTipsUtil.ShowTipsByResID(SweetChocoItemID , self.BtnItemTips2, nil, nil, 30)
end

return OpsLoverFestivalGuideWinView