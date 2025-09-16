--
-- Author: ZhengJanChuan
-- Date: 2024-02-22 17:22
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
-- local WardrobeStainTagItemVM = require("Game/Wardrobe/VM/Item/WardrobeStainTagItemVM")

---@class WardrobePositionItemVM : UIViewModel
local WardrobePositionItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobePositionItemVM:Ctor()
    self.ID = 0
    self.PositionIcon = nil
    self.StateIcon = nil
    self.StainTagVisible = false
    self.IsSelected = false
    self.StateIconVisible = false

    self.StainColor = ""
    self.StainColorVisible = false

    self.PositionSelectIcon = ""
    self.PositionSelectVisible = false
end

function WardrobePositionItemVM:OnInit()
end

function WardrobePositionItemVM:OnBegin()
end

function WardrobePositionItemVM:OnEnd()
end

function WardrobePositionItemVM:OnShutdown()
end

function WardrobePositionItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.PositionIcon = Value.PositionIcon
    self.StateIcon = Value.StateIcon
    self.StainTagVisible = Value.StainTagVisible
    self.StateIconVisible = Value.StateIcon ~= ""
    self.StainColor = Value.StainColor
    self.PositionSelectIcon = Value.PositionSelectIcon
    if self.StateIconVisible then
        self.PositionSelectVisible = false
    else
        if self.IsSelected then
            self.PositionSelectVisible = true
        end
    end
    self.StainColorVisible = Value.StainColorVisible
end


--要返回当前类
return WardrobePositionItemVM