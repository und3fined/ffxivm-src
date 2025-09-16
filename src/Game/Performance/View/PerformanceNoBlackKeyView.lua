---
--- Author: moodliu
--- DateTime: 2023-11-20 14:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")

---@class PerformanceNoBlackKeyView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DownKey PerformanceDownKeyItemView
---@field ImgBlueBg UImage
---@field ImgRedBg UImage
---@field UpKey PerformanceUpKeyItemView
---@field WhiteKeyA PerformanceWhiteKeyItemView
---@field WhiteKeyB PerformanceWhiteKeyItemView
---@field WhiteKeyC PerformanceWhiteKeyItemView
---@field WhiteKeyCPlus1 PerformanceWhiteKeyItemView
---@field WhiteKeyD PerformanceWhiteKeyItemView
---@field WhiteKeyE PerformanceWhiteKeyItemView
---@field WhiteKeyF PerformanceWhiteKeyItemView
---@field WhiteKeyG PerformanceWhiteKeyItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceNoBlackKeyView = LuaClass(UIView, true)

function PerformanceNoBlackKeyView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DownKey = nil
	--self.ImgBlueBg = nil
	--self.ImgRedBg = nil
	--self.UpKey = nil
	--self.WhiteKeyA = nil
	--self.WhiteKeyB = nil
	--self.WhiteKeyC = nil
	--self.WhiteKeyCPlus1 = nil
	--self.WhiteKeyD = nil
	--self.WhiteKeyE = nil
	--self.WhiteKeyF = nil
	--self.WhiteKeyG = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceNoBlackKeyView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.DownKey)
	self:AddSubView(self.UpKey)
	self:AddSubView(self.WhiteKeyA)
	self:AddSubView(self.WhiteKeyB)
	self:AddSubView(self.WhiteKeyC)
	self:AddSubView(self.WhiteKeyCPlus1)
	self:AddSubView(self.WhiteKeyD)
	self:AddSubView(self.WhiteKeyE)
	self:AddSubView(self.WhiteKeyF)
	self:AddSubView(self.WhiteKeyG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceNoBlackKeyView:OnInit()

	self.WhiteKeyA.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_A
	self.WhiteKeyB.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_B
	self.WhiteKeyC.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_C
	self.WhiteKeyD.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_D
	self.WhiteKeyE.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_E
	self.WhiteKeyF.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_F
	self.WhiteKeyG.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_G
	self.WhiteKeyCPlus1.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_MAX
	self.WhiteKeyCPlus1.IsKeyi = true
end

function PerformanceNoBlackKeyView:OnDestroy()

end

function PerformanceNoBlackKeyView:OnShow()

end

function PerformanceNoBlackKeyView:OnHide()

end

function PerformanceNoBlackKeyView:OnRegisterUIEvent()

end

function PerformanceNoBlackKeyView:OnRegisterGameEvent()

end

function PerformanceNoBlackKeyView:OnRegisterBinder()

end

return PerformanceNoBlackKeyView