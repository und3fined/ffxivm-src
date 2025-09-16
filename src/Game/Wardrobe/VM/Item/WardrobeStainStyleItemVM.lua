
--
-- Author: ZhengJanChuan
-- Date: 2025-03-20 16:10
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class WardrobeStainStyleItemVM : UIViewModel
local WardrobeStainStyleItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeStainStyleItemVM:Ctor()
	self.ID = 0
    self.Color = nil
    self.IsSelected = false
end

function WardrobeStainStyleItemVM:OnInit()
end

function WardrobeStainStyleItemVM:OnBegin()
end

function WardrobeStainStyleItemVM:OnEnd()
end

function WardrobeStainStyleItemVM:OnShutdown()
end

function WardrobeStainStyleItemVM:UpdateVM(Value)
	self.ID = Value.ID
    self.Color = Value.Color
end

function WardrobeStainStyleItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end

function WardrobeStainStyleItemVM:IsEqualVM(Value)
    return self.ID == Value.ID
end


--要返回当前类
return WardrobeStainStyleItemVM