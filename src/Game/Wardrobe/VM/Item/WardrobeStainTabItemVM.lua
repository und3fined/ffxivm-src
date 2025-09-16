--
-- Author: ZhengJanChuan
-- Date: 2025-03-20 16:10
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local DyeColorCfg = require("TableCfg/DyeColorCfg")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")


local NormalColor = "#878075"
local SelectedColor = "#FFF4D0"

local OutlineNormalColor = "#2121217F"
local OutlineSelectedColor = "#8066447F"

---@class WardrobeStainTabItemVM : UIViewModel
local WardrobeStainTabItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeStainTabItemVM:Ctor()
	self.ID = 0
    self.IsStain = nil
    self.IsMetal = false
    self.IsNormalcy = false
    self.IsSelected = false
    self.Name = ""
    self.TabSelectedColor = SelectedColor
    self.TabOutlineSelectedColor = OutlineSelectedColor
end

function WardrobeStainTabItemVM:OnInit()
end

function WardrobeStainTabItemVM:OnBegin()
end

function WardrobeStainTabItemVM:OnEnd()
end

function WardrobeStainTabItemVM:OnShutdown()
end

function WardrobeStainTabItemVM:UpdateVM(Value)
	self.ID = Value.ID
    self.Color = Value.Color
    self.IsStain = Value.Color ~= nil
    local DCCfg = DyeColorCfg:FindCfgByKey(Value.Color )
    local SocketIsMetal = false
    if DCCfg ~= nil and DCCfg.Type == 8 then
        SocketIsMetal = true
    end
	self.IsNormalcy = not SocketIsMetal
	self.IsMetal = SocketIsMetal
    self.Name = Value.Name
end


function WardrobeStainTabItemVM:UpdateColor(ColroID)
    self.Color = WardrobeUtil.GetColor(ColroID)
    self.IsStain = ColroID ~= 0
    local DCCfg = DyeColorCfg:FindCfgByKey(ColroID)
    local SocketIsMetal = false
    if DCCfg ~= nil and DCCfg.Type == 8 then
        SocketIsMetal = true
    end
	self.IsNormalcy = not SocketIsMetal
	self.IsMetal = SocketIsMetal
end

function WardrobeStainTabItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
    self.TabSelectedColor = IsSelected and SelectedColor or NormalColor
    self.TabOutlineSelectedColor = IsSelected and OutlineSelectedColor or OutlineNormalColor
end


--要返回当前类
return WardrobeStainTabItemVM