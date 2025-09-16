--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:外观追踪界面VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local EventID = require("Define/EventID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local FashionTrackEquipItemVM = require("Game/FashionEvaluation/VM/ItemVM/FashionTrackEquipItemVM")
local FashionTrackEquipModelItemVM = require("Game/FashionEvaluation/VM/ItemVM/FashionTrackEquipModelItemVM")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")

local LSTR = _G.LSTR

---@class FashionEvaluationTrackVM : UIViewModel
---@field AppearanceName string @当前外观名字
---@field IsExistCanUnLockEquip boolean @是否存在可解锁外观
---@field MaxTrackNum number @最大追踪数
---@field TrackAppearanceList table @外观追踪列表
---
local FashionEvaluationTrackVM = LuaClass(UIViewModel)

function FashionEvaluationTrackVM:Ctor(FashionEvaluationVM)
    self.AppearanceName = ""
    self.IsTrackListEmpty = true
    self.IsExistCanUnLockEquip = false
    self.TrackAppearanceList = {} --外观列表（数组，用于排序)
    self.TrackAppearanceVMList = UIBindableList.New(FashionTrackEquipItemVM)
    self.MaxTrackNum = 0
    self.TrackAppearanceMap = {} --外观列表（Map 用于查找）
    self.TrackEquipList = {} -- 同外观装备列表
    self.TrackEquipVMList = UIBindableList.New(FashionTrackEquipModelItemVM)
    self.FashionEvaluationVM = FashionEvaluationVM
    self.CanUnLockCurAppearance = false --当前外观是否可解锁
end



function FashionEvaluationTrackVM:OnInit()
    self.MaxTrackNum = FashionEvaluationVMUtils.GetMaxTrackNum()
end

function FashionEvaluationTrackVM:OnBegin()

end

function FashionEvaluationTrackVM:OnEnd()

end

function FashionEvaluationTrackVM:OnShutdown()

end

---可解锁>未解锁>衣橱已拥有
local function TrackSortFunc(EquipA, EquipB)
    if EquipA.CanUnLock ~= EquipB.CanUnLock then
        return EquipA.CanUnLock
    elseif EquipA.Unlock ~= EquipB.Unlock then
        return not EquipA.Unlock
    end
    return EquipA.Order < EquipB.Order
end

---@type 更新追踪外观列表
function FashionEvaluationTrackVM:UpdateTrackAppearanceList(TrackAppearanceList)
    self.IsExistCanUnLockEquip = false
    self.TrackAppearanceList = {}
    self.TrackAppearanceMap = {}
    if TrackAppearanceList == nil or next(TrackAppearanceList) == nil then
        self.IsTrackListEmpty = true
        return
    end

    self.IsTrackListEmpty = false
    for Index, TrackAppearanceID in ipairs(TrackAppearanceList) do
        local NewEquipInfo = {
            AppearanceID = TrackAppearanceID,
            CanUnLock = self:CanUnLock(TrackAppearanceID),
            Unlock = self:IsUnLock(TrackAppearanceID),
            IsOwn = self:IsOwned(TrackAppearanceID),
            Order = Index,
        }

        if NewEquipInfo.CanUnLock == true then
            self.IsExistCanUnLockEquip = true
        end
        self:UpdateRedDot(NewEquipInfo.AppearanceID)

        self.TrackAppearanceMap[TrackAppearanceID] = TrackAppearanceID
        table.insert(self.TrackAppearanceList, NewEquipInfo)
    end

    if not self.IsExistCanUnLockEquip then
        local RedDotName = self:GetRedDotName()
        _G.RedDotMgr:DelRedDotByName(RedDotName)
    end

    table.sort(self.TrackAppearanceList, TrackSortFunc)
    self.TrackAppearanceVMList:UpdateByValues(self.TrackAppearanceList, nil)
end

---@type 外观是否拥有
---@param ApperanceID 外观ID
function FashionEvaluationTrackVM:IsOwned(ApperanceID)
    return WardrobeMgr:GetIsUnlock(ApperanceID)
end

---@type 外观是否已解锁
---@param ApperanceID 外观ID
function FashionEvaluationTrackVM:IsUnLock(ApperanceID)
    return WardrobeMgr:GetIsUnlock(ApperanceID)
end

---@type 外观是否可解锁
---@param ApperanceID 外观ID
function FashionEvaluationTrackVM:CanUnLock(ApperanceID)
    return WardrobeUtil.JudgeUnlockAppearanceWithouItem(ApperanceID) and not self:IsOwned(ApperanceID)
end

---@type 外观是否已追踪
---@param AppearanceID 外观ID
function FashionEvaluationTrackVM:IsTracked(AppearanceID)
    return self.TrackAppearanceMap and self.TrackAppearanceMap[AppearanceID] ~= nil
end

---@type 将外观添加到追踪列表
---@param AppearanceID 外观ID
function FashionEvaluationTrackVM:AddEquipToTrackList(AppearanceID)
    local IsExist = self.TrackAppearanceMap[AppearanceID] ~= nil
    if IsExist == true then
        return true
    end

    if self.TrackAppearanceList == nil then
        self.TrackAppearanceList = {}
    end
    local NewEquipInfo = {
        AppearanceID = AppearanceID,
        CanUnLock = self:CanUnLock(AppearanceID),
        Unlock = self:IsUnLock(AppearanceID),
        IsOwn = self:IsOwned(AppearanceID),
        Order = #self.TrackAppearanceList,
    }

    table.insert(self.TrackAppearanceList, NewEquipInfo)
    self.TrackAppearanceMap[AppearanceID] = AppearanceID
    table.sort(self.TrackAppearanceList, TrackSortFunc)
    self.TrackAppearanceVMList:UpdateByValues(self.TrackAppearanceList, nil)

    -- --追踪标记成功提示
    _G.EventMgr:SendEvent(EventID.OnAppearanceTrackStateChanged, AppearanceID, true)
    return true
end

---@type 更新红点
function FashionEvaluationTrackVM:UpdateRedDot(AppearanceID)
    local CanUnLock = self:CanUnLock(AppearanceID)
    local RedDotName = self:GetRedDotName(AppearanceID)
    if CanUnLock == true then
        _G.RedDotMgr:AddRedDotByName(RedDotName)
    else
        _G.RedDotMgr:DelRedDotByName(RedDotName)
    end
end

---@type 是否可以将外观添加到追踪列表
function FashionEvaluationTrackVM:CanAddEquipToTrackList()
    local TrackListLength = table.length(self.TrackAppearanceList)
    return TrackListLength < self.MaxTrackNum
end

---@type 追踪列表是否存在可解锁外观
function FashionEvaluationTrackVM:IsExistUnlockableAppInTrackList()
    return self.IsExistCanUnLockEquip
end

---@type 将外观从追踪列表移除
---@param AppearanceID 外观ID
function FashionEvaluationTrackVM:RemoveEquipFromTrackList(AppearanceID)
    for Index, TrackEquip in ipairs(self.TrackAppearanceList) do
        if AppearanceID == TrackEquip.AppearanceID then
            table.remove(self.TrackAppearanceList, Index)
            self.TrackAppearanceMap[AppearanceID] = nil
        end
    end
    
    table.sort(self.TrackAppearanceList, TrackSortFunc)
    self.TrackAppearanceVMList:UpdateByValues(self.TrackAppearanceList, nil)

    -- --移除追踪标记提示
    _G.EventMgr:SendEvent(EventID.OnAppearanceTrackStateChanged, AppearanceID, false)
end

function FashionEvaluationTrackVM:GetTrackAppList()
    local AppearanceIDList = {}
    for _, AppInfo in pairs(self.TrackAppearanceList) do
        table.insert(AppearanceIDList, AppInfo.AppearanceID)
    end
    return AppearanceIDList
end

---@type 外观选中
---@param ApperanceID 外观ID
function FashionEvaluationTrackVM:OnAppearanceSelected(ApperanceID)
    self.CanUnLockCurAppearance = false
    local AppInfo = FashionEvaluationVMUtils.GetAppearanceInfo(ApperanceID)
	if AppInfo then
        self.AppearanceName = AppInfo.AppearanceName
    end
    local EquipList = FashionEvaluationVMUtils.GetSameAppearanceEquipmentList(ApperanceID)
    self:UpdateTrackEquipList(EquipList)
    self.CanUnLockCurAppearance = self:CanUnLock(ApperanceID)
end

---@type 更新装备列表
function FashionEvaluationTrackVM:UpdateTrackEquipList(EquipList)
    self.TrackEquipList = {}
    if EquipList then
        for _, EquipResID in ipairs(EquipList) do
            local ModelInfo = {
                EquipID = EquipResID,
            }
            local OwnNum = _G.BagMgr:GetItemNum(EquipResID)  -- 获取背包数量
            ModelInfo.OwnNumText = string.format(LSTR(FashionEvaluationDefine.BagHaveUKey), OwnNum)
            table.insert(self.TrackEquipList, ModelInfo)
        end
    end

    self.TrackEquipVMList:UpdateByValues(self.TrackEquipList, nil)
end

function FashionEvaluationTrackVM:GetRedDotName(AppID)
    if AppID == nil then
        return FashionEvaluationDefine.TrackRedDotName
    end
	local RedDotName = string.format(FashionEvaluationDefine.TrackRedDotName..'/'..AppID)
	return RedDotName
end

return FashionEvaluationTrackVM