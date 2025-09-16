---
--- Author: sammrli
--- DateTime: 2023-09-14 15:46
--- Description:金蝶游乐场主界面ViewModel
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local GateScoreItemVM = require("Game/Gate/View/Item/VM/GateScoreItemVM")
local GateLampItemVM = require("Game/Gate/View/Item/VM/GateLampItemVM")
local TimeUtil = require("Utils/TimeUtil")

---@class GateMainVM : UIViewModel
---@field LeftScore UIBindableList
---@field BottomScore UIBindableList
---@field KindNumList table<number>
local GateMainVM = LuaClass(UIViewModel)

function GateMainVM:Ctor()
    self.LeftScore = UIBindableList.New(GateScoreItemVM)
    self.BottomScore = UIBindableList.New(GateLampItemVM)
    self.KindNumList = {}
    self.Score = 0
    self.IsGameRunning = false
    self.LastSetScoreTime = nil
end

function GateMainVM:ResetData()
    self.KindNumList = {}
    self.Score = 0
    self.IsGameRunning = false
    self.LastSetScoreTime = nil

    local LampItemList = {}
    for i=1,4 do
        local VM = GateLampItemVM.New()
        table.insert(LampItemList, VM)
    end
    self.BottomScore:UpdateByValues(LampItemList)

    local ScoreItemList = {}
    for i=1,4 do
        local VM = GateScoreItemVM.New()
        table.insert(ScoreItemList, VM)
    end
    self.LeftScore:UpdateByValues(ScoreItemList)
end

function GateMainVM:AddKindNum(Kind)
    local KindNum = self.KindNumList[Kind]
    if KindNum then
        self.KindNumList[Kind] = KindNum + 1
    else
        self.KindNumList[Kind] = 1
    end
end

function GateMainVM:SetScore(Score, IsAdd)
    self.Score = Score
    local NumberList = {}
    table.insert(NumberList, math.floor(Score / 1000))
    table.insert(NumberList, math.floor(Score / 100) % 10)
    table.insert(NumberList, math.floor(Score / 10) % 10)
    table.insert(NumberList, Score % 10)
    for i = 1, self.BottomScore:Length() do
		local VM = self.BottomScore:Get(i)  ---@type GateLampItemVM
        VM:SetNumber(NumberList[i], IsAdd)
	end
    for i = 1, self.LeftScore:Length() do
		local VM = self.LeftScore:Get(i)    ---@type GateScoreItemVM
        VM:SetNumber(NumberList[i], IsAdd)
	end

    if not self.LastSetScoreTime then
        self.LastSetScoreTime = TimeUtil.GetServerTime()
    end

    if TimeUtil.GetServerTime() - self.LastSetScoreTime > 3 then
        self.LastSetScoreTime = TimeUtil.GetServerTime()
        _G.GoldSauserMgr:SendUpdateScoreReq(Score)
    end
end

function GateMainVM:SetGameRunning(Val)
    self.IsGameRunning = Val
end

function GateMainVM:GetScore()
    return self.Score
end

function GateMainVM:GetKindNumList()
    return self.KindNumList
end

function GateMainVM:GetGameRunning()
    return self.IsGameRunning
end

return GateMainVM