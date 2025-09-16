local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local CommercializationRandCfg = require("TableCfg/CommercializationRandCfg")
local CommercializationRandConsumeCfg = require("TableCfg/CommercializationRandConsumeCfg")
local UIBindableList = require("UI/UIBindableList")
local OpsConcertGetListItemVM = require("Game/Ops/VM/OpsConcert/OpsConcertGetListItemVM")
local OpsConcertFriendsListItemVM = require("Game/Ops/VM/OpsConcert/OpsConcertFriendsListItemVM")
local OpsActivityRewardItemVM = require("Game/Ops/VM/OpsActivityRewardItemVM")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local ProtoCS = require("Protocol/ProtoCS")
local CS_CMD = ProtoCS.CS_CMD
local GameNetworkMgr = require("Network/GameNetworkMgr")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local LSTR = _G.LSTR
local TimeUtil = _G.TimeUtil

local VoucherIcon = "Texture2D'/Game/UI/Texture/Ops/OpsConcert/UI_OpsConcert_Icon_Voucher.UI_OpsConcert_Icon_Voucher'"
---@class OpsConcertMainPanelVM : UIViewModel
local OpsConcertMainPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsConcertMainPanelVM:Ctor()
    self.NumText = nil
    self.CurrentMusicalNoteNum = nil
    --- 奖励列表，根据活动节点信息初始化
    self.RewardVMList = UIBindableList.New(OpsActivityRewardItemVM,{ItemSlotType = ItemDefine.ItemSlotType.Item96Slot})
    self.GetMusicalNoteTabSelected = nil
    --- 任务列表，根据活动节点信息初始化
    self.TaskVMList = UIBindableList.New(OpsConcertGetListItemVM)
    --- 已召回好友列表，请求服务器信息初始化
    self.CallFriendTabSelected = nil
    --- 微信/QQ好友列表，拉取登录信息初始化
    self.SocialFriendVMList = UIBindableList.New(OpsConcertFriendsListItemVM)
    --- 演奏动效
    self.IsEnoughForPerform = nil
    --- 是否演奏完成
    self.IsPerformComplete = nil
    --- 召回页面空状态显隐控制
    self.CallFriendListEmpty = nil
    --- 更多加载按钮显隐控制
    self.MoreBtnIsVisible = nil
    --- 绑定玩家列表
    self.BindPlayerList = nil
    --- 自己的绑定码
    self.InviteCode = nil
    --- 是否已经绑定
    self.IsBind = nil
    --- 演奏按钮文本
    self.PerformanceText = nil
    ---所有满足召回条件的微信/QQ好友列表，拉取登录信息初始化
    self.SocialFriendVMListInfo = {}
    --- 当前显示的微信/QQ好友列表
    self.CurrentShowFriendVMListInfo = {}
end

function OpsConcertMainPanelVM:Reset()
    self.SocialFriendVMListInfo = {}
    self.CurrentShowFriendVMListInfo = {}
end

function OpsConcertMainPanelVM:Update(ActivityData)
    self.GetMusicalNoteTabSelected = true
    self.CallFriendTabSelected = false
    if nil == ActivityData then
        return
    end
    self.ActivityID = ActivityData.ActivityID
    self:InitRewardList(ActivityData)
    self:InitTaskList(ActivityData)
    self:QuerySocialFriendList(ActivityData)
    self:InitInviteCodeNode(ActivityData)
    local NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeInviteeBindList)
    if NodeList and #NodeList > 0 then
        self.GetInviteListNodeID = NodeList[1].Head.NodeID
    end
    NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeBindInviterCode)
    if NodeList and #NodeList > 0 then
        self.BindeCodeNodeID = NodeList[1].Head.NodeID
        self.BindCode = NodeList[1].Extra.BindCode.Code
        self.IsBind = not string.isnilorempty(self.BindCode)
    end
end
--- 国内版本，初始化邀请码并发送好友角色的查询请求信息
function OpsConcertMainPanelVM:QuerySocialFriendList(ActivityData)
    local NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeCreatInviteCode)
    if NodeList and #NodeList > 0 then
        self.InviteCode = NodeList[1].Extra.InviterCode.InviterCode
        self.InviteCode = tostring(self.InviteCode)
    end
    local SocialFriendList = _G.LoginMgr.AllFriendServers or {}
    if  #SocialFriendList < 1 then
        self.CallFriendListEmpty = true
        self.MoreBtnIsVisible = false
        return
    end
    --构建查询用的OpenID信息
    local OpenIDs = {}
    for _, SocialFriend in ipairs(SocialFriendList) do
        table.insert(OpenIDs, tostring(SocialFriend.Role.OpenID))
    end
    local MsgID = CS_CMD.CS_CMD_QUERY_LAST_LOGIN_ROLES
	local SubMsgID = 0
	local MsgBody = {
        Cmd = SubMsgID,
        OpenIDs = OpenIDs
    }
    --发送查询请求
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


--- 国内版本，初始化微信/QQ好友列表，拉取登录信息初始化
function OpsConcertMainPanelVM:InitSocialFriendList(FriendMap)
    self.SocialFriendVMListInfo = {}
    local SocialFriendList = _G.LoginMgr.AllFriendServers
    if nil == SocialFriendList or #SocialFriendList < 1 then
        self.CallFriendListEmpty = true
        self.MoreBtnIsVisible = false
        return
    end
    ---根据上一次登录时间筛选出所有可以显示的微信/QQ好友列表，拉取登录信息初始化
    local TimeStamp30Days = 30 * 24 * 3600 
    for _, SocialFriend in ipairs(SocialFriendList) do
        local OpenID = SocialFriend.Role.OpenID
        local FriendRoleInfo = FriendMap[OpenID]
        if FriendRoleInfo then
            local Param = {}
            --- 微信/QQ好友的昵称
            Param.FriendName = SocialFriend.Name
            --- 微信/QQ好友的头像
            Param.HeadUrl = SocialFriend.HeadUrl
            --- 游戏内的角色名称
            Param.GameName =FriendRoleInfo.Name
            Param.UserOpenID = OpenID
            Param.InviterCode = self.InviteCode
            Param.LoginTime = FriendRoleInfo.LogoutTime
            local OfflineTime = TimeUtil.GetServerLogicTime() - FriendRoleInfo.LogoutTime
            local IsTimeOver =  OfflineTime >= TimeStamp30Days
            local Tips = IsTimeOver and "超过30天(包含)" or  "未达到30天"
            _G.FLOG_INFO(string.format(" 玩家 OpenID: %s, %s, 离线时间 :%s", tostring(OpenID), Tips, tostring(FriendRoleInfo.LogoutTime)))
            if IsTimeOver and FriendRoleInfo.IsOnline == false then
                table.insert(self.SocialFriendVMListInfo, Param)
            end
        end
    end
    if #self.SocialFriendVMListInfo < 1 then
        self.CallFriendListEmpty = true
        self.MoreBtnIsVisible = false
        return
    end
    self.CallFriendListEmpty = false
    self.MoreBtnIsVisible = true
    self:UpdateSocialFriendList()
end

--- 增加20个微信/QQ好友
function OpsConcertMainPanelVM:UpdateSocialFriendList()
    local CurrentShowFriendItem = self.SocialFriendVMList:GetItems()
    local EndIndex = 20
    if nil ~= CurrentShowFriendItem then
        EndIndex = #CurrentShowFriendItem + 20
    end
    if EndIndex >= #self.SocialFriendVMListInfo then
        EndIndex = #self.SocialFriendVMListInfo
        self.MoreBtnIsVisible = false
    end
    self.CurrentShowFriendVMListInfo = {}
    for i = 1, EndIndex do
        table.insert(self.CurrentShowFriendVMListInfo, self.SocialFriendVMListInfo[i])
    end
    self.SocialFriendVMList:UpdateByValues(self.CurrentShowFriendVMListInfo)
end


--- 初始化任务列表
function OpsConcertMainPanelVM:InitTaskList(ActivityData)
     ---初始化任务列表
     local TaskVMListParams = {}
     ---每日登录
     local NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeAccumulativeLoginDay)
     if NodeList then
         for _, Node in ipairs(NodeList) do
             local Param = self:GetTaskInfo(Node)
             if Param.IconReceivedVisible == false then
                Param.Priority = 4
             else
                Param.Priority = -1
             end
             table.insert(TaskVMListParams, Param)
         end
     end
     ---首次分享
     NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeShareInviterCode)
     if NodeList then
         for _, Node in ipairs(NodeList) do
             local Param = self:GetTaskInfo(Node)
             if Param.IconReceivedVisible == false then
                Param.Priority = 3
             else
                Param.Priority = -2
             end
             table.insert(TaskVMListParams, Param)
         end
     end
     ---完成副本
     NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeFinishScene)
     if NodeList then
         for _, Node in ipairs(NodeList) do
             local Param = self:GetTaskInfo(Node, nil, true)
             if Param.IconReceivedVisible == false then
                Param.Priority = 2
             else
                Param.Priority = -3
             end
             table.insert(TaskVMListParams, Param)
         end
     end
     ---绑定玩家
     NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeBindInvitee)
     if NodeList then
         for _, Node in ipairs(NodeList) do
             local CurrFinTimes = Node.Head.CurrFinTimes
             local ActivityNode = ActivityNodeCfg:FindCfgByKey(Node.Head.NodeID)
             if ActivityNode then
                 local RewardNum = ActivityNode.Rewards[1].Num
                 local TaskTitle = ActivityNode.NodeTitle
                 local Des = string.format(LSTR(1600015), CurrFinTimes*RewardNum) --乐章无上限，已获得%d
                 local Param = {
                 IsValid = true,
                 TaskTitle = TaskTitle,
                 Des = Des,
                 Icon = VoucherIcon,
                 Num = RewardNum,
                 BtnInfoVisible = false,
                 BtnDetailVisible = true,
                 ItemID = self.LotteryPropID,
                }
                 Param.Priority = 1
                 table.insert(TaskVMListParams, Param)
             end
         end
     end
     ---
     table.sort(TaskVMListParams, function(node1,node2)
        return node1.Priority > node2.Priority
        end)
     self.TaskVMList:UpdateByValues(TaskVMListParams)
end
---初始化奖励列表
function OpsConcertMainPanelVM:InitRewardList(ActivityData)
    local NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeLotteryDrawNoLayBack)
    local LotteryNode = nil
    if NodeList and #NodeList > 0 then
        local NodeID  = NodeList[1].Head.NodeID
        self.LotteryNodeID = NodeID
        LotteryNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    end
    if LotteryNode then
        local PrizePoolID = LotteryNode.Params[1]
        self.LotteryAwardNodes = CommercializationRandCfg:FindAllCfg("PrizePoolID = "..PrizePoolID)
        if self.LotteryAwardNodes then
            table.sort(self.LotteryAwardNodes, function(node1,node2)
            return node1.DropWeight > node2.DropWeight
            end)
            self.RewardVMList:Clear()
        end
        local LotteryCousumeNode = CommercializationRandConsumeCfg:FindCfg("PoolID = "..PrizePoolID)
        if LotteryCousumeNode then
            self.LotteryConsumeNum = LotteryCousumeNode.ConsumeResNum[1]
            self.TotolLotteryNum = #LotteryCousumeNode.ConsumeResNum
            self.LotteryPropID = LotteryCousumeNode.ConsumeResID
        end
    end
    self:UpdateRewardList(ActivityData)
end

--- 更新奖励列表的获取状况
function OpsConcertMainPanelVM:UpdateRewardList(ActivityData)
   local NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeLotteryDrawNoLayBack)
   self.LotteryInfo = NodeList[1].Extra.Lottery
   local DropedID = self.LotteryInfo.DropedResID or {}
   self.DropedResID = {}
   for i, v in ipairs(self.LotteryAwardNodes)do
       if table.contain(DropedID, v.ID) then
            self.LotteryAwardNodes[i].IconReceivedVisible = true
       end
   end
   self.RewardVMList:Clear()
   self.RewardVMList:UpdateByValues(self.LotteryAwardNodes)
   self:UpdateLotteryCousume()
   self.PerformanceText = LSTR(1600003) --演奏
   if #DropedID >= #self.LotteryAwardNodes then
        self.IsPerformComplete = true
        --演奏完成，动效消失
        self.IsEnoughForPerform = false
        self.PerformanceText = LSTR(1600017) --演奏完毕
    end
end

--- 更新抽奖道具的数量
function OpsConcertMainPanelVM:UpdateLotteryCousume()
    self.CurrentMusicalNoteNum = _G.BagMgr:GetItemNum(self.LotteryPropID)
    if self.CurrentMusicalNoteNum < self.LotteryConsumeNum then
        self.IsEnoughForPerform = false
    else
        self.IsEnoughForPerform = true
    end
    self.NumText = string.format("%d/%d", self.CurrentMusicalNoteNum, self.LotteryConsumeNum)
end

--- 初始化分享邀请码的节点
function OpsConcertMainPanelVM:InitInviteCodeNode(ActivityData)
    local NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeShareInviterCode)
    if NodeList and #NodeList > 0 then
        local NodeID  = NodeList[1].Head.NodeID
        self.ShareRewardStatus = NodeList[1].Head.RewardStatus
        local InviteCodeNode = ActivityNodeCfg:FindCfgByKey(NodeID)
        if InviteCodeNode then
            self.ShareParams = InviteCodeNode.Params
        end
    end
end


function OpsConcertMainPanelVM:SetMusicalNoteTabSelected()
    self.GetMusicalNoteTabSelected = true
    self.CallFriendTabSelected = false
end

function OpsConcertMainPanelVM:SetCallFriendTabSelected()
    self.GetMusicalNoteTabSelected = false
    self.CallFriendTabSelected = true
end

function OpsConcertMainPanelVM:GetTaskInfo(Node, Des, BtnInfoVisible, BtnDetailVisible)
    local Head = Node.Head
    local NodeID  = Head.NodeID
    local CurrFinTimes = Head.CurrFinTimes
    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    if ActivityNode then
        local TotalTimes = ActivityNode.MaxFinTimes
        local RewardList = ActivityNode.Rewards
        local RewardNum = RewardList[1].Num
        local TaskTitle = ActivityNode.NodeTitle
        local HelpInfoDes = ""
        TaskTitle = TaskTitle .. string.format("(%d/%d)", CurrFinTimes, TotalTimes)
        local Des = string.format(LSTR(1600016),CurrFinTimes*RewardNum, TotalTimes*RewardNum) --累计获得:%d/%d
        local IconReceivedVisible = CurrFinTimes == TotalTimes
        BtnInfoVisible = BtnInfoVisible or false
        BtnDetailVisible = BtnDetailVisible or false
        if BtnInfoVisible then
            HelpInfoDes = ActivityNode.NodeDesc
        end
        return {
            IsValid = true,
            TaskTitle = TaskTitle,
            Des = Des,
            Icon = VoucherIcon,
            Num = RewardNum,
            BtnInfoVisible =
                BtnInfoVisible,
            BtnDetailVisible = BtnDetailVisible,
            IconReceivedVisible = IconReceivedVisible,
            HelpInfoDes = HelpInfoDes,
            ItemID = self.LotteryPropID,
        }
    end
    return {IsValid = false}
end

function OpsConcertMainPanelVM:SetInviteList(RoleData)
    self.BindPlayerList = RoleData
end
return OpsConcertMainPanelVM