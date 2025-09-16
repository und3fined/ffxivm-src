---
--- Author: haialexzhou
--- DateTime: 2021-08-31 12:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local DefaultColor = "ffffffff"
local Ready1Color = "C9C08FFF"
local Ready2Color = "C05153FF"

---@class WarningBossCDItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DotItem UFCanvasPanel
---@field FCanvasPanel_43 UFCanvasPanel
---@field FImg_Already UFImage
---@field FImg_AlreadyType UFImage
---@field FImg_Empty UFImage
---@field FImg_Mask UFImage
---@field FImg_Ready01 UFImage
---@field FImg_Ready02 UFImage
---@field ScaleAnimation UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WarningBossCDItemView = LuaClass(UIView, true)

function WarningBossCDItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DotItem = nil
	--self.FCanvasPanel_43 = nil
	--self.FImg_Already = nil
	--self.FImg_AlreadyType = nil
	--self.FImg_Empty = nil
	--self.FImg_Mask = nil
	--self.FImg_Ready01 = nil
	--self.FImg_Ready02 = nil
	--self.ScaleAnimation = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WarningBossCDItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WarningBossCDItemView:OnInit()

end

function WarningBossCDItemView:OnDestroy()

end

function WarningBossCDItemView:OnShow()
	self:UpdateState(_G.PWorldWarningMgr.ReadyState.DEFAULT)
end

function WarningBossCDItemView:SetIcon(IconPath)
	UIUtil.ImageSetBrushFromAssetPath(self.FImg_AlreadyType, IconPath)
end

function WarningBossCDItemView:UpdateState(State)
	if (State == _G.PWorldWarningMgr.ReadyState.DEFAULT) then --默认
		UIUtil.SetIsVisible(self.FImg_Ready02, false)
		UIUtil.SetIsVisible(self.FImg_Already, false)
		UIUtil.SetIsVisible(self.FImg_Ready01, true)
		UIUtil.ImageSetColorAndOpacityHex(self.FImg_AlreadyType, DefaultColor)

	elseif (State == _G.PWorldWarningMgr.ReadyState.SHOWNAME) then --5秒
		UIUtil.ImageSetColorAndOpacityHex(self.FImg_AlreadyType, Ready2Color)
		UIUtil.SetIsVisible(self.FImg_Ready02, true)
		UIUtil.SetIsVisible(self.FImg_Ready01, false)

	elseif (State == _G.PWorldWarningMgr.ReadyState.ALREADY) then --0秒
		UIUtil.ImageSetColorAndOpacityHex(self.FImg_AlreadyType, Ready1Color)
		self:PlayAnimation(self.ScaleAnimation)
		UIUtil.SetIsVisible(self.FImg_Already, true)
		UIUtil.SetIsVisible(self.FImg_Ready01, false)
		UIUtil.SetIsVisible(self.FImg_Ready02, false)
	end
end


function WarningBossCDItemView:OnHide()

end

function WarningBossCDItemView:OnRegisterUIEvent()

end

function WarningBossCDItemView:OnRegisterGameEvent()

end

function WarningBossCDItemView:OnRegisterTimer()

end

function WarningBossCDItemView:OnRegisterBinder()

end

return WarningBossCDItemView