---
--- Author: sammrli
--- DateTime: 2024-07-31 22:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ChocoboTransportEnterBirdRoomItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AnimInGold UWidgetAnimation
---@field AnimInWhite UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
---@field PlayAnimInGold function
---@field PlayAnimInWhite function
local ChocoboTransportEnterBirdRoomItemView = LuaClass(UIView, true)

function ChocoboTransportEnterBirdRoomItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AnimInGold = nil
	--self.AnimInWhite = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboTransportEnterBirdRoomItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboTransportEnterBirdRoomItemView:OnInit()

end

function ChocoboTransportEnterBirdRoomItemView:OnDestroy()

end

function ChocoboTransportEnterBirdRoomItemView:OnShow()

end

function ChocoboTransportEnterBirdRoomItemView:OnHide()

end

function ChocoboTransportEnterBirdRoomItemView:OnRegisterUIEvent()

end

function ChocoboTransportEnterBirdRoomItemView:OnRegisterGameEvent()

end

function ChocoboTransportEnterBirdRoomItemView:OnRegisterBinder()

end

function ChocoboTransportEnterBirdRoomItemView:PlayAnimInGold()
	self:PlayAnimation(self.AnimInGold)
end

function ChocoboTransportEnterBirdRoomItemView:PlayAnimInWhite()
	self:PlayAnimation(self.AnimInWhite)
end

return ChocoboTransportEnterBirdRoomItemView