---
--- Author: Administrator
--- DateTime: 2024-07-31 09:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PWorldEntranceMagicCardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgIcon UFImage
---@field ImgLock UFImage
---@field ImgLock_1 UFImage
---@field PanelLock UFCanvasPanel
---@field PanelStatus UFCanvasPanel
---@field StatusImage UFImage
---@field StatusText UFTextBlock
---@field TextName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimMatchingIn UWidgetAnimation
---@field AnimMatchingLoop UWidgetAnimation
---@field AnimMatchingOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldEntranceMagicCardItemView = LuaClass(UIView, true)

function PWorldEntranceMagicCardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgIcon = nil
	--self.ImgLock = nil
	--self.ImgLock_1 = nil
	--self.PanelLock = nil
	--self.PanelStatus = nil
	--self.StatusImage = nil
	--self.StatusText = nil
	--self.TextName = nil
	--self.AnimIn = nil
	--self.AnimMatchingIn = nil
	--self.AnimMatchingLoop = nil
	--self.AnimMatchingOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldEntranceMagicCardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldEntranceMagicCardItemView:OnInit()
	self.Binders = {
        { "bShowStatus",    UIBinderSetIsVisible.New(self, self.PanelStatus) },
        { "IsUnlock",    	UIBinderSetIsVisible.New(self, self.PanelLock, true, true) },
        { "StatusText",     UIBinderSetText.New(self, self.StatusText)},
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
end

function PWorldEntranceMagicCardItemView:OnDestroy()

end

function PWorldEntranceMagicCardItemView:OnShow()
	self.TextName:SetText(_G.LSTR(1150026))--("幻卡对局室")
end

function PWorldEntranceMagicCardItemView:OnHide()

end

function PWorldEntranceMagicCardItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnClickButtonItem)
end

function PWorldEntranceMagicCardItemView:OnRegisterGameEvent()
end

function PWorldEntranceMagicCardItemView:OnRegisterBinder()
    self.VM = _G.PWorldEntVM:GetPworldEntMagicCardTypeVM()
	if self.VM == nil then
		return
	end
    self:RegisterBinders(self.VM, self.Binders)
end

function PWorldEntranceMagicCardItemView:OnClickButtonItem()
    if self.VM and self.VM.IsUnlock then
		_G.UIViewMgr:ShowView(_G.UIViewID.PWorldCardsMatchPanel)
	else
		_G.MsgTipsUtil.ShowTipsByID(146083) --"完成10级支线任务【决斗！九宫幻卡】解锁"
    end
end

return PWorldEntranceMagicCardItemView