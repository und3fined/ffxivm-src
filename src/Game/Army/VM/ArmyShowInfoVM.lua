---
--- Author: daniel
--- DateTime: 2023-03-07 16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ArmyDefine = require("Game/Army/ArmyDefine")
local GrandCompanyCfg = require("TableCfg/GrandCompanyCfg")
-- 计数器
local RecursionDepth1 = 0
local RecursionDepth2 = 0


---@class ArmyShowInfoVM : UIViewModel
---@field CaptainName string @部队长名字
---@field ArmyID number @部队ID
---@field Slogan string @招募标语
---@field UnionIcon string @联盟图标
---@field UnionBGIcon string @联盟背景图标
---@field BadgeData table @徽章数据
local ArmyShowInfoVM = LuaClass(UIViewModel)
---Ctor
function ArmyShowInfoVM:Ctor()
    self.CaptainName = nil
    self.ArmyID = nil
    self.Slogan = nil
    self.UnionIcon = nil
    self.BadgeData = nil
    self.UnionBGIcon = nil
    self.LeaderID = nil
    self.GrandCompanyType = nil
    self.ArmyName = nil
    self.ArmyShortName = nil
    self.bShowArmyLeader =  nil
    self.IsRoleQueryFinish = nil
end

function ArmyShowInfoVM:OnInit()
end

function ArmyShowInfoVM:OnBegin()
end

function ArmyShowInfoVM:OnEnd()
end

function ArmyShowInfoVM:OnShutdown()
end

--- 设置Info信息
---@param LeaderID number @部队长ID
---@param Type number @联盟类别
---@param ArmyID number @部队ID
---@param Slogan string @招募标语 or 公告（部队信息界面显示）
function ArmyShowInfoVM:SetData(LeaderID, Type, ArmyID, Slogan, BadgeData, ArmyName, ArmyShortName)
    RecursionDepth2 = RecursionDepth2 + 1
    if RecursionDepth2 > 5 then
        _G.FLOG_INFO(string.format("堆栈溢出排查日志，LeaderID:%s, Type:%s, ArmyID:%s, Slogan:%s, BadgeData:%s, ArmyName:%s, ArmyShortName:%s", LeaderID, Type, ArmyID, Slogan, BadgeData, ArmyName, ArmyShortName))
    end
    self.LeaderID = LeaderID
    self.ArmyID = ArmyID
    self.ArmyName = ArmyName or ""
    self.ArmyShortName =string.format("<%s>",ArmyShortName) or ""
    self.Slogan = Slogan
    self.GrandCompanyType = Type
    local Cfg = GrandCompanyCfg:FindCfgByKey(Type)
    if Cfg then
        self.UnionIcon = Cfg.Icon
        self.UnionBGIcon = Cfg.BgIcon
    end
    self:SetBadgeData(
        BadgeData or
            {
                TotemID = 0,
                IconID = 0,
                BackgroundID = 0
            }
    )
    self:SetIsRoleQueryFinish(false)
    -- LSTR string:查询中...
    --self.CaptainName = LSTR(910168)
    ---有缓存先用缓存显示
    local CacheRoleVM = _G.RoleInfoMgr:FindRoleVM(LeaderID)
    if CacheRoleVM then
        self.CaptainName = CacheRoleVM.Name
    end
    local function Callback(_, RoleVM)
        ---防止高延迟回包时，已切换部队
        if RoleVM.RoleID == self.LeaderID then
		    self.CaptainName = RoleVM.Name
        end
        self:SetIsRoleQueryFinish(true)
	end
    _G.RoleInfoMgr:QueryRoleSimple(LeaderID, Callback, self, false)
    RecursionDepth2 = 0
end

function ArmyShowInfoVM:SetBadgeData(BadgeData)
    RecursionDepth1 = RecursionDepth1 + 1
    if RecursionDepth1 > 5 then
        _G.FLOG_INFO(string.format("堆栈溢出排查日志，TotemID:%s, IconID:%s, BackgroundID:%s", BadgeData.TotemID, BadgeData.IconID, BadgeData.BackgroundID))
    end
    self.BadgeData = BadgeData
    RecursionDepth1 = 0
end

function ArmyShowInfoVM:SetIsShowArmyLeader(IsShowArmyLeader)
    self.bShowArmyLeader = IsShowArmyLeader
end

function ArmyShowInfoVM:GetLeaderID()
    return self.LeaderID
end

function ArmyShowInfoVM:SetIsRoleQueryFinish(IsRoleQueryFinish)
    self.IsRoleQueryFinish = IsRoleQueryFinish
end

function ArmyShowInfoVM:GetIsRoleQueryFinish()
    return self.IsRoleQueryFinish
end

function ArmyShowInfoVM:GetArmyName()
    return self.ArmyName
end

function ArmyShowInfoVM:GetArmyShortName()
    return self.ArmyShortName
end

function ArmyShowInfoVM:GetCaptainName()
    return self.CaptainName
end

return ArmyShowInfoVM
