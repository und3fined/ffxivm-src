---
--- Author: Leo
--- DateTime: 2023-03-29 11:18:17
--- Description: 采集笔记系统
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local JumboCactpotBoughtNumVM = require("Game/JumboCactpot/ItemVM/JumboCactpotBoughtNumVM")
local JumboCactpotBuffLItemVM = require("Game/JumboCactpot/ItemVM/JumboCactpotBuffLItemVM")
local JumboCactpotBuffRItemVM = require("Game/JumboCactpot/ItemVM/JumboCactpotBuffRItemVM")
local JumboCactpotGetRewardItemVM = require("Game/JumboCactpot/ItemVM/JumboCactpotGetRewardItemVM")
local JumboCactpotResumMiddleItemVM = require("Game/JumboCactpot/ItemVM/JumboCactpotResumMiddleItemVM")
local JumboCactpotResumDianItemVM = require("Game/JumboCactpot/ItemVM/JumboCactpotResumDianItemVM")
local JumboCactpotLottoryNameItemVM = require("Game/JumboCactpot/ItemVM/JumboCactpotLottoryNameItemVM")
local JumboCactpotTipsItemVM = require("Game/JumboCactpot/ItemVM/JumboCactpotTipsItemVM")
local JumbCactpotRewardBounsNewVM = require("Game/JumboCactpot/JumbCactpotRewardBounsNewVM")

local JumboCactpotVM = LuaClass(UIViewModel)

---Ctor
function JumboCactpotVM:Ctor()

end

function JumboCactpotVM:OnInit()
    self.NeedConsumptPrice = ""
    self.PriceColor = "#313131"
    self.RemainPurchases = 0
    self.XCTickExchangeNums = ""
    self.OwnJDNum = 0
    self.XCTicksNum = 0
    self.RemainLotteryTime = ""
    self.bBoughtMany = false
    self.bNoTime = false
    self.bReaminTime = true
    self.bBoughtMany = false

    self.BoughtNumberList = UIBindableList.New(JumboCactpotBoughtNumVM)
    self.PlateBoughtList = UIBindableList.New(JumboCactpotBoughtNumVM)
    self.GetRewardList = UIBindableList.New(JumboCactpotGetRewardItemVM)
    self.ResumeMiddleList = UIBindableList.New(JumboCactpotResumMiddleItemVM)
    self.ResumeDianList = UIBindableList.New(JumboCactpotResumDianItemVM)
    self.LottoryNameList = UIBindableList.New(JumboCactpotLottoryNameItemVM)
    self.TipsList = UIBindableList.New(JumboCactpotTipsItemVM)
    self.RewardBounsVM = JumbCactpotRewardBounsNewVM.New()

    -- JumboInfo
    self.BuyCountText = ""
    self.BuyCountVisible = true
    
    self.XCTickNumText = ""
    self.XCTickNumVisible = true

    self.RemainTimeText = ""
    self.RemainTimeVisible = false

    self.InfoDescText = ""
end

function JumboCactpotVM:OnBegin()

end

function JumboCactpotVM:UpdateVM(Value)

end

function JumboCactpotVM:OnShutdown()

end

function JumboCactpotVM:OnEnd()

end

--- @type 更新列表
--- @param
function JumboCactpotVM:UpdateList(List, Data)
    if List == nil then
        return
    end

    if Data[1] == nil then
        List:Clear()
        return
    end

    if nil ~= List and List:Length() > 0 then
        List:Clear()
    end

    List:UpdateByValues(Data)
end

return JumboCactpotVM