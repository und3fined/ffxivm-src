local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local CompanionCfg = require ("TableCfg/CompanionCfg")
local CompanionMergeGroupCfg = require ("TableCfg/CompanionMergeGroupCfg")

local CompanionListItemVM = require ("Game/Companion/VM/CompanionListItemVM")
local CompanionVM = require ("Game/Companion/VM/CompanionVM")

---@class CompanionListVM : UIViewModel
local CompanionListVM = LuaClass(UIViewModel)

---Ctor
function CompanionListVM:Ctor()
    self.CompanionVMList = nil
    self.CompanionName = nil
    self.ToggleFavourite = false
    self.CanCallCompanion = false
    self.IsShowCallBtn = true
end

function CompanionListVM:UpdateVMList()
    local CompanionList = CompanionVM:GetCompanionList()
    if CompanionList == nil then return end

    local CompanionItemVMList = {}
    local AddedMergeGroup = {}
    for _, Companion in pairs(CompanionList) do
        local ItemVM = CompanionListItemVM.New()
        local Cfg = CompanionCfg:FindCfgByKey(Companion.ID)
        local MergeGroupID = Cfg.MergeGroupID
        local IsMerge = MergeGroupID ~= nil and MergeGroupID ~= 0 or false
        local IsAddedGroup = false
        if IsMerge then
            IsAddedGroup = table.contain(AddedMergeGroup, MergeGroupID)
            if not IsAddedGroup then
                table.insert(AddedMergeGroup, MergeGroupID)
                Cfg = CompanionMergeGroupCfg:FindCfgByKey(Cfg.MergeGroupID)
            end
        end

        if not IsAddedGroup then
            ItemVM:SetListData(IsMerge, Cfg)
            table.insert(CompanionItemVMList, ItemVM)
        end
    end

    -- 排序函数
    local function SortFunction(VM1, VM2)
        local IsLike1 = VM1.IsFavourite and 1 or 0
        local IsLike2 = VM2.IsFavourite and 1 or 0
        
        -- 先排最加了最爱，再排UI优先度，最后排ID
        if IsLike1 ~= IsLike2 then
            return IsLike1 > IsLike2
        elseif VM1.Cfg.UISortPriority ~= VM2.Cfg.UISortPriority then
            return VM1.Cfg.UISortPriority < VM2.Cfg.UISortPriority
        else
            return VM1.CompanionID < VM2.CompanionID
        end
    end

    table.sort(CompanionItemVMList, SortFunction)

    -- 新设计要求不满24个宠物时填空格子
    local OwnCompanionCount = CompanionVM:GetOwnCompanionCount()
    local AtLeastIconCount = 24
    if OwnCompanionCount < AtLeastIconCount then
        local NeedEmptyCount = AtLeastIconCount - OwnCompanionCount
        for i = 1, NeedEmptyCount do
            local ItemVM = CompanionListItemVM.New()
            table.insert(CompanionItemVMList, ItemVM)
        end
    end

    self.CompanionVMList = CompanionItemVMList
end

function CompanionListVM:UpdateVMData()
    for _, ItemVM in ipairs(self.CompanionVMList) do
        ItemVM:UpdateListData()
    end
end

--要返回当前类
return CompanionListVM