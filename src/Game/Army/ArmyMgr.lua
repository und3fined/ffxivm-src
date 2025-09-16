-- Author: daniel
-- Date : 2023-02-09
-- Description : 部队
--
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ArmyMainVM
local ArmyEntryVM = require("Game/Army/ItemVM/ArmyEntryVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyTextColor = ArmyDefine.ArmyTextColor
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local ProtoCommon = require("Protocol/ProtoCommon")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local MsgTipsID = require("Define/MsgTipsID")
local RichTextUtil = require("Utils/RichTextUtil")
local GroupStoreIconCfg = require("TableCfg/GroupStoreIconCfg")
local GroupStoreEnlargeCfg = require("TableCfg/GroupStoreEnlargeCfg")
local GroupStoreCfg = require("TableCfg/GroupStoreCfg")
local BitUtil = require("Utils/BitUtil")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local ModuleOpenMgr
local ProtoRes = require("Protocol/ProtoRes")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ArmyErrorCode = ArmyDefine.ArmyErrorCode
local ItemCfg = require("TableCfg/ItemCfg")
local GroupLogCfg = require("TableCfg/GroupLogCfg")
local GroupLogType = ProtoCS.GroupLogType
local GroupBonusStateDataCfg = require("TableCfg/GroupBonusStateDataCfg")
local GroupBonusStateGroupCfg = require("TableCfg/GroupBonusStateGroupCfg")
local GroupUplevelpermissionCfg = require("TableCfg/GroupUplevelpermissionCfg")
local ScoreMgr = require("Game/Score/ScoreMgr")
local GroupDefaultCategoryCfg = require("TableCfg/GroupDefaultCategoryCfg")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local StringTools = _G.StringTools
local CommonUtil = require("Utils/CommonUtil")
local GrandCompanyCfg = require("TableCfg/GrandCompanyCfg")
local GroupEmblemTotemCfg = require("TableCfg/GroupEmblemTotemCfg")
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType
local InviteSignSideDefine = require("Game/Common/InviteSignSideWin/InviteSignSideDefine")
local InviteMenu = InviteSignSideDefine.InviteMenu
local MenuValues = InviteSignSideDefine.MenuValues
local ConditionMgr = require("Game/Interactive/ConditionMgr")

local ArmyLogType = ArmyDefine.ArmyLogType
local ArmyUpLevelPerermissionType = ArmyDefine.ArmyUpLevelPerermissionType

local LSTR = _G.LSTR
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_GROUP_CMD
local FLOG_ERROR = _G.FLOG_ERROR
local UIViewMgr
local UIViewID = _G.UIViewID
local GameNetworkMgr
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local TimerMgr

-- @class ArmyMgr : MgrBase
local ArmyMgr = LuaClass(MgrBase)
-- 是否部队Tops日志 刷新部队日志
local bTopLogs = false
-- 最后查询部队条件
local LastSearchArmyInput = nil
-- 页数
local PageNums = ArmyDefine.PageNums

-- 是否搜索满员部队
local bFullCapacity = nil

-- 侧边栏类型
local SidebarType = SidebarDefine.SidebarType

--- OnInit
---@field MyArmyID number @我的部队ID
---@field MyArmyInfo GroupFullInfo @我的部队信息
---@field CachePageData table @分页数据
---@field QueryTimerID number @查询定时器ID
---@field QueryCallbackInfo table @查询回调函数
---@field QueryMemberCallbackInfo table @查询成员回调函数
---@field QueryPendingInfo table @查询等待信息
---@field ArmyViewModels table<number, ArmyEntryVM> @部队视图模型
---@field SearchArmyTab table @查询部队缓存
---@field LastLogID number @保留上次最后的LogID
function ArmyMgr:OnInit()
    self.QuerySimpleID = 0
    self.bQueryArmy = false
    self.SelfArmyID = nil
    self.SelfArmyInfo = nil
    self.SelfRoleInfo = nil
    self.LeaderRoleID = nil
    self.SelfCategoryData = nil
    self.CachePageData = {}
    self.QueryTimerID = nil
    --self.QueryMemberTimerID = nil
    self.QueryStateCallback = nil
    self.QueryCallbackInfo = {}
    self.QueryMemberCallbackInfo = {}
    self.QueryArmySimpleCallbackInfo = {}
    self.QueryPendingInfo = {}
	self.ArmyViewModels = {}
    self.SearchArmyTab = nil
    --todo 用于申请详细数据，给聊天用，后续服务器处理完需要删除
    self.bIsOnlyGetData = false
    ---仓库数据 Store = {Index, Name, Capacity, Size, ExpansionNum, Items, IconId}
    self.Stores = {}
    self.RedDotMap = {}
    ---保存仓库红点名，用于取消和区分重复添加
    self.StoreRedDotNameList = {}
    ---保存仓库已读红点
    self.CancelStoreRedDotList = {}
    ---已经发送的红点
    self.SendCancelStoreRedDotList = {}
    -- ---见习晋升计时器
    -- self.InternUpTimer = nil
    self.ArmyBonusStates = {}
    self.ArmyUsedBonusStates = {}
    ---特效最大可持有数量
    self.ArmyMaxBonusStatesNum = nil
    ---特效最大可生效数量
    self.ArmyMaxUsedBonusStatesNum = nil
    ---部队金币仓库金币数量
    self.MoneyStoreNum = 0
    ---错误提示CD
    self.UseGroupBonusStateTypeErrorNextTime = 0
    self.UseGroupBonusStateNumErrorNextTime = 0
    ---特效查询回调
    self.QueryGroupBonusStateCallback = nil
    ---公会列表是否已经全部获取完了
    self.ArmyListIsEnd = false
    ---特效数据版本
    self.SEDataVersion = nil
    ---是否打开过招募界面，用于判断招募时打开是否删除红点，降低开销
    self.IsRecruitPanelHaveOpened = nil
    ---部队状态，用于判断拉取的数据
    self.ArmyState = nil
    ---部队解锁状态，用于判断是否是被邀请解锁（超过25级自动解锁的情况，这个bool是false,不能判断部队是否解锁）
    self.IsInvitedUnlock = nil
end

---region 分页
local PageType = {
    AllArmy = 1, -- 部队
    ArmySearch = 2, -- 部队条件
    Log = 3, -- 日志
    JoinApply = 4, -- 加入部队申请
    ArmyInvite = 5, -- 部队邀请
}

--- 获取初始分页数据
---@param Limit number @条数
function ArmyMgr:InitPageByType(PType, Limit)
    self.CachePageData[PType] = {
        Offset = 0, -- 开始索引
        Limit = Limit, -- 拉取条数
        bPulling = false, -- 是否正在拉取
    }
end

function ArmyMgr:ResetAll()
    local Len = table.length(PageType)
    for i = 1, Len do
        if self.CachePageData == nil then
            self.CachePageData = {}
        end
        self.CachePageData[i] = {
            Offset = 0, -- 开始索引
            Limit = PageNums[i], -- 拉取条数
            bPulling = false, -- 是否正在拉取
        }
    end
end

function ArmyMgr:ResetPageData(PType)
    self:InitPageByType(PType, PageNums[PType])
    return self.CachePageData[PType]
end

--- Get
function ArmyMgr:GetPageDataByType(PType)
    if self.CachePageData[PType] == nil then
        self:InitPageByType(PType, PageNums[PType])
    end
    return self.CachePageData[PType]
end

--- Set
function ArmyMgr:SetPageDataOffset(PType, Offset)
    -- 结束
    if self.CachePageData == nil then
        self.CachePageData = {}
    end
    if self.CachePageData[PType] == nil then
        self.CachePageData[PType] = {
            Limit = PageNums[PType], -- 拉取条数
        }
    end
    self.CachePageData[PType].bPulling = false
    self.CachePageData[PType].Offset = Offset
end
---endregion 分页

function ArmyMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
    TimerMgr = _G.TimerMgr
    UIViewMgr = _G.UIViewMgr
    ModuleOpenMgr = _G.ModuleOpenMgr
    ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
end

function ArmyMgr:OnEnd()
    GameNetworkMgr = nil
    GameNetworkMgr = nil
    TimerMgr = nil
    UIViewMgr = nil
    ArmyMainVM = nil
end

function ArmyMgr:OnShutdown()
    self.QuerySimpleID = nil
    self.bQueryArmy = nil
    self.SelfArmyID = nil
    self.SelfArmyInfo = nil
    self.SelfRoleInfo = nil
    self.LeaderRoleID = nil
    self.SelfCategoryData = nil
    self.CachePageData = nil
    if self.QueryTimerID ~= nil then
        self:UnRegisterTimer(self.QueryTimerID)
        self.QueryTimerID = nil
    end
    -- if self.QueryMemberTimerID ~= nil then
    --     self:UnRegisterTimer(self.QueryMemberTimerID)
    --     self.QueryMemberTimerID = nil
    -- end
    self.QueryCallbackInfo = nil
    self.QueryMemberCallbackInfo = nil
    self.QueryArmySimpleCallbackInfo = nil
    self.QueryPendingInfo = nil
	self.ArmyViewModels = nil
    self.SearchArmyTab = nil
    if self.InternUpTimer ~= nil then
        self:UnRegisterTimer(self.InternUpTimer)
        self.InternUpTimer = nil
    end
end

function ArmyMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY_SELF, self.OnNetMsgMyArmyInfo)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY, self.OnNetMsgGetArmyData)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY_LOGS, self.OnNetMsgGetArmyLogs)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_CREATE, self.OnNetMsgArmyCreate)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_DISBAND, self.OnNetMsgArmyDisband)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_NOTIFY_DISBAND, self.OnNetMsgArmyDisbandNotify)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUIT, self.OnNetMsgArmyQuit)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_EDIT_NOTICE, self.OnNetMsgArmyEditNotice)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_EDIT_RECRUIT_INFO, self.OnNetMsgArmyEditRecruitInfo)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_EDIT_EMBLEM, self.OnNetMsgArmyEditEmblem)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_EDIT_NAME, self.OnNetMsgArmyEditName)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_EDIT_ALIAS, self.OnNetMsgArmyEditAlias)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_SET_MEMBER_CATEGORY, self.OnMsgSetMemberClass)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_TRANSFER_LEADER, self.OnMsgTransferLeader)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_SEARCH, self.OnMsgArmySearch)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_APPLY, self.OnMsgArmyApply) ---玩家申请加入部队
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY_APPLY_LIST, self.OnMsgQueryApplyList)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_ACCEPT_APPLY, self.OnMsgArmyAcceptApply)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_NOTIFY_JOIN, self.OnMsgArmyNotifyJoin)--- 通知玩家加入部队
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_REFUSE_APPLY, self.OnMsgArmyRefuseApply)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_SEND_INVITATION, self.OnMsgArmySendInvita)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY_INVITATIONS, self.OnMsgQueryInviteList)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_NOTIFY_INVITATION, self.OnMsgArmyNotifyInvite)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_IGNORE_INVITATION, self.OnMsgArmyIgnoreInvita)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_ACCEPT_INVITATION, self.OnMsgArmyAcceptInvita)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_KICK_MEMBER, self.OnMsgArmyKickMember)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_NOTIFY_KICKED, self.OnMsgArmyNotifyKicked)
    -- self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_NOTIFY_SELF, self.OnNetMsgArmyNotifyQuit)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_EDIT_INFO, self.OnNetMsgArmyEditInfo)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_NOTIFY_APPLICATION_LIST, self.OnNetMsgNotifyAppliActionList)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_CHECK_SLOGAN, self.OnNetMsgCheckSlogan)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_ADD_GROUP_SCORE, self.OnNetMsgAddGroupScore)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_STORE_DEPOSIT_ITEM, self.OnNetMsgGroupStoreDepositItem)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_STORE_FETCH_ITEM, self.OnNetMsgGroupStoreFetChItem)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_STORE_ADD_EXTRA_GRID, self.OnNetMsgGroupStoreAddExtraGrid)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_STORE_SET_STORE_NAME, self.OnNetMsgGroupStoreSetStoreName)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_STORE_REQ_STORE_INFO, self.OnNetMsgGroupStoreReqStoreInfo)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_STORE_REQ_STORE_BASE_INFO, self.OnNetMsgGroupStoreReqStoreBaseInfo)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_CATEGORY_PERMISSION_CHANGE, self.OnMsgClassPermissionChange)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_STORE_STORE_CHANGE, self.OnMsgGroupItemChange)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_CATEGORY_UPDATE, self.OnMsgCategoryChange)
    -- self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY_APPLIED_GROUPS, self.OnNetMsgArmyAppliedGroups) --- 查询自己申请过的部队列表(可能不需要)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_NOTIFY_MEMBER_JOIN, self.OnMsgNotifyMemberJoin)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_NOTIFY_MEMBER_LEAVE, self.OnMsgNotifyMemberLeave)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY_MEMBERS, self.OnMsgQueryMembers)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_NOTIFY_REDS, self.OnMsgNotifyRed)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_READ_BAG, self.OnMsgDelStoreRedDot)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY_ROLES_GROUP, self.OnNetMsgQueryArmyInfoByRoleIDs)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_CATEGORY_INTERN_UP_CONFIRM, self.OnNetMsgGroupCategoryInternUpConfirm)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_EDIT_CATEGORY, self.OnNetMsgGroupEditCategory)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY_CATEGORY, self.OnNetMsgGroupQueryCategory)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_NOTIFY_ALIAS, self.OnNetMsgGroupNotifyAlias)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY_EDITED_TIMES, self.OnNetMsgQueryGroupEditedTimes)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_BONUS_STATE_QUERY, self.OnNetMsgGroupBonusStateQuery)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_BONUS_STATE_BUY, self.OnNetMsgGroupBonusStateBuy)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_BONUS_STATE_USE, self.OnNetMsgGroupBonusStateUse)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_BONUS_STATE_STOP, self.OnNetMsgGroupBonusStateStop)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_CHECK_SENSITIVE_TEXT, self.OnNetMsgGroupCheckSensitiveText)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY_MEMBERS_BY_CATEGORY, self.OnNetMsgQueryGroupMemberByCategory)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_NOTIFY_LOG, self.OnNetMsgGroupNotifyLog)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_MONEY_BAG_DEPOSIT, self.OnNetMsgGroupMoneyBagDeposit)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_MONEY_BAG_WITHDRAW, self.OnNetMsgGroupMoneyBagWithdraw)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_MONEY_BAG_QUERY, self.OnNetMsgGroupMoneyBagQuery)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_NOTIFY_MEMBER_ONLINE, self.OnNetMsgNotifyMemberOline)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY_GROUP_BASE_INFO, self.OnNetMsgQuertGroupBaseInfo)--信息界面数据
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_INVITE_SET_READ, self.OnNetMsgGroupInviteSetRead)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY_SELF_MEMBERS, self.OnNetMsgGroupQuerySelfMember)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_PETITION_GAIN, self.OnNetMsgGroupPeitionGain) --【署名】领取组建书
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_PETITION_QUERY, self.OnNetMsgGroupPeitionQuery) --【署名】查询组建书
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_PETITION_EDIT, self.OnNetMsgGroupPeitionEdit) --【署名】编辑组建书信息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_PETITION_CANCEL, self.OnNetMsgGroupPeitionCancel)--【署名】撤销组建部队
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_SIGN_INVITE, self.OnNetMsgGroupSignInvite)--【署名】邀请署名
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_SIGN_AGREE, self.OnNetMsgGroupSignAgree)--【署名】同意署名
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_SIGN_REFUSE, self.OnNetMsgGroupSignRefuse)--【署名】拒绝署名
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_SIGN_CANCEL, self.OnNetMsgGroupSignCancel)--【署名】取消署名
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_SIGN_QUERY_INVITES, self.OnNetMsgGroupSignQueryInvites)-- 查询署名邀请列表
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_GRAND_COMPANY_CHANGE, self.OnNetMsgGroupGrandCompanyChange)-- 转国防联军
    -- self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_ACTIVITY_SET, self.OnNetMsgGroupActivitySet)-- 设置活动偏好
    -- self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_ACTIVITY_SET_TIME, self.OnNetMsgGroupActivitySetTime)-- 设置活跃时间
    -- self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_RECRUIT_SET_PROF, self.OnNetMsgGroupRecruitSetProf)-- 设置招募职业偏好
    ----todo
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_SIGN_INVITED_TOC, self.OnSignInvitedToc)-- 【署名】推送被邀请署名
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_PETITION_CANCEL_TOC, self.OnGroupPeitionCancelToc)-- 【署名】推送被取消署名
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_SIGN_NUM_TOC, self.OnSignNumToc)-- 【署名】推送署名人数
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_GRAND_COMPANY_TOC, self.OnNetMsgGroupGrandCompanyToc)-- 【部队数据】推送国防联军变化
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_PROFILE_EDIT, self.OnNetMsgProfileEdit)-- 【情报】部队情报界面编辑
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_NOTIFY_REPUTATION, self.OnNetMsgNotifyReputation)-- 【特效】部队友好关系变化推送

end

function ArmyMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.SidebarItemTimeOut, self.OnGameEventSidebarItemTimeOut) --侧边栏Item超时
    self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnRecommendArmyModuleOpen) -- 解锁时显示红点
    self:RegisterGameEvent(EventID.LoadMapFinish, self.OnLeavePWorld) --- 离开副本处理弹窗(进出副本都会触发，但是进入副本不会有邀请缓存，不用额外判断)/之前的事件显示tips会不成功，改成进入地图时触发
end
-------------- Request Part Start-------------------------

function ArmyMgr:OnGameEventLoginRes()
    print("ArmyMgr:OnGameEventLoginRes")
    ---未解锁时不获取数据/模块解锁是依靠本地等级判断的，如果换机登录，被邀请加入触发的解锁状态会被清理，不在这里拦截登录拉取，登录下发会有判断，有部队才拉取全量数据
    -- local ModuleID = ProtoCommon.ModuleID
    -- if  not _G.ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDArmy) then
	-- 	return
	-- end

    --非0表示不是正式角色，还没有命名的临时角色或者演示场景角色
	if _G.DemoMajorType ~= 0 then
        return
    end

    self:SendGetArmyInfoMsg()
end

--- 获取自己部队信息Rsp
function ArmyMgr:OnNetMsgMyArmyInfo(MsgBody)
    local Msg = MsgBody.QuerySelf
    if Msg == nil then
        return
    end
    local ArmyID = 0

    ---先判断状态
    self.ArmyState = Msg.State
    ---被邀请解锁的情况
    self.IsInvitedUnlock = Msg.IsUnlock
    if self.IsInvitedUnlock and self.ArmyState ~= ProtoCS.RoleGroupState.RoleGroupStateJoinedGroup then
        self:SetArmyModuleOpen()
    end
    local Alias
    ---清理一下署名提醒创建红点/创建提醒红点用于断线重连时更新 / 对应状态进判断自己重新添加
    RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID.ArmyCreateRemind)
    RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID[ProtoCS.GroupRedDotType.GroupRedDotTypeSignFull])
    local RoleGroupStateData = Msg.RoleGroupStateData
    if RoleGroupStateData then
        if self.ArmyState == ProtoCS.RoleGroupState.RoleGroupStateInit then
            ---未解锁
            if nil == Msg[RoleGroupStateData] then
                return
            end
            local Init = Msg[RoleGroupStateData]
            if Init and Init.UnreadInviteJoinGroup then
                --- 如果有未读信息，请求一次邀请数据
                self:SendArmyGetInviteListMsg()
            end
            self.SelfArmyID = 0
        elseif self.ArmyState == ProtoCS.RoleGroupState.RoleGroupStateGainedPetition then
            ---领取组建书
            self.SelfArmyID = 0
            local GainedPetition = Msg[RoleGroupStateData]
            ---如果署名人数满了，添加红点
            local SignNum = 0
            if GainedPetition then
                SignNum = GainedPetition.SignedNum
            end
            local MaxSignNum = GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.GlobalCfgGroupSignNum) or 1
            if SignNum >= MaxSignNum then
                RedDotMgr:AddRedDotByID(ArmyDefine.ArmyRedDotID.ArmyCreateRemind)
            else
                RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID.ArmyCreateRemind)
            end
        elseif self.ArmyState == ProtoCS.RoleGroupState.RoleGroupStateSignedOtherPetition then
            ---已署名
            self.SelfArmyID = 0
            local SignedPetition = Msg[RoleGroupStateData]
            local SignNum = 0
            if SignedPetition then
                SignNum = SignedPetition.SignedNum
            end
            local MaxSignNum = GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.GlobalCfgGroupSignNum) or 1
            if SignNum >= MaxSignNum then
                RedDotMgr:AddRedDotByID(ArmyDefine.ArmyRedDotID[ProtoCS.GroupRedDotType.GroupRedDotTypeSignFull])
            else
                RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID[ProtoCS.GroupRedDotType.GroupRedDotTypeSignFull])
            end
        elseif self.ArmyState == ProtoCS.RoleGroupState.RoleGroupStateJoinedGroup then
            ---加入部队
            local JoinedGroup = Msg[RoleGroupStateData]
            if JoinedGroup then
                self.SelfArmyID = JoinedGroup.GroupID
                print("MsgID=500,GroupID="..self.SelfArmyID)
                ArmyID = self.SelfArmyID 
                self:SetCompanyChangeTime(JoinedGroup.LastGrandCompanyChangeTime)
                if self:IsInArmy() then
                    self:SetArmyModuleOpen()
                    if nil == self.SelfArmyInfo then
                        self.SelfArmyInfo = {}
                    end
                    if nil == self.SelfArmyInfo.Members then
                        self.SelfArmyInfo.Members = {}
                    end
                    ---登录时下发的成员数据结构和完整下发的数据结构不一样，转化一下
                    for _, Simple in ipairs(JoinedGroup.Members) do
                        local Member = {}
                        Member.Simple = Simple
                        table.insert(self.SelfArmyInfo.Members, Member)
                        if Member.Simple.RoleID == MajorUtil.GetMajorRoleID() then
                            self.SelfRoleInfo = Simple
                        end
                        if Member.Simple.CategoryID == ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_PRESIDENT then
                            if nil == self.SelfArmyInfo.Simple then
                                self.SelfArmyInfo.Simple = {}
                            end
                            if nil == self.SelfArmyInfo.Simple.Leader then
                                self.SelfArmyInfo.Simple.Leader = {}
                            end
                            self.SelfArmyInfo.Simple.Leader.RoleID = Member.Simple.RoleID
                        end
                    end
                    -- message Category
                    -- {
                    --   int32 ID = 1; // 阶级 ID
                    --   int32 IconID = 3;                                   // 阶级 ICON 配置 ID
                    --   string Name = 4;                                    // 名称
                    --   repeated GroupPermissionType PermisstionTypes = 5;  // 阶级权限列表
                    -- }
                    -- message GroupCategoryPermission
                    -- {
                    -- int32 CategoryID = 1;
                    -- repeated GroupPermissionType Types = 2; // 新的权限列表
                    -- }
                    ---现在登陆只下发权限数据，结构和全量的不一样，需要转换一下
                    local Categories = {}
                    for _, CategoryPermission in ipairs(JoinedGroup.CategoryPermissions) do
                        local Category = {ID = CategoryPermission.CategoryID, PermisstionTypes = CategoryPermission.Types}
                        table.insert(Categories, Category)
                    end
                    self.SelfArmyInfo.Categories = Categories
                    if self.SelfRoleInfo then
                        self.SelfCategoryData = self:GetCategoryDataByID(self.SelfRoleInfo.CategoryID)                  
                    else
                        _G.FLOG_ERROR("[ArmyMgr] OnNetMsgMyArmyInfo Members is do not include Player, ArmyID:", JoinedGroup.ID)
                    end
                    -- ---判断是否是见习，是的话就添加计时器
                    --self:SetInternUpTimer()
                    ---部队简称设置
                    Alias = JoinedGroup.Alias
                    local ArmySimples = {{RoleID = MajorUtil.GetMajorRoleID(), Simple = {Alias = JoinedGroup.Alias}}}
                    self:SetRoleArmyAlias(ArmySimples)
                    ---队徽设置
                    self:SetEmblem(JoinedGroup.Emblem)
                end
            end
        end
    end

    ---断线重连时需要发一次部队简称更新事件
    local OldAlias = self:GetArmyAlias()
    self:SetArmyAlias(Alias)
    self:SendArmyShortNameChange(Alias, OldAlias)

    local LastQuitTime = Msg.LastQuitTime
    self:ArmyRedDotAllUpdate(Msg.RedDots)
    ArmyMainVM:SetMyArmyBasicInfo(ArmyID, LastQuitTime)
    EventMgr:SendEvent(EventID.ArmySelfArmyIDUpdate)
    ---聊天推送
    local ChatMgr = _G.ChatMgr
    ---登录时需要下发公告信息，等待服务器处理,公告为空时不推送
    if Msg and Msg.Notice and not string.isnilorempty(Msg.Notice) then
        -- LSTR string:公告
        local Text = string.format("%s: %s", LSTR(910055), Msg.Notice)
        ChatMgr:AddArmyChatMsg(Text, 0, true)
    end
    ---服务器推送上线消息给本人时，因为部队数据没下发导致判断为无部队拦截掉，客户端特殊处理推送自己上线的消息
    RoleInfoMgr:QueryRoleSimple(MajorUtil.GetMajorRoleID(), function(_, RoleVM)
        -- LSTR string:上线了
        local Str = LSTR(910026)
        local Text = string.format("%s%s", RoleVM.Name or "", Str)
        local ChatMgr = _G.ChatMgr
        ChatMgr:AddArmyChatMsg(Text, 0, true)
        end, nil, true)
    --todo 临时处理，保证聊天用到部队数据时有数据，后续服务器处理完后需要改掉
    if ArmyID == nil then
        -- LSTR string:网络错误，请重试
        MsgTipsUtil.ShowTips(string.format(LSTR(910208)))
    else
        local bJoinedArmy = ArmyID > 0
        if bJoinedArmy then
            self.bIsOnlyGetData = true
            ArmyMgr:SendGetArmyDataMsg(ArmyID)
        end
    end
    --- 根据招募状态/是否是部队长/本地红点数据 判断是否显示招募红点，登录不下发部队长roleid,用CategoryID判断
    if self:GetCategoryIDByRoleID(MajorUtil.GetMajorRoleID()) == ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_PRESIDENT and not RedDotMgr:GetIsSaveDelRedDotByID(ArmyDefine.ArmyRedDotID.ArmyInformationEditRemind)  then
        RedDotMgr:AddRedDotByID(ArmyDefine.ArmyRedDotID.ArmyInformationEditRemind, nil, true)
        self.IsRecruitPanelHaveOpened = false
    else
        self.IsRecruitPanelHaveOpened = true
    end
    
end

--- 查询指定部队的信息Rsp
--- 如果是自己部队ID, 会返回完整信息
--- 非自己部队ID, 返回简要信息
function ArmyMgr:OnNetMsgGetArmyData(MsgBody)
    local Msg = MsgBody.Query
    if Msg.ID == self.SelfArmyID then
        --- 自己部队信息
        self:SetSelfArmyInfo(Msg.Full)
        self:SetInternUpTimer()
        ---todo 使用bIsOnlyGetData控制部队UI不显示，后续等服务器处理完再删
        if not UIViewMgr:IsViewVisible(UIViewID.ArmyPanel) and not self.bIsOnlyGetData then
            UIViewMgr:ShowView(UIViewID.ArmyPanel)
        end
        self.bIsOnlyGetData = false
    else
        --- 查询部队信息
        self.QueryPendingInfo[Msg.ID] = nil
		local ViewModel = self:FindArmyEntryVMInternal(Msg.ID)
		if nil == ViewModel then
			_G.FLOG_ERROR("[ArmyMgr] OnNetMsgGetArmyData ViewModel is nil, ArmyID:", Msg.ID)
		else
			ViewModel:UpdateVM(Msg.Full.Simple)
		end
		self:ProcessQueryCallback(Msg.ID)
    end
end

--- 拉取部队动态日志信息Rsp
function ArmyMgr:OnNetMsgGetArmyLogs(MsgBody)
    local Msg = MsgBody.QueryLogs
    if Msg == nil then
        return
    end
    if not bTopLogs then
        local NextOffset = Msg.Offset + #Msg.Logs
        self:SetPageDataOffset(PageType.Log, NextOffset)
        if Msg.Offset == 0 then
            ArmyMainVM:UpdateArmyLogs(Msg.Logs)
        else
            ArmyMainVM:AddArmyLogs(Msg.Logs)
        end
    else
        ArmyMainVM:UpdateDynamicLogs(Msg.Logs)
    end
end

--- 创建部队Rsp
function ArmyMgr:OnNetMsgArmyCreate(MsgBody)
    local Msg = MsgBody.Create
    if MsgBody.ErrorCode then
    --    if MsgBody.ErrorCode == ArmyErrorCode.ArmyCreateSameName then
    --         return
    --    end
       return
    end
    if Msg == nil then
        return
    end
    local ArmyID = Msg.Group.Simple.ID
    ArmyMainVM:SetMyArmyBasicInfo(ArmyID, 0)
    self:SetSelfArmyInfo(Msg.Group)
    local CallBack = function()
        UIViewMgr:HideView(UIViewID.ArmyPanel)
        local Params = {IsArmyCreate = true}
        UIViewMgr:ShowView(UIViewID.ArmyPanel, Params)
    end
    ArmyMainVM:ArmyCreateAnimPlay(CallBack)
    -- _G.EventMgr:SendEvent(_G.EventID.ArmyUpdateMainView)
    ---特殊处理，聊天推送会比创建下发得早，客户端在创建时特殊处理，推送一下，已和服务器对齐
    local Type =  ArmyLogType.LogTypeCreateGroup
    local CfgData = GroupLogCfg:FindCfgByKey(Type)
    if CfgData == nil then
        return
    end
    local FormatText = CfgData.Text
    local ChatMgr = _G.ChatMgr
    ChatMgr:AddArmyChatMsg(FormatText, 0, true)
    self:ClearInvitePopUpInfo()
    --- 显示招募红点
    RedDotMgr:AddRedDotByID(ArmyDefine.ArmyRedDotID.ArmyInformationEditRemind, nil, true)
    self.IsRecruitPanelHaveOpened = false
    self:SetArmyState(ProtoCS.RoleGroupState.RoleGroupStateJoinedGroup)
    --- 大字提示
    ArmyMgr:ShowJoinArmyTips()
    --- 清理未加入部队相关的红点
    self:ClearNoArmyRedDot()
    --- 清理掉组建书数据
    self:UpdataArmyCreatePeitionData()
    ArmyMainVM:UpdataArmyCreatePeitionData()
    
end

--- 解散部队
function ArmyMgr:OnNetMsgArmyDisband(MsgBody)
    self.SelfArmyID = 0
    ---todo 本地数据有过期风险，等待服务器优化完成后再使用服务器数据
    local GroupName
    if self.SelfArmyInfo.Simple then
        GroupName = self.SelfArmyInfo.Simple.Name
    end
    self:ArmyQuit()
    if GroupName then
        -- LSTR string:已解散[%s]部队
        MsgTipsUtil.ShowTips(string.format(LSTR(910115), GroupName))
    end
end

--- 部队解算通知Rsp
function ArmyMgr:OnNetMsgArmyDisbandNotify(MsgBody)
    local Msg = MsgBody.NotifyDisband
    if Msg == nil then
        return
    end
    self.SelfArmyID = 0
    self:ArmyQuit()
    -- LSTR string:部队[%s]已经解散了
    MsgTipsUtil.ShowTips(string.format(LSTR(910245), Msg.GroupName))
end

--- 离开部队Rsp
function ArmyMgr:OnNetMsgArmyQuit(MsgBody)
    self.SelfArmyID = 0
    self:ArmyQuit()
    -- LSTR string:离开了部队
    MsgTipsUtil.ShowTips(LSTR(910196)) --- GroupName
end

--- 编辑部队公告Rsp
function ArmyMgr:OnNetMsgArmyEditNotice(MsgBody)
    local Msg = MsgBody.EditNotice
    if Msg == nil then
        return
    end
    ArmyMainVM:UpdateNoticeInfo(Msg.Notice)
    -- 更新前3条动态日志
    self:SendGetTopLogsMsg()
end

--- 编辑部队招募(标语、公开状态)Rsp
function ArmyMgr:OnNetMsgArmyEditRecruitInfo(MsgBody)
    local Msg = MsgBody.EditRecruitInfo
    if Msg == nil then
        return
    end
    local RecruitStatus = Msg.RecruitStatus
    local RecruitSlogan = Msg.RecruitSlogan
    self:UpdateRecruitInfo(RecruitStatus, RecruitSlogan)
    ArmyMainVM:UpdateRecruitInfo(RecruitSlogan, RecruitStatus)
end

--- 编辑部队队徽Rsp
function ArmyMgr:OnNetMsgArmyEditEmblem(MsgBody)
    local Msg = MsgBody.EditEmblem
    if Msg == nil then
        return
    end
    self:SetEmblem(Msg.Emblem)
    ArmyMainVM:UpdateArmyEmblem(Msg.Emblem, Msg.EditedTime)
    EventMgr:SendEvent(EventID.ArmySelfArmyEmblemUpdate, Msg.Emblem, Msg.EditedTime)
    -- 更新前3条动态日志
    self:SendGetTopLogsMsg()
end

--- 编辑部队名称Rsp
function ArmyMgr:OnNetMsgArmyEditName(MsgBody)
    local Msg = MsgBody.EditName
    if Msg == nil then
        return
    end
    ArmyMainVM:UpdateArmyName(Msg.Name, Msg.NextEditTime)
    -- 更新前3条动态日志
    self:SendGetTopLogsMsg()
end

--- 编辑部队简称Rsp
function ArmyMgr:OnNetMsgArmyEditAlias(MsgBody)
    local Msg = MsgBody.EditAlias
    if Msg == nil then
        return
    end
    self:UpdateArmyShortName(Msg.Alias, Msg.NextEditTime)
    -- 更新前3条动态日志
    self:SendGetTopLogsMsg()
end

--- 编辑部队信息Rsp
--- @param MsgBody.EditInfo
function ArmyMgr:OnNetMsgArmyEditInfo(MsgBody)
    if MsgBody.ErrorCode then
        self:SendGroupQueryGroupBaseInfo()
        return
    end
    local Msg = MsgBody.EditInfo
    if Msg == nil then
        return
    end
    if Msg.IsEditName then
        EventMgr:SendEvent(EventID.ArmySelfArmyNameUpdate, Msg.Name, Msg.EditedNameTime)
        ArmyMainVM:UpdateArmyName(Msg.Name, Msg.EditedNameTime)
    end
    if Msg.IsEditAlias then
        --- 数据更新在简称响应
        self:UpdateArmyShortName(Msg.Alias, Msg.EditedAliasTime)
        --EventMgr:SendEvent(EventID.ArmySelfArmyAliasUpdate, Msg.Alias, Msg.EditedAliasTime)
    end
    -- if Msg.IsEditEmblem then
    --     ArmyMainVM:UpdateArmyEmblem(Msg.Emblem, Msg.NextEditEmblemTime)
    -- end
    if Msg.IsEditNotice then
        --ArmyMainVM:UpdateArmyEmblem(Msg.Emblem, Msg.NextEditEmblemTime)
        ArmyMainVM:UpdateNoticeInfo(Msg.Notice)
        EventMgr:SendEvent(EventID.ArmySelfArmyNoticeUpdate, Msg.Notice)
    end
    -- 更新前3条动态日志
    self:SendGetTopLogsMsg()
    ---[保存成功]
    MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.SaveSucceed)
end

---@deprecated 增加新的分组Rsp 
function ArmyMgr:OnMsgArmyAddCategory(MsgBody)
    local Msg = MsgBody.AddCategory
    if Msg == nil then
        return
    end
    local NewCategory = Msg.NewCategory
    local SIndex = NewCategory.ShowIndex + 1
    -- LSTR string:新增分组%d“%s”
    MsgTipsUtil.ShowTips(string.format(LSTR(910149), SIndex, NewCategory.Name))
    self:AddCategoryData(NewCategory)
    ArmyMainVM:AddCategoryData(self.SelfArmyInfo.Categories, NewCategory)
end

---@deprecated 删除分组
function ArmyMgr:OnMsgArmyDelCategory(MsgBody)
    local Msg = MsgBody.DelCategory
    if Msg == nil then
        return
    end
    -- LSTR string:删除成功
    MsgTipsUtil.ShowTips(LSTR(910073))
    self:RemoveCategoryDataByID(Msg.CategoryID)
    if #Msg.MemberIDs > 0 then
        for _, RoleID in ipairs(Msg.MemberIDs) do
            self:UpdateMemCategoryID(RoleID, Msg.MemberTargetID)
        end
    end
    ArmyMainVM:RemoveCategoryByID(Msg.CategoryID, Msg.MemberTargetID, Msg.MemberIDs)
end

--- 修改分组顺序
---@deprecated
function ArmyMgr:OnMsgEditClassShowIndex(MsgBody)
    local Msg = MsgBody.EditCategoryShowIndex
    if Msg == nil then
        return
    end
    self:UpdateCategoriesByPosReset(Msg.CategoryIDs)
    ArmyMainVM:UpdateCategory()
end

--- 修改分组名称Rsp
---@deprecated
function ArmyMgr:OnMsgEditClassName(MsgBody)
    local Msg = MsgBody.EditCategoryName
    if Msg == nil then
        return
    end
    -- LSTR string:修改成功
    MsgTipsUtil.ShowTips(LSTR(910046))
    ArmyMainVM:UpdateCategoryName(Msg.CategoryID, Msg.Name)
end

--- 修改分组Icon
---@deprecated
function ArmyMgr:OnMsgEditClassIcon(MsgBody)
    local Msg = MsgBody.EditCategoryIcon
    if Msg == nil then
        return
    end
    -- LSTR string:图标修改成功
    MsgTipsUtil.ShowTips(LSTR(910090))
    local CategoryData = self:UpdateCategoryElement(Msg.CategoryID, "IconID", Msg.IconID)
    ArmyMainVM:UpdateCategoryIcon(CategoryData)
end

--- 修改指定分组权限列表Rsp
---@deprecated
function ArmyMgr:OnMsgEditClassPermission(MsgBody)
    local Msg = MsgBody.EditCategoryPermission
    if Msg == nil then
        return
    end
    self:UpdatePermissionByCPermissions(Msg.CategoryPermissions)
    ArmyMainVM:EditCategoryPermissions(Msg.CategoryPermissions)
end

--- 响应修改指定分组权限列表Rsp
function ArmyMgr:OnMsgClassPermissionChange(MsgBody)
    local Msg = MsgBody.CategoryPermissionChange
    if Msg == nil then
        return
    end
    self:UpdatePermissionByCPermissions(Msg.CategoryPermissions)
    ArmyMainVM:EditCategoryPermissions(Msg.CategoryPermissions)
    ---如果自身阶级权限有变化，更新一次申请红点显示
    local SelfCategoryID = self:GetCategoryIDByRoleID(MajorUtil.GetMajorRoleID())
    local IsSelfCategoryChange = false
    for _, CategoryPermission in ipairs(Msg.CategoryPermissions) do
        if CategoryPermission.CategoryID == SelfCategoryID then
            IsSelfCategoryChange = true
        end
    end
    if IsSelfCategoryChange then    
        --- 更新自身权限数据
        self.SelfCategoryData = self:GetCategoryDataByID(self.SelfRoleInfo.CategoryID)
        local RedDotData = self:GetRedDotDataByType(ProtoCS.GroupRedDotType.GroupRedDotTypeApply)
        self:ArmyRedDotDataUpdate(RedDotData)
    end
end


--- 设置成员分组Rsp
function ArmyMgr:OnMsgSetMemberClass(MsgBody)
    if MsgBody.ErrorCode then
        local ErrorCategoryID  = ArmyMainVM:GetCurEditMemberCategoryID()
        ---更新编辑界面成员数据
        self:SendGroupQueryMemberByCategory(ErrorCategoryID)
        return
    end
    local Msg = MsgBody.SetMemberCategory
    if Msg == nil then
        return
    end
    --- 向已删除分组移动成员
    if Msg.CategoryID == 0 then
        -- LSTR string:分组已删除
        MsgTipsUtil.ShowTips(LSTR(910063))
        ---更新编辑界面数据
        self:SendGroupQueryCategory()
        return
    end
    --- todo 先用原来的更新函数，后续检查性能问题
    for _, MemberRoleID in ipairs(Msg.MemberRoleIDs) do
        self:UpdateMemCategoryID(MemberRoleID, Msg.CategoryID)
        ArmyMainVM:UpdateMemberCategory(Msg.MemberRoleID, Msg.CategoryID)
    end
    ArmyMainVM:UpdataEditCategoryPanelMemberData()
end

--- 转交部队长职务Rsp
function ArmyMgr:OnMsgTransferLeader(MsgBody)
    local Msg = MsgBody.TransferLeader
    if Msg == nil then
        return
    end
    -- LSTR string:转让部队长权限成功
    _G.MsgTipsUtil.ShowTips(LSTR(910239))
    local NewLeaderData, OldLeaderData = self:UpdateTransferLeader(Msg.NewLeaderRoleID, Msg.LastLeaderRoleID, Msg.LastLeaderCategoryID)
    ArmyMainVM:RefreshTransferLeaderData(NewLeaderData, OldLeaderData)
end

--- 搜索部队Rsp
function ArmyMgr:OnMsgArmySearch(MsgBody)
    local Msg = MsgBody.Search
    if Msg == nil then
        return
    end
    local NextOffset = Msg.Offset + #Msg.Groups
    local Key
    self.ArmyListIsEnd = #Msg.Groups < Msg.Limit
    --self.ArmyListIsEnd = #Msg.Groups == 0
    if LastSearchArmyInput == nil then
        self:SetPageDataOffset(PageType.AllArmy, NextOffset)
        Key = string.format("ArmyNoInput_%s", bFullCapacity and "Full" or "All")
    else
        self:SetPageDataOffset(PageType.ArmySearch, NextOffset)
        Key = string.format("ArmyInput_%s", bFullCapacity and "Full" or "All")
    end
    if self.SearchArmyTab == nil then
        self.SearchArmyTab = {}
        self.SearchArmyTab[Key] = {}
    elseif self.SearchArmyTab[Key] == nil then
        self.SearchArmyTab[Key] = {}
    end
    for _, ArmyData in ipairs(Msg.Groups) do
        local FindValue = table.find_by_predicate(self.SearchArmyTab[Key], function(Element)
            return Element.ID == ArmyData.ID
        end)
        if not FindValue then
            table.insert(self.SearchArmyTab[Key], ArmyData)
        end
    end
    ArmyMainVM:UpdateArmyList(Msg.Offset, Msg.Groups)
end

--- 申请加入 玩家申请加入部队
function ArmyMgr:OnMsgArmyApply(MsgBody)
    local ErrorCode = MsgBody.ErrorCode
    if ErrorCode then
        local PageData
        if LastSearchArmyInput == nil then
            PageData = self:GetPageDataByType(PageType.AllArmy)
        else
            PageData = self:GetPageDataByType(PageType.ArmySearch)
        end
        if PageData then
            PageData.Offset = ArmyDefine.Zero
        end
        self:SendArmySearchMsg()
        local JoinInfoView = UIViewMgr:FindView(UIViewID.ArmyJoinInfoViewWin)
        if JoinInfoView and JoinInfoView.SendUpdateReq then
            JoinInfoView:SendUpdateReq()
        end
        return
    end
    -- LSTR string:申请成功
    MsgTipsUtil.ShowTips(LSTR(910180))
end

--- 获取申请加入部队的玩家列表
function ArmyMgr:OnMsgQueryApplyList(MsgBody)
    local Msg = MsgBody.QueryApplyList
    if Msg == nil then
        return
    end
    local NextOffset = Msg.Offset + #Msg.ApplyRoles
    self:SetPageDataOffset(PageType.JoinApply, NextOffset)
    --if Msg.Offset == 0 then
        ArmyMainVM:UpdateApplyJoinArmyRoleList(Msg.ApplyRoles)
    --else
        --ArmyMainVM:AddApplyJoinArmyRoleList(Msg.ApplyRoles)
    -- end
    local IsHaveApplyRedDot = RedDotMgr:FindRedDotNodeByID(ArmyDefine.ArmyRedDotID[ProtoCS.GroupRedDotType.GroupRedDotTypeInvite])
    local IsHaveApply = false
    if Msg.ApplyRoles and #Msg.ApplyRoles > 0 then
        IsHaveApply = true
    else
        IsHaveApply = false
    end
    ---如果列表数据和红点不匹配，客户端这边进行一次更新，防止服务器红点数据下发丢包/网关问题导致bug
    if IsHaveApply ~= IsHaveApplyRedDot then
        local Status = IsHaveApply and 1 or 0
        self:SetRedDotDataByType(ProtoCS.GroupRedDotType.GroupRedDotTypeApply, Status)
        self:ArmyRedDotDataUpdateByType(ProtoCS.GroupRedDotType.GroupRedDotTypeApply)
    end
end

--- 同意申请加入
function ArmyMgr:OnMsgArmyAcceptApply(MsgBody)
    local Msg = MsgBody.AcceptApply
    local ErrorCode = MsgBody.ErrorCode
    if ErrorCode then
        self:SendGetArmyQueryApplyListMsg()
        return
    end
    if Msg == nil then
        return
    end
    -- LSTR string:通过成功
    MsgTipsUtil.ShowTips(LSTR(910242))
    self:AddMemberToArmy(Msg.Member)
    ArmyMainVM:AcceptRoleJoinForRoleData(Msg.Member)
    -- 更新前3条动态日志
    self:SendGetTopLogsMsg()
end

--- 通知玩家加入部队
function ArmyMgr:OnMsgArmyNotifyJoin(MsgBody)
    local Msg = MsgBody.NotifyJoin
    if Msg == nil then
        return
    end
    --- 申请受限解锁处理,如果是邀请，这个时候已经解锁
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDArmy) then
        ---设置为受限解锁
        self.IsInvitedUnlock = true
    end
    --- 如果未解锁，解锁部队
    self:SetArmyModuleOpen()
    local ArmyID = Msg.GroupID
    self.SelfArmyID = ArmyID
    ArmyMainVM:SetMyArmyBasicInfo(ArmyID, 0)
    if UIViewMgr:IsViewVisible(UIViewID.ArmyPanel) then
        UIViewMgr:HideView(UIViewID.ArmyPanel)
        ---需要屏蔽其他未加入时的部队弹窗界面
        UIViewMgr:HideView(UIViewID.ArmyJoinInfoViewWin)
        UIViewMgr:HideView(UIViewID.ArmyApplyJoinPanel)
        self.bIsOnlyGetData = false
    else
        self.bIsOnlyGetData = true
    end
    self:SendGetArmyDataMsg(ArmyID)
    if Msg.JoinWay and Msg.JoinWay == ProtoCS.JoinWay.JoinWaySign then
        ArmyMgr:ShowJoinArmyTips()
    else
        -- LSTR string:成功加入部队
        MsgTipsUtil.ShowTips(LSTR(910127))
    end

    EventMgr:SendEvent(EventID.ArmySelfArmyIDUpdate)
    self:ClearInvitePopUpInfo()
    self:SetArmyState(ProtoCS.RoleGroupState.RoleGroupStateJoinedGroup)
    --- 清理未加入部队相关的红点
    self:ClearNoArmyRedDot()
end

--- 拒绝玩家申请
function ArmyMgr:OnMsgArmyRefuseApply(MsgBody)
    local Msg = MsgBody.RefuseApply
    local ErrorCode = MsgBody.ErrorCode
    if ErrorCode then
        self:SendGetArmyQueryApplyListMsg()
        return
    end
    if Msg == nil then
        return
    end
    -- LSTR string:拒绝成功
    MsgTipsUtil.ShowTips(LSTR(910134))
    ArmyMainVM:RefuseRoleJoinForRoleIds(Msg.TargetMemberRoleIDs)
end

--- 发送加入邀请
function ArmyMgr:OnMsgArmySendInvita(MsgBody)
    local Msg = MsgBody.SendInvite
    if Msg == nil then
        return
    end
    -- local TargetMemberRoleIDs = Msg.TargetMemberRoleIDs
    -- LSTR string:已成功发送邀请，等待对方确认
    MsgTipsUtil.ShowTips(LSTR(910108))
end

--- 查询玩家受邀的部队列表
function ArmyMgr:OnMsgQueryInviteList(MsgBody)
    local Msg = MsgBody.QueryInviteList
    if Msg == nil then
        return
    end
    local List = Msg.Invitations
    --local NextOffset = Msg.Offset + #List
    --self:SetPageDataOffset(PageType.ArmyInvite, NextOffset)
    local ArmyIDList = {}
    for _, InviteData in ipairs(List) do
        table.insert(ArmyIDList, InviteData.GroupID)
        if not InviteData.IsRead then
            if self.UnReadInviteList == nil then
                self.UnReadInviteList = {}
            end
            local ViteInfo = {GroupID = InviteData.GroupID, InviterRoleID = InviteData.InviterID, Time = InviteData.Time}
            table.insert(self.UnReadInviteList, ViteInfo)
        end
    end
    if self.UnReadInviteList and #self.UnReadInviteList > 0 then
        self:ShowUnReadInviteWindow()
    end
    local IsHaveInviteRedDot = RedDotMgr:FindRedDotNodeByID(ArmyDefine.ArmyRedDotID[ProtoCS.GroupRedDotType.GroupRedDotTypeInvite])
    local IsHaveInvite = false
    if #ArmyIDList > 0 then
        self:QueryArmySimples(ArmyIDList, function()
            local ArmyVMList = {}
            for _, InviteData in ipairs(List) do
                local ArmyVM = self:FindArmyEntryVM(InviteData.GroupID, true)
                ArmyVM.InviteTime = InviteData.Time
                table.insert(ArmyVMList, ArmyVM)
            end
            ArmyMainVM:UpdateInviteRoleArmyList(ArmyVMList)
        end, false)
        IsHaveInvite = true
    else
        IsHaveInvite = false
        ArmyMainVM:UpdateInviteRoleArmyList(nil)
    end
    ---如果列表数据和红点不匹配，客户端这边进行一次更新，防止服务器红点数据下发丢包/网关问题导致bug
    if IsHaveInvite ~= IsHaveInviteRedDot then
        local Status = IsHaveInvite and 1 or 0
        self:SetRedDotDataByType(ProtoCS.GroupRedDotType.GroupRedDotTypeInvite, Status)
        self:ArmyRedDotDataUpdateByType(ProtoCS.GroupRedDotType.GroupRedDotTypeInvite)
    end
end

--- 通知玩家入队邀请
function ArmyMgr:OnMsgArmyNotifyInvite(MsgBody)
    local Msg = MsgBody.NotifyInvite
    if Msg == nil then
        return
    end
    --local InviterName
    --local ArmyName
    local GroupID = Msg.GroupID
    --_G.FLOG_INFO("部队邀请玩家 通知弹窗屏蔽，GroupID:" .. GroupID)
    local RedData = self:GetRedDotDataByType(ProtoCS.GroupRedDotType.GroupRedDotTypeInvite)
    if RedData then
        RedData.Status = 1
    else
        RedData = {Tid = ProtoCS.GroupRedDotType.GroupRedDotTypeInvite, Status = 1}
    end
    self:ArmyRedDotDataUpdate(RedData)
    --- 如果在副本里，就不接入弹窗
    self:UpdataInviteWindow(Msg.InviterRoleID, GroupID)
    ---解锁部队
    self.IsInvitedUnlock = true
    self:SetArmyModuleOpen()
end

--- 拒绝邀请 玩家 => 拒绝 => 部队
function ArmyMgr:OnMsgArmyIgnoreInvita(MsgBody)
    local ErrorCode = MsgBody.ErrorCode
    if ErrorCode then
        self:SendArmyGetInviteListMsg()
    end
    local Msg = MsgBody.IgnoreInvite
    if Msg == nil then
        return
    end
    ArmyMainVM:RemoveArmyInviteListByArmyIDs(Msg.GroupIDs)
    -- LSTR string:【已拒绝邀请】
    MsgTipsUtil.ShowTips(LSTR(910023))
end

--- 接受邀请
function ArmyMgr:OnMsgArmyAcceptInvita(MsgBody)
    local ErrorCode = MsgBody.ErrorCode
    if ErrorCode then
        self:SendArmyGetInviteListMsg()
        return
    end
    local Msg = MsgBody.AcceptInvite
    if Msg == nil then
        return
    end
    self.SelfArmyID = Msg.GroupID
    ArmyMainVM:SetMyArmyBasicInfo(self.SelfArmyID, 0)
    UIViewMgr:HideView(UIViewID.ArmyPanel)
    ---需要屏蔽部队详情界面
    UIViewMgr:HideView(UIViewID.ArmyJoinInfoViewWin)
    self:SendGetArmyDataMsg(self.SelfArmyID)
    ---只在被邀请时解锁，其他情况下未解锁进入公会是不合规情况
    self:SetArmyModuleOpen()

    EventMgr:SendEvent(EventID.ArmySelfArmyIDUpdate)
end

--- 移除成员
function ArmyMgr:OnMsgArmyKickMember(MsgBody)
    local Msg = MsgBody.KickMember
    if Msg == nil then
        return
    end
    local RoleID = Msg.MemberID
    -- local CategoryID = self:GetCategoryIDByRoleID(RoleID)
    self:RemoveMemberByRoleID(RoleID)
    ArmyMainVM:RemoveArmyMember(RoleID)
    ArmyMainVM:UpdateCategory()
    -- LSTR string:除名成功！
    _G.MsgTipsUtil.ShowTips(LSTR(910274))
end

--- 通知玩家被移除部队
function ArmyMgr:OnMsgArmyNotifyKicked(MsgBody)
    local Msg = MsgBody.NotifyKicked
    if Msg == nil then
        return
    end
    if Msg.GroupID == self.SelfArmyID then
        -- LSTR string:你被移出了[%s]部队
        MsgTipsUtil.ShowTips(string.format(LSTR(910039), Msg.GroupName))
        self.SelfArmyID = 0
        self:ArmyQuit()
    end
end

function  ArmyMgr:OnNetMsgNotifyAppliActionList( MsgBody )
    local Msg = MsgBody.NotifyApplicationList
	if nil == Msg then
		return
	end

    local GroupID = Msg.GroupID
    local RoleIDs = Msg.RoleIDs
    if nil == GroupID or nil == RoleIDs then
        return
    end

    if GroupID == self.SelfArmyID then
        ArmyMainVM:UpdateJoinListByRemoveRoleIds(RoleIDs)
    end
end

--- 创建部队时，校验招募标语
function  ArmyMgr:OnNetMsgCheckSlogan( MsgBody )
    local Msg = MsgBody.CheckSlogan
    if nil == Msg then
		return
	end

    local RecruitSlogan = Msg.RecruitSlogan
    if nil == RecruitSlogan then
        return
    end
    ArmyMainVM:SetCreatePanelRecruitSlogan(RecruitSlogan)
end

function  ArmyMgr:OnNetMsgAddGroupScore( MsgBody )
    local Msg = MsgBody.AddGroupScore
    if nil == Msg then
		return
	end

    local GroupLevel = Msg.GroupLevel
    local GroupScore = Msg.GroupScore
    if nil == GroupLevel or nil == GroupScore then
        return
    end
    self:UpdateArmyLevelAndScore(GroupLevel, GroupScore)
end

--------- 部队仓库 Start---------

--- 部队存物品
function  ArmyMgr:OnNetMsgGroupStoreDepositItem( MsgBody )
    local Msg = MsgBody.StoreDeposit
    if nil == Msg then
		return
	end

    local Page = Msg.Page
    if nil == Page then
        return
    end
    --- 更新仓库和背包
    self:UpdateArmyStoreAndBagInfo(Page.Index, Page.Name, Page.Capacity, Page.Size, Page.ExpansionNum, Page.Items)
    if not Msg.Result then
        -- LSTR string:存物品失败
        MsgTipsUtil.ShowTips(string.format(LSTR(910098)))
    else
        local ItemName
        ItemName = ItemCfg:GetItemName(Msg.ResID)
        if ItemName then
            ItemName = RichTextUtil.GetText(string.format("%s", ItemName), ArmyTextColor.YellowHex)
            -- LSTR string:已存储
            MsgTipsUtil.ShowTips(string.format("%s%s", LSTR(910107), ItemName))
        end
    end
   
end

--- 部队取物品
function  ArmyMgr:OnNetMsgGroupStoreFetChItem( MsgBody )
    local Msg = MsgBody.StoreFetch
    if nil == Msg then
		return
	end

    local Page = Msg.Page
    if nil == Page then
        return
    end
    --- 更新仓库和背包
    self:UpdateArmyStoreAndBagInfo(Page.Index, Page.Name, Page.Capacity, Page.Size, Page.ExpansionNum, Page.Items)
    if not Msg.Result then
       -- LSTR string:取物品失败
       MsgTipsUtil.ShowTips(string.format(LSTR(910085)))
    else
        local ItemName
        ItemName = ItemCfg:GetItemName(Msg.ResID)

        if ItemName then
            ItemName = RichTextUtil.GetText(string.format("%s", ItemName), ArmyTextColor.YellowHex)
            -- LSTR string:已领取
            MsgTipsUtil.ShowTips(string.format("%s%s", LSTR(910122), ItemName))
        end
    end
end

--- 部队仓库扩容
function  ArmyMgr:OnNetMsgGroupStoreAddExtraGrid( MsgBody )
    local Msg = MsgBody.StoreAddGrid
    if nil == Msg then
		return
	end
    local Page = Msg.Page
    if nil == Page then
        return
    end
    self:UpdateArmyStoreExpansionNum(Page.Index, Page.ExpansionNum)
end

--- 部队仓库改名
function  ArmyMgr:OnNetMsgGroupStoreSetStoreName( MsgBody )
    local Msg = MsgBody.StoreSetName
    if nil == Msg then
		return
	end
    local StoreIndex = Msg.StoreIndex
    local Name = Msg.Name
    local IconId = Msg.IconId
    if nil == StoreIndex or nil == Name then
        return
    end
    self:UpdateArmyStoreName(StoreIndex, Name, IconId)
end

--- 部队仓库全量信息下发
function  ArmyMgr:OnNetMsgGroupStoreReqStoreInfo( MsgBody )
    local Msg = MsgBody.StoreReqInfo
    if nil == Msg then
		return
	end

    local Page = Msg.Page
    if nil == Page then
        return
    end
    --- 更新仓库和背包
    self:UpdateArmyStoreAndBagInfo(Page.Index, Page.Name, Page.Capacity, Page.Size, Page.ExpansionNum, Page.Items, Page.IconId)
end

--- 部队所有仓库基础信息下发
function  ArmyMgr:OnNetMsgGroupStoreReqStoreBaseInfo( MsgBody )
    local Msg = MsgBody.StoreBaseInfo
    if nil == Msg then
		return
	end

    local Infos = Msg.Infos
    if nil == Infos then
        return
    end
    --- 更新仓库
    self:UpdateArmyStoreBaseInfo(Infos)
end

--- 部队仓库物品变化
function ArmyMgr:OnMsgGroupItemChange(MsgBody)
    local Msg = MsgBody.GroupStoreChange
    if nil == Msg then
		return
	end

    local StoreIndex = Msg.StoreIndex
    if nil == StoreIndex then
        return
    end
    local IsSend = UIViewMgr:IsViewVisible(UIViewID.ArmyDepotPanel)
    if IsSend then
        self:SendGroupStoreReqStoreInfo(StoreIndex)
    end
end

--- 自身分组变化
function ArmyMgr:OnMsgCategoryChange(MsgBody)
    print("OnMsgCategoryChange")
    local Msg = MsgBody.GroupCategoryToc
    if Msg == nil then
        return
    end
    local RoleID = MajorUtil.GetMajorRoleID()
    self:UpdateMemCategoryID(RoleID, Msg.CategoryId)
    --- 更新自身权限数据 todo 后面放到权限/分组更新函数处理
    if  self.SelfRoleInfo == nil then
        self.SelfRoleInfo = {}
    end
    self.SelfRoleInfo.CategoryID = Msg.CategoryId
    self.SelfCategoryData = self:GetCategoryDataByID(self.SelfRoleInfo.CategoryID)
    ArmyMainVM:UpdateMemberCategory(RoleID, Msg.CategoryId)
    --- 更新一次申请红点显示
    local RedDotData = self:GetRedDotDataByType(ProtoCS.GroupRedDotType.GroupRedDotTypeApply)
    self:ArmyRedDotDataUpdate(RedDotData)
end
--------- 部队仓库 End---------

---部队成员增加
function ArmyMgr:OnMsgNotifyMemberJoin(MsgBody)
    local Msg = MsgBody.MemberJoinToc
    if Msg == nil then
        return
    end
    local RoleId = Msg.RoleId
    self:AddMemberByRoleId(RoleId)
    --self:AddMemberToArmy(Member)
    --ArmyMainVM:AcceptRoleJoinForRoleData(Msg.Member)
    ---todo 等确认需要实时跟新再用事件
    -- 更新前3条动态日志
    self:SendGetTopLogsMsg()
end

---部队成员离开
function ArmyMgr:OnMsgNotifyMemberLeave(MsgBody)
    local Msg = MsgBody.MemberLeaveToc
    if Msg == nil then
        return
    end
    local RoleID = Msg.RoleId
    self:RemoveMemberByRoleID(RoleID)
    ArmyMainVM:RemoveArmyMember(RoleID)
    ArmyMainVM:UpdateCategory()
end

---查询部队成员数据响应
function ArmyMgr:OnMsgQueryMembers(MsgBody)
    local Msg = MsgBody.QueryMembers
    if Msg == nil then
        return
    end
    local Members = Msg.Members
    for _, Member in ipairs(Members) do
        local Result, MemberIndex =
        table.find_by_predicate(
        self.SelfArmyInfo.Members,
        function(Element)
            return Element.Simple.RoleID == Member.Simple.RoleID
        end
        )
        if Result then
            local CurTime = TimeUtil.GetServerTime()
            local AddMember = {Simple = Member.Simple, Time = CurTime}
            self.SelfArmyInfo.Members[MemberIndex] = AddMember
        end
    end
    self:ProcessQueryMemberCallback()
end

--- 部队红点变化更新
function ArmyMgr:OnMsgNotifyRed(MsgBody)
    local Msg = MsgBody.Reds
    if Msg == nil then
        return
    end
    local RedDots = Msg.RedDots
    self:ArmyRedDotUpdate(RedDots)
end

--- 部队取消仓库红点
function ArmyMgr:OnMsgDelStoreRedDot(MsgBody)
    local Msg = MsgBody.ReadBag
    if Msg == nil then
        return
    end
    local IDs = Msg.IDs
    self:ClearArmyStroeRedDot(IDs)
end
---查询角色部队数据响应
function ArmyMgr:OnNetMsgQueryArmyInfoByRoleIDs(MsgBody)
    local Msg = MsgBody.QueryRolesGroup
    if Msg == nil then
        return
    end
    local Simples = Msg.Simples
    ---todo 后续加本地缓存，防止短时间频繁查询带来的开销
    self:SetRoleArmyAlias(Simples)
    self:ProcessQueryArmySimpleCallback(Simples)
    --self:SetRoleArmyAlias(Simples)
end

---角色转正响应
function ArmyMgr:OnNetMsgGroupCategoryInternUpConfirm(MsgBody)
    local Msg = MsgBody.InternUpConfirm
    if Msg == nil then
        return
    end
    local UpTime = Msg.UpTime
    local CurTime = TimeUtil.GetServerTime()
    local WaitTime = UpTime - CurTime
    if self.InternUpTimer then
        self:UnRegisterTimer(self.InternUpTimer)
        self.InternUpTimer = nil
    end
    ---是否达到转正时间
    if WaitTime > 0 then
        self.InternUpTimer = self:RegisterTimer(self.SendGroupCategoryInternUpConfirm, WaitTime)
    end
end

---分组修改响应
function ArmyMgr:OnNetMsgGroupEditCategory(MsgBody)
    local Msg = MsgBody.EditCategory
    if self.SelfArmyInfo then
        self.SelfArmyInfo.Categories = Msg.Categories
    end
    self:DefaultCategoryNameWrite()
    ---分组编辑界面数据只能在这里更新
    ArmyMainVM:UpdataEditCategoryPanelData(Msg.Categories)
    ---[保存成功]
    MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.SaveSucceed)
end

---分组查询响应
function ArmyMgr:OnNetMsgGroupQueryCategory(MsgBody)
    local Msg = MsgBody.Categories
    if self.SelfArmyInfo then
        self.SelfArmyInfo.Categories = Msg.Categories
    end
    self:DefaultCategoryNameWrite()
    ---分组编辑界面数据只能在这里更新
    ArmyMainVM:UpdataEditCategoryPanelData(Msg.Categories)
end

---部队简称变更响应
function ArmyMgr:OnNetMsgGroupNotifyAlias(MsgBody)
    local Msg = MsgBody.Alias
    --self:SetArmyAlias(Msg.Alias)
    self:UpdateArmyShortName(Msg.Alias)
    local ArmySimples = {{RoleID = MajorUtil.GetMajorRoleID(), Simple = {Alias = Msg.Alias}}}
    self:SetRoleArmyAlias(ArmySimples)  
end

---部队编辑时间变更响应
function ArmyMgr:OnNetMsgQueryGroupEditedTimes(MsgBody)
    local Msg = MsgBody.EditedTimes
    EventMgr:SendEvent(EventID.ArmyInfoEditTimeUpdate, Msg)
end

-- message BonusStateQueryRsp{
--     repeated int32 IDs = 1; // 已持有的加成状态id列表
--     repeated BonusStateUp Ups = 2;// 生效中的加成状态列表
--     int64 Version = 3;//数据版本号
--     Reputation Reputation = 4;//友好关系
--   }

---部队特效查询响应
function ArmyMgr:OnNetMsgGroupBonusStateQuery(MsgBody)
    local Msg = MsgBody.BonusStateQuery
    self.SEDataVersion = Msg.Version
    self:UpdateArmyBonusStateData(Msg)
    if self.QueryGroupBonusStateCallback then
        self.QueryGroupBonusStateCallback()
    end
end

---部队特效购买响应
function ArmyMgr:OnNetMsgGroupBonusStateBuy(MsgBody)
    if MsgBody.ErrorCode then
        self:SendGroupBonusStateQuery()
        UIViewMgr:HideView(UIViewID.ArmySEBuyWin)
        return
    end
    local Msg = MsgBody.BonusStateBuy
    if Msg == nil then
        return
    end
    self.SEDataVersion = Msg.Version
    self:AddArmyBonusState(Msg.ID, Msg.Num)
    local BonusStateData = {}
    BonusStateData.IDs = self.ArmyBonusStates
    BonusStateData.Ups = self.ArmyUsedBonusStates
    BonusStateData.Reputation = self.Reputation
    ArmyMainVM:UpdateBonusStateData(BonusStateData)
    local StateShowCfg = GroupBonusStateDataCfg:FindCfgByKey(Msg.ID)
    local Name = StateShowCfg.EffectName
    local Num = Msg.Num
    -- LSTR string:已购买
    MsgTipsUtil.ShowTips(string.format("%s%d%s'%s'",LSTR(910116), Num, LSTR(910031), Name))
    ---购买完成关闭
    UIViewMgr:HideView(UIViewID.ArmySEBuyWin)

end

---部队特效使用响应
function ArmyMgr:OnNetMsgGroupBonusStateUse(MsgBody)
    if MsgBody.ErrorCode then
        self:SendGroupBonusStateQuery()
        return
    end
    local Msg = MsgBody.BonusStateUse
    self.SEDataVersion = Msg.Version
    self:DelArmyBonusState(Msg.ID, 1)
    self:AddArmyUsedBonusState(Msg.ID, Msg.EndTime, Msg.Index)
    local BonusStateData = {}
    BonusStateData.IDs = self.ArmyBonusStates
    BonusStateData.Ups = self.ArmyUsedBonusStates
    ArmyMainVM:UpdateBonusStateData(BonusStateData)
    local StateShowCfg = GroupBonusStateDataCfg:FindCfgByKey(Msg.ID)
    local Name = StateShowCfg.EffectName
    --Name = RichTextUtil.GetText(Name, ArmyTextColor.YellowHex)
    -- LSTR string:已生效
    MsgTipsUtil.ShowTips(string.format("'%s'%s",Name, LSTR(910112)))
end

---部队特效停用响应
function ArmyMgr:OnNetMsgGroupBonusStateStop(MsgBody)
    if MsgBody.ErrorCode then
        self:SendGroupBonusStateQuery()
        return
    end
    local Msg = MsgBody.BonusStateStop
    self.SEDataVersion = Msg.Version
    self:DelArmyUsedBonusState(Msg.ID)
    local BonusStateData = {}
    BonusStateData.IDs = self.ArmyBonusStates
    BonusStateData.Ups = self.ArmyUsedBonusStates
    ArmyMainVM:UpdateBonusStateData(BonusStateData)
    local StateShowCfg = GroupBonusStateDataCfg:FindCfgByKey(Msg.ID)
    local Name = StateShowCfg.EffectName
    --Name = RichTextUtil.GetText(Name, ArmyTextColor.YellowHex)
    -- LSTR string:已停用
    MsgTipsUtil.ShowTips(string.format("'%s'%s",Name, LSTR(910102)))
end

function ArmyMgr:OnNetMsgGroupCheckSensitiveText(MsgBody)
    local Msg = MsgBody.CheckSensitiveText
    if MsgBody.ErrorCode then
        self.QueryCheckTextCallback(false)
        return
    end
    if Msg.IsPass then
        self.QueryCheckTextCallback(true)
    else
        self.QueryCheckTextCallback(false)
    end
end

---部队查询指定阶级成员响应
function ArmyMgr:OnNetMsgQueryGroupMemberByCategory(MsgBody)
    local Msg = MsgBody.QueryMembersByCategory
    if Msg.Members and Msg.CategoryID then
        ArmyMainVM:UpdataCurEditMemberList(Msg.Members, Msg.CategoryID)
    end
end

---部队推送聊天动态响应
function ArmyMgr:OnNetMsgGroupNotifyLog(MsgBody)
    local Msg = MsgBody.LogNotify
    if Msg.logs then
       self:LogTextPushChat(Msg.logs)
    end
end

---部队仓库存金币
function ArmyMgr:OnNetMsgGroupMoneyBagDeposit(MsgBody)
    if MsgBody.ErrorCode then
        ---服务器处理提示
        --MsgTipsUtil.ShowTips()
        self:SendGroupMoneyBagQuery()
        return
    end
    local Msg = MsgBody.MoneyBagDeposit
    if Msg.TotalNum and Msg.Num then
        -- LSTR string:存入成功
        MsgTipsUtil.ShowTips(LSTR(910096))
        self:SetMoneyStoreNumAndUpdateVMdata(Msg.TotalNum, true)
        UIViewMgr:HideView(UIViewID.ArmyDepotMoneyWin)
    end
end

---部队仓库取金币
function ArmyMgr:OnNetMsgGroupMoneyBagWithdraw(MsgBody)
    if MsgBody.ErrorCode then
        self:SendGroupMoneyBagQuery()
        return
    end
    local Msg = MsgBody.MoneyBagWithdraw
    if Msg and Msg.TotalNum and Msg.Num  then
        -- LSTR string:取出成功
        MsgTipsUtil.ShowTips(LSTR(910082))
        self:SetMoneyStoreNumAndUpdateVMdata(Msg.TotalNum, true)
        UIViewMgr:HideView(UIViewID.ArmyDepotMoneyWin)
    end
end

---部队仓库查询金币
function ArmyMgr:OnNetMsgGroupMoneyBagQuery(MsgBody)
    local Msg = MsgBody.MoneyBagQuery
    if Msg.TotalNum then
        self:SetMoneyStoreNumAndUpdateVMdata(Msg.TotalNum)
        local View = UIViewMgr:FindVisibleView(UIViewID.ArmyDepotMoneyWin)
        if View then
            View:UpdatePanel(Msg.TotalNum)
        end
    end
end

---部队成员上线推送
function ArmyMgr:OnNetMsgNotifyMemberOline(MsgBody)
    local Msg = MsgBody.NotifyMemberOnline
    if Msg.RoleID then
        self:MemberOlinePushChat(Msg.RoleID)
    end
end

--- 信息界面数据更新 --todo 战绩添加/公告/3条动态
function ArmyMgr:OnNetMsgQuertGroupBaseInfo(MsgBody)
    local Msg = MsgBody.GroupBaseInfo
    self:UpdataBaseInfo(Msg)
    self:ProcessQueryArmyPanelBaseInfoCallback(Msg)
    --ArmyMainVM:UpdateArmyInfoPanel(Msg)
    --todo 部队信息界面
    --ArmyMainVM:UpdateArmyInfoPanel(Msg)
end

--- 已读邀请弹窗数据更新
function ArmyMgr:OnNetMsgGroupInviteSetRead(MsgBody)
    local Msg = MsgBody.InviteSetRead
    if Msg.GroupIDs then
        self:UpdateArmyUnReadInviteListByReadGroupIDs(Msg.GroupIDs)
    end
end

function ArmyMgr:OnNetMsgGroupQuerySelfMember(MsgBody)
    local Msg = MsgBody.QuerySelfMembers
    if Msg and Msg.Members then
        self:UpdateSelfArmyMembers(Msg.Members)
    else
        _G.FLOG_WARNING("ArmyMgr:OnNetMsgGroupQuerySelfMember QuerySelfMembers is nil, Player may not have joined the army")
    end
end

--PetitionGain = {GroupPetition, GainTime}
---【署名】领取组建书
function ArmyMgr:OnNetMsgGroupPeitionGain(MsgBody)
    local PetitionGain = MsgBody.PetitionGain
    if PetitionGain then
        local PetitionData = {
            GroupPetition = PetitionGain.GroupPetition,-- 组建书信息
            Signs = {},
            GainTime = PetitionGain.GainTime,-- 领取时间
            RoleID = MajorUtil:GetMajorRoleID(),
        }
        self:UpdataArmyCreatePeitionData(PetitionData)
        ArmyMainVM:UpdataArmyCreatePeitionData(PetitionData)
    end
    self:SetArmyState(ProtoCS.RoleGroupState.RoleGroupStateGainedPetition)
    ---清理署名邀请和部队邀请
    self:ClearInvitePopUpInfo()
    ---清理邀请红点
    self:ClearInviteRedDot()
end

--【署名】查询组建书
function ArmyMgr:OnNetMsgGroupPeitionQuery(MsgBody)
    local PetitionQuery = MsgBody.PetitionQuery
    self:UpdataArmyCreatePeitionData(PetitionQuery)
    ArmyMainVM:UpdataArmyCreatePeitionData(PetitionQuery)
end

--【署名】编辑组建书信息
function ArmyMgr:OnNetMsgGroupPeitionEdit(MsgBody)
    local PetitionEdit = MsgBody.PetitionEdit
    self:UpdataArmyCreatePeitionDataByBase(PetitionEdit)
    ArmyMainVM:UpdataArmyCreatePeitionData(PetitionEdit)
end

--【署名】撤销组建部队
function ArmyMgr:OnNetMsgGroupPeitionCancel(MsgBody)
    --local PetitionCancel = MsgBody.PetitionCancel
    self:UpdataArmyCreatePeitionData()
    ArmyMainVM:UpdataArmyCreatePeitionData()
    ---清理提醒红点
    RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID.ArmyCreateRemind)
    ---弹提示
    --LSTR  已撤销创建部队
    MsgTipsUtil.ShowTips(LSTR(910346))
    self:SetArmyState(ProtoCS.RoleGroupState.RoleGroupStateInit)
end

--【署名】邀请署名
function ArmyMgr:OnNetMsgGroupSignInvite(MsgBody)
    local SignInvite = MsgBody.SignInvite
    --成功邀请署名tips
    MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InvitedSucceed)
end

--【署名】同意署名
function ArmyMgr:OnNetMsgGroupSignAgree(MsgBody)
    --local SignAgreeInvite = MsgBody.SignAgreeInvite
    if MsgBody.ErrorCode then
        ---如果同意失败，重新请求数据
        self:SendGroupSignQueryInvites()
        return
    end
    self:SendGroupSignQueryInvites()
    self:SetArmyState(ProtoCS.RoleGroupState.RoleGroupStateSignedOtherPetition)
end

--【署名】拒绝署名
function ArmyMgr:OnNetMsgGroupSignRefuse()
    --local SignRefuseInvite = MsgBody.SignRefuseInvite
    -- LSTR string:【已拒绝邀请】
    MsgTipsUtil.ShowTips(LSTR(910023))
    self:SendGroupSignQueryInvites()
end

--【署名】取消署名
function ArmyMgr:OnNetMsgGroupSignCancel()
    --local SignCancel = MsgBody.SignCancel
    self:SendGroupSignQueryInvites()
    ---清理提醒红点
    RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID[ProtoCS.GroupRedDotType.GroupRedDotTypeSignFull])
    self:SetArmyState(ProtoCS.RoleGroupState.RoleGroupStateInit)
end

-- 查询署名邀请列表,和服务器确认下是全量
function ArmyMgr:OnNetMsgGroupSignQueryInvites(MsgBody)
    local SignQueryInvites = MsgBody.SignQueryInvites
    local Invites = SignQueryInvites.Invites
    ArmyMainVM:UpdateSignData(Invites)
    local IsHaveInviteRedDot = RedDotMgr:FindRedDotNodeByID(ArmyDefine.ArmyRedDotID[ProtoCS.GroupRedDotType.GroupRedDotTypeSignInvite])
    local IsHaveInvite = false
    if #Invites > 1 then
        IsHaveInvite = true
    elseif #Invites == 1 then
        local SignData = Invites[1]
        local Signs = SignData.Signs
        local IsSigned = false
        if Signs and #Signs > 0 then
            local selfRoleID = MajorUtil:GetMajorRoleID()
            for _, RoleID in ipairs(Signs) do
                if selfRoleID == RoleID then
                    IsSigned = true
                    break
                end
            end
        end
        IsHaveInvite = not IsSigned
    else
        IsHaveInvite = false
    end
    ---如果列表数据和红点不匹配，客户端这边进行一次更新，防止服务器红点数据下发丢包/网关问题导致bug
    if IsHaveInvite ~= IsHaveInviteRedDot then
        local Status = IsHaveInvite and 1 or 0
        self:SetRedDotDataByType(ProtoCS.GroupRedDotType.GroupRedDotTypeSignInvite, Status)
        self:ArmyRedDotDataUpdateByType(ProtoCS.GroupRedDotType.GroupRedDotTypeSignInvite)
    end
end

-- 转国防联军
function ArmyMgr:OnNetMsgGroupGrandCompanyChange(MsgBody)
    local GrandCompanyChange = MsgBody.GrandCompanyChange
    local GrandCompanyType = GrandCompanyChange.GrandCompanyType
    local Emblem = GrandCompanyChange.Emblem
    self:SetArmyUnionType(GrandCompanyType)
    ArmyMainVM:SetBGIcon(GrandCompanyType)
    self:SetEmblem(Emblem)
    local GrandCompanyName = ""
    for _, UnitedArmyTab in ipairs(ArmyDefine.UnitedArmyTabs) do
        if GrandCompanyType == UnitedArmyTab.ID then
            GrandCompanyName = UnitedArmyTab.Name
        end
    end
    local Time = TimeUtil.GetServerTime()
    self:SetCompanyChangeTime(Time)
    ---国防联军变化时需要关闭所有部队界面
    self:HideAllArmyView()
    --LSTR  转队成功，当前部队所属%s
    MsgTipsUtil.ShowTips(string.format(LSTR(910369), GrandCompanyName))
end

-- 活动偏好设置
function ArmyMgr:OnNetMsgGroupActivitySet(MsgBody)
    local ActivitySet = MsgBody.ActivitySet
    ---已改为整体设置，后续有单独设置再启用
end

-- 活跃时间设置
function ArmyMgr:OnNetMsgGroupActivitySetTime(MsgBody)
    local ActivitySetTime = MsgBody.ActivitySetTime
    ---已改为整体设置，后续有单独设置再启用
end

-- 招募职业偏好设置
function ArmyMgr:OnNetMsgGroupRecruitSetProf(MsgBody)
    local RecruitSetProf = MsgBody.RecruitSetProf
    ---已改为整体设置，后续有单独设置再启用
end

-- 情报界面数据
function ArmyMgr:OnNetMsgGroupProfileInfo(MsgBody)
    local ProfileInfo = MsgBody.ProfileInfo
    ---已改为整体设置，后续有单独设置再启用
end

---【署名】推送国防联军变化
function ArmyMgr:OnNetMsgGroupGrandCompanyToc(MsgBody)
    local GrandCompanyToc = MsgBody.GrandCompanyToc
    self:SetArmyUnionType(GrandCompanyToc.GrandCompanyType)
    self:SetCompanyChangeTime(GrandCompanyToc.ChangeTime)
    ---国防联军变化时需要关闭所有部队界面
    self:HideAllArmyView()
    ---tips
    local GrandCompanyName = ""
    for _, UnitedArmyTab in ipairs(ArmyDefine.UnitedArmyTabs) do
        if GrandCompanyToc.GrandCompanyType == UnitedArmyTab.ID then
            GrandCompanyName = UnitedArmyTab.Name
        end
    end
    ---LSTR 部队已转到%s属下
    local TipsText = string.format(LSTR(910437), GrandCompanyName)
    MsgTipsUtil.ShowTips(TipsText)
end

function ArmyMgr:OnNetMsgProfileEdit(MsgBody)
    local GroupProfileEdite = MsgBody.GroupProfileEdite
    if GroupProfileEdite then
        ArmyMainVM:UpdateInformationByEdit(GroupProfileEdite)
        ---[保存成功]
        MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.SaveSucceed)
    end
end

--- 友好关系变化
function ArmyMgr:OnNetMsgNotifyReputation(MsgBody)
    local ReputationToc = MsgBody.ReputationToc
    if ReputationToc then
        ---如果有变化，关闭部队特效界面
        if UIViewMgr:IsViewVisible(UIViewID.ArmySEPanel) then
            UIViewMgr:HideView(UIViewID.ArmySEPanel)
            --- 数据发生变化，请刷新重试
            MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.DataUpdate)
        end
        if UIViewMgr:IsViewVisible(UIViewID.ArmySEBuyWin) then
            UIViewMgr:HideView(UIViewID.ArmySEBuyWin)
        end
    end
end

---署名邀请处理/需要弹窗和解锁部队/红点更新
function ArmyMgr:OnSignInvitedToc(MsgBody)
    local SignInvitedToc = MsgBody.SignInvitedToc
    local RoleID
    if SignInvitedToc then
        RoleID = SignInvitedToc.RoleID
    end
    if RoleID then
        self:UpdataInviteWindow(RoleID)
    end
    ---解锁部队
    self.IsInvitedUnlock = true
    self:SetArmyModuleOpen()
    local IsHaveInviteRedDot = RedDotMgr:FindRedDotNodeByID(ArmyDefine.ArmyRedDotID[ProtoCS.GroupRedDotType.GroupRedDotTypeSignInvite])
    local IsHaveInvite = true
    ---如果无红点，客户端手动添加红点
    if IsHaveInvite ~= IsHaveInviteRedDot then
        local Status = IsHaveInvite and 1 or 0
        self:SetRedDotDataByType(ProtoCS.GroupRedDotType.GroupRedDotTypeSignInvite, Status)
        self:ArmyRedDotDataUpdateByType(ProtoCS.GroupRedDotType.GroupRedDotTypeSignInvite)
    end
end

---取消署名推送，需要更新署名者的状态
function ArmyMgr:OnGroupPeitionCancelToc()
    self:SendGroupSignQueryInvites()
end

-- 【署名】推送署名人数
function ArmyMgr:OnSignNumToc(MsgBody)
    local SignNumToc = MsgBody.SignNumToc
    local SelfRoleID = MajorUtil.GetMajorRoleID()
    local MaxSignNum = GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.GlobalCfgGroupSignNum) or 0
    if SignNumToc then
        if SelfRoleID == SignNumToc.RoleID then
            ---目前的逻辑是只要人数变满就一定亮红点，不满就消失
            if SignNumToc.Num >= MaxSignNum then
                RedDotMgr:AddRedDotByID(ArmyDefine.ArmyRedDotID.ArmyCreateRemind)
            else
                RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID.ArmyCreateRemind)
            end
        else
            if SignNumToc.Num >= MaxSignNum then
                RedDotMgr:AddRedDotByID(ArmyDefine.ArmyRedDotID[ProtoCS.GroupRedDotType.GroupRedDotTypeSignFull])
            else
                RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID[ProtoCS.GroupRedDotType.GroupRedDotTypeSignFull])
            end
        end
    end
    EventMgr:SendEvent(EventID.ArmySignNumToc, SignNumToc)
end

-------------- Request Part End---------------------------

-------------- Send Part Start-------------------------
--- @获取部队信息
function ArmyMgr:SendGetArmyInfoMsg()

    --非0表示不是正式角色，还没有命名的临时角色或者演示场景角色
    if _G.DemoMajorType ~= 0 then
        return
    end
    
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUERY_SELF
    local MsgBody = {
        Cmd = SubMsgID,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 查询指定部队的信息
--- 如果是自己部队, 会返回完整信息
--- 非自己部队, 返回简要信息
---@param ID integer 部队ID
function ArmyMgr:SendGetArmyDataMsg(ID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUERY
    local MsgBody = {
        Cmd = SubMsgID,
        Query = {
            ID = ID
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 获取部队动态日志
---@param IsResetOffset boolean @true:从0开始
function ArmyMgr:SendGetArmyLogsMsg(IsResetOffset)
    bTopLogs = false
    local PageData
    if IsResetOffset then
        PageData = self:ResetPageData(PageType.Log)
    else
        PageData = self:GetPageDataByType(PageType.Log)
    end
    if PageData == nil or PageData.bPulling then
        return
    end
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUERY_LOGS
    local MsgBody = {
        Cmd = SubMsgID,
        QueryLogs = {
            Offset = PageData.Offset,
            Limit = PageData.Limit
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 获取部队头3条动态日志
function ArmyMgr:SendGetTopLogsMsg()
    bTopLogs = true
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUERY_LOGS
    local MsgBody = {
        Cmd = SubMsgID,
        QueryLogs = {
            Offset = 0,
            Limit = 3
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 创建部队
---@param GType GrandCompanyType 所属国防联军类型
---@param Name string 名称
---@param Alias string 简称
---@param Emblem GroupEmblem 队徽
---@param RecruitSlogan string 招募标语
function ArmyMgr:SendArmyCreateMsg(GType, Name, Alias, Emblem)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_CREATE
    local Categories = self:GetDefaultCategoryName()
    local MsgBody = {
        Cmd = SubMsgID,
        Create = {
            GrandCompanyType = GType,
            Name = Name,
            Alias = Alias,
            Emblem = Emblem,
            -- RecruitSlogan = RecruitSlogan,
            Categories = Categories
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 退出部队
function ArmyMgr:SendArmyQuitMsg()
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUIT
    local MsgBody = {
        Cmd = SubMsgID,
        Quit = {}
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 解散部队
function ArmyMgr:SendArmyDisbandMsg()
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_DISBAND
    local MsgBody = {
        Cmd = SubMsgID,
        Disband = {}
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 编辑部队公告
---@param Notice string 公告
function ArmyMgr:SendArmyEditNoticeMsg(Notice)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_EDIT_NOTICE
    local MsgBody = {
        Cmd = SubMsgID,
        EditNotice = {
            Notice = Notice
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 编辑部队招募（标语、状态）
---@param RecruitSlogan string 招募标语
---@param Status GroupRecruitStatus 招募公开状态 0 公开 1关闭
function ArmyMgr:SendArmyEditRecruitInfoMsg(RecruitSlogan, Status)
    local MsgID = CS_CMD.CS_CMD_GROUP
        local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_EDIT_RECRUIT_INFO
        local MsgBody = {
            Cmd = SubMsgID,
            EditRecruitInfo = {
                RecruitStatus = Status,
                RecruitSlogan = RecruitSlogan
            }
        }
        GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 编辑部队名称
---@param Name string 名称
function ArmyMgr:SendArmyEditNameMsg(Name)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_EDIT_NAME
    local MsgBody = {
        Cmd = SubMsgID,
        EditName = {
            Name = Name
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 编辑部队简称
---@param Alias string 简称
function ArmyMgr:SendArmyEditAliasMsg(Alias)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_EDIT_ALIAS
    local MsgBody = {
        Cmd = SubMsgID,
        EditAlias = {
            Alias = Alias
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 编辑部队队徽
---@param Emblem Emblem 队徽
function ArmyMgr:SendArmyEditEmblemMsg(Emblem)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_EDIT_EMBLEM
    local MsgBody = {
        Cmd = SubMsgID,
        EditEmblem = {
            Emblem = Emblem
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 编辑部队信息
---@param Name string 名称
---@param ShortName string 简称
---@param Emblem Emblem 队徽
function ArmyMgr:SendArmyEditInfoMsg(Name, ShortName, Notice)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_EDIT_INFO
    local MsgBody = {
        Cmd = SubMsgID,
        EditInfo = {
            IsEditName = Name ~= nil,
            Name = Name,
            IsEditAlias = ShortName ~= nil,
            Alias = ShortName,
            IsEditNotice = Notice ~= nil,
            Notice = Notice,
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 添加新的分组
---@deprecated
---@param CategoryName string 分组名称
function ArmyMgr:SendArmyAddCategoryMsg(CategoryName)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_ADD_CATEGORY
    local MsgBody = {
        Cmd = SubMsgID,
        AddCategory = {
            Name = CategoryName
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 删除指定分组
---@param ID number 分组ID
---@deprecated
function ArmyMgr:SendArmyDelCategoryMsg(ID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_DEL_CATEGORY
    local MsgBody = {
        Cmd = SubMsgID,
        DelCategory = {
            CategoryID = ID
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 修改指定分组显示索引
---@param CategoryID number 分组ID
---@param ShowIndex number 显示Index
---@deprecated
function ArmyMgr:SendEditClassSIndexMsg(CategoryID, ShowIndex)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_EDIT_CATEGORY_SHOW_INDEX
    local MsgBody = {
        Cmd = SubMsgID,
        EditCategoryShowIndex = {
            CategoryID = CategoryID,
            NewIndex = ShowIndex
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 修改指定分组名称
---@param CategoryID number 分组名称
---@param Name string 分组名称
---@deprecated
function ArmyMgr:SendArmyEditCategoryNameMsg(CategoryID, Name)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_EDIT_CATEGORY_NAME
    local MsgBody = {
        Cmd = SubMsgID,
        EditCategoryName = {
            CategoryID = CategoryID,
            Name = Name
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 修改指定分组 Icon
---@param CategoryID number 分组ID
---@param IconID number 分组IconID
---@deprecated
function ArmyMgr:SendArmyEditCategoryIconMsg(CategoryID, IconID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_EDIT_CATEGORY_ICON
    local MsgBody = {
        Cmd = SubMsgID,
        EditCategoryIcon = {
            CategoryID = CategoryID,
            IconID = IconID
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 修改指定分组权限列表
---@param CategoryPermissions table<GroupCategoryPermission> 分组权限数据表
---@deprecated
function ArmyMgr:SendEditClassPmsMsg(CategoryPermissions)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_EDIT_CATEGORY_PERMISSION
    local MsgBody = {
        Cmd = SubMsgID,
        EditCategoryPermission = {
            CategoryPermissions = CategoryPermissions
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 设置成员分组
---@param RoleID number 角色ID
---@param CategoryID number 分组ID
function ArmyMgr:SendArmySetMemberCategoryMsg(RoleIDs, CategoryID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_SET_MEMBER_CATEGORY
    local MsgBody = {
        Cmd = SubMsgID,
        SetMemberCategory = {
            MemberRoleIDs = RoleIDs,
            CategoryID = CategoryID
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 转交部队长职务
---@param TargetMemberRoleID number 新部队长角色Id
function ArmyMgr:SendArmyTransferLeaderMsg(TargetMemberRoleID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_TRANSFER_LEADER
    local MsgBody = {
        Cmd = SubMsgID,
        TransferLeader = {
            TargetMemberRoleID = TargetMemberRoleID
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 搜索部队
---@param Input any 部队Id或者名称
function ArmyMgr:SendArmySearchByInputMsg(Input)
    self.SearchArmyTab = {}
    local PageData
    LastSearchArmyInput = Input
    if LastSearchArmyInput == nil then
        self.bQueryArmy = false
        self.QuerySimpleID = 0
        PageData = self:ResetPageData(PageType.AllArmy)
    else
        LastSearchArmyInput = tostring(Input)
        PageData = self:ResetPageData(PageType.ArmySearch)
    end
    self:SendArmySearchMsg(PageData, nil)
end

--- 根据上一次条件搜索下一页
---@param PageData CachePageData @分页参数
---@param bFull boolean @是否满员
---@param Order number @1:根据Level降序 -1:根据Level升序
function ArmyMgr:SendArmySearchMsg(PageData, bFull)
    if PageData == nil then
        if LastSearchArmyInput == nil then
            PageData = self:GetPageDataByType(PageType.AllArmy)
        else
            PageData = self:GetPageDataByType(PageType.ArmySearch)
        end
    end
    if bFull == nil then
        bFullCapacity = bFullCapacity ~= nil and bFullCapacity or false
    else
        if bFull ~= bFullCapacity then
            if PageData then
                PageData.Offset = ArmyDefine.Zero
                PageData.bPulling = false
            end
            bFullCapacity = bFull
        end
    end
    if PageData == nil or PageData.bPulling then
        return
    end
    local Key
    if LastSearchArmyInput == nil then
        Key = string.format("ArmyNoInput_%s", bFullCapacity and "Full" or "All")
    else
        Key = string.format("ArmyInput_%s", bFullCapacity and "Full" or "All")
    end
    if self.SearchArmyTab == nil then
        self.SearchArmyTab = {}
    end
    if self.SearchArmyTab[Key] ~= nil and #self.SearchArmyTab[Key] >= PageData.Offset + PageData.Limit then
        local Result = {}
        local Length = #self.SearchArmyTab[Key]
        local StartIdx = PageData.Offset + 1
        local EndIdx = PageData.Offset + PageData.Limit
        for i = StartIdx, EndIdx, 1 do
            if i > Length then
                break
            end
            table.insert(Result, self.SearchArmyTab[Key][i])
        end
        ArmyMainVM:UpdateArmyList(PageData.Offset, Result)
        PageData.Offset = PageData.Offset + #Result
        return
    end
    PageData.bPulling = true
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_SEARCH
    local MsgBody = {
        Cmd = SubMsgID,
        Search = {
            Input = LastSearchArmyInput,
            Offset = PageData.Offset,
            Limit = PageData.Limit,
            OnlyFull = bFullCapacity,
            Order = 1,
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 玩家申请加入部队
---@param ArmyIds table<number> 申请的部队Id列表
---@param Message string 申请留言
function ArmyMgr:SendArmyApplyJoinMsg(ArmyIds, Message)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_APPLY
    local MsgBody = {
        Cmd = SubMsgID,
        Apply = {
            GroupIDs = ArmyIds,
            Message = Message
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 部队同意玩家申请
---@param RoleID number 玩家ID
function ArmyMgr:SendArmyAcceptApplyMsg(RoleID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_ACCEPT_APPLY
    local MsgBody = {
        Cmd = SubMsgID,
        AcceptApply = {
            TargetMemberRoleID = RoleID
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 部队拒绝申请的玩家Id列表
---@param RoleId table<number> 玩家Id列表
function ArmyMgr:SendArmyRefuseApplyMsg(RoleIDs)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_REFUSE_APPLY
    local MsgBody = {
        Cmd = SubMsgID,
        RefuseApply = {
            TargetMemberRoleIDs = RoleIDs
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 部队邀请玩家
---@param RoleIDs table<number> 玩家Id列表
function ArmyMgr:SendArmyInviteMsg(RoleIDs)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_SEND_INVITATION
    local MsgBody = {
        Cmd = SubMsgID,
        SendInvite = {
            TargetMemberRoleIDs = RoleIDs
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 个人邀请玩家加入自己部队
function ArmyMgr:SendArmyInviteMsgByPlayer(RoleID)
    local ArmyID = self.SelfArmyID
    if ArmyID == nil then
        -- LSTR string:网络错误，请重试
        MsgTipsUtil.ShowTips(string.format(LSTR(910208)))
        return
    end
    if ArmyID > 0 then
        local RoleIDs = {
            [1] = RoleID
        }
        self:SendArmyInviteMsg(RoleIDs)
    else
        MsgTipsUtil.ShowTipsByID(MsgTipsID.Army_NoArmy)
    end
end

--- 获取收到的入队邀请列表 --改全量拉取，服务器做上限设置
function ArmyMgr:SendArmyGetInviteListMsg()
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUERY_INVITATIONS
    local MsgBody = {
        Cmd = SubMsgID,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 接受部队邀请
---@param ArmyID number 部队ID
function ArmyMgr:SendArmyAcceptInviteMsg(ArmyID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_ACCEPT_INVITATION
    local MsgBody = {
        Cmd = SubMsgID,
        AcceptInvite = {
            GroupID = ArmyID
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 玩家拒绝部队的邀请列表
---@param ArmyIDs table<number> 部队Id列表
function ArmyMgr:SendIgnoreInviteMsg(ArmyIDs)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_IGNORE_INVITATION
    local MsgBody = {
        Cmd = SubMsgID,
        IgnoreInvite = {
            GroupIDs = ArmyIDs
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 移除成员
---@param RoleIds table<number> 玩家Id列表
function ArmyMgr:SendKickMemberMsg(RoleID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_KICK_MEMBER
    local MsgBody = {
        Cmd = SubMsgID,
        KickMember = {
            MemberID = RoleID
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 获取申请加入部队的玩家列表
function ArmyMgr:SendGetArmyQueryApplyListMsg()
    self:ResetPageData(PageType.JoinApply)
    local PageData = self:GetPageDataByType(PageType.JoinApply)
    if PageData == nil or PageData.bPulling then
        return
    end
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUERY_APPLY_LIST
    local MsgBody = {
        Cmd = SubMsgID,
        QueryApplyList = {
            Offset = PageData.Offset,
            Limit = PageData.Limit
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 创建部队时发送招募标语校验
---@param RecruitSlogan string 招募标语
function ArmyMgr:SendCheckSloganMsg(RecruitSlogan)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_CHECK_SLOGAN

    local MsgBody = {
        Cmd = SubMsgID,
        CheckSlogan = { RecruitSlogan = RecruitSlogan },
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

end

--------- 部队仓库 Start---------
--- 部队存物品
function  ArmyMgr:SendGroupStoreDepositItem(StoreIndex, GID, Count, ResID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_STORE_DEPOSIT_ITEM

    local MsgBody = {
        Cmd = SubMsgID,
        StoreDeposit = {
            StoreIndex = StoreIndex,
            GID = GID,
            Count = Count,
            ResID = ResID,
        },
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 部队取物品
function  ArmyMgr:SendGroupStoreFetChItem(StoreIndex, GID, ResID, Num)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_STORE_FETCH_ITEM

    local MsgBody = {
        Cmd = SubMsgID,
        StoreFetch = {
            StoreIndex = StoreIndex,
            GID = GID,
            ResID = ResID,
            Num = Num,
        },
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 部队仓库扩容
function  ArmyMgr:SendGroupStoreAddExtraGrid(StoreIndex)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_STORE_ADD_EXTRA_GRID
    local ExpansionNum = self.Stores[StoreIndex].ExpansionNum + 1
    local MsgBody = {
        Cmd = SubMsgID,
        StoreAddGrid = {
            StoreIndex = StoreIndex,
            ExpansionNum =  ExpansionNum,
        },
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 部队仓库改名
function  ArmyMgr:SendGroupStoreSetStoreName(StoreIndex, Name, IconId)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_STORE_SET_STORE_NAME

    local MsgBody = {
        Cmd = SubMsgID,
        StoreSetName = {
            StoreIndex = StoreIndex,
            Name = Name,
            IconId = IconId,
        },
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 部队仓库全量信息请求
function  ArmyMgr:SendGroupStoreReqStoreInfo(StoreIndex)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_STORE_REQ_STORE_INFO

    local MsgBody = {
        Cmd = SubMsgID,
        StoreReqInfo = {
            StoreIndex = StoreIndex,
        },
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 部队仓库简单信息请求
function  ArmyMgr:SendGroupStoreReqStoreBaseInfo()
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_STORE_REQ_STORE_BASE_INFO

    local MsgBody = {
        Cmd = SubMsgID,
        StoreBaseInfo = {}
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---仓库红点取消
function  ArmyMgr:SendDelStoreRedDot()
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_READ_BAG

    local MsgBody = {
        Cmd = SubMsgID,
        ReadBag = {
            IDs = self.CancelStoreRedDotList
        },

    }
    -- 不能在这清空， 列表数据UpdateByValues会调一次onshow,会重新添加
    for _, ID in ipairs(self.CancelStoreRedDotList) do
        self:AddSendCancelStoreRedDot(ID)
    end
    
    self.CancelStoreRedDotList = {}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--------- 部队仓库 End---------

---查询部队成员数据
function ArmyMgr:SendQueryMembersMsg(RoleIds)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUERY_MEMBERS
    local MsgBody = {
        Cmd = SubMsgID,
        QueryMembers = {
            RoleIds = RoleIds
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---查询角色部队概要数据
function ArmyMgr:SendQueryArmyInfoByRoleIDs(RoleIDs)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUERY_ROLES_GROUP
    local MsgBody = {
        Cmd = SubMsgID,
        QueryRolesGroup = {
            RoleIDs = RoleIDs
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function ArmyMgr:SendGroupCategoryInternUpConfirm()
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_CATEGORY_INTERN_UP_CONFIRM
    local MsgBody = {
        Cmd = SubMsgID,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 修改部队分组数据
function ArmyMgr:SendGroupEditCategory(Categories)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_EDIT_CATEGORY
    local SendCategories = {}
    for _, CategorieData in ipairs(Categories) do
        local SendCategoryData = {}
        SendCategoryData.ID = CategorieData.ID
        SendCategoryData.IconID = CategorieData.IconID
        SendCategoryData.Name = CategorieData.Name
        SendCategoryData.PermisstionTypes = CategorieData.PermisstionTypes
        table.insert(SendCategories, SendCategoryData)
    end
    local MsgBody = {
        Cmd = SubMsgID,
        EditCategory = {
            Categories = SendCategories
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 查询部队分组数据 -- 目前只用于更新分组编辑界面
function ArmyMgr:SendGroupQueryCategory()
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUERY_CATEGORY
    local MsgBody = {
        Cmd = SubMsgID,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 查询编辑时间
function ArmyMgr:SendGroupQueryCategory()
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUERY_EDITED_TIMES
    local MsgBody = {
        Cmd = SubMsgID,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 查询敏感词
function ArmyMgr:SendGroupCheckSensitiveText(Text)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_CHECK_SENSITIVE_TEXT
    local MsgBody = {
        Cmd = SubMsgID,
        CheckSensitiveText = 
        {
            Text = Text,
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

end

--- 查询最新指定阶级的成员（不对外使用，仅在出错时查询更新数据，成员数据变化本身会推送）
function ArmyMgr:SendGroupQueryMemberByCategory(CategoryID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUERY_MEMBERS_BY_CATEGORY
    local MsgBody = {
        Cmd = SubMsgID,
        QueryMembersByCategory = 
        {
            CategoryID = CategoryID,
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 查询部队特效数据
function ArmyMgr:SendGroupBonusStateQuery()
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_BONUS_STATE_QUERY
    local MsgBody = {
        Cmd = SubMsgID,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end  

--- 部队特效购买
function ArmyMgr:SendGroupBonusStateBuy(ID, Num)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_BONUS_STATE_BUY
    local MsgBody = {
        Cmd = SubMsgID,
        BonusStateBuy = 
        {
            ID = ID,
            Num = Num,
            Version = self.SEDataVersion
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end 

--- 部队特效使用
function ArmyMgr:SendGroupBonusStateUse(ID, Index)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_BONUS_STATE_USE
    local MsgBody = {
        Cmd = SubMsgID,
        BonusStateUse = 
        {
            ID = ID,
            Index = Index,
            Version = self.SEDataVersion
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end 

--- 部队特效停用
function ArmyMgr:SendGroupBonusStateStop(ID, Index)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_BONUS_STATE_STOP
    local MsgBody = {
        Cmd = SubMsgID,
        BonusStateStop = 
        {
            ID = ID,
            Index = Index,
            Version = self.SEDataVersion
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end 

--- 部队仓库存金币
function ArmyMgr:SendGroupMoneyBagDeposit(Num, TotalNum)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_MONEY_BAG_DEPOSIT
    local MsgBody = {
        Cmd = SubMsgID,
        MoneyBagDeposit = 
        {
            Num = Num,
            TotalNum = TotalNum,
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end 

--- 部队仓库取金币
function ArmyMgr:SendGroupMoneyBagWithDraw(Num, TotalNum)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_MONEY_BAG_WITHDRAW
    local MsgBody = {
        Cmd = SubMsgID,
        MoneyBagWithdraw = 
        {
            Num = Num,
            TotalNum = TotalNum,
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end 

--- 部队仓库金币查询
function ArmyMgr:SendGroupMoneyBagQuery()
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_MONEY_BAG_QUERY
    local MsgBody = {
        Cmd = SubMsgID,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end 

--- 部队信息界面更新查询
function ArmyMgr:SendGroupQueryGroupBaseInfo(RoleID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUERY_GROUP_BASE_INFO
    local MsgBody = {
        Cmd = SubMsgID,
        GroupBaseInfo = {
            RoleID = RoleID,
        }
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end 

--- 部队邀请弹窗设置已读
function ArmyMgr:SendGroupInviteSetRead(GroupIDs)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_INVITE_SET_READ
    local MsgBody = {
        Cmd = SubMsgID,
        InviteSetRead = {
            GroupIDs = GroupIDs,
        },
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end 

function ArmyMgr:SendQuerySelfMember()
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_QUERY_SELF_MEMBERS
    local MsgBody = {
        Cmd = SubMsgID,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- // 组建书信息
-- message GroupPetition{
--   GroupPetitionBase  GroupPetition = 1; // 组建书信息
--   uint64 RoleID = 2;//创建者
--   repeated uint64 Signs = 3;//署名列表
--   int64 GainTime = 4;// 领取时间
-- }
---【署名】领取组建书
function ArmyMgr:SendGroupPeitionGain(GroupPetition)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_PETITION_GAIN
    local MsgBody = {
        Cmd = SubMsgID,
        PetitionGain = {
            GroupPetition = GroupPetition,
        },
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--查询组建书
function ArmyMgr:SendGroupPeitionQuery()
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_PETITION_QUERY
    local MsgBody = {
        Cmd = SubMsgID,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--编辑组建书
function ArmyMgr:SendGroupPeitionEdit(GroupPetition)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_PETITION_EDIT
    local MsgBody = {
        Cmd = SubMsgID,
        PetitionEdit = {
            GroupPetition = GroupPetition
        },
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--【署名】撤销组建部队
function ArmyMgr:SendGroupPeitionCancel(RoleID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_PETITION_CANCEL
    local MsgBody = {
        Cmd = SubMsgID,
        PetitionCancel = {
            RoleID = RoleID
        },
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--【署名】邀请署名
function ArmyMgr:SendGroupSignInvite(RoleID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_SIGN_INVITE
    local MsgBody = {
        Cmd = SubMsgID,
        SignInvite = {
            RoleID = RoleID,
        },
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--【署名】同意署名
function ArmyMgr:SendGroupSignAgree(RoleID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_SIGN_AGREE
    local MsgBody = {
        Cmd = SubMsgID,
        SignAgreeInvite = {
            RoleID = RoleID,
        },
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--【署名】拒绝署名
function ArmyMgr:SendGroupSignRefuse(RoleID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_SIGN_REFUSE
    local MsgBody = {
        Cmd = SubMsgID,
        SignRefuseInvite = {
            RoleID = RoleID,
        },
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--【署名】取消署名
function ArmyMgr:SendGroupSignCancel(RoleID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_SIGN_CANCEL
    local MsgBody = {
        Cmd = SubMsgID,
        SignCancel = {
            RoleID = RoleID,
        },
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 查询署名邀请列表
function ArmyMgr:SendGroupSignQueryInvites()
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_SIGN_QUERY_INVITES
    local MsgBody = {
        Cmd = SubMsgID,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 转国防联军
function ArmyMgr:SendGroupGrandCompanyChange(GrandCompanyType, Emblem)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_GRAND_COMPANY_CHANGE
    local MsgBody = {
        Cmd = SubMsgID,
        GrandCompanyChange = {
            GrandCompanyType = GrandCompanyType,
            Emblem = Emblem,
        },
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 活动偏好设置 单个设置
function ArmyMgr:SendGroupActivitySet(ID, IsOn)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_ACTIVITY_SET
    local MsgBody = {
        Cmd = SubMsgID,
        ActivitySet = {
            ID = ID,
            IsOn = IsOn,
        },
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 活跃时间设置
function ArmyMgr:SendGroupGrandActivitySetTime(ID)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_ACTIVITY_SET_TIME
    local MsgBody = {
        Cmd = SubMsgID,
        ActivitySetTime = {
            ID = ID
        },
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---情报界面编辑设置
function ArmyMgr:SendGroupRecruitSetProf(EditeData)
    local MsgID = CS_CMD.CS_CMD_GROUP
    local SubMsgID = SUB_MSG_ID.CS_CMD_GROUP_PROFILE_EDIT
    local MsgBody = {
        Cmd = SubMsgID,
        GroupProfileEdite = {
            RecruitStatus = EditeData.RecruitStatus,          ---招募状态
            RecruitSlogan = EditeData.RecruitSlogan,          --- 招募标语
            RecruitProfs = EditeData.RecruitProfs,            ---招募职业按位存储状态
            ActivityTime = EditeData.ActivityTime,            --- 活动时间
            ActivityIcons = EditeData.ActivityIcons,          ---活动ICON按位存储状态
        },
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-------------- Send Part End---------------------------

------------- OpenPanel Start -------------------------
--- 打开部队主界面
function ArmyMgr:OpenArmyMainPanel(SkipPanelID, SkipParams)
    ---防止未解锁时进入部队
    local ModuleID = ProtoCommon.ModuleID
	if  not _G.ModuleOpenMgr:ModuleState(ModuleID.ModuleIDArmy) then
		return false
	end

    --提审版本未下载全量资源时禁用部队系统
    if CommonUtil.ShouldDownloadRes() then
        CommonUtil.ShowDownloadResMsgBox()
        return false
    end

    self:ResetAll()
    local ArmyID = self.SelfArmyID
    if ArmyID == nil then
        -- LSTR string:网络错误，请重试
        MsgTipsUtil.ShowTips(string.format(LSTR(910208)))
        ---做容错处理，没有数据就重新请求，不阻塞玩家
        self:SendGetArmyInfoMsg()
    else
        local bJoinedArmy = ArmyID > 0
        ArmyMainVM:SetSkipPanelData(SkipPanelID, SkipParams)
        if bJoinedArmy then
            ArmyMainVM:SetIsOpenPanel(true)
            self:SendGetArmyDataMsg(ArmyID)
        else
            ArmyMainVM:SetIsOpenPanel(true)
            self:SendArmySearchByInputMsg()
            if not UIViewMgr:IsViewVisible(UIViewID.ArmyPanel) then
                UIViewMgr:ShowView(UIViewID.ArmyPanel)
            elseif SkipPanelID then
                local ArmyView = UIViewMgr:FindView(UIViewID.ArmyPanel)
                if ArmyView and ArmyView.OnRefreshUI then
                    ArmyView:SKipUI(SkipPanelID)
                end
            end
        end
        return true
    end
    return false
end

--- 打开仓库界面
function ArmyMgr:OpenArmyStore(IsOuterOpen)
    local IsInArmy = self:IsInArmy()
    if IsInArmy then
        ArmyMgr:SendGroupMoneyBagQuery()
        local Params = {
            IsOuterOpen = IsOuterOpen
        }
        UIViewMgr:ShowView(UIViewID.ArmyDepotPanel, Params)
    end
end

--- 打开查询部队界面
---@param ArmyID number 部队ID
function ArmyMgr:OpenArmyQueryListByID(ArmyID)
    if ArmyID == nil then
        --ArmyID = 806583285673192178
        FLOG_ERROR("ArmyMgr:OpenArmyQueryListByID ArmyID is nil")
        return
    end
    ---防止未解锁时进入部队
    local ModuleID = ProtoCommon.ModuleID
    if  not _G.ModuleOpenMgr:ModuleState(ModuleID.ModuleIDArmy) then
        return
    end
    local IsUnlockLevel = self:CheckIsArmyUnlockLevel()
    if IsUnlockLevel ~= true then
        ---未达到解锁等级，打开查看部队详情界面
        self:OpenArmyJoinInfoPanelByArmyID(ArmyID)
        return
    end
    if ArmyID > 0 then
        self.QuerySimpleID = ArmyID
        self.bQueryArmy = true
        self.SelfArmyID = 0
        ArmyMainVM:SetIsOpenPanel(true)
        self:SendArmySearchByInputMsg(ArmyID)
        if not UIViewMgr:IsViewVisible(UIViewID.ArmyPanel) then
            UIViewMgr:ShowView(UIViewID.ArmyPanel)
        end

        EventMgr:SendEvent(EventID.ArmySelfArmyIDUpdate)
    else
        FLOG_ERROR("ArmyMgr:OpenArmyQueryListByID ArmyID <= 0")
    end
end

--- 打开部队特效界面
function ArmyMgr:OpenArmySEPanel(IsOutOpen)
    local IsInArmy = self:IsInArmy()
    local IsUnLock = self:GetArmyPerermissionData(ArmyUpLevelPerermissionType.ArmySELevel)
    if IsInArmy and IsUnLock then
        self:QueryGroupBonusState(function()
            local Params = {IsOutOpen = IsOutOpen}
            UIViewMgr:ShowView(UIViewID.ArmySEPanel, Params)
        end)
    end
end

--- 打开部队信息编辑界面
function ArmyMgr:OpenArmyEditInfoPanel()
    local IsInArmy = self:IsInArmy()
    if IsInArmy then
        ArmyMainVM:SetInfoPanelIsOpenEditWin(true)
        self:OpenArmyMainPanel()
    end
end

--- 打开部队创建界面
function ArmyMgr:OpenArmyCreatePanel()
    local IsInArmy = self:IsInArmy()
    ---防止未解锁时进入部队
    local ModuleID = ProtoCommon.ModuleID
    if not IsInArmy and ModuleOpenMgr:ModuleState(ModuleID.ModuleIDArmy) then
        local SkipIndex = ArmyDefine.ArmySkipPanelID.CreatePanel
        self:OpenArmyMainPanel(SkipIndex)
    end
end

--- 部队商店是否解锁
function ArmyMgr:IsArmyShopUnlock()
    local IsInArmy = self:IsInArmy()
	local ArmyShopPermissionData = self:GetArmyPerermissionData(ArmyUpLevelPerermissionType.ArmyShopLevel)
	if IsInArmy and ArmyShopPermissionData then
		local ShopID = ArmyShopPermissionData.Value[1]
		if ShopID then
			return _G.ShopMgr:ShopIsUnLock(ShopID)
		end
	end

    return false
end

--- 打开部队商店界面
function ArmyMgr:OpenArmyShopPanel()
    local IsInArmy = self:IsInArmy()
    local ArmyShopPermissionData = self:GetArmyPerermissionData(ArmyUpLevelPerermissionType.ArmyShopLevel)
    if IsInArmy and ArmyShopPermissionData then
        local ShopID = ArmyShopPermissionData.Value[1]
        if ShopID then
            _G.ShopMgr:OpenShop(ShopID, nil, false, 2)
        end
    end
end


---ShowMsgBoxTwoOp             				@显示双选弹窗
---@param UIView UIView          			@调用者对象
---@param Title string   					@标题，默认为 ""
---@param Message string       				@文本信息，默认为 ""
---@param RightCB function					@右按钮回调
---@param LeftCB function 					@左按钮回调
---@param RightBtnName string   			@右按钮名称，默认为国际化字符串 确认
---@param LeftBtnName string   				@左按钮名称，默认为国际化字符串 取消
---@param Params MsgBoxExParams				@额外参数包
--- 打开部队转国防联军界面
function ArmyMgr:OpenTransferWin(Params)
    if Params then
        local GrandCompanyType = Params[1]
        local CurGrandCompanyType = self:GetArmyUnionType()
        if GrandCompanyType == CurGrandCompanyType then
            --相同国防联军拦截对话配置
            _G.NpcDialogMgr:PlayDialogLib(ArmyDefine.ArmyDialoglibID)
            return
        else
            _G.NpcDialogMgr:PlayDialogLib(0 -1)
        end
        local GrandCompanyName = ""
        for _, UnitedArmyTab in ipairs(ArmyDefine.UnitedArmyTabs) do
            if GrandCompanyType == UnitedArmyTab.ID then
                GrandCompanyName = UnitedArmyTab.Name
            end
        end
        ---冷却时间,单位小时，默认给24，后续会用读表数据覆盖
        local CDTime = 24
        --LSTR  是否要将部队转换至%s?
        local ContentTitle = string.format(LSTR(910367), GrandCompanyName)
        --LSTR 转队
        local Title = LSTR(910362)
        local Emblem = self:GetEmblem()
        local IsNeedReset = self:BadgeDataErrorCheckByGrandID(GrandCompanyType, Emblem.TotemID)
        if IsNeedReset then
            ---有专属队徽，重新随机一个
            Emblem = self:BadgeDataRandomly(GrandCompanyType)
        end
        local RightBtnName = LSTR(10002)
        local LeftBtnName = LSTR(10003)
        local CostNum
        local CostItemID
        local CostColor
        local RightBtnOpState
        local LeftBtnOpState = CommBtnColorType.Normal
        local WarningText
        -- local Params = {
        --     ---todo 等配置，以及格式等效果图
        --     CostNum = 15000,
        --     CostItemID = 19000002,
        -- }
        ---货币消耗
        local Costfg = GroupGlobalCfg:FindCfgByKey(ArmyDefine.GlobalCfgType.GlobalCfgGrandCompanyChangeCost)
        if Costfg then
            CostNum = Costfg.Value[2] 
            CostItemID = Costfg.Value[1] 
        end
        local CurCostNum = ScoreMgr:GetScoreValueByID(CostItemID )
        local NoEnoughCostNum = CostNum > CurCostNum
        if NoEnoughCostNum then
            --Params.CostNum = RichTextUtil.GetText(tostring(Params.CostNum), ArmyTextColor.NoEnoughRedHex)
            CostColor = ArmyTextColor.NoEnoughRedHex
            RightBtnOpState = CommBtnColorType.Normal
        else
            CostColor = "FFFFFFFF"
            RightBtnOpState = CommBtnColorType.Recommend
        end
        ---CD判断
        local CompanyChangeCDfg = GroupGlobalCfg:FindCfgByKey(ArmyDefine.GlobalCfgType.GlobalCfgGrandCompanyChangeCD)
        --local CDText = ""
        local CD = 86400
        local IsCD = false
        if CompanyChangeCDfg then
            CD = CompanyChangeCDfg.Value[1] * 3600 
            --CDText = CompanyChangeCDfg.Value[1]
            CDTime = CompanyChangeCDfg.Value[1] or CDTime
        end
        --LSTR 1.转换后，与原大国防联军的友好度将会降低为1级。
        -- 2.转换后，部队特效购买折扣将会根据最新友好度等级发生变化。
        -- 3.部队其他资产、状态等不会发生变化。
        -- 4.转籍后经过%s小时(地球时间)才可再次进行转籍。
        local Content = string.format(LSTR(910360), CDTime)
        local CompanyChangeTime = self:GetCompanyChangeTime() or 0
        local Time = TimeUtil.GetServerTime()
        if Time - CompanyChangeTime < CD then
            RightBtnOpState = CommBtnColorType.Normal
            CostNum = nil
            CostItemID = nil
            ---LSTR string:转队时间不满%s小时
            WarningText = string.format(LSTR(910361),CDTime)
            IsCD = true
        end
        local RightCB = function()
            if IsCD then
                -- LSTR string:无法转队，转队时间不满%s小时
                MsgTipsUtil.ShowTips(string.format(LSTR(910366), CDTime))
                return
            end
            if NoEnoughCostNum then
                -- LSTR string:无法转队，金钱不足
                MsgTipsUtil.ShowTips(LSTR(910368))
                return
            end
            if Emblem then
                self:SendGroupGrandCompanyChange(GrandCompanyType, Emblem)
                UIViewMgr:HideView(UIViewID.HelpInfoMidWinView)
            else
                print("NO Emblem Data")
            end
        end
        --MsgBoxUtil.ShowMsgBoxTwoOp(self ,Title, Message, RightCB, LeftCB, LeftBtnName, RightBtnName, Params)
        ----新弹窗接入
        local ConfirmFun = function()  
            UIViewMgr:HideView(UIViewID.HelpInfoMidWinView)
        end
        local Cfgs = {{ HelpName = Title, SecTitle = ContentTitle, SecContent = { { SecContent = Content }} }, {SecTitle = "", SecContent = { { SecContent = "" } }} }
        local NewParams = { 
            Cfgs = Cfgs, 
            ShowBtn = true, 
            LeftBtnText = LeftBtnName, 
            RightBtnText = RightBtnName, 
            View = self, 
            RightBtnCB = RightCB, 
            LeftBtnCB = ConfirmFun, 
            CloseBtnCB = ConfirmFun, 
            CostNum = CostNum,
            CostItemID = CostItemID,
            CostColor = CostColor,
            LeftBtnOpState = LeftBtnOpState,
            RightBtnOpState = RightBtnOpState,
            WarningText = WarningText, --错误警告文本

        }
        self.HelpInfoMidWinView = UIViewMgr:ShowView(UIViewID.HelpInfoMidWinView, NewParams)
    end
end

--- 打开查看部队界面
function ArmyMgr:OpenArmyJoinInfoPanel(RoleID, Params)
    ---外部调用，如果有部队就隐藏加入按钮
    if Params == nil then
        local IsInArmy = self:IsInArmy()
        if IsInArmy then
            local InfoParams = {
                IsHideBtn = true,
            }
            self:QueryArmyArmyBasePanelInfo(RoleID, ArmyDefine.ArmyInfoType.JoinInfo, nil, InfoParams)
        else
            local InfoParams = {
                OpenPath = ArmyDefine.ArmyOpenJoinInfoType.OuterPanel,
            }
            self:QueryArmyArmyBasePanelInfo(RoleID, ArmyDefine.ArmyInfoType.JoinInfo, nil, InfoParams)
        end
    else
        self:QueryArmyArmyBasePanelInfo(RoleID, ArmyDefine.ArmyInfoType.JoinInfo, nil, Params)
    end
end


--- 打开查看部队界面通过部队id
function ArmyMgr:OpenArmyJoinInfoPanelByArmyID(ArmyID)
    self:QueryArmySimple(ArmyID,  function(ArmySimple)
        local RoleID = ArmySimple.LeaderID
        self:OpenArmyJoinInfoPanel(RoleID)
    end, true)
end

--- 打开查看部队界面by本地数据/用于预览
function ArmyMgr:OpenArmyJoinInfoPanelByLocalData(Params)
    UIViewMgr:ShowView(UIViewID.ArmyJoinInfoViewWin, Params)
end

--- 打开部队邀请界面，并选中对应ID的部队
function ArmyMgr:OpenArmyInvitePanel(ArmyID)
    local IsInArmy = self:IsInArmy()
    ---防止未解锁时进入部队
    local ModuleID = ProtoCommon.ModuleID
    if not IsInArmy and ModuleOpenMgr:ModuleState(ModuleID.ModuleIDArmy) then
        local SkipIndex = ArmyDefine.ArmySkipPanelID.InvitePanel
        local SkipParams = {ArmyID = ArmyID, FailTipsID = ArmyDefine.ArmyTipsID.InvitedInvalidated}
        self:OpenArmyMainPanel(SkipIndex, SkipParams)
    end
end

--- 打开部队邀请界面，并选中对应ID的邀请
function ArmyMgr:OpenArmySignInvitePanel(RoleID)
    local IsInArmy = self:IsInArmy()
    ---防止未解锁时进入部队
    local ModuleID = ProtoCommon.ModuleID
    if not IsInArmy and ModuleOpenMgr:ModuleState(ModuleID.ModuleIDArmy) then
        local SkipIndex = ArmyDefine.ArmySkipPanelID.InviteSignPanel
        local SkipParams = {RoleID = RoleID, FailTipsID = ArmyDefine.ArmyTipsID.InvitedInvalidated}
        self:OpenArmyMainPanel(SkipIndex, SkipParams)
    end
end

function ArmyMgr:OpenInviteWinByItemType(ItemType)
    local PanleTitleText
    if ItemType == InviteSignSideDefine.InviteItemType.ArmyInvite then
        ---LSTR 邀请好友
        PanleTitleText = LSTR(910405)
    elseif ItemType == InviteSignSideDefine.InviteItemType.ArmySignInvite then
        ---LSTR 邀请署名
        PanleTitleText = LSTR(910336)
    end
    local Params =
    {
        ItemType = ItemType,
        MenusData = {MenuValues[InviteMenu.Friend]},
        PanleTitleText = PanleTitleText,
    }
    UIViewMgr:ShowView(UIViewID.ArmyInviteWin, Params)
end

--- 查询部队基础展示信息
function ArmyMgr:QueryArmyArmyBasePanelInfo(RoleID, Type, Callback, Params)
    local Time = TimeUtil.GetServerTime()
    local Info = { RoleID = RoleID, Callback = Callback, Time = Time, Type = Type , Params = Params}
    if nil == self.QueryArmyBaseInfoCallbackInfo then
        self.QueryArmyBaseInfoCallbackInfo = {}
    end
    table.insert(self.QueryArmyBaseInfoCallbackInfo, Info)
    local function WaitTimeOut(InInfo)
        table.remove_item(self.QueryArmyBaseInfoCallbackInfo, InInfo)
    end
    TimerMgr:AddTimer(nil, WaitTimeOut, ArmyDefine.QueryWaitTime, nil, nil, Info)

    self:SendGroupQueryGroupBaseInfo(RoleID)
end

function ArmyMgr:JumpToArmyShopGoods(ItemID, TransferData)
    local IsInArmy = self:IsInArmy()
    local ArmyShopPermissionData = self:GetArmyPerermissionData(ArmyUpLevelPerermissionType.ArmyShopLevel)
    if IsInArmy and ArmyShopPermissionData then
        local ShopID = ArmyShopPermissionData.Value[1]
        if ShopID then
            _G.ShopMgr:JumpToShopGoods(ShopID, ItemID, nil, TransferData)
            return
        end
    end

    -- LSTR string:部队商店尚未开启
    _G.MsgTipsUtil.ShowTips(LSTR(910253))
end

function ArmyMgr:OpenUIPanel(PanelFuncID, Params)
    local IsClosePlayDialog = true
    if PanelFuncID == ArmyDefine.ArmyPanelInteractID.SEPanel then
        self:OpenArmySEPanel(true)
    elseif PanelFuncID == ArmyDefine.ArmyPanelInteractID.InfoEditWin then
        self:OpenArmyEditInfoPanel()
    elseif PanelFuncID == ArmyDefine.ArmyPanelInteractID.ShopPanel then
        self:OpenArmyShopPanel()
    elseif PanelFuncID == ArmyDefine.ArmyPanelInteractID.CreatePanel then
        self:OpenArmyCreatePanel()
    elseif PanelFuncID == ArmyDefine.ArmyPanelInteractID.TransferWin then
        self:OpenTransferWin(Params)
        ---转队界面可能进对话，转队逻辑特殊处理
        IsClosePlayDialog = false
    end
    if IsClosePlayDialog then
        _G.NpcDialogMgr:PlayDialogLib(0 -1)
    end
end

--------------- OpenPanel end---------------------------------
---FindArmyEntryVMInternal
---@param ArmyID number
---@private
function ArmyMgr:FindArmyEntryVMInternal(ArmyID)
	if nil ~= self.ArmyViewModels then
		return self.ArmyViewModels[ArmyID]
	end
end

---FindArmyEntryVM
---@param ArmyID number
---@return ArmyEntryVM @如果没有缓存或者超时, 会请求服务数据
function ArmyMgr:FindArmyEntryVM(ArmyID, IsUseCache)
	if nil == ArmyID then
		return
	end
    local bValid = true
	local ViewModel = self:FindArmyEntryVMInternal(ArmyID)
    local Time = TimeUtil.GetServerTime()
	if nil == ViewModel then
		ViewModel = ArmyEntryVM.New()
		ViewModel.ID = ArmyID
        ViewModel.CacheTime = 0
		self.ArmyViewModels[ArmyID] = ViewModel
    end
    IsUseCache = IsUseCache ~= false and true or false
    if ArmyID > 0 then
        if not IsUseCache or Time - ViewModel.CacheTime > ArmyDefine.ArmyInfoCacheTime then
            bValid = false
            local Item = self.QueryPendingInfo[ArmyID]
            if nil == Item then
                self.QueryPendingInfo[ArmyID] = { ID = ArmyID, Time = Time, bRequest = false }
                if nil == self.QueryTimerID then
                    self.QueryTimerID = self:RegisterTimer(self.OnTimerQueryArmyInfo, 0, 0.1, -1)
                end
            end
        end
    end
	return ViewModel, bValid
end

---QueryGroupSimple
---@param ArmyID number0
---@param Callback function
---@param Params any
---@param IsUseCache boolean
function ArmyMgr:QueryArmySimple(ArmyID, Callback, IsUseCache)
    local ViewModel, bValid = self:FindArmyEntryVM(ArmyID, IsUseCache)
	if nil == Callback then
		return
	end
    if bValid then
		Callback(ViewModel)
	else
        local Time = TimeUtil.GetServerTime()
        local Info = { ArmyIDList = { ArmyID }, Callback = Callback, Time = Time, ViewModel = ViewModel }
        table.insert(self.QueryCallbackInfo, Info)
        local function WaitTimeOut(InInfo)
            table.remove_item(self.QueryCallbackInfo, InInfo)
            _G.FLOG_WARNING("[ArmyMgr] QueryGroupSimple WaitTimeOut")
        end
        TimerMgr:AddTimer(nil, WaitTimeOut, ArmyDefine.QueryWaitTime, nil, nil, Info)
    end
end

---QueryGroupSimple
---@param ArmyIDs table<number>
---@param Callback function
---@param Params any
---@param IsUseCache boolean
function ArmyMgr:QueryArmySimples(ArmyIDList, Callback, IsUseCache)
    local List = {}

	for _, v in ipairs(ArmyIDList) do
		if nil ~= v and 0 ~= v then
			local _, IsValid = self:FindArmyEntryVM(v, IsUseCache)
			if not IsValid and nil == table.find_item(List, v) then
				table.insert(List, v)
			end
		end
	end

	if nil == Callback then
		return
	end

	if #List > 0 then
		local Time = TimeUtil.GetServerTime()
		local Info = { ArmyIDList = List, Callback = Callback, Time = Time }
		table.insert(self.QueryCallbackInfo, Info)
		local function WaitTimeOut(InInfo)
			table.remove_item(self.QueryCallbackInfo, InInfo)
		end
		_G.TimerMgr:AddTimer(nil, WaitTimeOut, ArmyDefine.QueryWaitTime, nil, nil, Info)
	end

end

--- 是否已加入部队
function ArmyMgr:IsInArmy()
    local ArmyID = self.SelfArmyID
    return ArmyID and ArmyID > 0
end

---OnTimerQueryGroupInfo
---@private
function ArmyMgr:OnTimerQueryArmyInfo()
    local ArmyID = nil
    local QueryPendingInfo = self.QueryPendingInfo
    local Time = TimeUtil.GetServerTime()
	for _, v in pairs(QueryPendingInfo) do
		if not v.bRequest or Time - v.Time >= ArmyDefine.QueryOverTime then
			ArmyID = v.ID
            break
		end
	end
    if nil ~= ArmyID then
        local CurQueryPendingInfo = QueryPendingInfo[ArmyID]
        CurQueryPendingInfo.Time = Time
        CurQueryPendingInfo.bRequest = true
        self:SendGetArmyDataMsg(ArmyID)
    else
        if self.QueryTimerID ~= nil then
            self:UnRegisterTimer(self.QueryTimerID)
            self.QueryTimerID = nil
        end
        self.QueryPendingInfo = {}
    end
end

---ProcessQueryCallback
---@param ArmyID number
---@private
function ArmyMgr:ProcessQueryCallback(ArmyID)
	for i = #self.QueryCallbackInfo, 1, -1 do
		local Info = self.QueryCallbackInfo[i]
        table.remove_item(Info.ArmyIDList, ArmyID)
		if #Info.ArmyIDList <= 0 then
			if nil ~= Info.Callback then
				Info.Callback(Info.ViewModel)
			end
			table.remove(self.QueryCallbackInfo, i)
		end
	end
end

---ProcessQueryCallback
---@param ArmyID number
---@privates
function ArmyMgr:ProcessQueryMemberCallback()
    if self.QueryMemberCallbackInfo ~= nil then
        for i = #self.QueryMemberCallbackInfo, 1, -1 do
            local Elem = self.QueryMemberCallbackInfo[i]
            local Result =
            table.find_by_predicate(
            self.SelfArmyInfo.Members,
            function(Element)
                return Element.Simple.RoleID == Elem.RoleIDList[1]
            end
            )
            if nil ~= Elem.Callback then
                Elem.Callback(Result, Elem.Params)
            end
            table.remove(self.QueryMemberCallbackInfo, i)
        end
    end
end

---ProcessQueryCallback
---@param ArmySimpleList GroupSimple // 玩家部队简要信息
-- message GroupSimple{
--     uint64 RoleID = 1;
--     GroupSimpleInfo Simple = 2; // 简要信息
--     GroupPetition GroupPetition = 3;// 组件书信息
--     bool IsSignPetition = 4;//是否署名了他人的组建书
--   }
---@privates
function ArmyMgr:ProcessQueryArmySimpleCallback(ArmySimpleList)
    if self.QueryArmySimpleCallbackInfo ~= nil then
        for i = #self.QueryArmySimpleCallbackInfo, 1, -1 do
            local Elem = self.QueryArmySimpleCallbackInfo[i]
            local IsExist = false
            for _, RoleID in pairs(Elem.RoleIDs) do
                for _, ArmySimple in ipairs(ArmySimpleList) do
                    IsExist = false
                    if RoleID == ArmySimple.RoleID then
                        IsExist = true
                        break
                    end
                end
                if not IsExist then
                    break
                end
            end
            if IsExist then
                if nil ~= Elem.Callback then
                    Elem.Callback(ArmySimpleList, Elem.Params)
                end
                table.remove(self.QueryArmySimpleCallbackInfo, i)
            end
        end
    end
end

---ProcessQueryCallback
---@param ArmySimpleList GroupSimple
---@privates
function ArmyMgr:ProcessQueryArmyPanelBaseInfoCallback(PanelBaseInfo)
    if self.QueryArmyBaseInfoCallbackInfo ~= nil then
        for i = #self.QueryArmyBaseInfoCallbackInfo, 1, -1 do
            local Elem = self.QueryArmyBaseInfoCallbackInfo[i]
            ---todo 等服务器添加
            if PanelBaseInfo.RoleID == Elem.RoleID then
                if nil ~= Elem.Type then
                    if Elem.Type == ArmyDefine.ArmyInfoType.Info then
                        ArmyMainVM:UpdateArmyInfoPanel(PanelBaseInfo)
                    elseif Elem.Type == ArmyDefine.ArmyInfoType.JoinInfo then
                        local Params = {
                            PanelBaseInfo = PanelBaseInfo,
                            Info = Elem.Params,
                        }
                        UIViewMgr:ShowView(UIViewID.ArmyJoinInfoViewWin, Params)
                    elseif Elem.Type == ArmyDefine.ArmyInfoType.Profile then
                        ArmyMainVM:UpdateInformationData(PanelBaseInfo)
                    end
                end
                if nil ~= Elem.Callback then
                    Elem.Callback(PanelBaseInfo, Elem.Params)
                end
                table.remove(self.QueryArmyBaseInfoCallbackInfo, i)
            end
        end
    end
end

function ArmyMgr:GetSearchArmyCount()
    local PageData
    if LastSearchArmyInput == nil then
        PageData = self:GetPageDataByType(PageType.AllArmy)
    else
        PageData = self:GetPageDataByType(PageType.ArmySearch)
    end
    if PageData == nil then
        return 0
    end
    return PageData.Offset
end

function ArmyMgr:SetSearchArmyCount(Num)
    local PageData
    if LastSearchArmyInput == nil then
        PageData = self:GetPageDataByType(PageType.AllArmy)
    else
        PageData = self:GetPageDataByType(PageType.ArmySearch)
    end
    if PageData == nil then
        return 0
    end
    PageData.Offset = Num
end

function ArmyMgr:GetLogsCount()
    local PageData = self:GetPageDataByType(PageType.Log)
    if PageData == nil then
        return ArmyDefine.Zero
    end
    return PageData.Offset
end

function ArmyMgr:GetSelfArmyInfo()
    return self.SelfArmyInfo
end

function ArmyMgr:GetArmyUnionType()
    if self.SelfArmyInfo and self.SelfArmyInfo.Simple then
        return self.SelfArmyInfo.Simple.GrandCompanyType
    end
end

function ArmyMgr:SetArmyUnionType(GrandCompanyType)
    if self.SelfArmyInfo and self.SelfArmyInfo.Simple then
        self.SelfArmyInfo.Simple.GrandCompanyType = GrandCompanyType
    end
end

function ArmyMgr:GetArmyLevel()
    if self.SelfArmyInfo and self.SelfArmyInfo.Simple then
        return self.SelfArmyInfo.Simple.Level
    end
end

function ArmyMgr:GetSelfRoleInfo()
    return self.SelfRoleInfo
end

function ArmyMgr:GetSelfCategoryData()
    return self.SelfCategoryData
end

function ArmyMgr:GetArmyID()
    if self.SelfArmyInfo and self.SelfArmyInfo.Simple and self.SelfArmyInfo.Simple.ID then
        return self.SelfArmyInfo.Simple.ID 
    end
    return 0
end

function ArmyMgr:GetSelfIsHavePermisstion(QueryPermisstionType)
    if self:IsInArmy() then
        ---特殊处理，是部队长直接返回true,因为服务器不会初始化部队长的权限列表，在客户端第一次设置前，部队长的权限列表是空的
        local bLeader = self:IsLeader()
        if bLeader then
            return true
        end
        local CategoryData = self:GetSelfCategoryData()
        if CategoryData and CategoryData.PermisstionTypes then
            for _, PermisstionType in pairs(CategoryData.PermisstionTypes) do
                if PermisstionType == QueryPermisstionType then
                    return true
                end
            end
        end
    end
    return false
end

function ArmyMgr:GetIsHavePermisstionByCategoryID(ID, QueryPermisstionType)
    ---特殊处理，是部队长直接返回true,因为服务器不会初始化部队长的权限列表，在客户端第一次设置前，部队长的权限列表是空的
    local bLeader = ID == ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_PRESIDENT
    if bLeader then
        return true
    end
    local CategoryData = self:GetCategoryDataByID(ID)
    if CategoryData and CategoryData.PermisstionTypes then
        for _, PermisstionType in pairs(CategoryData.PermisstionTypes) do
            if PermisstionType == QueryPermisstionType then
                return true
            end
        end
    end
    return false
end

function ArmyMgr:GetArmyCategories()
    if self.SelfArmyInfo then
        return self.SelfArmyInfo.Categories
    else
        return {}
    end
end

function ArmyMgr:GetRecruitInfo()
    if self.SelfArmyInfo then
        local ArmySimple = self.SelfArmyInfo.Simple
        local RecruitStatus = ArmySimple.RecruitStatus
        local RecruitSlogan = ArmySimple.RecruitSlogan
        return RecruitStatus, RecruitSlogan
    end
end

function ArmyMgr:UpdateRecruitInfo(RecruitStatus, RecruitSlogan)
    local ArmySimple = self.SelfArmyInfo.Simple
    ArmySimple.RecruitStatus = RecruitStatus
    ArmySimple.RecruitSlogan = RecruitSlogan
end

--- 设置自己部队信息
function ArmyMgr:SetSelfArmyInfo(ArmyInfo)
    local OldArmyInfo = self.SelfArmyInfo
    local ArmySimple = ArmyInfo.Simple
    if nil == ArmySimple then
        _G.FLOG_WARNING("ArmyMgr:SetSelfArmyInfo: ArmyInfo.Simple is nil")
        return
    end
    self.SelfArmyInfo = ArmyInfo
    self.SelfArmyID = ArmySimple.ID
    self.ArmyUsedBonusStates = ArmyInfo.BonusStateUps
    self:SetEmblem(ArmySimple.Emblem)
    ---处理默认分组名
    self:DefaultCategoryNameWrite()
    self:GetMemberDataByRoleID(MajorUtil.GetMajorRoleID(), function(Member) 
        local RoleInfo = Member
        self.SelfRoleInfo = RoleInfo.Simple
        self.SelfCategoryData = self:GetCategoryDataByID(self.SelfRoleInfo.CategoryID)
        local LeaderRoleID = self:GetLeaderRoleID()
        local bLeader = self:IsLeader()
        ArmyMainVM:UpdateMyArmyInfo(ArmyInfo, self.SelfCategoryData, LeaderRoleID, bLeader)
    end)
    local ArmySimples = {{RoleID = MajorUtil.GetMajorRoleID(), Simple = ArmySimple}}
    self:SetRoleArmyAlias(ArmySimples)

    local OldAlias
    if OldArmyInfo and OldArmyInfo.Simple then
        OldAlias = OldArmyInfo.Simple.Alias
    end
    local Alias
    Alias = ArmySimple.Alias
    self:SendArmyShortNameChange(Alias, OldAlias)
    EventMgr:SendEvent(EventID.ArmySelfArmyIDUpdate)
end

function ArmyMgr:UpdateArmyShortName(Alias, EditTime)
    ArmyMainVM:UpdateArmyShortName(Alias, EditTime)
    local OldAlias = self:GetArmyAlias()
    self:SetArmyAlias(Alias)
    self:SendArmyShortNameChange(Alias, OldAlias, EditTime)
end

function ArmyMgr:SendArmyShortNameChange(Alias, OldAlias, EditTime)
    if OldAlias ~= Alias then
        EventMgr:SendEvent(EventID.ArmySelfArmyAliasUpdate, Alias, EditTime)
    end
end

--- 判断自身是否是部队长
function ArmyMgr:IsLeader()
    local LeardRoleID = self:GetLeaderRoleID()
    return LeardRoleID == MajorUtil.GetMajorRoleID()
end

--- 获取分组信息
---@param ID number @分组ID
function ArmyMgr:GetCategoryDataByID(ID)
    if nil == ID or not self.SelfArmyInfo then
        return nil
    end
    local CategoryData, ShowIndex =
        table.find_by_predicate(
        self.SelfArmyInfo.Categories,
        function(Element)
            return Element.ID == ID
        end
    )
    return CategoryData, ShowIndex
end

--- 获取分组排序位置
---@param ID number @分组ID
function ArmyMgr:GetCategoryShowIndexDataByID(ID)
    if nil == ID or not self.SelfArmyInfo then
        return nil
    end
    local CategoryData, ShowIndex =
        table.find_by_predicate(
        self.SelfArmyInfo.Categories,
        function(Element)
            return Element.ID == ID
        end
    )
    return ShowIndex
end

function ArmyMgr:GetCategoryIDByRoleID(RoleID, Callback, Params)
    ---兼容旧接口
    if nil == Callback then
        local RoleData = self:GetMemberDataByRoleID(RoleID)
        if RoleData == nil then
            return nil
        end
        local CategoryID = RoleData.Simple.CategoryID
        return CategoryID
    end

    self:GetMemberDataByRoleID(RoleID, function(Member, Params)
        Callback(Member.CategoryID, Params)
    end,Params)
    -- local RoleData = self:GetMemberDataByRoleID(RoleID)
    -- if RoleData == nil then
    --     return nil
    -- end
    -- local CategoryID = RoleData.CategoryID
    -- return CategoryID
end

--- 获取部队ID
function ArmyMgr:GetLeaderRoleID()
    ---todo self.LeaderRoleID貌似就没启用过,后续排查
    local RoleID = self.LeaderRoleID
    if nil == RoleID then
        if self.SelfArmyInfo and self.SelfArmyInfo.Simple and self.SelfArmyInfo.Simple.Leader then
            RoleID = self.SelfArmyInfo.Simple.Leader.RoleID
        end
    end
    return RoleID
end

--- 获取是否是部队成员
---@param RoleID number @RoleID
function ArmyMgr:GetIsArmyMemberByRoleID(RoleID)
    return self:GetMemberDataByRoleID(RoleID) ~= nil
end

--- 获取成员信息,如果只是判断是否是部队成员，可以不用传Callback
---@param RoleID number @RoleID
---@param IsEmptyCallback boolean @是否在本地数据为空时触发回调
function ArmyMgr:GetMemberDataByRoleID(RoleID, Callback, Params, IsEmptyCallback)
    if nil == self.SelfArmyInfo then
        return
    end

    local Result =
        table.find_by_predicate(
        self.SelfArmyInfo.Members,
        function(Element)
            return Element.Simple.RoleID == RoleID
        end
    )
    ---兼容查询是否是部队成员接口
    if nil == Callback then
        return Result
    end

    if nil == Result and not IsEmptyCallback then
        return
    end
    local Curtime = TimeUtil.GetServerTime()
    if Result and not Result.IsNotComplete and Result.Time and Curtime - Result.Time < ArmyDefine.MemberQueryTime then
        Callback(Result, Params)
    else
        local Time = TimeUtil.GetServerTime()
		local Info = { RoleIDList =  { RoleID }, Callback = Callback, Time = Time, Params = Params}
		table.insert(self.QueryMemberCallbackInfo, Info)
		local function WaitTimeOut(InInfo)
			table.remove_item(self.QueryMemberCallbackInfo, InInfo)
		end
        TimerMgr:AddTimer(nil, WaitTimeOut, ArmyDefine.QueryWaitTime, nil, nil, Info)

        self:SendQueryMembersMsg(Info.RoleIDList)
    end
end

--- 获取角色公会简单信息
---@param RoleIDs table @RoleIDs
function ArmyMgr:GetArmySimpleDataByRoleIDs(RoleIDs, Callback, Params)
        --- 防止空表报错，服务器不接受空表
        if nil == RoleIDs then
            return
        end
        local IsSend = false
        for _, RoleID in pairs(RoleIDs) do
            if RoleID then
                IsSend = true
                break
            end
        end
        if not IsSend then
            return
        end
        local Time = TimeUtil.GetServerTime()
		local Info = { RoleIDs = RoleIDs, Callback = Callback, Time = Time, Params = Params }
        if nil == self.QueryArmySimpleCallbackInfo then
            self.QueryArmySimpleCallbackInfo = {}
        end
		table.insert(self.QueryArmySimpleCallbackInfo, Info)
		local function WaitTimeOut(InInfo)
			table.remove_item(self.QueryArmySimpleCallbackInfo, InInfo)
		end
        TimerMgr:AddTimer(nil, WaitTimeOut, ArmyDefine.QueryWaitTime, nil, nil, Info)

        self:SendQueryArmyInfoByRoleIDs(Info.RoleIDs)
end

--- 添加成员
---@param RoleData GroupRoleData
function ArmyMgr:AddMemberToArmy(RoleData)
    local Result =
        table.find_by_predicate(
        self.SelfArmyInfo.Members,
        function(Element)
            return Element.Simple.RoleID == RoleData.Simple.RoleID
        end
    )
    if Result == nil then
        table.insert(self.SelfArmyInfo.Members, RoleData)
    end
end

--- 添加成员,只添加RoleId,详细数据需要再请求
---@param RoleId number
function ArmyMgr:AddMemberByRoleId(RoleId)
    if self.SelfArmyInfo == nil then
        self.SelfArmyInfo = {}
    end
    if self.SelfArmyInfo.Members == nil then
        self.SelfArmyInfo.Members = {}
    end
    local Result =
        table.find_by_predicate(
        self.SelfArmyInfo.Members,
        function(Element)
            return Element.Simple.RoleID == RoleId
        end
    )
    if Result == nil then
        local Member = {Simple = {RoleID = RoleId }, IsNotComplete = true}
        table.insert(self.SelfArmyInfo.Members, Member)
    end
end

--- 获取部队分组成员数量
function ArmyMgr:GetArmyMembersByCategotyID(CategoryID)
    local Members =
        table.find_all_by_predicate(
        self.SelfArmyInfo.Members,
        function(Element)
            return Element.Simple.CategoryID == CategoryID
        end
    )
    return Members
end

--- 获取部队分组IDs
function ArmyMgr:GetCategoryIconIDs()
    local IconIDs = {}
    for _, v in pairs(self.SelfArmyInfo.Categories) do
        table.insert(IconIDs, v.IconID)
    end
    return IconIDs
end
--- 获取部队分组PermissionIDS
function ArmyMgr:GetPermissionByCategoryID(CategoryID)
    local CategoryData = self:GetCategoryDataByID(CategoryID)
    if CategoryData then
        return CategoryData.PermisstionTypes
    end
    return {}
end

--- 修改成员分组
---@param RoleID number @RoleID
---@param CategoryID number @分组ID
function ArmyMgr:UpdateMemCategoryID(RoleID, CategoryID)
    if self.SelfArmyInfo == nil then
        self.SelfArmyInfo = {}
    end
    if self.SelfArmyInfo.Members == nil then
        self.SelfArmyInfo.Members = {}
    end
    local Result = table.find_by_predicate(self.SelfArmyInfo.Members, function(Element)
        return Element.Simple.RoleID == RoleID
    end)
    if Result then
        Result.Simple.CategoryID = CategoryID
    else
        FLOG_ERROR("角色ID == " .. tostring(RoleID) .. " 在部队成员中未找到此RoleID")
    end
end

function ArmyMgr:UpdatePermissionByCID(CategoryID, Types)
    local CategoryData = self:GetCategoryDataByID(CategoryID)
    if CategoryData then
        CategoryData.PermisstionTypes = Types
    end
end

function ArmyMgr:UpdatePermissionByCPermissions(CategoryPermissions)
    for _, CategoryPermission in ipairs(CategoryPermissions) do
        local CategoryData = self:GetCategoryDataByID(CategoryPermission.CategoryID)
        if CategoryData then
            CategoryData.PermisstionTypes = CategoryPermission.Types
        end
    end
end

--- 删除成员
---@param RoleID number @RoleID
function ArmyMgr:RemoveMemberByRoleID(RoleID)
    if self.SelfArmyInfo and self.SelfArmyInfo.Members then
        local Length = #self.SelfArmyInfo.Members
        for i = Length, 1, -1 do
            if RoleID == self.SelfArmyInfo.Members[i].Simple.RoleID then
                table.remove(self.SelfArmyInfo.Members, i)
                break
            end
        end
    end
end

--- 转移部队长
---@param OldLeaderRID number @旧部队长RoleID
---@param NewLeaderRID number @新部队长RoleID
---@param OldLeaderNewCategoryID number @旧部队长转移后的分组
function ArmyMgr:UpdateTransferLeader(OldLeaderRID, NewLeaderRID, OldLeaderNewCategoryID)
    local MyArmyInfo = self.SelfArmyInfo
    local ArmySimData = MyArmyInfo.Simple
    local NewLeaderMemData = table.find_by_predicate(MyArmyInfo.Members, function(Element)
        return Element.Simple.RoleID == NewLeaderRID
    end)
    local OldLeaderMemData = table.find_by_predicate(MyArmyInfo.Members, function(Element)
        return Element.Simple.RoleID == OldLeaderRID
    end)
    NewLeaderMemData.Simple.CategoryID = ArmyDefine.LeaderCID
    if OldLeaderMemData then
        OldLeaderMemData.Simple.CategoryID = OldLeaderNewCategoryID
    end
    ArmySimData.Leader = NewLeaderMemData
    MyArmyInfo.TransferLeaderTime = _G.TimeUtil.GetServerTime()
    return NewLeaderMemData, OldLeaderMemData
end

---@deprecated 增加新的分组
function ArmyMgr:AddCategoryData(CategoryData)
    table.insert(self.SelfArmyInfo.Categories, CategoryData)
end

---@deprecated 移除分组信息
---@param ID number @分组ID
function ArmyMgr:RemoveCategoryDataByID(ID)
    local Length = #self.SelfArmyInfo.Categories
    local bRemove = true
    local DelCategoryData = table.find_by_predicate(self.SelfArmyInfo.Categories, function(Element)
        return Element.ID == ID
    end)
    for i = Length, 1, -1 do
        local CategoryData = self.SelfArmyInfo.Categories[i]
        if DelCategoryData == CategoryData and bRemove then
            table.remove(self.SelfArmyInfo.Categories, i)
            bRemove = false
        else
            --- ShowInde 前移
            if CategoryData.ShowIndex > DelCategoryData.ShowIndex then
                CategoryData.ShowIndex =  CategoryData.ShowIndex - 1
            end
        end
    end
end

--- 修改分组信息名称、IconID
---@param ID number @分组ID
---@param Key string @键
---@param Vale any @值
function ArmyMgr:UpdateCategoryElement(ID, Key, Value)
    local Result = table.find_by_predicate(self.SelfArmyInfo.Categories, function(Element)
        return Element.ID == ID
    end)
    if Result and Result[Key] then
        Result[Key] = Value
    else
        FLOG_ERROR("ID == " .. tostring(ID) .. "or Key == " .. Key .. " not found in Categories")
    end
    return Result
end

--- 分组显示位置重置
---@param CategoryIDs any @新的分组列表(下标为 show_index)
function ArmyMgr:UpdateCategoriesByPosReset(CategoryIDs)
    local Categories = self.SelfArmyInfo.Categories
    if #Categories ~= #CategoryIDs then
        FLOG_ERROR("The number of categories is out of sync")
        return
    end
    for i, ID in ipairs(CategoryIDs) do
        local Result = table.find_by_predicate(Categories, function(Element)
            return Element.ID == ID
        end)
        if Result then
            Result.ShowIndex = i - 1
        end
    end
    ---需要给Categories排序
    table.sort(Categories, function(A, B)
        return A.ShowIndex < B.ShowIndex
    end)
end

--- 过去时间转换
---@param Time number @时间戳 秒
function ArmyMgr:GetPassTimeStr(Time)
    local PassTime = _G.TimeUtil.GetServerTime() - Time
    local Minute = math.floor(PassTime / ArmyDefine.Minutes)
    local Hour = math.floor(PassTime / ArmyDefine.Hour)
    local Day = math.floor(PassTime / ArmyDefine.Day)
    if Day > 0 then
        -- LSTR string:%d天前
        return string.format(_G.LSTR(910002), Day)
    elseif Hour > 0 then
        -- LSTR string:%d小时前
        return string.format(_G.LSTR(910003), Hour)
    elseif Minute > 0 then
        -- LSTR string:%d分钟前
        return string.format(_G.LSTR(910001), Minute)
    else
        if PassTime <= ArmyDefine.Zero then
            -- LSTR string:刚刚
            return _G.LSTR(910070)
        else
            -- LSTR string:%d秒前
            return string.format(_G.LSTR(910004), PassTime)
        end
    end
end

function ArmyMgr:UpdataInviteWindow(InviterRoleID, GroupID)
    local InviterName
    local ArmyName
    --- 如果在副本里，就不接入弹窗
    --- 在副本中
    local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
    ---暂时只屏蔽部队邀请，署名邀请直接显示
    if IsInDungeon and GroupID then
        if self.UnReadInviteList == nil then
            self.UnReadInviteList = {}
        end
        local ValidTime = GroupGlobalCfg:GetValueByType(ProtoRes.GroupGlobalConfigType.GroupGlobalConfigType_MaxApplyRecordKeepDays)
        if ValidTime then
            --- 天转秒
            ValidTime = ValidTime * 86400
        end
        local Curtime = TimeUtil.GetServerTime()
        ValidTime = Curtime + ValidTime
        local ViteInfo = {GroupID = GroupID, InviterRoleID = InviterRoleID,  ValidTime = ValidTime, Time = Curtime}
        table.insert(self.UnReadInviteList, ViteInfo)
    else
        --- 直接弹窗的不做时间判断
        RoleInfoMgr:QueryRoleSimple(InviterRoleID, function(_, RoleVM)
            if nil == RoleVM then
                return
            end
            -- LSTR string:未知
            InviterName = RoleVM.Name or LSTR(910162)
            if ArmyName ~= nil and GroupID then
                self:ShowInviteWindow(InviterName, ArmyName, GroupID)
                local ReadGroupIDs = {GroupID}
                self:SendGroupInviteSetRead(ReadGroupIDs)
            elseif GroupID == nil then
                ---无部队id视为署名邀请
                self:ShowInviteWindow(InviterName, nil, nil, nil, InviterRoleID)
            end
        end, nil, false)
        if GroupID then
            self:QueryArmySimple(GroupID, function(ArmyVM)
                if nil == ArmyVM then
                    return
                end
                -- LSTR string:未知
                ArmyName = ArmyVM.Name or LSTR(910162)
                if InviterName ~= nil then
                    self:ShowInviteWindow(InviterName, ArmyName, GroupID)
                    local ReadGroupIDs = {GroupID}
                    self:SendGroupInviteSetRead(ReadGroupIDs)
                end
            end, false)
        end
    end
end

--- 部队邀请弹窗
---@param InviterName string @邀请者名字
---@param ArmyName string @部队名字
---@param GroupID number @部队ID
---@param Time number @部队邀请有效时间 - 时间戳
function ArmyMgr:ShowInviteWindow(InviterName, ArmyName, GroupID, Time, RoleID)
    --- 副本里面不能有弹窗
    local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
    --- 先只屏蔽部队邀请，署名邀请等策划确认
    if IsInDungeon and GroupID then
        return
    end

    local AgreeArmyInviteCB ---同意邀请回调
    local RefuseArmyInviteCB ---拒绝邀请回调
    if GroupID then
        --- 不能有相同部队的邀请弹窗
        self:ClearInvitePopUpInfoByArmyID(GroupID)
        AgreeArmyInviteCB = function()
            --self:SendArmyAcceptInviteMsg(GroupID)
            ---打开邀请界面
            self:OpenArmyInvitePanel(GroupID)
            self:ClearInvitePopUpInfoByArmyID(GroupID)
        end
        RefuseArmyInviteCB = function()
            self:SendIgnoreInviteMsg({GroupID})
            self:ClearInvitePopUpInfoByArmyID(GroupID)
        end
    elseif RoleID then
        --- 不能有相同角色的署名弹窗
        self:ClearInvitePopUpInfoByRoleID(RoleID)
        AgreeArmyInviteCB = function()
            --self:SendGroupSignAgree(RoleID)
            ---打开邀请界面
            self:OpenArmySignInvitePanel(RoleID)
            self:ClearInvitePopUpInfoByRoleID(RoleID)
        end
        RefuseArmyInviteCB = function()
            self:SendGroupSignRefuse(RoleID)
            self:ClearInvitePopUpInfoByRoleID(RoleID)
        end
    end

    local RichName = RichTextUtil.GetText(InviterName,  ArmyTextColor.BlueHex)
    local Params = {}
    local CurSidebarType = SidebarType.ArmyInvite
    -- LSTR string:玩家%s
    Params.Desc1 = string.format(LSTR(910177), RichName)
    if ArmyName and ArmyName ~= "" then
        -- LSTR string:部队邀请
        Params.Title = LSTR(910263)
        -- LSTR string:邀请你加入部队[%s]
        Params.Desc2 = string.format(LSTR(910243), ArmyName)
        CurSidebarType = SidebarType.ArmyInvite
    else
        -- LSTR string:部队署名邀请
        Params.Title = LSTR(910410)
        -- LSTR string:邀请你署名部队组建
        Params.Desc2 = string.format(LSTR(910403))
        CurSidebarType = SidebarType.ArmySignInvite
    end

    local StartTime = TimeUtil.GetServerTime()
    local CountDown = 0
    local CountDownCfgTime = SidebarMgr:GetShowTimeByType(CurSidebarType) or 0
    local ValidShowTime = CountDownCfgTime or 0
    if Time then
        ValidShowTime = Time - StartTime
        if ValidShowTime < 0 and GroupID then
            ---去除无效邀请
            return
        end
        CountDown = CountDownCfgTime < ValidShowTime and CountDownCfgTime or ValidShowTime
    else
        CountDown = CountDownCfgTime
    end

    Params.RoleID = RoleID
    Params.GroupID = GroupID
    Params.TransData = {}
    --- 透传给展开后的侧边栏
    Params.TransData.GroupID = GroupID
    Params.TransData.RoleID = RoleID
    Params.CBFuncObj = self
    Params.CBFuncRight = AgreeArmyInviteCB
    Params.CBFuncLeft = RefuseArmyInviteCB
    ---LSTR:前往
    Params.BtnTextRight = LSTR(910408)
    SidebarMgr:AddSidebarItem(CurSidebarType, StartTime, CountDown, Params)
end

function ArmyMgr:OnGameEventSidebarItemTimeOut( Type, TransData )
    if Type ~= SidebarType.ArmyInvite and Type ~= SidebarType.ArmySignInvite then 
        return
    end
	--self:ClearInvitePopUpInfo()
    if TransData.GroupID then
        self:ClearInvitePopUpInfoByArmyID(TransData.GroupID)
    elseif TransData.RoleID then
        self:ClearInvitePopUpInfoByRoleID(TransData.RoleID)
    end
end

function ArmyMgr:ClearInvitePopUpInfo()
	--删除侧边栏VM数据
	SidebarMgr:RemoveSidebarAllItem(SidebarType.ArmyInvite)
    SidebarMgr:RemoveSidebarAllItem(SidebarType.ArmySignInvite)
end


function ArmyMgr:ClearInvitePopUpInfoByArmyID(ArmyID)
	--删除指定侧边栏VM数据
    SidebarMgr:RemoveSidebarItemByParam( ArmyID, "GroupID")
end

function ArmyMgr:ClearInvitePopUpInfoByRoleID(RoleID)
	--删除指定侧边栏VM数据
    SidebarMgr:RemoveSidebarItemByParam( RoleID, "RoleID")
end

function ArmyMgr:UpdateArmyLevelAndScore(GroupLevel, GroupScore)
    local OldLevel 
    if self.SelfArmyInfo and self.SelfArmyInfo.Simple then
        OldLevel = self.SelfArmyInfo.Simple.Level
        self.SelfArmyInfo.Simple.Level = GroupLevel
        if OldLevel ~= GroupLevel then
            EventMgr:SendEvent(EventID.ArmyLevelUpdate, GroupLevel)
        end
    end
    self:UpdataArmyScoreValue(GroupScore)
    ArmyMainVM:UpdateGroupScore(GroupScore)
end

--- 更新部队仓库和背包信息
---@param Index string @仓库下标
---@param Name string @部队仓库名字
---@param Capacity number @部队仓库容量
---@param Size number @部队仓库总量
---@param ExpansionNum number @部队仓库扩充次数
---@param Items number @部队物品信息
function ArmyMgr:UpdateArmyStoreAndBagInfo(Index, Name, Capacity, Size, ExpansionNum, Items, IconId)
    -- 更新背包信息，监听背包事件，无需接口
    --- self:UpdateBagInfo()
    self:UpdateArmyStore(Index, Name, Capacity, Size, ExpansionNum, Items, IconId)
end

--- 更新部队仓库信息
---@param Index number @仓库下标
---@param Name string @部队仓库名字
---@param Capacity number @部队仓库容量
---@param Size number @部队仓库总量
---@param ExpansionNum number @部队仓库扩充次数
---@param Items table @部队物品信息
function ArmyMgr:UpdateArmyStore(Index, Name, Capacity, Size, ExpansionNum, Items, IconId)
    local Store = self.Stores[Index]
    if nil == Store then
        self.Stores[Index] = {}
        Store = self.Stores[Index]
    end
    Store.Index = Index
    Store.Name = Name
    Store.Capacity = Capacity
    Store.Size = Size
    Store.ExpansionNum = ExpansionNum
    Store.Items = Items
    Store.IconId = IconId or 1
    if Store.IconId == 0 then
        Store.IconId = 1
    end
    local ArmyDepotPanelVM = ArmyMainVM:GetDepotPanelVM()
    local ArmyDepotPageVM = ArmyDepotPanelVM:GetDepotPageVM()
    if ArmyDepotPageVM ~= nil then
        ArmyDepotPageVM:OnItemUpdate()
        local DepotSimple = { DepotName = Store.Name, ItemNum = Store.Size, Index = Store.Index, Type = Store.IconId, Capacity = Store.Capacity, Items =  Store.Items}
        ArmyDepotPageVM:UpdateDepotPageVMForDepotSimple(DepotSimple)
    end
    -- local DepotpageItemVM = ArmyDepotPageVM:FindDepotPageVM(Index)
    -- if DepotpageItemVM ~= nil then
    --     DepotpageItemVM:UpdateItems(Items)
    -- end
end

function ArmyMgr:UpdateArmyStoreBaseInfo(Infos)
    for _, Info in ipairs(Infos) do
        if nil == self.Stores[Info.Index] then
            self.Stores[Info.Index] = {}
        end
        self.Stores[Info.Index].Name = Info.Name
    end
    if self.SelfArmyInfo then
        local ArmyInfoPageVM = ArmyMainVM:GetArmyInfoPageVM()
        ArmyInfoPageVM:UpdateDynamicLogs(self.SelfArmyInfo.TopLogs)
    end
end

---更新部队名字 + 图标
---@param Index number @仓库下标
function ArmyMgr:UpdateArmyStoreName(StoreIndex, Name, IconId)
    local Store = self.Stores[StoreIndex]
    self:UpdateNameMsgTips(StoreIndex, Name, IconId)
    Store.Name = Name
    Store.IconId = IconId or 1
    if Store.IconId == 0 then
        Store.IconId = 1
    end
    local ArmyDepotPanelVM = ArmyMainVM:GetDepotPanelVM()
    local ArmyDepotPageVM = ArmyDepotPanelVM:GetDepotPageVM()
    if ArmyDepotPageVM ~= nil then
        ArmyDepotPageVM:OnNameChanged(StoreIndex, IconId, Name)
    end

end

---部队名字 + 图标更新提示
---@param Index number @仓库下标
function ArmyMgr:UpdateNameMsgTips(StoreIndex, Name, IconId)
    local Store = self.Stores[StoreIndex]
    local Path = ""
    local OldIcon
    local CurrentIcon
    local IconConfig = GroupStoreIconCfg:FindAllCfg()
    if Store.IconId == 0 then
        Store.IconId = 1
    end
    for _, IconInfo in ipairs(IconConfig) do
        if IconInfo.ID == Store.IconId then
            Path = IconInfo.Icon
            OldIcon = RichTextUtil.GetTexture(Path, 40, 40, -8) or ""
            --OldIcon = string.format("%s%s",  '</>', OldIcon)
        end
        if IconInfo.ID == IconId then
            Path = IconInfo.Icon
            CurrentIcon = RichTextUtil.GetTexture(Path, 40, 40, -8) or ""
        end
    end
    if Store.Name == "" and StoreIndex then
        local StoreCfg = GroupStoreCfg:FindCfgByKey(StoreIndex)
        if StoreCfg then
            -- LSTR string:默认仓库名
            Store.Name = StoreCfg.GroupDefaultName or LSTR(910277)
        end
    end
    local OldName = Store.Name
    OldName = RichTextUtil.GetText(OldName, "e5e5e5")
    local CurrentName =  RichTextUtil.GetText(Name, "e5e5e5")
    -- LSTR string:{1} {2}已改名为{3} {4}
    local UpdateStr = StringTools.Format(LSTR(910022),OldIcon, OldName, CurrentIcon, CurrentName)
    MsgTipsUtil.ShowTips(UpdateStr)
end

---仓库扩容
---@param StoreIndex number @仓库下标
---@param ExpansionNum number @部队仓库扩充次数
function ArmyMgr:UpdateArmyStoreExpansionNum(StoreIndex, ExpansionNum)
    local Store = self.Stores[StoreIndex]
    Store.ExpansionNum = ExpansionNum

    local AddNum = GroupStoreEnlargeCfg:FindCfgByKey(ExpansionNum) and GroupStoreEnlargeCfg:FindCfgByKey(ExpansionNum).Enlarge or 0
    Store.Capacity = Store.Capacity + AddNum
    --- 仓库容量显示更新
    local ArmyDepotPanelVM = ArmyMainVM:GetDepotPanelVM()
    ArmyDepotPanelVM:UpdatePanelInfo()
end

---仓库名字获取
---@param StoreIndex number @仓库下标
function ArmyMgr:GetStoreName(StoreIndex)
    if self.Stores[StoreIndex] then
        return self.Stores[StoreIndex].Name
    end
end

---仓库扩容次数获取
---@param StoreIndex number @仓库下标
function ArmyMgr:GetStoreExpansionNum(StoreIndex)
    if self.Stores[StoreIndex] then
        return self.Stores[StoreIndex].ExpansionNum
    end
end

---仓库容量获取
---@param StoreIndex number @仓库下标
function ArmyMgr:GetStoreCapacity(StoreIndex)
    if self.Stores[StoreIndex] then
        return self.Stores[StoreIndex].Capacity
    end
end

---仓库数据获取
function ArmyMgr:GetAllStoreData()
    if self.Stores then
        return self.Stores
    end
end

---设置部队仓库Item剩余可堆叠数(只记录未满格子的)，{[StoreIndex] = {[ResID] = Num}}
function ArmyMgr:SetGroupStoreItemNumberStacks(ResID, Num, StoreIndex)
    if self.GroupStoreItemNumberStacksMap == nil then
        self.GroupStoreItemNumberStacksMap = {}
    end
    if self.GroupStoreItemNumberStacksMap[StoreIndex] == nil then
        self.GroupStoreItemNumberStacksMap[StoreIndex] = {}
    end
    local StoreMap = self.GroupStoreItemNumberStacksMap[StoreIndex]
    StoreMap[ResID] = Num
end

---获取部队仓库Item剩余可堆叠数(只记录未满格子的)
function ArmyMgr:GetGroupStoreItemNumberStacksByResID(ResID, StoreIndex)
    if self.GroupStoreItemNumberStacksMap == nil then
        return 0
    end
    if self.GroupStoreItemNumberStacksMap[StoreIndex] == nil then
        return 0
    end
    local StoreMap = self.GroupStoreItemNumberStacksMap[StoreIndex]
    return StoreMap[ResID] or 0
end

---清理部队仓库Item剩余可堆叠数(只记录未满格子的)
function ArmyMgr:ClearAllGroupStoreItemNumberStacks()
    self.GroupStoreItemNumberStacksMap = nil
end

---清理部队仓库Item剩余可堆叠数(只记录未满格子的)，单个仓库清理
function ArmyMgr:ClearGroupStoreItemNumberStacksByStoreIndex(StoreIndex)
    if self.GroupStoreItemNumberStacksMap == nil then
        return
    end
    if self.GroupStoreItemNumberStacksMap[StoreIndex] == nil then
        return
    end
    self.GroupStoreItemNumberStacksMap[StoreIndex] = nil
end


--- 部队红点相关 Start---------
---红点更新-服务器下发使用
function ArmyMgr:ArmyRedDotUpdate(RedDotMap, IsClientTrigger)
    for _, Data in pairs(RedDotMap) do
        --self.RedDotMap[Type] = Data
        ---已有就更新，没有就添加
        local RedDotData = self:GetRedDotDataByType(Data.Tid)
        if RedDotData then
            --- 申请红点变化时，需要保证申请列表同步刷新
            if Data.Tid == ProtoCS.GroupRedDotType.GroupRedDotTypeApply and RedDotData.Status ~= Data.Status then
                self:SendGetArmyQueryApplyListMsg()
            end
            --- 邀请红点变化时，需要保证邀请列表同步刷新
            if Data.Tid == ProtoCS.GroupRedDotType.GroupRedDotTypeInvite and RedDotData.Status ~= Data.Status then
                self:SendArmyGetInviteListMsg()
            end
            RedDotData.Status = Data.Status
        else
            table.insert(self.RedDotMap, Data)
            --- 申请红点变化时，需要保证申请列表同步刷新(只有服务器下发的变化触发)
            if Data.Tid == ProtoCS.GroupRedDotType.GroupRedDotTypeApply and not IsClientTrigger then
                self:SendGetArmyQueryApplyListMsg()
            end
            --- 邀请红点变化时，需要保证邀请列表同步刷新(只有服务器下发的变化触发)
            if Data.Tid == ProtoCS.GroupRedDotType.GroupRedDotTypeInvite and not IsClientTrigger then
                self:SendArmyGetInviteListMsg()
            end
        end
        self:ArmyRedDotDataUpdate(Data)
    end
end

---登录时红点更新，只有新增有红点的数据
function ArmyMgr:ArmyRedDotAllUpdate(RedDotMap)
    self.RedDotMap = RedDotMap
    for _, Type in pairs(ProtoCS.GroupRedDotType) do
        self:ArmyRedDotDataUpdateByType(Type)
    end
end

--- 红点系统增删调用
function ArmyMgr:ArmyRedDotDataUpdate(RedDotData)
    if RedDotData == nil then
        return
    end
    --- 仓库是动态红点，特殊处理
    if RedDotData.Tid == ProtoCS.GroupRedDotType.GroupRedDotTypeBag then
        if RedDotData.Status then
            for Index = 1, 64 do
                --- 与服务器做了约定，红点协议只更新仓库新增，不处理消失，消失走仓库已读协议
                local RedDotState = BitUtil.IsBitSetByInt64(RedDotData.Status, Index, false)
                if nil == self.StoreRedDotNameList[Index] then
                    if RedDotState then
                        self.StoreRedDotNameList[Index] = RedDotMgr:AddRedDotByParentRedDotID(ArmyDefine.ArmyRedDotID[RedDotData.Tid])
                        self:DelSendCancelStoreRedDot(Index)
                    end
                end
            end
        end
    else
        if RedDotData.Status then
            local RedDotState = BitUtil.IsBitSetByInt64(RedDotData.Status, 0, false)
            ---本地拦截无权限的申请红点
            local IsHavePermisstion = self:GetSelfIsHavePermisstion(ProtoRes.GroupPermissionType.GROUP_PERMISSION_TYPE_AcceptApply)
            ---无权限不显示申请红点
            if not IsHavePermisstion and RedDotData.Tid == ProtoCS.GroupRedDotType.GroupRedDotTypeApply then
                RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID[RedDotData.Tid])
                return
            end
            if RedDotState then
                ---拦截未解锁部队时的红点
                local ModuleID = ProtoCommon.ModuleID
                if  not _G.ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDArmy) then
                    return
                end
                RedDotMgr:AddRedDotByID(ArmyDefine.ArmyRedDotID[RedDotData.Tid])
            else
                RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID[RedDotData.Tid])
            end
        end
    end
end

--- 解锁时刷新红点
function ArmyMgr:OnRecommendArmyModuleOpen(ModuleID)
    if ModuleID == ProtoCommon.ModuleID.ModuleIDArmy then
        local ArmyID = self.SelfArmyID
        if ArmyID == nil then
            self:SendGetArmyInfoMsg()
        else
            if self.RedDotMap then
                self:ArmyRedDotAllUpdate(self.RedDotMap)
            end
        end
    end
end

--- 红点系统增删调用
function ArmyMgr:ArmyRedDotDataUpdateByType(Type)
    local RedDotData = self:GetRedDotDataByType(Type)
    self:ArmyRedDotDataUpdate(RedDotData)
end


--- 通过红点类型获取数据
function ArmyMgr:GetRedDotDataByType(Type)
    for _, RedDotData in ipairs(self.RedDotMap) do
        if Type == RedDotData.Tid then
            return RedDotData
        end
    end
end

--- 通过红点类型设置数据
function ArmyMgr:SetRedDotDataByType(Type, Status)
    local IsFind = false
    for _, RedDotData in ipairs(self.RedDotMap) do
        if Type == RedDotData.Tid then
            IsFind = true
            RedDotData.Status = Status
        end
    end
    if not IsFind then
        local RedDotData = {Tid = Type, Status = Status}
        table.insert(self.RedDotMap, RedDotData)
    end
end

--- 清理邀请/署名邀请红点
function ArmyMgr:ClearInviteRedDot()
    --- 清理署名邀请红点
    self:ClearRedDotByType(ProtoCS.GroupRedDotType.GroupRedDotTypeSignInvite)
    self:ArmyRedDotDataUpdateByType(ProtoCS.GroupRedDotType.GroupRedDotTypeSignInvite)
    --- 清理邀请红点
    self:ClearRedDotByType(ProtoCS.GroupRedDotType.GroupRedDotTypeInvite)
    self:ArmyRedDotDataUpdateByType(ProtoCS.GroupRedDotType.GroupRedDotTypeInvite)
end

--- 仓库红点清理
function ArmyMgr:ClearArmyStroeRedDot(IDs)
    for _, ID in ipairs(IDs) do
        self:DelSendCancelStoreRedDot(ID)
        if nil ~= self.StoreRedDotNameList[ID] then
            local IsDel = RedDotMgr:DelRedDotByName(self.StoreRedDotNameList[ID])
            if IsDel then
                self.StoreRedDotNameList[ID] = nil
            end
        end
    end
end

---仓库红点名获取（没有就是无红点）
function ArmyMgr:GetStroeRedDotName(Index)
    return self.StoreRedDotNameList[Index]
end

---仓库已发送已读红点添加
function ArmyMgr:AddSendCancelStoreRedDot(Index)
    if self.SendCancelStoreRedDotList then
        self.SendCancelStoreRedDotList[Index] = Index
    end
end

---仓库已发送已读红点清除
function ArmyMgr:DelSendCancelStoreRedDot(Index)
    if self.SendCancelStoreRedDotList and self.SendCancelStoreRedDotList[Index] then
        self.SendCancelStoreRedDotList[Index] = nil
    end
end


---仓库已读红点添加
function ArmyMgr:AddCancelStoreRedDot(Index)
    ---如果是已发送的
    for _, RedIndex in pairs(self.SendCancelStoreRedDotList) do
        if Index == RedIndex then
            return
        end
    end 
    ---如果是已有的
    for _, RedIndex in ipairs(self.CancelStoreRedDotList) do
        if Index == RedIndex then
            return
        end
    end 
    table.insert(self.CancelStoreRedDotList, Index)
end

---是否有仓库已读红点
function ArmyMgr:IsExistCancelStoreRedDot()
    return #self.CancelStoreRedDotList ~= 0
end

function ArmyMgr:ClearNoArmyRedDot()
    ---清理提醒红点/其他邀请红点在同意时会清理
    RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID[ProtoCS.GroupRedDotType.GroupRedDotTypeSignFull])
    RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID.ArmyCreateRemind)
end

---清理某个类型的红点
function ArmyMgr:ClearRedDotByType(Type)
    local RedData = self:GetRedDotDataByType(Type)
    if RedData then
        RedData.Status = 0
    else
        RedData = {Tid = Type, Status = 0}
        self:SetRedDotDataByType(Type, RedData)
    end
end

--- 部队红点相关 End------

---部队退出解散时用，清空部分数据
function ArmyMgr:ArmyQuit()
    ArmyMainVM:ArmyQuit()
    --- 只清除有问题数据，其他数据先不清除，防止报错
    self.SelfArmyInfo = {}
    --self.SelfArmyInfo.Members = {}
    local RedData = self:GetRedDotDataByType(ProtoCS.GroupRedDotType.GroupRedDotTypeApply)
    if RedData then
        RedData.Status = 0
    else
        RedData = {Tid = ProtoCS.GroupRedDotType.GroupRedDotTypeApply, Status = 0}
    end
    self:ArmyRedDotDataUpdateByType(ProtoCS.GroupRedDotType.GroupRedDotTypeApply)
    for _, RedDotName in pairs(self.StoreRedDotNameList) do
        RedDotMgr:DelRedDotByID(RedDotName)
    end
    ---清除本地红点（招募红点）
    RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID.ArmyInformationEditRemind)
    self.StoreRedDotNameList = {}
    self.CancelStoreRedDotList = {}
    -- ---清除见习转正倒计时
    -- if self.InternUpTimer ~= nil then
    --     self:UnRegisterTimer(self.InternUpTimer)
    --     self.InternUpTimer = nil
    -- end
    ---现在退出部队不会解锁了，屏蔽掉
    --ModuleOpenMgr:OnExitArmy()
    self:HideAllArmyView()

    self:SetArmyAlias()
    EventMgr:SendEvent(EventID.ArmySelfArmyAliasUpdate)
    EventMgr:SendEvent(EventID.ArmySelfArmyIDUpdate)
    EventMgr:SendEvent(EventID.ArmyExit)
    ---设置状态
    self:SetArmyState(ProtoCS.RoleGroupState.RoleGroupStateInit)
end

--- 获取部队成员RoleID列表
function ArmyMgr:GetArmyAllMemberRoleID()
    if nil == self.SelfArmyInfo or nil == self.SelfArmyInfo.Members then
        ---应组队需求，无部队时返回空表
        return {}
    end
    local MemberRoleIDList = {}
    for _, Member in pairs(self.SelfArmyInfo.Members) do
        table.insert(MemberRoleIDList, Member.Simple.RoleID)
    end
    return MemberRoleIDList
end

--- 设置RoleVM的部队简称
function ArmyMgr:SetRoleArmyAlias(ArmySimples)
    for _, ArmySimple in ipairs(ArmySimples) do
        ---实时修改，保证个人铭牌那边数据无问题
        local RoleVM = RoleInfoMgr:FindRoleVM(ArmySimple.RoleID)
        local Alias
        if ArmySimple and ArmySimple.Simple then
            Alias = ArmySimple.Simple.Alias
        end
        if RoleVM then
            RoleVM:SetArmyAlias(Alias)
        end
    end
    
end

--- 获取自己部队简称
function ArmyMgr:GetArmyAlias()
    if self.SelfArmyInfo and self.SelfArmyInfo.Simple then
        return self.SelfArmyInfo.Simple.Alias
    end
end

--- 设置自己部队简称
function ArmyMgr:SetArmyAlias(Alias)
    if self.SelfArmyInfo and self.SelfArmyInfo.Simple then
        self.SelfArmyInfo.Simple.Alias = Alias
    end
end

function ArmyMgr:SetInternUpTimer()
    if not self:IsInArmy() then
        if self.InternUpTimer ~= nil then
            self:UnRegisterTimer(self.InternUpTimer)
            self.InternUpTimer = nil
        end
        return
    end
end


---查询文本是否合法（敏感词）
---@param Text string @文本内容
---@param Callback function @查询结果回调函数，参数1，查询结果(是否合法true/false)；参数2，查询的原始文本Text
---todo 应该会有QueryCheckTextCallback被覆盖的风险，后续优化，先保持和JudgeSearchMgr:QueryTextIsLegal一致
function ArmyMgr:CheckSensitiveText( Text, Callback)
    if string.isnilorempty(Text) then
        if Callback ~= nil then
            Callback(Text, false)
        end
        return
    end
    self.QueryCheckTextCallback = Callback
    self:SendGroupCheckSensitiveText(Text)
end

---根据日志数据组装文本
function ArmyMgr:LogTextPushChat(LogDatas)
    ---第一个参数是否是角色id
    for _, LogData in ipairs(LogDatas) do
        ArmyMgr:GetArmyLogTextByLogData(LogData, function(Text)
            local ChatMgr = _G.ChatMgr
            ChatMgr:AddArmyChatMsg(Text, 0, true)
        end)
    end

end

---推送成员上线
function ArmyMgr:MemberOlinePushChat(RoleID)
    RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
        -- LSTR string:上线了
        local Str = LSTR(910026)
        local Text = string.format("%s%s", RoleVM.Name or "", Str)
        local ChatMgr = _G.ChatMgr
        ChatMgr:AddArmyChatMsg(Text, 0, true)
        end, nil, true)
end

----@param BonusStateData table  { IDs = {int}, -- 已持有的加成状态id列表 Ups = {Up = {ID = 1,-- 加成状态ID EndTime = 2 --结束时间}}-- 生效中的加成状态列表}
function ArmyMgr:UpdateArmyBonusStateData(BonusStateData)
    self.ArmyBonusStates = BonusStateData.IDs
    self.ArmyUsedBonusStates = BonusStateData.Ups
    self.Reputation = BonusStateData.Reputation
    ArmyMainVM:UpdateBonusStateData(BonusStateData)
end


---部队内部查询使用，后续需要再拓展
function ArmyMgr:QueryGroupBonusState(Callback)
    self:SendGroupBonusStateQuery()
    self.QueryGroupBonusStateCallback = Callback
end

function ArmyMgr:GetArmyBonusStates()
    return self.ArmyBonusStates    
end

function ArmyMgr:GetArmyBonusStatesNum()
    if self.ArmyBonusStates then
        return #self.ArmyBonusStates
    else
        return 0
    end
end

function ArmyMgr:GetArmyUsedBonusStates()
    return self.ArmyUsedBonusStates    
end

function ArmyMgr:GetArmyMaxBonusStatesNum()
    if nil == self.ArmyMaxBonusStatesNum then
        self.ArmyMaxBonusStatesNum = GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.GlobalCfgGroupBonusStateNum)
    end
    return self.ArmyMaxBonusStatesNum 
end

function ArmyMgr:GetArmyMaxUsedBonusStatesNum()
    if nil == self.ArmyMaxUsedBonusStatesNum then
        self.ArmyMaxUsedBonusStatesNum = GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.GlobalCfgGroupBonusStateUpNum)
    end
    return self.ArmyMaxUsedBonusStatesNum 
end

function ArmyMgr:GetArmyScoreValue()
    if self.SelfArmyInfo and self.SelfArmyInfo.Score then
        return self.SelfArmyInfo.Score.Count or 0
    end
end

function ArmyMgr:UpdataArmyScoreValue(Count)
    if self.SelfArmyInfo and self.SelfArmyInfo.Score then
        self.SelfArmyInfo.Score.Count = Count
    end
end

function ArmyMgr:AddArmyBonusState(ID, Num)
   for _ = 1, Num do
        table.insert(self.ArmyBonusStates, ID)
   end
end

function ArmyMgr:DelArmyBonusState(ID, Num)
    local DelID = ID
    for _ = 1, Num do
        local _, Index = table.find_by_predicate(self.ArmyBonusStates, function(A)
            return DelID == A
        end)
        if Index then
            table.remove(self.ArmyBonusStates, Index)
        end
    end
 end

 function ArmyMgr:AddArmyUsedBonusState(ID, EndTime, Index)
    table.insert(self.ArmyUsedBonusStates, {ID = ID, EndTime = EndTime, Index = Index})
 end

 function ArmyMgr:DelArmyUsedBonusState(ID)
    local DelID = ID
    local _, Index = table.find_by_predicate(self.ArmyUsedBonusStates, function(A)
        return DelID == A.ID
    end)
    if Index then
        table.remove(self.ArmyUsedBonusStates, Index)
    end
 end

 function ArmyMgr:SetMoneyStoreNumAndUpdateVMdata(TotalNum, IsAnimPlay)
    self:SetMoneyStoreNum(TotalNum)
    ArmyMainVM:UpdateArmyMoneyStoreData(TotalNum, IsAnimPlay)
 end

 function ArmyMgr:SetMoneyStoreNum(TotalNum)
    self.MoneyStoreNum = TotalNum
 end

 function ArmyMgr:UseGroupBonusState(ID)
    if #self.ArmyUsedBonusStates >= self.ArmyMaxUsedBonusStatesNum then
        local CurTime = TimeUtil.GetServerTime()
        if self.UseGroupBonusStateNumErrorNextTime and self.UseGroupBonusStateNumErrorNextTime < CurTime then
            self.UseGroupBonusStateNumErrorNextTime = CurTime + 3
            MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyErrorCode.UseGroupBonusStateNumError)
        end
        return
    end
    local AllCfg = GroupBonusStateGroupCfg:FindAllCfg()
    local StateGroupData = {}
    for _, StateGroup in ipairs(AllCfg) do
        local IsFind
        for _, State in ipairs(StateGroup.States) do
            if State.ID == ID then
                IsFind = true
                break
            end
        end
        if IsFind then
            StateGroupData = StateGroup
        end
    end
    local IsExist = true
    local Index = 0
    while(IsExist) do
        Index = Index + 1
        IsExist = table.find_by_predicate(self.ArmyUsedBonusStates, function(A)
            return A.Index == Index
        end)
    end
    for _, UsedBonusState in ipairs(self.ArmyUsedBonusStates) do
        if self.ArmyUsedBonusStates.Index == Index then
            IsExist = true
        end
        for _, State in ipairs(StateGroupData.States) do
            if State.ID == UsedBonusState.ID then
                local CurTime = TimeUtil.GetServerTime()
                if CurTime - UsedBonusState.EndTime > 0 then
                    ArmyMgr:SendGroupBonusStateUse(ID, Index)
                else
                    if self.UseGroupBonusStateTypeErrorNextTime and self.UseGroupBonusStateTypeErrorNextTime < CurTime then
                        self.UseGroupBonusStateTypeErrorNextTime = CurTime + 3
                        MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyErrorCode.UseGroupBonusStateTypeError)
                    end
                end
                return
            end
        end
    end
    ArmyMgr:SendGroupBonusStateUse(ID, Index)
 end

 function ArmyMgr:FormatMoneyNumber(MoneyNum)

    local resultNum = MoneyNum
    if type(MoneyNum) == "number" then
        local inter, point = math.modf(MoneyNum)

        local StrNum = tostring(inter)
        local NewStr = ""
        local NumLen = string.len( StrNum )
        local Count = 0
        for i = NumLen, 1, -1 do
            if Count % 3 == 0 and Count ~= 0  then
                NewStr = string.format("%s,%s",string.sub( StrNum,i,i),NewStr) 
            else
                NewStr = string.format("%s%s",string.sub( StrNum,i,i),NewStr) 
            end
            Count = Count + 1
        end
        ---小数点，不显示
        -- if point > 0 then
        --     --@desc 存在小数点
        --     local strPoint = string.format( "%.2f", point )
        --     resultNum = string.format("%s%s",NewStr,string.sub( strPoint,2, string.len( strPoint ))) 
        -- else
        resultNum = NewStr
        --end
    end
    
    return resultNum
 end

---根据类型获取日志ICON
function ArmyMgr:GetArmyLogIconByLogType(LogType)
    local CfgData = GroupLogCfg:FindCfgByKey(LogType)
    if CfgData == nil then
        return
    end
    local LogIcon = CfgData.Icon
    return LogIcon
end

 ---根据数据组装日志文本
function ArmyMgr:GetArmyLogTextByLogData(LogData, CallBack)
    if LogData == nil then
        return
    end
    local Type = LogData.LogType
    local CfgData = GroupLogCfg:FindCfgByKey(Type)
    if CfgData == nil then
        return
    end
    local FormatText = CfgData.Text
    if Type == ArmyLogType.LogTypeCreateGroup then
        --  组建了新部队
        CallBack(FormatText)
    elseif Type == ArmyLogType.LogTypeGroupLevelUp then
        --  部队等级提升为%d级
        local Text = StringTools.Format(FormatText, LogData.Params[1])
        CallBack(Text)
    elseif Type == ArmyLogType.LogTypePermissionUnlock then
        --  获得了“<span color="#D1BA8EFF">%s</>”的权利
        local PermissionCfg = GroupUplevelpermissionCfg:FindCfgByKey(LogData.Params[1])
        local PermissionStr = ""
        if PermissionCfg then
            PermissionStr = PermissionCfg.Permission
        end
        local Text = StringTools.Format(FormatText, PermissionStr)
        CallBack(Text)
    elseif Type == ArmyLogType.LogTypeEditGroupNotice then
        --  <span color="#6FB1E9FF">%s</>编辑了公告
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local Text = StringTools.Format(FormatText, RoleVM.Name or "")
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeEditGroupName then
        --  部队名已被修改为“%s”
        local Text = StringTools.Format(FormatText, LogData.StringParams[1])
        CallBack(Text)
    elseif  Type == ArmyLogType.LogTypeEditGroupAlias then
        --  部队简称已被修改为“%s”
        local Text = StringTools.Format(FormatText, LogData.StringParams[1])
        CallBack(Text)
    elseif Type == ArmyLogType.LogTypeEditGroupEmblem then
        --  <span color="#6FB1E9FF">%s</>更新了部队队徽
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local Text = StringTools.Format(FormatText, RoleVM.Name or "")
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeCategoryAdd then
        --  <span color="#6FB1E9FF">%s</>添加了“%s”阶级
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local Text = StringTools.Format(FormatText, RoleVM.Name or "", LogData.StringParams[1])
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeCategoryDelete then
        --  <span color="#6FB1E9FF">%s</>删除了“%s”阶级
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local Text = StringTools.Format(FormatText, RoleVM.Name or "", LogData.StringParams[1])
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeCategoryEditName then
        --  <span color="#6FB1E9FF">%s</>将阶级名称更改为“%s”
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local Text = StringTools.Format(FormatText, RoleVM.Name or "", LogData.StringParams[1])
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeCategoryEditPermission then
        --  <span color="#6FB1E9FF">%s</>修改了“%s”阶级的设置
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local Text = StringTools.Format(FormatText, RoleVM.Name or "", LogData.StringParams[1])
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeJoin then
        --  <span color="#6FB1E9FF">%s</>加入了部队
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local Text = StringTools.Format(FormatText, RoleVM.Name or "")
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeQuit then
        --  <span color="#6FB1E9FF">%s</>退出了部队
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local Text = StringTools.Format(FormatText, RoleVM.Name or "")
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeDepositItem then
        --  <span color="#6FB1E9FF">%s</>存入了%d个<span color="#D1BA8EFF">%s</>到仓库
        local ItemName = ItemCfg:GetItemName(LogData.Params[2])
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local Text = StringTools.Format(FormatText, RoleVM.Name or "", LogData.Params[3], ItemName)
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeFetchItem then
        --  <span color="#6FB1E9FF">%s</>从仓库取出了%d个<span color="#D1BA8EFF">%s</>
        local ItemName = ItemCfg:GetItemName(LogData.Params[2])
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local Text = StringTools.Format(FormatText, RoleVM.Name or "", LogData.Params[3], ItemName)
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeSetMemberCategory then
        --  <span color="#6FB1E9FF">%s</>就任为“%s”
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local Text = StringTools.Format(FormatText, RoleVM.Name or "",LogData.StringParams[1])
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeBonusStateObtain then
        -- 获得特效
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local GroupBonusStateData = GroupBonusStateDataCfg:FindCfgByKey(LogData.Params[2])
            -- LSTR string:未知特效
            local SEName = LSTR(910163)
            if GroupBonusStateData and GroupBonusStateData.EffectName then
                SEName =  GroupBonusStateData.EffectName
            end
            local Text = StringTools.Format(FormatText, RoleVM.Name or "", SEName)
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeBonusStateUse then
        -- 使用特效
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local GroupBonusStateData = GroupBonusStateDataCfg:FindCfgByKey(LogData.Params[2])
            -- LSTR string:未知特效
            local SEName = LSTR(910163)
            if GroupBonusStateData and GroupBonusStateData.EffectName then
                SEName =  GroupBonusStateData.EffectName
            end
            local Text = StringTools.Format(FormatText, RoleVM.Name or "", SEName)
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeBonusStateStop then
        -- 取消特效
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local GroupBonusStateData = GroupBonusStateDataCfg:FindCfgByKey(LogData.Params[2])
            -- LSTR string:未知特效
            local SEName = LSTR(910163)
            if GroupBonusStateData and GroupBonusStateData.EffectName then
                SEName =  GroupBonusStateData.EffectName
            end
            local Text = StringTools.Format(FormatText, RoleVM.Name or "", SEName)
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeMoneyBagDeposit then
        -- 存金币
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local Num = self:FormatMoneyNumber(LogData.Params[3])
            local Icon = ScoreMgr:GetScoreIconName(LogData.Params[2])
            if Icon then
                Icon = RichTextUtil.GetTexture(Icon, 40, 40, -8)
            else
                Icon = ""
            end
            local Text = StringTools.Format(FormatText, RoleVM.Name or "", Icon, Num)
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeMoneyBagWithdraw then
        -- 取金币
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
            local Num = self:FormatMoneyNumber(LogData.Params[3])
            local Icon = ScoreMgr:GetScoreIconName(LogData.Params[2])
            if Icon then
                Icon = RichTextUtil.GetTexture(Icon, 40, 40, -8)
            else
                Icon = ""
            end
            local Text = StringTools.Format(FormatText, RoleVM.Name or "", Icon, Num)
            CallBack(Text)
            end, nil, true)
    elseif Type == ArmyLogType.LogTypeGrandCompanyChanged then
        -- 转国防联军
        local GrandCompanyName = ""
        for _, UnitedArmyTab in ipairs(ArmyDefine.UnitedArmyTabs) do
            if LogData.Params[1] == UnitedArmyTab.ID then
                GrandCompanyName = UnitedArmyTab.Name
            end
        end
        -- 部队转移到了“{1}”属下。
        local Text = StringTools.Format(FormatText, GrandCompanyName)
        CallBack(Text)
    elseif Type == ArmyLogType.LogTypeInformatioinChanged then
        RoleInfoMgr:QueryRoleSimple(LogData.Params[1], function(_, RoleVM)
        -- {1}更新了部队信息
        local Text = StringTools.Format(FormatText, RoleVM.Name or "")
        CallBack(Text)
        end, nil, true)
    end
end

function ArmyMgr:GetSearchArmyListIsEnd()
    return self.ArmyListIsEnd
end

function ArmyMgr:SetSearchArmyListIsEnd(IsEnd)
    self.ArmyListIsEnd = IsEnd
end

function ArmyMgr:ClearLastSearchArmyInput()
    LastSearchArmyInput = nil
end

--- 获取部队分组成员数量
function ArmyMgr:GetArmyMembersCount()
    if self.SelfArmyInfo and self.SelfArmyInfo.Members then
        return #self.SelfArmyInfo.Members
    else
        return 0
    end
end

--- 获取部队成员最大数量
function ArmyMgr:GetArmyMemberMaxCount(ArmyLevel)
    local Level = ArmyLevel or self:GetArmyLevel()
    if Level then
        local MemberPermissionData = ArmyMgr:GetArmyPerermissionData(ArmyUpLevelPerermissionType.ArmyMemberNumUp, ArmyLevel)
        if MemberPermissionData then
            local MaxCount = MemberPermissionData.Value[1]
            return MaxCount
        end
    end
    local DefaultMemberCount = GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.GlobalCfgGroupDefaultMemberNum)
    if DefaultMemberCount then
        return DefaultMemberCount
    end
    return 0
end

--- 获取部队仓库数量
function ArmyMgr:GetArmyStoreMaxCount(ArmyLevel)
    local Level = ArmyLevel or self:GetArmyLevel()
    if Level then
        local StroePermissionData = ArmyMgr:GetArmyPerermissionData(ArmyUpLevelPerermissionType.ArmyStorageLocker, ArmyLevel)
        if StroePermissionData then
            local StroeNum = StroePermissionData.Value[1]
            return StroeNum
        end
    end
    return 0
end

--- 获取部队商店ID
function ArmyMgr:GetArmyShopID(ArmyLevel)
    local Level = ArmyLevel or self:GetArmyLevel()
    if Level then
        local PermissionData = ArmyMgr:GetArmyPerermissionData(ArmyUpLevelPerermissionType.ArmyShopLevel, ArmyLevel)
        if PermissionData then
            local ShopID = PermissionData.Value[1]
            return ShopID
        end
    end
end

--- 获取当前部队权限的数据
function ArmyMgr:GetArmyPerermissionData(UpLevelPermissionType, ArmyLevel)
    local Level = ArmyLevel or self:GetArmyLevel()
    if Level then
        local GroupMemberPermissionCfg = GroupUplevelpermissionCfg:GetPermissionByType(UpLevelPermissionType)
        local PermissionData
        for _, Cfg in ipairs(GroupMemberPermissionCfg) do
            if Cfg.Level <= Level then
                if PermissionData == nil then
                    PermissionData = Cfg
                elseif PermissionData.FuncLevel < Cfg.FuncLevel then
                    PermissionData = Cfg
                end
            end
        end
        return PermissionData
    end
end

function ArmyMgr:DefaultCategoryNameWrite()
    ---处理默认分组名
    if self.SelfArmyInfo and self.SelfArmyInfo.Categories then
        for _, Category in ipairs(self.SelfArmyInfo.Categories) do
            if Category.Name == "" then
                local DefaultCategoryData =  GroupDefaultCategoryCfg:FindCfgByKey(Category.ID)
                if DefaultCategoryData then
                    Category.Name = DefaultCategoryData.Name
                end
            end
        end
    end
end

function ArmyMgr:GetDefaultCategoryName()
    local Cfg = GroupDefaultCategoryCfg:FindAllCfg()
    local Categories = {}
    ---获取默认分组名
    for _, CategoryData in ipairs(Cfg) do
        local Category = {}
        Category.Name =  CategoryData.Name
        Category.ID =  CategoryData.ID
        table.insert(Categories, Category)
    end
    return Categories
end

---获取默认分组数量
function ArmyMgr:GetDefaultCategoryNum()
    local Cfg = GroupDefaultCategoryCfg:FindAllCfg()
    local CategoriesNum = 0
    ---容错处理，等后续见习分组配置删除后可去掉
    for _, CategoryData in ipairs(Cfg) do
        if CategoryData.ID ~= 0 then
            CategoriesNum = CategoriesNum + 1
        end
    end
    return CategoriesNum
end

---获取新人分组
function ArmyMgr:GetNewMemberCategoryID()
    local Categories = self:GetArmyCategories()
    if Categories and #Categories > 0 then
        return Categories[#Categories]
    else
        return ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_MEMBER
    end
end

--- 部队除名
function ArmyMgr:KickMember(RoleID)
    if nil == RoleID then
        return
    end
    if not self:IsInArmy() then
        MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyErrorCode.NoArmyPleaseJoin)
        return
    elseif not self:GetSelfIsHavePermisstion(ProtoRes.GroupPermissionType.GROUP_PERMISSION_TYPE_KickMember) then
        MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyErrorCode.NoPermisstion)
        return
    elseif RoleID == self:GetLeaderRoleID()then
        -- LSTR string:不能除名部队长
        MsgTipsUtil.ShowTips(string.format(LSTR(910030)))
        return
    elseif RoleID == MajorUtil.GetMajorRoleID() then
        -- LSTR string:不能除名自己
        MsgTipsUtil.ShowTips(string.format(LSTR(910029)))
        return
    end
    self:KickMemberMsgBox(RoleID)
end

--- 部队除名弹窗
function ArmyMgr:KickMemberMsgBox(RoleID)
    local RoleVM = RoleInfoMgr:FindRoleVM(RoleID)
    --- 删除成员
    MsgBoxUtil.ShowMsgBoxTwoOp(
    self,
    -- LSTR string:提示
    LSTR(910144),
    -- LSTR string:确认除名部队成员 %s 吗?
    string.format(LSTR(910195), RichTextUtil.GetText(RoleVM.Name,  ArmyTextColor.BlueHex)),
    function()
        ArmyMgr:SendKickMemberMsg(RoleID)
    end
    )
end

--- 取消署名弹窗
function ArmyMgr:ShowSignCancelMsgBox(RoleID)
    local RoleVM = RoleInfoMgr:FindRoleVM(RoleID)
    --- 取消署名
    MsgBoxUtil.ShowMsgBoxTwoOp(
    self,
    -- LSTR string:提示
    LSTR(910144),
    -- LSTR string:确定要取消对%s组建的部队进行署名吗？
    string.format(LSTR(910439), RichTextUtil.GetText(RoleVM.Name,  ArmyTextColor.BlueHex)),
    function()
        ArmyMgr:SendGroupSignCancel(RoleID)
    end
    )
end

--- 部队长转让
function ArmyMgr:ArmyTransferLeader(TargetMemberRoleID)
    if nil == TargetMemberRoleID then
        return
    end
    self:GetMemberDataByRoleID(TargetMemberRoleID, function(MemberQueryData)
        if MemberQueryData then
            self:ArmyTransferLeaderInternal(MemberQueryData.Simple)
        else
            -- LSTR string:对方不是你的部队成员
            MsgTipsUtil.ShowTips(string.format(LSTR(910099)))
        end
    end, nil, true)
end

function ArmyMgr:ArmyTransferLeaderInternal(MemberSimpleData)
    if not self:IsInArmy() then
        MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyErrorCode.NoArmyPleaseJoin)
        return
    elseif not self:IsLeader() then
        -- LSTR string:只有部队长可以转让
        MsgTipsUtil.ShowTips(string.format(LSTR(910086)))
        return
    elseif MemberSimpleData.RoleID == MajorUtil.GetMajorRoleID() then
        -- LSTR string:不能转让给自己
        MsgTipsUtil.ShowTips(string.format(LSTR(910027)))
        return
    end
    self:ArmyTransferLeaderMsgBox(MemberSimpleData)
end

--- 部队长转让弹窗
function ArmyMgr:ArmyTransferLeaderMsgBox(MemberSimpleData)
    local RoleVM = RoleInfoMgr:FindRoleVM(MemberSimpleData.RoleID)
    --- 转让部队长
    local Callback = function()
        local CurrentTime = _G.TimeUtil.GetServerTime()
        local MyArmyInfo = self.SelfArmyInfo
        local TransferSpace = GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.TransferLeaderTimeInterval)
        local PassedTime = CurrentTime - MyArmyInfo.TransferLeaderTime - TransferSpace * ArmyDefine.Day
        local bTransferLeader = PassedTime >= ArmyDefine.Zero
        local Day = math.floor((CurrentTime - MemberSimpleData.JoinTime) / ArmyDefine.Day)
        local JoinTimeSpace = GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.NewLeaderJoinedTimeMinLimit)
        local bMemberJoinTime = Day >= JoinTimeSpace
        if bTransferLeader and bMemberJoinTime then
            ArmyMgr:SendArmyTransferLeaderMsg(MemberSimpleData.RoleID)
        else
            if not bTransferLeader then
                -- LSTR string:%s天仅能进行一次转让单个部队操作
                _G.MsgTipsUtil.ShowTips(string.format(LSTR(910015), TransferSpace))
            elseif not bMemberJoinTime then
                -- LSTR string:必须为加入部队%s天及以上的成员
                _G.MsgTipsUtil.ShowTips(string.format(LSTR(910123), JoinTimeSpace))
            end
        end
    end
    MsgBoxUtil.ShowMsgBoxTwoOp(
        self,
        -- LSTR string:提示
        LSTR(910144),
        -- LSTR string:确认转让部队长权限给 %s 吗？
        string.format(LSTR(910194), RichTextUtil.GetText(RoleVM.Name,  ArmyTextColor.BlueHex)),
        Callback,
        nil,
        -- LSTR string:取消
        LSTR(910083),
        -- LSTR string:转让
        LSTR(910236),
        { RightBtnCD = 10 }
    )
end

---退出副本弹未读弹窗
function ArmyMgr:OnLeavePWorld()
    self:ShowUnReadInviteWindow()
    self:ShowUnReadJoinArmyTips()
end

function ArmyMgr:ShowUnReadJoinArmyTips()
    if not self:IsInArmy() then 
        ---如果出副本退出了部队
        self.IsShowJoinTips = false
        return
    end
    if self.IsShowJoinTips then
        self:ShowJoinArmyTips()
    end
end

function ArmyMgr:ShowUnReadInviteWindow()
    if self:IsInArmy() then 
        return
    end
    local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
    if self.UnReadInviteList and #self.UnReadInviteList > 0 and not IsInDungeon then
        local InviteInfoList =  self.UnReadInviteList
        --self.UnReadInviteList = {}
        local RoleIDs = {}
        local GroupIDs = {}
        local InvalidList = {}
        for _, InviteInfo in ipairs(InviteInfoList) do
            local IsInvalid = false
            local CurTime = TimeUtil.GetServerTime()
            if InviteInfo.Time then
                --- 超过24小时不弹窗/侧边栏表无配置，有配置再读配置，先代码设置
                IsInvalid = CurTime - InviteInfo.Time > 86400
            end
            if InviteInfo.ValidTime then
                --- 超过有效期不显示
                IsInvalid = IsInvalid or CurTime - InviteInfo.ValidTime > 0
            end
            if IsInvalid then
                table.insert(InvalidList, InviteInfo.GroupID)
            elseif InviteInfo.InviterRoleID then
                table.insert(RoleIDs, InviteInfo.InviterRoleID)
                GroupIDs[InviteInfo.InviterRoleID] = {
                    GroupID = InviteInfo.GroupID,
                    ValidTime = InviteInfo.ValidTime
                }
            end
        end
        --- 处理超过24小时的邀请/失效的邀请
        if InvalidList and #InvalidList > 1 then
            self:SendGroupInviteSetRead(InvalidList)
        end
        if RoleIDs and #RoleIDs > 0 then
            RoleInfoMgr:QueryRoleSimples(RoleIDs, function()
                local ReadGroupIDs = {}
                for _, RoleID in ipairs(RoleIDs) do
                    local RoleVM = RoleInfoMgr:FindRoleVM(RoleID, true)
                    if nil == RoleVM then
                        return
                    end
                    local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
                    if IsInDungeon then
                        return
                    end
                    local GroupID
                    local ValidTime
                    if GroupIDs[RoleID] then
                        GroupID = GroupIDs[RoleID].GroupID
                        ValidTime = GroupIDs[RoleID].ValidTime
                    end
                    if GroupID then
                        table.insert(ReadGroupIDs, GroupID)
                    end
                    -- LSTR string:未知
                    local InviterName = RoleVM.Name or LSTR(910162)
                    self:QueryArmySimple(GroupID, function(ArmyVM)
                        if nil == ArmyVM then
                            return
                        end
                        -- LSTR string:未知
                        local ArmyName = ArmyVM.Name or LSTR(910162)
                        if InviterName ~= nil and GroupID ~= nil  then
                            self:ShowInviteWindow(InviterName, ArmyName, GroupID, ValidTime)
                        end
                    end, false)
                end
                self:SendGroupInviteSetRead(ReadGroupIDs)
            end, nil, false)
        end
    end
end

function ArmyMgr:UpdateArmyUnReadInviteListByReadGroupIDs(GroupIDs)
    if GroupIDs then
        local UnReadInviteListTemp = {}
        if self.UnReadInviteList == nil then
            self.UnReadInviteList = {}
            return
        end
        for _, InviteInfo in ipairs(self.UnReadInviteList) do
            if InviteInfo then
                local IsRemoveData = false
                for _, GroupID in ipairs(GroupIDs) do
                    if GroupID == InviteInfo.GroupID then
                        IsRemoveData = true
                        break
                    end
                end
                if not IsRemoveData then
                    table.insert(UnReadInviteListTemp, InviteInfo)
                end
            end
        end
        self.UnReadInviteList = UnReadInviteListTemp
    end
end

function ArmyMgr:UpdateSelfArmyMembers(Members)
    if self.SelfArmyInfo == nil then
        return
    end
    self.SelfArmyInfo.Members = Members
    -- for _, Simple in ipairs(Members) do
    --     local Member = {}
    --     Member.Simple = Simple
    --     table.insert(self.SelfArmyInfo.Members, Member)
    --     if Member.Simple.RoleID == MajorUtil.GetMajorRoleID() then
    --         self.SelfRoleInfo = Simple
    --     end
    -- end
    ArmyMainVM:UpdataMembersByViewSwitch(Members)
end

function ArmyMgr:GetIsRecruitPanelHaveOpened()
   return self.IsRecruitPanelHaveOpened
end

function ArmyMgr:SetIsRecruitPanelHaveOpened(InIsRecruitPanelHaveOpened)
    self.IsRecruitPanelHaveOpened = InIsRecruitPanelHaveOpened
end

function ArmyMgr:SendCancelCreate()
    local RoleID = MajorUtil.GetMajorRoleID()
    self:SendGroupPeitionCancel(RoleID)
 end
 
 function ArmyMgr:UpdataArmyCreatePeitionData(PetitionData)
    self.PetitionData = PetitionData
 end

 function ArmyMgr:UpdataArmyCreatePeitionDataByBase(PetitionDataBase)
    ---base数据无署名人数和时间
    if  self.PetitionData and PetitionDataBase then
        self.PetitionData.GroupPetition = PetitionDataBase.GroupPetition
    end
 end

 function ArmyMgr:GetArmyCreatePeitionData()
    return self.PetitionData
 end

---@param BaseInfo
-- {int32 GroupLevel = 1;
-- int32 GroupExp = 2;
-- GroupLog Log = 3; // 动态日志：最新的一条 已废弃
-- repeated BonusStateUp BonusStateUps = 4;// 生效中的加成状态列表
-- string GroupName = 5; // 部队名称
-- string GroupAlias = 6; // 部队昵称
-- string GroupNotice = 7;// 部队公告
-- int32 MemberCount = 8;// 队员数量
-- GroupEmblem Emblem = 9;// 队徽
-- uint64 LeaderID = 10;// 部队长ID
-- Score Score = 11;// 部队战绩
-- int32 ActivityIcons = 12;//活动偏好icon列表 按位存储
-- int32 ActivityTimeType = 13;//活动时间:1|每日,2|工作日,3|休息日
-- int32 RecruitProfs = 14;//招募的职业 按位存储
-- string RecruitSlogan = 15;// 招募标语
-- repeated  GroupLog Logs = 16; // 动态日志：最新的N条}
 function ArmyMgr:UpdataBaseInfo(BaseInfo)
    self.BaseInfo = BaseInfo
    self.Emblem = BaseInfo.Emblem
    self.Reputation = BaseInfo.Reputation
 end

 function ArmyMgr:GetBaseInfo()
    return self.BaseInfo or {}
 end

 function ArmyMgr:GetProfileInfo()
    local Info
    if self.BaseInfo then
        Info = {
            ActivityIcons = self.BaseInfo.ActivityIcons,
            ActivityTimeType = self.BaseInfo.ActivityTimeType,
            RecruitProfs = self.BaseInfo.RecruitProfs,
            RecruitSlogan = self.BaseInfo.RecruitSlogan,
            --todo 招募状态和国防联军好感度
        }
    end
 end

 ---设置队徽配置
 function ArmyMgr:SetEmblem(Emblem)
    self.Emblem = Emblem
 end

 ---获取队徽配置
 function ArmyMgr:GetEmblem()
    return self.Emblem
 end

 ---设置国防联军变更时间
 function ArmyMgr:SetCompanyChangeTime(CompanyChangeTime)
    self.CompanyChangeTime = CompanyChangeTime
 end

 ---获取国防联军变更时间
 function ArmyMgr:GetCompanyChangeTime()
    return self.CompanyChangeTime
 end
 
---随机队徽配置
function ArmyMgr:BadgeDataRandomly(GrandID)
    if GrandID == nil then
        return
    end
    local RandomBadge = {}
    local Cfg =  GrandCompanyCfg:FindCfgByKey(GrandID)
    local Length = #Cfg.ArmyBadge
    local BadgeIndex = math.random(1, Length)
    RandomBadge.TotemID = Cfg.ArmyBadge[BadgeIndex].IDs.ImpliedID or 0
    RandomBadge.IconID = Cfg.ArmyBadge[BadgeIndex].IDs.ShieldID or 0
    RandomBadge.BackgroundID = Cfg.ArmyBadge[BadgeIndex].IDs.BgID or 0
    return RandomBadge
end

---检查国防联军是否和队徽图标冲突 返回true代表有冲突
function ArmyMgr:BadgeDataErrorCheckByGrandID(GrandID, TotemID)
    local IsNeedReset = true
    local TotemCfg = GroupEmblemTotemCfg:FindCfgByKey(TotemID)
    if TotemCfg and TotemCfg.CompanyIDs then
        for _, CompanyID in ipairs(TotemCfg.CompanyIDs) do
            if GrandID == CompanyID then
                IsNeedReset = false
            end
        end
    end
    return IsNeedReset
end

---获取部队状态 无/领创建书/已署名/已有部队
function ArmyMgr:GetArmyState()
    return self.ArmyState
end

---设置部队状态 无/领创建书/已署名/已有部队
function ArmyMgr:SetArmyState(ArmyState)
    self.ArmyState = ArmyState
end

---货币数字规范
function ArmyMgr:FormatNumber(Number)
    
    local resultNum = Number
    if type(Number) == "number" then
        local inter, point = math.modf(Number)

        local StrNum = tostring(inter)
        local NewStr = ""
        local NumLen = string.len( StrNum )
        local Count = 0
        for i = NumLen, 1, -1 do
            if Count % 3 == 0 and Count ~= 0  then
                NewStr = string.format("%s,%s",string.sub( StrNum,i,i),NewStr) 
            else
                NewStr = string.format("%s%s",string.sub( StrNum,i,i),NewStr) 
            end
            Count = Count + 1
        end

        if point > 0 then
            --@desc 存在小数点，
            local strPoint = string.format( "%.2f", point )
            resultNum = string.format("%s%s",NewStr,string.sub( strPoint,2, string.len( strPoint ))) 
        else
            resultNum = NewStr
        end
    end
    
    return resultNum
end

---获取部队国防联军友好关系
function ArmyMgr:GetReputation()
    return self.Reputation
end

---查询是否是被限制的解锁（未到25级通过邀请解锁的部队）
function ArmyMgr:GetIsRestrictedArmyPanel()
    local IsRestricted = false
    local IsArmyConds = ModuleOpenMgr:CheckArmyConds()
    if self.IsInvitedUnlock and not self:IsInArmy() and not IsArmyConds then
        IsRestricted = true
    end
    return IsRestricted
end


---设置部队解锁
function ArmyMgr:SetArmyModuleOpen()
    if not ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDArmy) then
        ModuleOpenMgr:OnJoinArmy()
    end
end

---获取组建书署名人数是否已满，无组建书会返回false
function ArmyMgr:GetArmySignIsFull()
    if nil == self.PetitionData then
        return false
    end
    local MaxSignNum = self:GetArmySignFullNum()
    local Signs = self.PetitionData.Signs
    if Signs then
        local SignNum = #Signs 
        return SignNum >= MaxSignNum
    else
        return false
    end
end

---获取组建书署名人数最大数量
function ArmyMgr:GetArmySignFullNum()
    return GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.GlobalCfgGroupSignNum) or 0
end

--- 半屏好友署名邀请用，检查并邀请
function ArmyMgr:CheckAndSendGroupSignInvite(RoleID)
    if self.ArmyState ~= ProtoCS.RoleGroupState.RoleGroupStateGainedPetition then
        _G.FLOG_WARNING("[ArmyMgr] CheckAndSendGroupSignInvite ArmyState Isn't RoleGroupStateGainedPetition")
        return
    end
    self:GetArmySimpleDataByRoleIDs({RoleID}, function(GroupSimples) 
        for _, GroupSimple in pairs(GroupSimples) do
            if GroupSimple.RoleID == RoleID then
                local RoleGroupState = GroupSimple.State
                if RoleGroupState == ProtoCS.RoleGroupState.RoleGroupStateInit then
                    ---依赖本地数据拦截 其他邀请失败原因优先显示
                    if self:GetArmySignIsFull() then
                        --- 邀请失败，部队署名人数已满%s人
                        local TextStr = string.format(LSTR(910421), self:GetArmySignFullNum())
                        MsgTipsUtil.ShowTips(TextStr)
                    else
                        ArmyMgr:SendGroupSignInvite(RoleID)
                    end
                elseif RoleGroupState == ProtoCS.RoleGroupState.RoleGroupStateJoinedGroup  then
                    --- 邀请失败，对方已有部队
                    MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InvitedJoinArmy)
                elseif RoleGroupState == ProtoCS.RoleGroupState.RoleGroupStateGainedPetition  then
                    --- 邀请失败，对方领取了部队组建书
                    MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InvitedArmyCreating)
                elseif RoleGroupState == ProtoCS.RoleGroupState.RoleGroupStateSignedOtherPetition  then
                    --- 邀请失败，对方已署名了其他人的部队组建书
                    if self.PetitionData and self.PetitionData.Signs then
                        local IsSignSelf = table.find_by_predicate(self.PetitionData.Signs, function(A)
                            return A == RoleID
                        end)
                        if IsSignSelf then
                            --- 对方已同意你的署名邀请
                            MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InvitedAgreed)
                        else
                            --- 邀请失败，对方已署名了其他人的部队组建书
                            MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InvitedSignOther)
                        end
                    else
                        --- 本地无组建书数据，抛出日志
                        _G.FLOG_WARNING("[ArmyMgr] CheckAndSendGroupSignInvite PetitionData or PetitionData.Signs is nil")
                        --- 邀请失败，对方已署名了其他人的部队组建书
                        MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InvitedSignOther)
                    end
                end
            end
        end
    end)
end


--- 半屏好友部队邀请用，检查并邀请
function ArmyMgr:CheckAndSendGroupInvite(RoleID)
    self:GetArmySimpleDataByRoleIDs({RoleID}, function(GroupSimples) 
        for _, GroupSimple in pairs(GroupSimples) do
            if GroupSimple.RoleID == RoleID then
                local RoleGroupState = GroupSimple.State
                if RoleGroupState == ProtoCS.RoleGroupState.RoleGroupStateInit then
                    ArmyMgr:SendArmyInviteMsg({RoleID})
                elseif RoleGroupState == ProtoCS.RoleGroupState.RoleGroupStateJoinedGroup  then
                    --- 对方已有部队,确认下是否是自己部队
                    local Simple = GroupSimple.Simple
                    local ArmyID
                    if Simple then
                        ArmyID = Simple.ID
                    end
                    if ArmyID == self:GetArmyID() then
                        --- 邀请失败，对方已加入当前部队
                        MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InvitedJoinSelfArmy)
                    else
                        --- 邀请失败，对方已有部队
                        MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InvitedJoinArmy)
                    end
                elseif RoleGroupState == ProtoCS.RoleGroupState.RoleGroupStateGainedPetition  then
                    --- 邀请失败，对方领取了部队组建书
                    MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InvitedArmyCreating)
                elseif RoleGroupState == ProtoCS.RoleGroupState.RoleGroupStateSignedOtherPetition  then
                    --- 邀请失败，对方已署名了其他人的部队组建书
                    MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InvitedSignOther)
                end
            end
        end
    end)
end

function ArmyMgr:CheckIsArmyUnlockLevel()
    local NomalUnlockLevel = GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.GlobalCfgGroupOpenLevel)
    local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
	if RoleDetail == nil then
		FLOG_ERROR('ArmyMgr:CheckIsArmyUnlockLevel GetMajorRoleDetail Error ')
		return false
	end
	if RoleDetail.Prof == nil or RoleDetail.Prof.ProfList == nil then
		FLOG_ERROR('ArmyMgr:CheckIsArmyUnlockLevel RoleDetail.Prof == nil or RoleDetail.Prof.ProfList == nil')
		return false
	end

	local ProfList = RoleDetail.Prof.ProfList
	for _, value in pairs(ProfList) do
		if value.Level >= NomalUnlockLevel then
			return true
		end
	end
end

function ArmyMgr:GetArmyName()
    local ArmyName
    if self.SelfArmyInfo and self.SelfArmyInfo.Simple then
        ArmyName = self.SelfArmyInfo.Simple.Name
    end
    return ArmyName or ""
end

function ArmyMgr:GetArmyQuitCreateCD()
    local CD = GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.CreateArmyAgainTimeInterval) or 0
    CD = CD * ArmyDefine.Hour
    return CD
end

---关闭所有部队界面
function ArmyMgr:HideAllArmyView()
    UIViewMgr:HideView(UIViewID.ArmyPanel)
     ---关闭其他部队界面
     UIViewMgr:HideView(UIViewID.ArmyDepotPanel)
     UIViewMgr:HideView(UIViewID.ArmyDepotRename)
     UIViewMgr:HideView(UIViewID.ArmyDepotMoneyWin)
 
     UIViewMgr:HideView(UIViewID.ArmyCategoryEditPanel)
 
     UIViewMgr:HideView(UIViewID.ArmySEPanel)
     UIViewMgr:HideView(UIViewID.ArmySEBuyWin)
 
     UIViewMgr:HideView(UIViewID.ArmyEditRecruitPanel)
     UIViewMgr:HideView(UIViewID.ArmyEditInfoPanel)
     UIViewMgr:HideView(UIViewID.ArmySelectQuantityWin)
end

---显示部队结成提示，只有创建者和署名者会有，后续加入无
function ArmyMgr:ShowJoinArmyTips()
    --- 大字提示
    local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
    if IsInDungeon then
        self.IsShowJoinTips = true
    else
        -- LSTR string:部队结成
        MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmySignJoinTipsID)
        self.IsShowJoinTips = false
    end
end

-----仓库拦截判断，累计充值不达到30的，不允许开启仓库
function ArmyMgr:GetArmyStoreIsOpen()
    local IsOpen = ConditionMgr:CheckConditionByID(ArmyDefine.ArmyStoreOpenConditionID)
    return IsOpen
end

---仓库存入并检查是否开放
function ArmyMgr:SendGroupStoreDepositItemAndCheck(StoreIndex, GID, Count, ResID)
    ---添加前置判断，如果未购买月卡，且未完成对应任务，不给点开
    if self:GetArmyStoreIsOpen() then
        self:SendGroupStoreDepositItem(StoreIndex, GID, Count, ResID)
    else
        _G.MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.NoOpenArmyStore)
    end
end

---仓库取出并检查是否开放
function ArmyMgr:SendGroupStoreFetChItemAndCheck(StoreIndex, GID, ResID, Num)
    ---添加前置判断，如果未购买月卡，且未完成对应任务，不给点开
    if self:GetArmyStoreIsOpen() then
        self:SendGroupStoreFetChItem(StoreIndex, GID, ResID, Num)
    else
        _G.MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.NoOpenArmyStore)
    end
end

---金币仓库存入并检查是否开放
function ArmyMgr:SendGroupMoneyBagDepositAndCheck(Num, TotalNum)
    ---添加前置判断，如果未购买月卡，且未完成对应任务，不给点开
    if self:GetArmyStoreIsOpen() then
        self:SendGroupMoneyBagDeposit(Num, TotalNum)
    else
        _G.MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.NoOpenArmyStore)
    end
end

---金币仓库取出并检查是否开放
function ArmyMgr:SendGroupMoneyBagWithDrawAndCheck(Num, TotalNum)
    ---添加前置判断，如果未购买月卡，且未完成对应任务，不给点开
    if self:GetArmyStoreIsOpen() then
        self:SendGroupMoneyBagWithDraw(Num, TotalNum)
    else
        _G.MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.NoOpenArmyStore)
    end
end

return ArmyMgr
