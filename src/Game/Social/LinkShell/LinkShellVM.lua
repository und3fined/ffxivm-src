---@author: wallencai(蔡文超) 2022-07-15 14:40:23
---@通讯贝的数据管理&和视图层绑定的数据

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LinkShellMemVM = require("Game/Social/LinkShell/VM/LinkShellMemVM")
local LinkShellMemGroupVM = require("Game/Social/LinkShell/VM/LinkShellMemGroupVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LinkShellItemVM = require("Game/Social/LinkShell/VM/LinkShellItemVM")
local LinkShellSearchItemVM = require("Game/Social/LinkShell/VM/LinkShellSearchItemVM")
local LinkShellNewsItemVM = require("Game/Social/LinkShell/VM/LinkShellNewsItemVM")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")
local TimeUtil = require("Utils/TimeUtil")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local LinkshellDefineCfg = require("TableCfg/LinkshellDefineCfg")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local SocialDefine = require("Game/Social/SocialDefine")

local LSTR = _G.LSTR
local RECRUITING_SET = LinkShellDefine.RECRUITING_SET
local LINKSHELL_IDENTIFY = LinkShellDefine.LINKSHELL_IDENTIFY
local SidebarType = SidebarDefine.SidebarType.LinkShellInvite
local MemGroupType = LinkShellDefine.MemGroupType
local IdentifyToMemType = LinkShellDefine.IdentifyToMemType
local MaxActNum = LinkShellDefine.MaxActNum
local MaxScreenActNum = LinkShellDefine.MaxScreenActNum
local RedDotID = SocialDefine.RedDotID

---通讯贝排序算法
local ItemListSortFunc = function(lhs, rhs)
    if lhs.Type ~= rhs.Type then
        return lhs.Type > rhs.Type
    end

    -- 置顶 
    if lhs.IsStick ~= rhs.IsStick then
        return lhs.IsStick == true
    end

    return lhs.Time < rhs.Time
end

---通讯贝成员类型排序算法
local LinkShellMemTypeSortFunction = function(MemTypeA, MemTypeB)
    return MemTypeA.Type < MemTypeB.Type
end

--- 通讯贝成员排序列表
local LinkShellReqMemSortFunction = function(MemA, MemB)
    return MemA.ReqTime < MemB.ReqTime
end

local SearchMemSortFunction = function(lhs, rhs)
    -- 排序是否优先
    if lhs.IsSortPriority ~= rhs.IsSortPriority then
        return lhs.IsSortPriority
    end

    if lhs.MemNum ~ rhs.MemNum then
        return lhs.MemNum > rhs.MemNum
    end

    return lhs.ID > rhs.ID
end

---@class LinkShellVM : UIViewModel
local LinkShellVM = LuaClass(UIViewModel)

function LinkShellVM:Ctor()

end

function LinkShellVM:OnInit()
    self:Reset()
end

function LinkShellVM:OnBegin()
end

function LinkShellVM:OnEnd()
end

function LinkShellVM:OnShutdown()
    self:Reset()
end

function LinkShellVM:Reset()
    self.NewInviteList = {}
    self.ApplyJoinTotalNum = 0
    self.CurLinkShellID = nil
    self.CurLinkShellIdentify = nil 
    self.MoreMemVM = nil -- 更多操作按钮所对应的成员VM
    self.CurMoreMemberItem = nil 

    self.IsShowJoinedEmptyTips = true
    self.IsShowInvitedEmptyTips = true
    self.FindKeyword = nil
    self.IsEmptySearchList = false 
    self.IsEmptyNews = true -- 动态是否为空
    self.IsShowCannotJoin = false 
    self.IsScreening = false
    self.ScreenActIDs = {} 

    self.IsChangingIdentify = false

    self.LinkShellItemVMList = self:ResetBindableList(self.LinkShellItemVMList, LinkShellItemVM)
    self.LinkShellInvitedItemVMList = self:ResetBindableList(self.LinkShellInvitedItemVMList, LinkShellItemVM)
    self.NewsItemVMList = self:ResetBindableList(self.NewsItemVMList, LinkShellNewsItemVM)
    self.PartNewsItemVMList = self:ResetBindableList(self.PartNewsItemVMList)
    self.LinkShellMemTreeVMList = self:ResetBindableList(self.LinkShellMemTreeVMList, LinkShellMemGroupVM)
    self.LinkShellApplyVMList = self:ResetBindableList(self.LinkShellApplyVMList, LinkShellMemVM)
    self.SearchItemVMList = self:ResetBindableList(self.SearchItemVMList, LinkShellSearchItemVM)
    self.ShowingSearchItemVMList = self:ResetBindableList(self.ShowingSearchItemVMList)

    ------------------------------
    -- 创建
    self.CreateSelectedActIDs = {} -- 创建通讯贝选择的活动ID列表

    -- 通讯贝管理
    self.MgSelectedActIDs = nil -- 活动设置选择的活动ID列表
    self.MgRecruitSet = RECRUITING_SET.AUDIT 
    self.MgIsAllowPrivateChat = false -- 是否允许私聊 
end

function LinkShellVM:ClearTempData()
    self.CurLinkShellID = nil
    self.CurLinkShellIdentify = nil 
    self.MoreMemVM = nil 
    self.CurMoreMemberItem = nil 
    self.IsEmptyNews = true

    self.SearchItemVMList:Clear()
    self.LinkShellMemTreeVMList:Clear()
    self.LinkShellApplyVMList:Clear()
    self.NewsItemVMList:Clear()
    self.PartNewsItemVMList:Clear()
end

---更新通讯贝Item列表
---@param JoinedList table @已加入的通讯贝列表，{ cslinkshells.LinkShellsList, ... }
function LinkShellVM:UpdateLinkShellItemList(JoinedList)
    local VMList = self.LinkShellItemVMList
    if nil == VMList then
        return
    end

    VMList:Clear()

    local CurJoinedNum = 0
    local ApplyTotalNum = 0

    for _, v in ipairs(JoinedList) do
        local ItemVM = LinkShellItemVM.New()
        ItemVM:UpdateByLinkShellsList(v)
        VMList:Add(ItemVM)

        if ItemVM.IsAdmin then
            local ApplyNum = ItemVM.ApplyNum or 0
            if ApplyNum > 0 then
                ApplyTotalNum = ApplyTotalNum + ApplyNum
            end
        end

        CurJoinedNum = CurJoinedNum + 1
    end

    if CurJoinedNum > 0 then
        --添加空Item("创建通讯贝" item)
        local MaxNum = LinkshellDefineCfg:GetLinkShellMaxNum()
        if CurJoinedNum < MaxNum then
            VMList:Add(LinkShellItemVM.New())
        end
    end

    VMList:Sort(ItemListSortFunc)

    self:RefreshJoinedEmptyTipsFlag()

    self.ApplyJoinTotalNum = ApplyTotalNum
    self:UpdateMyLinkShellRedDot()

    EventMgr:SendEvent(EventID.LinkShellListUpdate)
end

---更新受邀通讯贝Item列表
---@param InvitedList table @被邀请加入通讯贝列表，{ cslinkshells.LSBeInviteRecord, ... }
function LinkShellVM:UpdateLinkShellInvitedItemList(InvitedList)
    local VMList = self.LinkShellInvitedItemVMList
    if nil == VMList then
        return
    end

    VMList:Clear()


    for _, v in ipairs(InvitedList) do
        local ItemVM = LinkShellItemVM.New()
        ItemVM:UpdateByInvitedRecord(v)
        VMList:Add(ItemVM)
    end

    VMList:Sort(ItemListSortFunc)
    self:RefreshInvitedEmptyTipsFlag()

    EventMgr:SendEvent(EventID.LinkShellInvitedListUpdate)
end

--- 处理邀请加入通讯贝的通知
---@param Record LSBeInviteRecord 
function LinkShellVM:HandleInviteJoin(Record)
    if nil == Record then
        return
    end

    local LinkShellID = Record.ComGroupID
    if nil == LinkShellID then
        return
    end

    -- 侧边栏
    self:AddInviteItem(LinkShellID, Record.Name, Record.InviterID)

    -- 受邀通讯贝列表
    local VMList = self.LinkShellInvitedItemVMList
    if nil == VMList then
        return
    end

    local ItemVM = VMList:Find(function(Item) return Item.ID == LinkShellID end) 
    if ItemVM then
        return
    end

    ItemVM = LinkShellItemVM.New()
    ItemVM:UpdateByInvitedRecord(Record)
    VMList:Add(ItemVM)

    VMList:Sort(ItemListSortFunc)
    self:RefreshInvitedEmptyTipsFlag()

    EventMgr:SendEvent(EventID.LinkShellInvitedListUpdate, ItemVM)
end

---更新通讯贝详情 
---@param Detail cslinkshells.LinkShellsDetails @通讯贝详情
function LinkShellVM:UpdateLinkShellDetail(Detail)
    local LinkShellID = Detail.ID
    local Predicate = function(Item) return Item.ID == LinkShellID end

    local ItemVM = self.LinkShellItemVMList:Find(Predicate)
    if ItemVM ~= nil then
        ItemVM:UpdateByLinkShellsDetail(Detail)

    else 
        ItemVM = self.LinkShellInvitedItemVMList:Find(Predicate)
        if ItemVM ~= nil then
            ItemVM:UpdateByLinkShellsDetail(Detail)
        end
    end
end

---更新通讯贝修改的信息 
---@param LinkShellID number @通讯贝ID
---@param InfoList table @通讯贝修改信息列表，{ cslinkshells.UpdateDetails, ... }
function LinkShellVM:UpdateLinkShellModifyInfo(LinkShellID, InfoList)
    local ItemVM = self.LinkShellItemVMList:Find(function(Item) return Item.ID == LinkShellID end)
    if nil == ItemVM then
        return
    end

    ItemVM:UpdateByModifyInfo(InfoList)
end

---更改通讯贝收藏状态
---@param LinkShellID number @通讯贝ID
---@param CollectState boolean @通讯贝收藏状态
function LinkShellVM:SetLinkShellCollectState(LinkShellID, CollectState)
    local ItemVM = self.LinkShellItemVMList:Find(function(Item) return Item.ID == LinkShellID end)
    if nil == ItemVM then
        return
    end

    ItemVM.IsCollect = CollectState == true
    self.LinkShellItemVMList:Sort(ItemListSortFunc)
end

---置顶通讯贝
---@param LinkShellID number @通讯贝ID
function LinkShellVM:SetLinkShellStick(LinkShellID)
    if nil == LinkShellID then
        return
    end

    local Items = self.LinkShellItemVMList:GetItems() or {}

    for _, v in ipairs(Items) do
        if v.ID == LinkShellID then
            v.IsStick = true

        else
            v.IsStick = false 
        end
    end

    self.LinkShellItemVMList:Sort(ItemListSortFunc)
end

---创建通讯贝成功，增加新的通讯贝信息
---@param CreateRsp cslinkshells.CreateLinkShellRsp @通讯贝详情
function LinkShellVM:AddLinkShellList(CreateRsp)
    local VMList = self.LinkShellItemVMList
    if nil == VMList then
        return
    end

    local MaxNum = LinkshellDefineCfg:GetLinkShellMaxNum()
    if MaxNum > 1 and VMList:Length() <= 0 then
        --添加空Item("创建通讯贝" item)
        VMList:Add(LinkShellItemVM.New())
    end

    local ItemVM = LinkShellItemVM.New()
    ItemVM:UpdateByCreateRsp(CreateRsp)
    VMList:Add(ItemVM)

    -- 达到上限后，删除空Item (“创建通讯贝”)
    local JoinedItems = VMList:FindAll(function(e) return e:IsJoined() end)
    if #JoinedItems >= MaxNum then
        VMList:RemoveByPredicate(function(Item) return Item.IsEmpty end)
    end

    VMList:Sort(ItemListSortFunc)
    self:RefreshJoinedEmptyTipsFlag()

    EventMgr:SendEvent(EventID.LinkShellListUpdate, ItemVM)
end

---销毁通讯贝
---@param LinkShellID numebr @通讯贝ID
function LinkShellVM:DestroyLinkShell(LinkShellID)
    if nil == LinkShellID then
        return
    end
    
    local VMList = self.LinkShellItemVMList
    if nil == VMList then
        return
    end

    VMList:RemoveByPredicate(function(Item) return Item.ID == LinkShellID end)

    -- 已进入通讯贝为空时，删除空Item (“创建通讯贝”)
    local JoinedItems = VMList:FindAll(function(e) return e:IsJoined() end)
    local CurJoinedNum = #JoinedItems
    if CurJoinedNum <= 0 then
        VMList:RemoveByPredicate(function(Item) return Item.IsEmpty end)

    else
        local EmptyItemVM = VMList:Find(function(Item) return Item.IsEmpty end)
        if nil == EmptyItemVM then
            local MaxNum = LinkshellDefineCfg:GetLinkShellMaxNum()
            if CurJoinedNum < MaxNum then
                --添加空Item("创建通讯贝" item)
                VMList:Add(LinkShellItemVM.New())
            end
        end
    end

    -- 更新小红点
    local ApplyTotalNum = self.ApplyJoinTotalNum
    if ApplyTotalNum > 0 then
        self:UpdateApplyTotalNumAndRedDot()
    end

    self:RefreshJoinedEmptyTipsFlag()

    EventMgr:SendEvent(EventID.LinkShellListUpdate)
    EventMgr:SendEvent(EventID.LinkShellDestory, LinkShellID)
end

---销毁受邀通讯贝
---@param LinkShellID numebr @通讯贝ID
function LinkShellVM:DestroyInvitedLinkShell(LinkShellID)
    if nil == LinkShellID then
        return
    end
    
    local VMList = self.LinkShellInvitedItemVMList
    if nil == VMList then
        return
    end

    VMList:RemoveByPredicate(function(Item) return Item.ID == LinkShellID end)
    self:RefreshInvitedEmptyTipsFlag()

    EventMgr:SendEvent(EventID.LinkShellInvitedListUpdate)
end

---更新本地玩家在指定通讯贝的身份
---@param LinkShellID number @通讯贝ID
---@param Identify LinkShellDefine.LINKSHELL_IDENTIFY @身份
---@return boolean @是否更新成员列表信息
function LinkShellVM:UpdateLocalPlayerIdentify(LinkShellID, Identify)
    local ItemVM = self:QueryLinkShell(LinkShellID)
    if ItemVM then
        local IsAdminOrig = ItemVM.IsAdmin

        ItemVM:UpdateIdentiry(Identify)
        self:UpdateApplyTotalNumAndRedDot()

        if LinkShellID == self.CurLinkShellID then
            self.CurLinkShellIdentify = ItemVM.Identify

            -- 1、现在是创建者身份; 
            -- 2、普通身份和管理员身份变更;
            return ItemVM.IsCreator or (IsAdminOrig ~= ItemVM.IsAdmin)
        end
    end
end

function LinkShellVM:RefreshJoinedEmptyTipsFlag()
    self.IsShowJoinedEmptyTips = self.LinkShellItemVMList:Length() <= 0
end

function LinkShellVM:RefreshInvitedEmptyTipsFlag()
    self.IsShowInvitedEmptyTips = self.LinkShellInvitedItemVMList:Length() <= 0
end

-------------------------------------------------------------------------------------------------------
--- 通讯贝成员 

--- 更新通讯贝成员列表
---@param LinkShellID number @通讯贝ID
---@param Mems table @通讯贝成员列表，{ cslinkshells.LinkShellMember, ... }
function LinkShellVM:UpdateLinkShellMembers(LinkShellID, Mems)
    -- 更新具体通讯贝信息（成员人数）
    local LSItemVM = self:QueryLinkShell(LinkShellID)
    if LSItemVM then
        LSItemVM:UpdateMemNumInfo(Mems)
    end

    if LinkShellID ~= self.CurLinkShellID then
        return
    end

    local ReqRoleIDS = {} 
    local MemTreeVMList = self.LinkShellMemTreeVMList
    MemTreeVMList:Clear()

    for _, v in ipairs(Mems) do
        local Type = IdentifyToMemType[v.Identify]
        local ItemVM = MemTreeVMList:Find(function(Item) return Item.Type == Type end)
        if nil == ItemVM then
            ItemVM = LinkShellMemGroupVM.New(Type)
            MemTreeVMList:Add(ItemVM)
        end

        local Member = LinkShellMemVM.New()
        Member:UpdateByLinkShellMember(v)
        ItemVM:AddMember(Member)

        table.insert(ReqRoleIDS, v.RoleID)
    end

    RoleInfoMgr:QueryRoleSimples(ReqRoleIDS, function()
        local Items = self.LinkShellMemTreeVMList:GetItems()

        for _, v in ipairs(Items) do
            v:UpdateMemsRoleInfo()
        end

        self.LinkShellMemTreeVMList:Sort(LinkShellMemTypeSortFunction)
    end, nil, false)

    EventMgr:SendEvent(EventID.LinkShellRefreshMemList)
end

---修改通讯贝创建者
---@param LinkShellID number @通讯贝ID
---@param TransferRoleID number @受让者角色ID
function LinkShellVM:ModifyLinkShellCreator(LinkShellID, TransferRoleID)
    ---更新本地玩家身份
    self:UpdateLocalPlayerIdentify(LinkShellID, LINKSHELL_IDENTIFY.NORMAL)

    if LinkShellID ~= self.CurLinkShellID then
        return
    end

    local NormalType = MemGroupType.Normal
    local MemTreeVMList = self.LinkShellMemTreeVMList
    local NormalGroup = MemTreeVMList:Find(function(Item) return Item.Type == NormalType end)
    if nil == NormalGroup then
        NormalGroup = LinkShellMemGroupVM.New(NormalType)
        MemTreeVMList:Add(NormalGroup)
        MemTreeVMList:Sort(LinkShellMemTypeSortFunction)
    end

    local AdminType = MemGroupType.Admin
    local AdminGroup = MemTreeVMList:Find(function(Item) return Item.Type == AdminType end)
    if nil == AdminGroup then
        return
    end

    local OtherMem = AdminGroup.MemList:Find(function(Mem) return Mem.RoleID == TransferRoleID end)
    if nil == OtherMem then -- 受让者原来是普通成员
        OtherMem = NormalGroup.MemList:Find(function(Mem) return Mem.RoleID == TransferRoleID end)
        OtherMem:SetIdentiry(LINKSHELL_IDENTIFY.CREATOR)

        -- 将普通玩家加入到管理组名单内
        NormalGroup:RemoveMem(OtherMem)
        AdminGroup:AddMember(OtherMem)
    end

    --本地玩家
    local SelfRoleID = MajorUtil.GetMajorRoleID()
    local SelfMem = AdminGroup.MemList:Find(function(Mem) return Mem.RoleID == SelfRoleID end)
    if SelfMem then
        SelfMem:SetIdentiry(LINKSHELL_IDENTIFY.NORMAL)
        AdminGroup:RemoveMem(SelfMem)
        NormalGroup:AddMember(SelfMem)
    end

    MemTreeVMList:Sort(LinkShellMemTypeSortFunction)
end

--- 更新管理成员信息
---@param LinkShellID number @通讯贝ID
---@param RoleID nunber @设置角色ID 
---@param AppointOrRecall boolean @任命(true)、罢免 (false)
function LinkShellVM:UpdateManageMemberInfo(LinkShellID, RoleID, AppointOrRecall)
    if LinkShellID ~= self.CurLinkShellID then
        return
    end

    -- 更新管理数量
    local ItemVM = self:QueryLinkShell(LinkShellID)
    if ItemVM then
        local Num = ItemVM.AdminNum
        ItemVM:UpdateAdminCount(AppointOrRecall and (Num + 1) or (Num - 1))
    end

    local AdminType = MemGroupType.Admin
    local MemTreeVMList = self.LinkShellMemTreeVMList
    local AdminGroup = MemTreeVMList:Find(function(Item) return Item.Type == AdminType end)
    if nil == AdminGroup then
        return
    end

    local IsUpdateTree = true
    local NormalType = MemGroupType.Normal
    local NormalGroup = MemTreeVMList:Find(function(Item) return Item.Type == NormalType end)
    if nil == NormalGroup then
        NormalGroup = LinkShellMemGroupVM.New(NormalType)
        MemTreeVMList:Add(NormalGroup)
        MemTreeVMList:Sort(LinkShellMemTypeSortFunction)

        IsUpdateTree = false 
    end

    -- 被罢免管理权限
    local MemList = AdminGroup.MemList
    local AdminMem = MemList:Find(function(Mem) return Mem.RoleID == RoleID end)
    if AdminMem and AppointOrRecall == false then
        AdminMem:SetIdentiry(LINKSHELL_IDENTIFY.NORMAL)
        NormalGroup:AddMember(AdminMem)
        AdminGroup:RemoveMem(AdminMem)

        EventMgr:SendEvent(EventID.LinkShellRefreshMemList)
    end

    -- 从普通成员提升为管理员
    MemList = NormalGroup.MemList
    local NormalMem = MemList:Find(function(Mem) return Mem.RoleID == RoleID end)
    if NormalMem and AppointOrRecall == true then
        NormalMem:SetIdentiry(LINKSHELL_IDENTIFY.MANAGER)
        AdminGroup:AddMember(NormalMem)
        NormalGroup:RemoveMem(NormalMem)

        if MemList:Length() == 0 then
            MemTreeVMList:Remove(NormalGroup)
            IsUpdateTree = false 
        end
    end

    if IsUpdateTree then
        MemTreeVMList:OnUpdateList()
    end
end

--- 从通讯贝中移除某个成员
---@param LinkShellID number @通讯贝ID
---@param RoleID number @待移除的成员ID
function LinkShellVM:RemoveMember(LinkShellID, RoleID)
    -- 更新具体通讯贝信息（成员人数）
    local ItemVM = self:QueryLinkShell(LinkShellID)
    if ItemVM then
        ItemVM:UpdateMemCount(ItemVM.MemNum - 1)
    end

    if LinkShellID ~= self.CurLinkShellID then
        return
    end

    local IsUpdateTree = true
    local AdminType = MemGroupType.Admin
    local MemTreeVMList = self.LinkShellMemTreeVMList
    local AdminGroup = MemTreeVMList:Find(function(Item) return Item.Type == AdminType end)
    if AdminGroup then
        AdminGroup:RemoveByRoleID(RoleID)

        if ItemVM then
            ItemVM:UpdateAdminCount(ItemVM.AdminNum - 1)
        end
    end

    local NormalType = MemGroupType.Normal
    local NormalGroup = MemTreeVMList:Find(function(Item) return Item.Type == NormalType end)
    if NormalGroup ~= nil then
        NormalGroup:RemoveByRoleID(RoleID)

        if NormalGroup.MemList:Length() == 0 then
            MemTreeVMList:Remove(NormalGroup)
            IsUpdateTree = false 
        end
    end

    if IsUpdateTree then
        MemTreeVMList:OnUpdateList()
    end
end

-------------------------------------------------------------------------------------------------------
---通讯贝申请列表

--- 更新通讯贝申请列表
---@param LinkShellID number @通讯贝ID
---@param ReqList table @申请列表, { cslinkshells.ReqJoin, ... }
function LinkShellVM:UpdateLinkShellApplyList(LinkShellID, ReqList)
    if nil == LinkShellID or table.is_nil_empty(ReqList) then
        return
    end

    if LinkShellID == self.CurLinkShellID then
        local ReqRoleIDS = {}
        local ApplyVMList = self.LinkShellApplyVMList
        ApplyVMList:Clear()

        for _, v in ipairs(ReqList) do
            local LinkShellMem = LinkShellMemVM.New()
            LinkShellMem:UpdateByReqJoin(v)
            ApplyVMList:Add(LinkShellMem)
            table.insert(ReqRoleIDS, v.RoleID)
        end

        ApplyVMList:Sort(LinkShellReqMemSortFunction)

        RoleInfoMgr:QueryRoleSimples(ReqRoleIDS, function()
            local Items = self.LinkShellApplyVMList:GetItems()

            for _, v in ipairs(Items) do
                local RoleVM = RoleInfoMgr:FindRoleVM(v.RoleID, true)
                if RoleVM ~= nil then
                    v:UpdateRoleInfo(RoleVM)
                end
            end
        end, nil, false)
    end

    -- 更新具体通讯贝信息（申请人数）
    local ItemVM = self:QueryLinkShell(LinkShellID)
    if ItemVM then
        ItemVM:UpdateApplyNum(#ReqList)
    end
end

--- 从申请列表中移除玩家
---@param LinkShellID number @通讯贝ID
---@param RoleID number @被拉黑的玩家ID
function LinkShellVM:RemoveRoleFromApplyList(LinkShellID, RoleID)
    -- 更新具体通讯贝信息（申请人数）
    local ItemVM = self:QueryLinkShell(LinkShellID)
    if ItemVM then
        ItemVM:UpdateApplyNum(ItemVM.ApplyNum - 1)
        self.ApplyJoinTotalNum = math.max(self.ApplyJoinTotalNum - 1, 0)
        self:UpdateMyLinkShellRedDot()
    end

    if LinkShellID == self.CurLinkShellID then
        self.LinkShellApplyVMList:RemoveByPredicate(function(Item) return Item.RoleID == RoleID end)
    end
end

function LinkShellVM:SetCurMoreMemberItem(ItemView, MemVM)
    self.MoreMemVM = MemVM 
    self.CurMoreMemberItem = ItemView
end

-------------------------------------------------------------------------------------------------------
--- 创建 
function LinkShellVM:UpdateCreateSelectedActIDs(ActID)
    if nil == ActID then
        return false
    end

    local IDList = self.CreateSelectedActIDs 
    if nil == IDList then
        return false
    end

    -- 列表已存在ID，就删除
    if table.remove_item(IDList, ActID) then
        EventMgr:SendEvent(EventID.LinkShellCreateSelectedActIDsUpdate)
        return true
    end

    -- 不存在ID，尝试添加
    if #IDList < MaxActNum then
        table.insert(IDList, ActID)
        EventMgr:SendEvent(EventID.LinkShellCreateSelectedActIDsUpdate)
        return true
    else
        MsgTipsUtil.ShowTips(LSTR(40043)) -- "活动数量已达最大限制！"
    end

    return false
end

function LinkShellVM:IsInCreateSelectedAct(ID)
    return nil ~= ID and table.contain(self.CreateSelectedActIDs or {}, ID)
end
-------------------------------------------------------------------------------------------------------
--- 管理 

function LinkShellVM:UpdateMgSelectedActIDs(ActID)
    if nil == ActID then
        return false
    end

    local IDList = self.MgSelectedActIDs 
    if nil == IDList then
        return false
    end

    -- 列表已存在ID，就删除
    if table.remove_item(IDList, ActID) then
        EventMgr:SendEvent(EventID.LinkShellMgSelectedActIDsUpdate)
        return true
    end

    -- 不存在ID，尝试添加
    if #IDList < MaxActNum then
        table.insert(IDList, ActID)
        EventMgr:SendEvent(EventID.LinkShellMgSelectedActIDsUpdate)
        return true
    else
        MsgTipsUtil.ShowTips(LSTR(40043)) -- "活动数量已达最大限制！"
    end

    return false
end

---重置活动设置数据
---@param ActIDs table @活动ID列表
function LinkShellVM:ResetMgSelectedActIDs( ActIDs )
    self.MgSelectedActIDs = ActIDs

    EventMgr:SendEvent(EventID.LinkShellMgSelectedActIDsUpdate)
end

function LinkShellVM:IsInMgSelectedAct(ID)
    return nil ~= ID and table.contain(self.MgSelectedActIDs or {}, ID)
end

function LinkShellVM:ClearMgData()
    self.MgSelectedActIDs = nil
    self.MgRecruitSet = RECRUITING_SET.AUDIT 
    self.MgIsAllowPrivateChat = false 
end

-------------------------------------------------------------------------------------------------------
--- 搜索、筛选 

---更新通讯贝搜索列表
---@param LinkShells table @搜索列表，{ cslinkshells.FindLinkShell, ... }
function LinkShellVM:UpdateSearchItemList(LinkShells)
    local VMList = self.SearchItemVMList
    VMList:Clear()

    for _, v in ipairs(LinkShells) do
        local ItemVM = LinkShellSearchItemVM.New()
        ItemVM:UpdateBySearchValue(v)

        VMList:Add(ItemVM)
    end

    self:UpdateShowingSearchItemList(self.IsShowCannotJoin)
end

function LinkShellVM:UpdateShowingSearchItemList(IsShowCannotJoin)
    self.IsShowCannotJoin = IsShowCannotJoin

    local Items = {}
    if IsShowCannotJoin then
        Items = self.SearchItemVMList:GetItems()
    else
        Items = self.SearchItemVMList:FindAll(function(e) return e.IsShowJoinBtn end)
    end

    -- 设置优先级
    local Keyword = self.FindKeyword
    local IsCheckName = not string.isnilorempty(Keyword)

    for _, v in ipairs(Items) do
        v:SetSortPriority(IsCheckName and (Keyword == v.Name))
    end

    self.ShowingSearchItemVMList:Update(Items, SearchMemSortFunction)

    local IsEmpty = #Items <= 0
    self.IsEmptySearchList = IsEmpty

    if not IsEmpty then
        EventMgr:SendEvent(EventID.LinkShellPlayJoinUpdateListAnim)
    end
end

function LinkShellVM:RemoveSearchItemVM(LinkShellID)
    if nil == LinkShellID then
        return
    end

    local ItemVMList = self.ShowingSearchItemVMList
    if ItemVMList then
        ItemVMList:RemoveByPredicate(function(Item) return Item.ID == LinkShellID end)
    end

    ItemVMList = self.SearchItemVMList
    if ItemVMList then
        ItemVMList:RemoveByPredicate(function(Item) return Item.ID == LinkShellID end)
    end

    EventMgr:SendEvent(EventID.LinkShellListUpdate)
end

--- 更新通讯贝申请信息（时间、满员状态）
---@param LinkShellID number @通讯贝ID
---@param IsFull boolean @通讯贝是否满员
function LinkShellVM:UpdateLinkShellApplyInfo(LinkShellID, IsFull)
    if nil == LinkShellID then
        return
    end

    local ItemVMList = self.ShowingSearchItemVMList
    if ItemVMList then
        local ItemVM = ItemVMList:Find(function(Item) return Item.ID == LinkShellID end)
        if ItemVM then
            local CurTime = TimeUtil.GetServerTime()
            ItemVM:UpdateApplyTime(CurTime)
            ItemVM:SetIsFull(IsFull)
        end
    end
end

function LinkShellVM:UpdateScreenActIDs(ActID)
    if nil == ActID then
        return false
    end

    local IDList = self.ScreenActIDs 
    if nil == IDList then
        return
    end

    -- 列表已存在ID，就删除
    if table.remove_item(IDList, ActID) then
        EventMgr:SendEvent(EventID.LinkShellScreenActUpdate)
        return
    end

    -- 不存在ID，尝试添加
    local CurNum = #IDList
    if CurNum < MaxScreenActNum then
        table.insert(IDList, ActID)
        EventMgr:SendEvent(EventID.LinkShellScreenActUpdate)

    else
        local Fmt = LSTR(40044) -- "当前已选活动偏好 %d/%d"
        local Content = string.format(Fmt, CurNum, MaxScreenActNum)
        MsgTipsUtil.ShowTips(Content)
    end
end

function LinkShellVM:IsInScreenSelectedAct(ID)
    return nil ~= ID and table.contain(self.ScreenActIDs or {}, ID)
end

function LinkShellVM:UpdateIsScreeningState()
    self.IsScreening = #(self.ScreenActIDs or {}) > 0
end

function LinkShellVM:ResetFindScreenData()
    self.IsScreening = false
    self.ScreenActIDs = {} 
end

function LinkShellVM:ClearFindData()
    self.FindKeyword = nil
    self.IsEmptySearchList = false 

    self:ResetFindScreenData()
end

-------------------------------------------------------------------------------------------------------
---通讯贝事件


---更新动态事件Item列表
---@param NewsList table @动态事件列表, { cslinkshells.LinkShellEvent, ... }
function LinkShellVM:UpdateNewsItemList(NewsList)
    local VMList = self.NewsItemVMList
    VMList:UpdateByValues(NewsList, function(lhs, rhs)
        return (lhs.Time or 0) > (rhs.Time or 0)
    end)
    
    local RoleIDMap = {}

    for _, v in ipairs(NewsList) do
        -- 发起者
        local Sender = v.SendID
        if Sender then
            RoleIDMap[Sender] = true
        end

        -- 接收者
        local Receiver = v.RecvID
        if Receiver then
            RoleIDMap[Receiver] = true
        end
    end

    RoleInfoMgr:QueryRoleSimples(table.indices(RoleIDMap), function()
        local Items = self.NewsItemVMList:GetItems()

        for k, v in ipairs(Items) do
            v:UpdateRoleInfo()

            --部分动态事件
            if k <= 1 then
                local NewsVMList = self.PartNewsItemVMList
                NewsVMList:Clear()
                NewsVMList:Add(v)
            end
        end
    end, nil, false)

    self.IsEmptyNews = VMList:Length() <= 0
end

-------------------------------------------------------------------------------------
---主界面侧标拦（通讯贝邀请）
function LinkShellVM:AddInviteItem( LinkShellID, LinkShellName, RoleID )
    if nil == LinkShellID or nil == RoleID then
        return
    end

    local Item = table.find_by_predicate(self.NewInviteList, function(e) return e.LinkShellID == LinkShellID end)
    if Item then
        return
    end

    RoleInfoMgr:QueryRoleSimple(RoleID, function(Params, RoleVM)
        if nil == RoleVM or nil == Params then
            return
        end

        local Info = Params
        Info.RoleID = RoleVM.RoleID
        Info.Name = RoleVM.Name or ""

        table.insert(self.NewInviteList, Info)

        if #self.NewInviteList == 1 then
            self:TryAddSidebarItem()
        end
    end, { LinkShellID = LinkShellID, LinkShellName = LinkShellName or "" })
end

function LinkShellVM:RemoveInviteItem( LinkShellID, RoleID )
    local Num = #self.NewInviteList

    for i = Num, 1, -1 do
        local Item = self.NewInviteList[i]
        if Item and Item.LinkShellID == LinkShellID and Item.RoleID == RoleID then
            table.remove(self.NewInviteList, i)
        end
    end
end

function LinkShellVM:IsHaveNewInvite()
    return self.NewInviteList and #self.NewInviteList > 0
end

function LinkShellVM:TryAddSidebarItem( )
    if not self:IsHaveNewInvite() then
        return
    end

    if SidebarMgr:GetSidebarItemVM(SidebarType) ~= nil then
        return
    end

 	if _G.PWorldMgr:CurrIsInDungeon() then
        return
    end 

    local StartTime = TimeUtil.GetServerTime()

    local Info = self.NewInviteList[1]
    local Params = { RoleID = Info.RoleID, LinkShellID = Info.LinkShellID }

    SidebarMgr:AddSidebarItem(SidebarType, StartTime, nil, Params)
end

-------------------------------------------------------------------------------------------------------
--- 小红点

function LinkShellVM:UpdateApplyTotalNumAndRedDot()
    local VMList = self.LinkShellItemVMList
    if nil == VMList then
        return
    end

    local Num = 0

    for _, v in ipairs(VMList:GetItems()) do
        if v.IsAdmin then
            local ApplyNum = v.ApplyNum or 0
            if ApplyNum > 0 then
                Num = Num + ApplyNum
            end
        end
    end

    self.ApplyJoinTotalNum = Num
    self:UpdateMyLinkShellRedDot()
end

function LinkShellVM:UpdateMyLinkShellRedDot()
    RedDotMgr:SetRedDotNodeValueByID(RedDotID.MyLinkShell, self.ApplyJoinTotalNum or 0)
end

-------------------------------------------------------------------------------------------------------

--- 根据通讯贝ID查询对应的通讯贝
---@param LinkShellID number @通讯贝ID
function LinkShellVM:QueryLinkShell(LinkShellID)
    if nil == LinkShellID then
        return
    end

    return self.LinkShellItemVMList:Find(function(Item) return Item.ID == LinkShellID end)
end

--- 获取通讯贝列表ID的接口
function LinkShellVM:GetLinkShellIDList()
    local Ret = {}
    local Items = self.LinkShellItemVMList:GetItems() or {}

    for _, v in ipairs(Items) do
        if v:IsJoined() then
            table.insert(Ret, v.ID)
        end
    end

    return Ret
end

---获取可邀请通讯贝列表
function LinkShellVM:GetInvitableLinkShellList()
    local Ret = {}

    local Items = self.LinkShellItemVMList:GetItems()

    for _, v in ipairs(Items) do
        if v:IsJoined() then
            if v.RecruitSet == RECRUITING_SET.INVITE then -- 仅支持邀请
                if v.IsAdmin then
                    table.insert(Ret, { ID = v.ID, Name = v.Name })
                end

            else
                table.insert(Ret, { ID = v.ID, Name = v.Name })
            end
        end
    end

    return Ret
end

return LinkShellVM