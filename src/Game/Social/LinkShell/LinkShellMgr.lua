--
-- Author: wallencai
-- Date : 2022-7-1
-- Description: 用来处理通讯贝与后台的协议
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local MajorUtil = require ("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")
local LinkshellDefineCfg = require("TableCfg/LinkshellDefineCfg")
local PWorldMgr = require("Game/PWorld/PWorldMgr")

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.GroupChat.LinkShells.CS_SUBMSGID_LINKSHELL
local RECRUITING_SET = LinkShellDefine.RECRUITING_SET
local SidebarType = SidebarDefine.SidebarType.LinkShellInvite
local LSTR = _G.LSTR
local GameNetworkMgr

-- @class LinkShellMgr : MgrBase
local LinkShellMgr = LuaClass(MgrBase)

function LinkShellMgr:OnInit()
end

function LinkShellMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
end

function LinkShellMgr:OnEnd()
end

function LinkShellMgr:OnShutDown()
end

function LinkShellMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_GETLIST, self.OnNetMsgLinkShellGetList) --拉取通讯贝列表
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_BE_INVITE_RECORD, self.OnNetMsgInvitedLinkShellList) --查询通讯贝被邀请信息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_GETDETAILS, self.OnNetMsgLinkShellGetDetails) --拉取通讯贝详情
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_CREATE, self.OnNetMsgLinkShellCreate) --创建通讯贝 
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_DESTROY, self.OnNetMsgLinkShellDestroy) --解散通讯贝
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_UPDATEDETAILS, self.OnNetMsgLinkShellUpdateDetails) --修改通讯贝信息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_GETMEMS, self.OnNetMsgLinkShellGetMembers) --拉取通讯贝成员
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_REQJOINLIST, self.OnNetMsgLinkShellReqJoinList) --拉取请求加入列表
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_JOIN, self.OnNetMsgLinkShellJoin) --请求加入通讯贝
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_AUDITJOIN, self.OnNetMsgLinkShellAuditJoin) --审批加入请求
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_INVITEJOIN, self.OnNetMsgLinkShellInviteJoin) --邀请加入通讯贝
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_ANSWERINVITEJOIN, self.OnNetMsgLinkShellAnswerInviteJoin) --回复邀请
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_TRANSFERCREATE, self.OnNetMsgLinkShellTransferCreate)  --修改创建者
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_SETMANAGE, self.OnNetMsgLinkShellSetManage)  --设置管理员
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_LEAVE, self.OnNetMsgLinkShellLeave)  --离开通讯贝
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_KICKOFF, self.OnNetMsgLinkShellKickoff)  --踢出通讯贝
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_EVENTS, self.OnNetMsgLinkShellEvents) --查看通讯贝事件
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_FIND, self.OnNetMsgLinkShellFind) --查找通讯贝
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_STICK, self.OnNetMsgLinkShellStick) --置顶通讯贝

    --- Notify Msg
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_AUDITJOIN_RESULT_NTF, self.OnAuditJoinResultNotify) --通知加入了通讯贝或被拒绝
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_INVITE_JOIN_NTF, self.OnInviteJoinNotify) --邀请加入通讯贝通知
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_JOIN_LINKSHELL, self.OnJoinLinkShellNotify) --新成员加入通讯贝通知
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_DESTROY_NTF, self.OnLinkShellDestroyNotify) --销毁通讯贝通知
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_KICKOFF_NTF, self.OnKickOffNotify) --踢出通讯贝通知
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_TITLE_CHANGE_NTF, self.OnCurPlayerTitleChangeNotify) --身份变化通知
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LINKSHELL, SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_APPLY_JOIN_NTF, self.OnApplyJoinNotify) --通知管理员有人请求加入通讯贝
end

function LinkShellMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes) --角色成功登录
    self:RegisterGameEvent(EventID.SidebarItemTimeOut, self.OnGameEventSidebarItemTimeOut) --侧边栏Item超时
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
end

function LinkShellMgr:OnGameEventLoginRes()
    self:SendMsgGetLinkShellListReq()
end

function LinkShellMgr:OnGameEventSidebarItemTimeOut( Type, TransData )
    if Type ~= SidebarType then 
        return
    end

    local Info = self:GetNewInviteFirstRequest()
    if Info then
        SidebarMgr:RemoveSidebarItem(SidebarType)
        self:TryAddNewItem({ RoleID = Info.RoleID, LinkShellID = Info.LinkShellID })
    end
end

function LinkShellMgr:OnGameEventPWorldMapEnter()
    -- 从副本退出来
	if PWorldMgr:CurrIsFromDungeonExit() then
        LinkShellVM:TryAddSidebarItem()
	end
end

------- Respone Part ----------------------

function LinkShellMgr:OnNetMsgLinkShellGetList(MsgBody)
    local ListRsp = MsgBody.List 
    if nil == ListRsp then
        return
    end

    LinkShellVM:UpdateLinkShellItemList(ListRsp.List or {})
end

function LinkShellMgr:OnNetMsgInvitedLinkShellList(MsgBody)
    local BeInviteRecord = MsgBody.BeInviteRecord 
    if nil == BeInviteRecord then
        return
    end

    LinkShellVM:UpdateLinkShellInvitedItemList(BeInviteRecord.records or {})
end

--- 收到详情更新的消息
---@param MsgBody any
---这个请求的方式是以列表的形式传递的，可以同时请求多个通讯贝详情
function LinkShellMgr:OnNetMsgLinkShellGetDetails(MsgBody)
    local Details = MsgBody.Details.Details;
    for _, Detail in ipairs(Details) do
        LinkShellVM:UpdateLinkShellDetail(Detail)
    end
end

function LinkShellMgr:OnNetMsgLinkShellCreate(MsgBody)
    LinkShellVM:AddLinkShellList(MsgBody.Create)

    EventMgr:SendEvent(EventID.LinkShellCreateSuc)

    MsgTipsUtil.ShowTips(LSTR(40020)) -- "创建通讯贝成功"
end

-- 销毁通讯贝的回调
function LinkShellMgr:OnNetMsgLinkShellDestroy(MsgBody)
    LinkShellVM:DestroyLinkShell(MsgBody.Destroy.ID)
end

-- CS_SUB_CMD_LINKSHELL_UPDATEDETAILS
-- 更新单个通讯贝的某项细节
function LinkShellMgr:OnNetMsgLinkShellUpdateDetails(MsgBody)
    local UpdateDetails = MsgBody.UpdateDetails
    local DetailsList = UpdateDetails.Details
    local LinkShellID = UpdateDetails.ID

    LinkShellVM:UpdateLinkShellModifyInfo(LinkShellID, DetailsList)
    local IsMajor = MajorUtil.IsMajorByRoleID(UpdateDetails.RoleID)

    for _, v in pairs(DetailsList) do
        if not string.isnilorempty(v.Name) then
            EventMgr:SendEvent(EventID.LinkShellRename, LinkShellID)

            if IsMajor then
                MsgTipsUtil.ShowTips(LSTR(40021)) -- "修改通讯贝名成功"
            end
        end

        if IsMajor then
            if v.Manifesto then
                MsgTipsUtil.ShowTips(LSTR(40022)) --"修改招募宣言成功"
            end

            if v.Announcement then
                MsgTipsUtil.ShowTips(LSTR(40023)) --"修改公告成功"
            end

            if v.Recruiting or v.PrivateChatSet then
                MsgTipsUtil.ShowTips(LSTR(40024)) --"修改招募设置成功"
            end

            if v.Events then
                MsgTipsUtil.ShowTips(LSTR(40112)) --"修改主要活动成功"
            end
        end
    end
end

-- 获取成员列表回调
function LinkShellMgr:OnNetMsgLinkShellGetMembers(MsgBody)
    local MemsList = MsgBody.MemsList
    LinkShellVM:UpdateLinkShellMembers(MemsList.ID, MemsList.Mems)
end

function LinkShellMgr:OnNetMsgLinkShellReqJoinList(MsgBody)
    local ReqJoinList = MsgBody.ReqJoinList
    local LinkShellID = ReqJoinList.ID
    local ReqList = ReqJoinList.Reqs

    LinkShellVM:UpdateLinkShellApplyList(LinkShellID, ReqList)
end

--- 加入通讯贝的返回
function LinkShellMgr:OnNetMsgLinkShellJoin(MsgBody)
    local JoinMsg = MsgBody.Join
    if nil == JoinMsg then
        return
    end

    local LinkShellID = JoinMsg.ID
    local IsFull = JoinMsg.IsFull
    LinkShellVM:UpdateLinkShellApplyInfo(LinkShellID, IsFull)

    if IsFull then
        -- "该通讯贝已满员"
        MsgTipsUtil.ShowTips(LSTR(40025))
        return
    end

    if JoinMsg.RecruitingSet == RECRUITING_SET.AUDIT then
        -- "申请发送成功"
        MsgTipsUtil.ShowTips(LSTR(40026))

    elseif JoinMsg.RecruitingSet == RECRUITING_SET.OPEN then
        LinkShellVM:RemoveSearchItemVM(LinkShellID)

        --- "加入成功"
        MsgTipsUtil.ShowTips(LSTR(40027))
    end
end

--- 处理申请结果的返回
---@param MsgBody any
function LinkShellMgr:OnNetMsgLinkShellAuditJoin(MsgBody)
    local Rsp = MsgBody.AuditJoin
    if nil == Rsp then
        return
    end

    local ErrCode = Rsp.ErrCode
    if ErrCode == 144028 then
        --- "该申请已被处理"
        MsgTipsUtil.ShowTips(LSTR(40005))

    else
        RoleInfoMgr:QueryRoleSimple(Rsp.AuditRoleID, function( _, RoleVM )
            if nil == RoleVM or string.isnilorempty(RoleVM.Name) then
                return
            end

            if ErrCode ~= 0 then
                if ErrCode == 144041 then
                    --"%s已经是通讯贝的成员"
                    MsgTipsUtil.ShowTips(string.format(LSTR(40028), RoleVM.Name))
                end

            else
                if Rsp.Result then
                    --"已接受%s的申请"
                    MsgTipsUtil.ShowTips(string.format(LSTR(40029), RoleVM.Name))

                else
                    --"已拒绝%s的申请"
                    MsgTipsUtil.ShowTips(string.format(LSTR(40030), RoleVM.Name))
                end
            end
        end)
    end

    local LinkShellID = Rsp.ID
    LinkShellVM:RemoveRoleFromApplyList(LinkShellID, Rsp.AuditRoleID)

    if ErrCode == 0 and Rsp.Result then
        --拉取最新通讯贝成员列表
        if LinkShellVM.CurLinkShellID == LinkShellID then
            self:SendMsgGetLinkShellMembersReq(LinkShellID)
        end
    end
end

function LinkShellMgr:OnNetMsgLinkShellInviteJoin(MsgBody)
    local InviteJoin = MsgBody.InviteJoin
    if nil == InviteJoin then
        return
    end

    if InviteJoin.IsFull then
        MsgTipsUtil.ShowTips(LSTR(40031)) --"该通讯贝已满员"
    end
end

function LinkShellMgr:OnNetMsgLinkShellAnswerInviteJoin(MsgBody)
    local AnswerInvite = MsgBody.AnswerInvite
    if nil == AnswerInvite or not MajorUtil.IsMajorByRoleID(AnswerInvite.RoleID) then
        return
    end

    LinkShellVM:DestroyInvitedLinkShell(AnswerInvite.ID)

    if AnswerInvite.Result then
        self:SendMsgGetLinkShellListReq()
        MsgTipsUtil.ShowTips(LSTR(40032)) -- "加入通讯贝成功"

    else
        MsgTipsUtil.ShowTips(LSTR(40033)) -- "已拒绝通讯贝邀请"
    end
end

--- 转让创建者身份
---@param MsgBody any
function LinkShellMgr:OnNetMsgLinkShellTransferCreate(MsgBody)
    local TransferCreateRsp = MsgBody.TransferCreate
    if TransferCreateRsp then
        LinkShellVM:ModifyLinkShellCreator(TransferCreateRsp.ID, TransferCreateRsp.TransferRoleID)
    end

    LinkShellVM.IsChangingIdentify = false 
end

--- 提升或者取消某个成员的管理员资格
function LinkShellMgr:OnNetMsgLinkShellSetManage(MsgBody)
    local SetManageRsp = MsgBody.SetManage
    if SetManageRsp then
        LinkShellVM:UpdateManageMemberInfo(SetManageRsp.ID, SetManageRsp.SetRoleID, SetManageRsp.AppointOrRecall)

        -- "任命成功"、"撤销成功"
        local Content = SetManageRsp.AppointOrRecall and LSTR(40034) or LSTR(40035)
        MsgTipsUtil.ShowTips(Content)
    end

    LinkShellVM.IsChangingIdentify = false 
end

--- 退出通讯贝的回调
---@param MsgBody any
function LinkShellMgr:OnNetMsgLinkShellLeave(MsgBody)
    LinkShellVM:DestroyLinkShell(MsgBody.Leave.ID)
end

--- 踢掉玩家的通知
---@param MsgBody any
function LinkShellMgr:OnNetMsgLinkShellKickoff(MsgBody)
    local KickOff = MsgBody.KickOff
    local RoleID = KickOff.KickOffRoleID

    RoleInfoMgr:QueryRoleSimple(RoleID, function( _, RoleVM )
        if nil == RoleVM or string.isnilorempty(RoleVM.Name) then
            return
        end

        --"玩家%s已被移出通讯贝"
        MsgTipsUtil.ShowTips(string.format(LSTR(40036), RoleVM.Name))

    end)  

    LinkShellVM:RemoveMember(KickOff.ID, RoleID)
end

--- 查看通讯贝事件
function LinkShellMgr:OnNetMsgLinkShellEvents(MsgBody)
    local Events = MsgBody.Events
    if Events then
        LinkShellVM:UpdateNewsItemList(Events.LinkShellEvent or {})
    end
end

--- 查询通讯贝的返回
---@param MsgBody any
function LinkShellMgr:OnNetMsgLinkShellFind(MsgBody)
    local Find = MsgBody.Find
    if nil == Find then
        return
    end

    LinkShellVM:UpdateSearchItemList(Find.LinkShells or {})
end

--- 设置通讯贝收藏列表
---@param MsgBody any
function LinkShellMgr:OnNetMsgLinkShellCollect(MsgBody)
    local Collect = MsgBody.Collect
    LinkShellVM:SetLinkShellCollectState(Collect.ID, Collect.Collect)
end

--- 置顶通讯贝
---@param MsgBody any
function LinkShellMgr:OnNetMsgLinkShellStick(MsgBody)
    local Stick = MsgBody.Stick or {}
    LinkShellVM:SetLinkShellStick(Stick.ID)

    MsgTipsUtil.ShowTips(LSTR(40037)) --"通讯贝已置顶"
end

-------- Notify Msg ----------

---  通知加入了通讯贝或被拒绝
---@param MsgBody any
function LinkShellMgr:OnAuditJoinResultNotify(MsgBody)
    local AuditJoinNtf = MsgBody.AuditJoinNtf or {}
    if AuditJoinNtf.Result then
        self:SendMsgGetLinkShellListReq()

        MsgTipsUtil.ShowTips(LSTR(40032)) --"加入通讯贝成功"
    end
end

--- 邀请加入通讯贝通知
---@param MsgBody any
function LinkShellMgr:OnInviteJoinNotify(MsgBody)
    local InviteJoinNtf = MsgBody.InviteJoinNtf
    if nil == InviteJoinNtf then
        return
    end
    
    local Record = InviteJoinNtf.Record
    if Record then
        LinkShellVM:HandleInviteJoin(Record)
    end
end

--- 新成员加入通讯贝
---@param MsgBody any
function LinkShellMgr:OnJoinLinkShellNotify(MsgBody)
end

--- 销毁通讯贝的通知
---@param MsgBody any
function LinkShellMgr:OnLinkShellDestroyNotify(MsgBody)
    local DestroyNtf = MsgBody.DestroyNtf
    if nil == DestroyNtf then
        return
    end
    
    local LinkShellID = DestroyNtf.ID
    local VM = LinkShellVM:QueryLinkShell(LinkShellID)
    if VM then
        --"通讯贝%s已解散"
        local Content = string.format(LSTR(40038), VM.Name or "")
        MsgTipsUtil.ShowTips(Content)

        LinkShellVM:DestroyLinkShell(LinkShellID)
    end
end

--- 被通讯贝踢掉的通知
---@param MsgBody any
function LinkShellMgr:OnKickOffNotify(MsgBody)
    LinkShellVM:DestroyLinkShell(MsgBody.KickOffNtf.ID)

end

--- 当前玩家职位变化通知
---@param MsgBody any
function LinkShellMgr:OnCurPlayerTitleChangeNotify(MsgBody)
    local Ntf = MsgBody.TitleChangeNtf
    if Ntf then
        local LinkShellID = Ntf.ID
        if LinkShellVM:UpdateLocalPlayerIdentify(LinkShellID, Ntf.Identify) then
            self:SendMsgGetLinkShellMembersReq(LinkShellID)
       end
    end
end

--通知管理员有人请求加入通讯贝
function LinkShellMgr:OnApplyJoinNotify(MsgBody)
    local Ntf = MsgBody.ApplyJoinNtf
    if Ntf then
        LinkShellVM:UpdateLinkShellApplyList(Ntf.ID, { Ntf.Req })
        LinkShellVM:UpdateApplyTotalNumAndRedDot()
    end
end

------------ Request -------------------------

--- 拉取通讯贝的列表
function LinkShellMgr:SendMsgGetLinkShellListReq()
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_GETLIST

    local MsgBody = {
        SubCmd = SubMsgID,
        List = { }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 查询被邀请通讯贝
function LinkShellMgr:SendMsgGetInvitedLinkShellListReq()
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_BE_INVITE_RECORD

    local MsgBody = {
        SubCmd = SubMsgID,
        BeInviteRecord = { }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 获取通讯贝的详情
---@param LinkShellID number|table
function LinkShellMgr:SendGetLinkShellDetailReq(LinkShellID)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_GETDETAILS

    local MsgBody = {
        SubCmd = SubMsgID,
        Details = {
            LinkShellIDs = { LinkShellID }
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 请求创建通讯贝
---@param Name string @通讯贝名称
---@param Events table @主要活动
function LinkShellMgr:SendMsgCreateLinkShellReq(Name, Events)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_CREATE

    local MsgBody = {
        SubCmd = SubMsgID,
            Create = {
                Create = {
                    Name = Name,
                    Recruiting = RECRUITING_SET.AUDIT,
                    Events = Events,
                    Manifesto = "",
                    PrivateChatSet = 1 -- @是否允许私聊
                }
            }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 请求离开当前通讯贝
---@param LinkShellID any
function LinkShellMgr:SendMsgLeaveLinkShellReq(LinkShellID)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_LEAVE

    local MsgBody = {
        SubCmd = SubMsgID,
        Leave = {
            ID = LinkShellID,
            RoleID = MajorUtil.GetMajorRoleID()
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 解散通讯贝
---@param LinkShellID any
function LinkShellMgr:SendMsgDestroyLinkShellReq(LinkShellID)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_DESTROY

    local MsgBody = {
        SubCmd = SubMsgID,
        Destroy = {
            ID = LinkShellID,
            RoleID = MajorUtil.GetMajorRoleID()
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 请求通讯贝成员列表
---@param ID integer @通讯贝ID
function LinkShellMgr:SendMsgGetLinkShellMembersReq(ID)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_GETMEMS

    local MsgBody = {
        SubCmd = SubMsgID,
        MemsList = {
            ID = ID
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 拉取通讯贝请求加入列表
---@param ID integer @通讯贝ID
function LinkShellMgr:SendMsgGetReqJoinListReq(ID)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_REQJOINLIST

    local MsgBody = {
        SubCmd = SubMsgID,
        ReqJoinList = {
            ID = ID,
            RoleID = MajorUtil.GetMajorRoleID()
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 请求加入通讯贝的请求
---@param ID any
---@param Remark any
function LinkShellMgr:SendMsgJoinLinkShellReq(ID, Remark)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_JOIN

    local MsgBody = {
        SubCmd = SubMsgID,
        Join = {
            ID = ID,
            RoleID = MajorUtil.GetMajorRoleID(),
            Remark = Remark
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 审批加入请求
---@param ID number
---@param AuditRoleID number
---@param Result boolean
function LinkShellMgr:SendMsgAuditJoinLinkShellReq(ID, AuditRoleID, Result)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_AUDITJOIN

    local MsgBody = {
        SubCmd = SubMsgID,
        AuditJoin = {
            ID = ID,
            RoleID = MajorUtil.GetMajorRoleID(),
            AuditRoleID = AuditRoleID,
            Result = Result
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- func desc
---@param ID any
---@param RoleID any
---@param InviteRoleID any
function LinkShellMgr:SendMsgLSInviteJoinReq(ID, RoleID, InviteRoleID)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_INVITEJOIN

    local MsgBody = {
        SubCmd = SubMsgID,
        InviteJoin = {
            ID = ID,
            RoleID = RoleID,
            InviteRoleID = InviteRoleID,
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---回复通讯贝邀请
---@param LinkShellID number @通讯贝ID 
---@param InviterRoleID integer @邀请人角色ID
---@param IsArgee boolean @是否同意 
function LinkShellMgr:SendMsgLSAnswerInviteJoinReq(LinkShellID, InviterRoleID, IsArgee)
    if nil == LinkShellID then
        return
    end

    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_ANSWERINVITEJOIN

    local MsgBody = {
        SubCmd = SubMsgID,
        AnswerInvite = {
            ID = LinkShellID,
            RoleID = MajorUtil.GetMajorRoleID(),
            Result = IsArgee,
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

    self:TryAddNewItem({ RoleID = InviterRoleID, LinkShellID = LinkShellID })
end

--- 搜索推荐通讯贝
function LinkShellMgr:SendSearchRecommendLinkShell( )
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_FIND

    local MsgBody = {
        SubCmd = SubMsgID,
        Find = { Filter = {{ Weight = true }}, Count = 20 }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 根据名称搜索通讯贝
---@param Name string @模糊查找
function LinkShellMgr:SendSearchLinkShellByName(Name)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_FIND

    local MsgBody = {
        SubCmd = SubMsgID,
        Find = { 
            Filter = {{Name = Name}}, 
            Count = 30 
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 根据通讯贝ID搜寻通讯贝
---@param LinkShellID any
function LinkShellMgr:SendSearchLinkShellByID(LinkShellID)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_FIND

    local MsgBody = {
        SubCmd = SubMsgID,
        Find = {
            Filter = {{ ID = LinkShellID }},
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 根据通讯贝活动搜寻通讯贝
---@param Events table @活动
function LinkShellMgr:SendSearchLinkShellByAct(Events)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_FIND

    local MsgBody = {
        SubCmd = SubMsgID,
        Find = {
            Filter = {
                {Events = {Events = Events}
            }},
            Count = 30 
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---修改通讯贝信息
---@param LinkShellID number @通讯贝ID
---@param Name string @通讯贝名称
---@param RecruitSet number @通讯贝的招募模式
---@param ActIDs table @通讯贝活动
---@param Manifesto string @招募宣言
---@param Notice string @公告
---@param IsAllowPrivateChat boolean @是否允许私聊
function LinkShellMgr:SetModifyLinkShellInfo(LinkShellID, Name, RecruitSet, ActIDs, Manifesto, Notice, IsAllowPrivateChat)
    local Details = {}

    -- 名称
    if nil ~= Name then
        table.insert(Details, {Name = Name})
    end

    -- 招募模式 
    if nil ~= RecruitSet then
        table.insert(Details, {Recruiting = RecruitSet})

        if RecruitSet ~= RECRUITING_SET.AUDIT then
            IsAllowPrivateChat = false
        end
    end

    -- 主要活动
    if nil ~= ActIDs then
        table.insert(Details, {Events = {Events = ActIDs}})
    end

    -- 招募宣言
    if nil ~= Manifesto then
        table.insert(Details, {Manifesto = Manifesto})
    end

    -- 公告
    if nil ~= Notice then
        table.insert(Details, {Announcement = Notice})
    end

    -- 私聊 
    if nil ~= IsAllowPrivateChat then
        table.insert(Details, {PrivateChatSet = IsAllowPrivateChat and 1 or 0})
    end

    if #Details > 0 then
        local MsgID = CS_CMD.CS_CMD_LINKSHELL
        local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_UPDATEDETAILS
        local MsgBody = {
            SubCmd = SubMsgID,
            UpdateDetails = {ID = LinkShellID, Details = Details}
        }

        GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    end
end

--- 置顶通讯贝
---@param LinkShellID integer @通讯贝ID
function LinkShellMgr:SendStickLinkShell(LinkShellID)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_STICK

    local MsgBody = {
        SubCmd = SubMsgID,
        Stick = {
            ID = LinkShellID
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 将指定玩家踢出通讯贝
---@param LinkShellID integer @通讯贝ID
---@param RoleID integer @角色ID
---@param KickOffRoleID integer @被踢出的玩家ID
function LinkShellMgr:SendKickOff(LinkShellID, KickOffRoleID)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_KICKOFF

    local MsgBody = {
        SubCmd = SubMsgID,
        KickOff = {
            ID = LinkShellID,
            KickOffRoleID = KickOffRoleID
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 设置or罢免管理员
---@param LinkShellID integer @通讯贝ID
---@param RoleID integer @操作角色ID
---@param SetRoleID integer @设置的用户ID
---@param IsAppoint boolean @true:设为管理员 false:罢免管理员
function LinkShellMgr:SendSetManager(LinkShellID, SetRoleID, IsAppoint)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_SETMANAGE

    local MsgBody = {
        SubCmd = SubMsgID,
        SetManage = {
            ID = LinkShellID,
            SetRoleID = SetRoleID,
            AppointOrRecall = IsAppoint
        }
    }

    LinkShellVM.IsChangingIdentify = true 
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 移交管理员
---@param LinkShellID integer @通讯贝ID
---@param RoleID integer @角色ID
---@param TransferRoleID integer @移交的角色ID
function LinkShellMgr:SendTransferCreator(LinkShellID, TransferRoleID)
    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_TRANSFERCREATE

    local MsgBody = {
        SubCmd = SubMsgID,
        TransferCreate = {
            ID = LinkShellID,
            TransferRoleID = TransferRoleID
        }
    }

    LinkShellVM.IsChangingIdentify = true 
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 查询通讯贝动态事件
---@param LinkShellID number @通讯贝ID
---@param Num number @数量
function LinkShellMgr:QueryNews(LinkShellID, Num)
    if nil == LinkShellID then
        return
    end

    local MsgID = CS_CMD.CS_CMD_LINKSHELL
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_LINKSHELL_EVENTS

    local MsgBody = {
        SubCmd = SubMsgID,
        Events = {
            ID = LinkShellID,
            RoleID = MajorUtil.GetMajorRoleID(),
            Index = 0, --从倒数x条开始索引 
            Nums = Num or 100,
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---邀请加入通讯贝
---@param InviteRoleID 被邀请人角色ID 
function LinkShellMgr:InviteJoin( InviteRoleID )
    if nil == InviteRoleID then
        return
    end

    local LinkShellList = LinkShellVM:GetInvitableLinkShellList() or {}
    if #LinkShellList <= 0 then
        --"您当前没有可以进行邀请的通讯贝"
        MsgTipsUtil.ShowTips(LSTR(40039))
        return
    end

    _G.UIViewMgr:ShowView(_G.UIViewID.LinkShellInviteWin, { LinkShellList = LinkShellList, InviteRoleID = InviteRoleID })
end

function LinkShellMgr:GetNewInviteFirstRequest()
    return (LinkShellVM.NewInviteList or {})[1]
end

function LinkShellMgr:CheckLinkshellNumLimit(TipsKey)
    local MaxNum = LinkshellDefineCfg:GetLinkShellMaxNum()
	local IDList = self:GetLinkShellIDs()
    if #IDList < MaxNum then
        return true 
    end

    if TipsKey then
        MsgTipsUtil.ShowTips(LSTR(TipsKey))
    end

    return false 
end

function LinkShellMgr:GetLinkShellIDs()
	return LinkShellVM:GetLinkShellIDList()
end

-------------------------------------------------------------------------------------------------------
---主界面侧标拦（通讯贝邀请）

function LinkShellMgr:TryAddNewItem( Params )
    --删除模块VM数据
    LinkShellVM:RemoveInviteItem(Params.LinkShellID, Params.RoleID)

    if not LinkShellVM:IsHaveNewInvite() then
        --删除侧边栏VM数据
        SidebarMgr:RemoveSidebarItem(SidebarType)

    else
        LinkShellVM:TryAddSidebarItem()
    end
end

function LinkShellMgr:OpenLinkShellInviteSidebar(StartTime, CountDown, Type)
    local Info = self:GetNewInviteFirstRequest()
    if nil == Info then
        return
    end

    local AcceptCallBack = function(_, Data)
		self:SendMsgLSAnswerInviteJoinReq(Data.LinkShellID, Data.RoleID, true)
        self:TryAddNewItem(Data)
    end

    local RefuseCallBack = function(_, Data)
		self:SendMsgLSAnswerInviteJoinReq(Data.LinkShellID, Data.RoleID, false)
        self:TryAddNewItem(Data)
    end

    local Params = {
        Title       = LSTR(40041), --"通讯贝邀请"
        Desc1       = string.format('%s<span color="#8FBDD5FF">%s</>', LSTR(10005), Info.Name or ""), --"玩家"
        Desc2       = string.format('%s[%s]', LSTR(40042), Info.LinkShellName or ""), --"邀请你加入通讯贝"
        StartTime   = StartTime,
        CountDown   = CountDown,
        CBFuncRight = AcceptCallBack,
        CBFuncLeft  = RefuseCallBack,
        Type        = Type, 

        --透传数据
        TransData = { RoleID = Info.RoleID, LinkShellID = Info.LinkShellID },
    }

    _G.UIViewMgr:ShowView(_G.UIViewID.SidebarCommon, Params)
end

return LinkShellMgr