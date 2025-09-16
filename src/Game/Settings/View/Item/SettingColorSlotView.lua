---
--- Author: anypkvcai
--- DateTime: 2022-05-04 17:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ChatSettingColorSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImageColor UFImage
---@field ImageSelected UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatSettingColorSlotView = LuaClass(UIView, true)

function ChatSettingColorSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImageColor = nil
	--self.ImageSelected = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatSettingColorSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatSettingColorSlotView:OnInit()

end

function ChatSettingColorSlotView:OnDestroy()

end

function ChatSettingColorSlotView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Color = Params.Data
	if nil == Color then
		return
	end

	UIUtil.ImageSetColorAndOpacityHex(self.ImageColor, Color)
end

function ChatSettingColorSlotView:OnHide()

end

function ChatSettingColorSlotView:OnRegisterUIEvent()

end

function ChatSettingColorSlotView:OnRegisterGameEvent()

end

function ChatSettingColorSlotView:OnRegisterBinder()

end

function ChatSettingColorSlotView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImageSelected, IsSelected)
	--self.ToggleColor:SetChecked(IsSelected)
end

return ChatSettingColorSlotView