---@author: wallencai(蔡文超) 2022-07-11 17:16:09
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local TimeUtil = require("Utils/TimeUtil")
local ChatMgr = require("Game/Chat/ChatMgr")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local FriendDefine = require("Game/Social/Friend/FriendDefine")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local FriendEntryVM = require("Game/Social/Friend/VM/FriendEntryVM")
local FriendGroupEntryVM = require("Game/Social/Friend/VM/FriendGroupEntryVM")
local FriendGroupItemVM = require("Game/Social/Friend/VM/FriendGroupItemVM")
local SocialSettings = require("Game/Social/SocialSettings")
local FriendsDefineCfg = require("TableCfg/FriendsDefineCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local MajorUtil = require("Utils/MajorUtil")
local Json = require("Core/Json")
local TeamMgr = require("Game/Team/TeamMgr")
local PWorldTeamMgr = require("Game/PWorld/Team/PWorldTeamMgr")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local SocialDefine = require("Game/Social/SocialDefine")
local CommonUtil = require("Utils/CommonUtil")
local FriendPlatformFriendItemVM = require("Game/Social/Friend/VM/FriendPlatformFriendItemVM")

local AllGroupID = FriendDefine.AllGroupID
local DefaultGroupID = FriendDefine.DefaultGroupID
local BlackGroupID = FriendDefine.BlackGroupID
local SidebarType = SidebarDefine.SidebarType.FriendInvite
local MaxRecentTeamNum = FriendDefine.MaxRecentTeamNum
local MaxRecentChatNum = FriendDefine.MaxRecentChatNum
local RedDotID = SocialDefine.RedDotID
local PlayerItemSortFunc = SocialDefine.PlayerItemSortFunc
local ListState = FriendDefine.ListState

local LSTR
local FLOG_INFO

--- 分组排序
local GroupSortFunc = function(lhs, rhs)
    local lhs_ID = lhs.ID
    local rhs_ID = rhs.ID
    if lhs_ID ~= rhs_ID then
        if nil == lhs_ID or nil == rhs_ID then
            return nil ~= lhs_ID
        end

        if lhs_ID == BlackGroupID or rhs_ID == BlackGroupID then
            return lhs_ID ~= BlackGroupID 
        end

        if lhs_ID == DefaultGroupID or rhs_ID == DefaultGroupID then
            return lhs_ID ~= DefaultGroupID 
        end
    end

    if lhs.CreateTime ~= rhs.CreateTime then
        return lhs.CreateTime < rhs.CreateTime
    end

    return lhs_ID < rhs_ID
end

--- 搜索排序算法
---@param s1 any
---@param s2 any
local FriendSearchSortFunc = function(s1, s2)
    if s1.IsOnline ~= s2.IsOnline then
        return s1.IsOnline
    end

    return s1.Name < s2.Name
end

---@class FriendVM : UIViewModel
local FriendVM = LuaClass(UIViewModel)

---Ctor
function FriendVM:Ctor()

end

--- func desc
function FriendVM:OnInit()
    self:Reset()
end

--- func desc
function FriendVM:OnBegin()
    LSTR = _G.LSTR
    FLOG_INFO = _G.FLOG_INFO
end

function FriendVM:OnEnd()

end

function FriendVM:OnShutdown()
    self:Reset()
end

function FriendVM:Reset()
    self.RejectFriendRequest = false

    self.NewFriendRequestList = {}
    self.CurSidebarInfo = nil

    self.AllFriends = {}
    self.BlackRoleIDMap = {}

	self.Keyword = ""
    self.CreateGroupCount = 0 -- 玩家创建分组个数

    self.CurShowingGroupID = nil
    self.FriendListState = ListState.Normal

    self.GroupVMList = self:ResetBindableList(self.GroupVMList)
    self.ShowingFriendEntryVMList = self:ResetBindableList(self.ShowingFriendEntryVMList)

    --- 平台好友
    self.PlatformKeyword = ""
    self.PlatformFriendListState = ListState.Normal
	self.PlatformInvitedPlayerMap = {} 
    self.PlatformFriendItemVMList = self:ResetBindableList(self.PlatformFriendItemVMList, FriendPlatformFriendItemVM)
    self.ShowingPlatformFriendItemVMList = self:ResetBindableList(self.ShowingPlatformFriendItemVMList)

    ------------------------------------------------------------------------
    -- 分组管理

    self.IsCheckedSingleBoxAll = false
    self.BtnBatchSwitchEnabled = false
    self.CurBatchSwitchRoleIDs = {}
    self.IsCreateGrouping = false 
    self.IsDeleteGrouping = false

    self.GroupManageVMList = self:ResetBindableList(self.GroupManageVMList, FriendGroupItemVM)
    self.GroupManageFriendVMList = self:ResetBindableList(self.GroupManageFriendVMList, FriendEntryVM)

    ------------------------------------------------------------------------
    -- 添加好友

    self.IsEmptyFindList = false 
    self.FindEmptyTips = nil
    self.IsEmptyApplyList = true
    self.RecentTeamRoleIDs = {} 
    self.RecentChatRoleIDs = {} 

    self.IsScreening = false
    self.ProfScreenList = {} 
    self.PlayStyleScreenList = {} 

    self.FindResultVMList = self:ResetBindableList(self.FindResultVMList)
    self.FriendApplyVMList = self:ResetBindableList(self.FriendApplyVMList)
end

--- 更新分组列表
---@param Groups table @分组信息列表，{ csfriends.Groups, ... }
---@param BlackList table @黑名单列表，{ csfriends.BlackListPerson, ... }
function FriendVM:UpdateGroupList(Groups, BlackList)
    local ReqRoleIDs = {}

    for _, v in ipairs(Groups) do
        for _, v1 in ipairs(v.Friends) do
            local RoleID = v1.RoleID
            if RoleID then
                table.insert(ReqRoleIDs, RoleID)
            end
        end
    end

    local BlackMap = {}

    for _, v in ipairs(BlackList) do
        local RoleID = v.RoleID
        if RoleID then
            table.insert(ReqRoleIDs, RoleID)

            BlackMap[RoleID] = true
        end
    end

    self.BlackRoleIDMap = BlackMap

    local QueryCallBack = function()
        local GroupVMList = self.GroupVMList
        GroupVMList:Clear()

        -- 增加 "黑名单" 组
        local GroupVM = FriendGroupEntryVM.New()
        GroupVM:UpdateByBlackList(BlackList)
        GroupVMList:Add(GroupVM)

        -- 好友分组
        local Count = 0

        for _, v in ipairs(Groups) do
            local ID = v.ID
            if ID and ID ~= DefaultGroupID then
                Count = Count + 1
            end
  
            local EntryVM = FriendGroupEntryVM.New()
            EntryVM:UpdateByFriendGroup(v)
            GroupVMList:Add(EntryVM)
       end

        self.CreateGroupCount = Count 

        local Items = self.GroupVMList:GetItems()

        for _, v in ipairs(Items) do
            v:UpdateMembersRoleInfo()
        end

        GroupVMList:Sort(GroupSortFunc)


        self:UpdateAllFriends()
        self:UpdateFindFriendListState()

        EventMgr:SendEvent(EventID.FriendUpdate)
    end

    if #ReqRoleIDs > 0 then
        RoleInfoMgr:QueryRoleSimples(ReqRoleIDs, QueryCallBack, nil, false)

    else
        QueryCallBack()
    end
end

function FriendVM:UpdateAllFriends()
    local CurRoleIDMap = table.invert(table.extract(self.AllFriends, "RoleID"))
    local AddRoleIDs = {} 

    self.AllFriends = {}

    local GroupItems = self.GroupVMList:GetItems()

    for _, v in ipairs(GroupItems) do
        if v.ID ~= BlackGroupID then
            local MemItems = v.MemberVMList:GetItems()

            for _, v1 in ipairs(MemItems) do
                local RoleID = v1.RoleID
                if nil ~= RoleID then
                    table.insert(self.AllFriends, v1)

                    --更新私聊对话
                    ChatMgr:UpdatePrivateChatSession(RoleID)

                    if nil == CurRoleIDMap[RoleID] then 
                        table.insert(AddRoleIDs, RoleID)
                    end
                end
            end
        end
    end

    self:FilterFriendVMByGroupID(self.CurShowingGroupID)

    if #AddRoleIDs > 0 then
        EventMgr:SendEvent(EventID.FriendAdd, AddRoleIDs)

        -- 检查最近信息（排除好友、黑名单）
        self:CheckRecentInfo()
    end
end

--- 删除好友
---@param RoleID number @被删角色ID 
function FriendVM:RemoveFriend(RoleID)
    if nil == RoleID then
        return
    end

    local GroupVMList = self.GroupVMList
    local GroupVM = GroupVMList:Find(function(Item) return Item:GetMemberByRoleID(RoleID) ~= nil and Item.ID ~= BlackGroupID end)
    if nil == GroupVM then
        return
    end

    GroupVM.MemberVMList:RemoveByPredicate(function(Item) return Item.RoleID == RoleID end)
    GroupVM:UpdateMembersRoleInfo()

    -- 更新所有好友数据
    if table.remove_item(self.AllFriends, RoleID, "RoleID") then
        self:FilterFriendVMByGroupID(self.CurShowingGroupID)
    end

    EventMgr:SendEvent(EventID.FriendUpdate)
    EventMgr:SendEvent(EventID.FriendRemoved, {RoleID})

    -- 删除签名信息设置
    SocialSettings.DeleteFriendHideSignInfo(RoleID)
end

--- 更新好友备注
---@param RoleID number @角色ID 
---@param NewRemark string @新备注 
function FriendVM:UpdateFriendRemark(RoleID, NewRemark)
    local Items = self.GroupVMList:GetItems()

    for _, v in ipairs(Items) do
        local Member = v:GetMemberByRoleID(RoleID)
        if Member then
            Member.Remark = NewRemark
            break
        end
    end
end

--- 改变玩家分组
---@param Groups csproto.role.friends.MoveFriendGroup @移动好友分组信息
function FriendVM:TransformFriendsGroup(Groups)
    if nil == Groups or #Groups <= 0 then
        return
    end

    local GroupVMList = self.GroupVMList
    local OldGroupIDList = {}
    local NewGroupIDList = {}

    for _, v in ipairs(Groups) do
        local RoleID = v.RoleID

        -- 移除批处理数据
        self:RemoveBatchSwitch(RoleID)

        local FriendEntry = nil
        local OldGroup = GroupVMList:Find(function(Item)
            local Member = Item:GetMemberByRoleID(RoleID)
            if Member then
                FriendEntry = Member
                return true
            end
        end)

        local NewGroupID = v.ID
        if nil ~= OldGroup and nil ~= FriendEntry and OldGroup.ID ~= NewGroupID then -- Fixed后台未做重复移除的检验问题
            OldGroup.MemberVMList:Remove(FriendEntry)

            if not table.contain(OldGroupIDList, OldGroup.ID) then
                table.insert(OldGroupIDList, OldGroup.ID)
            end

            local NewGroup = GroupVMList:Find(function(Item) return Item.ID == NewGroupID end)
            if NewGroup then
                NewGroup.MemberVMList:Add(FriendEntry)
                FriendEntry.GroupID = NewGroupID

                if not table.contain(NewGroupIDList, NewGroupID) then
                    table.insert(NewGroupIDList, NewGroupID)
                end
            end
        end
    end

    local UpdateGroupRoleInfo = function(IDs, IsShowTips)
        for _, v in ipairs(IDs) do
            local Group = GroupVMList:Find(function(Item) return Item.ID == v end)
            if Group then
                Group:UpdateMembersRoleInfo()

                if IsShowTips then
                    local Fmt = LSTR(30035) -- 好友移动至‘%s’
                    local Content = string.format(Fmt, Group.Name)
                    MsgTipsUtil.ShowTips(Content)
                end
            end
        end
    end

    --更新新老分组成员角色信息
    UpdateGroupRoleInfo(OldGroupIDList)
    UpdateGroupRoleInfo(NewGroupIDList, true)

    EventMgr:SendEvent(EventID.FriendTransGroup, OldGroupIDList, NewGroupIDList)
end

function FriendVM:CheckItemsSortPriority(Items, b)
    local Keyword = self.Keyword
    local IsCheckName = (nil == b) and (not string.isnilorempty(Keyword))

    for _, v in ipairs(Items) do
        v:SetSortPriority(IsCheckName and (Keyword == v.Name) or b)
    end
end

--- 是否已经是好友
---@param RoleID number @角色ID 
function FriendVM:IsAreadyFriend(RoleID)
    return table.find_by_predicate(self.AllFriends or {}, function(e) return RoleID ~= nil and RoleID == e.RoleID end) ~= nil
end

---------------------------------------------------------------------------------------------------------------
--- 好友过滤

--- 通过组ID过滤
---@param ID number @小组ID
function FriendVM:FilterFriendVMByGroupID(ID, NotRefreshList)
    if nil == ID then
        return
    end

    self.CurShowingGroupID = ID

    if NotRefreshList then
        return
    end

    if ID == AllGroupID then
        self:ClearFilterData()
        return
    end

    local GroupVM = self.GroupVMList:Find(function(Item) return Item.ID == ID end)
    if nil == GroupVM then
        return
    end

    local Items = GroupVM.MemberVMList:GetItems()
    self:CheckItemsSortPriority(Items, false)

    self.ShowingFriendEntryVMList:Update(Items, PlayerItemSortFunc)
    self:UpdateListState()

    if #Items > 0 then
        EventMgr:SendEvent(EventID.FriendPlayUpdateFriendListAnim)
    end
end

--- 通过玩家名关键词过滤
---@param Keyword string @关键词 
function FriendVM:FilterFriendByKeyword( Keyword )
    local FilterList = {}

    for _, v in ipairs(self.AllFriends) do
        local Name = v.Name
        if Name then
            local Pattern = CommonUtil.ReviseRegexSpecialCharsPattern(Keyword)
            if string.find(Name, Pattern) then
                table.insert(FilterList, v)
            end
        end
    end

	self.Keyword = Keyword
    self:CheckItemsSortPriority(FilterList)

    self.ShowingFriendEntryVMList:Update(FilterList, PlayerItemSortFunc)
    self:UpdateListState()

    if #FilterList > 0 then
        EventMgr:SendEvent(EventID.FriendPlayUpdateFriendListAnim)
    end
end

function FriendVM:ClearFilterData()
	self.Keyword = ""

    self:CheckItemsSortPriority(self.AllFriends, false)

    self.ShowingFriendEntryVMList:Update(self.AllFriends, PlayerItemSortFunc)
    self:UpdateListState()

    if #self.AllFriends > 0 then
        EventMgr:SendEvent(EventID.FriendPlayUpdateFriendListAnim)
    end
end

function FriendVM:UpdateListState()
    local State = ListState.Normal 
    if self.ShowingFriendEntryVMList:Length() <= 0 then
        if string.isnilorempty(self.Keyword) then
            if table.is_nil_empty(self.AllFriends) and table.is_nil_empty(self.BlackRoleIDMap) then
                State = ListState.NoFriend
            else
                State = ListState.ListEmpty
            end
        else
            State = ListState.SearchEmpty
        end
    end

    self.FriendListState = State
end

function FriendVM:ClearListPanelData()
    self.ShowingFriendEntryVMList:Clear()
    self.CurShowingGroupID = nil
    self.FriendListState = ListState.Normal
end

---------------------------------------------------------------------------------------------------------------
---黑名单

--- 更新黑名单成员角色信息
function FriendVM:UpdateBlackRoleInfo()
    local GroupVM = self.GroupVMList:Find(function(Item) return Item.ID == BlackGroupID end)
    if nil == GroupVM then
        return
    end

    -- 更新角色成员信息
    GroupVM:UpdateMembersRoleInfo()
end

--- 添加黑名单
---@param RoleID number @角色ID
function FriendVM:AddBlackListInfo( RoleID )
    if nil == RoleID then
        return
    end

    local GroupVM = self.GroupVMList:Find(function(Item) return Item.ID == BlackGroupID end)
    if nil == GroupVM then
        return
    end

    -- 从好友列表、申请列表中移除玩家
    self:RemoveFriend(RoleID)
    self:RemoveFromApplyList(RoleID)

    -- 更新黑名单Map
    self.BlackRoleIDMap[RoleID] = true

    local Entry = FriendEntryVM:New()
    Entry:UpdateVM({GroupID = BlackGroupID, RoleID = RoleID})
    GroupVM.MemberVMList:Add(Entry)

    -- 检查最近信息（排除好友、黑名单）
    self:CheckRecentInfo()

    RoleInfoMgr:QueryRoleSimple(RoleID, function() 
        self:UpdateBlackRoleInfo() 

        EventMgr:SendEvent(EventID.FriendAddBlack)
    end, nil, false)
end

--- 移出黑名单
---@param RoleID number @角色ID
function FriendVM:RemoveBlackList( RoleID )
    if nil == RoleID then
        return
    end

    local GroupVMList = self.GroupVMList
    local GroupVM = GroupVMList:Find(function(Item) return Item.ID == BlackGroupID end)
    if nil == GroupVM then
        return
    end

    -- 更新黑名单Map
    self.BlackRoleIDMap[RoleID] = nil 

    GroupVM.MemberVMList:RemoveByPredicate(function(Item) return Item.RoleID == RoleID end)

    self:UpdateBlackRoleInfo()

    EventMgr:SendEvent(EventID.FriendRemoveBlack)
end

--- 判断玩家是否在黑名单
---@param RoleID number @角色ID 
function FriendVM:IsInBlackList(RoleID)
    if nil == RoleID or RoleID <= 0 then
        return false
    end

    return self.BlackRoleIDMap[RoleID]
end

--- 获取黑名单玩家EntryVM
---@param RoleID number @角色ID 
---@return FriendEntryVM @玩家VM数据
function FriendVM:GetBlackPlayerEntryVM(RoleID)
    if nil == RoleID then
        return
    end

    local GroupVM = self.GroupVMList:Find(function(Item) return Item.ID == BlackGroupID end)
    if GroupVM then
        return GroupVM:GetMemberByRoleID(RoleID)
    end
end

---------------------------------------------------------------------------------------------------------------
---分组

--- 重置分组管理信息
function FriendVM:ResetGroupManageInfo()
    local GroupManageVMList = self.GroupManageVMList
    GroupManageVMList:Clear()

    local Data = {}
    local Items = self.GroupVMList:GetItems()
    local CreateCount = self.CreateGroupCount
	local IsCreatedGroup = CreateCount > 0  -- 只有玩家创建一个自定义分组后，才显示默认分组("未分组")

    for _, v in ipairs(Items) do
        local GroupID = v.ID
        if GroupID ~= BlackGroupID and (GroupID ~= DefaultGroupID or IsCreatedGroup) then
            local Info = { 
                ID = v.ID, 
                Name = v.Name, 
                CreateTime = v.CreatTime, 
                OnlineCount = v.OnlineCount,  
                TotalCount = v.TotalCount,  
            }
            table.insert(Data, Info)
        end
    end

    --添加空Item("新建分组" item)
    local MaxNum = FriendsDefineCfg:GetFriendGroupMax()
    if CreateCount < MaxNum then
        table.insert(Data, {})
    end

    GroupManageVMList:UpdateByValues(Data) 
end

function FriendVM:GetSwitchGroupJumpList(CurGroupID, Callback, CallbackView)
    local Ret = {}
	local Items = self.GroupManageVMList:GetItems()
	local GroupVMList = self.GroupVMList

	for _, v in ipairs(Items) do
		local ID = v.ID
		if ID and ID ~= CurGroupID then
			local EntryVM = GroupVMList:Find(function(Item) return Item.ID == ID end)
			if EntryVM then
				local Desc = string.format('%s（%s/%s）', EntryVM.Name, EntryVM.OnlineCount or 0, EntryVM.TotalCount or 0)
				table.insert(Ret,
					{
						TextName = Desc,
						Data = v,
						ClickItemCallback = Callback,
						View = CallbackView,
					}
				)
            end
		end
	end

    return Ret
end

--- 增加新的好友分组
---@param GroupRsp csfriends.NewFriendGroupRsp @分组信息
function FriendVM:AddFriendGroup(GroupRsp)
    local GroupVM = FriendGroupEntryVM.New()
    GroupVM:UpdateByFriendGroup(GroupRsp)
    GroupVM:UpdateMembersRoleInfo()

    local GroupVMList = self.GroupVMList
    GroupVMList:Add(GroupVM)
    GroupVMList:Sort(GroupSortFunc)

	self.CreateGroupCount = self.CreateGroupCount + 1

    --分组管理数据
    if self:IsGroupManaging() then
        local MgVMList = self.GroupManageVMList

        -- 检测添加默认分组
        local CurCount = self.CreateGroupCount 
        if CurCount <= 1 then
            local DefaultGroupVM = GroupVMList:Find(function(Item) return Item.ID == DefaultGroupID end)
            if DefaultGroupVM then
                MgVMList:AddByValue({ID = DefaultGroupVM.ID, Name = DefaultGroupVM.Name, CreateTime = DefaultGroupVM.CreateTime})
            end

        else
            local MaxNum = FriendsDefineCfg:GetFriendGroupMax()
            if CurCount >= MaxNum then
                MgVMList:RemoveByPredicate(function(Item) return nil == Item.ID end)
            end
        end

        -- 添加新分组
        MgVMList:AddByValue({ID = GroupVM.ID, Name = GroupVM.Name, CreateTime = GroupVM.CreateTime})

        MgVMList:Sort(GroupSortFunc)
    end

    EventMgr:SendEvent(EventID.FriendGroupInfoUpdate)
end

--- 删除好友分组
---@param ID number @删除的好友分组ID
function FriendVM:RemoveFriendGroup(ID)
    -- 如果删除的分组内有好友，那么将当前分组的所有好友移动到默认分组内
    local DefaultGroup
    local DeletedGroup

    local GroupVMList = self.GroupVMList
    local Items = GroupVMList:GetItems()

    for _, v in ipairs(Items) do
        if v.ID == DefaultGroupID then
            DefaultGroup = v
        end

        if v.ID == ID then
            DeletedGroup = v
        end

        -- 提前跳出循环
        if DefaultGroup ~= nil and DeletedGroup ~= nil then
            break
        end
    end

    if DeletedGroup == nil or DefaultGroup == nil then
        return
    end

    -- 将删除分组的好友信息复制到默认分组
    local Friends = DeletedGroup.MemberVMList:GetItems()

    for _, v in ipairs(Friends) do
        -- 更新分组ID
        v.GroupID = DefaultGroupID
    end

    DefaultGroup.MemberVMList:AddRange(Friends)
    if #Friends > 0 then
        DefaultGroup:UpdateMembersRoleInfo()
    end

    GroupVMList:Remove(DeletedGroup)

    -- 如果刚好删除的是当前选中展示的那个分组，重置分组到默认分组
    if ID == self.CurShowingGroupID then
        self:FilterFriendVMByGroupID(DefaultGroupID)
    end

	self.CreateGroupCount = math.max(self.CreateGroupCount - 1, 0)

    --分组管理数据
    if self:IsGroupManaging() then
        local MgVMList = self.GroupManageVMList

        -- 检测删除默认分组
        local CurCount = self.CreateGroupCount
        if CurCount <= 0 then
            MgVMList:RemoveByPredicate(function(Item) return Item.ID == DefaultGroupID end)
        end

        MgVMList:RemoveByPredicate(function(Item) return Item.ID == ID end)

        local EmptyItemVM = MgVMList:Find(function(Item) return nil == Item.ID end)
        if nil == EmptyItemVM then
            -- 由于被摧毁的通讯贝均为玩家加入的通讯贝，所以此处无需判断数量，直接添加一个空Item(“新建分组”)
            MgVMList:AddByValue({})
        end
    end

    EventMgr:SendEvent(EventID.FriendGroupInfoUpdate)
end

--- 更新某个好友分组的名称信息
---@param ID number @好友分组ID
---@param NewName string @新的名称
function FriendVM:UpdateFriendGroupName(ID, NewName)
    local GroupVMList = self.GroupVMList
    local GroupVM = GroupVMList:Find(function(Item) return Item.ID == ID end)
    if nil == GroupVM then
        return
    end

    GroupVM:UpdateName(NewName)

    GroupVMList:Sort(GroupSortFunc)

    --分组管理数据
    if self:IsGroupManaging() then
        local GroupManageVMList = self.GroupManageVMList
        local ItemVM = GroupManageVMList:Find(function(Item) return Item.ID == ID end)
        if ItemVM then
            ItemVM:UpdateName(NewName)
        end
    end

    EventMgr:SendEvent(EventID.FriendGroupInfoUpdate)
end

function FriendVM:GetNewGroupDefaultName()
    local Count = self.CreateGroupCount
    local Fmt = LSTR(30036) -- "未命名%s"
    local Ret = string.format(Fmt, Count > 0 and tostring(Count + 1) or "")
    return Ret
end

--- 是否正在小组管理操作中
function FriendVM:IsGroupManaging()
	return UIViewMgr:IsViewVisible(UIViewID.FriendGroupManageWin)
end

---更新分组管理好友数据列表
function FriendVM:UpdateGroupManageFriendVMList(GroupID)
    local FriendVMList = self.GroupManageFriendVMList
    if nil == GroupID then
        FriendVMList:Clear()
        return
    end

    local GroupEntryVM = self.GroupVMList:Find(function(Item) return Item.ID == GroupID end)
    if nil == GroupEntryVM then
        FriendVMList:Clear()
        return
    end

    local Items = GroupEntryVM.MemberVMList:GetItems()
    FriendVMList:Update(Items, PlayerItemSortFunc)
end

---------------------------------------------------------------------
--- 批量调整分组

function FriendVM:IsInBatchSwitch(RoleID)
    return nil ~= RoleID and table.contain(self.CurBatchSwitchRoleIDs or {}, RoleID)
end

function FriendVM:AddBatchSwitch(RoleID)
    if nil == RoleID then 
        return
    end

    local RoleIDs = self.CurBatchSwitchRoleIDs
    if nil ~= RoleIDs and not table.contain(RoleIDs, RoleID) then
        table.insert(RoleIDs, RoleID)

        --检测是否全选的状态，简单点处理，只比较玩家数量
        self.IsCheckedSingleBoxAll = #RoleIDs == self.GroupManageFriendVMList:Length()
        self.BtnBatchSwitchEnabled = true

        EventMgr:SendEvent(EventID.FriendBatchSwitchGroupUpdate)
    end
end

function FriendVM:RemoveBatchSwitch(RoleID)
    if nil == RoleID then 
        return
    end

    local RoleIDs = self.CurBatchSwitchRoleIDs
    if nil ~= RoleIDs then
        if table.remove_item(RoleIDs, RoleID) then
            self.IsCheckedSingleBoxAll = false 
            self.BtnBatchSwitchEnabled = #RoleIDs > 0 
            EventMgr:SendEvent(EventID.FriendBatchSwitchGroupUpdate)
        end
    end
end

function FriendVM:SetAllSwitch(b)
    if not b then
        self.CurBatchSwitchRoleIDs = {}
    else
        local Items = self.GroupManageFriendVMList:GetItems()
        local Data = {}

        for _, v in ipairs(Items) do
            table.insert(Data, v.RoleID)
        end

        self.CurBatchSwitchRoleIDs = Data 
    end

    self.IsCheckedSingleBoxAll = b 
    self.BtnBatchSwitchEnabled = #self.CurBatchSwitchRoleIDs > 0 

    EventMgr:SendEvent(EventID.FriendBatchSwitchGroupUpdate)
end

function FriendVM:ClearGroupSwitchData( )
    self.IsCheckedSingleBoxAll = false
    self.BtnBatchSwitchEnabled = false
    self.CurBatchSwitchRoleIDs = {}
end

function FriendVM:ClearGroupManageData( )
    self:ClearGroupSwitchData()

    self.GroupManageVMList:Clear()
    self.IsCreateGrouping = false 
    self.IsDeleteGrouping = false
end

function FriendVM:GetDropDownItems( )
	local Ret = {}
    local AllGroupName = FriendDefine.AllGroupName

    -- 增加 "全部好友" 组
	local AllGroup = { GroupID = AllGroupID}
	table.insert(Ret, AllGroup)

    local OnlineCount = 0
    local TotalCount = 0

	local Items = self.GroupVMList:GetItems()
	local IsCreatedGroup = self.CreateGroupCount > 0 

	for _, v in ipairs(Items) do
		local GroupID = v.ID
		local Data = { GroupID = GroupID, Name = v.Desc }

		if GroupID ~= BlackGroupID then -- 黑名单不计算到 "全部好友" 分组
			OnlineCount = OnlineCount + v.OnlineCount
			TotalCount = TotalCount + v.TotalCount

            -- 只有玩家创建一个自定义分组后，才显示默认分组("未分组")
            if GroupID ~= DefaultGroupID or IsCreatedGroup then
				table.insert(Ret, Data)
			end

		else
			table.insert(Ret, Data)
		end

	end

	AllGroup.Name = string.format("%s %s/%s", AllGroupName, OnlineCount, TotalCount)

    return Ret
end

-------------------------------------------------------------------------------------------------------
--- 添加好友（寻找好友、申请列表） 

--- 更新寻找好友结果列表
---@param RoleIDs table @角色ID列表
---@param IsSort boolean @是否排序, 默认排序
function FriendVM:UpdateFindFriendList(RoleIDs, IsSort)
    -- 搜索列表为空
    if nil == RoleIDs or #RoleIDs <= 0 then
        self.FindResultVMList:Clear()
        self.IsEmptyFindList = true

        return 
    end

    RoleInfoMgr:QueryRoleSimples(RoleIDs, function()
        self.FindResultVMList:Clear()

        for _, roleId in ipairs(RoleIDs) do
            local RoleVM = RoleInfoMgr:FindRoleVM(roleId)

            -- 特殊处理，屏蔽掉无效玩家
            if not string.isnilorempty(RoleVM.Name) then
                local FriendEntry = FriendEntryVM.New()
                FriendEntry:UpdateRoleInfo(RoleVM)
                FriendEntry.IsFriend = self:IsAreadyFriend(roleId)

                self.FindResultVMList:Add(FriendEntry)
            end
        end

        if IsSort ~= false then
            self.FindResultVMList:Sort(FriendSearchSortFunc)
        end

        local IsEmpty = self.FindResultVMList:Length() <= 0
        self.IsEmptyFindList = IsEmpty 

        if not IsEmpty then
            EventMgr:SendEvent(EventID.FriendPlayAddUpdateListAnim)
        end

    end, nil, false)
end

function FriendVM:UpdateFindFriendListState()
    local Items = self.FindResultVMList:GetItems()
    if #Items <= 0 then
        return
    end

    for _, v in ipairs(Items) do
        v.IsFriend = self:IsAreadyFriend(v.RoleID)
    end
end

--- 更新好友申请列表
---@param FriendApplyVMList any
function FriendVM:UpdateApplyList(FriendApplyVMList)
    local ApplyList = self.FriendApplyVMList
    ApplyList:Clear()

    for _, ConsortPerson in ipairs(FriendApplyVMList) do
        local vm = FriendEntryVM.New()
        vm:UpdateByConsortInfo(ConsortPerson)
        ApplyList:Add(vm)
    end

    self:UpdateIsEmptyApplyList()

    if not self.IsEmptyApplyList then
        EventMgr:SendEvent(EventID.FriendPlayAddUpdateListAnim)
    end

    self:UpdateApplyAddFriendRedDot()
end

--- 申请列表新增玩家
---@param ConsortNtf any @主动推送的添加好友通知
function FriendVM:AddNewConsortApply(ConsortNtf)
    local RoleID = ConsortNtf.RoleID
    local currentVM = self.FriendApplyVMList:Find(function(Item)
        return Item.RoleID == RoleID
    end)

    if currentVM == nil then
        local VM = FriendEntryVM.New()
        VM:UpdateByConsortInfo(ConsortNtf)
        self.FriendApplyVMList:Add(VM)

        self:UpdateIsEmptyApplyList()
    else
        -- 已经申请列表里面已经存在了
        currentVM:UpdateReqTime(ConsortNtf.Time)
        currentVM:UpdateRemark(ConsortNtf.Remark)
    end

    self:AddRequestItem(RoleID)
    self:UpdateApplyAddFriendRedDot()
end

--- 好友申请列表中移除指定玩家
---@param RoleID number @移除的玩家的角色ID
function FriendVM:RemoveFromApplyList(RoleID)
    self.FriendApplyVMList:RemoveByPredicate(function(rolevm)
        return rolevm.RoleID == RoleID
    end)

    self:UpdateIsEmptyApplyList()
    self:UpdateApplyAddFriendRedDot()
end

function FriendVM:UpdateIsEmptyApplyList()
    self.IsEmptyApplyList = self.FriendApplyVMList:Length() <= 0
end

------- 寻找好友（职业、游戏风格筛选）

function FriendVM:UpdateScreenDataInternal(ScreenList, ID)
    if nil == ScreenList or nil == ID then
        return false
    end

    -- 列表已存在ID，就删除
    if table.remove_item(ScreenList, ID) then
        return true
    end

    -- 不存在ID，就添加
    table.insert(ScreenList, ID)
    return true
end

function FriendVM:UpdateProfScreen(ProfID)
    local IsChange = self:UpdateScreenDataInternal(self.ProfScreenList, ProfID)
    if IsChange then 
        EventMgr:SendEvent(EventID.FriendScreenProfUpdate)
    end
end

function FriendVM:UpdatePlayStyleScreen(StyleID)
    local IsChange = self:UpdateScreenDataInternal(self.PlayStyleScreenList, StyleID)
    if IsChange then 
        EventMgr:SendEvent(EventID.FriendScreenPlayStyleUpdate)
    end
end

function FriendVM:ResetFindScreenData()
    self.ProfScreenList = {} 
    self.PlayStyleScreenList = {} 

    EventMgr:SendEvent(EventID.FriendScreenProfUpdate)
    EventMgr:SendEvent(EventID.FriendScreenPlayStyleUpdate)
end

function FriendVM:ClearFindScreenData()
    self.IsScreening = false
    self.ProfScreenList = {} 
    self.PlayStyleScreenList = {} 
end

------- 近期组队、近期聊天

function FriendVM:SaveRecentInfoInternal(SetupID, RoleIDs)
	if nil == RoleIDs then
		return
	end

   local Str = Json.encode(RoleIDs)
    if Str then 
        _G.ClientSetupMgr:SendSetReq(SetupID, Str)
    end
end

function FriendVM:UpdateRecentInfo(SetupID, RoleIDs)
    local SrcNum = #RoleIDs
    local MajorRoleID = MajorUtil.GetMajorRoleID()

	for i = #RoleIDs, 1, -1 do
		local RoleID = RoleIDs[i]

        -- 去掉已是好友的玩家、去掉黑名单玩家
        if RoleID == MajorRoleID or self:IsAreadyFriend(RoleID) or self:IsInBlackList(RoleID) then
            table.remove(RoleIDs, i)
        end
	end

    local IsChange = SrcNum ~= #RoleIDs

    if SetupID == ClientSetupID.FriendRecentTeam then

        -- 检测当前玩家队伍成员
        local UpdateTeamMem = function(MemberList) 
            for _, v in ipairs(MemberList) do
                local RoleID = v.RoleID
                if RoleID and MajorRoleID ~= RoleID and not table.contain(RoleIDs, RoleID)
                    and not self:IsAreadyFriend(RoleID) and not self:IsInBlackList(RoleID) then
                    table.insert(RoleIDs, 1, RoleID)
                    IsChange = true
                end
            end
        end

        -- 外部队伍
        if TeamMgr:IsInTeam() then
            UpdateTeamMem(TeamMgr:GetMemberList() or {})
        end

        -- 副本队伍
        if PWorldTeamMgr:IsInTeam() then
            UpdateTeamMem(PWorldTeamMgr:GetMemberList() or {})
        end

        IsChange = self:CheckRecentNumLimit(RoleIDs, MaxRecentTeamNum) or IsChange
        self.RecentTeamRoleIDs = RoleIDs

    elseif SetupID == ClientSetupID.FriendRecentChat then
        IsChange = self:CheckRecentNumLimit(RoleIDs, MaxRecentChatNum) or IsChange
        self:CheckRecentNumLimit(RoleIDs, MaxRecentChatNum)
        self.RecentChatRoleIDs = RoleIDs
    end

    -- 保存
    if IsChange then
        self:SaveRecentInfoInternal(SetupID, RoleIDs)
        EventMgr:SendEvent(EventID.FriendRecentInfoUpdate, SetupID)
    end
end

---检查是否超出数量限制
function FriendVM:CheckRecentNumLimit(IDList, MaxNum)
    local Ret = false

    for i = #IDList, 1, -1 do
        if #IDList > MaxNum then
            table.remove(IDList, i)
            Ret = true
        end
    end

    return Ret
end

---添加最近组队玩家
---@param RoleIDs number @玩家角色ID列表
function FriendVM:AddRecentTeamInfo(RoleIDs)
    if nil == RoleIDs or #RoleIDs <= 0 then
        return
    end

	local MajorRoleID = MajorUtil.GetMajorRoleID()

    for _, v in ipairs(RoleIDs) do
        if v ~= MajorRoleID and not self:IsAreadyFriend(v) and not self:IsInBlackList(v) then
            local IDList = self.RecentTeamRoleIDs 

            for i = #IDList, 1, -1 do
                local ID = IDList[i]
                if ID == v then
                    table.remove(IDList, i)
                end
            end

            -- 移动到列表最前
            table.insert(IDList, 1, v)
        end
    end

    -- 检查是否超出数量限制
    self:CheckRecentNumLimit(self.RecentTeamRoleIDs, MaxRecentTeamNum)

    self:SaveRecentInfoInternal(ClientSetupID.FriendRecentTeam, self.RecentTeamRoleIDs)
end

---刷新最近聊天玩家信息
function FriendVM:RefreshRecentChatInfo()
    -- 私聊会话列表
    local VMList = ChatMgr:GetPrivateItemVMList()
    if nil == VMList or VMList:Length() <= 0 then
        return
    end

    -- 过滤掉好友和黑名单玩家
    local RoleIDs = {}
    local Items = VMList:GetItems()

    for _, v in ipairs(Items) do
        local RoleID = v.RoleID
        if nil ~= RoleID and not self:IsAreadyFriend(RoleID) and not self:IsInBlackList(RoleID) then
            table.insert(RoleIDs, RoleID)

            if #RoleIDs >= MaxRecentChatNum then
                break
            end
        end
    end

    self.RecentChatRoleIDs = RoleIDs
    self:SaveRecentInfoInternal(ClientSetupID.FriendRecentChat, RoleIDs)
end

---检查最近信息（排除好友、黑名单）
function FriendVM:CheckRecentInfo()
    self:UpdateRecentInfo(ClientSetupID.FriendRecentTeam, self.RecentTeamRoleIDs)
    self:UpdateRecentInfo(ClientSetupID.FriendRecentChat, self.RecentChatRoleIDs)
end

-------------------------------------------------------------------------------------------------------
---主界面侧标拦（好友申请）

function FriendVM:AddRequestItem( RoleID )
    if nil == RoleID or self.RejectFriendRequest then
        return
    end

    local Item = table.find_by_predicate(self.NewFriendRequestList, function(item) return item.RoleID == RoleID end)
    if Item then
        return
    end

    RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
        if nil == RoleVM then
            return
        end

        local Info = { RoleID = RoleVM.RoleID, Name = RoleVM.Name or "" }
        table.insert(self.NewFriendRequestList, Info)

        if #self.NewFriendRequestList == 1 then
            self:TryAddSidebarItem()
        end
    end)
end

function FriendVM:RemoveRequestItem( RoleID )
    table.remove_item(self.NewFriendRequestList, RoleID, "RoleID")
end

function FriendVM:IsHaveNewRequest()
    return self.NewFriendRequestList and #self.NewFriendRequestList > 0
end

function FriendVM:TryAddSidebarItem( )
    if not self:IsHaveNewRequest() then
        return
    end

    if SidebarMgr:GetSidebarItemVM(SidebarType) ~= nil then
        return
    end

	if _G.PWorldMgr:CurrIsInDungeon() then
        return
    end

    local StartTime = TimeUtil.GetServerTime()
    SidebarMgr:AddSidebarItem(SidebarType, StartTime)
end

-------------------------------------------------------------------------------------------------------
--- 小红点

---更新好友申请小红点
function FriendVM:UpdateApplyAddFriendRedDot( )
    local ApplyList = self.FriendApplyVMList
    if ApplyList then
        RedDotMgr:SetRedDotNodeValueByID(RedDotID.ApplyList, ApplyList:Length())
    end
end

-------------------------------------------------------------------------------------------------------
--- 设置 

function FriendVM:SetRejectFriendRequest(b)
    self.RejectFriendRequest = b 

    -- 清理侧边栏
    if b then
        self.NewFriendRequestList = {}
        SidebarMgr:RemoveSidebarItem(SidebarType)
    end
end

-------------------------------------------------------------------------------------------------------
--- 平台好友

--- 更新平台好友数据
function FriendVM:UpdatePlatformFriendItemVMList()
    local VMList = self.PlatformFriendItemVMList
    VMList:Clear()

    local ServerFriends = _G.LoginMgr.AllFriendServers 
    if nil == ServerFriends or #ServerFriends <= 0 then
        self.ShowingPlatformFriendItemVMList:Clear()
        self:UpdatePlatformFriendListState()
        return
    end

    local PlatformFriendList = {}
    local ReqRoleIDs = {}
    local InvitedPlayerMap = self.PlatformInvitedPlayerMap 

    for _, v in ipairs(ServerFriends) do
        local Role = v.Role or {}
        local RoleID = tonumber(Role.RoleID)
        if RoleID then
            table.insert(ReqRoleIDs, RoleID)
            table.insert(PlatformFriendList, {
                PlatformName = v.Name, 
                RoleID = RoleID, 
                IsInvited = InvitedPlayerMap[RoleID] == true,
            })
        end
    end

	FLOG_INFO("[FriendVM] UpdatePlatformFriendItemVMList, %s", table.concat(ReqRoleIDs, ", "))

    local QueryCallBack = function()
        VMList:UpdateByValues(PlatformFriendList)

        self.ShowingPlatformFriendItemVMList:Update(VMList:GetItems(), PlayerItemSortFunc)
        self:UpdatePlatformFriendListState()
    end

    if #ReqRoleIDs > 0 then
        RoleInfoMgr:QueryRoleSimples(ReqRoleIDs, QueryCallBack, nil, false)

    else
        QueryCallBack()
    end
end

--- 通过组合名关键词过滤
---@param Keyword string @关键词 
function FriendVM:FilterPlatformFriendByKeyword( Keyword )
    local PlatformFriendItems = self.PlatformFriendItemVMList:GetItems()

    local FilterList = {}

    for _, v in ipairs(PlatformFriendItems) do
        local Name = v.PlayerName
        if Name then
            local Pattern = CommonUtil.ReviseRegexSpecialCharsPattern(Keyword)
            if string.find(Name, Pattern) then
                table.insert(FilterList, v)
            end
        end
    end

	self.PlatformKeyword = Keyword
    self:CheckItemsSortPriority(FilterList)

    self.ShowingPlatformFriendItemVMList:Update(FilterList, PlayerItemSortFunc)
    self:UpdatePlatformFriendListState()
end

function FriendVM:UpdatePlatformFriendRoleInfos()
    local VMList = self.PlatformFriendItemVMList
    local Items = VMList:GetItems()

    -- Fixed 初始查询角色信息超时，导致数据未初始化
    local ServerFriends = _G.LoginMgr.AllFriendServers or {}
    if #ServerFriends ~= #Items then
        self:UpdatePlatformFriendItemVMList()
        return
    end

    local ReqRoleIDs = {}

    for _, v in ipairs(Items) do
        local RoleID = v.RoleID
        if RoleID then
            table.insert(ReqRoleIDs, RoleID)
        end
    end

    if #ReqRoleIDs <= 0 then
        return
    end

    RoleInfoMgr:QueryRoleSimples(ReqRoleIDs, function()
		for _, v in ipairs(Items) do
			local RoleVM = RoleInfoMgr:FindRoleVM(v.RoleID)
			if RoleVM then
				v:UpdateRoleInfo(RoleVM)
			end
		end

        self.ShowingPlatformFriendItemVMList:Sort(PlayerItemSortFunc)
    end, nil, false)
end

function FriendVM:UpdatePlatformFriendListState()
    local State = ListState.Normal 

    if self.ShowingPlatformFriendItemVMList:Length() <= 0 then
        State = string.isnilorempty(self.PlatformKeyword) and ListState.NoFriend or ListState.SearchEmpty
    end

    self.PlatformFriendListState = State
end

function FriendVM:ClearPlatformFriendFilterData()
	self.PlatformKeyword = ""

    local PlatformFriendItems = self.PlatformFriendItemVMList:GetItems()
    self:CheckItemsSortPriority(PlatformFriendItems, false)

    self.ShowingPlatformFriendItemVMList:Update(PlatformFriendItems, PlayerItemSortFunc)
    self:UpdatePlatformFriendListState()
end

function FriendVM:AddPlatformInvitedPlayer(RoleID)
    if nil == RoleID then
        return
    end

    self.PlatformInvitedPlayerMap[RoleID] = true

    local ItemVM = self.PlatformFriendItemVMList:Find(function(Item) return Item.RoleID == RoleID end)  
    if ItemVM then
        ItemVM:SetIsInvited(true)
    end
end

-------------------------------------------------------------------------------------------------------

return FriendVM