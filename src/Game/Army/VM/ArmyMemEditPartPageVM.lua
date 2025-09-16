---
--- Author: daniel
--- DateTime: 2023-03-13 16:34
--- Description:分组权限编辑
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local ArmyMemPartEditItemVM = require("Game/Army/ItemVM/ArmyMemPartEditItemVM")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ProtoCommon = require("Protocol/ProtoCommon")

---@deprecated
---@class ArmyMemEditPartPageVM : UIViewModel
---@field CategoryTreeList any @TreeList
local ArmyMemEditPartPageVM = LuaClass(UIViewModel)

---Ctor
function ArmyMemEditPartPageVM:Ctor()
    self.CategoryTreeList = nil
end

function ArmyMemEditPartPageVM:OnInit()
    self.CategoryTreeList = UIBindableList.New(ArmyMemPartEditItemVM)
end

function ArmyMemEditPartPageVM:OnBegin()
end

function ArmyMemEditPartPageVM:OnEnd()
end

function ArmyMemEditPartPageVM:OnShutdown()
    self.CategoryTreeList:Clear()
    self.CategoryTreeList = nil
end

function ArmyMemEditPartPageVM:UpdateCategoryList(Categories)
    self.CategoryTreeList:UpdateByValues(Categories, ArmyDefine.ArmyCategorySortFunc)
end

function ArmyMemEditPartPageVM:UpdateMemberListByCID(CategoryID, CategoryData)
    local Category = self.CategoryTreeList:Find(function(Element)
        return Element.CategoryID == CategoryID
    end)
    if Category then
        Category:UpdateVM(CategoryData)
    end
end

function ArmyMemEditPartPageVM:UpdateClassIconByID(CategoryID, CategoryIconID)
    local CategoryVM = self.CategoryTreeList:Find(function(Element)
        return Element.CategoryID == CategoryID
    end)
    if CategoryVM then
        CategoryVM:SetIcon(CategoryIconID)
    end
end

return ArmyMemEditPartPageVM
