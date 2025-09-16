---
--- Author: Administrator
--- DateTime: 2023-12-14 15:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIUtil = require("Utils/UIUtil")

---@class ChocoboSkillPanelItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgMask UFImage
---@field ImgSelect UFImage
---@field RedDot CommonRedDot2View
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboSkillPanelItemView = LuaClass(UIView, true)

function ChocoboSkillPanelItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgMask = nil
	--self.ImgSelect = nil
	--self.RedDot = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboSkillPanelItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboSkillPanelItemView:OnInit()

end

function ChocoboSkillPanelItemView:OnDestroy()

end

function ChocoboSkillPanelItemView:OnShow()
    UIUtil.SetIsVisible(self.RedDot, true)
    self.RedDot:SetIsCustomizeRedDot(true)
    self:UpdateRedDot()
end

function ChocoboSkillPanelItemView:OnHide()

end

function ChocoboSkillPanelItemView:OnRegisterUIEvent()

end

function ChocoboSkillPanelItemView:OnRegisterGameEvent()

end

function ChocoboSkillPanelItemView:OnRegisterBinder()
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

    if not self.Binders then
        self.Binders = {
            { "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
            { "IsLock", UIBinderSetIsVisible.New(self, self.ImgMask) },
            { "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
        }
    end
    self:RegisterBinders(ViewModel, self.Binders)
end

function ChocoboSkillPanelItemView:OnSelectChanged(Value)
    if self.VM ~= nil then
        self.VM:SetSelect(Value)
        if Value then
            self:DelRedDot()
        end
    end
end

function ChocoboSkillPanelItemView:UpdateRedDot()
    if self.VM == nil or self.VM.SkillID == nil then
        return
    end

    if self.VM.IsLock then
        if self.RedDot and self.RedDot.ItemVM then
            self.RedDot.ItemVM.IsVisible = false
        end
        return
    end
    
    local IsShow = true
    local RedDotList = _G.ChocoboMgr:GetCustomizeRedDotList()
    local RedDotName = "SkillList" .. self.VM.SkillID
    
    for __, ItemName in pairs(RedDotList) do
        if RedDotName == ItemName then
            IsShow = false
        end
    end

    if self.RedDot and self.RedDot.ItemVM then
        self.RedDot.ItemVM.IsVisible = IsShow
    end

    if self.VM.IsSelect then
        self:DelRedDot()
    end

    _G.ChocoboMgr:AddCustomizeRedDotName(RedDotName)
end

function ChocoboSkillPanelItemView:DelRedDot()
    if self.RedDot and self.RedDot.ItemVM then
        self.RedDot.ItemVM.IsVisible = false
    end
end

return ChocoboSkillPanelItemView