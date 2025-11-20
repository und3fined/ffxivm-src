---
--- Author: v_vvxinchen
--- DateTime: 2025-07-16 14:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class OpsSkiTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field Comm74Slot CommBackpack74SlotView
---@field TextName UFTextBlock
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsSkiTipsItemView = LuaClass(UIView, true)

function OpsSkiTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.Comm74Slot = nil
	--self.TextName = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsSkiTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm74Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsSkiTipsItemView:OnInit()
	
end

function OpsSkiTipsItemView:OnDestroy()

end

function OpsSkiTipsItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Item = Params.Data
	if nil == Item then
		return
	end

	self:SetGetSuitContentShow(Item)
end

function OpsSkiTipsItemView:SetGetSuitContentShow(Item)
	local ItemID = Item.ItemID
	self.ItemID = ItemID
	local Cfg = ItemCfg:FindCfgByKey(ItemID)
	local IconPath = UIUtil.GetIconPath(Cfg.IconID)
	UIUtil.ImageSetBrushFromAssetPath(self.Comm74Slot.Icon, IconPath)
	local ItemQualityIcon = ItemUtil.GetSlotColorIcon(ItemID, ItemDefine.ItemSlotType.Item74Slot)
	UIUtil.ImageSetBrushFromAssetPath(self.Comm74Slot.ImgQuanlity, ItemQualityIcon)
	self.TextName:SetText(Cfg.ItemName)
	self.TextQuantity:SetText("x "..Item.Num)

	UIUtil.SetIsVisible(self.Comm74Slot.IconChoose, false)
	UIUtil.SetIsVisible(self.Comm74Slot.RichTextQuantity, false)
	UIUtil.SetIsVisible(self.Comm74Slot.RichTextLevel, false)
end

function OpsSkiTipsItemView:OnHide()

end

function OpsSkiTipsItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickedGoBtn)
end

function OpsSkiTipsItemView:OnClickedGoBtn()
	_G.UIViewMgr:HideView(_G.UIViewID.ItemTips)
	ItemTipsUtil.ShowTipsByResID(self.ItemID, self, _G.UE.FVector2D(15 ,0))
end

function OpsSkiTipsItemView:OnRegisterGameEvent()

end

function OpsSkiTipsItemView:OnRegisterBinder()

end

return OpsSkiTipsItemView