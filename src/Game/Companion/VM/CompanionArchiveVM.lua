local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local CompanionCfg = require ("TableCfg/CompanionCfg")
local CompanionMergeGroupCfg = require ("TableCfg/CompanionMergeGroupCfg")
local ItemUtil = require("Utils/ItemUtil")
local TimeUtil = require("Utils/TimeUtil")
local CommonDefine = require("Define/CommonDefine")
local BagDefine = require("Game/Bag/BagDefine")

local CompanionListItemVM = require ("Game/Companion/VM/CompanionListItemVM")
local CompanionVM = require ("Game/Companion/VM/CompanionVM")
local CompanionArchiveFilterItemVM = require ("Game/Companion/VM/CompanionArchiveFilterItemVM")

local LSTR = _G.LSTR
local ClientVisionMgr = _G.ClientVisionMgr
local CompanionMgr = _G.CompanionMgr
local FLOG_ERROR = _G.FLOG_ERROR

---@class CompanionArchiveVM : UIViewModel
local CompanionArchiveVM = LuaClass(UIViewModel)

---Ctor
function CompanionArchiveVM:Ctor()
    self.UnlockItemID = nil
    self.ResID = nil
    self.CompanionVMList = nil
    self.CompanionName = nil
    self.CompanionMoveType = nil
    self.CompanionFootprint = nil
    self.IsOwnCompanion = nil
    self.IsNotProtect = nil
    self.IsShowDescription = nil
    self.CompanionExpository = nil
    self.CompanionCry = nil
    self.IsSearching = nil
    self.AllCompanionCount = 0
    self.AllCompanionIDList = nil
    self.NotOwnCompanionIDList = nil
    self.CurrentShowList = nil
    self.IsShowNotOwn = false
    self.GetWayTypeMap = {} -- 用于判断某途径是否有宠物
    self.AllGetWayTypes = nil   -- 配置中的获取途径集合
    self.GetWayFilterValue = nil
    self.GetWayFilterTypes = nil
    self.IsMergeCompanion = false
    self.IsEmpty = false
    self.LastEmptyType = nil
    self.CanBattle = nil
    self.HasShow = nil
    self.IsShowing = false
    self.IsAttacking = false
    self.IsMoving = false
    self.AutoPlayInteract = false
    self.Source = BagDefine.ItemGetWaySource.Companion
end

function CompanionArchiveVM:GetAllData()
    local AllCompanionCfg = CompanionCfg:GetPackageCfg()
    local AllIDList = {}
    local AllCompanionCount = 0
    local AddedMergeGroup = {}
    local CurServerTime = TimeUtil.GetServerTime()
    for _, Cfg in ipairs(AllCompanionCfg) do
        if ClientVisionMgr:CheckVersionByGlobalVersion(Cfg.VersionName) then
            local IsChVersion = CommonDefine.bChsVersion == true    -- 只有国服才有上线日期功能
            local PassReleaseCheck = not IsChVersion
            if IsChVersion then
                PassReleaseCheck = false
                if Cfg.NotCheckRelease == 1 then
                    PassReleaseCheck = true
                else
                    if not string.isnilorempty(Cfg.ReleaseDate) then
                        local ReleaseTime = TimeUtil.GetTimeFromString(Cfg.ReleaseDate)
                        PassReleaseCheck = ReleaseTime and CurServerTime >= ReleaseTime
                    end
                end
            end
            
            if PassReleaseCheck then
                local CompanionID = Cfg.ID
                table.insert(AllIDList, CompanionID)

                -- 记录有宠物的获取途径
                local GetWayList = ItemUtil.GetItemGetWayList(Cfg.UnlockItemID)
                for _, GetWay in ipairs(GetWayList or {}) do
                    local GetWayType = GetWay.ItemAccessFunType
                    if not self.GetWayTypeMap[GetWayType] then
                        self.GetWayTypeMap[GetWayType] = true
                    end
                end
                
                local IsInGroup, GroupID = CompanionMgr:IsCompanionInMergeGroup(CompanionID)
                if IsInGroup then
                    local IsAddedGroup = table.contain(AddedMergeGroup, GroupID)
                    if not IsAddedGroup then
                        table.insert(AddedMergeGroup, GroupID)
                        AllCompanionCount = AllCompanionCount + 1
                    end
                else
                    AllCompanionCount = AllCompanionCount + 1
                end
            end
        end
    end

    local NotOwnIDList = {}
    for _, CompanionID in pairs(AllIDList) do
        if not CompanionVM:IsOwnCompanion(CompanionID) then
            table.insert(NotOwnIDList, CompanionID)
        end
    end

    self.AllCompanionCount = AllCompanionCount
    self.AllCompanionIDList = AllIDList
    self.NotOwnCompanionIDList = NotOwnIDList

    -- 默认展示所有宠物
    self.CurrentShowList = self.AllCompanionIDList
end

function CompanionArchiveVM:ShowAllCompanion()
    self:ShowCompanion(nil)
end

function CompanionArchiveVM:ShowCompanion(SearchFilter)
    local CompanionItemVMList = {}
    local AddedMergeGroup = {}
    for _, ID in ipairs(self.CurrentShowList) do
        local Cfg = CompanionCfg:FindCfgByKey(ID)
        local IsInGroup, GroupID = CompanionMgr:IsCompanionInMergeGroup(ID)
        local IsMerge = Cfg.MergeGroupID and Cfg.MergeGroupID ~= 0 or false
        local IsAddedGroup = false
        if IsInGroup then
            IsAddedGroup = table.contain(AddedMergeGroup, GroupID)
            if not IsAddedGroup then
                table.insert(AddedMergeGroup, GroupID)
                Cfg = CompanionMgr:GetCompanionExternalCfg(ID)
            end
        end
 
        if self:IsInFiltered(ID, SearchFilter) then
            if not IsAddedGroup then
                local ItemVM = CompanionListItemVM.New()
                ItemVM:SetArchiveData(IsMerge, Cfg)
                table.insert(CompanionItemVMList, ItemVM)
            end
        end
    end

    -- 排序函数
    local function SortFunction(VM1, VM2)
        local Cfg1 = VM1.Cfg
        local Cfg2 = VM2.Cfg
        
        -- 先排UI优先度，再排ID
        if Cfg1.UISortPriority ~= Cfg2.UISortPriority then
            return Cfg1.UISortPriority < Cfg2.UISortPriority
        else
            return VM1.CompanionID < VM2.CompanionID
        end
    end

    table.sort(CompanionItemVMList, SortFunction)
    self.IsEmpty = #CompanionItemVMList <= 0
    self.CompanionVMList = CompanionItemVMList
end

-- 是否可过滤
function CompanionArchiveVM:IsInFiltered(ID, SearchFilter)
    -- 名字过滤
    local IsInNameFilter = false

    local Cfg = CompanionMgr:GetCompanionExternalCfg(ID)
    if Cfg == nil then return false end
    
    if SearchFilter and string.len(SearchFilter) > 0 then
        -- 未解锁的宠物不允许按名字搜索
        local CanShowInfo = CompanionVM:IsOwnCompanion(ID) or Cfg.IsStoryProtect == 0
        if CanShowInfo then
            if Cfg.Name == SearchFilter or string.find(Cfg.Name, SearchFilter) ~= nil then
                IsInNameFilter = true
            end
        end
    else
        IsInNameFilter = true
    end

    -- 获取途径过滤
    local IsInGetWayFilter = false
    local GetWayList = ItemUtil.GetItemGetWayList(Cfg.UnlockItemID)
    if GetWayList == nil or #GetWayList == 0 then
        IsInGetWayFilter = true
    end

    for _, GetWay in ipairs(GetWayList and GetWayList or {}) do
        if self:IsValueInGetWayFilter(GetWay.ItemAccessFunType) then
            IsInGetWayFilter = true
            break
        end
    end

    return IsInNameFilter and IsInGetWayFilter
end

function CompanionArchiveVM:ShowCompanionInfo(VMData)
    self.IsShowDescription = false

    local Cfg = VMData.Cfg
    local IsOwnCompanion = not VMData.IsNotOwn
    self.ResID = Cfg.UnlockItemID
    self.CompanionMoveType = Cfg.MoveType
    self.CompanionFootprint = Cfg.FootprintImage
    self.CompanionExpository = Cfg.Expository
    self.CompanionCry = Cfg.Cry
    self.IsNotProtect = IsOwnCompanion or Cfg.IsStoryProtect == 0
    self.IsOwnCompanion = IsOwnCompanion
    self.CompanionName = self.IsNotProtect and Cfg.Name or LSTR(120015)
    self.IsMergeCompanion = VMData.IsMerge
    self.CanBattle = Cfg.CanBattle
end

function CompanionArchiveVM:SetDescriptionVisible(Visible)
    self.IsShowDescription = Visible
end

function CompanionArchiveVM:IsValueInGetWayFilter(Value)
    if self.GetWayFilterValue == nil then return false end

    return table.contain(self.GetWayFilterValue, Value)
end

function CompanionArchiveVM:SetGetWayFilterValue(Value)
    self.GetWayFilterValue = { Value }
end

function CompanionArchiveVM:ClearData()
	self.IsSearching = false
    self.IsShowNotOwn = false
    self.CurrentShowList = nil
    self.IsMergeCompanion = false
    self.IsEmpty = false
    self.IsOwnCompanion = false
    self.IsNotProtect = false
    self.IsShowing = false
    self.IsAttacking = false
    self.IsMoving = false
    self.AutoPlayInteract = false
end

function CompanionArchiveVM:ResetAnimaionState()
    self:SetShowState(false)
    self:SetAttackState(false)
    self:SetMoveState(false)
    self:SetAutoPlayInteract(false)
end

function CompanionArchiveVM:SetShowState(State)
    self.IsShowing = State
end

function CompanionArchiveVM:GetShowState()
    return self.IsShowing
end

function CompanionArchiveVM:SetAttackState(State)
    self.IsAttacking = State
end

function CompanionArchiveVM:GetAttackState()
    return self.IsAttacking
end

function CompanionArchiveVM:SetMoveState(State)
    self.IsMoving = State
end

function CompanionArchiveVM:GetMoveState()
    return self.IsMoving
end

function CompanionArchiveVM:SetAutoPlayInteract(State)
    self.AutoPlayInteract = State
end

function CompanionArchiveVM:GetAutoPlayInteract()
    return self.AutoPlayInteract
end

--- 获取途径筛选器默认值为所有已配置的的途径集合
function CompanionArchiveVM:InitGetWayFilterData()
    local FilterTypes = {
        { ItemData = { FilterType = 0 },
        Name = LSTR(120016) },
    }
    
    local AllGetWayTypes = {}
    local AllGetWayList = ProtoRes.ItemAccessFunType

    for _, GetWayType in pairs(AllGetWayList) do
        if GetWayType ~= 0 then
            if self.GetWayTypeMap[GetWayType] then
                local Name = ProtoEnumAlias.GetAlias(ProtoRes.ItemAccessFunType, GetWayType)
                table.insert(FilterTypes, { ItemData = { FilterType = GetWayType }, Name = Name} )
                table.insert(AllGetWayTypes, GetWayType)
            end
        end
    end

    self.AllGetWayTypes = AllGetWayTypes
    self.GetWayFilterTypes = FilterTypes
end

function CompanionArchiveVM:ResetGetWayFilterValue()
    if self.AllGetWayTypes then
        self.GetWayFilterValue = self.AllGetWayTypes
    else
        FLOG_ERROR("[CompanionArchiveVM][ResetGetWayFilterValue]No filter data")
        self.GetWayFilterValue = {}
    end
end

function CompanionArchiveVM:UpdateVMData()
    for _, ItemVM in ipairs(self.CompanionVMList) do
        ItemVM:UpdateArchiveData()
    end
end

--要返回当前类
return CompanionArchiveVM