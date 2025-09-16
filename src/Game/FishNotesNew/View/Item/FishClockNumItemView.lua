---
--- Author: v_vvxinchen
--- DateTime: 2025-01-07 20:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class FishClockNumItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSet UFButton
---@field TextClockNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishClockNumItemView = LuaClass(UIView, true)

function FishClockNumItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSet = nil
	--self.TextClockNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishClockNumItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishClockNumItemView:OnInit()

end

function FishClockNumItemView:OnDestroy()

end

function FishClockNumItemView:OnShow()

end

function FishClockNumItemView:OnHide()

end

function FishClockNumItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSet, self.OnClickBtnSet)
end

function FishClockNumItemView:OnClickBtnSet()
	_G.UIViewMgr:ShowView(_G.UIViewID.FishNoteClockSetWinView)
end

function FishClockNumItemView:OnRegisterGameEvent()

end

function FishClockNumItemView:OnRegisterBinder()
	self:RegisterBinders(_G.FishIngholeVM, {{"TextClockNum", UIBinderSetText.New(self, self.TextClockNum)}})
end

return FishClockNumItemView