local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local ActivityCfg = require("TableCfg/ActivityCfg")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local OpsNewbieStrategyPanelVM = require("Game/Ops/VM/OpsNewbieStrategy/OpsNewbieStrategyPanelVM")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local OpsNewbieStrategyDefine = require("Game/Ops/OpsNewbieStrategy/OpsNewbieStrategyDefine")
local MapMap2areaCfg = require("TableCfg/MapMap2areaCfg")
local CrystalPortalCfg = require("TableCfg/TeleportCrystalCfg")
local ItemUtil = require("Utils/ItemUtil")
local JumpUtil = require("Utils/JumpUtil")
local JumpCfg = require("TableCfg/JumpCfg")
local QuestHelper = require("Game/Quest/QuestHelper")
local EventID
local RedDotMgr
local OpsActivityMgr

---@class OpsNewbieStrategyMgr : MgrBase
local OpsNewbieStrategyMgr = LuaClass(MgrBase)

---OnInit
function OpsNewbieStrategyMgr:OnInit()
    self.SaveRewardNodeReqMap = nil ---保存请求领奖的节点，防止短时间多次点击领奖，领奖回包/活动更新时清理
end

function OpsNewbieStrategyMgr:OnBegin()
    EventID = _G.EventID
    RedDotMgr = _G.RedDotMgr
    OpsActivityMgr = _G.OpsActivityMgr

    ---第一次获取到数据时，做首次打开红点处理
    self.FirstUpdata = true
    --self.WaitClaimedNodelist = {}
end

function OpsNewbieStrategyMgr:OnEnd()
end

function OpsNewbieStrategyMgr:OnShutdown()

end

function OpsNewbieStrategyMgr:OnRegisterNetMsg()

end

function OpsNewbieStrategyMgr:OnRegisterGameEvent()
    -- 活动中心数据更新-用于更新红点显示
	self:RegisterGameEvent(EventID.OpsActivityUpdate, self.OnOpsActivityUpdate)
    -- 活动中心领奖更新/考虑到后续可能会有一键领奖之类的，把领奖数据更新放在这里处理
    self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.OnOpsActivityGetRewardUpdate)
end

---------------------------- 界面操作start ----------------------------

---打开界面
function OpsNewbieStrategyMgr:OpenOpsNewbieStrategyMainPanelView()
    --依靠活动中心实现界面显示
    --UIViewMgr:ShowView(UIViewID.OpsNewbieStrategyMainPanelView)
end

function OpsNewbieStrategyMgr:OpenEthericProgressPanel(NodeID, NodeTitle)
    local CfgData = ActivityNodeCfg:FindCfgByKey(OpsNewbieStrategyDefine.ActivitySummaryNodeID.AdvancedEthericNodeID)
    local Str = CfgData.StrParam
    local ShieldCrystalIDList = {}
    if Str then
        local JumpStrList = string.split(Str, ",")
        for _, JumpStr in ipairs(JumpStrList) do
            local JumpParams = string.split(JumpStr, "|")
            if JumpParams and JumpParams[1] then
                local NewbieStrategyStrParamType = tonumber(JumpParams[1])
                    if NewbieStrategyStrParamType == OpsNewbieStrategyDefine.NewbieStrategyStrParamType.ShieldCrystalID then
                    ---以太水晶id屏蔽
                    for Index, ShieldCrystalID in ipairs(JumpParams) do
                        if Index > 1 then
                            table.insert(ShieldCrystalIDList, tonumber(ShieldCrystalID))
                        end
                    end
                end
            end
        end
    end
    local Params = {NodeID = NodeID, NodeTitle = NodeTitle, ShieldCrystalIDList = ShieldCrystalIDList}
    UIViewMgr:ShowView(UIViewID.OpsNewbieStrategyLightofEtherWinView, Params)
end

function OpsNewbieStrategyMgr:NodeJump(NodeID, PluralJumpParam)
    local CfgData = ActivityNodeCfg:FindCfgByKey(NodeID)
    local Params = {NodeID = NodeID}
    if PluralJumpParam then
        if CfgData then
            Params.NodeTitle = CfgData.NodeTitle
            Params.ActivityID = CfgData.ActivityID
        end
        Params.JumpData = PluralJumpParam
        UIViewMgr:ShowView(UIViewID.OpsNewBieStrategyCommListWinView, Params)
    else
        if CfgData then
            local IsCanJump = JumpUtil.IsCurJumpIDCanJump(tonumber(CfgData.JumpParam))
            if IsCanJump then
                OpsActivityMgr:Jump(CfgData.JumpType, CfgData.JumpParam)
            else
                self:JumpUnlockSys(tonumber(CfgData.JumpParam))
            end
        end
    end
end

function OpsNewbieStrategyMgr:OpenBraveryAwardPanel()
    local Params = {}
    if self.ActivityList == nil then
        self.ActivityList = OpsActivityMgr:GetActivityListByClassify(OpsNewbieStrategyDefine.OpsNewbieStrategyMenuIndex)
    end
    Params.ActivityData = table.find_by_predicate(self.ActivityList, function(A)
        return A.Activity.ActivityID == OpsNewbieStrategyDefine.ActivityID.BraveryAwardActivityID
    end)
    UIViewMgr:ShowView(UIViewID.OpsNewbieStrategyBraveryAwardWinView, Params)
end

---------------------------- 界面操作end ----------------------------

---------------------------- 数据处理start --------------------------
---对应活动下节点数据处理,将其处理为对应UI显示需要数据
function OpsNewbieStrategyMgr:GetActivityNodeUIDataByNodeList(NodeList)
    local UIData = {}
    if NodeList then
        UIData.MaxNum = 0
        UIData.CompletedNum = 0
        UIData.IsGetAllReward = true
        local Items = {}
        for _, Node in ipairs(NodeList) do

            local NodeID
            if Node.Head then
                NodeID = Node.Head.NodeID
                if UIData.IsGetAllReward and Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
                    UIData.IsGetAllReward = false
                end
            end
            if NodeID ~= nil and Node.Head then
                ---汇总节点处理，不考虑多个情况
                local IsActivitySummaryNodeID = table.find_by_predicate(OpsNewbieStrategyDefine.ActivitySummaryNodeID , function(A)
                    return A == NodeID
                end)
                if IsActivitySummaryNodeID then
                    --- 不获取cfgdata,需要时对应VM主动获取，不是所有地方都需要cfgdata
                    UIData.ActivitySummaryNode = {Node = Node}
                    --break
                else
                    local IsCompositeNode = false
                    ---表格数据/注意只读
                    local CfgData = ActivityNodeCfg:FindCfgByKey(Node.Head.NodeID)
                    ---获取活动纯显示节点数据
                    if CfgData and CfgData.NodeType == ActivityNodeType.ActivityNodeTypeClientShow then
                        if CfgData.Params and #CfgData.Params > 1 then
                            if CfgData.Params[1] == OpsNewbieStrategyDefine.ShowNodeType.ActivityData then
                                local TaskID = CfgData.Params[2]
                                local QuestCfg = QuestHelper.GetQuestCfgItem(TaskID)
                                local ChapterCfg
                                if QuestCfg then
                                    ChapterCfg = QuestHelper.GetChapterCfgItem(QuestCfg.ChapterID)
                                end
                                if ChapterCfg then
                                    UIData.QuestName = ChapterCfg.QuestName
                                end
                            end
                        end
                    end
                    ---无标题节点视为不需要显示的子节点
                    local NodeTitle
                    if CfgData then
                        NodeTitle = CfgData.NodeTitle
                    end
                    if  CfgData and NodeTitle ~= nil and NodeTitle ~= "" then
                        local NodeType = CfgData.NodeType
                        if CfgData.Params and #CfgData.Params > 1 and NodeType ==  ActivityNodeType.ActivityNodeTypeAccumulativeFinishNode then
                            IsCompositeNode = true
                        end
                        local SubNodeList = {}
                        if IsCompositeNode and CfgData.Params then
                            ---后续如果有嵌套复合节点，在这里做递归
                            for _, SubNodeID in ipairs(CfgData.Params) do
                                local SubNodeData = {}
                                for _, FindNode in ipairs(NodeList) do
                                    if  FindNode.Head and SubNodeID == FindNode.Head.NodeID then
                                        SubNodeData.Node = FindNode
                                        break
                                    end
                                end
                                local SubCfgData = ActivityNodeCfg:FindCfgByKey(SubNodeID)
                                SubNodeData.CfgData = SubCfgData
                                table.insert(SubNodeList, SubNodeData)
                            end
                        end
                        local Item = {Node = Node, CfgData = CfgData, IsCompositeNode = IsCompositeNode, SubNodeList = SubNodeList}
                        if Node.Head.Finished then
                            UIData.CompletedNum = UIData.CompletedNum + 1
                        end
                        table.insert(Items, Item)
                    end
                end
            end
        end
        if Items then
            ---有汇总节点使用汇总节点，无汇总节点使用计数
            if UIData.ActivitySummaryNode then
                local CfgData = ActivityNodeCfg:FindCfgByKey(UIData.ActivitySummaryNode.Node.Head.NodeID)
                if CfgData then
                    UIData.MaxNum = CfgData.Target
                    UIData.SummaryNodeDesc = CfgData.NodeDesc
                end
            elseif Items then
                UIData.MaxNum = #Items
            end
        end
        UIData.CompletedNumText = string.format("%s/%s", UIData.CompletedNum, UIData.MaxNum)
        ---有汇总节点使用汇总节点，无汇总节点使用计数
        if UIData.ActivitySummaryNode then
            UIData.IsFinished =  UIData.ActivitySummaryNode.Node.Head.Finished
        else
            UIData.IsFinished = UIData.CompletedNum >= UIData.MaxNum
        end
        table.sort(Items, function(A, B)
            if A.CfgData.NodeSort ~= B.CfgData.NodeSort then
                return A.CfgData.NodeSort > B.CfgData.NodeSort
            else
                return A.Node.Head.NodeID < B.Node.Head.NodeID
            end
        end)
        UIData.Items = Items
    end
    return UIData
end

---活动数据更新
function OpsNewbieStrategyMgr:OnOpsActivityUpdate()
    if self.FirstUpdata then
        ---需要考虑活动消失的情况/使用活动中心的首次红点逻辑，屏蔽掉
        --self:AddAllFirstOpenRedDot()
        self.FirstUpdata = false
    end
    self.ActivityList = OpsActivityMgr:GetActivityListByClassify(OpsNewbieStrategyDefine.OpsNewbieStrategyMenuIndex)
    if self.ActivityList then
        self:UpdateActivityRedDot(self.ActivityList)
    end
end

---GetRewardMsg = {
---    Detail = {
---        Head = {ActivityID, EmergencyShutDown, Effected, Hiden}
---        Nodes = repeated ActivityNode Nodes
---    }
---}
function OpsNewbieStrategyMgr:OnOpsActivityGetRewardUpdate(GetRewardMsg)
    if GetRewardMsg and GetRewardMsg.Reward then
        local Reward = GetRewardMsg.Reward
        local RewardActivityID = Reward.Detail.Head.ActivityID
        self.ActivityList = OpsActivityMgr:GetActivityListByClassify(OpsNewbieStrategyDefine.OpsNewbieStrategyMenuIndex)
        local RewardActivity = table.find_by_predicate(self.ActivityList, function(A)
            return A.Activity.ActivityID == RewardActivityID
        end)
        if RewardActivity == nil then
            return
        end
        ---更新一次红点
        if self.ActivityList then
            self:UpdateActivityRedDot(self.ActivityList)
        end
        ---更新界面数据
        local IsUIShow = UIViewMgr:FindView(UIViewID.OpsActivityMainPanel)
        if IsUIShow then
            OpsNewbieStrategyPanelVM:UpdateOpsNewbieStrategySubActivityData(RewardActivity)
            ---领奖完成后更新一次勇气嘉奖数据
            _G.OpsActivityMgr:SendQueryActivity(OpsNewbieStrategyDefine.ActivityID.BraveryAwardActivityID)
        end
        ---领奖表现展示
        local NodeList = Reward.Detail.Nodes
        for _, Node in ipairs(NodeList) do
            local NodeID = Node.Head.NodeID
            local RewardStatus = Node.Head.RewardStatus
            if NodeID and self.NodeReWardGetMap and self.NodeReWardGetMap[NodeID] and RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
                _G.LootMgr:SetDealyState(true) --屏蔽飘字，等关领取弹窗再打开
                UIViewMgr:ShowView(UIViewID.CommonRewardPanel, self.NodeReWardGetMap[NodeID])
                self.NodeReWardGetMap[NodeID] = nil
                self:ClearSaveRewardReqNodeByNodeID(NodeID)
                if NodeID == OpsNewbieStrategyDefine.ShowAppStoreRatingNodeID then
                    _G.UE.UCommonUtil.ShowAppStoreRatingAlert()
                end
            end
        end
    end
end

---更新红点
function OpsNewbieStrategyMgr:UpdateActivityRedDot(ActivityList)
    for _, ActivityData in ipairs(ActivityList) do
        if ActivityData.Detail and ActivityData.Detail.NodeList then
            for _, Node in ipairs(ActivityData.Detail.NodeList) do
                if Node.Head and Node.Head.RewardStatus then
                    ---待领奖加红点
                    if Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
                        self:SetRedDotShowByNodeID(Node.Head.NodeID, true)
                    elseif Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
                        self:SetRedDotShowByNodeID(Node.Head.NodeID, false)
                    end
                end
            end
        end
    end
end

---勇气嘉奖更新
function OpsNewbieStrategyMgr:GetBraveryAwardProgress(NodeList)
    local BraveryAwardProBar = 0
    local NodeList = NodeList
    local MaxNum
    local CurNum 
    local IshaveGiveReward = false
    local IsFinishedAndGiveAllReward = true
    local IsFinished = true
    for _, Node in ipairs(NodeList) do
        if Node.Head then
            local Head = Node.Head
            local RewardStatus = Head.RewardStatus
            local Finished = Head.Finished
            IsFinished = Finished and IsFinished
            if RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
                IshaveGiveReward = true
                ---有奖励未领取时，不视为完成
                IsFinishedAndGiveAllReward = false
            elseif Finished == false then
                IsFinishedAndGiveAllReward = false
            end
            local NodeID = Head.NodeID
            local CfgData = ActivityNodeCfg:FindCfgByKey(NodeID)
            if CfgData then
                if CfgData.Target then
                    if MaxNum then
                        MaxNum = MaxNum > CfgData.Target and MaxNum or CfgData.Target
                    else
                        MaxNum = CfgData.Target
                    end
                end
                --如果已完成，直接手动设置进度为满
                if Finished then
                    if CfgData.Target then
                        if CurNum then
                            CurNum = CurNum > CfgData.Target and CurNum or CfgData.Target
                        else
                            CurNum = CfgData.Target
                        end
                    end
                elseif Node.Extra and Node.Extra.Progress then 
                    if CurNum then
                        CurNum = CurNum > Node.Extra.Progress.Value and CurNum or Node.Extra.Progress.Value
                    else
                        CurNum = Node.Extra.Progress.Value
                    end
                end
            end
        end
    end
    ---规避节点变更更新推送时，无进度数据导致的显示错误，如果已完成，直接手动设置进度为满
    if IsFinished then
        BraveryAwardProBar = 1
        CurNum = MaxNum or 0
    elseif MaxNum and CurNum then
        BraveryAwardProBar = CurNum/MaxNum
    end
    return BraveryAwardProBar, CurNum, MaxNum, IshaveGiveReward, IsFinishedAndGiveAllReward
end

function OpsNewbieStrategyMgr:GetProgressValueByNode(Node)
    if Node and Node.Extra and Node.Progress then
        return Node.Progress.Value or 0
    end
    return 0
end
---------------------------- 数据处理end ----------------------------

---------------------------- 数据查询start ----------------------------
function OpsNewbieStrategyMgr:GetMenuActivityIsUnlock(PanelKey)
    ---首选和推荐暂时无锁定
    if OpsNewbieStrategyDefine.PanelKey.FirstChoicePanel == PanelKey then
        return true
    elseif  OpsNewbieStrategyDefine.PanelKey.RecommendPanel == PanelKey then
        return true
    elseif OpsNewbieStrategyDefine.PanelKey.AdvancedPanel == PanelKey then
        return OpsNewbieStrategyPanelVM:GetAdvancedIsUnlock()
    end
end

function OpsNewbieStrategyMgr:GetAetherLightNodeMapID(NodeID)
    local MapIDs = {}
    if NodeID then
        local AreaID = OpsNewbieStrategyDefine.AetherLightNodeAreaID[NodeID]
        if AreaID then
            local AllCfg = MapMap2areaCfg:FindAllCfg()
            for _, CfgData in ipairs(AllCfg) do
                if CfgData.AreaID == AreaID then
                    table.insert(MapIDs, CfgData.ID)
                end
            end
        end
    end
    return MapIDs
end

---获取所有的水晶id通过地图id/ 屏蔽掉不存在水晶的id DisplayOrder ~= 0 
function OpsNewbieStrategyMgr:GetAllCrystalIDByMapID(MapIDs)
    local AllCrystalData = {}
    if MapIDs then
        local AllCfg = CrystalPortalCfg:FindAllCfg()
        for _, CfgData in ipairs(AllCfg) do
            for _, MapID in ipairs(MapIDs) do
                if CfgData.MapID == MapID and CfgData.DisplayOrder ~= 0 then
                    local CopyData = table.clone(CfgData)
                    table.insert(AllCrystalData, CopyData)
                    break
                end
            end
        end
    end
    return AllCrystalData
end

function OpsNewbieStrategyMgr:GetAllCrystalDataByNodeID(NodeID)
    local AllCrystalData
    local MapIDs = self:GetAetherLightNodeMapID(NodeID)
    if MapIDs and #MapIDs > 0 then
        AllCrystalData = self:GetAllCrystalIDByMapID(MapIDs)
    end
    return AllCrystalData or {}
end

function OpsNewbieStrategyMgr:GetFirstRewardNumByNodeID(NodeID)
    local CfgData = ActivityNodeCfg:FindCfgByKey(NodeID)
    if CfgData then
        local Rewards = CfgData.Rewards
        if Rewards and Rewards[1] then
            return Rewards[1].Num
        end
    end
    return 0
end

---------------------------- 数据查询end ----------------------------

----------------------------红点接口----------------------------------
-----根据节点ID生成红点名/进阶节点需要特殊处理，统一挂在进阶主界面下
function OpsNewbieStrategyMgr:GetRedDotNameByNodeID(NodeID)
    local NodeCfgData = ActivityNodeCfg:FindCfgByKey(NodeID)
    local ActivityID = NodeCfgData.ActivityID
    ---进阶节点需要特殊处理，统一挂在进阶主界面下
    if ActivityID ~= OpsNewbieStrategyDefine.ActivityID.FirstChoiceActivityID and 
    ActivityID ~= OpsNewbieStrategyDefine.ActivityID.RecommendActivityID and
    ActivityID ~= OpsNewbieStrategyDefine.ActivityID.BraveryAwardActivityID then
        ActivityID = OpsNewbieStrategyDefine.ActivityID.AdvancedActivityID
    end
    local ActivityCfgData = ActivityCfg:FindCfgByKey(ActivityID)
    local ClassifyID = ActivityCfgData.ClassifyID
    local ActivityRedDotName = OpsActivityMgr:GetRedDotName(ClassifyID, ActivityID)
    local NodeRedDotName = ActivityRedDotName.."/"..NodeID
    return NodeRedDotName
end

-----根据活动ID获取红点名
function OpsNewbieStrategyMgr:GetRedDotNameByActivityID(ActivityID)
    local RedDotName = OpsActivityMgr:GetRedDotName(OpsNewbieStrategyDefine.OpsNewbieStrategyMenuIndex, ActivityID)
    return RedDotName or ""
end

function OpsNewbieStrategyMgr:GetFirstRedDotNameByActivityID(ActivityID)
    local RedDotName = self:GetRedDotNameByActivityID(ActivityID)
    RedDotName = RedDotName.."/".."FirstOpen"
    return RedDotName
end

---设置节点领取红点
function OpsNewbieStrategyMgr:SetRedDotShowByNodeID(NodeID, IsShow)
    local RedDotName = self:GetRedDotNameByNodeID(NodeID)
    if IsShow then
        RedDotMgr:AddRedDotByName(RedDotName)
    else
        RedDotMgr:DelRedDotByName(RedDotName)
    end
end

---设置首次进入红点
function OpsNewbieStrategyMgr:SetRedDotShowByActivityID(ActivityID, IsShow, IsClientNode)
    local RedDotName = self:GetFirstRedDotNameByActivityID(ActivityID)
    if IsShow then
        RedDotMgr:AddRedDotByName(RedDotName, nil, IsClientNode)
    else
        RedDotMgr:DelRedDotByName(RedDotName)
    end
end

---删除首次进入红点
function OpsNewbieStrategyMgr:DelFirstOpenRedDot(ActivityID)
    local RedDotName = self:GetFirstRedDotNameByActivityID(ActivityID)
	local IsSaveDelRedDot = RedDotMgr:GetIsSaveDelRedDotByName(RedDotName)
	if not IsSaveDelRedDot then
		self:SetRedDotShowByActivityID(ActivityID, false, true)
	end
end

---添加首次进入红点
function OpsNewbieStrategyMgr:AddFirstOpenRedDot(ActivityID)
    local RedDotName = self:GetFirstRedDotNameByActivityID(ActivityID)
	local IsSaveDelRedDot = RedDotMgr:GetIsSaveDelRedDotByName(RedDotName)
	if not IsSaveDelRedDot then
		self:SetRedDotShowByActivityID(ActivityID, true, true)
	end
end

---添加所有首次进入红点
function OpsNewbieStrategyMgr:AddAllFirstOpenRedDot()
    ---首选红点
    self:AddFirstOpenRedDot(OpsNewbieStrategyDefine.ActivityID.FirstChoiceActivityID)
    ---推荐
    self:AddFirstOpenRedDot(OpsNewbieStrategyDefine.ActivityID.RecommendActivityID)
    ---进阶
    self:AddFirstOpenRedDot(OpsNewbieStrategyDefine.ActivityID.AdvancedActivityID)
end


---领取/先弹通用奖励弹窗
function OpsNewbieStrategyMgr:GetRewardByNodeID(NodeID)
    if NodeID then
        if self.NodeReWardGetMap == nil then
            self.NodeReWardGetMap = {}
        end
        ---做一个拦截处理，防止短时间多次请求,
        if self.SaveRewardNodeReqMap and self.SaveRewardNodeReqMap[NodeID] then
            if self.TimerMap == nil then
                self.TimerMap = {}
            end
            if self.TimerMap[NodeID] == nil then
                self.TimerMap[NodeID] = self:RegisterTimer(function() 
                    self:ClearSaveRewardReqNodeByNodeID(NodeID)
                end , 1)
            end
            return
        end
        local Cfg = ActivityNodeCfg:FindCfgByKey(NodeID)
        local Rewards = Cfg.Rewards
        local ItemList = {}
        for _, Reward in ipairs(Rewards) do
            if Reward.ItemID ~= 0 and Reward.ItemID ~= nil then
                local Item = {ResID = Reward.ItemID, Num = Reward.Num}
                table.insert(ItemList, Item)
            end
        end
        local Params = {
            ItemList = ItemList,
            -- ShowBtn = true,
            -- ShowBtnLeft = true,
            -- -- LSTR string:取消
            -- BtnLeftText = LSTR(920006),
            -- ShowBtnRight = true,
            -- -- LSTR string:领取
            -- BtnRightText = LSTR(920026),
            -- LSTR string:获得物品
            Title = LSTR(920023),
            -- BtnLeftCB = function() 
            --     UIViewMgr:HideView(UIViewID.CommonRewardPanel)
            -- end,
            -- BtnRightCB = function() 
            --     OpsActivityMgr:SendActivityNodeGetReward(NodeID) 
            --     UIViewMgr:HideView(UIViewID.CommonRewardPanel)
            -- end
        }
        self.NodeReWardGetMap[NodeID] = Params
        --UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
        ---缓存请求过的节点，1s内不允许再次请求
        if self.SaveRewardNodeReqMap == nil then
            self.SaveRewardNodeReqMap = {}
        end
        self.SaveRewardNodeReqMap[NodeID] = NodeID
        OpsActivityMgr:SendActivityNodeGetReward(NodeID) 
    end
end 

function OpsNewbieStrategyMgr:ClearSaveRewardReqNodeByNodeID(NodeID)
    if self.SaveRewardNodeReqMap and self.SaveRewardNodeReqMap[NodeID] then
        self.SaveRewardNodeReqMap[NodeID] = nil
    end
    if self.TimerMap and self.TimerMap[NodeID] then
        self:UnRegisterTimer(self.TimerMap[NodeID])
        self.TimerMap[NodeID] = nil
    end
end

---新人攻略是否已完成（完成且ling）
function OpsNewbieStrategyMgr:IsNewBieStrategyFinish()
    if self.ActivityList and OpsNewbieStrategyPanelVM  then
        ---检查首选/推荐是否完成
        local FirstChoicePanelVM = OpsNewbieStrategyPanelVM:GetFirstChoicePanelVM()
        local RecommendPanelVM = OpsNewbieStrategyPanelVM:GetRecommendPanelVM()
        local AdvancedPanelVM = OpsNewbieStrategyPanelVM:GetAdvancedPanelVM()
            ---判断打开默认页签下标
        if FirstChoicePanelVM and not FirstChoicePanelVM:GetIsFinished() or not FirstChoicePanelVM:GetIsGetAllReward() then
            ---首选没完成/未领奖
            return false
        elseif RecommendPanelVM and not RecommendPanelVM:GetIsFinished() or not RecommendPanelVM:GetIsGetAllReward() then
            ---推荐未完成/未领奖
            return false
        elseif AdvancedPanelVM and not AdvancedPanelVM:GetIsFinished() or not AdvancedPanelVM:GetIsGetAllReward() then
            ---首选完成，推荐完成，检查进阶
            return false
        else
            ---首选完成，推荐完成，进阶完成，检查勇气嘉奖
            local BraveryAwardActivity = self:GetBraveryAwardActivityData()
            if BraveryAwardActivity then
                if BraveryAwardActivity.Detail and BraveryAwardActivity.Detail.NodeList then
                    for _, Node in ipairs(BraveryAwardActivity.Detail.NodeList) do
                        if Node.Head then
                            ---待领奖/未完成
                            if not Node.Head.Finished or Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
                                return false
                            end
                        end
                    end
                end
            end
        end
        return true
    end
    return false
end

function OpsNewbieStrategyMgr:GetBraveryAwardActivityData()
    if self.ActivityList == nil  then
        self.ActivityList = OpsActivityMgr:GetActivityListByClassify(OpsNewbieStrategyDefine.OpsNewbieStrategyMenuIndex)
    end
    local BraveryAwardActivity
    for _, Data in pairs(self.ActivityList) do
        if Data.Activity.ActivityID == OpsNewbieStrategyDefine.ActivityID.BraveryAwardActivityID then
            BraveryAwardActivity = Data
            break
        end
    end
    return BraveryAwardActivity
end

---跳转未解锁处理
function OpsNewbieStrategyMgr:JumpUnlockSys(JumpID)
    local ModuleID
    local JumpData = JumpCfg:FindCfgByKey(JumpID) or {}
    ModuleID = JumpData.ModuleID
    ----只处理系统解锁表配置的
    if ModuleID and ModuleID ~= 0 then
        local SysUnlockData = _G.ModuleOpenMgr:GetCfgByModuleID(ModuleID) 
        if SysUnlockData then
            local UnlockName = SysUnlockData.SysNotice
            --LSTR 提示
            local TitleText = LSTR(920046)
            --LSTR 解锁条件
            local SubTitleText = LSTR(920047)
            --LSTR 亲爱的冒险者，你尚未解锁“%s”
            local ContentText = string.format(LSTR(920048), UnlockName)
            local TaskID = SysUnlockData.PreTask[1]
            local Params = {
                TitleText = TitleText,
                SubTitleText = SubTitleText,
                ContentText = ContentText,
                TaskID = TaskID,
            }
            UIViewMgr:ShowView(UIViewID.OpsNewbieStrategyHintWinView, Params)
        end
    else
        local JumpUnlockTipsText = JumpData.ForbiddenTips
        if JumpUnlockTipsText and JumpUnlockTipsText ~= "" then
            _G.MsgTipsUtil.ShowTips(JumpUnlockTipsText)
        else
            _G.MsgTipsUtil.ShowTipsByID(OpsNewbieStrategyDefine.UnlockTipsID)
        end
    end
end

--要返回当前类
return OpsNewbieStrategyMgr