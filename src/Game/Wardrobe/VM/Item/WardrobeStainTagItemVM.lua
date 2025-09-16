--
-- Author: ZhengJanChuan
-- Date: 2024-03-04 14:48
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class WardrobeStainTagItemVM : UIViewModel
local WardrobeStainTagItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeStainTagItemVM:Ctor()
    self.StainColor = nil
    self.StainColorVisible = false
end

function WardrobeStainTagItemVM:OnInit()
end

function WardrobeStainTagItemVM:OnBegin()
end

function WardrobeStainTagItemVM:OnEnd()
end

function WardrobeStainTagItemVM:OnShutdown()
end

function WardrobeStainTagItemVM:UpdateVM(Value)
    self.StainColor = Value.StainColor
    self.StainColorVisible = Value.StainColorVisible ~= nil
end


--要返回当前类
return WardrobeStainTagItemVM