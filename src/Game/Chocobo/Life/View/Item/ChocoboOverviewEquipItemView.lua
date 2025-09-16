---
--- Author: Administrator
--- DateTime: 2023-12-14 15:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class ChocoboOverviewEquipItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgEquip UFImage
---@field NewSlot CommBackpack96SlotView
---@field PanelEquip UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboOverviewEquipItemView = LuaClass(UIView, true)

function ChocoboOverviewEquipItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgEquip = nil
	--self.NewSlot = nil
	--self.PanelEquip = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboOverviewEquipItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.NewSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboOverviewEquipItemView:OnInit()

end

function ChocoboOverviewEquipItemView:OnDestroy()

end

function ChocoboOverviewEquipItemView:OnShow()
    UIUtil.SetIsVisible(self.NewSlot.RichTextLevel, false)
    UIUtil.SetIsVisible(self.NewSlot.RichTextQuantity, false)
    UIUtil.SetIsVisible(self.NewSlot.IconChoose, false)
end

function ChocoboOverviewEquipItemView:OnHide()

end

function ChocoboOverviewEquipItemView:OnRegisterUIEvent()

end

function ChocoboOverviewEquipItemView:OnRegisterGameEvent()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Data = Params.Data
    if nil == Data then
        return
    end

    local ViewModel = Data
    self.VM = ViewModel
    
    local Binders = {
        { "BGPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgEquip) },
        { "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.NewSlot.Icon) },
        { "IsShowSlot", UIBinderSetIsVisible.New(self, self.NewSlot) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

function ChocoboOverviewEquipItemView:OnRegisterBinder()

end

return ChocoboOverviewEquipItemView