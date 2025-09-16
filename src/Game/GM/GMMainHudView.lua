---
--- Author: v_zanchang
--- DateTime: 2022-05-16 11:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")


---@class GMMainHudView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GMMain_UIBP GMMainView
---@field Overlay_37 UOverlay
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMMainHudView = LuaClass(UIView, true)
local GMMain = nil

function GMMainHudView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GMMain_UIBP = nil
	--self.Overlay_37 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMMainHudView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GMMain_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMMainHudView:OnInit()
	self.IsAttach = 0
	GMMain = self.GMMain_UIBP
end

function GMMainHudView:OnDestroy()

end

function GMMainHudView:OnShow()
	if not self.AttachOverlay:HasChild(GMMain) then
		self.AttachOverlay:AddChild(GMMain)
	end
	_G.UIViewMgr:HideView(_G.UIViewID.GMMainMinimizationHud)
	local IsOpen = _G.LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_GM)
	if IsOpen then
		UIUtil.SetIsVisible(self.AttachOverlay, true, true)
		UIUtil.SetIsVisible(GMMain, true, true)
	else
		UIUtil.SetIsVisible(self.AttachOverlay, false)
		UIUtil.SetIsVisible(GMMain, false)
	end
end

function GMMainHudView:OnHide()
	if not self.AttachOverlay:HasChild(GMMain) then
		self.AttachOverlay:AddChild(GMMain)
	end
	UIUtil.SetIsVisible(GMMain, false, false)
end

function GMMainHudView:OnRegisterUIEvent()

end

function GMMainHudView:OnRegisterGameEvent()

end

function GMMainHudView:OnRegisterBinder()

end

return GMMainHudView