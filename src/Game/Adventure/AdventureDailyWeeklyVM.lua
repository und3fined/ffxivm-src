local LuaClass = require("Core/LuaClass")
local AdventureBaseVM = require("Game/Adventure/AdventureBaseVM")
local AdventureItemVM = require("Game/Adventure/ItemVM/AdventureItemVM")
local AdventureMgr = require("Game/Adventure/AdventureMgr")
local RichTextUtil = require("Utils/RichTextUtil")
local UIUtil = require("Utils/UIUtil")
local JumpUtil = require("Utils/JumpUtil")
local ItemUtil = require("Utils/ItemUtil")
local AdventureDefine = require("Game/Adventure/AdventureDefine")
local ScoreCfg = require("TableCfg/ScoreCfg")
local UIBindableList = require("UI/UIBindableList")
local LSTR = _G.LSTR
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local PWorldEntPolDR = require("Game/PWorld/Entrance/Policy/PWorldEntPolDR")
local ProfUtil = require("Game/Profession/ProfUtil")
local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")

local PWorldMatchMgr = _G.PWorldMatchMgr
local AdventureDailyWeeklyVM = LuaClass(AdventureBaseVM)

---Ctor
function AdventureDailyWeeklyVM:Ctor()
    self.ItemList = UIBindableList.New(AdventureItemVM)
    self.PrograssText = nil
    self.DescriptionText = nil
    self.IsEffectStateVisible = nil
    self.IsEmptyVisible = false
    self.Type = nil
    self.ItemListVisible = false
    self.EmptyText = nil
    self.ReceiveTipsVisible = false
end

function AdventureDailyWeeklyVM:SetCurType(Type)
    self.Type = Type
end

function AdventureDailyWeeklyVM:GetSurplusTime()
    if self.Type and self.Type == AdventureDefine.MainTabIndex.Daily then
        return AdventureMgr:GetDailyRefreshSurplusTime()
    else
        return AdventureMgr:GetWeeklyRefreshSurplusTime()
    end
end

function AdventureDailyWeeklyVM:SetDiffByType()
    if self.Type and self.Type == AdventureDefine.MainTabIndex.Daily then
        local List = {}
        local Cfgs = AdventureMgr:GetSceneEnterDailyRandomData()
    
        for _, Cfg in pairs(Cfgs) do
            table.insert(List, Cfg.ID)
        end
    
        PWorldMatchMgr:SubLackProfUpd(self, List)
    end
end

---更新周任务右上角宝箱奖励领取状态
function AdventureDailyWeeklyVM:UpdateWeeklyRewardStatus()
    local HasRewardCanCollect = AdventureMgr:IsStageRewardCanGet()
  
    if HasRewardCanCollect then
        self.DescriptionText = LSTR(520013)
        self.PrograssText = ""
        self.IsEffectStateVisible = true
    else
        local FinishCount = AdventureMgr:GetFinishCount() or 0
        if FinishCount >= AdventureMgr:GetMaxFinishCount() then
            self.DescriptionText = LSTR(520023)
            self.PrograssText = ""
        else
            self.DescriptionText = ""
            self.PrograssText = string.format("%d/%d", AdventureMgr:GetFinishCount(), AdventureMgr:GetMaxFinishCount())
        end

        self.IsEffectStateVisible = false
    end
end

function AdventureDailyWeeklyVM:SetWeeklyItemData(Params)
    local Log = self:FindLog(AdventureMgr:GetChallengeOriginLogs(), Params.ID)
    if Log then
        Params.ContentText = Log.Desc
        Params.UnFinishText = LSTR(520036)
        Params.MainIconPath = Log.Icon

        if Log.Collected then
            Params.DescriptionText = LSTR(520021)
        else
            Params.DescriptionText = string.format(LSTR(520024), string.format("%d/%d", Log.Progress, Log.Total))
        end

        if Log.Collected then
            Params.IsUnFinishVisible = true
            Params.UnFinishText = LSTR(520022)
        else
            if Log.IsFinish then
                Params.IsBtnGetVisible = true
                Params.BtnGetText = LSTR(520055)
            else
                if Log.JumpID and JumpUtil.IsCurJumpIDCanJump(Log.JumpID) then
                    Params.IsBtnGoVisible = true
                else
                    Params.IsUnFinishVisible = true
                end
            end
        end

        local RewardList = {
            {
                IsShowProgressPoint = true,
                IsMaskVisible = Log.Collected
            }
        }
    
        for i = 1,#Log.RewardItemList do
            local Produce = Log.RewardItemList and Log.RewardItemList[i] or {}
            local ItemParams = {
                NumText = "",
                IsMaskVisible = false,
                IconPath = "",
                Num = Produce.Num
            }

            if next(Produce) then
                local ItemIconID = ItemUtil.GetItemIcon(Produce.ResID)
                if ItemIconID ~= 0 then
                    ItemParams.IconPath = UIUtil.GetIconPath(ItemIconID)
                end
                ItemParams.ResID = Produce.ResID
                ItemParams.NumText = _G.ScoreMgr.FormatScore(Produce.Num)
                ItemParams.IsMaskVisible = Log.Collected
            end

            table.insert(RewardList, ItemParams)
        end

        Params.RewardList = RewardList
    end
end

function AdventureDailyWeeklyVM:SetDailyTaskItem(i, Cfg)
    local ProfIcon = ProfUtil.LackProfFunc2Icon(PWorldMatchMgr:GetLackProfFunc(Cfg.ID))
    local TypeCfg = SceneEnterTypeCfg:FindCfgByKey(Cfg.TypeID)
    local Params = {
        Type = AdventureDefine.MainTabIndex.Daily,
        ID =  Cfg.ID,
        ContentText = AdventureDefine.DailyPwordContent[Cfg.ID] and string.format(LSTR(AdventureDefine.DailyPwordContent[Cfg.ID]), Cfg.Name) or Cfg.Name,
        IsBtnGoVisible = true,
        IsUnFinishVisible = false,
        BtnGoText = LSTR(520008),
        UnFinishText = LSTR(520019),
        MainIconPath = TypeCfg.Icon or "",
        IsNew = false,
        IsDescriptionVisible = true,
        OnClickGo = self.OnClickGoHandle
    }

    local LimitNum = _G.CounterMgr:GetCounterLimit(Cfg.Counter)
    local CurNum = _G.CounterMgr:GetCounterCurrValue(Cfg.Counter)
    if CurNum and LimitNum then
        Params.DescriptionText = string.format(LSTR(520038), CurNum, LimitNum)
    end

    if AdventureMgr:IsCurTabNotRead(AdventureDefine.MainTabIndex.Daily) then
        Params.IsNew = true
    else
        local AdventureRedData = AdventureMgr:GetAdventureTaskSaveData()
        if not AdventureRedData.DailyTaskRecord or not  string.find(AdventureRedData.DailyTaskRecord, Cfg.ID) then
            Params.IsNew = true
        end
    end

    local RewardList = {}
    local Rewards = PWorldEntPolDR:GetRewardData(Cfg)
    for i, v in ipairs(Rewards) do
        local RewardParams = {
            NumText = "",
            IsMaskVisible = v.HasGot,
            ResID = v.ID,
            DateText = v.ShowTipDaily and LSTR(520037) or "",
            IsJobVisible = v.LackFunc and true or false,
            JobIconPath = ProfIcon,
        }

        local ItemIconID = ItemUtil.GetItemIcon(v.ID)
        if ItemIconID ~= 0 then
            RewardParams.IconPath = UIUtil.GetIconPath(ItemIconID)
        end

        table.insert(RewardList, RewardParams)
    end
  
    Params.RewardList = RewardList
    return Params
end

function AdventureDailyWeeklyVM:GetWeeklyListData()
    local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
    RedDotMgr:DelRedDotByID(AdventureDefine.RedDefines.WeekUnLockRed)

    local Temp = AdventureMgr:GetChallengeLogs()
    local ChallengeLogs = {}
    for _,Log in pairs(Temp) do
        table.insert(ChallengeLogs, Log)
    end

    self.IsEmptyVisible = #ChallengeLogs == 0
    self.ReceiveTipsVisible = true
    self.EmptyText = LSTR(520031)
    local ItemListData = {}
    if not next(ChallengeLogs) then 
        self.ItemListVisible = false
    else
        self.ItemListVisible = true
        table.sort(ChallengeLogs, self.SortWeeklyLogPredicate)
        local IsNew = AdventureMgr:IsCurTabNotRead(AdventureDefine.MainTabIndex.Weekly)
        for i, Log in ipairs(ChallengeLogs) do
            local Params = {
                ID = Log.LogID,
                OnClickGet = self.OnClickGetHandle,
                OnClickGo = self.OnClickGoHandle,
                IsNew = IsNew,
                IsDescriptionVisible = true,
                Type = AdventureDefine.MainTabIndex.Weekly,
                BtnGoText = LSTR(520008),
            }

            self:SetWeeklyItemData(Params)
            table.insert(ItemListData, Params)
        end
    end

    self:UpdateWeeklyRewardStatus()
    return ItemListData
end

function AdventureDailyWeeklyVM:GetDailyListData()
    local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
    RedDotMgr:DelRedDotByID(AdventureDefine.RedDefines.DailyUnLockRed)
    local DailyTaskData = AdventureMgr:GetSceneEnterDailyTask()
    local ItemListData = {}
    self.IsEmptyVisible = #DailyTaskData == 0
	self.EmptyText = LSTR(520032)
    self.ReceiveTipsVisible = false
    if not next(DailyTaskData) then 
        self.ItemListVisible = false
    else
        self.ItemListVisible = true
        table.sort(DailyTaskData, self.SortDailyListPredicate)
        for i, v in ipairs(DailyTaskData) do
            table.insert(ItemListData, self:SetDailyTaskItem(i, v))
        end
    end

    return ItemListData
end

function AdventureDailyWeeklyVM:GetCurTypeListData()
    if self.Type and self.Type == AdventureDefine.MainTabIndex.Daily then
        return self:GetDailyListData()
    else
        return self:GetWeeklyListData()
    end
end

function AdventureDailyWeeklyVM:FindLog(ChallengeLogs, ID)
    if ChallengeLogs == nil then
        return
    end

    return ChallengeLogs[ID]
end

---日随排序
function AdventureDailyWeeklyVM.SortDailyListPredicate(Left, Right)
    local LeftCollected = PWorldMatchMgr:HasDailyRewardRecv(Left.ID)
    local RightCollected = PWorldMatchMgr:HasDailyRewardRecv(Right.ID)

    local LeftScore = Left.Priority
    if LeftCollected then
        LeftScore = LeftScore + 10000
    end
    
    local RightScore = Right.Priority
    if RightCollected then
        RightScore = RightScore + 10000
    end
    return LeftScore < RightScore
end

---周任务排序 可领取>不可领取>已领取
function AdventureDailyWeeklyVM.SortWeeklyLogPredicate(Left, Right)
    local LeftScore = Left.LogID
    if Left.IsFinish then
        LeftScore = LeftScore + (Left.Collected and 10000 or -10000)
    else
        if Left.Collected then
            LeftScore = LeftScore + 10000
        end
    end

    local RightScore = Right.LogID
    if Right.IsFinish then
        RightScore = RightScore + (Right.Collected and 10000 or -10000)
    else
        if Right.Collected then
            RightScore = RightScore + 10000
        end
    end

    return LeftScore < RightScore
end

function AdventureDailyWeeklyVM:OnClickGetHandle(ID)
    local Cfg = AdventureMgr:GetChallengeOriginLogs()
    local Log = Cfg and Cfg[ID] or {}
    local RewardList = Log.RewardItemList or {}
    local NeedConfirm = false
    local ScoreInfo = {}
    if next(RewardList) then
        for i, v in ipairs(RewardList) do
            if AdventureDefine.ScoreLimitCheck[v.ResID] then
                ScoreInfo = ScoreCfg:FindCfgByKey(v.ResID)
                local Num = _G.ScoreMgr:GetScoreValueByID(v.ResID)
                if Num >= ScoreInfo.MaxValue then
                    NeedConfirm = true
                    break
                end
            end
        end
    end

    local function Callback()
        AdventureMgr:SendChallengelogCollect(ID)
	end

    if NeedConfirm then
        _G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(520029), string.format(LSTR(520003), ScoreInfo.NameText or ""), Callback, nil, LSTR(520012), LSTR(520041))
    else
        Callback()
    end
end

function AdventureDailyWeeklyVM:OnClickGoHandle(ID)
    if self.Type == AdventureDefine.MainTabIndex.Daily then
        PWorldEntUtil.ShowPWorldEntViewDR(ID)
    else
        local Cfg = AdventureMgr:GetChallengeOriginLogs()
        local Log = Cfg and Cfg[ID] or {}
        JumpUtil.JumpTo(Log.JumpID)
    end
end

function AdventureDailyWeeklyVM:IsNeedUpdateTime()
    return true
end

function AdventureDailyWeeklyVM:HideClearData()
    if self.Type == AdventureDefine.MainTabIndex.Daily then
        AdventureMgr:SaveDailyTaskNum()
        PWorldMatchMgr:UnSubLackProfUpd(self)
    end

    AdventureMgr:SetAdventureReadTimeByIndex(self.Type)
    local NewRedData = AdventureDefine.TabNewRed
    if NewRedData[self.Type] and NewRedData[self.Type].Child then
        local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
        RedDotMgr:DelRedDotByID(NewRedData[self.Type].Child)
    end

    self.Type = nil
end

function AdventureDailyWeeklyVM:UpdateDailyRewardShow(Data)
    for i, v in ipairs(Data) do
        local Result = self.ItemList:Find(function(Element)
            return Element.ID == v.ID
        end)

        if Result then
            Result:SetRewardData(v.RewardList)
        end
    end
end

return AdventureDailyWeeklyVM