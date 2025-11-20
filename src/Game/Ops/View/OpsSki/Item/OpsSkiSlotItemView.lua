---
--- Author: v_vvxinchen
--- DateTime: 2025-06-30 09:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local LSTR = _G.LSTR

---@class OpsSkiSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field BtnSlot UFButton
---@field ImgColor UFImage
---@field ImgSlot UFImage
---@field PanelPurchased UFCanvasPanel
---@field PanelRound UFCanvasPanel
---@field TextColor UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsSkiSlotItemView = LuaClass(UIView, true)

function OpsSkiSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.BtnSlot = nil
	--self.ImgColor = nil
	--self.ImgSlot = nil
	--self.PanelPurchased = nil
	--self.PanelRound = nil
	--self.TextColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsSkiSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsSkiSlotItemView:OnInit()

end

function OpsSkiSlotItemView:OnDestroy()

end

function OpsSkiSlotItemView:OnShow()
	local SuitData = self.Params.SuitData
	self:SetBuyState(SuitData)
	UIUtil.ImageSetColorAndOpacityHex(self.ImgColor, SuitData.Color)
	self.TextColor:SetText(LSTR(SuitData.ColorUkey))

	local DefaultSuit = SuitData.Color == nil
	UIUtil.SetIsVisible(self.PanelRound, not DefaultSuit)

	local GoodsID = SuitData.GoodsID
	local GoodsData = _G.StoreMgr:GetProductDataByID(GoodsID)
	if table.is_nil_empty(GoodsData) then return end
	local GoodCfgData = GoodsData.Cfg
	local CfgItems = GoodCfgData.Items or {}
	local GoodsItemID = CfgItems[1].ID
	self.GoodsItemID = GoodsItemID
	local IconPath = UIUtil.GetIconPath(ItemUtil.GetItemIcon(GoodsItemID))
	UIUtil.ImageSetBrushFromAssetPath(self.ImgSlot, IconPath)
end

function OpsSkiSlotItemView:SetBuyState(SuitData)
	self.SuitData = SuitData
	UIUtil.SetIsVisible(self.PanelPurchased, SuitData.IsBuy)
end

function OpsSkiSlotItemView:OnHide()

end

function OpsSkiSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSlot, self.OnClickBtnCheck)
end

function OpsSkiSlotItemView:OnClickBtnCheck()
	local ProtoRes = require("Protocol/ProtoRes")
	local OPS_JUMP_TYPE = ProtoRes.Game.OPS_JUMP_TYPE
	_G.OpsActivityMgr:Jump(OPS_JUMP_TYPE.TABLE_JUMP, self.SuitData.JumpID)
end

function OpsSkiSlotItemView:OnRegisterGameEvent()

end

function OpsSkiSlotItemView:OnRegisterBinder()

end

return OpsSkiSlotItemView