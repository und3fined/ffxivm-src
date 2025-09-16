--
-- Author: ZhengJanChuan
-- Date: 2024-02-23 15:38
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local NormalColor = "#878075"
local SelectedColor = "#FFF4D0"

local OutlineNormalColor = "#2121217F"
local OutlineSelectedColor = "#8066447F"

---@class WardrobePageTabItemVM : UIViewModel
local WardrobePageTabItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobePageTabItemVM:Ctor()
    self.IsSelected = false
    self.TabName = ""
    self.TabSelectedColor = SelectedColor
    self.TabOutlineSelectedColor = OutlineSelectedColor
end

function WardrobePageTabItemVM:OnInit()
end

function WardrobePageTabItemVM:OnBegin()
end

function WardrobePageTabItemVM:OnEnd()
end

function WardrobePageTabItemVM:OnShutdown()
end

function WardrobePageTabItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
    self.TabSelectedColor = IsSelected and SelectedColor or NormalColor
    self.TabOutlineSelectedColor = IsSelected and OutlineSelectedColor or OutlineNormalColor
end

function WardrobePageTabItemVM:UpdateVM(Value)
    self.TabName = Value.TabName
end


--要返回当前类
return WardrobePageTabItemVM