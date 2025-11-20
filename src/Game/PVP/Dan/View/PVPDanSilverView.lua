---
--- Author: Administrator
--- DateTime: 2025-07-16 16:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PVPDanSilverView : UIView
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
local PVPDanSilverView = LuaClass(UIView, true)

function PVPDanSilverView:Ctor()
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

function PVPDanSilverView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPDanSilverView:OnInit()
	self.Binders = {
		{ "IsAchieved", UIBinderValueChangedCallback.New(self, nil, self.SetIsAchieved) },
	}
end

function PVPDanSilverView:OnDestroy()

end

function PVPDanSilverView:OnShow()

end

function PVPDanSilverView:OnHide()

end

function PVPDanSilverView:OnRegisterUIEvent()

end

function PVPDanSilverView:OnRegisterGameEvent()

end

function PVPDanSilverView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function PVPDanSilverView:SetIsAchieved(IsAchieved)
	UIUtil.SetIsVisible(self.PanelAchieve, IsAchieved)
	UIUtil.SetIsVisible(self.ImgEmpty, not IsAchieved)
end

return PVPDanSilverView