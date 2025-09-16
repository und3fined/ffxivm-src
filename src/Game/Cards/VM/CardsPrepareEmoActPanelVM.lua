--
-- Author: MichaelYang_LightPaw
-- Date: 2023-10-23 14:50
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local EmotionCfg = require("TableCfg/EmotionCfg")
local CardsEmoActSlotItemVM = require("Game/Cards/VM/CardsEmoActSlotItemVM")
local FantasyCardMotionClassifyCfg = require("TableCfg/FantasyCardMotionClassifyCfg")
local UIBindableList = require("UI/UIBindableList")
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender

---@class CardsPrepareEmoActPanelVM : UIViewModel
local CardsPrepareEmoActPanelVM = LuaClass(UIViewModel)

function CardsPrepareEmoActPanelVM:Ctor()
    self.EmoItemVMList = UIBindableList.New(CardsEmoActSlotItemVM)
    self.AllEmoData = nil
end

--- func desc
---@param EmoType  MagicCardLocalDef.EmotionClassifyType
---@param DataTable any
local function SetIsDisabledByEmoType(EmoType, DataTable)
    if (EmoType <= 0) then
        DataTable.IsDisabled = not DataTable.IsGetted
        return
    end

    if (not DataTable.IsGetted) then
        DataTable.IsDisabled = true
        return
    end

    -- 判断一下是否包含目标动作类型
    for k,v in pairs(DataTable.ShowEmoTypeTable) do
        if (v == EmoType) then
            DataTable.IsDisabled = false
            return
        end
    end

    DataTable.IsDisabled = true
end

function CardsPrepareEmoActPanelVM:InitData()
    local MajorActiveEmotionIDs = _G.EmotionMgr.MajorActiveEmotionIDs
    local AllEmotionClassify = FantasyCardMotionClassifyCfg:FindAllCfg()

    self.AllEmoData = {}

    -- 只展示激活的情感动作
    for k, v in ipairs(AllEmotionClassify) do
        local ShowEmoTypeTable = {}
        if (v.IsSalute > 0) then
            table.insert(ShowEmoTypeTable, LocalDef.EmotionClassifyType.EmotionSolute)
        end
        if (v.IsWin > 0) then
            table.insert(ShowEmoTypeTable, LocalDef.EmotionClassifyType.EmotionWin)
        end
        if (v.IsDraw > 0) then
            table.insert(ShowEmoTypeTable, LocalDef.EmotionClassifyType.EmotionDraw)
        end
        if (v.IsLose > 0) then
            table.insert(ShowEmoTypeTable, LocalDef.EmotionClassifyType.EmotionLose)
        end

        if #ShowEmoTypeTable > 0 then
            local DataTable = {}
            DataTable.EmoClassifyTableID = v.ID
            DataTable.EmotionTableID = v.EmotionID
            DataTable.ShowEmoTypeTable = ShowEmoTypeTable
            DataTable.IsGetted = MajorActiveEmotionIDs[v.EmotionID]
            DataTable.IsDisabled = not MajorActiveEmotionIDs[v.EmotionID]
            DataTable.UIPriority = 0
            local EmoData = EmotionCfg:FindCfgByKey(DataTable.EmotionTableID)
            if (EmoData ~= nil) then
                DataTable.UIPriority = EmoData.UIPriority
            end
            table.insert(self.AllEmoData, DataTable)
        end
    end

    self:UpdateInfoByEmoType(0)
end

function CardsPrepareEmoActPanelVM:ResetAllUsedIcon()
    local VMItemList = self.EmoItemVMList.Items
    for k,v in pairs(VMItemList) do
        v:SetIsUsed(false)
    end
end

--- 通过情感动作的类型更新显示列表
---@param TargetEmoType MagicCardLocalDef.EmotionClassifyType
function CardsPrepareEmoActPanelVM:UpdateInfoByEmoType(TargetEmoType)
    local FilterEmoList = {}
    if TargetEmoType <= 0 then
        FilterEmoList = self.AllEmoData
    else
        for _, EmoData in pairs(self.AllEmoData) do
            local EmoTtypeList = EmoData.ShowEmoTypeTable
            for _, EmoTtype in pairs(EmoTtypeList) do
                if (TargetEmoType == EmoTtype) then
                    table.insert(FilterEmoList, EmoData)
                end
            end
        end
    end
    
    -- 这里先排序下
    table.sort(
        FilterEmoList,
        function(l, r)
            local LDisabled = l.IsDisabled
            local RDisabled = r.IsDisabled

            if (LDisabled and not RDisabled) then
                return false
            end

            if (not LDisabled and RDisabled) then
                return true
            end

            local PriorityL = l.UIPriority or 0
            local PriorityR = r.UIPriority or 0
            if PriorityL == PriorityR then
                return l.EmotionTableID < r.EmotionTableID
            end

            return PriorityL < PriorityR
        end
    )

    self.EmoItemVMList:UpdateByValues(FilterEmoList)
end

-- 要返回当前类
return CardsPrepareEmoActPanelVM
