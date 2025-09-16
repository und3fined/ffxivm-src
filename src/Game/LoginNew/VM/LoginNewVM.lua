---
--- Author: richyczhou
--- DateTime: 2024-06-25 10:43
--- Description:
---

local LoginMgr = require("Game/Login/LoginMgr")
local CommonUtil = require("Utils/CommonUtil")
local LuaClass = require("Core/LuaClass")
local FriendItemVM = require("Game/LoginNew/VM/Item/FriendItemVM")
local SaveKey = require("Define/SaveKey")
local UIBindableList = require("UI/UIBindableList")
local UIViewModel = require("UI/UIViewModel")

local FLOG_INFO = _G.FLOG_INFO
local AccountMgr = _G.UE.UAccountMgr
local USaveMgr = _G.UE.USaveMgr

---@class LoginNewVM : UIViewModel
local LoginNewVM = LuaClass(UIViewModel)

---Ctor
function LoginNewVM:Ctor()
    self.OpenID = nil
    self.WorldID = nil
    self.WorldState = nil
    self.NodeTag = nil
    self.Token = nil
    self.ChannelID = nil

    -- 是否在更新中
    self.ShowUpdating = false
    -- 好友同玩
    self.ShowFriendList = false
    self.FriendList = UIBindableList.New(FriendItemVM)

    -- 是否显示预下载
    self.ShowPreDownloadBtn = false
    self.PreDownloading = false

    -- 是否有公告
    self.ShowNoticeBtn = true

    -- 未登录,等待登录
    self.NoLogin = true
    -- 区服是否正在拉取中
    self.IsMapleDataRequiring = true
    self.ShowStartBtn = false

    -- 协议状态
    self.AgreeProtocol = false
    self.ShowAgreeProtocolGuide = false

    self.DevLogin = false
    self.ShowResearchBtn = not UE.UCommonUtil.IsShipping()

    -- 排队
    self.FakeWaitTotalTime = 0
    self.FakeWaitCountTime = 0
    self.FakeWaitPeople = 0
    self.FakeWaitTotalTimeStr = ""
    self.FakeWaitCountTimeStr = ""

    -- 是否已经首次显示AnimIn入场动画
    self.HasShowAnimIn = false
    self.IsCanRestoreLoginAnim = false
    self.HasLogin = false
end

function LoginNewVM:OnInit()
end

function LoginNewVM:OnBegin()
    self.ShowPreDownloadBtn = false
    self.NeedShowUpdateAgreementView = self:CheckUserAgreementConfigExist()
end

function LoginNewVM:OnEnd()
end

function LoginNewVM:OnShutdown()
end

---SetAgreeProtocol
---@param AgreeProtocol boolean
function LoginNewVM:SetAgreeProtocolNoSave(AgreeProtocol)
    self.AgreeProtocol = AgreeProtocol
    FLOG_INFO("[LoginNewVM:SetAgreeProtocolNoSave] AgreeProtocol:%s", tostring(AgreeProtocol))

    if AgreeProtocol then
        AccountMgr.Get():SetCouldCollectSensitiveInfo(true)
        AccountMgr.Get():SetSensitiveInfo(string.format("{\"Model\" :\"%s\"}", _G.UE.UCommonUtil.GetDeviceModel()))
    else
        AccountMgr.Get():SetCouldCollectSensitiveInfo(false)
    end
end

---SetAgreeProtocol
---@param AgreeProtocol boolean
function LoginNewVM:SetAgreeProtocol(AgreeProtocol)
    self:SetAgreeProtocolNoSave(AgreeProtocol)

    USaveMgr.SetInt(SaveKey.UserAgreementChecked, AgreeProtocol and 1 or 0, false)
end

---GetAgreeProtocol
---@return boolean
function LoginNewVM:GetAgreeProtocol()
    return self.AgreeProtocol
end

function LoginNewVM:GetCurWorldName()
    return LoginMgr:GetMapleNodeName(self.WorldID)
end

function LoginNewVM:UpdateFriendList()
    local FriendIconList = {}
    ---@type ServerFriends
    local FriendServers = LoginMgr.FriendServers
    if FriendServers then
        for _, FriendRoleItem in ipairs(FriendServers) do
            FLOG_INFO("[LoginNewVM:UpdateFriendList] Account name:%s, headUrl:%s, WorldID:%d ---------->", FriendRoleItem.Name, FriendRoleItem.HeadUrl, FriendRoleItem.Role.WorldID)
            local IconUrl = {
                Name = FriendRoleItem.Name,
                IconUrl = FriendRoleItem.HeadUrl,
                WorldID = FriendRoleItem.Role.WorldID,
            }
            table.insert(FriendIconList, IconUrl);

            --local Role = FriendRoleItem.Role
            --FLOG_INFO("Name:%s, \nRoleID:%s, \nWorldID:%d, \nOpenID:%s, \nProf:%d, \nLevel:%d, \nLoginTime:%s, \nHeadPortraitID:%d",
            --        Role.Name, Role.RoleID, Role.WorldID, Role.OpenID, Role.Prof, Role.Level, Role.LoginTime, Role.HeadPortraitID)
        end

        self.ShowFriendList = FriendIconList and #FriendIconList > 0
    end
    self.FriendList:UpdateByValues(FriendIconList)
end

function LoginNewVM:CheckUserAgreementConfigExist()
    if not CommonUtil.IsInternationalChina() then
       return false
    end

    local ConfigModuleName = "Config/UserAgreementUpdateConfig"
    local ProjectDir = UE4.UKismetSystemLibrary.GetProjectDirectory()
    local ConfigPath = string.format("%s/Source/Script/%s.lua", ProjectDir, ConfigModuleName)
    if _G.FDIR_EXISTFILE(ConfigPath) then
        ---@type UserAgreementUpdateConfig
        local Config = require(ConfigModuleName)
        if Config then
            local Version = _G.UE.USaveMgr.GetInt(SaveKey.UserAgreementVersion, 0, false)
            if Version >= Config.Version then
                FLOG_INFO("[LoginNewVM:CheckUserAgreementConfigExist] Has show id in UserAgreementIds...")
                return false
            end

            FLOG_INFO("[LoginNewVM:CheckUserAgreementConfigExist] Version:%d", Config.Version)
            self:SetAgreeProtocol(false)
            self.UserAgreementVersion = Config.Version

            USaveMgr.SetInt(SaveKey.UserAgreementVersion, Config.Version, false)
            return true
        else
            FLOG_INFO("[LoginNewVM:CheckUserAgreementConfigExist] UserAgreementConfig load failed...")
        end
    else
        FLOG_INFO("[LoginNewVM:CheckUserAgreementConfigExist] UserAgreementConfig no exist...")
    end
    return false
end

function LoginNewVM:GetCurWorldName()
    return LoginMgr:GetMapleNodeName(self.WorldID)
end

return LoginNewVM