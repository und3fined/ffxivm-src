---
--- Author: janezli
--- DateTime: 2024-10-11 14:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MountSpeedWinVM = require("Game/Mount/VM/MountSpeedWinVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class MountSpeedWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF_Focus3 UFCanvasPanel
---@field EFF_Focus4 UFCanvasPanel
---@field ImgGearFocus1 UFImage
---@field ImgGearFocus2 UFImage
---@field ImgGearFocus3 UFImage
---@field ImgGearFocus4 UFImage
---@field ImgMount UFImage
---@field TextCity UFTextBlock
---@field TextGear1 UFTextBlock
---@field TextGear2 UFTextBlock
---@field ThroughFrame CommonThroughFrameSView
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountSpeedWinView = LuaClass(UIView, true)

local LSTR = _G.LSTR

function MountSpeedWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF_Focus3 = nil
	--self.EFF_Focus4 = nil
	--self.ImgGearFocus1 = nil
	--self.ImgGearFocus2 = nil
	--self.ImgGearFocus3 = nil
	--self.ImgGearFocus4 = nil
	--self.ImgMount = nil
	--self.TextCity = nil
	--self.TextGear1 = nil
	--self.TextGear2 = nil
	--self.ThroughFrame = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountSpeedWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ThroughFrame)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountSpeedWinView:OnInit()
	self.ViewModel = MountSpeedWinVM.New()
end

function MountSpeedWinView:OnDestroy()

end

function MountSpeedWinView:OnShow()
	self.ThroughFrame.TextTitle:SetText(LSTR(200003))
	self.ThroughFrame.TextCloseTips:SetText(LSTR(200013))
	local Params = self.Params 
    if Params == nil then
        return
    end
	self.ViewModel:UpdateContent(Params)
	self:PlayAnimation(self.AnimIn)
end

function MountSpeedWinView:OnHide()

end

function MountSpeedWinView:OnRegisterUIEvent()

end

function MountSpeedWinView:OnRegisterGameEvent()

end

function MountSpeedWinView:OnRegisterBinder()
	local Binders = {
		{ "TextCity", UIBinderSetText.New(self, self.TextCity) },
		{ "TextGear1", UIBinderSetText.New(self, self.TextGear1) },
		{ "TextGear2", UIBinderSetText.New(self, self.TextGear2) },
		{ "ImgGearFocus1Visible", UIBinderSetIsVisible.New(self, self.ImgGearFocus1) },
		{ "ImgGearFocus4Visible", UIBinderSetIsVisible.New(self, self.ImgGearFocus4) },
		{ "EFF_Focus4Visible", UIBinderSetIsVisible.New(self, self.EFF_Focus4) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

return MountSpeedWinView