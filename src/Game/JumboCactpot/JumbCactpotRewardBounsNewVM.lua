local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local UIBindableList = require("UI/UIBindableList")
local JumboCactpotRewardBuffItemVM = require("Game/JumboCactpot/ItemVM/JumboCactpotRewardBuffItemVM")

---@class JumbCactpotRewardBounsNewVM : UIViewModel
local JumbCactpotRewardBounsNewVM = LuaClass(UIViewModel)

function JumbCactpotRewardBounsNewVM:Ctor()
    self.BuySum = 0
    self.Stage1stInitNum = 0
    self.Stage2stInitNum = 0
    self.Stage3stInitNum = 0
    self.Stage4stInitNum = 0
    self.Stage5stInitNum = 0
    self.Stage6stInitNum = 0
    self.Stage7stInitNum = 0
    self.BaseRewardNum1 = 0
    self.BaseRewardNum2 = 0
    self.BaseRewardNum3 = 0
    self.BaseRewardNum4 = 0
    self.BaseRewardNum5 = 0
    self.StagePro = 0
    self.FinishStage = -1
    self.JumbRewardBuffList = UIBindableList.New(JumboCactpotRewardBuffItemVM)
end

function JumbCactpotRewardBounsNewVM:IsEqualVM(Value)
    return true
end

function JumbCactpotRewardBounsNewVM:UpdateVM(Value)
    self.BuySum = Value.BuySum
    self.Stage1stInitNum = Value.Stage1stInitNum
    self.Stage2stInitNum = Value.Stage2stInitNum
    self.Stage3stInitNum = Value.Stage3stInitNum
    self.Stage4stInitNum = Value.Stage4stInitNum
    self.Stage5stInitNum = Value.Stage5stInitNum
    self.Stage6stInitNum = Value.Stage6stInitNum
    self.Stage7stInitNum = Value.Stage7stInitNum
    self.BaseRewardNum1 = Value.BaseRewardNum1
    self.BaseRewardNum2 = Value.BaseRewardNum2
    self.BaseRewardNum3 = Value.BaseRewardNum3
    self.BaseRewardNum4 = Value.BaseRewardNum4
    self.BaseRewardNum5 = Value.BaseRewardNum5
    self.StagePro = Value.StagePro
    self.FinishStage = Value.FinishStage

    self:UpdateList(Value.RewardBuffListData)
end

function JumbCactpotRewardBounsNewVM:UpdateList(Data)
    local JumbRewardBuffList = self.JumbRewardBuffList
    if Data[1] == nil then
        JumbRewardBuffList:Clear()
        return
    end

    if nil ~= JumbRewardBuffList and JumbRewardBuffList:Length() > 0 then
        JumbRewardBuffList:Clear()
    end

    JumbRewardBuffList:UpdateByValues(Data)
end

return JumbCactpotRewardBounsNewVM