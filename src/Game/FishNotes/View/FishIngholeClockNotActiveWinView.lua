---
--- Author: Administrator
--- DateTime: 2023-03-29 11:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")

local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")

---@class FishIngholeClockNotActiveWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnActivation Comm2BtnLView
---@field RichTextBox_Desc URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeClockNotActiveWinView = LuaClass(UIView, true)

function FishIngholeClockNotActiveWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnActivation = nil
	--self.RichTextBox_Desc = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeClockNotActiveWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnActivation)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeClockNotActiveWinView:OnInit()
	self.Binders = {
		{ "FishingholeClockActiveTips", UIBinderSetText.New(self, self.RichTextBox_Desc) },
	}
end

function FishIngholeClockNotActiveWinView:OnDestroy()

end

function FishIngholeClockNotActiveWinView:OnShow()

end

function FishIngholeClockNotActiveWinView:OnHide()

end

function FishIngholeClockNotActiveWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnActivation, self.OnClickButtonActivation)
end

function FishIngholeClockNotActiveWinView:OnRegisterGameEvent()

end

function FishIngholeClockNotActiveWinView:OnRegisterBinder()
	self:RegisterBinders(FishIngholeVM, self.Binders)
end

function FishIngholeClockNotActiveWinView:OnClickButtonActivation()
	FishIngholeVM:OnActiveClick()
end

return FishIngholeClockNotActiveWinView