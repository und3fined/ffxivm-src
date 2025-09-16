--
-- Author: jianweili
-- Date: 2020-09-03 11:03:50
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local CommonUtil = require("Utils/CommonUtil")

local LoadingView = LuaClass(UIView, true)

function LoadingView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoadingView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoadingView:OnInit()
	--UIUtil.SetIsVisible(self.Rote, false)
end

function LoadingView:OnDestroy()

end

function LoadingView:OnShow()
	--if PWorldMgr:IsShowLoading() then
	--if WorldMsgMgr:IsSpecial() then
	--    UIUtil.ImageSetColorAndOpacity(self.BG, 1, 1, 1, 1)
	--else
	--    UIUtil.ImageSetColorAndOpacity(self.BG, 0, 0, 0, 1)
	--end

	UIUtil.ImageSetColorAndOpacity(self.BG, 0, 0, 0, 1)

	if CommonUtil.IsWithEditor() then
		UIUtil.SetIsVisible(self.Rote, true)
		self:PlayAnimation(self.Rotation, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, 2.0)
	else
		UIUtil.SetIsVisible(self.Rote, false)
	end
end

function LoadingView:OnHide()

end

function LoadingView:OnRegisterUIEvent()

end

function LoadingView:OnRegisterGameEvent()

end

function LoadingView:OnRegisterTimer()

end

function LoadingView:OnRegisterBinder()

end

return LoadingView