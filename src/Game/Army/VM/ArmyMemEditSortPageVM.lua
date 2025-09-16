---
--- Author: daniel
--- DateTime: 2023-03-13 16:34
--- Description:分组编辑
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local ArmyMemEditClassItemVM = require("Game/Army/ItemVM/ArmyMemEditClassItemVM")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ArmyDefine = require("Game/Army/ArmyDefine")
local GlobalCfgType = ArmyDefine.GlobalCfgType
local LSTR = _G.LSTR

---@class ArmyMemEditSortPageVM : UIViewModel
---@field CategoryList any @List
local ArmyMemEditSortPageVM = LuaClass(UIViewModel)

---Ctor
function ArmyMemEditSortPageVM:Ctor()
    self.CategoryList = nil
end

function ArmyMemEditSortPageVM:OnInit()
    self.CategoryList = UIBindableList.New(ArmyMemEditClassItemVM)
end

function ArmyMemEditSortPageVM:OnBegin()
end

function ArmyMemEditSortPageVM:OnEnd()
end

function ArmyMemEditSortPageVM:OnShutdown()
    self.CategoryList:Clear()
    self.CategoryList = nil
end

--- 更新分组列表
function ArmyMemEditSortPageVM:UpdateCategoryList(Categories)
    local CategoryList = self.CategoryList
    CategoryList:Clear()
    if Categories == nil then
        return
    end
    local Len = #Categories
    local MaxClassNum = GroupGlobalCfg:GetValueByType(GlobalCfgType.CategoryClassifyMaxLimit)
    if Len < MaxClassNum then
        Len = Len + 1
    end
    local Length = #Categories
    for i = 1, Len do
        if Categories[i] then
            self:RefreshCategoryVM(Categories[i], Length)
        else
            local EntryData = {
                ID = -1, ---改成-1，防止和见习分组冲突
                -- LSTR string:新增分组
                Name = LSTR(910148),
                Permssions = {},
                ShowIndex = 10,
                IconID = 0,
                bLeader = false
            }
            self:RefreshCategoryVM(EntryData, nil)
        end
    end
    CategoryList:Sort(ArmyDefine.ArmyCategorySortFunc)
end

--- 添加分组数据
---@param CategoryData ang @分组数据
---@param IconIDs table @已包含
function ArmyMemEditSortPageVM:RefreshCategoryVM(CategoryData, Length)
    local CategoryList = self.CategoryList
    local VM = CategoryList:Find(function(Element)
        return Element.ID == CategoryData.ID
    end)
    if not VM then
        VM = ArmyMemEditClassItemVM.New()
        VM:RefreshVM(CategoryData, Length)
        CategoryList:Add(VM)
    else
        VM:RefreshVM(CategoryData, Length)
    end
end

--- 修改分组名称
---@param CategoryID number @分组ID
---@param Name string @分组名称
function ArmyMemEditSortPageVM:UpdateCategoryName(CategoryID, Name)
    local Result = self.CategoryList:Find(function(Element)
        return Element.ID == CategoryID
    end)
    if Result then
        Result.Name = Name
    end
end

--- 移除分组
function ArmyMemEditSortPageVM:RemoveCategoryVMByID(CategoryID)
    self.CategoryList:RemoveByPredicate(function(Element)
        return Element.ID == CategoryID
    end)
end

function ArmyMemEditSortPageVM:SortRefresh()
    self.CategoryList:Update()
end

--- 判断是否存在
function ArmyMemEditSortPageVM:CheckedIsExistCategoryName(CategoryName)
    CategoryName = string.gsub(CategoryName, "^%s*(.-)%s*$", "%1")
    local Result = self.CategoryList:Find(function(Element)
        return Element.Name == CategoryName
    end)
    return Result ~= nil
end

return ArmyMemEditSortPageVM
