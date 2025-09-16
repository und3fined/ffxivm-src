---
--- Author: saintzhao
--- DateTime: 2024-11-12 16:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class PandoraMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Common_PopUpBG_UIBP CommonPopUpBGView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PandoraMainPanelView = LuaClass(UIView, true)

function PandoraMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Common_PopUpBG_UIBP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PandoraMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_PopUpBG_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PandoraMainPanelView:OnInit()
	self.AppId = ""
end

function PandoraMainPanelView:OnDestroy()

end

function PandoraMainPanelView:OnShow()
	if nil ~= self.Params then
		self.AppId = self.Params.AppId
		local OpenArgs = self.Params.OpenArgs
		_G.FLOG_INFO("PandoraMainPanelView:OnShow, AppId: %s", self.AppId)
		_G.PandoraMgr:OpenAppWithWidget(self, self.AppId, OpenArgs)
		local LinearColor = _G.UE.FLinearColor.FromHex("FFFFFF00")
		self.Common_PopUpBG_UIBP:SetColorAndOpacity(LinearColor)
	end
end

function PandoraMainPanelView:OnHide()
	_G.PandoraMgr:CloseApp(self.AppId)
end

function PandoraMainPanelView:OnRegisterUIEvent()

end

function PandoraMainPanelView:OnRegisterGameEvent()

end

function PandoraMainPanelView:OnRegisterBinder()

end

return PandoraMainPanelView