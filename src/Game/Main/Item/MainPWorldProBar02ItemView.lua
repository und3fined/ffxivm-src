---
--- Author: kofhuang
--- DateTime: 2024-12-11 17:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SpecialUislotCfg = require("TableCfg/SpecialUislotCfg")
local EventID = require("Define/EventID")

---@class MainPWorldProBar02ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field ImgFrame UFImage
---@field PanelName UFCanvasPanel
---@field ProBarFull UProgressBar
---@field ProBarPanel UFCanvasPanel
---@field ProBarSchedule UProgressBar
---@field ProBarSchedule02 UProgressBar
---@field TextPercent UFTextBlock
---@field TextTargetName UFTextBlock
---@field AnimFull UWidgetAnimation
---@field AnimHideAll UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLevelChange UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProgress UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainPWorldProBar02ItemView = LuaClass(UIView, true)

function MainPWorldProBar02ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgFrame = nil
	--self.PanelName = nil
	--self.ProBarFull = nil
	--self.ProBarPanel = nil
	--self.ProBarSchedule = nil
	--self.ProBarSchedule02 = nil
	--self.TextPercent = nil
	--self.TextTargetName = nil
	--self.AnimFull = nil
	--self.AnimHideAll = nil
	--self.AnimIn = nil
	--self.AnimLevelChange = nil
	--self.AnimOut = nil
	--self.AnimProgress = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainPWorldProBar02ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainPWorldProBar02ItemView:OnInit()

end

function MainPWorldProBar02ItemView:OnDestroy()

end

function MainPWorldProBar02ItemView:OnShow()

end

function MainPWorldProBar02ItemView:OnHide()

end

function MainPWorldProBar02ItemView:OnRegisterUIEvent()

end

function MainPWorldProBar02ItemView:OnRegisterGameEvent()

end

function MainPWorldProBar02ItemView:OnRegisterBinder()

end


function MainPWorldProBar02ItemView:PlayAnimOut()
    self:PlayAnimation(self.AnimHideAll)
end

function MainPWorldProBar02ItemView:PlayAnimIn()
    self:PlayAnimation(self.AnimIn)
end

function MainPWorldProBar02ItemView:HideAll()
    self:RegisterTimer(self.PWorldProgressSlotUnVisibility, 0.5, 0, 1)
    self:PlayAnimation(self.AnimOut)
end

function MainPWorldProBar02ItemView:Hide()
    self:PWorldProgressSlotUnVisibility()
end

function MainPWorldProBar02ItemView:PWorldProgressSlotUnVisibility()
    _G.EventMgr:SendEvent(_G.EventID.PWorldProgressSlotHide, {})
end

function MainPWorldProBar02ItemView:SetContent(ID,Order,CurValue,MaxValue)
    local Cfg = SpecialUislotCfg:FindCfgByID(ID)

    if Cfg == nil then
        return
    end

    self.TextTargetName:SetText(Cfg.UIName)
    self.TextPercent:SetText(tostring(CurValue))

    local Progress = CurValue / MaxValue

    if CurValue == MaxValue then
		UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextTargetName, "bb1a37b2")
		UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextPercent, "bb1a37b2")
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextTargetName, "ffb9b9ff")
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextPercent, "ffb9b9ff")
        self.ProBarFull:SetPercent(1.0)
        self.ProBarFull:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
        self:PlayAnimation(self.AnimFull)
        self.ProBarSchedule:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
    else
		self:PlayAnimation(self.AnimProgress, Progress, 1, nil, 0)
		if Progress <= 0.59 then
			UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextTargetName, "187eb9b2")
			UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextPercent, "187eb9b2")
			UIUtil.TextBlockSetColorAndOpacityHex(self.TextTargetName, "ffffffff")
			UIUtil.TextBlockSetColorAndOpacityHex(self.TextPercent, "ffffffff")
			self.ProBarFull:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
			self.ProBarSchedule:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
			self.ProBarSchedule02:SetPercent(Progress)
			self.ProBarSchedule02:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
		elseif Progress <= 0.79 then
			if Progress == 0.6 then
				self:PlayAnimation(self.AnimLevelChange)
			end
			UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextTargetName, "da9a0080")
			UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextPercent, "da9a0080")
			UIUtil.TextBlockSetColorAndOpacityHex(self.TextTargetName, "ffffffff")
			UIUtil.TextBlockSetColorAndOpacityHex(self.TextPercent, "ffffffff")
			self.ProBarFull:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
			self.ProBarSchedule02:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
			self.ProBarSchedule:SetPercent(Progress)
			self.ProBarSchedule:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
		else
			if Progress == 0.8 then
				self:PlayAnimation(self.AnimLevelChange)
			end
			UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextTargetName, "bb1a37b2")
			UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextPercent, "bb1a37b2")
			UIUtil.TextBlockSetColorAndOpacityHex(self.TextTargetName, "ffb9b9ff")
			UIUtil.TextBlockSetColorAndOpacityHex(self.TextPercent, "ffb9b9ff")
			self.ProBarSchedule:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
			self.ProBarSchedule02:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
			self.ProBarFull:SetPercent(Progress)
			self.ProBarFull:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
		end
    end
end

return MainPWorldProBar02ItemView