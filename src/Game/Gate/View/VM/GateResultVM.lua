---
--- Author: sammrli
--- DateTime: 2023-09-20 15:46
--- Description:金蝶结算界面ViewModel
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local GateResultListItemVM = require("Game/Gate/View/Item/VM/GateResultListItemVM")
local GateMainVM = require("Game/Gate/View/VM/GateMainVM")
local RideShootingTargetTypeCfg = require("TableCfg/RideShootingTargetTypeCfg")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")

---@see GateResultPanelView

---@class GateResultVM : UIViewModel
---@field RecordTableList UIBindableList
---@field TotalScore string
---@field CoinNum string
---@field ScoreGrade number
local GateResultVM = LuaClass(UIViewModel)

function GateResultVM:Ctor()
    self.RecordTableList = UIBindableList.New(GateResultListItemVM)
    self.TotalScore = 0
    self.CoinNum = 0
    self.ItemIcon = nil
    self.ScoreGrade = nil
    self:InitData()
end

function GateResultVM:InitData()
    local IconList = {
        "PaperSprite'/Game/UI/Atlas/Gate/Frames/UI_Gate_Icon_Gold_png.UI_Gate_Icon_Gold_png'",
        "PaperSprite'/Game/UI/Atlas/Gate/Frames/UI_Gate_Icon_Silver_png.UI_Gate_Icon_Silver_png'",
        "PaperSprite'/Game/UI/Atlas/Gate/Frames/UI_Gate_Icon_Copper_png.UI_Gate_Icon_Copper_png'",
        "PaperSprite'/Game/UI/Atlas/Gate/Frames/UI_Gate_Icon_Red_png.UI_Gate_Icon_Red_png'",
    }
    local RecordList = {}
    for i=1,4 do
        local VM = GateResultListItemVM.New()
        VM.IconPath = IconList[i]
        table.insert(RecordList, VM)
    end
    self.RecordTableList:UpdateByValues(RecordList)
end

function GateResultVM:SetResult()
    local AllCfg = RideShootingTargetTypeCfg:FindAllCfg()
    local KindNumList = GateMainVM:GetKindNumList()
    for i=1, self.RecordTableList:Length() do
        local VM = self.RecordTableList:Get(i)  ---@type GateResultListItemVM
        local KindNum = KindNumList[i] or 0
        VM.Name = tostring(AllCfg[i].Label)
        VM.Num = tostring(AllCfg[i].Score).."x"..tostring(KindNum)
        VM.Score = tostring(AllCfg[i].Score * KindNum)
    end

    self.TotalScore = GateMainVM:GetScore()

    self.ScoreGrade = self:GetGrade()
    self.ItemIcon = "Texture2D'/Game/Assets/Icon/ItemIcon/065000/UI_Icon_065025.UI_Icon_065025'"
end

function GateResultVM:SetCoinNum(Num)
    self.CoinNum = Num or 0
end

function GateResultVM:GetGrade()
    local Score = self.TotalScore
    local Scores = GoldSauserDefine.AirForceConfig.Scores
    --local Icons = GoldSauserDefine.AirForceConfig.Icons

    local Grade = 1
    for i=1,#Scores do
        if Score >= Scores[i] then
            Grade = i
        else
            break
        end
    end
    return Grade
end

return GateResultVM