--
-- Author: haialexzhou
-- Date: 2020-09-18 19:45:49
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")

local PWorldMainPanelView = LuaClass(UIView, true)

function PWorldMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnExit = nil
	--self.BtnText = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldMainPanelView:OnInit()

end

function PWorldMainPanelView:OnDestroy()

end

function PWorldMainPanelView:OnShow()
	self:UpdateUI()
end

function PWorldMainPanelView:OnHide()

end

function PWorldMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnExit, self.OnClickBtnExit)
end

function PWorldMainPanelView:OnRegisterGameEvent()

end

function PWorldMainPanelView:OnRegisterTimer()

end

function PWorldMainPanelView:OnRegisterBinder()

end

function PWorldMainPanelView:OnClickBtnExit()
	_G.PWorldMgr:SendLeavePWorld()
end

function PWorldMainPanelView:UpdateUI()
	self.BtnText:SetText("退出副本")
end

return PWorldMainPanelView