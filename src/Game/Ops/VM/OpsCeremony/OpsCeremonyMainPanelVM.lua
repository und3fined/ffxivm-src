local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local TimeUtil = require("Utils/TimeUtil")
local OpsCeremonyDefine = require("Game/Ops/View/OpsCeremony/OpsCeremonyDefine")
local ActivityCfg = require("TableCfg/ActivityCfg")
local LSTR = _G.LSTR

local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsCeremonyMainPanelVM : UIViewModel
local OpsCeremonyMainPanelVM = LuaClass(UIViewModel)
---用于定义集合面板中活动节点的ID
local NodeIDDefine = OpsCeremonyDefine.NodeIDDefine
---Ctor
function OpsCeremonyMainPanelVM:Ctor()
    self.TitleText = nil
    self.MysteriousVisitorParams = {}
    self.PenguinWarsParams = {}
    self.CelebrationParams = {}
    self.FatPenguinParams = {}
    self.SeasonShopParams = {}
end

function OpsCeremonyMainPanelVM:Update(ActivityData)
    local Activity = ActivityData.Activity
    self.TitleText = Activity.Title
    local MysteriousVisitorFinish = false
    self.CelebrationParams.IsLock = false
    local NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeStatistic)
    if NodeList then
        --- 若任务被紧急关闭则活动参数对应的节点容器为nil
        for _, Node in ipairs(NodeList) do
            local NodeID  = Node.Head.NodeID
            local Extra = Node.Extra
            local Progress = Extra.Progress.Value or 0
		    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode then
                --- 初始化异界访客活动节点
                if NodeID == NodeIDDefine.MysteriousVisitor then
                    self.MysteriousVisitorParams.Node = Node
                    self.MysteriousVisitorParams.Icon = ActivityNode.StrParam
                    self.MysteriousVisitorParams.Title = ActivityNode.NodeTitle
                    self.MysteriousVisitorParams.Info = Activity.Info
                    --- 是否完成任务
                    MysteriousVisitorFinish = Progress == 1 or Node.Head.Finished
                    self.MysteriousVisitorParams.IsFinish = MysteriousVisitorFinish
                    --- 任务完成图标可见
                    self.MysteriousVisitorParams.IconPassedPromVisible = MysteriousVisitorFinish
                    --- 叙事任务显示叙述图标可见
                    self.MysteriousVisitorParams.IconPromVisible = true
                    self.MysteriousVisitorParams.RedDotName = _G.OpsSeasonActivityMgr:GetRedDotName(tostring(OpsCeremonyDefine.ActivityID).."/"..tostring(NodeIDDefine.MysteriousVisitor))
                --- 初始化迷失企鹅大作战节点
                elseif NodeID == NodeIDDefine.PenguinWars then
                    self.PenguinWarsParams.Node = Node
                    self.PenguinWarsParams.Icon = ActivityNode.StrParam
                    self.PenguinWarsParams.Title = ActivityNode.NodeTitle
                    self.PenguinWarsParams.IsFinish = Progress == 1 or Node.Head.Finished
                    self.PenguinWarsParams.Info = Activity.Info
                    if Progress == 0 then
                        self.PenguinWarsParams.RedDotName = _G.OpsSeasonActivityMgr:GetRedDotName(tostring(OpsCeremonyDefine.ActivityID).."/"..tostring(NodeIDDefine.PenguinWars))
                    else
                        self.PenguinWarsParams.RedDotName = _G.OpsSeasonActivityMgr:GetRedDotName(tostring(OpsCeremonyDefine.ActivityID).."/"..tostring(NodeIDDefine.PenguinWars2))
                    end
                --- 获取迷失企鹅大作战阶段3的完成情况
                elseif NodeID == NodeIDDefine.PenguinWars3 then
                    self.PenguinWarsParams.FateTaskInFinished = Progress == 1 or Node.Head.Finished
                --- 初始化跨越时空的庆典节点
                elseif NodeID == NodeIDDefine.Celebration then
                    self.CelebrationParams.Node = Node
                    self.CelebrationParams.Icon = ActivityNode.StrParam
                    self.CelebrationParams.Title = ActivityNode.NodeTitle
                    self.CelebrationParams.IsFinish = Progress == 1 or Node.Head.Finished
                    self.CelebrationParams.Info = Activity.Info
                    --- 检查活动解锁时间,目前只支持国服时间
                    local CelebrationActivity = ActivityCfg:FindCfgByKey(OpsCeremonyDefine.CelebrationActivityID)
                    if CelebrationActivity then
                        local StartTime = CelebrationActivity.ChinaActivityTime.StartTime
                        local ActivityDataStamp = TimeUtil.GetTimeFromString(StartTime)
                        if ActivityDataStamp > TimeUtil.GetServerLogicTime() then
                            self.CelebrationParams.StartTimeVisible = true
                            -- 未到开启时间，也需要锁定
                            self.CelebrationParams.IsLock = true
                            self.CelebrationParams.StartTimeText = string.format(LSTR(1580007),StartTime)
                        else
                            self.CelebrationParams.StartTimeVisible = false
                            self.CelebrationParams.StartTimeText = ""
                            self.CelebrationParams.IsLock = false
                        end
                    end
                    self.CelebrationParams.RedDotName = _G.OpsSeasonActivityMgr:GetRedDotName(tostring(OpsCeremonyDefine.ActivityID).."/"..tostring(NodeIDDefine.Celebration))
                --- 庆典参数需要检查两个节点信息
                elseif NodeID == NodeIDDefine.Celebration2 then
                    self.CelebrationParams.PartiesNode = Node
                end
            end
	    end
        self.CelebrationParams.IsLock = self.CelebrationParams.IsLock or not MysteriousVisitorFinish
        self.PenguinWarsParams.IsLock = not MysteriousVisitorFinish
        local ActivityEndTime = Activity.ChinaActivityTime.EndTime
        local ActivityEndStamp = TimeUtil.GetTimeFromString(ActivityEndTime)
        self.CelebrationParams.ActivityEndStamp = ActivityEndStamp
        self.PenguinWarsParams.ActivityEndStamp = ActivityEndStamp
    end

   NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
    if NodeList then
        for _, Node in ipairs(NodeList) do
            local NodeID  = Node.Head.NodeID
		    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode then
                -- 初始化胖胖企鹅节点
                if NodeID == NodeIDDefine.FatPenguin then
                    self.FatPenguinParams.Node = Node
                    self.FatPenguinParams.Title = ActivityNode.NodeTitle
                    self.FatPenguinParams.Icon = ActivityNode.StrParam
                    self.FatPenguinParams.RedDotName = _G.OpsSeasonActivityMgr:GetRedDotName(tostring(OpsCeremonyDefine.ActivityID).."/"..tostring(NodeIDDefine.FatPenguin))
                -- 初始化季节商店节点,季节商店没有锁定、任务、是否完成等概念，活动结束时直接关闭入口
                elseif NodeID == NodeIDDefine.SeasonShop then
                    self.SeasonShopParams.Node = Node
                    self.SeasonShopParams.Title = ActivityNode.NodeTitle
                    self.SeasonShopParams.Icon = ActivityNode.StrParam
                -- 初始化视频显示节点
                elseif NodeID == NodeIDDefine.VideoShow then
                    self.VideoShowNodeInfo = ActivityNode
                end
            end
        end
    end
end



return OpsCeremonyMainPanelVM