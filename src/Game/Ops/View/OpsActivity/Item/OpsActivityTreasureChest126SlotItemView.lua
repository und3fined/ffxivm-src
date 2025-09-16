---
--- Author: yutingzhan
--- DateTime: 2024-11-15 09:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class OpsActivityTreasureChest126SlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field Comm126Slot CommBackpack126SlotView
---@field TextState UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityTreasureChest126SlotItemView = LuaClass(UIView, true)

function OpsActivityTreasureChest126SlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.Comm126Slot = nil
	--self.TextState = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityTreasureChest126SlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm126Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityTreasureChest126SlotItemView:OnInit()
    UIUtil.SetIsVisible(self.Comm126Slot.IconChoose, false)
	UIUtil.SetIsVisible(self.Comm126Slot.RichTextLevel, false)
end

function OpsActivityTreasureChest126SlotItemView:OnDestroy()

end

function OpsActivityTreasureChest126SlotItemView:OnShow()

end

function OpsActivityTreasureChest126SlotItemView:OnHide()

end

function OpsActivityTreasureChest126SlotItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self,  self.BtnCheck, self.OnClickBtnCheck)
end

function OpsActivityTreasureChest126SlotItemView:OnClickBtnCheck()
    if self.Params == nil or self.Params.Data == nil then return end
    _G.PreviewMgr:OpenPreviewView(self.Params.Data.ItemID)
end

function OpsActivityTreasureChest126SlotItemView:OnRegisterGameEvent()

end

function OpsActivityTreasureChest126SlotItemView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then return end

    local ViewModel = Params.Data
    if nil == ViewModel or nil == ViewModel.RegisterBinder then
        return
    end

    if (self.Binders == nil) then
        self.Binders = {
            {
                "ItemQualityIcon",
                UIBinderSetBrushFromAssetPath.New(self, self.Comm126Slot.ImgQuanlity)
            },
            {
                "Icon",
                UIBinderSetBrushFromAssetPath.New(self, self.Comm126Slot.Icon)
            },
            {
                "Num",
                UIBinderSetText.New(self, self.Comm126Slot.RichTextQuantity)
            },

			{
                "IconReceivedVisible",
                UIBinderSetIsVisible.New(self, self.Comm126Slot.IconReceived)
            },
            {
                "IconReceivedVisible",
                UIBinderSetIsVisible.New(self, self.Comm126Slot.ImgMask)
            },
			{
                "BtnCheck",
                UIBinderSetIsVisible.New(self, self.BtnCheck, false, true)
            },
            {
                "LotteryProbability",
                UIBinderSetText.New(self, self.TextState)
            },
            {
                "ProbabilityColor",
                UIBinderSetColorAndOpacityHex.New(self, self.TextState)
            },
        }
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

return OpsActivityTreasureChest126SlotItemView