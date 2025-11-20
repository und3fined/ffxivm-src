---
--- Author: yutingzhan
--- DateTime: 2025-08-27 14:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ItemDefine = require("Game/Item/ItemDefine")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
---@class OpsGirlsDayCandyPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field CloseBtn CommonCloseBtnView
---@field Comm126Slot1 CommBackpack126SlotView
---@field Comm126Slot2 CommBackpack126SlotView
---@field IconTitle UFImage
---@field OpsCommMoney OpsCommMoneySlotView
---@field RichTextHint URichTextBox
---@field RichTextInfo URichTextBox
---@field TextAward1 UFTextBlock
---@field TextAward2 UFTextBlock
---@field TextBtn UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsGirlsDayCandyPanelView = LuaClass(UIView, true)

function OpsGirlsDayCandyPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.CloseBtn = nil
	--self.Comm126Slot1 = nil
	--self.Comm126Slot2 = nil
	--self.IconTitle = nil
	--self.OpsCommMoney = nil
	--self.RichTextHint = nil
	--self.RichTextInfo = nil
	--self.TextAward1 = nil
	--self.TextAward2 = nil
	--self.TextBtn = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsGirlsDayCandyPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.Comm126Slot1)
	self:AddSubView(self.Comm126Slot2)
	self:AddSubView(self.OpsCommMoney)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsGirlsDayCandyPanelView:OnInit()

end

function OpsGirlsDayCandyPanelView:OnDestroy()

end

function OpsGirlsDayCandyPanelView:OnShow()
	if self.Params == nil then
		return
	end
	local NodeCfg = self.Params.NodeCfg
	self.TextTitle:SetText(NodeCfg.NodeTitle)
	self.RichTextInfo:SetText(NodeCfg.NodeDesc)
	self.TextBtn:SetText(LSTR(100170))
	self.RichTextHint:SetText(LSTR(100179))
	self:SetSlotItem(NodeCfg.Rewards[1], self.Comm126Slot1)
	self:SetSlotItem(NodeCfg.Rewards[2], self.Comm126Slot2)
end

function OpsGirlsDayCandyPanelView:OnHide()

end

function OpsGirlsDayCandyPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Comm126Slot1.BtnCheck, self.OnClickSlotItem1)
	UIUtil.AddOnClickedEvent(self, self.Comm126Slot2.BtnCheck, self.OnClickSlotItem2)
end

function OpsGirlsDayCandyPanelView:OnClickSlotItem1()
	local Reward = self.Params.NodeCfg.Rewards[1]
	_G.PreviewMgr:OpenPreviewView(Reward.ItemID)
end

function OpsGirlsDayCandyPanelView:OnClickSlotItem2()
	local Reward = self.Params.NodeCfg.Rewards[2]
	_G.PreviewMgr:OpenPreviewView(Reward.ItemID)
end


function OpsGirlsDayCandyPanelView:OnRegisterGameEvent()

end

function OpsGirlsDayCandyPanelView:OnRegisterBinder()

end

function OpsGirlsDayCandyPanelView:SetSlotItem(Reward, Slot)
	local ItemQualityIcon = ItemUtil.GetSlotColorIcon(Reward.ItemID, ItemDefine.ItemSlotType.Item126Slot)

	local Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(Reward.ItemID))
	local Num = _G.ScoreMgr.FormatScore(Reward.Num)
	local BtnCheckVisible = ItemUtil.IsCanPreviewByResID(Reward.ItemID)
	UIUtil.SetIsVisible(Slot.IconChoose, false)
	UIUtil.SetIsVisible(Slot.IconReceived, false)
	UIUtil.SetIsVisible(Slot.PanelAvailable, false)
	UIUtil.SetIsVisible(Slot.ImgMask, false)
	UIUtil.SetIsVisible(Slot.RichTextLevel, false)

	UIUtil.SetIsVisible(Slot.BtnCheck, BtnCheckVisible)

	Slot:SetIconImg(Icon)
	Slot:SetQualityImg(ItemQualityIcon)
	Slot:SetNum(Num)
end

return OpsGirlsDayCandyPanelView