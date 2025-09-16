
local LuaClass = require("Core/LuaClass")
local EntranceBase = require("Game/Interactive/EntranceItem/EntranceBase")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsID = require("Define/MsgTipsID")
local QuestHelper = require("Game/Quest/QuestHelper")

local EntranceNpcQuest = LuaClass(EntranceBase)

--计算Distance、入口的显示字符串
function EntranceNpcQuest:OnInit(FunctionItem)
    self.FunctionItem = FunctionItem
    if nil ~= self.FunctionItem then
        self.DisplayName = self.FunctionItem.DisplayName
        self.QuestID = self.FunctionItem.QuestID
    else
        self.DisplayName = ""
        self.QuestID = nil
    end
end

function EntranceNpcQuest:OnUpdateDistance()
end

--Entrance的响应逻辑
function EntranceNpcQuest:OnClick()
    -- 战斗状态下不支持交互操作
    -- if MajorUtil.IsMajorCombat() == true then
    --     _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.CombatStateCantInteraction)
    --     return
    -- end

    -- 检查主角当前的状态是否可以进行交互操作
    if not _G.InteractiveMgr:IsCanDoBehavior() then
        return
    end
    
    if self.FunctionItem and self.FunctionItem.ResID then
        local EObjQuestParams = _G.QuestMgr:GetEObjQuestParamsList(self.FunctionItem.ResID)
        if EObjQuestParams and EObjQuestParams[1] and not QuestHelper.CheckLootItems(EObjQuestParams[1].QuestID, EObjQuestParams[1].TargetID) then
            QuestHelper.PlayRestrictedDialog(EObjQuestParams[1].QuestID, EObjQuestParams[1].TargetID)
            return
        end
    end
    
    --直接执行二级交互项的功能
    if nil ~= self.FunctionItem then
        self.FunctionItem:Click()
    end
end

function EntranceNpcQuest:CheckInterative(EnableCheckLog)
    return true
end

function EntranceNpcQuest:OnGenFunctionList()
    return {}
end

---GetIconPath
---@return string
function EntranceNpcQuest:GetIconPath()
    if nil ~= self.FunctionItem then
        return self.FunctionItem.IconPath
    end
    return nil
end

return EntranceNpcQuest
