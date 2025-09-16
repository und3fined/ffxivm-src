---
--- Author: zimuyi
--- DateTime: 2023-03-23 19:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local LSTR = _G.LSTR

---@class RechargingServiceWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnQuestion UFButton
---@field BtnRecord UFButton
---@field BtnReport UFButton
---@field ImgBG1 UImage
---@field ImgBG2 UImage
---@field ImgBG3 UImage
---@field ImgQuestion UFImage
---@field ImgRecord UFImage
---@field ImgReport UFImage
---@field TextQuestion UFTextBlock
---@field TextRecord UFTextBlock
---@field TextReport UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RechargingServiceWinView = LuaClass(UIView, true)

function RechargingServiceWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnQuestion = nil
	--self.BtnRecord = nil
	--self.BtnReport = nil
	--self.ImgBG1 = nil
	--self.ImgBG2 = nil
	--self.ImgBG3 = nil
	--self.ImgQuestion = nil
	--self.ImgRecord = nil
	--self.ImgReport = nil
	--self.TextQuestion = nil
	--self.TextRecord = nil
	--self.TextReport = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RechargingServiceWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RechargingServiceWinView:OnInit()

end

function RechargingServiceWinView:OnDestroy()

end

function RechargingServiceWinView:OnShow()
	self.TextQuestion:SetText(LSTR(940022))
	self.TextReport:SetText(LSTR(940023))
	self.TextRecord:SetText(LSTR(940024))
	self.BG:SetTitleText(LSTR(940025))
end

function RechargingServiceWinView:OnHide()

end

function RechargingServiceWinView:OnRegisterUIEvent()

end

function RechargingServiceWinView:OnRegisterGameEvent()

end

function RechargingServiceWinView:OnRegisterBinder()

end

return RechargingServiceWinView