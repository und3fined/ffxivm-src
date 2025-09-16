--
-- Author: ZhengJanChuan
-- Date: 2024-03-04 16:45
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIBindableList = require("UI/UIBindableList")
local WardrobeTipsListItemVM  = require("Game/Wardrobe/VM/Item/WardrobeTipsListItemVM")

---@class WardrobeTipsItemVM : UIViewModel
local WardrobeTipsItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeTipsItemVM:Ctor()
    self.SameEquipmentList = UIBindableList.New(WardrobeTipsListItemVM)
    self.SelectedIndex = 1
    self.ApperanceID = nil
   
end

function WardrobeTipsItemVM:OnInit()
end

function WardrobeTipsItemVM:OnBegin()
end

function WardrobeTipsItemVM:OnEnd()
end

function WardrobeTipsItemVM:OnShutdown()
end

function WardrobeTipsItemVM:UpdateVM(Value)
    self.SameEquipmentList:UpdateByValues(Value.DataList)
end

function WardrobeTipsItemVM:UpdateSelectIndex(Index)
    self.SelectedIndex = Index
end


--要返回当前类
return WardrobeTipsItemVM