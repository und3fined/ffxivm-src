local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local OpsCeremonyDefine = require("Game/Ops/View/OpsCeremony/OpsCeremonyDefine")
local ItemUtil = require("Utils/ItemUtil")
local LSTR = _G.LSTR

---@class OpsCermonyPenguinWarsPanelVM : UIViewModel
local OpsCermonyPenguinWarsPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsCermonyPenguinWarsPanelVM:Ctor()
    self.IsFirstStage = true
    self.IsSecondStage = false
    self.TaskDescText = nil
    self.ActivityDescText = nil
    self.TimeText = nil
    self.NextBattleTimeText = nil
    self.FateTaskInFinished = false
    self.Info = nil
end

function OpsCermonyPenguinWarsPanelVM:Update(Params)
    ---Progress统计的是第一阶段
    self.Info = Params.Info or ""
    local NodeID  = Params.Node.Head.NodeID
    local Extra = Params.Node.Extra
    local TaskIsFinished = Extra.Progress.Value == 1 or Params.Node.Head.Finished
    self.FateTaskInFinished = Params.FateTaskInFinished
    self.FirstStageActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    self.SecondStageActivityNode = ActivityNodeCfg:FindCfgByKey(OpsCeremonyDefine.NodeIDDefine.PenguinWars2)
    self.FateTaskActivityNode = ActivityNodeCfg:FindCfgByKey(OpsCeremonyDefine.NodeIDDefine.PenguinWars3)
    if self.FirstStageActivityNode then
        self.IsFirstStage = not TaskIsFinished
        self.IsSecondStage = TaskIsFinished
        self.TimeText = _G.OpsSeasonActivityMgr:GetActivityTime(OpsCeremonyDefine.PenguinWarsActivityID)
        ---一阶段只需要跟新任务描述即可
        if self.IsFirstStage then
            self.TaskDescText = _G.OpsSeasonActivityMgr:GetTaskDesc(OpsCeremonyDefine.TaskIDDefine.PenguinWarsTask)
        else
            --- 二阶段需要更新活动描述
            if self.SecondStageActivityNode then
                self.TaskDescText = self.SecondStageActivityNode.NodeDesc
            end
            --- 根据Fate任务的完成情况设置相关属性
            if self.FateTaskActivityNode then
                if self.FateTaskInFinished then
                    self.ActivityDescText = self.FateTaskActivityNode.NodeDesc .. "(1/1)"
                else
                    self.ActivityDescText = self.FateTaskActivityNode.NodeDesc .. "(0/1)"
                end
            end
            if Params.ActivityEndStamp and Params.ActivityEndStamp - TimeUtil.GetServerLogicTime() <= 3599 then
                self.PartiesTimeText = ""
            else
                self.NextBattleTimeText = string.format(LSTR(1580022), _G.OpsSeasonActivityMgr:GetNextActivityOpenTime(2, 0)) ---下一场战斗%s开始
            end
        end
    end
    --- 读取节点表，更新奖励信息，一阶段只有代币奖励
    self:UpdateRewardInfo()
end

function OpsCermonyPenguinWarsPanelVM:UpdateRewardInfo()
    --- 一阶段只有一个奖励
    if self.FirstStageActivityNode then
        local Reward1 = self.FirstStageActivityNode.Rewards[1]
        self.Item1 = ItemUtil.CreateItem(Reward1.ItemID, Reward1.Num)
        self.Item1.IsItem = true
        self.Item1.IconReceivedVisible = false
    end
    --- 二阶段有两个奖励
    if self.FateTaskActivityNode then
        local Reward2 = self.FateTaskActivityNode.Rewards[1]
        self.Item2 = ItemUtil.CreateItem(Reward2.ItemID, Reward2.Num)
        self.Item2.IsItem = true
        self.Item2.IconReceivedVisible = self.FateTaskInFinished or false
        self.Item3 = {
			Num = 1,
			Icon = "PaperSprite'/Game/UI/Atlas/Achievement/Frames/UI_Achievement_Icon_Title_png.UI_Achievement_Icon_Title_png'",
			IsItem = false,
			ScoreID = nil,
			AchievementID = nil,
			IconReceivedVisible = self.FateTaskInFinished or false,
		}
    end
end
return OpsCermonyPenguinWarsPanelVM