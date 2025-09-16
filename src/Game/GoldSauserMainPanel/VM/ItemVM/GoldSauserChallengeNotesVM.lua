---
--- Author: alex
--- DateTime: 2024-09-10 11:37
--- Description:每周挑战ViewModel 金碟主界面
---
local LuaClass = require("Core/LuaClass")
--local UIViewModel = require("UI/UIViewModel")
local AdventureDailyWeeklyVM = require("Game/Adventure/AdventureDailyWeeklyVM")
local UIBindableList = require("UI/UIBindableList")
local GoldSauserChallengeNoteItemVM = require("Game/GoldSauserMainPanel/VM/ItemVM/GoldSauserChallengeNoteItemVM")
local ProtoRes = require("Protocol/ProtoRes")

local AdventureMgr = require("Game/Adventure/AdventureMgr")
local RichTextUtil = require("Utils/RichTextUtil")
local JumpUtil = require("Utils/JumpUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")

local challenge_log_category = ProtoRes.challenge_log_category
local EToggleButtonState = _G.UE.EToggleButtonState
local LSTR = _G.LSTR

local GoldSauserChallengeNotesVM = LuaClass(AdventureDailyWeeklyVM)

---Ctor
function GoldSauserChallengeNotesVM:Ctor()
    self.ItemList = UIBindableList.New(GoldSauserChallengeNoteItemVM)
end

--- 更新笔记列表数据
function GoldSauserChallengeNotesVM:UpdateAllNoteItemList()
    local ItemList = self.ItemList
    if not ItemList then
        return
    end
    ItemList:Clear()

    local Logs = AdventureMgr:GetCategoryChallengeLogs(challenge_log_category.CHALLENGE_LOG_CATEGORY_GOLDSAUCER) -- 挑战笔记功能为在VM中调用Mgr内容，故延用相同逻辑
    table.sort(Logs, self.SortWeeklyLogPredicate)
    for _, Log in pairs(Logs) do
        local TParams = {
            ID = Log.LogID,
            OnClickGet = self.OnClickGetHandle,
            OnClickGo = self.OnClickGoHandle,
            ContentText = Log.Desc,
            MainIconPath = Log.Icon,
        }

        
        if Log.Collected then
            TParams.DescriptionText = RichTextUtil.GetText(LSTR(350035), "b56728ff")
        else
            TParams.DescriptionText = RichTextUtil.GetText(string.format(LSTR(350036), Log.Progress, Log.Total), "6c6964ff")
        end

        if Log.Collected then
            TParams.ToggleBtnState = EToggleButtonState.Locked
            TParams.DisabledText = LSTR(350037)
        else
            if Log.IsFinish then
                TParams.ToggleBtnState = EToggleButtonState.Unchecked
            else
                if Log.JumpID and JumpUtil.IsCurJumpIDCanJump(Log.JumpID) then
                    TParams.ToggleBtnState = EToggleButtonState.Checked
                else
                    TParams.ToggleBtnState = EToggleButtonState.Locked
                    TParams.DisabledText = LSTR(350038)
                end
            end
        end

        local RewardItemList = Log.RewardItemList
        if RewardItemList and next(RewardItemList) then
            local RewardList = {}
            for _, Reward in ipairs(RewardItemList) do
                local ItemParams = {
                    NumText = "",
                    IsMaskVisible = false,
                    IconPath = "",
                    Num = Reward.Num or 0
                }
    
                local ItemIconID = ItemUtil.GetItemIcon(Reward.ResID)
                if ItemIconID ~= 0 then
                    ItemParams.IconPath = UIUtil.GetIconPath(ItemIconID)
                end
                ItemParams.ResID = Reward.ResID
                ItemParams.NumText = _G.ScoreMgr.FormatScore(Reward.Num) or ""
                ItemParams.IsMaskVisible = Log.Collected
                table.insert(RewardList, ItemParams)
            end
            TParams.RewardList = RewardList
        end
        ItemList:AddByValue(TParams)
    end
end

--- 更新笔记列表数据
function GoldSauserChallengeNotesVM:UpdateNoteItemCollected(LogID)
    local ItemList = self.ItemList
    if not ItemList then
        return
    end
   
    local TargetItemVM = ItemList:Find(function(e)
        return e.ID == LogID
    end)

    if not TargetItemVM then
        return
    end
    TargetItemVM.DescriptionText = RichTextUtil.GetText(LSTR(350035), "b56728ff")
    TargetItemVM.ToggleBtnState = EToggleButtonState.Locked
    TargetItemVM.DisabledText = LSTR(350037)

    local RewardList = TargetItemVM.RewardList
    if not RewardList then
        return
    end

    for Index = 1, RewardList:Length() do
        local RewardItemVM = RewardList:Get(Index)
        if RewardItemVM then
            RewardItemVM.IsMaskVisible = true
        end
    end
end

return GoldSauserChallengeNotesVM