local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

local SaveKey = require("Define/SaveKey")

local RideCfg = require("TableCfg/RideCfg")
local MountVM = require("Game/Mount/VM/MountVM")
local MountCustomCfg = require("TableCfg/MountCustomCfg")
local MountCustomMadeSlotVM = require("Game/Mount/VM/MountCustomMadeSlotVM")

local DataReportUtil = require("Utils/DataReportUtil")
local TimeUtil = require("Utils/TimeUtil")
local MountUtil = require("Game/Mount/MountUtil")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")

local ParentRedDotName = "Root/Menu/Mount"
local HandBookParentRedDotName = "Root/Menu/AtlasEntrance/Mount"

local MountMgr = _G.MountMgr
---@class MountCustomMadeVM : UIViewModel
local MountCustomMadeVM = LuaClass(UIViewModel)

function MountCustomMadeVM:Ctor()
    self.MountID = nil
    self.CustomData = nil -- 储存数据
    self.UnlockList = nil
    self.CustomList = nil -- 用于筛选后展示
    self.bShowUnlockedOnly = false
    self.SelectedID = nil
    self.EquipedID = nil
    self.CurrentSelectedSlot = nil

    self.FunctionButtonText = nil
    self.NameText = nil
    self.Price = nil
    self.PriceBeforeDiscounted = nil
    self.bIsDiscounted = nil
    self.bMoneyVisible = nil
    self.CurPriceTextColor = nil

    self.bIsShowPlayer = nil
    self.CustomMadeCfgMap = {}
    self.DefaultCustomMadeIDMap = {}
    self.NewMap = {}
    self.MountNewMap = {}
    self.RedDotNameMap = {}
    self.HandBookRedDotNameMap = {}
    setmetatable(self.NewMap, { __jsontype = 'table' })
    setmetatable(self.MountNewMap, { __jsontype = 'table' })
end

function MountCustomMadeVM:OnEnd()
    self.MountID = nil
    self.CustomData = nil
end

function MountCustomMadeVM:UpdateCustomList(MountID)
    if MountID == nil and self.CustomData == nil then return end
    if MountID == nil or self.MountID == MountID then
        -- 不用重建，只用更新
        if self.UnlockList ~= nil and self.CustomData ~= nil then
            for _, CustomSlotVM in ipairs(self.CustomData) do
                local UnlockInfo = self.UnlockList[CustomSlotVM.ID]
                CustomSlotVM:UpdateOwnState(UnlockInfo)
                CustomSlotVM.bIsNew = self:IsNew(CustomSlotVM.ID)
                if MountVM.MountMap ~= nil and MountVM.MountMap[MountID] ~= nil then
                    CustomSlotVM.bIsEquiped = MountVM.MountMap[MountID].Facade == CustomSlotVM.ID 
                    or MountVM.MountMap[MountID].Facade == 0 and CustomSlotVM.ID == self:GetDefaultCustomMadeID(MountID)
                    --FLOG_INFO("[mount] update %s IsEquiped %s", tostring(CustomSlotVM.ID), tostring(CustomSlotVM.bIsEquiped))
                end
            end 
        else
            FLOG_WARNING("[mount_custom] UnlockList is nil")
        end
    elseif self.UnlockList ~= nil then
        self.MountID = MountID
        local NewCustomData = {}
        for _, Cfg in ipairs(self.CustomMadeCfgMap) do
            if Cfg.MountID == MountID then
                local CustomSlotVM = MountCustomMadeSlotVM.New()
                local UnlockInfo = self.UnlockList[Cfg.ID]
                CustomSlotVM.bIsNew = self:IsNew(Cfg.ID)
                if MountVM.MountMap ~= nil and MountVM.MountMap[MountID] ~= nil then
                    CustomSlotVM.bIsEquiped = MountVM.MountMap[MountID].Facade == Cfg.ID
                    or MountVM.MountMap[MountID].Facade == 0 and Cfg.ID == self:GetDefaultCustomMadeID(MountID)
                    if CustomSlotVM.bIsEquiped then
                        MountCustomMadeVM.EquipedID = Cfg.ID
                    end
                   --FLOG_INFO("[mount] create %s IsEquiped %s", tostring(Cfg.ID), tostring(CustomSlotVM.bIsEquiped))
                end
                CustomSlotVM:Update(Cfg, UnlockInfo)
                NewCustomData[Cfg.ID] = CustomSlotVM
            end
        end
        self.CustomData = NewCustomData
    end

    local NewCustomList = {}
    if self.CustomData ~= nil then
        for _, CustomSlot in ipairs(self.CustomData) do
            -- unlock show   Launch  |  insert
            -- true   true   true    |  true
            -- true   true   false   |  true
            -- true   false  true    |  true
            -- true   false  false   |  true
            -- false  true   true    |  false
            -- false  true   false   |  false
            -- false  false  true    |  true
            -- false  false  false   |  false
            if CustomSlot.bIsUnlocked or (not self.bShowUnlockedOnly and self:IsLaunched(CustomSlot.ID)) then
                table.insert(NewCustomList, CustomSlot)
        end
        end
    end
    table.sort(NewCustomList, function(A, B) return A.Order > B.Order end)
    self.CustomList = NewCustomList
end

function MountCustomMadeVM:SetSelectID(CustomMadeID)
    if MountCustomMadeVM.CustomData == nil then return end
	local OldSelectedSlotVM = MountCustomMadeVM.CustomData[MountCustomMadeVM.SelectedID]
	if OldSelectedSlotVM ~= nil then
		OldSelectedSlotVM.bIsSelected = false
	end

	MountCustomMadeVM.CurrentSelectedSlot = MountCustomMadeVM.CustomData[CustomMadeID]
	if MountCustomMadeVM.CurrentSelectedSlot == nil then return end
	MountCustomMadeVM.CurrentSelectedSlot.bIsSelected = true

	MountCustomMadeVM.SelectedID = CustomMadeID
    MountCustomMadeVM.NameText = MountCustomMadeVM.CurrentSelectedSlot.Name
    MountCustomMadeVM.Price = MountCustomMadeVM.CurrentSelectedSlot.Price
    MountCustomMadeVM.PriceBeforeDiscounted = MountCustomMadeVM.CurrentSelectedSlot.PriceBeforeDiscounted
    if MountCustomMadeVM.Price ~= nil and MountCustomMadeVM.PriceBeforeDiscounted ~= nil then
        MountCustomMadeVM.bIsDiscounted = MountCustomMadeVM.Price ~= MountCustomMadeVM.PriceBeforeDiscounted
    end
    MountCustomMadeVM.CurPriceTextColor = MountCustomMadeVM.CurrentSelectedSlot.PriceTextColor
    MountCustomMadeVM.bMoneyVisible = MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.NotOwnedCanBuy
    DataReportUtil.ReportCustomizeUIFlowData(2, self.MountID,"", MountCustomMadeVM.CurrentSelectedSlot.ID, MountCustomMadeVM.NameText, 1)
end

function MountCustomMadeVM:SetEquipedID(CustomMadeID)
	local OldEquipedSlotVM = MountCustomMadeVM.CustomData[MountCustomMadeVM.EquipedID]
	if OldEquipedSlotVM ~= nil then
		OldEquipedSlotVM.bIsEquiped = false
	end

	local EquipSlot = MountCustomMadeVM.CustomData[CustomMadeID]
	if EquipSlot ~= nil then
        EquipSlot.bIsEquiped = true
    end

    MountCustomMadeVM.EquipedID = CustomMadeID
end

function MountCustomMadeVM:IsCustomMadeEnabled(MountID)
    if self.CustomMadeCfgMap == nil then
        _G.FLOG_ERROR("MountCustomMadeVM.CustomMadeCfgMap is nil")
        return
    end
    for _, Cfg in pairs(self.CustomMadeCfgMap) do
        if Cfg.MountID == MountID then
            return true
        end
    end
    return false
end

function MountCustomMadeVM:OnMountMgrBegin()
    -- 加载所有cfg，用于读取上架时间判断是否已上架
    local AllCfg = MountCustomCfg:FindAllCfg()
    for _, Cfg in ipairs(AllCfg) do
        self.CustomMadeCfgMap[Cfg.ID] = Cfg
    end
end

function MountCustomMadeVM:CheckAllCustomMadeIsNew()
    for Idx, Cfg in ipairs(self.CustomMadeCfgMap) do
        if self:IsLaunched(Idx) then
            self:AddNew(Cfg.ID, false)
        end
    end
    self:PropertyValueChanged("NewMap")
end

function MountCustomMadeVM:IsLaunched(CustomMadeID)
    if self.CustomMadeCfgMap == nil then return false end
    local Cfg = self.CustomMadeCfgMap[CustomMadeID]
    if Cfg == nil then return false end
    local LaunchTime = TimeUtil.GetTimeFromString(Cfg.LaunchTime)
    local CurrentTime = TimeUtil.GetServerLogicTime()
    return LaunchTime ~= nil and CurrentTime > LaunchTime
end

function MountCustomMadeVM:AddNew(CustomMadeID, bIgnoreUpdateVM)
    local Cfg = self.CustomMadeCfgMap[CustomMadeID]
    if Cfg == nil then return end
    if MountVM:IsNotOwnedMount(Cfg.MountID) then return end
    if self:IsNewStateNotAvailable(Cfg.ID) then
        self.NewMap[CustomMadeID] = { bClicked = false }
    end
    if self:IsMountNewStateNotAvailable(Cfg.MountID) then
        self.MountNewMap[Cfg.MountID] = { bClicked = false }
        self.RedDotNameMap[Cfg.MountID] = RedDotMgr:AddRedDotByParentRedDotName(ParentRedDotName)
        self.HandBookRedDotNameMap[Cfg.MountID] = RedDotMgr:AddRedDotByParentRedDotName(HandBookParentRedDotName)
    end
    if bIgnoreUpdateVM == nil or not bIgnoreUpdateVM then
        self:PropertyValueChanged("NewMap")
    end
    self:SaveNewInfo()
end

function MountCustomMadeVM:RemoveNew(CustomMadeID, bIgnoreUpdateVM)
    local Cfg = self.CustomMadeCfgMap[CustomMadeID]
    if Cfg == nil then return end
    if self.NewMap == nil or self.NewMap[CustomMadeID] == nil then return end
    self.NewMap[CustomMadeID].bClicked = true
    if bIgnoreUpdateVM == nil or not bIgnoreUpdateVM then
        self:PropertyValueChanged("NewMap")
    end
    self:SaveNewInfo()
end

-- 外观处于未上新状态
function MountCustomMadeVM:IsNewStateNotAvailable(CustomMadeID)
    return self.NewMap == nil or self.NewMap[CustomMadeID] == nil
end

-- 外观刚上架的New状态
function MountCustomMadeVM:IsNew(CustomMadeID)
    return self.NewMap ~= nil and self.NewMap[CustomMadeID] ~= nil and not self.NewMap[CustomMadeID].bClicked
end

-- 外观已经被用户点选过的状态
function MountCustomMadeVM:IsClicked(CustomMadeID)
    return self.NewMap ~= nil and self.NewMap[CustomMadeID] ~= nil and self.NewMap[CustomMadeID].bClicked
end

function MountCustomMadeVM:MountRemoveNew(MountID, bIgnoreUpdateVM)
    if self.MountNewMap == nil or self.MountNewMap[MountID] == nil then return end
    self.MountNewMap[MountID].bClicked = true
    RedDotMgr:DelRedDotByName(self.RedDotNameMap[MountID])
    RedDotMgr:DelRedDotByName(self.HandBookRedDotNameMap[MountID])
    if bIgnoreUpdateVM == nil or not bIgnoreUpdateVM then
        self:PropertyValueChanged("NewMap")
    end
    self:SaveNewInfo()
end

function MountCustomMadeVM:IsMountNewStateNotAvailable(MountID)
    return self.MountNewMap == nil or self.MountNewMap[MountID] == nil
end

function MountCustomMadeVM:MountIsNew(MountID)
    return self.MountNewMap ~= nil and self.MountNewMap[MountID] ~= nil and not self.MountNewMap[MountID].bClicked
end

function MountCustomMadeVM:MountIsClicked(MountID)
    return self.MountNewMap ~= nil and self.MountNewMap[MountID] ~= nil and self.MountNewMap[MountID].bClicked
end

function MountCustomMadeVM:GetRedDotName(MountID)
    if self.RedDotNameMap == nil or self.RedDotNameMap[MountID] == nil then
        return ""
    end
    return self.RedDotNameMap[MountID]
end

function MountCustomMadeVM:GetHandBookRedDotName(MountID)
    if self.HandBookRedDotNameMap == nil or self.HandBookRedDotNameMap[MountID] == nil then
        return ""
    end
    return self.HandBookRedDotNameMap[MountID]
end

function MountCustomMadeVM:SaveNewInfo()
    MountUtil.SaveMap(self.NewMap, SaveKey.CustomMadeNewMap)
    MountUtil.SaveMap(self.MountNewMap, SaveKey.CustomMadeMountNewMap)
end

function MountCustomMadeVM:LoadNewInfo()
    self.NewMap = MountUtil.LoadMap(SaveKey.CustomMadeNewMap)
    self.MountNewMap = MountUtil.LoadMap(SaveKey.CustomMadeMountNewMap)
end

function MountCustomMadeVM:GetDefaultCustomMadeID(MountID)
    if self.DefaultCustomMadeIDMap[MountID] ~= nil then return self.DefaultCustomMadeIDMap[MountID] end
    local RideCfgRow = RideCfg:FindCfgByKey(MountID)
    if RideCfgRow == nil then return end
    for ID, CustomMadeCfgRow in pairs(self.CustomMadeCfgMap) do
        if CustomMadeCfgRow.MountID == MountID and RideCfgRow.ImeChanId == CustomMadeCfgRow.ImeChanID then
            self.DefaultCustomMadeIDMap[MountID] = ID
            return ID
        end
    end
end

return MountCustomMadeVM