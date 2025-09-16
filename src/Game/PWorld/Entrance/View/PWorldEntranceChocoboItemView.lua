---
--- Author: Administrator
--- DateTime: 2024-07-31 09:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIUtil = require("Utils/UIUtil")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

---@class PWorldEntranceChocoboItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgIcon UFImage
---@field ImgLock UFImage
---@field ImgLock_1 UFImage
---@field PanelLock UFCanvasPanel
---@field PanelStatus UFCanvasPanel
---@field StatusImage UFImage
---@field StatusText UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimMatchingIn UWidgetAnimation
---@field AnimMatchingLoop UWidgetAnimation
---@field AnimMatchingOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldEntranceChocoboItemView = LuaClass(UIView, true)

function PWorldEntranceChocoboItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgIcon = nil
	--self.ImgLock = nil
	--self.ImgLock_1 = nil
	--self.PanelLock = nil
	--self.PanelStatus = nil
	--self.StatusImage = nil
	--self.StatusText = nil
	--self.AnimIn = nil
	--self.AnimMatchingIn = nil
	--self.AnimMatchingLoop = nil
	--self.AnimMatchingOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldEntranceChocoboItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldEntranceChocoboItemView:OnInit()

end

function PWorldEntranceChocoboItemView:OnDestroy()

end

function PWorldEntranceChocoboItemView:OnShow()
    self.TextName:SetText(_G.LSTR(430009))--("陆行鸟竞赛")
end

function PWorldEntranceChocoboItemView:OnHide()

end

function PWorldEntranceChocoboItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnClickButtonItem)
end

function PWorldEntranceChocoboItemView:OnRegisterGameEvent()
end

function PWorldEntranceChocoboItemView:OnRegisterBinder()
    self.VM = _G.PWorldEntVM:GetPworldEntChocoboTypeVM()
    self.Binders = {
        { "bShowStatus",    UIBinderSetIsVisible.New(self, self.PanelStatus) },
        { "IsUnlock",    	UIBinderSetIsVisible.New(self, self.PanelLock, true, true) },
        { "StatusText",     UIBinderSetText.New(self, self.StatusText)},
        { "IsOpen",         UIBinderSetIsVisible.New(self, self.StatusImage) },
        { "StatusImage",    UIBinderSetBrushFromAssetPath.New(self, self.StatusImage)},
        { "IsMatching",     UIBinderValueChangedCallback.New(self, nil, function (_, NewValue, OldValue)
            if NewValue then
                self:PlayAnimation(self.AnimMatchingIn)
                self:PlayAnimation(self.AnimMatchingLoop, 0, 0)
            else
                self:PlayAnimation(self.AnimMatchingOut)
                if self:IsAnimationPlaying(self.AnimMatchingLoop) then
                    self:StopAnimation(self.AnimMatchingLoop)
                end
            end
        end)},
    }
    
    self:RegisterBinders(self.VM, self.Binders)
end

function PWorldEntranceChocoboItemView:OnClickButtonItem()
    if self.VM and not self.VM.IsUnlock then
        _G.MsgTipsUtil.ShowTipsByID(146084)
        return
    end

    PWorldEntUtil.ShowPWorldEntView(ProtoCommon.ScenePoolType.ScenePoolChocobo)
end

return PWorldEntranceChocoboItemView