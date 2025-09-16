---
--- Author: yutingzhan
--- DateTime: 2024-11-06 17:05
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

---@class OpsActivityTreasureChest96SlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field Comm96Slot CommBackpack96SlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityTreasureChest96SlotItemView = LuaClass(UIView, true)

function OpsActivityTreasureChest96SlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.Comm96Slot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityTreasureChest96SlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityTreasureChest96SlotItemView:OnInit()
    UIUtil.SetIsVisible(self.Comm96Slot.IconChoose, false)
	UIUtil.SetIsVisible(self.Comm96Slot.RichTextLevel, false)
end

function OpsActivityTreasureChest96SlotItemView:OnDestroy()

end

function OpsActivityTreasureChest96SlotItemView:OnShow()

end

function OpsActivityTreasureChest96SlotItemView:OnHide()

end

function OpsActivityTreasureChest96SlotItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self,  self.BtnCheck, self.OnClickBtnCheck)
end

function OpsActivityTreasureChest96SlotItemView:OnClickBtnCheck()
    if self.Params == nil or self.Params.Data == nil then return end
    _G.PreviewMgr:OpenPreviewView(self.Params.Data.ItemID)
end

function OpsActivityTreasureChest96SlotItemView:OnRegisterGameEvent()

end

function OpsActivityTreasureChest96SlotItemView:OnRegisterBinder()
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
                UIBinderSetBrushFromAssetPath.New(self, self.Comm96Slot.ImgQuanlity)
            },
            {
                "Icon",
                UIBinderSetBrushFromAssetPath.New(self, self.Comm96Slot.Icon)
            },
            {
                "Num",
                UIBinderSetText.New(self, self.Comm96Slot.RichTextQuantity)
            },

			{
                "IconReceivedVisible",
                UIBinderSetIsVisible.New(self, self.Comm96Slot.IconReceived)
            },
            {
                "IconReceivedVisible",
                UIBinderSetIsVisible.New(self, self.Comm96Slot.ImgMask)
            },
			{
                "BtnCheck",
                UIBinderSetIsVisible.New(self, self.BtnCheck, false, true)
            },
        }
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

return OpsActivityTreasureChest96SlotItemView