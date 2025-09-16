---
--- Author: moodliu
--- DateTime: 2023-11-20 19:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")

---@class PerformanceNoBlackLargeKeyView : UIView
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
local PerformanceNoBlackLargeKeyView = LuaClass(UIView, true)

function PerformanceNoBlackLargeKeyView:Ctor()
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

function PerformanceNoBlackLargeKeyView:OnRegisterSubView()
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

function PerformanceNoBlackLargeKeyView:OnInit()

end

function PerformanceNoBlackLargeKeyView:OnDestroy()

end

function PerformanceNoBlackLargeKeyView:OnShow()
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

function PerformanceNoBlackLargeKeyView:OnHide()

end

function PerformanceNoBlackLargeKeyView:OnRegisterUIEvent()

end

function PerformanceNoBlackLargeKeyView:OnRegisterGameEvent()

end

function PerformanceNoBlackLargeKeyView:OnRegisterBinder()

end

return PerformanceNoBlackLargeKeyView