local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreConvertCfg = require("TableCfg/ScoreConvertCfg")
local LSTR = _G.LSTR

---@class MarketExchangeWinVM : UIViewModel
local MarketExchangeWinVM = LuaClass(UIViewModel)

---Ctor
function MarketExchangeWinVM:Ctor()
	self.ScoreIconID = nil
    self.TargetIconID = nil

    self.ScoreName = nil
    self.TargetName = nil

    self.ScoreNumCount = nil
    self.TargetNumCount = nil

    self.RecommendedInfoVisible = nil
    self.RecommendedInfo = nil

    self.ImgExchangeVisible = nil
    self.BtnExchangeEnabled = nil
    self.ExchangeTitleText = nil
end

function MarketExchangeWinVM:UpdateMV(SourceIcon, TargetIcon, SourceNumCount)
    self.ScoreIconID = SourceIcon
    self.TargetIconID = TargetIcon

    self.ScoreName = ScoreMgr:GetScoreNameText(SourceIcon)
    self.TargetName = ScoreMgr:GetScoreNameText(TargetIcon)

    if TargetIcon == ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE then
        self.ImgExchangeVisible = false
        self.ExchangeTitleText = LSTR(1010018)
    else
        self.ImgExchangeVisible = true
        self.ExchangeTitleText = LSTR(1010019)
    end

    self:SetExchangeValue(SourceNumCount)

    self.BtnExchangeEnabled = ScoreMgr:GetScoreValueByID(MarketExchangeWinVM.ScoreIconID) > 0
end

function MarketExchangeWinVM:SetRecommendedExchange(RecommendedValue)
    self.RecommendedInfoVisible = true
    self.RecommendedInfo = RecommendedValue
    self:SetExchangeValue(RecommendedValue)
end

function MarketExchangeWinVM:HideRecommendedExchange()
    self.RecommendedInfoVisible = false
end

function MarketExchangeWinVM:SetExchangeValue(SourceNumCount)
    self.ScoreNumCount = SourceNumCount

    if self.ScoreIconID == nil or self.TargetIconID == nil then
        return
    end
    
    local SearchConditions = string.format("DeductID = %d and TargetID = %d", self.ScoreIconID, self.TargetIconID)
    local ScoreConvertData = ScoreConvertCfg:FindCfg(SearchConditions)
    if nil ~= ScoreConvertData then
        self.TargetNumCount = self.ScoreNumCount * ScoreConvertData.TargetNum
    end
end


--要返回当前类
return MarketExchangeWinVM