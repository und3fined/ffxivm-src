---
--- Author: yutingzhan
--- DateTime: 2025-08-27 14:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsGirlsDayAwardPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Award100 OpsGirlsDayAwardItemView
---@field Award200 OpsGirlsDayAwardItemView
---@field Award300 OpsGirlsDayAwardItemView
---@field Award400 OpsGirlsDayAwardItemView
---@field Award500 OpsGirlsDayAwardItemView
---@field Award600 OpsGirlsDayAwardItemView
---@field Award700 OpsGirlsDayAwardItemView
---@field Award800 OpsGirlsDayAwardItemView
---@field BtnTips UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommInforBtn CommInforBtnView
---@field PanelTips UFCanvasPanel
---@field RichTextTips URichTextBox
---@field TextHint UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsGirlsDayAwardPanelView = LuaClass(UIView, true)

function OpsGirlsDayAwardPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Award100 = nil
	--self.Award200 = nil
	--self.Award300 = nil
	--self.Award400 = nil
	--self.Award500 = nil
	--self.Award600 = nil
	--self.Award700 = nil
	--self.Award800 = nil
	--self.BtnTips = nil
	--self.CloseBtn = nil
	--self.CommInforBtn = nil
	--self.PanelTips = nil
	--self.RichTextTips = nil
	--self.TextHint = nil
	--self.TextQuantity = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsGirlsDayAwardPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Award100)
	self:AddSubView(self.Award200)
	self:AddSubView(self.Award300)
	self:AddSubView(self.Award400)
	self:AddSubView(self.Award500)
	self:AddSubView(self.Award600)
	self:AddSubView(self.Award700)
	self:AddSubView(self.Award800)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommInforBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsGirlsDayAwardPanelView:OnInit()

end

function OpsGirlsDayAwardPanelView:OnDestroy()

end

function OpsGirlsDayAwardPanelView:OnShow()
	if self.Params == nil then
		return
	end
	self.TextTitle:SetText(LSTR(100171))
	self.TextHint:SetText(LSTR(100172))
	self.RichTextTips:SetText(LSTR(100173))
	self.TextTips:SetText(LSTR(100170))
	self.TextQuantity:SetText(self.Params.Num)
	self:UpdateRewardStatus()
	self:SetRewardItem()
end

function OpsGirlsDayAwardPanelView:OnHide()

end

function OpsGirlsDayAwardPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTips, self.OnBtnTipsClick)
end

function OpsGirlsDayAwardPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.UpdateRewardStatus)
	self:RegisterGameEvent(_G.EventID.LootItemUpdateRes, self.OnLootItemUpdateRes)
	self:RegisterGameEvent(_G.EventID.RefreshSnowRiceFruitNum, self.RefreshSnowRiceFruitNum)
end

function OpsGirlsDayAwardPanelView:OnRegisterBinder()

end

function OpsGirlsDayAwardPanelView:OnBtnTipsClick()
	local StageJumpInfo = self.Params.ShopJumpInfo
	if StageJumpInfo then
		_G.OpsActivityMgr:Jump(StageJumpInfo.JumpType, StageJumpInfo.JumpParam)
	end
end

function OpsGirlsDayAwardPanelView:SetRewardItem()
	local NodeList = self.GetAwardNodeList
	for Index, Node in ipairs(NodeList) do
		local AwardItem = self["Award" .. Index .. "00"]
		local NodeID  = Node.Head.NodeID
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
		if AwardItem and NodeCfg then
			AwardItem:SetRewardItem(NodeCfg)
		end
	end
end

function OpsGirlsDayAwardPanelView:UpdateRewardStatus()
	local NodeListInfo = OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID)
	if NodeListInfo == nil then
		return
	end
	local NodeList = NodeListInfo.NodeList
	self.GetAwardNodeList = {}
	if NodeList then
		for _, Node in ipairs(NodeList) do
			local NodeID  = Node.Head.NodeID
			local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
			if NodeCfg and NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeDaughterDayGetAward then
				table.insert(self.GetAwardNodeList, Node)
			end
		end
	end
    table.sort(self.GetAwardNodeList, function(a, b) return a.Head.NodeID < b.Head.NodeID end)
	for Index, Node in ipairs(self.GetAwardNodeList) do
		local AwardItem = self["Award" .. Index .. "00"]
		if AwardItem then
			AwardItem:UpdateRewardStatus(Node)
		end
	end
end

function OpsGirlsDayAwardPanelView:OnLootItemUpdateRes(InLootList, InReason)
	if not InLootList or not next(InLootList) then return end
	if not string.find(InReason, "Activity") then return end

	local ItemList = {}
	for i, v in ipairs(self.GetAwardNodeList) do
		if string.find(InReason, tostring(v.Head.NodeID)) then
			local LOOT_TYPE = ProtoCS.LOOT_TYPE
			for k, v in pairs(InLootList) do
				if v.Type == LOOT_TYPE.LOOT_TYPE_ITEM then
					table.insert(ItemList, {ResID = v.Item.ResID, Num = v.Item.Value})
				elseif v.Type == LOOT_TYPE.LOOT_TYPE_SCORE then
					table.insert(ItemList, {ResID = v.Score.ResID, Num = v.Score.Value})
				end
			end
			break
		end
	end

	if next(ItemList) then
		_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, {ItemList = ItemList})
	end
end

function OpsGirlsDayAwardPanelView:RefreshSnowRiceFruitNum(Param)
	if not Param then return end
	local Num = Param.Num
	self.Params.Num = Num
	self.TextQuantity:SetText(Num)
end

return OpsGirlsDayAwardPanelView