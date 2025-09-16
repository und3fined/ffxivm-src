local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local SaveKey = require("Define/SaveKey")
local RaceCfg = require("TableCfg/RaceCfg")
local ProfUtil = require("Game/Profession/ProfUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local TwelveGodCfg = require("TableCfg/TwelveGodCfg")
local PworldCfg = require("TableCfg/PworldCfg")
local TimeUtil = require("Utils/TimeUtil")

local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
---@class LoginRoleMainPanelVM : UIViewModel
local LoginRoleMainPanelVM = LuaClass(UIViewModel)

local LoginRoleRaceGenderVM = require("Game/LoginRole/LoginRoleRaceGenderVM")

function LoginRoleMainPanelVM:Ctor()
    self.RoleList = {}
    self.RaceName = ""
    self.TribeName = ""
    self.Birthday = ""
    self.GodName = ""
    self.TitleName = ""
    self.ProfName = ""
    self.AddrInfo = ""
    self.PanelServerVisible = false
    self.OriginalServer = ""
    self.CurServer = ""

    -- Role列表中选择第几个
    self.CurSelectRoleID = 0
    self.CurSelectRoleIdx = 1
    self.CurSelectRoleCfg = nil

    self.MaxRoleCount = 4

    --等待login回包ing
    self.WaitLoginRsping = false
    self.SendRoleLoginReqTime = 0
end

function LoginRoleMainPanelVM:OnInit()
end

function LoginRoleMainPanelVM:OnBegin()
end

function LoginRoleMainPanelVM:OnEnd()
end

function LoginRoleMainPanelVM:OnShutdown()
end

function LoginRoleMainPanelVM:OnShow()
	local RoleSimpleList = _G.LoginMgr.tbRoleSimple
	if nil == RoleSimpleList then 
        FLOG_ERROR("Login No Role, OnShow")
        return 
    end

	local LastLoginRoleID = _G.UE.USaveMgr.GetInt(SaveKey.LastLoginRoleID, 0, false)
    local IsFind = false
    for index = 1, #RoleSimpleList do
        if RoleSimpleList[index].RoleID == LastLoginRoleID then
            self:SelectRole(index, true)
            IsFind = true
            break
        end
    end

    if not IsFind then
        self:SelectRole(1, true)
    end

    local RoleList = table.deepcopy(RoleSimpleList)
    local LeftNum = self.MaxRoleCount - #RoleSimpleList
    if LeftNum > 0 then
        table.insert(RoleList, {})
        -- for index = 1, LeftNum do
            -- table.insert(RoleList, {})
        -- end
    end

    self.RoleList = RoleList
end

function LoginRoleMainPanelVM:GetSelectRoleSimple()
    if self.CurSelectRoleIdx >= 1 and self.CurSelectRoleIdx <= #self.RoleList then
        return self.RoleList[self.CurSelectRoleIdx]
    end

    return nil
end

function LoginRoleMainPanelVM:SelectRole(Index, PassShowModel)
	local RoleSimpleList = _G.LoginMgr.tbRoleSimple
	if nil == RoleSimpleList then 
        FLOG_ERROR("Login No Role")
        return 
    end

    if Index > #RoleSimpleList then
        FLOG_ERROR("Login Index > Num")
        return 
    end

	local RoleSimple = RoleSimpleList[Index]
    if nil == RoleSimple then 
        FLOG_ERROR("Login RoleSimple is nil")
        return 
    end

    FLOG_INFO("LoginRoleMainPanelVM:SelectRole index:%d pass:%s", Index, tostring(PassShowModel))
    self.CurSelectRoleID = RoleSimple.RoleID
    self.CurSelectRoleIdx = Index
	_G.UE.USaveMgr.SetInt(SaveKey.LastLoginRoleID, RoleSimple.RoleID, false)

    local RaceID = RoleSimple.Race
    local RaceConfig = RaceCfg:FindCfgByRaceID(RaceID)
    if RaceConfig and RaceConfig.RaceName then
        if RoleSimple.Gender == ProtoCommon.role_gender.GENDER_MALE then
            self.RaceName = string.format(_G.LSTR(980067), RaceConfig.RaceName)--"%s 男"
        else
            self.RaceName = string.format(_G.LSTR(980068), RaceConfig.RaceName)--"%s 女"
        end
    end

    RaceConfig = RaceCfg:FindCfgByTribeID(RoleSimple.Tribe)
    if RaceConfig then
        self.TribeName = RaceConfig.TribeName
    end
    
    self.Birthday = _G.LoginUIMgr:GetBirthdayStr(RoleSimple.CreateMoon, RoleSimple.CreateStar)

    local GodCfg = TwelveGodCfg:FindCfgByKey(RoleSimple.GodType)
    if GodCfg then
        self.GodName = GodCfg.Name
        self.TitleName = GodCfg.Title
    end

    local ProfName = RoleInitCfg:FindRoleInitProfName(RoleSimple.Prof) or ""
    self.ProfName = string.format(_G.LSTR(980069), RoleSimple.Level, ProfName)--%d级%s
	local Cfg = PworldCfg:FindCfgByKey(RoleSimple.CurrScene)
    if Cfg then
        self.AddrInfo = Cfg.PWorldName
    else
        if RoleSimple.CurrScene then
            FLOG_ERROR("Login RoleSimple.CurrScene %d is nil", RoleSimple.CurrScene)
        end
        
        self.AddrInfo = ""
    end

    self.CurSelectRoleCfg = LoginRoleRaceGenderVM:GetRoleCfgByRoleSimple(RoleSimple)
    LoginRoleRaceGenderVM:SelectRoleSetCurrentRaceCfg(self.CurSelectRoleCfg)

    if not PassShowModel then
        _G.LoginUIMgr:ShowSelectRoleModel()
    end

    local OrignWorldID = _G.LoginMgr:GetWorldID()
    local CurWorldID = RoleSimple.CrossZoneID
    if RoleSimple.CrossZoneID == 0 or OrignWorldID == CurWorldID then
        self.PanelServerVisible = false
        CurWorldID = OrignWorldID
    else
        self.PanelServerVisible = true
        self.OriginalServer = _G.LoginMgr:GetMapleNodeName(OrignWorldID)
    end
    self.CurServer = _G.LoginMgr:GetMapleNodeName(CurWorldID)
end

function LoginRoleMainPanelVM:ClearWaitLoginRspingFlag()
    -- self.WaitLoginRsping = false
end

function LoginRoleMainPanelVM:OnStartBtnClick(bBackOrignServer)
    -- local CurTimeMS = TimeUtil.GetLocalTimeMS()
    -- --做个5s的超时
    -- if CurTimeMS - self.SendRoleLoginReqTime > 5000 then
    --     self.WaitLoginRsping = false
    -- end

    -- if self.WaitLoginRsping then
    --     FLOG_WARNING("WaitLoginRsping")
    --     return 
    -- end

    _G.LoginMapMgr:StopBGM()
    
    FLOG_INFO("Login OnStartBtnClick %d", self.CurSelectRoleID)
	_G.LoginMgr:SendRoleLoginReq(self.CurSelectRoleID, nil, bBackOrignServer)
    -- self.WaitLoginRsping = true
    -- self.SendRoleLoginReqTime = CurTimeMS
end

return LoginRoleMainPanelVM