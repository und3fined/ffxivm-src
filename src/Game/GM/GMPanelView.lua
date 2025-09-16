---
--- Author: Administrator
--- DateTime: 2024-12-12 14:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoginMgr = require("Game/Login/LoginMgr")
local ProtoRes = require("Protocol/ProtoRes")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

---@class GMPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonGM UFButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMPanelView = LuaClass(UIView, true)

function GMPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonGM = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMPanelView:OnInit()

end

function GMPanelView:OnDestroy()

end

function GMPanelView:OnShow()
	self.FTextBlock_67:SetText(_G.LSTR(1440001))
	local IsOpen = LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_GM)
	if IsOpen then
		UIUtil.SetIsVisible(self.ButtonGM, true, true)
	else
		UIUtil.SetIsVisible(self.ButtonGM, false)
	end
end

function GMPanelView:OnButtonGM()
	if UIViewMgr:IsViewVisible(UIViewID.GMMain) then
		UIViewMgr:HideView(UIViewID.GMMain)
	else
		UIViewMgr:ShowView(UIViewID.GMMain)
	end
end

function GMPanelView:OnHide()

end

function GMPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonGM, self.OnButtonGM)
end

function GMPanelView:OnRegisterGameEvent()

end

function GMPanelView:OnRegisterBinder()

end

return GMPanelView