local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FishDefine = require("Game/Fish/FishDefine")
local TimeUtil = require("Utils/TimeUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local FishIngholeBaitsVM = require("Game/FishNotes/ItemVM/FishIngholeBaitsVM")

---@class FishReleaseTipVM : UIViewModel
local FishReleaseTipVM = LuaClass(UIViewModel)

local TrueReleaseText = FishDefine.FishNewItemTipsText.TrueReleaseText
local FalseReleaseText = FishDefine.FishNewItemTipsText.FalseReleaseText

function FishReleaseTipVM:Ctor()
    self.ReleaseFishID = nil
    self.ReleaseFishName = ""
    self.ReleaseFishLevel = 0
    self.ReleaseFishText = ""
    self.TextState = ""
    self.FishTime = ""
    self.FishTimePercent = 0
    self.bFishWindowBarVisible = false
    self.IsAutoRelease = false
    self.BtnText = ""
    self.AutoReleaseIndex = 0 -- 自动放生功能是否解锁，暂时默认解锁，因此未使用
    self.bIsknown = true
    self.bHasFish = false
    self.BaitsInfo = FishIngholeBaitsVM.New()
end

function FishReleaseTipVM:UpdateReleaseFishData(Item)
    if Item then
        self.ReleaseFishID = Item.ResID
        self.ReleaseFishName = Item.Name
        self.ReleaseFishLevel = Item.FishLevel
        local LevelText = string.format(FishDefine.FishNewItemTipsText.TextLevel, self.ReleaseFishLevel)
        self.ReleaseFishText = string.format("%s %s", self.ReleaseFishName, LevelText)
        self.IsAutoRelease = Item.IsFishLoop
        if Item.FishNum == 0 then
            self.bHasFish = false
        else
            self.bHasFish = true
        end
        self.bIsknown = not Item.IsUnknown

        local Fish = _G.FishNotesMgr:GetFishDataByItemID(Item.ResID)
        if Fish then
            self:RefreshFishTime(Fish)
            self:RefreshFishBait(Fish.Cfg)
        end
    end
    if self.IsAutoRelease then
        self.BtnText = TrueReleaseText
    else
        self.BtnText = FalseReleaseText
    end
    if not self.bIsknown then
        self.ReleaseFishName = "???"
    end
end

function FishReleaseTipVM:UpdateAutoRelease()
    self.IsAutoRelease = not self.IsAutoRelease
    if self.IsAutoRelease then
        self.BtnText = TrueReleaseText
    else
        self.BtnText = FalseReleaseText
    end
end

function FishReleaseTipVM:RefreshFishTime(Fish)
    if Fish == nil then
        return
    end
    local TimeCondition = Fish.TimeCondition and Fish.TimeCondition[1]
    if Fish.WeatherCondition == nil and TimeCondition == nil then
        --全天可钓
        self.TextState = _G.LSTR(180042)--"全天可钓"
        self.FishTime = ""
        self.bFishWindowBarVisible = false
    else
        local Begin, End = _G.FishNotesMgr:GetFishNeasetWindowTime(Fish.Cfg.ID, _G.FishMgr.AreaID)
        if Begin ~= nil and End ~= nil then
            local Now = TimeUtil.GetServerTime()
            local bActive = Now >= Begin and Now < End
            if bActive then
                --活跃中
                local TotalWindowTime = End - Begin
                local LeftTime = End - Now
                self.TextState = _G.LSTR(180066)--"活跃中"
                self.FishTime = LocalizationUtil.GetCountdownTimeForLongTime(LeftTime)
                self.FishTimePercent = LeftTime / TotalWindowTime
                self.bFishWindowBarVisible = true
            else
                --休眠期
                local RemainSeconds = Begin - Now
                self.TextState = _G.LSTR(180067)--"休眠期"
                self.FishTime =  LocalizationUtil.GetCountdownTimeForLongTime(RemainSeconds)
                self.bFishWindowBarVisible = false
            end
        else
            --暂不出现
            self.TextState = _G.LSTR(180068)--"暂不出现"
            self.FishTime = ""
            self.bFishWindowBarVisible = false
        end
    end
end

function FishReleaseTipVM:RefreshFishBait(Fish)
    local BaitsList, _ = _G.FishNotesMgr:GetAllBaitData(Fish, _G.FishMgr.AreaID)
    --钓饵链
    if not table.is_nil_empty(BaitsList) then
        self.BaitsInfo:UpdateVM(BaitsList, Fish, _G.FishMgr.AreaID)
    end
end

return FishReleaseTipVM