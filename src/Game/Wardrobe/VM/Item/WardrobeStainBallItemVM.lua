--
-- Author: ZhengJanChuan
-- Date: 2024-03-04 14:47
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class WardrobeStainBallItemVM : UIViewModel
local WardrobeStainBallItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeStainBallItemVM:Ctor()
    self.IsSelected = false
	self.Color = nil
	self.ColorImg = nil
	self.StainVisible = true
	self.IsMetal = false
	self.ID = 0
end

function WardrobeStainBallItemVM:OnInit()
end

function WardrobeStainBallItemVM:OnBegin()
end

function WardrobeStainBallItemVM:OnEnd()
end

function WardrobeStainBallItemVM:OnShutdown()
end

function WardrobeStainBallItemVM:UpdateVM(Value)
    self.Color = Value.Color
	local Type = Value.ColorType
    self.ColorImg = string.format("PaperSprite'/Game/UI/Atlas/Wardrobe/Frames/UI_Wardrobe_Img_BallColor%d_png.UI_Wardrobe_Img_BallColor%d_png'", Type, Type)
	self.StainVisible = not Value.IsMetal
	self.IsMetal = Value.IsMetal
	self.ID = Value.ID
end

function WardrobeStainBallItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end


--要返回当前类
return WardrobeStainBallItemVM