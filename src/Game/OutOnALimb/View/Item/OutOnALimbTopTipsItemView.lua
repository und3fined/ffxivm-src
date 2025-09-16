---
--- Author: Administrator
--- DateTime: 2023-11-09 16:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR

---@class OutOnALimbTopTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FVerticalTips UFVerticalBox
---@field LevelPanel UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field RichTextContent URichTextBox
---@field TextDifficulty UFTextBlock
---@field TextMedium UFTextBlock
---@field TextSimple UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OutOnALimbTopTipsItemView = LuaClass(UIView, true)

function OutOnALimbTopTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FVerticalTips = nil
	--self.LevelPanel = nil
	--self.PopUpBG = nil
	--self.RichTextContent = nil
	--self.TextDifficulty = nil
	--self.TextMedium = nil
	--self.TextSimple = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OutOnALimbTopTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OutOnALimbTopTipsItemView:InitConstStringInfo()
	self.TextSimple:SetText(LSTR(370015))
	self.TextMedium:SetText(LSTR(370016))
	self.TextDifficulty:SetText(LSTR(370017))
end

function OutOnALimbTopTipsItemView:OnInit()
	self.Binders = {
		{"TopTipsText", UIBinderSetText.New(self, self.RichTextContent)},
		{"bShowDifficultyMark", UIBinderSetIsVisible.New(self, self.LevelPanel)},
		{"TopTipsTitle", UIBinderSetText.New(self, self.TextTitle)},
	}
	self:InitConstStringInfo()
end

function OutOnALimbTopTipsItemView:OnDestroy()

end

function OutOnALimbTopTipsItemView:OnShow()
	self.PopUpBG:SetHideOnClick(false)
	self.PopUpBG:SetCallback(self, function(View)
		FLOG_INFO("OutOnALimbTopTipsItemView: PopUpBG CallBack is Called")
		UIUtil.SetIsVisible(View, false)
	end)
end

function OutOnALimbTopTipsItemView:OnHide()

end

function OutOnALimbTopTipsItemView:OnRegisterUIEvent()

end

function OutOnALimbTopTipsItemView:OnRegisterGameEvent()

end

function OutOnALimbTopTipsItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
    self:RegisterBinders(ViewModel, self.Binders)
end

return OutOnALimbTopTipsItemView