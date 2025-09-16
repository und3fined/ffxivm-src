---
--- Author: haialexzhou
--- DateTime: 2021-05-11 15:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class DeathFloatButtonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFloat UButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DeathFloatButtonView = LuaClass(UIView, true)

function DeathFloatButtonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFloat = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DeathFloatButtonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DeathFloatButtonView:OnInit()

end

function DeathFloatButtonView:OnDestroy()

end

function DeathFloatButtonView:OnShow()

end

function DeathFloatButtonView:OnHide()

end

function DeathFloatButtonView:OnRegisterUIEvent()
	_G.UIUtil.AddOnClickedEvent(self, self.BtnFloat, self.OnClickFloat)
end

function DeathFloatButtonView:OnRegisterGameEvent()

end

function DeathFloatButtonView:OnRegisterTimer()

end

function DeathFloatButtonView:OnRegisterBinder()

end

function DeathFloatButtonView:OnClickFloat()
	--_G.UIViewMgr:ShowView(_G.UIViewID.BeDeathView)
	_G.ReviveMgr:ShowReviveMsgBox() -- 2023-10-20 michaelyang ，策划和美术一起确认，使用通用弹窗提示
	self:Hide()
end

return DeathFloatButtonView