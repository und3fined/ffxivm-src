---
--- Author: Administrator
--- DateTime: 2025-07-16 16:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PVPDanGoldView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img UFImage
---@field Img1 UFImage
---@field Img2 UFImage
---@field Img3 UFImage
---@field Img4 UFImage
---@field Img5 UFImage
---@field Img6 UFImage
---@field ImgEmpty UFImage
---@field PanelAchieve UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPDanGoldView = LuaClass(UIView, true)

function PVPDanGoldView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Img = nil
	--self.Img1 = nil
	--self.Img2 = nil
	--self.Img3 = nil
	--self.Img4 = nil
	--self.Img5 = nil
	--self.Img6 = nil
	--self.ImgEmpty = nil
	--self.PanelAchieve = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPDanGoldView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPDanGoldView:OnInit()
	self.Binders = {
		{ "IsAchieved", UIBinderValueChangedCallback.New(self, nil, self.SetIsAchieved) },
	}
end

function PVPDanGoldView:OnDestroy()

end

function PVPDanGoldView:OnShow()

end

function PVPDanGoldView:OnHide()

end

function PVPDanGoldView:OnRegisterUIEvent()

end

function PVPDanGoldView:OnRegisterGameEvent()

end

function PVPDanGoldView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function PVPDanGoldView:SetIsAchieved(IsAchieved)
	UIUtil.SetIsVisible(self.PanelAchieve, IsAchieved)
	UIUtil.SetIsVisible(self.ImgEmpty, not IsAchieved)
end

return PVPDanGoldView