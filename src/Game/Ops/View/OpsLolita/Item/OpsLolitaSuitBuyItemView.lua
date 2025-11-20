---
--- Author: v_vvxinchen
--- DateTime: 2025-07-28 14:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local OPS_JUMP_TYPE = ProtoRes.Game.OPS_JUMP_TYPE

---@class OpsLolitaSuitBuyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field BtnCheck UFButton
---@field IconMoney UFImage
---@field IconTeachingMaterials UFImage
---@field IconTeleport UFImage
---@field ImgReceive UFImage
---@field ImgSelect UFImage
---@field ImgSlot UFImage
---@field PanelMoney UFHorizontalBox
---@field PanelOriginalPrice UFCanvasPanel
---@field PanelPurchased UFCanvasPanel
---@field PanelTeleport UFCanvasPanel
---@field TextName UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextPrice UFTextBlock
---@field TextReceive UFTextBlock
---@field Img SlateBrush
---@field Teleport bool
---@field ItemType int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLolitaSuitBuyItemView = LuaClass(UIView, true)

function OpsLolitaSuitBuyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.BtnCheck = nil
	--self.IconMoney = nil
	--self.IconTeachingMaterials = nil
	--self.IconTeleport = nil
	--self.ImgReceive = nil
	--self.ImgSelect = nil
	--self.ImgSlot = nil
	--self.PanelMoney = nil
	--self.PanelOriginalPrice = nil
	--self.PanelPurchased = nil
	--self.PanelTeleport = nil
	--self.TextName = nil
	--self.TextOriginalPrice = nil
	--self.TextPrice = nil
	--self.TextReceive = nil
	--self.Img = nil
	--self.Teleport = nil
	--self.ItemType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLolitaSuitBuyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsLolitaSuitBuyItemView:OnInit()

end

function OpsLolitaSuitBuyItemView:OnDestroy()

end

function OpsLolitaSuitBuyItemView:OnShow()
	--IsBuy
	local SuitDataList = self.Params.SuitDataList
	self:SetBuyState(SuitDataList)

	local SuitData = SuitDataList[self.ItemType]
	if SuitData == nil then
		return
	end

	--Name
	self.TextName:SetText(SuitData.GoodsName)
	--Icon
	--local IconPath = UIUtil.GetIconPath(IconID)
	--UIUtil.ImageSetBrushFromAssetPath(self.ImgSlot, IconPath)

	--Price
	self.TextPrice:SetText(SuitData.BuyGoodPrice)
	self.TextOriginalPrice:SetText(SuitData.OriginalPrice)
	UIUtil.SetIsVisible(self.PanelOriginalPrice, SuitData.Discount ~= 100)
end

function OpsLolitaSuitBuyItemView:SetBuyState(SuitDataList)
	local SuitData = SuitDataList[self.ItemType]
	if SuitData == nil then
		return
	end
	self.SuitData = SuitData
	UIUtil.SetIsVisible(self.ImgReceive, SuitData.IsBuy)
end

function OpsLolitaSuitBuyItemView:OnHide()

end

function OpsLolitaSuitBuyItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnClickBtnCheck)
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickButtonItem)
end

function OpsLolitaSuitBuyItemView:OnClickBtnCheck()
	if self.SuitData == nil then
		return
	end
	local JumpID = self.SuitData.JumpID
	if JumpID ~= "" then
		_G.OpsActivityMgr:Jump(OPS_JUMP_TYPE.TABLE_JUMP, JumpID)
	else
		--不可预览时，弹出详情
		local ResID = self.SuitData.GoodsItemID
		if ResID and ResID > 0 then
			ItemTipsUtil.ShowTipsByResID(ResID, self.BtnCheck, {X = 0,Y = 0}, nil)
		end
	end
end

function OpsLolitaSuitBuyItemView:OnClickButtonItem()
	local Selected = self.bSelected
	self:OnSelectChanged(not Selected, true)
end

function OpsLolitaSuitBuyItemView:OnSelectChanged(bSelected, bClick)
	self.bSelected = bSelected
	UIUtil.SetIsVisible(self.ImgSelect, bSelected)
	local View = self.Params.View
	View:OnTableViewSelectChanged(bClick)
end

function OpsLolitaSuitBuyItemView:OnRegisterGameEvent()

end

function OpsLolitaSuitBuyItemView:OnRegisterBinder()

end
return OpsLolitaSuitBuyItemView