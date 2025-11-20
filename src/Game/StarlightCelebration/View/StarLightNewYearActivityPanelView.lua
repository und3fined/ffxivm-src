---
--- Author: v_vvxinchen
--- DateTime: 2025-08-12 10:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local TimeUtil = require("Utils/TimeUtil")

local ItemUtil = require("Utils/ItemUtil")
local ChatDefine = require("Game/Chat/ChatDefine")
local CommonUtil = require("Utils/CommonUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local RewardStatus = ProtoCS.Game.Activity.RewardStatus
local FromHex = _G.UE.FLinearColor.FromHex
local LSTR = _G.LSTR

local BtnState = {NoTimeYet = 1, GoToMainCity = 2, Send = 3, HasSent = 4}

---@class StarLightNewYearActivityPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityTime OpsActivityTimeItemView
---@field Btn UFButton
---@field BtnCopy UFButton
---@field BtnGetReward UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field ImgCheck UFImage
---@field ImgReward UFImage
---@field StarlightCelebrationTransition_UIBP StarlightCelebrationTransitionView
---@field TextBless UFTextBlock
---@field TextBtn UFTextBlock
---@field TextCount UFTextBlock
---@field TextReward UFTextBlock
---@field TextSendTips UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimRewardAvailableHide UWidgetAnimation
---@field AnimRewardAvailableLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StarLightNewYearActivityPanelView = LuaClass(UIView, true)

function StarLightNewYearActivityPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityTime = nil
	--self.Btn = nil
	--self.BtnCopy = nil
	--self.BtnGetReward = nil
	--self.CloseBtn = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.ImgCheck = nil
	--self.ImgReward = nil
	--self.StarlightCelebrationTransition_UIBP = nil
	--self.TextBless = nil
	--self.TextBtn = nil
	--self.TextCount = nil
	--self.TextReward = nil
	--self.TextSendTips = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimRewardAvailableHide = nil
	--self.AnimRewardAvailableLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StarLightNewYearActivityPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityTime)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.StarlightCelebrationTransition_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StarLightNewYearActivityPanelView:OnInit()
	self.TextSendTips:SetText(LSTR(1700057)) --在任意主城的喊话频道发送下方祝福语，领取跨年奖励
	self.TextReward:SetText(LSTR(1700058)) --跨年奖励
end

function StarLightNewYearActivityPanelView:OnDestroy()
	
end

---@type 停留在页面期间可发送时间到了时刷新按钮
function StarLightNewYearActivityPanelView:AddTimer(NodeCfg)
	local TargetTime = TimeUtil.ParseBeijingTime(NodeCfg.StartTime)
	local CurrTime = TimeUtil.GetServerLogicTime()
	local Delay = math.max(TargetTime - CurrTime, 0)  -- 确保非负
	if Delay > 0 then
		self.CheckTimer = self:RegisterTimer(function()
			self:RefreshUIByRewardStatus()
		end, Delay, 0, 1)
	end
end

function StarLightNewYearActivityPanelView:OnShow()
	if self.Params == nil then
		return
	end
	self.ActivityTime:SetParams(nil)
	self:UpdateNodeData()
end

---@type 刷新节点数据和UI
function StarLightNewYearActivityPanelView:UpdateNodeData()
	local NodeList = self.Params.NodeList
	if not table.is_nil_empty(NodeList) then
		local Node, ActivityNode = _G.OpsSeasonActivityMgr:NodeByNodeTitle(NodeList, _G.LSTR(1700045))
		self.NodeCfg = ActivityNode
		self.NodeParams = Node
		self.NodeID = ActivityNode.NodeID
		self:UpdateNodeUI(ActivityNode)
		self:AddTimer(ActivityNode)
	end
end

---@type 刷新节点UI
function StarLightNewYearActivityPanelView:UpdateNodeUI(NodeCfg)
	self.TextTips:SetText(string.format(LSTR(1700063), NodeCfg.StartTime)) --%s后开启
	self.TextTitle:SetText(NodeCfg.NodeDesc)
	self.ActivityTime.TextTime:SetText(self.Params:GetActivityNodeCompleteTime(NodeCfg.NodeID))
	self.ActivityTime.InforBtn.HelpInfoID = self.Params:GetActivityHelpInfo()
	self.TextBless:SetText(NodeCfg.StrParam)
	self.Blessing = NodeCfg.StrParam or ""
	local Rewards = NodeCfg.Rewards and NodeCfg.Rewards[1]
	if Rewards then
		self.TextCount:SetText(Rewards.Num)
		self.RewardsItemID = Rewards.ItemID
		self.RewardsItemNum = Rewards.Num
		local IconPath = UIUtil.GetIconPath(ItemUtil.GetItemIcon(Rewards.ItemID))
		UIUtil.ImageSetBrushFromAssetPath(self.ImgReward, IconPath)
	end
	self:RefreshUIByRewardStatus()
end

---@type 根据不用状态刷新按钮和奖励的显示
function StarLightNewYearActivityPanelView:RefreshUIByRewardStatus()
	local Node = self.NodeParams
	local NodeRewardStatus = Node.Head.RewardStatus
	if NodeRewardStatus == RewardStatus.RewardStatusNo then
		local TargetTime = TimeUtil.ParseBeijingTime(self.NodeCfg.StartTime)
		local CurrTime = TimeUtil.GetServerLogicTime()
		--是否到发送时间
		if CurrTime < TargetTime then
			self.BtnState = BtnState.NoTimeYet
			self.TextBtn:SetText(LSTR(1700059)) --时间未到
			self.TextBtn:SetColorAndOpacity(FromHex("6e2e2b"))
		else
			--是否在主城
			if not _G.StarLightNewYearActivityMgr:IsInMainCity() then
				self.BtnState = BtnState.GoToMainCity
				self.TextBtn:SetText(LSTR(1700060)) --前往主城
			else
				self.BtnState = BtnState.Send
				self.TextBtn:SetText(LSTR(1700061)) --发送
			end
			self.TextBtn:SetColorAndOpacity(FromHex("fff9e7"))
		end
	else
		self.TextBtn:SetText(LSTR(1700062)) --已发送
		self.BtnState = BtnState.HasSent
		self.TextBtn:SetColorAndOpacity(FromHex("6e2e2b"))
		--_G.StarLightNewYearActivityMgr:UnRegisterChatShareGameEvent()
	end

	UIUtil.SetIsVisible(self.TextTips, self.BtnState == BtnState.NoTimeYet)
	UIUtil.SetIsVisible(self.ImgCheck, NodeRewardStatus == RewardStatus.RewardStatusDone)
	if NodeRewardStatus == RewardStatus.RewardStatusWaitGet then
		self:PlayAnimation(self.AnimRewardAvailableLoop, 0, 0, 0, 1.0, false)
	else
		self:StopAnimation(self.AnimRewardAvailableLoop)
		self:PlayAnimation(self.AnimRewardAvailableHide)
	end
end

function StarLightNewYearActivityPanelView:OnHide()
	if self.CheckTimer then
        self:UnRegisterTimer(self.CheckTimer)
		self.CheckTimer = nil
    end
	self:StopAllAnimations()
end


function StarLightNewYearActivityPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CloseBtn, self.OnClickCloseBtn)
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickSendBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnCopy, self.OnClickBtnCopy)
	UIUtil.AddOnClickedEvent(self, self.BtnGetReward, self.OnClickedGetReward)
end

function StarLightNewYearActivityPanelView:OnClickCloseBtn()
	_G.UIViewMgr:HideView(_G.UIViewID.OpsStarLightNewYearActivityPanel)
end

function StarLightNewYearActivityPanelView:OnClickSendBtn()
	if self.BtnState == BtnState.GoToMainCity then
		--前往任意主城，并选中大水晶
		_G.StarLightNewYearActivityMgr:ShowWorldMapSelectCrystal()
	elseif self.BtnState == BtnState.Send then
		--打开聊天窗口，选中区域，录入祝福语
		_G.ChatMgr:ShowChatView(ChatDefine.ChatChannel.Area)
		local ChatView = _G.UIViewMgr:FindVisibleView(_G.UIViewID.ChatMainPanel)
		ChatView.ChatBarPanel:SetChatText(self.Blessing)
	--else
		--不响应
	end
end

---@type 复制祝福语
function StarLightNewYearActivityPanelView:OnClickBtnCopy()
    CommonUtil.ClipboardCopy(self.Blessing)
    MsgTipsUtil.ShowTips(LSTR(910142)) --拷贝成功
end

function StarLightNewYearActivityPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdate, self.OnOpsActivityUpdate)
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.OnOpsActivityUpdate)
end

---@type 节点更新
function StarLightNewYearActivityPanelView:OnOpsActivityUpdate(GetRewardMsg)
	local NodeData = _G.OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID)
	if NodeData and NodeData.NodeList then
		self.Params.NodeList = NodeData.NodeList
		self:UpdateNodeData()
	end
	
	if GetRewardMsg and GetRewardMsg.Reward then
        local Reward = GetRewardMsg.Reward
		---领奖表现展示
		local NodeList = Reward.Detail.Nodes
		for _, Node in ipairs(NodeList) do
			local NodeID = Node.Head.NodeID
			local NodeRewardStatus = Node.Head.RewardStatus
			if self.NodeID and NodeID and self.NodeID == NodeID and NodeRewardStatus == RewardStatus.RewardStatusDone then
				local ResID = self.RewardsItemID
				if ResID and ResID > 0 then
					_G.LootMgr:SetDealyState(true) --屏蔽飘字，等关领取弹窗再打开
					local ItemList = {
						{ResID = ResID, Num = self.RewardsItemNum or 1}
					}
					_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, {ItemList = ItemList})
				end
				break
			end
		end
	end
end

---@type 获取奖励
function StarLightNewYearActivityPanelView:OnClickedGetReward()
	local Node = self.NodeParams
	local NodeRewardStatus = Node.Head.RewardStatus
    if NodeRewardStatus == RewardStatus.RewardStatusWaitGet then
		_G.OpsActivityMgr:SendActivityNodeGetReward(self.NodeID)
	else
		local ResID = self.RewardsItemID
		if ResID and ResID > 0 then
			ItemTipsUtil.ShowTipsByResID(ResID, self.ImgReward, {X = 10, Y = 0})
		end
	end
end

function StarLightNewYearActivityPanelView:OnRegisterBinder()

end

return StarLightNewYearActivityPanelView