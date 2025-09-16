---
--- Author: xingcaicao
--- DateTime: 2023-08-08 16:26
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local LinkShellActivityVM = require("Game/Social/LinkShell/VM/LinkShellActivityVM")
local UIBindableList = require("UI/UIBindableList")
local LinkshellCfg = require("TableCfg/LinkshellCfg")
local LinkshellDefineCfg = require("TableCfg/LinkshellDefineCfg")

local LSTR = _G.LSTR
local LinkShellItemType = LinkShellDefine.ItemType
local RECRUITING_SET = LinkShellDefine.RECRUITING_SET
local LINKSHELL_IDENTIFY = LinkShellDefine.LINKSHELL_IDENTIFY

---@field IsEmpty boolean @是否为空Item
---@field Type number @招募Item类型
---@field ID numebr @通讯贝ID
---@field Name string @通讯贝名称
---@field Time number @加入时间（或者邀请时间）
---@field MemNum number @成员数量
---@field AdminNum number @管理数量
---@field MemDesc string @成员描述
---@field MaxMemNum number @成员最大数量
---@field IsStick boolean @是否置顶
---@field IsAllowPrivateChat boolean @是否允许私聊
---@field Identify LinkShellDefine.LINKSHELL_IDENTIFY @身份
---@field IsAdmin boolean @是否是管理
---@field IsCreator boolean @是否是创建者
---@field RecruitSet cslinkshells.RECRUITING_SET @招募设置
---@field ApplyNum number @申请人员数量
---@field Manifesto string @宣言
---@field Notice string @公告
---@field StrTips string @提示
---@field InviterRoleID number @邀请者RoleID
---@field InviterName string @邀请者名
---@field ActVMList UIBindableList @活动VM列表
---@class LinkShellItemVM : UIViewModel
local LinkShellItemVM = LuaClass(UIViewModel)

function LinkShellItemVM:Ctor( )
    self.IsEmpty = true

    self.Type       = LinkShellItemType.Empty 
    self.ID         = nil
    self.Name       = "" 
    self.Time       = 0
    self.MemNum     =  0 
    self.AdminNum   =  0 
    self.MemDesc    = ""
    self.IsStick    = false 
    self.Identify   = LINKSHELL_IDENTIFY.IDENTIFY_UNKNOWN
    self.IsAdmin    = false
    self.IsCreator = false
    self.RecruitSet = RECRUITING_SET.SET_UNKNOWN
    self.ApplyNum   = 0

    self.Manifesto = ""
    self.Notice = ""
    self.StrTips = ""

    self.IsEmptyManifesto = true
    self.IsEmptyAct = true
    self.IsEmptyNotice = true

    self.InviterRoleID = nil 
    self.InviterName = ""

    self.IsAllowPrivateChat = false

    self.MaxMemNum = LinkshellDefineCfg:GetMemMaxNum()
    self.ActVMList = UIBindableList.New(LinkShellActivityVM) 
end

---更新数据（已加入的通讯贝）
---@param Value cslinkshells.LinkShellsList @通讯贝服务器信息 
function LinkShellItemVM:UpdateByLinkShellsList( Value )
    self.IsEmpty = false

    self.Type       = LinkShellItemType.Joined
    self.ID         = Value.ID
    self.Name       = Value.Name or ""
    self.Time       = Value.JoinTime or 0
    self.MemNum     = Value.MemNum or 0
    self.AdminNum   = Value.ManagerNum or 0
    self.IsStick    = Value.IsStick == true
    self.ApplyNum   = Value.ReqJoinNum or 0

    self.IsAllowPrivateChat = Value.PrivateChatSet == 1

    self:UpdateIdentiry(Value.Identify)
    self:UpdateRecruitSet(Value.Recruiting)
    self:UpdateMemDesc()

    self.InviterRoleID = nil 
    self.InviterName = ""
    self.ActVMList:Clear()
end

---更新数据（被邀请加入的通讯贝）
---@param Value cslinkshells.LSBeInviteRecord @通讯贝服务器信息 
function LinkShellItemVM:UpdateByInvitedRecord( Value )
    self.IsEmpty = false

    self.Type   = LinkShellItemType.Invited
    self.ID     = Value.ComGroupID
    self.Name   = Value.Name or ""
    self.Time   = Value.Time or 0
    self.MemNum = Value.MemNum or 0

    self.IsStick= false 
    self.IsAllowPrivateChat = false

    self:UpdateMemDesc()
    self:UpdateStrTips()

    local RoleID = Value.InviterID
    self.InviterRoleID = RoleID 
    self.InviterName = ""
    self.ActVMList:Clear()

    if RoleID then  
        RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
            if RoleVM then
                -- "邀请人：%s"
                self.InviterName = string.format(LSTR(40085), RoleVM.Name or "")
            end
        end, nil, false)
    end
end

---更新数据（创建通讯贝）
---@param Value cslinkshells.CreateLinkShellRsp @通讯贝服务器信息 
function LinkShellItemVM:UpdateByCreateRsp( Value )
    self.IsEmpty = false

    self.Type       = LinkShellItemType.Joined
    self.ID         = Value.LinkShellID
    self.Name       = Value.Name or ""
    self.Time       = TimeUtil.GetServerTime()
    self.MemNum     = 1 
    self.AdminNum   = 1 
    self.IsStick    = false 
    self.IsAllowPrivateChat = Value.PrivateChatSet == 1

    self.InviterRoleID = nil 
    self.InviterName = ""

    self:UpdateManifesto(Value.Manifesto)
    self:UpdateNotice()
    self:UpdateIdentiry(LINKSHELL_IDENTIFY.CREATOR)
    self:UpdateRecruitSet(Value.Recruiting)
    self:UpdateMemDesc()
    self:UpdateActList()
end

---更新数据（通讯贝详情数据）
---@param Value cslinkshells.LinkShellsDetails @通讯贝服务器信息 
function LinkShellItemVM:UpdateByLinkShellsDetail( Value )
    self.Name = Value.Name or ""

    self:UpdateManifesto(Value.Manifesto)
    self:UpdateNotice(Value.Announcement)
    self:UpdateRecruitSet(Value.Recruiting)
    self:UpdateActList(Value.Events)
end

---更新数据（通讯贝修改数据）
---@param Value table @通讯贝修改信息列表，{ cslinkshells.UpdateDetails, ... }
function LinkShellItemVM:UpdateByModifyInfo( Value )
    for _, v in ipairs(Value) do
        --名字
        local Name = v.Name
        if not string.isnilorempty(Name) then
            self.Name = Name
        end

        --招募设置
        local RecruitSet = v.Recruiting 
        if RecruitSet then
            self:UpdateRecruitSet(RecruitSet)
        end

        --主要活动
        local Events = (v.Events or {}).Events
        if Events then
            self:UpdateActList(Events)
        end

        --宣言
        local Manifesto = v.Manifesto 
        if Manifesto then
            self:UpdateManifesto(Manifesto)
        end

        --公告
        local Notice = v.Announcement
        if Notice then
            self:UpdateNotice(Notice)
        end

        -- 允许私聊
        local PrivateChatSet = v.PrivateChatSet
        if PrivateChatSet then
            self.IsAllowPrivateChat = PrivateChatSet == 1
        end
    end
end

---更新身份
function LinkShellItemVM:UpdateIdentiry( Identify )
    self.Identify = Identify -- 身份
    self.IsAdmin = Identify == LINKSHELL_IDENTIFY.CREATOR or Identify == LINKSHELL_IDENTIFY.MANAGER
    self.IsCreator = Identify == LINKSHELL_IDENTIFY.CREATOR

    self:UpdateStrTips()
end

---更新招募设置
function LinkShellItemVM:UpdateRecruitSet( Set )
    self.RecruitSet = Set or RECRUITING_SET.SET_UNKNOWN
end

---更新活动列表
---@param Events table @活动
function LinkShellItemVM:UpdateActList( Events )
    local ActData = {}

    for _, v in ipairs(Events or {}) do
        local Cfg = LinkshellCfg:FindCfgByKey(v)
        if Cfg then
            table.insert(ActData, {ID = Cfg.ID, Icon = Cfg.Icon2, Desc = Cfg.Desc})
        end
    end

    local VMList = self.ActVMList
    VMList:UpdateByValues(ActData, function(lhs, rhs)
        return lhs.ID < rhs.ID 
    end)

    self.IsEmptyAct = VMList:Length() <= 0 
end

function LinkShellItemVM:UpdateMemDesc()
    self.MemDesc = string.format("%s/%s", self.MemNum, self.MaxMemNum)
end

function LinkShellItemVM:UpdateStrTips( )
    if self.Type == LinkShellItemType.Invited then
        self.StrTips = LSTR(40086) -- "邀请加入"
        return

    elseif self.Type == LinkShellItemType.Joined then
        local Num = self.ApplyNum or 0
        if Num > 0 and self.IsAdmin then
            self.StrTips = string.format(LSTR(40087), Num) -- "新申请：%s"
            return
        end
    end

    self.StrTips = ""
end

---更新成员数量信息
---@param Mems table @成员列表
function LinkShellItemVM:UpdateMemNumInfo( Mems )
	local MgrMems = table.find_all_by_predicate(Mems, function(e) 
        local Identify = e.Identify
        return Identify == LINKSHELL_IDENTIFY.CREATOR or Identify == LINKSHELL_IDENTIFY.MANAGER
    end)

    self:UpdateMemCount(#Mems)
    self:UpdateAdminCount(#MgrMems)
end

function LinkShellItemVM:UpdateAdminCount(Num)
    self.AdminNum = Num 
end

function LinkShellItemVM:UpdateMemCount(Num)
    self.MemNum = Num 
    self:UpdateMemDesc()
end

function LinkShellItemVM:UpdateApplyNum( Num )
    Num = math.max(Num, 0)
    self.ApplyNum = Num

    self:UpdateStrTips()
end

function LinkShellItemVM:UpdateManifesto( Text )
    self.Manifesto = Text or ""
    self.IsEmptyManifesto = string.isnilorempty(Text)
end

function LinkShellItemVM:UpdateNotice( Text )
    self.Notice = Text or ""
    self.IsEmptyNotice = string.isnilorempty(Text)
end

---是否已加入
function LinkShellItemVM:IsJoined()
    return self.Type == LinkShellItemType.Joined
end

return LinkShellItemVM