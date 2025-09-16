---
--- Author: moodliu
--- DateTime: 2023-11-24 15:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PerformanceNewRecordPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnContinuePlay CommBtnMView
---@field BtnHelp CommHelpBtnView
---@field BtnQuit CommBtnMView
---@field ImgScore UFImage
---@field PanelNewRecord UFCanvasPanel
---@field TableViewRewards UTableView
---@field TextEntry1 UFTextBlock
---@field TextEntry2 UFTextBlock
---@field TextEntry3 UFTextBlock
---@field TextEntry4 UFTextBlock
---@field TextEntry5 UFTextBlock
---@field TextEntryValue1 UFTextBlock
---@field TextEntryValue2 UFTextBlock
---@field TextEntryValue3 UFTextBlock
---@field TextEntryValue4 UFTextBlock
---@field TextEntryValue5 UFTextBlock
---@field TextGetAll UFTextBlock
---@field TextName UFTextBlock
---@field TextTopComboValue UFTextBlock
---@field TextTopScore UFTextBlock
---@field TextTotalScore UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceNewRecordPageView = LuaClass(UIView, true)

function PerformanceNewRecordPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnContinuePlay = nil
	--self.BtnHelp = nil
	--self.BtnQuit = nil
	--self.ImgScore = nil
	--self.PanelNewRecord = nil
	--self.TableViewRewards = nil
	--self.TextEntry1 = nil
	--self.TextEntry2 = nil
	--self.TextEntry3 = nil
	--self.TextEntry4 = nil
	--self.TextEntry5 = nil
	--self.TextEntryValue1 = nil
	--self.TextEntryValue2 = nil
	--self.TextEntryValue3 = nil
	--self.TextEntryValue4 = nil
	--self.TextEntryValue5 = nil
	--self.TextGetAll = nil
	--self.TextName = nil
	--self.TextTopComboValue = nil
	--self.TextTopScore = nil
	--self.TextTotalScore = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceNewRecordPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnContinuePlay)
	self:AddSubView(self.BtnHelp)
	self:AddSubView(self.BtnQuit)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceNewRecordPageView:OnInit()

end

function PerformanceNewRecordPageView:OnDestroy()

end

function PerformanceNewRecordPageView:OnShow()

end

function PerformanceNewRecordPageView:OnHide()

end

function PerformanceNewRecordPageView:OnRegisterUIEvent()

end

function PerformanceNewRecordPageView:OnRegisterGameEvent()

end

function PerformanceNewRecordPageView:OnRegisterBinder()

end

return PerformanceNewRecordPageView