---
--- Author: Administrator
--- DateTime: 2023-05-04 11:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class FishIngholeMsgItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field BtnPick UFButton
---@field BtnReport UFButton
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field TextPickValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeMsgItemView = LuaClass(UIView, true)

function FishIngholeMsgItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.BtnPick = nil
	--self.BtnReport = nil
	--self.PlayerHeadSlot = nil
	--self.TextPickValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeMsgItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeMsgItemView:OnInit()

end

function FishIngholeMsgItemView:OnDestroy()

end

function FishIngholeMsgItemView:OnShow()

end

function FishIngholeMsgItemView:OnHide()

end

function FishIngholeMsgItemView:OnRegisterUIEvent()

end

function FishIngholeMsgItemView:OnRegisterGameEvent()

end

function FishIngholeMsgItemView:OnRegisterBinder()

end

return FishIngholeMsgItemView