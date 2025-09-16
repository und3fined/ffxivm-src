---
--- Author: moodliu
--- DateTime: 2023-11-20 19:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")

---@class PerformanceFullLargeKeyView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BlackKeyBb PerformanceFullBlackKeyItemView
---@field BlackKeyBb1 PerformanceFullBlackKeyItemView
---@field BlackKeyBb2 PerformanceFullBlackKeyItemView
---@field BlackKeyCSharp PerformanceFullBlackKeyItemView
---@field BlackKeyCSharp1 PerformanceFullBlackKeyItemView
---@field BlackKeyCSharp2 PerformanceFullBlackKeyItemView
---@field BlackKeyEb PerformanceFullBlackKeyItemView
---@field BlackKeyEb1 PerformanceFullBlackKeyItemView
---@field BlackKeyEb2 PerformanceFullBlackKeyItemView
---@field BlackKeyFSharp PerformanceFullBlackKeyItemView
---@field BlackKeyFSharp1 PerformanceFullBlackKeyItemView
---@field BlackKeyFSharp2 PerformanceFullBlackKeyItemView
---@field BlackKeyGSharp PerformanceFullBlackKeyItemView
---@field BlackKeyGSharp1 PerformanceFullBlackKeyItemView
---@field BlackKeyGSharp2 PerformanceFullBlackKeyItemView
---@field ImgBlueBg UImage
---@field ImgRedBg UImage
---@field WhiteKeyA PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyA1 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyA2 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyB PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyB1 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyB2 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyC PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyC1 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyC2 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyD PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyD1 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyD2 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyE PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyE1 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyE2 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyF PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyF1 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyF2 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyG PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyG1 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyG2 PerformanceFullLargeWhiteKeyItemView
---@field WhiteKeyi PerformanceFullLargeWhiteKeyItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceFullLargeKeyView = LuaClass(UIView, true)

function PerformanceFullLargeKeyView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BlackKeyBb = nil
	--self.BlackKeyBb1 = nil
	--self.BlackKeyBb2 = nil
	--self.BlackKeyCSharp = nil
	--self.BlackKeyCSharp1 = nil
	--self.BlackKeyCSharp2 = nil
	--self.BlackKeyEb = nil
	--self.BlackKeyEb1 = nil
	--self.BlackKeyEb2 = nil
	--self.BlackKeyFSharp = nil
	--self.BlackKeyFSharp1 = nil
	--self.BlackKeyFSharp2 = nil
	--self.BlackKeyGSharp = nil
	--self.BlackKeyGSharp1 = nil
	--self.BlackKeyGSharp2 = nil
	--self.ImgBlueBg = nil
	--self.ImgRedBg = nil
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

function PerformanceFullLargeKeyView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BlackKeyBb)
	self:AddSubView(self.BlackKeyBb1)
	self:AddSubView(self.BlackKeyBb2)
	self:AddSubView(self.BlackKeyCSharp)
	self:AddSubView(self.BlackKeyCSharp1)
	self:AddSubView(self.BlackKeyCSharp2)
	self:AddSubView(self.BlackKeyEb)
	self:AddSubView(self.BlackKeyEb1)
	self:AddSubView(self.BlackKeyEb2)
	self:AddSubView(self.BlackKeyFSharp)
	self:AddSubView(self.BlackKeyFSharp1)
	self:AddSubView(self.BlackKeyFSharp2)
	self:AddSubView(self.BlackKeyGSharp)
	self:AddSubView(self.BlackKeyGSharp1)
	self:AddSubView(self.BlackKeyGSharp2)
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

function PerformanceFullLargeKeyView:OnInit()
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

	self.BlackKeyBb.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_A_PLUS
	self.BlackKeyBb1.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_A_PLUS + MPDefines.KeyDefines.KEY_MAX
	self.BlackKeyBb2.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_A_PLUS + MPDefines.KeyDefines.KEY_MAX * 2
	self.BlackKeyCSharp.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_C_PLUS
	self.BlackKeyCSharp1.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_C_PLUS + MPDefines.KeyDefines.KEY_MAX
	self.BlackKeyCSharp2.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_C_PLUS + MPDefines.KeyDefines.KEY_MAX * 2
	self.BlackKeyEb.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_D_PLUS
	self.BlackKeyEb1.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_D_PLUS + MPDefines.KeyDefines.KEY_MAX
	self.BlackKeyEb2.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_D_PLUS + MPDefines.KeyDefines.KEY_MAX * 2
	self.BlackKeyFSharp.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_F_PLUS
	self.BlackKeyFSharp1.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_F_PLUS + MPDefines.KeyDefines.KEY_MAX
	self.BlackKeyFSharp2.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_F_PLUS + MPDefines.KeyDefines.KEY_MAX * 2
	self.BlackKeyGSharp.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_G_PLUS
	self.BlackKeyGSharp1.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_G_PLUS + MPDefines.KeyDefines.KEY_MAX
	self.BlackKeyGSharp2.Key = MPDefines.KeyStart + MPDefines.KeyDefines.KEY_G_PLUS + MPDefines.KeyDefines.KEY_MAX * 2
	self.WhiteKeyi.IsKeyi = true
	self.WhiteKeyi.Key = MPDefines.KeyEnd
end

function PerformanceFullLargeKeyView:OnDestroy()

end

function PerformanceFullLargeKeyView:OnShow()

end

function PerformanceFullLargeKeyView:OnHide()

end

function PerformanceFullLargeKeyView:OnRegisterUIEvent()

end

function PerformanceFullLargeKeyView:OnRegisterGameEvent()

end

function PerformanceFullLargeKeyView:OnRegisterBinder()

end

return PerformanceFullLargeKeyView