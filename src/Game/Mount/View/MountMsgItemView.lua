---
--- Author: jamiyang
--- DateTime: 2023-03-16 14:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MountMsgItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field BtnPick UFButton
---@field BtnReport UFButton
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field TextPickValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountMsgItemView = LuaClass(UIView, true)

function MountMsgItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.BtnPick = nil
	--self.BtnReport = nil
	--self.PlayerHeadSlot = nil
	--self.TextPickValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountMsgItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountMsgItemView:OnInit()

end

function MountMsgItemView:OnDestroy()

end

function MountMsgItemView:OnShow()

end

function MountMsgItemView:OnHide()

end

function MountMsgItemView:OnRegisterUIEvent()

end

function MountMsgItemView:OnRegisterGameEvent()

end

function MountMsgItemView:OnRegisterBinder()

end

return MountMsgItemView