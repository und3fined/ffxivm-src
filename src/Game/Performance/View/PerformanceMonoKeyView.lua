---
--- Author: moodliu
--- DateTime: 2023-11-20 19:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")

---@class PerformanceMonoKeyView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BlackKeyBb PerformanceBlackKeyItemView
---@field BlackKeyCSharp PerformanceBlackKeyItemView
---@field BlackKeyEb PerformanceBlackKeyItemView
---@field BlackKeyFSharp PerformanceBlackKeyItemView
---@field BlackKeyGSharp PerformanceBlackKeyItemView
---@field DownKey PerformanceDownKeyItemView
---@field UpKey PerformanceUpKeyItemView
---@field WhiteKeyA PerformanceWhiteKeyItemView
---@field WhiteKeyB PerformanceWhiteKeyItemView
---@field WhiteKeyC PerformanceWhiteKeyItemView
---@field WhiteKeyD PerformanceWhiteKeyItemView
---@field WhiteKeyE PerformanceWhiteKeyItemView
---@field WhiteKeyF PerformanceWhiteKeyItemView
---@field WhiteKeyG PerformanceWhiteKeyItemView
---@field WhiteKeyi PerformanceWhiteKeyItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceMonoKeyView = LuaClass(UIView, true)

function PerformanceMonoKeyView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BlackKeyBb = nil
	--self.BlackKeyCSharp = nil
	--self.BlackKeyEb = nil
	--self.BlackKeyFSharp = nil
	--self.BlackKeyGSharp = nil
	--self.DownKey = nil
	--self.UpKey = nil
	--self.WhiteKeyA = nil
	--self.WhiteKeyB = nil
	--self.WhiteKeyC = nil
	--self.WhiteKeyD = nil
	--self.WhiteKeyE = nil
	--self.WhiteKeyF = nil
	--self.WhiteKeyG = nil
	--self.WhiteKeyi = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceMonoKeyView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BlackKeyBb)
	self:AddSubView(self.BlackKeyCSharp)
	self:AddSubView(self.BlackKeyEb)
	self:AddSubView(self.BlackKeyFSharp)
	self:AddSubView(self.BlackKeyGSharp)
	self:AddSubView(self.DownKey)
	self:AddSubView(self.UpKey)
	self:AddSubView(self.WhiteKeyA)
	self:AddSubView(self.WhiteKeyB)
	self:AddSubView(self.WhiteKeyC)
	self:AddSubView(self.WhiteKeyD)
	self:AddSubView(self.WhiteKeyE)
	self:AddSubView(self.WhiteKeyF)
	self:AddSubView(self.WhiteKeyG)
	self:AddSubView(self.WhiteKeyi)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceMonoKeyView:OnInit()

	self.WhiteKeyA.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_A
	self.WhiteKeyB.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_B
	self.WhiteKeyC.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_C
	self.WhiteKeyD.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_D
	self.WhiteKeyE.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_E
	self.WhiteKeyF.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_F
	self.WhiteKeyG.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_G

	self.BlackKeyBb.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_A_PLUS
	self.BlackKeyCSharp.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_C_PLUS
	self.BlackKeyEb.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_D_PLUS
	self.BlackKeyFSharp.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_F_PLUS
	self.BlackKeyGSharp.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_G_PLUS
	self.WhiteKeyi.Key = MPDefines.KeyCenterStart + MPDefines.KeyDefines.KEY_MAX
	self.WhiteKeyi.IsKeyi = true
end

function PerformanceMonoKeyView:OnDestroy()

end

function PerformanceMonoKeyView:OnShow()

end

function PerformanceMonoKeyView:OnHide()

end

function PerformanceMonoKeyView:OnRegisterUIEvent()

end

function PerformanceMonoKeyView:OnRegisterGameEvent()

end

function PerformanceMonoKeyView:OnRegisterBinder()

end

return PerformanceMonoKeyView