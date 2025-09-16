---
--- Author: yutingzhan
--- DateTime: 2025-04-01 15:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommonVideoPlayerView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PopUpBG CommonPopUpBGView
---@field UMGVideoPlayer UMGVideoPlayerView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonVideoPlayerView = LuaClass(UIView, true)

function CommonVideoPlayerView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PopUpBG = nil
	--self.UMGVideoPlayer = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonVideoPlayerView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.UMGVideoPlayer)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonVideoPlayerView:OnInit()
end

function CommonVideoPlayerView:OnDestroy()

end

function CommonVideoPlayerView:OnShow()
	if self.Params == nil then
		return
	end
	if string.isnilorempty(self.Params.VideoPath) then
		return
	end

	self.UMGVideoPlayer.SetVideoPath(self.UMGVideoPlayer, self.Params.VideoPath)
	self.UMGVideoPlayer.SetSeekValue(self.UMGVideoPlayer, self.Params.SeekValue)
	UIUtil.SetIsVisible(self.UMGVideoPlayer, true)
	self.PopUpBG:SetHideOnClick(false)
end

function CommonVideoPlayerView:OnHide()
	if self.Params == nil then
		return
	end

	local HideCallback = self.Params.HideCallBack
	if nil ~= HideCallback then
		HideCallback()
	end
end

function CommonVideoPlayerView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.UMGVideoPlayer.CloseButton, self.Hide)
end

function CommonVideoPlayerView:OnRegisterGameEvent()

end

function CommonVideoPlayerView:OnRegisterBinder()

end

return CommonVideoPlayerView