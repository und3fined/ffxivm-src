local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local DateTimeTools = require("Common/DateTimeTools")
local TimeUtil = require("Utils/TimeUtil")

---@class HouseLandListWinItemVM : UIViewModel
local HouseLandListWinItemVM = LuaClass(UIViewModel)

---Ctor
function HouseLandListWinItemVM:Ctor()
    self.Index = nil
    self.IsCollect = nil
    self.IconLandSales = nil
    self.TextHouseLand = nil
    self.TextBuyType = nil
    self.IconMoney = nil
    self.ResidenceNumber = nil
    self.AreaNumber = nil
    self.LandNumber = nil
    self.SubAreaNumber = nil

    self.PhaseTypeStr = ""
    self.PhaseTimeStr = ""
    self.ReadyEndTime = 0
    self.PhaseEndTime = 0
end

function HouseLandListWinItemVM:UpdateVM(Params)
    self.WidgetClassIndex = Params.WidgetClassIndex
    if Params.WidgetClassIndex == 0 then
        self.ReadyEndTime = Params.ReadyEndTime
        self.PhaseEndTime = Params.PhaseEndTime
        self.PhaseTypeStr = HouseLocalDef.LandListPhaseTypeStr[Params.LandStatu]
        local PhaseTimeStr = ""
        if Params.LandStatu == ProtoCS.LandStatusType.LandStatusType_Ready then
            local TimeStr = TimeUtil.GetTimeFormat("%Y/%m/%d %H:%M", self.ReadyEndTime)
            PhaseTimeStr = string.format(HouseLocalDef.LandListPhaseTimeStr[1], TimeStr)
        else
            local ServerTime = TimeUtil.GetServerTime()
            local LeftTime = self.PhaseEndTime - ServerTime
            local TimeStr = DateTimeTools.TimeFormat(LeftTime, "dd:hh", true)
            PhaseTimeStr = string.format(HouseLocalDef.LandListPhaseTimeStr[2], TimeStr)
        end
        self.PhaseTimeStr = PhaseTimeStr
    elseif Params.WidgetClassIndex == 1 then
        self.ResidenceNumber = Params.ResidenceNumber
        self.AreaNumber = Params.AreaNumber
        self.SubAreaNumber = Params.SubAreaNumber
        self.LandNumber = Params.LandNumber
        self.IsCollect = Params.IsCollect
        self.IconLandSales = string.format(HouseLocalDef.LandStatuIconPath, Params.LandStatus, Params.LandStatus)
        self.TextHouseLand = string.format(HouseLocalDef.LocalTxtStr.LandListInfoTxt, Params.AreaNumber,
            HouseLocalDef.SubAreaTypeStr[Params.SubAreaNumber].Name, Params.LandNumber,
            HouseLocalDef.LandSizeTypeStr[Params.LandSize])
        self.TextBuyType = HouseLocalDef.LandBuyTabTypeStr[Params.BuyType + 1].Name
        self.IconMoney = _G.ScoreMgr:GetScoreIconName(Params.MoneyType)
    end
end

function HouseLandListWinItemVM:AdapterOnGetWidgetIndex()
    return self.WidgetClassIndex or 0
end

function HouseLandListWinItemVM:IsEqualVM(Value)
    return false
end

function HouseLandListWinItemVM:CollectLand()
    _G.HouseLandMgr:SendCollectLandReq(self.ResidenceNumber, self.AreaNumber, self.LandNumber, not self.IsCollect)
    self.IsCollect = not self.IsCollect
end

return HouseLandListWinItemVM
