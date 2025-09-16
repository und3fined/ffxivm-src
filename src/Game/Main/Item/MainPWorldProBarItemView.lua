---
--- Author: sammrli
--- DateTime: 2023-12-28 15:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SpecialUislotCfg = require("TableCfg/SpecialUislotCfg")
local EventID = require("Define/EventID")

---@class MainPWorldProBarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FHorizontal UFHorizontalBox
---@field ImgBg UFImage
---@field ImgFrame UFImage
---@field ProBarFull UProgressBar
---@field ProBarPanel UFCanvasPanel
---@field ProBarSchedule UProgressBar
---@field TextPercent UFTextBlock
---@field TextTargetName UFTextBlock
---@field AnimFull UWidgetAnimation
---@field AnimHideAll UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProgress UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainPWorldProBarItemView = LuaClass(UIView, true)

function MainPWorldProBarItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FHorizontal = nil
	--self.ImgBg = nil
	--self.ImgFrame = nil
	--self.ProBarFull = nil
	--self.ProBarPanel = nil
	--self.ProBarSchedule = nil
	--self.TextPercent = nil
	--self.TextTargetName = nil
	--self.AnimFull = nil
	--self.AnimHideAll = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimProgress = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainPWorldProBarItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainPWorldProBarItemView:OnInit()

end

function MainPWorldProBarItemView:OnDestroy()

end

function MainPWorldProBarItemView:OnShow()

end

function MainPWorldProBarItemView:OnHide()

end

function MainPWorldProBarItemView:OnRegisterUIEvent()

end

function MainPWorldProBarItemView:OnRegisterGameEvent()

end

function MainPWorldProBarItemView:OnRegisterBinder()

end

function MainPWorldProBarItemView:PlayAnimOut()
    self:PlayAnimation(self.AnimHideAll)
end

function MainPWorldProBarItemView:PlayAnimIn()
    self:PlayAnimation(self.AnimIn)
end

function MainPWorldProBarItemView:HideAll()
    self:RegisterTimer(self.PWorldProgressSlotUnVisibility, 0.5, 0, 1)
    self:PlayAnimation(self.AnimOut)
end

function MainPWorldProBarItemView:Hide()
    self:PWorldProgressSlotUnVisibility()
end

function MainPWorldProBarItemView:PWorldProgressSlotUnVisibility()
    _G.EventMgr:SendEvent(_G.EventID.PWorldProgressSlotHide, {})
end

function MainPWorldProBarItemView:SetContent(ID,Order,CurValue,MaxValue)
    local Cfg = SpecialUislotCfg:FindCfgByID(ID)

    if Cfg == nil then
        return
    end

    self.TextTargetName:SetText(Cfg.UIName)
    self.TextPercent:SetText(tostring(CurValue))

    local Progress = CurValue / MaxValue

    if CurValue == MaxValue then
        self.ProBarFull:SetPercent(1.0)
        self.ProBarFull:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
        self:PlayAnimation(self.AnimFull)
        self.ProBarSchedule:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
    else
        self.ProBarSchedule:SetPercent(Progress)
        self.ProBarSchedule:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
        self.ProBarFull:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
    end
end

return MainPWorldProBarItemView