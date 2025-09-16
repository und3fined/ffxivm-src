---
--- Author: moodliu
--- DateTime: 2023-11-20 19:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")

---@class PerformanceFullNoBlackLargeKeyView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field WhiteKeyA PerformanceFullWhiteKeyItemView
---@field WhiteKeyA1 PerformanceFullWhiteKeyItemView
---@field WhiteKeyA2 PerformanceFullWhiteKeyItemView
---@field WhiteKeyB PerformanceFullWhiteKeyItemView
---@field WhiteKeyB1 PerformanceFullWhiteKeyItemView
---@field WhiteKeyB2 PerformanceFullWhiteKeyItemView
---@field WhiteKeyC PerformanceFullWhiteKeyItemView
---@field WhiteKeyC1 PerformanceFullWhiteKeyItemView
---@field WhiteKeyC2 PerformanceFullWhiteKeyItemView
---@field WhiteKeyD PerformanceFullWhiteKeyItemView
---@field WhiteKeyD1 PerformanceFullWhiteKeyItemView
---@field WhiteKeyD2 PerformanceFullWhiteKeyItemView
---@field WhiteKeyE PerformanceFullWhiteKeyItemView
---@field WhiteKeyE1 PerformanceFullWhiteKeyItemView
---@field WhiteKeyE2 PerformanceFullWhiteKeyItemView
---@field WhiteKeyF PerformanceFullWhiteKeyItemView
---@field WhiteKeyF1 PerformanceFullWhiteKeyItemView
---@field WhiteKeyF2 PerformanceFullWhiteKeyItemView
---@field WhiteKeyG PerformanceFullWhiteKeyItemView
---@field WhiteKeyG1 PerformanceFullWhiteKeyItemView
---@field WhiteKeyG2 PerformanceFullWhiteKeyItemView
---@field WhiteKeyi PerformanceFullWhiteKeyItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceFullNoBlackLargeKeyView = LuaClass(UIView, true)

function PerformanceFullNoBlackLargeKeyView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.WhiteKeyA = nil
	--self.WhiteKeyA1 = nil
	--self.WhiteKeyA2 = nil
	--self.WhiteKeyB = nil
	--self.WhiteKeyB1 = nil
	--self.WhiteKeyB2 = nil
	--self.WhiteKeyC = nil
	--self.WhiteKeyC1 = nil
	--self.WhiteKeyC2 = nil
	--self.WhiteKeyD = nil
	--self.WhiteKeyD1 = nil
	--self.WhiteKeyD2 = nil
	--self.WhiteKeyE = nil
	--self.WhiteKeyE1 = nil
	--self.WhiteKeyE2 = nil
	--self.WhiteKeyF = nil
	--self.WhiteKeyF1 = nil
	--self.WhiteKeyF2 = nil
	--self.WhiteKeyG = nil
	--self.WhiteKeyG1 = nil
	--self.WhiteKeyG2 = nil
	--self.WhiteKeyi = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceFullNoBlackLargeKeyView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.WhiteKeyA)
	self:AddSubView(self.WhiteKeyA1)
	self:AddSubView(self.WhiteKeyA2)
	self:AddSubView(self.WhiteKeyB)
	self:AddSubView(self.WhiteKeyB1)
	self:AddSubView(self.WhiteKeyB2)
	self:AddSubView(self.WhiteKeyC)
	self:AddSubView(self.WhiteKeyC1)
	self:AddSubView(self.WhiteKeyC2)
	self:AddSubView(self.WhiteKeyD)
	self:AddSubView(self.WhiteKeyD1)
	self:AddSubView(self.WhiteKeyD2)
	self:AddSubView(self.WhiteKeyE)
	self:AddSubView(self.WhiteKeyE1)
	self:AddSubView(self.WhiteKeyE2)
	self:AddSubView(self.WhiteKeyF)
	self:AddSubView(self.WhiteKeyF1)
	self:AddSubView(self.WhiteKeyF2)
	self:AddSubView(self.WhiteKeyG)
	self:AddSubView(self.WhiteKeyG1)
	self:AddSubView(self.WhiteKeyG2)
	self:AddSubView(self.WhiteKeyi)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceFullNoBlackLargeKeyView:OnInit()
	self.WhiteKeyA.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_A
	self.WhiteKeyA1.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_A + MPDefines.KeyDefines.KEY_MAX
	self.WhiteKeyA2.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_A + MPDefines.KeyDefines.KEY_MAX * 2
	self.WhiteKeyB.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_B
	self.WhiteKeyB1.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_B + MPDefines.KeyDefines.KEY_MAX
	self.WhiteKeyB2.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_B + MPDefines.KeyDefines.KEY_MAX * 2
	self.WhiteKeyC.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_C
	self.WhiteKeyC1.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_C + MPDefines.KeyDefines.KEY_MAX
	self.WhiteKeyC2.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_C + MPDefines.KeyDefines.KEY_MAX * 2
	self.WhiteKeyD.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_D
	self.WhiteKeyD1.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_D + MPDefines.KeyDefines.KEY_MAX
	self.WhiteKeyD2.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_D + MPDefines.KeyDefines.KEY_MAX * 2
	self.WhiteKeyE.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_E
	self.WhiteKeyE1.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_E + MPDefines.KeyDefines.KEY_MAX
	self.WhiteKeyE2.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_E + MPDefines.KeyDefines.KEY_MAX * 2
	self.WhiteKeyF.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_F
	self.WhiteKeyF1.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_F + MPDefines.KeyDefines.KEY_MAX
	self.WhiteKeyF2.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_F + MPDefines.KeyDefines.KEY_MAX * 2
	self.WhiteKeyG.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_G
	self.WhiteKeyG1.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_G + MPDefines.KeyDefines.KEY_MAX
	self.WhiteKeyG2.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_G + MPDefines.KeyDefines.KEY_MAX * 2
	self.WhiteKeyi.Key = MPDefines.KeyEnd
	self.WhiteKeyi.IsKeyi = true
end

function PerformanceFullNoBlackLargeKeyView:OnDestroy()

end

function PerformanceFullNoBlackLargeKeyView:OnShow()

end

function PerformanceFullNoBlackLargeKeyView:OnHide()

end

function PerformanceFullNoBlackLargeKeyView:OnRegisterUIEvent()

end

function PerformanceFullNoBlackLargeKeyView:OnRegisterGameEvent()

end

function PerformanceFullNoBlackLargeKeyView:OnRegisterBinder()

end

return PerformanceFullNoBlackLargeKeyView