---
--- Author: Administrator
--- DateTime: 2025-06-16 19:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemUtil = require("Utils/ItemUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local OpsLimitedTimeSlotItemVM = require("Game/Ops/VM/OpsLimitedTimeSlotItemVM")

local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsNewcomersMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityTime OpsActivityTimeItemView
---@field Btn1 UFButton
---@field Btn2 UFButton
---@field Btn3 UFButton
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field ImgSlot1 UFImage
---@field ImgSlot2 UFImage
---@field ImgSlot3 UFImage
---@field RichTextPanelContent1 URichTextBox
---@field RichTextPanelContent2 URichTextBox
---@field TextPanelTitle1 UFTextBlock
---@field TextPanelTitle2 UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewcomersMainPanelView = LuaClass(UIView, true)

function OpsNewcomersMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityTime = nil
	--self.Btn1 = nil
	--self.Btn2 = nil
	--self.Btn3 = nil
	--self.CommonBkgMask_UIBP = nil
	--self.ImgSlot1 = nil
	--self.ImgSlot2 = nil
	--self.ImgSlot3 = nil
	--self.RichTextPanelContent1 = nil
	--self.RichTextPanelContent2 = nil
	--self.TextPanelTitle1 = nil
	--self.TextPanelTitle2 = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewcomersMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityTime)
	self:AddSubView(self.CommonBkgMask_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewcomersMainPanelView:OnInit()

end

function OpsNewcomersMainPanelView:OnDestroy()

end

function OpsNewcomersMainPanelView:OnShow()
	local ActCfg = self.Params.Activity or {}
    if self.TextTitle then
        self.TextTitle:SetText(ActCfg.Title or "")
    end
	self.RewardItemIDList = {}
	local NodeIDList = {}
	local ClientShowNodes = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow) or {}
	for i = 1, #ClientShowNodes do
		table.insert(NodeIDList, (ClientShowNodes[i].Head or {}).NodeID or 0)
	end
	table.sort(NodeIDList, function(LeftID, RightID) return LeftID < RightID end)

	self:ShowPanel(NodeIDList[1], 2)
end

function OpsNewcomersMainPanelView:ShowPanel(NodeID, NodeIndex)
	local ClientShowNodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
	if ClientShowNodeCfg == nil then
		return
	end
	local TextPanelTitleView = self["TextPanelTitle" .. tostring(NodeIndex)]
	if TextPanelTitleView ~= nil then 
		TextPanelTitleView:SetText(ClientShowNodeCfg.NodeTitle or "")
	end

	local RichTextPanelContentView = self["RichTextPanelContent" .. tostring(NodeIndex)]
	if RichTextPanelContentView ~= nil then 
		RichTextPanelContentView:SetText(ClientShowNodeCfg.NodeDesc or "")
	end

	local Rewards = ClientShowNodeCfg.Rewards or {}
	for i = 1, 2 do
		local Reward = Rewards[i] or {}
		local PanelIndex = (NodeIndex - 1) * 2 + i
		local RewardItemCfg = ItemCfg:FindCfgByKey(Reward.ItemID or 0)
		local ImgView = self["ImgSlot" .. tostring(PanelIndex)]
		if RewardItemCfg ~= nil and ImgView ~= nil then
			table.insert(self.RewardItemIDList, Reward.ItemID)
			UIUtil.ImageSetBrushFromAssetPath(ImgView, ItemCfg.GetIconPath(RewardItemCfg.IconID))
		end
	end
end

function OpsNewcomersMainPanelView:OnHide()

end

function OpsNewcomersMainPanelView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.Btn1, self.OnBtnClick, {1})
	--UIUtil.AddOnClickedEvent(self, self.Btn2, self.OnBtnClick, {2})
	--UIUtil.AddOnClickedEvent(self, self.Btn3, self.OnBtnClick, {3})
end

function OpsNewcomersMainPanelView:OnRegisterGameEvent()

end

function OpsNewcomersMainPanelView:OnRegisterBinder()

end

function OpsNewcomersMainPanelView:OnBtnClick(Params)
	local BtnIndex = Params[1] or 0
	local BtnView = self["Btn" .. tostring(BtnIndex)]
	local ResID = (self.RewardItemIDList or {})[BtnIndex] or 0
	if BtnView ~= nil and ResID ~= 0 then
		ItemTipsUtil.ShowTipsByResID(ResID, BtnView, {X = 0,Y = 0})
	end
end

return OpsNewcomersMainPanelView