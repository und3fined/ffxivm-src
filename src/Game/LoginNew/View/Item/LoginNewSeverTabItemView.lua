---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class LoginNewSeverTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIconCheck UFImage
---@field ImgIconUncheck UFImage
---@field ToggleBtnPreview UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewSeverTabItemView = LuaClass(UIView, true)

function LoginNewSeverTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIconCheck = nil
	--self.ImgIconUncheck = nil
	--self.ToggleBtnPreview = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewSeverTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewSeverTabItemView:OnInit()
    self.Binders = {
        { "CheckIconPath", UIBinderSetImageBrush.New(self, self.ImgIconCheck) },
        { "UnCheckIconPath", UIBinderSetImageBrush.New(self, self.ImgIconUncheck) },
    }
end

function LoginNewSeverTabItemView:OnDestroy()

end

function LoginNewSeverTabItemView:OnShow()
    print("[LoginNewSeverTabItemView:OnShow] ", self.ViewModel.Desc)
    self.ToggleBtnPreview:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
end

function LoginNewSeverTabItemView:OnHide()

end

function LoginNewSeverTabItemView:OnRegisterUIEvent()

end

function LoginNewSeverTabItemView:OnRegisterGameEvent()

end

function LoginNewSeverTabItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    ---@type LoginMapleTabItemVM
    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    self.ViewModel = ViewModel
    self:RegisterBinders(ViewModel, self.Binders)
end

function LoginNewSeverTabItemView:OnSelectChanged(IsSelected)
    self:StopAllAnimations()
    --self.ToggleBtnPreview:SetChecked(IsSelected)
    if IsSelected then
        print("[LoginNewSeverTabItemView:OnSelectChanged] Checked ", self.ViewModel.Desc, IsSelected)
        self:PlayAnimation(self.AnimChecked)
        self.ToggleBtnPreview:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
    else
        local CheckState = self.ToggleBtnPreview:GetCheckedState()
        print("[LoginNewSeverTabItemView:OnSelectChanged] Unchecked ", self.ViewModel.Desc, IsSelected, CheckState)
        if CheckState == _G.UE.EToggleButtonState.Checked then
            self:PlayAnimation(self.AnimUnchecked)
            self.ToggleBtnPreview:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
        end
    end
end

return LoginNewSeverTabItemView