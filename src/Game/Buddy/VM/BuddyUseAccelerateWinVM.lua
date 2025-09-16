local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local BagMgr = require("Game/Bag/BagMgr")
local DateTimeTools = require("Common/DateTimeTools")
local RichTextUtil = require("Utils/RichTextUtil")
local ScoreCfg = require("TableCfg/ScoreCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreMgr = require("Game/Score/ScoreMgr")
local BuddyFeedCfg = require("TableCfg/BuddyFeedCfg")

local BuddyMgr

---@class BuddyUseAccelerateWinVM : UIViewModel
local BuddyUseAccelerateWinVM = LuaClass(UIViewModel)

---Ctor
function BuddyUseAccelerateWinVM:Ctor()
    BuddyMgr = _G.BuddyMgr
    self.AccelerateProgressPercent = nil
    self.NormalProgressPercent = nil
    self.AccelerateTimeText = nil
    self.CDTimeText = nil
    self.ItemDesc = nil
    
    self.UseCoinVisible = nil
    self.UseCoinDescText = nil
    self.ItemVM = ItemVM.New()

    self.TriggerEnabled = nil
    self.BtnaccelerateEnabled = nil

    self.Trigger = false
    self.TriggerCheck = self.Trigger
    self.NeedRefresh = false
    self.NeedItemNum = nil
    self.EFFVisible = nil
    self.Icon = nil
end

function BuddyUseAccelerateWinVM:UpdateVM()
    self.Item = ItemUtil.CreateItem(BuddyMgr.AccelerateItemID)
    self.Trigger = false
    self.TriggerCheck = self.Trigger
    self.NeedRefresh = true
    self:UpdateAccelerateProgress()
end

function BuddyUseAccelerateWinVM:UpdateAccelerateProgress()
    local PerAccelerateTime = self:GetItemAccelerateTime()
    local LetfTime = BuddyMgr:GetSurfaceCDTime()
    self.CDTimeText = DateTimeTools.TimeFormat(LetfTime, "hh:mm:ss", false)

    self.NormalProgressPercent = (BuddyMgr.DyeCDTime - LetfTime)/BuddyMgr.DyeCDTime

    local NeedNum = math.ceil(LetfTime/PerAccelerateTime)
    self.NeedItemNum = NeedNum
    if self.Item.Num ~= NeedNum or self.NeedRefresh == true then
        self.Item.Num = NeedNum
        self.ItemVM:UpdateVM(self.Item, {IsShowNumProgress = true})
        local Num = BagMgr:GetItemNum(BuddyMgr.AccelerateItemID)
        self.UseCoinVisible = NeedNum > Num
        if NeedNum > Num then
            if self.Trigger == true then
                self.AccelerateTimeText = DateTimeTools.TimeFormat(NeedNum * PerAccelerateTime, "hh:mm:ss", false)
                self.AccelerateProgressPercent = 1
                self.EFFVisible = true
            else
                self.AccelerateTimeText = DateTimeTools.TimeFormat(Num * PerAccelerateTime, "hh:mm:ss", false)
                self.AccelerateProgressPercent = self.NormalProgressPercent + Num * PerAccelerateTime/BuddyMgr.DyeCDTime
                self.EFFVisible = false
            end
            
            self.ItemDesc = string.format(_G.LSTR(1000010), ItemUtil.GetItemName(BuddyMgr.AccelerateItemID))
            self.UseCoinDescText = self:GetUseCoinDescText(NeedNum - Num)

            if Num > 0 then
                self.BtnaccelerateEnabled = true
            end
        else
            self.AccelerateTimeText = DateTimeTools.TimeFormat(NeedNum * PerAccelerateTime, "hh:mm:ss", false)
            self.ItemDesc = ItemUtil.GetItemName(BuddyMgr.AccelerateItemID)
            self.AccelerateProgressPercent = 1
            self.Trigger = false
            self.EFFVisible = true
            self.BtnaccelerateEnabled = true
        end
        self.NeedRefresh = false
    end
    

end

function BuddyUseAccelerateWinVM:GetUseCoinDescText(Num)
    local ScoreID, ScoreExchangeNum = self:GetItemAccelerateCoin()
    local ScoreInfo = ScoreCfg:FindCfgByKey(ScoreID)

    self.Icon = ScoreInfo.IconName
    
    local NumColor = "d1ba8e"
    self.TriggerEnabled = true
    self.BtnaccelerateEnabled = true
    local CoinNum = Num * ScoreExchangeNum
    if ScoreMgr:GetScoreValueByID(ScoreID) < CoinNum then
        NumColor = "dc5868"
        self.TriggerEnabled = false
        self.BtnaccelerateEnabled = false
    end
	local NumRichText = RichTextUtil.GetText(string.format("%d", CoinNum), NumColor, 0, nil)
    return string.format("%s%s",  NumRichText,_G.LSTR(1000011))
end

function BuddyUseAccelerateWinVM:GetItemAccelerateTime()
    local SearchConditions = string.format("ItemID = %d", BuddyMgr.AccelerateItemID)
	local Cfg = BuddyFeedCfg:FindCfg(SearchConditions)
    if Cfg and  Cfg.Func[1] then
        if Cfg.Func[1].Type == ProtoRes.BuddyFuncType.BuddyFuncTypeReduceCD then
            return Cfg.Func[1].Value[1]
        end
    end
    return 3600
end

function BuddyUseAccelerateWinVM:GetItemAccelerateCoin()
    local SearchConditions = string.format("ItemID = %d", BuddyMgr.AccelerateItemID)
	local Cfg = BuddyFeedCfg:FindCfg(SearchConditions)
    if Cfg then
        return Cfg.DeductScoreType, Cfg.DeductScoreNum
    end
    return ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE, 500
end



function BuddyUseAccelerateWinVM:ChangeUseCoinTrigger()
    self.Trigger = not self.Trigger
    self.TriggerCheck = self.Trigger

    self.NeedRefresh = true
end

function BuddyUseAccelerateWinVM:SetCDOnTime()
	self:UpdateAccelerateProgress()
end


--要返回当前类
return BuddyUseAccelerateWinVM