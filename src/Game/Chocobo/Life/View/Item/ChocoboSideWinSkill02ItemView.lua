---
--- Author: Administrator
--- DateTime: 2023-12-14 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ChocoboSkillVM = require("Game/Chocobo/Life/VM/ChocoboSkillVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ChocoboMainVM = nil

---@class ChocoboSideWinSkill02ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CarrySkill02 ChocoboCarrySkill02ItemView
---@field ImgArrow UFImage
---@field PanelArrow UFCanvasPanel
---@field AnimArrowLoop UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field ButtonIndex int64
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboSideWinSkill02ItemView = LuaClass(UIView, true)

function ChocoboSideWinSkill02ItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CarrySkill02 = nil
	--self.ImgArrow = nil
	--self.PanelArrow = nil
	--self.AnimArrowLoop = nil
	--self.AnimIn = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboSideWinSkill02ItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CarrySkill02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboSideWinSkill02ItemView:OnInit()
    ChocoboMainVM = _G.ChocoboMainVM
    -- self.ViewModel = ChocoboSkillVM.New()
    self.IsSelect = false
end

function ChocoboSideWinSkill02ItemView:OnDestroy()

end

function ChocoboSideWinSkill02ItemView:OnShow()

end

function ChocoboSideWinSkill02ItemView:OnHide()

end

function ChocoboSideWinSkill02ItemView:OnRegisterUIEvent()
end

function ChocoboSideWinSkill02ItemView:OnRegisterGameEvent()
end

function ChocoboSideWinSkill02ItemView:OnRegisterBinder()
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
        { "Icon", UIBinderSetBrushFromAssetPath.New(self, self.CarrySkill02.ImgSkillIcon) },
        { "IsAdd", UIBinderSetIsVisible.New(self, self.CarrySkill02.ImgAdd) },
        { "IsAdd", UIBinderSetIsVisible.New(self, self.CarrySkill02.ImgSkillIcon, true) },
        { "IsCheck", UIBinderSetIsVisible.New(self, self.CarrySkill02.ImgCheck) },
        { "IsSelect", UIBinderSetIsVisible.New(self, self.CarrySkill02.ImgSelect) },
        { "IsSelect", UIBinderSetIsVisible.New(self, self.ImgArrow) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

function ChocoboSideWinSkill02ItemView:OnSelectChanged(Value)
    self.IsSelect = Value
    if self.VM ~= nil then
        self.VM:SetSelect(Value)
    end

    if Value then
        self:PlayAnimation(self.AnimIn)
    else
        self:StopAllAnimations()
    end
end

function ChocoboSideWinSkill02ItemView:OnAnimationFinished(Anim)
    if Anim == self.AnimIn and self.IsSelect then
        self:PlayAnimation(self.AnimArrowLoop, 0, 0)
    end
end

return ChocoboSideWinSkill02ItemView