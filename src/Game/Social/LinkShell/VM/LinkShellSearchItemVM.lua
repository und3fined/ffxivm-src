---
--- Author: xingcaicao
--- DateTime: 2023-08-10 16:48
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LinkshellCfg = require("TableCfg/LinkshellCfg")
local UIBindableList = require("UI/UIBindableList")
local LinkShellActivityVM = require("Game/Social/LinkShell/VM/LinkShellActivityVM")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")
local LinkshellDefineCfg = require("TableCfg/LinkshellDefineCfg")
local TimeUtil = require("Utils/TimeUtil")

local LSTR = _G.LSTR
local RECRUITING_SET = LinkShellDefine.RECRUITING_SET

---@field ID numebr @通讯贝ID
---@field Name string @通讯贝名称
---@field IsShowJoinBtn boolean @成员是否满员
---@field Manifesto string @宣言
---@field MemNum number @成员数量
---@field MemDesc string @成员描述
---@field MaxMemNum number @成员最大数量
---@field StrTips string @提示
---@field IsAllowPrivateChat boolean @是否允许私聊
---@field RecruitSet cslinkshells.RECRUITING_SET @招募设置
---@field ActVMList UIBindableList @活动VM列表
---@class LinkShellSearchItemVM : UIViewModel
local LinkShellSearchItemVM = LuaClass(UIViewModel)

function LinkShellSearchItemVM:Ctor( )
    self.ID             = nil
    self.Name           = ""
    self.IsShowJoinBtn  = false 
    self.Manifesto      = ""
    self.MemNum         = 0
    self.MemDesc        = ""
    self.StrTips        = ""
    self.RecruitSet     = RECRUITING_SET.SET_UNKNOWN
    self.IsSortPriority = false -- 是否排序优先
    self.IsAllowPrivateChat = false
    self.CreatorRoleID = nil
    self.IsApplyCD = nil 

    self.MaxMemNum = LinkshellDefineCfg:GetMemMaxNum()
    self.ActVMList = UIBindableList.New(LinkShellActivityVM) 
end

function LinkShellSearchItemVM:UpdateBySearchValue(Value)
    local MaxMemNum = self.MaxMemNum
    local Recruiting = Value.Recruiting

    self.ID         = Value.ID
    self.Name       = Value.Name
    self.MemNum     = Value.MemNum or 0
    self.Manifesto  = Value.Manifesto or ""
    self.MemDesc    = string.format("%s/%s", self.MemNum, MaxMemNum)
    self.RecruitSet = Recruiting or RECRUITING_SET.SET_UNKNOWN
    self.IsSortPriority = false
    self.IsAllowPrivateChat = Value.PrivateChatSet == 1
    self.CreatorRoleID = Value.CreatorID

    self:UpdateApplyTime(Value.AppJoinTime)

    if self.MemNum >= MaxMemNum then
        self.StrTips = LSTR(40093) -- "人员已满"
        self.IsShowJoinBtn = false 

    else
        if Recruiting == RECRUITING_SET.INVITE then
            self.StrTips = LSTR(40094) -- "仅可邀请加入"
            self.IsShowJoinBtn = false 

        else
            self.StrTips = ""
            self.IsShowJoinBtn = true 
        end
    end

    --活动列表
    local Events = Value.Events or {}
    local ActData = {}

    for _, v in ipairs(Events) do
        local Cfg = LinkshellCfg:FindCfgByKey(v)
        if Cfg then
            table.insert(ActData, {ID = Cfg.ID, Icon = Cfg.Icon, Desc = Cfg.Desc})
        end
    end

    self.ActVMList:UpdateByValues(ActData, function(lhs, rhs)
        return lhs.ID < rhs.ID 
    end)
end

function LinkShellSearchItemVM:SetSortPriority(b)
    self.IsSortPriority = b == true
end

function LinkShellSearchItemVM:UpdateApplyTime(Time)
    local CDTime = self.ApplyCD
    if nil == CDTime then
        CDTime = LinkshellDefineCfg:GetLinkShellApplyCD()
        self.ApplyCD = CDTime
    end

    Time = Time or 0
    local CurTime = TimeUtil.GetServerTime()
    self.IsApplyCD = (CDTime + Time) > CurTime
end

function LinkShellSearchItemVM:SetIsFull(b)
    if not b then
        return
    end

    local MaxMemNum = self.MaxMemNum
    self.MemNum = MaxMemNum 
    self.IsShowJoinBtn = false 

    self.StrTips = LSTR(40093) -- "人员已满"
    self.MemDesc = string.format("%s/%s", MaxMemNum, MaxMemNum)
end

return LinkShellSearchItemVM