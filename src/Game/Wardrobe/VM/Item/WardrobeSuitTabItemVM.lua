--
-- Author: ZhengJanChuan
-- Date: 2024-02-22 17:22
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
-- local WardrobeStainTagItemVM = require("Game/Wardrobe/VM/Item/WardrobeStainTagItemVM")

---@class WardrobeSuitTabItemVM : UIViewModel
local WardrobeSuitTabItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeSuitTabItemVM:Ctor()
    self.ID = 0
    self.PositionIcon = nil
    self.StateIcon = nil
    self.StainTagVisible = false
    self.IsSelected = false
    self.StateIconVisible = false

    self.StainColor = ""
    self.StainColorVisible = false
    
    self.bShowSelectedState = nil

    self.PositionSelectIcon = ""
    self.PositionSelectVisible = false
end

function WardrobeSuitTabItemVM:OnInit()
end

function WardrobeSuitTabItemVM:OnBegin()
end

function WardrobeSuitTabItemVM:OnEnd()
end

function WardrobeSuitTabItemVM:OnShutdown()
end

function WardrobeSuitTabItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.PositionIcon = Value.PositionIcon
    self.StateIcon = ""
    self.StainTagVisible = false
    self.StainColorVisible = false
    self.bShowSelectedState = true
    self.PositionSelectIcon = Value.PositionSelectIcon
end


--要返回当前类
return WardrobeSuitTabItemVM