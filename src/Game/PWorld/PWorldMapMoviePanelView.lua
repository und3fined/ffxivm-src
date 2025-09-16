---
--- Author: frankjfwang
--- DateTime: 2021-01-26 19:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR

---@class PWorldMapMoviePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BlackScreen UImage
---@field SkipPromptText UTextBlock
---@field TouchButton UButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldMapMoviePanelView = LuaClass(UIView, true)

function PWorldMapMoviePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.BlackScreen = nil
	self.SkipPromptText = nil
	self.TouchButton = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldMapMoviePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldMapMoviePanelView:OnInit()

end

function PWorldMapMoviePanelView:OnDestroy()

end

function PWorldMapMoviePanelView:OnShow()
	self.BlackScreen:SetVisibility(_G.UE.ESlateVisibility.Visible)
	self.SkipPromptText:SetVisibility(_G.UE.ESlateVisibility.Hidden)
	self.IsConfirmedToSkip = false
	self.CanBeSkipped = self.Params.CanBeSkipped
	UIUtil.AddOnClickedEvent(self, self.TouchButton, self.OnSkippedButtonClicked)
end

function PWorldMapMoviePanelView:OnSkippedButtonClicked()
	FLOG_INFO("skip button clicked!")
	self.SkipPromptText:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
	if not self.CanBeSkipped then
		self.SkipPromptText:SetText(LSTR("动画无法跳过"))
	else
		if not self.IsConfirmedToSkip then
			self.SkipPromptText:SetText(LSTR("再次点击屏幕跳过"))
			self.IsConfirmedToSkip = true
		else
			local MapMovieMgr = _G.UE.USubsystemBlueprintLibrary.GetWorldSubsystem(
				MajorUtil.GetMajor(), _G.UE.UMapMovieMgr)
			MapMovieMgr:StopMovie()
			return
		end
	end

	self:RegisterTimer(self.OnResetSkipPromtTextTimer, 3.0, 0, 1)
end

function PWorldMapMoviePanelView:OnHide()
	--UIViewMgr:ShowAll()
	self.BlackScreen:SetVisibility(_G.UE.ESlateVisibility.Visible)
end

function PWorldMapMoviePanelView:OnRegisterUIEvent()

end

function PWorldMapMoviePanelView:OnRegisterGameEvent()

end

function PWorldMapMoviePanelView:OnRegisterTimer()
	self:RegisterTimer(self.OnHideBlackScreenTimer, 0.2, 0, 0)
end

function PWorldMapMoviePanelView:OnRegisterBinder()

end

function PWorldMapMoviePanelView:OnHideBlackScreenTimer()
	self.BlackScreen:SetVisibility(_G.UE.ESlateVisibility.Hidden)
end
function PWorldMapMoviePanelView:OnResetSkipPromtTextTimer()
	FLOG_INFO("OnResetSkipPromtTextTimer")
	self.SkipPromptText:SetVisibility(_G.UE.ESlateVisibility.Hidden)
	self.IsConfirmedToSkip = false
end

return PWorldMapMoviePanelView