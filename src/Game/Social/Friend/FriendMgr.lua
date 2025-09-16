--
-- Author: wallencai
-- Date : 2022-6-30
-- Description : 好友系统的协议处理
--
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local FriendVM = require("Game/Social/Friend/FriendVM")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local EventID = require("Define/EventID")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local Json = require("Core/Json")
local FriendsDefineCfg = require("TableCfg/FriendsDefineCfg")
local SocialSettings = require("Game/Social/SocialSettings")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local PWorldMgr = require("Game/PWorld/PWorldMgr")

local LSTR = _G.LSTR

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Friend.Friends.CS_SUBMSGID_FRIENDS
local SidebarType = SidebarDefine.SidebarType.FriendInvite
local ClientSetupKey = ProtoCS.ClientSetupKey
local FriendSettingType = ProtoCS.Friend.Friends.FriendSettingType 

local SUB_MSG_ID_SEARCH = ProtoCS.Role.Search.CsSubMsgIDSearch
local SearchFriendType = ProtoCS.Role.Search.SearchFriendType

-- @class FriendMgr : MgrBase
local FriendMgr = LuaClass(MgrBase)

function FriendMgr:OnInit()
    self.IsQueryRecentInfo = true 
    SocialSettings.InitSettings()
end

function FriendMgr:OnBegin()
end

function FriendMgr:OnEnd()
end

function FriendMgr:OnShutDown()
end

function FriendMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_CONSORT, self.OnNetMsgFriendConsort)               --添加好友
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_INBLACKLIST, self.OnNetMsgFriendsInBlacklist)      --加入黑名单
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_OUTBLACKLIST, self.OnNetMsgFriendsOutBlacklist)    --移出黑名单
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_REMOVE, self.OnNetMsgFriendsRemove)                --删除好友
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_GET_LIST, self.OnNetMsgFriendsGetList)             --拉取好友列表
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_MOVEGROUP, self.OnNetMsgFriendsMoveGroup)          --移动好友分组
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_REMOVEGROUP, self.OnNetMsgFriendsRemoveGroup)      --删除分组
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_NEWGROUP, self.OnNetMsgFriendsNewGroup)            --新建分组
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_EDITGROUP, self.OnNetMsgFriendsEditGroup)          --编辑分组
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_CONSORTLIST, self.OnNetMsgFriendsApplyList)        --获取好友申请列表
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_CONFIRMADD, self.OnNetMsgFriendsConfirmAdd)        --同意/拒绝好友申请
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_FRIENDSETREMARD, self.OnNetMsgSetRemark)           --设置好友备注
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_SAVE_SETTING, self.OnNetMsgSaveSetting)            --拉取好友设置
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_PULL_SETTING, self.OnNetMsgPullSetting)            --拉取好友设置

    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_CONSORT_NTF, self.OnConsortNotify)       --收到好友申请的推送
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FRIENDS, SUB_MSG_ID.CS_SUB_CMD_FRIENDS_CONFIRMADD_NTF, self.OnConfirmAddNotify) --确认好友结果通知

    self:RegisterGameNetMsg(CS_CMD.CS_CMD_SEARCH, SUB_MSG_ID_SEARCH.CsSubMsgIDSearchFriend, self.OnNetMsgFriendsFind) --好友搜索
end

function FriendMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes) --角色成功登录
    self:RegisterGameEvent(EventID.SidebarItemTimeOut, self.OnGameEventSidebarItemTimeOut) --侧边栏Item超时
	self:RegisterGameEvent(EventID.ClientSetupPost, self.OnEventClientSetupPost)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
end

function FriendMgr:OnGameEventLoginRes()
    self:SendGetFriendListMsg()
    self:SendFriendsApplyListMsg()
	self:SendGetSettings()

    --- 更新平台好友数据
    FriendVM:UpdatePlatformFriendItemVMList()
end

function FriendMgr:OnGameEventSidebarItemTimeOut( Type, TransData )
    if Type ~= SidebarType then 
        return
    end

    local Info = self:GetNewFriendFirstRequest()
    if Info then
        SidebarMgr:RemoveSidebarItem(SidebarType)
        self:TryAddNewItem(Info.RoleID)
    end
end

function FriendMgr:OnEventClientSetupPost( EventParams )
	if nil == EventParams then
		return
	end

	local IsSetRsp = EventParams.BoolParam1
    if IsSetRsp then
        return
    end

    local RoleIDs = nil
    local SetupKey = EventParams.IntParam1
    if SetupKey == ClientSetupID.FriendRecentTeam  -- 最近组队
        or SetupKey == ClientSetupID.FriendRecentChat then -- 最近聊天

        local Value = EventParams.StringParam1 or ""
        if not string.isnilorempty(Value) then
            RoleIDs = Json.decode(Value) or {}
        end
    end

    if RoleIDs then
        FriendVM:UpdateRecentInfo(SetupKey, RoleIDs)
    end
end

function FriendMgr:OnGameEventPWorldMapEnter()
    -- 从副本退出来
	if PWorldMgr:CurrIsFromDungeonExit() then
        FriendVM:TryAddSidebarItem()
	end
end

--- 好友申请的回包,服务器默认回空包
---@param MsgBody any
function FriendMgr:OnNetMsgFriendConsort(MsgBody)
    MsgTipsUtil.ShowTips(LSTR(30009)) -- "发送申请成功"

    --fixed 非双方互删好友再次添加对方好友时，后台不会发送CS_SUB_CMD_FRIENDS_CONFIRMADD_NTF等其他可以获取最新好友列表的回包，导致好友列表数据有误的问题
    self:SendGetFriendListMsg()
end

--- 加入黑名单返回
---@param MsgBody any
function FriendMgr:OnNetMsgFriendsInBlacklist(MsgBody)
    MsgTipsUtil.ShowTips(LSTR(30010)) --"加入黑名单成功"

    local Rsp = MsgBody.MoveInBlackList 
    if Rsp then
        FriendVM:AddBlackListInfo(Rsp.MvRoleID)
    end
end

--- 移出黑名单返回
---@param MsgBody any
function FriendMgr:OnNetMsgFriendsOutBlacklist(MsgBody)
    MsgTipsUtil.ShowTips(LSTR(30011)) --"成功将玩家移出黑名单"

    local Rsp = MsgBody.MoveOutBlackList
    if Rsp then
        FriendVM:RemoveBlackList(Rsp.MvRoleID)
    end

    -- 非双方互删好友再次添加对方好友时，后台会把玩家加回至好友列表
    self:SendGetFriendListMsg()
end

--- 删除好友的返回
---@param MsgBody any
function FriendMgr:OnNetMsgFriendsRemove(MsgBody)
    local RoleID = MsgBody.RemoveFriends.RmRoleID
    if nil == RoleID then
        return
    end

    FriendVM:RemoveFriend(RoleID)

    -- 检查最近信息（排除好友、黑名单）
    FriendVM:CheckRecentInfo()

    MsgTipsUtil.ShowTips(LSTR(30012)) --"删除成功"
end

function FriendMgr:OnNetMsgFriendsGetList(MsgBody)
    local Rsp = MsgBody.FriendsList
    if nil == Rsp then
        return
    end
    
    FriendVM:UpdateGroupList(Rsp.Groups, Rsp.BlackList)

    if self.IsQueryRecentInfo and UIViewMgr:IsViewVisible(UIViewID.SocialMainPanel) then
        _G.ClientSetupMgr:SendQueryReq({ClientSetupID.FriendRecentTeam, ClientSetupID.FriendRecentChat})
        self.IsQueryRecentInfo = false 
    end
end

function FriendMgr:OnNetMsgFriendsMoveGroup(MsgBody)
    local MoveFriendGroup = MsgBody.MoveFriendGroup
    if MoveFriendGroup then
        FriendVM:TransformFriendsGroup(MoveFriendGroup.Groups)
    end
end

--- 删除好友分组的返回
---@param MsgBody any
function FriendMgr:OnNetMsgFriendsRemoveGroup(MsgBody)
    local ErrorCode = MsgBody.ErrorCode
    if ErrorCode and ErrorCode > 0 then
        FriendVM.IsDeleteGrouping = false 
        return
    end

    MsgTipsUtil.ShowTips(LSTR(30012)) --"删除成功"
    FriendVM:RemoveFriendGroup(MsgBody.RemoveFriendGroup.ID)
    FriendVM.IsDeleteGrouping = false 
end

function FriendMgr:OnNetMsgFriendsNewGroup(MsgBody)
    local ErrorCode = MsgBody.ErrorCode
    if ErrorCode and ErrorCode > 0 then
        FriendVM.IsCreateGrouping = false 
        return
    end

    local NewGroup = MsgBody.NewGroup
    if nil == NewGroup then
        FriendVM.IsCreateGrouping = false 
        return
    end

    MsgTipsUtil.ShowTips(LSTR(30013)) --"新增分组成功"
    FriendVM:AddFriendGroup(NewGroup)
    FriendVM.IsCreateGrouping = false 
end

function FriendMgr:OnNetMsgFriendsEditGroup(MsgBody)
    MsgTipsUtil.ShowTips(LSTR(30014)) --"修改成功"

    local EditGroup = MsgBody.EditGroup
    FriendVM:UpdateFriendGroupName(EditGroup.ID, EditGroup.NewName)
end

function FriendMgr:OnNetMsgFriendsApplyList(MsgBody)
    local ConsortList = MsgBody.ConsortList.ConsortList
    FriendVM:UpdateApplyList(ConsortList)
end

--- 同意 & 拒绝好友申请
---@param MsgBody any
function FriendMgr:OnNetMsgFriendsConfirmAdd(MsgBody)
    local ConfirmConsort = MsgBody.ConfirmConsort
    if ConfirmConsort.IsAdd then
        MsgTipsUtil.ShowTips(LSTR(30015)) --"添加好友成功"

        self:SendGetFriendListMsg()
    else
        MsgTipsUtil.ShowTips(LSTR(30016)) --"已拒绝申请"
    end

    FriendVM:RemoveFromApplyList(MsgBody.ConfirmConsort.ToRoleID)
end

--- 好友搜索结果返回
---@param MsgBody any
function FriendMgr:OnNetMsgFriendsFind(MsgBody)
    FriendVM:UpdateFindFriendList((MsgBody.Find or {}).RoleIDs or {})
end

--- 设置玩家属性的返回
---@param MsgBody any
function FriendMgr:OnNetMsgSetRemark(MsgBody)
    local RemarkRsp = MsgBody.SetFriendRemark
    FriendVM:UpdateFriendRemark(RemarkRsp.Friend, RemarkRsp.NewRemark)
end

--- 玩家保存设置
function FriendMgr:OnNetMsgSaveSetting(MsgBody)
    if nil == MsgBody then
        return
    end

    local Rsp = MsgBody.SaveSetting
    if nil == Rsp or nil == Rsp.settings then
        return
    end

    for _, v in pairs(Rsp.settings) do
        local Type = v.Typ
        if Type == FriendSettingType.FriendSettingType_BlockStranger then -- 拒绝好友申请
            FriendVM:SetRejectFriendRequest(v.Value ~= 0)
        end
    end
end

--- 玩家设置信息
function FriendMgr:OnNetMsgPullSetting(MsgBody)
    if nil == MsgBody then
        return
    end

    local Rsp = MsgBody.PullSetting
    if nil == Rsp or nil == Rsp.settings then
        return
    end

    for _, v in pairs(Rsp.settings) do
        local Type = v.Typ
        if Type == FriendSettingType.FriendSettingType_BlockStranger then -- 拒绝好友申请
            FriendVM:SetRejectFriendRequest(v.Value ~= 0)
        end
    end
end

--- 收到好友请求的推送
function FriendMgr:OnConsortNotify(MsgBody)
    local ConsortNtf = MsgBody.ConsortNtf
    if nil == ConsortNtf then
        return
    end

    local RoleID = ConsortNtf.RoleID
    if nil == RoleID then
        return
    end

    RoleInfoMgr:QueryRoleSimple(RoleID, function()
        FriendVM:AddNewConsortApply(ConsortNtf)
    end, nil, false)
end

function FriendMgr:OnConfirmAddNotify(MsgBody)
    local Ntf = MsgBody.ConfirmFriendsNtf
    if Ntf.IsAgree then
        local RoleID = Ntf.RoleID
        FriendVM:RemoveFromApplyList(RoleID)
        self:TryAddNewItem(RoleID)

        self:SendGetFriendListMsg()

        RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
            if RoleVM then
                -- "已和%s成为好友"
                local Content = string.format(LSTR(30017), RoleVM.Name or "")
                MsgTipsUtil.ShowTips(Content)
            end
        end, nil, false)
    end
end

-------------- Request Part ---------------------------

--- 主动添加好友
---@param ToRoleID integer @添加好友的RoleID
---@param Remark string @备注信息
---@param Source number @好友添加来源
function FriendMgr:SendFriendsConsortMsg(ToRoleID, Remark, Source)
    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_CONSORT

    local MsgBody = {
        SubCmd = SubMsgID,
        Consort = {
            ToRoleID = ToRoleID,
            Remark = Remark,
            AddFrom = Source
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 请求将好友加入到黑名单
---@param MvRoleID integer @加入黑名单的玩家ID
---@param Unfriend boolean @是否解除好友关系
---@param DelEachOther boolean @是否双向删除
---@param Remark string @备注
function FriendMgr:SendMoveToBlacklistMsg(MvRoleID, Unfriend, DelEachOther, Remark)
    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_INBLACKLIST

    local MsgBody = {
        SubCmd = SubMsgID,
        MoveInBlackList = {
            MvRoleID = MvRoleID,
            Unfriend = Unfriend,
            DelEachOther = DelEachOther,
            Remark = Remark
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 移出黑名单
---@param MvRoleID any
function FriendMgr:SendMoveOutBlacklistMsg(MvRoleID)
    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_OUTBLACKLIST

    local MsgBody = {
        SubCmd = SubMsgID,
        MoveOutBlackList = {
            MvRoleID = MvRoleID
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 删除好友
---@param RmRoleID integer @被删除好友的RoleID
---@param DelEachOther boolean @是否互相删除
function FriendMgr:SendRemoveFriendMsg( RmRoleID, DelEachOther)
    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_REMOVE

    local MsgBody = {
        SubCmd = SubMsgID,
        RemoveFriends = {
            RmRoleID = RmRoleID,
            DelEachOther = DelEachOther
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---获取好友列表
function FriendMgr:SendGetFriendListMsg( )
    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_GET_LIST

    local MsgBody = {
        SubCmd = SubMsgID,
        FriendsList = {
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 移动玩家分组
---@param RoleIDs integer @移动的玩家ID列表
---@param GroupID integer @新的分组ID
function FriendMgr:SendFriendsMoveGroupMsg(RoleIDs, GroupID)
    if nil == RoleIDs or #RoleIDs <= 0 or nil == GroupID then
        return
    end

    local Groups = {}

    for _, v in ipairs(RoleIDs) do
        table.insert(Groups, {RoleID = v, ID = GroupID})
    end

    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_MOVEGROUP

    local MsgBody = {
        SubCmd = SubMsgID,
        MoveFriendGroup = { Groups = Groups }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---请求：移除好友分组
---@param ID integer @好友分组的ID
function FriendMgr:SendFriendsRemoveGroupMsg(ID)
    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_REMOVEGROUP

    local MsgBody = {
        SubCmd = SubMsgID,
        RemoveFriendGroup = {
            ID = ID
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function FriendMgr:SendFriendsCreateGroupMsg(Name)
    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_NEWGROUP

    local MsgBody = {
        SubCmd = SubMsgID,
        NewGroup = {
            Name = Name,
            Stick = 0
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 请求修改好友分组信息
---@param FriendGroupID integer @好友分组ID
---@param NewName string @好友分组的新名称
function FriendMgr:SendFriendsEditGroupMsg(FriendGroupID, NewName)
    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_EDITGROUP

    local MsgBody = {
        SubCmd = SubMsgID,
        EditGroup = {
            ID = FriendGroupID,
            NewName = NewName,
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- func desc
---@param RoleID number 玩家自身的RoleID
---@param FriendIDs table 请求的其他玩家的列表
function FriendMgr:SendFriendsDetailsMsg(FriendIDs)
    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_DETAILS

    local MsgBody = {
        SubCmd = SubMsgID,
        Details = {
            FriendID = FriendIDs
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function FriendMgr:SendFriendsApplyListMsg( )
    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_CONSORTLIST

    local MsgBody = {
        SubCmd = SubMsgID,
        ConsortList = {
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 同意或者拒绝好友申请
---@param ToRoleID integer @申请人的角色ID
---@param IsAdd boolean @是否同意
function FriendMgr:SendFriendsConfirmAddMsg(ToRoleID,  IsAdd)
    if nil == ToRoleID then
        return
    end

    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_CONFIRMADD

    local MsgBody = {
        SubCmd = SubMsgID,
        ConfirmConsort = {
            ToRoleID = ToRoleID,
            RoleID = MajorUtil.GetMajorRoleID(),
            IsAdd = IsAdd
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

    self:TryAddNewItem(ToRoleID)
end

--- 查找好友（全部推荐）
function FriendMgr:SendFindFriends_AllRecommond()
	local RoleVM = MajorUtil.GetMajorRoleVM()
    if nil == RoleVM then
        return
    end

    -- 1）优先按主角游戏风格进行查找
    local PlayStyleIDs = nil 
    local PersonSetInfos = RoleVM.PersonSetInfos
    if PersonSetInfos then
        local StrSet = PersonSetInfos[ClientSetupKey.Playstyle]
        if not string.isnilorempty(StrSet) then
            PlayStyleIDs = Json.decode(StrSet)
            if PlayStyleIDs and #PlayStyleIDs > 0 then
                self:SendFindFriends_Dim(nil, PlayStyleIDs)
                return
            end
        end
    end

    -- 2) 按照主角当前职业进行查找
	local ProfID = RoleVM.Prof
    if ProfID then
        self:SendFindFriends_Dim({ProfID})
    end
end

--- 查找好友（模糊搜索，即职业和游戏风格）
---@param ProfIDs table @职业ID列表
---@param StyleIDs table @游戏风格ID列表
function FriendMgr:SendFindFriends_Dim(ProfIDs, StyleIDs)
    local MsgID = CS_CMD.CS_CMD_SEARCH
    local SubMsgID = SUB_MSG_ID_SEARCH.CsSubMsgIDSearchFriend

    local MsgBody = {
        SubCmd = SubMsgID,
        Find = {
            FindType = SearchFriendType.SearchFriendDim,
            Dim = { Profs = ProfIDs, StyleIDs = StyleIDs }
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 查找好友（角色ID）
---@param RoleID number @角色ID
function FriendMgr:SendFindFriends_RoleID(RoleID)
    local MsgID = CS_CMD.CS_CMD_SEARCH
    local SubMsgID = SUB_MSG_ID_SEARCH.CsSubMsgIDSearchFriend

    local MsgBody = {
        SubCmd = SubMsgID,
        Find = {
            FindType = SearchFriendType.SearchFriendRoleID,
            FindRoleID = RoleID
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 查找好友（角色名）
---@param RoleName string @角色名
function FriendMgr:SendFindFirnds_RoleName(RoleName)
    local MsgID = CS_CMD.CS_CMD_SEARCH
    local SubMsgID = SUB_MSG_ID_SEARCH.CsSubMsgIDSearchFriend

    local MsgBody = {
        SubCmd = SubMsgID,
        Find = {
            FindType = SearchFriendType.SearchFriendName,
            Name = RoleName
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 请求修改好友备注
---@param FriendRoleID any
---@param NewRemark any
function FriendMgr:SendSetFriendRemark(FriendRoleID, NewRemark)
    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_FRIENDSETREMARD

    local MsgBody = {
        SubCmd = SubMsgID,
        SetFriendRemark = {
            Friend = FriendRoleID,
            NewRemark = NewRemark
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 获取玩家设置(好友)
function FriendMgr:SendGetSettings()
    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_PULL_SETTING

    local MsgBody = {
        SubCmd = SubMsgID,
        PullSetting = {}
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 设置是否拒绝好友申请 
function FriendMgr:SendSetRejectFriendRequest(IsReject)
    local MsgID = CS_CMD.CS_CMD_FRIENDS
    local SubMsgID = SUB_MSG_ID.CS_SUB_CMD_FRIENDS_SAVE_SETTING

    local MsgBody = {
        SubCmd = SubMsgID,
        SaveSetting = {settings = { {Typ = FriendSettingType.FriendSettingType_BlockStranger, Value = IsReject and 1 or 0} }}
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function FriendMgr:GetNewFriendFirstRequest()
    return (FriendVM.NewFriendRequestList or {})[1]
end

-------------------------------------------------------------------------------------------------
--- 对外接口

---获取所有好友
---@return table<FriendEntryVM>
function FriendMgr:GetAllFriends()
    return FriendVM.AllFriends or {}
end

---指定玩家是否是好友
---@param RoleID number @角色ID 
---@return boolean
function FriendMgr:IsFriend( RoleID )
    return nil ~= RoleID and FriendVM:IsAreadyFriend(RoleID) or false
end

---指定玩家是否处于黑名单
---@param RoleID number @角色ID 
---@return boolean
function FriendMgr:IsInBlackList( RoleID )
    if nil == RoleID or RoleID <= 0 then
        return false
    end

    return FriendVM:IsInBlackList(RoleID)
end

--- 获取黑名单玩家信息
---@param RoleID number @角色ID 
---@return FriendEntryVM @玩家VM数据
function FriendMgr:GetBlackPlayerInfo(RoleID)
    return FriendVM:GetBlackPlayerEntryVM(RoleID)
end

---好友数量是否达到上限
---@param IsShowTips boolean @达到上限后是否弹提示
---@return boolean
function FriendMgr:IsFriendNumLimit( IsShowTips )
    local CurCount = #(FriendVM.AllFriends or {})
    local MaxCount = FriendsDefineCfg:GetFriendMax()
    if CurCount >= MaxCount then
        if IsShowTips then
            -- "你的好友数量已达到上限"
            MsgTipsUtil.ShowTips(LSTR(30018))
        end

        return true
    end

    return false
end

---添加好友（当前玩家）
---@param RoleID number @角色ID 
---@param Source FriendDefine.AddSource @好友添加来源
function FriendMgr:AddFriend( RoleID, Source )
    if nil == RoleID then
        return
    end

	--不可添加自己
	if MajorUtil.IsMajorByRoleID(RoleID) then
        -- "不可添加自己"
		MsgTipsUtil.ShowTips(LSTR(30019))
		return
	end

	--不可重复添加好友
	if self:IsFriend(RoleID) then
        -- "已在好友列表"
		MsgTipsUtil.ShowTips(LSTR(30020))
		return
	end

	--好友数量超过上限
    if self:IsFriendNumLimit(true) then
        return
    end

    local SureFunc = function( )
        local Params = {
            Title = LSTR(30021), --"添加好友申请"
            Desc = LSTR(30022), --"好友申请留言"
            HintText = LSTR(30023), --"请输入留言"
            ConfirmButtonText = LSTR(30024), --"发送申请"
            MaxTextLength = 15,
            SureCallback = function(Text)
                self:SendFriendsConsortMsg(RoleID, Text or "", Source)
            end
        }

        UIViewMgr:ShowView(UIViewID.CommonPopupInput, Params)
    end

	--如果玩家在黑名单中，需要继续弹框
	if self:IsInBlackList(RoleID) then
		MsgBoxUtil.ShowMsgBoxTwoOp(
            nil, 
			LSTR(10004), --"提 示"
            LSTR(30025), --"是否确认添加，该玩家目前位于黑名单内，添加好友将会将其移出黑名单"
            SureFunc,
            nil, LSTR(10003), LSTR(10002)) -- "取 消"、"确 认"

		return
	end

    SureFunc()
end

---删除好友（当前玩家）
---@param RoleID number @角色ID 
---@param RoleName string @角色名
---@param SureCallBack function @点击确定按钮的回调函数
function FriendMgr:DeleteFriend( RoleID, RoleName, SureCallBack)
    if nil == RoleID then
        return
    end

	--不可删除自己
	if MajorUtil.IsMajorByRoleID(RoleID) then
		MsgTipsUtil.ShowTips(LSTR(30026)) --"不可删除自己"
		return
	end

	--不可删除非好友
	if not self:IsFriend(RoleID) then
		MsgTipsUtil.ShowTips(LSTR(30027)) --"对方非好友"
		return
	end

    -- '是否将<span color="#6fb1e9ff">%s</>从好友列表中删除？'
    local Content = string.format(LSTR(30028), RoleName or "")
    MsgBoxUtil.ShowMsgBoxTwoOp(
        nil, 
        LSTR(10004), --"提 示"
        Content,
        function() 
            self:SendRemoveFriendMsg(RoleID, false)

            if SureCallBack then
                SureCallBack()
            end
        end,
        nil, LSTR(10003), LSTR(10002)) -- "取 消"、"确 认"
end

---添加黑名单（当前玩家）
---@param RoleID number @角色ID 
---@param RoleName strng @角色名
---@param SureCallBack function @点击确定按钮的回调函数
function FriendMgr:AddBlackList( RoleID, RoleName, SureCallBack)
    if nil == RoleID then
        return
    end

	--不可添加自己
	if MajorUtil.IsMajorByRoleID(RoleID) then
		MsgTipsUtil.ShowTips(LSTR(30019)) --"不可添加自己"
		return
	end

	--不可重复添加黑名单
	if self:IsInBlackList(RoleID) then
		MsgTipsUtil.ShowTips(LSTR(30029)) --"已在黑名单列表"
		return
	end

    --'是否将<span color="#6fb1e9ff">%s</>加入黑名单？加入后玩家的聊天信息将会不可见，此外组队信息、部队邀请等各项功能将受到限制'
    local Content = string.format(LSTR(30030), RoleName or "")
    MsgBoxUtil.ShowMsgBoxTwoOp(
        nil, 
        LSTR(10004), --"提 示"
        Content,
        function() 
            self:SendMoveToBlacklistMsg(RoleID, true, false, "")

            if SureCallBack then
                SureCallBack()
            end
        end,
        nil, LSTR(10003), LSTR(10002)) -- "取 消"、"确 认"
end

---移出黑名单（当前玩家）
---@param RoleID number @角色ID 
---@param IsFriendBeforeBlack boolean @玩家被拉黑前是否为好友
---@param SureCallBack function @点击确定按钮的回调函数
function FriendMgr:RemoveBlackList( RoleID, IsFriendBeforeBlack, SureCallBack)
    if nil == RoleID then
        return
    end

	--不可重复添加黑名单
	if not self:IsInBlackList(RoleID) then
		MsgTipsUtil.ShowTips(LSTR(30031)) --"不在黑名单列表中"
        return
    end

    local function SendMoveOut()
        self:SendMoveOutBlacklistMsg(RoleID)

        if SureCallBack then
            SureCallBack()
        end
    end

    --玩家被拉黑前不是好友
    if not IsFriendBeforeBlack then 
        SendMoveOut()
        return
    end

	--好友数量未超过上限
    if not self:IsFriendNumLimit() then
        SendMoveOut()
        return
    end

    MsgBoxUtil.ShowMsgBoxTwoOp(
        nil, 
        LSTR(10004), --"提 示"
        LSTR(30032), --"好友已满移除该玩家后该玩家会成为陌生人"
        function() 
            SendMoveOut()
        end,
        nil, LSTR(10003), LSTR(10002)) -- "取 消"、"确 认"
end

---添加最近组队玩家
---@param RoleIDs number @玩家角色ID列表
function FriendMgr:AddRecentTeamPlayer(RoleIDs)
    FriendVM:AddRecentTeamInfo(RoleIDs)
end

---刷新最近聊天玩家信息
function FriendMgr:RefreshRecentChatInfo()
    FriendVM:RefreshRecentChatInfo()
end

--- 是否拒绝好友申请
function FriendMgr:IsRejectFriendRequest()
    return FriendVM.RejectFriendRequest
end

-------------------------------------------------------------------------------------------------------
---主界面侧标拦（好友申请）

function FriendMgr:TryAddNewItem( RoleID )
    --删除模块VM数据
    FriendVM:RemoveRequestItem(RoleID)

    if not FriendVM:IsHaveNewRequest() then
        --删除侧边栏VM数据
        SidebarMgr:RemoveSidebarItem(SidebarType)

    else
        FriendVM:TryAddSidebarItem()
    end
end

function FriendMgr:OpenFriendRequestSidebar(StartTime, CountDown, Type)
    local Info = self:GetNewFriendFirstRequest()
    if nil == Info then
        return
    end

    local AcceptCallBack = function(_, RoleID)
		self:SendFriendsConfirmAddMsg(RoleID, true)
    end

    local RefuseCallBack = function(_, RoleID)
		self:SendFriendsConfirmAddMsg(RoleID, false)
    end

    local Params = {
        Title       = LSTR(30033), --"好友邀请"
        Desc1       = string.format('%s<span color="#8FBDD5FF">%s</>', LSTR(10005), Info.Name or ""), --"玩家"
        Desc2       = LSTR(30034), --"请求添加你为好友"
        StartTime   = StartTime,
        CountDown   = CountDown,
        CBFuncLeft  = RefuseCallBack,
        CBFuncRight = AcceptCallBack,
        Type        = Type, 

        --透传数据
        TransData = Info.RoleID,
    }

    _G.UIViewMgr:ShowView(_G.UIViewID.SidebarCommon, Params)
end

-------------------------------------------------------------------------------------------------------
--- 平台好友

--- 邀请平台好友上线
---@param OpenID string @平台好友的OpenID
---@param RoleID number @角色ID
function FriendMgr:InvitePlatformFriendOnline(OpenID, RoleID)
    if not string.isnilorempty(OpenID) then
        _G.ShareMgr:QueryBackendArkInfo(OpenID)
    end

    FriendVM:AddPlatformInvitedPlayer(RoleID)
    MsgTipsUtil.ShowTips(LSTR(30071)) -- "邀请成功"
end

-------------------------------------------------------------------------------------------------------

return FriendMgr
