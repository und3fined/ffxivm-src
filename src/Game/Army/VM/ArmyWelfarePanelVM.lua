---
--- Author: Star
--- DateTime: 2023-11-24 16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ArmyDefine = require("Game/Army/ArmyDefine")
local ProtoRes = require("Protocol/ProtoRes")
local GroupUplevelpermissionCfg = require("TableCfg/GroupUplevelpermissionCfg")
local ArmyUpLevelPerermissionType = ArmyDefine.ArmyUpLevelPerermissionType


local ArmyMgr

---@class ArmyWelfarePanelVM : UIViewModel
---@field GroupPermissionList table @权限列表数据
---@field GroupPermissionTable table @权限数据
local ArmyWelfarePanelVM = LuaClass(UIViewModel)


---Ctor
function ArmyWelfarePanelVM:Ctor()
    
end

function ArmyWelfarePanelVM:OnInit()
    ArmyMgr = _G.ArmyMgr
    self.WelfareList = ArmyDefine.ArmyWelfareTabs
end

function ArmyWelfarePanelVM:UpdateArmyWelfareInfo()
    self:UpdateUnlockState()
end

function ArmyWelfarePanelVM:UpdateUnlockState()
    local Cfg = GroupUplevelpermissionCfg:FindAllCfg()
    local ArmyLevel = ArmyMgr:GetArmyLevel() or 0
    local PrivilegeList = {}
    for _, Data in ipairs(Cfg) do
        if Data.Level and Data.Level <= ArmyLevel then
            local ReplaceIndex
            local IsExist = false
            for Index, Privilege in ipairs(PrivilegeList) do
                if Data.Type == Privilege.Type then
                    IsExist = true
                    if Data.Level > Privilege.Level then
                        ReplaceIndex = Index
                    end
                end
            end
            local ItemData = table.clone(Data)
            if ReplaceIndex then
                PrivilegeList[ReplaceIndex] = ItemData
            elseif IsExist == false then
                if Data.Type ~= 0 then
                    table.insert(PrivilegeList, ItemData)
                end
            end
        end
    end

    --local ArmyLevel = ArmyMgr:GetArmyLevel()
    for Index, WelfareData in ipairs(self.WelfareList) do
        WelfareData.IsLocked = true
        if self.ItemOffsetY and self.ItemOffsetY[Index] then
            WelfareData.OffsetY = self.ItemOffsetY[Index]
        end
        if WelfareData.ID == ArmyDefine.ArmyWelfarePageId.Store then
            --local StoreData= ArmyMgr:GetAllStoreData()
            local UnLockLevel
            --- 部队存储仓库数据就是用ID当下标存储的，直接用下标就行
                local StoreAllData = GroupUplevelpermissionCfg:GetPermissionByType(ArmyUpLevelPerermissionType.ArmyStorageLocker)
                local StoreData = table.find_by_predicate(StoreAllData, function(Data)
                    return Data.FuncLevel == 1
                end)
                if StoreData then
                    local GroupLevel = StoreData.Level
                    if GroupLevel then
                        UnLockLevel = GroupLevel
                    end
                end
            if UnLockLevel then
                WelfareData.UnLockLevel = UnLockLevel
            end
            WelfareData.IsLocked = false
        elseif WelfareData.ID == ArmyDefine.ArmyWelfarePageId.Shop then
            local AllData = GroupUplevelpermissionCfg:GetPermissionByType(ArmyUpLevelPerermissionType.ArmyShopLevel)
            local Data = table.find_by_predicate(AllData, function(Data)
                return Data.FuncLevel == 1
            end)
            if Data then
                local GroupLevel = Data.Level
                if GroupLevel then
                    WelfareData.UnLockLevel = GroupLevel
                end
            end
        elseif WelfareData.ID == ArmyDefine.ArmyWelfarePageId.SE then
            WelfareData.UnLockLevel = 3
        elseif WelfareData.ID == ArmyDefine.ArmyWelfarePageId.House then
            WelfareData.IsLocked = true
        end
        local CfgData = table.find_by_predicate(PrivilegeList, function(Data)
            return Data.Type == WelfareData.ID
        end)
        ---如果存在未解锁等级，则用等级判断是否解锁
        if WelfareData.UnLockLevel then
            WelfareData.IsLocked = ArmyLevel < WelfareData.UnLockLevel
            if CfgData then
                WelfareData.WelfareLevel = CfgData.FuncLevel or 1
            else
                WelfareData.IsLocked = true
            end
        end
    end
end

function ArmyWelfarePanelVM:OnBegin()
end

function ArmyWelfarePanelVM:OnEnd()
end

function ArmyWelfarePanelVM:OnShutdown()

end

function ArmyWelfarePanelVM:SetItemOffsetY(ItemOffsetY)
    self.ItemOffsetY = ItemOffsetY
end

return ArmyWelfarePanelVM
