local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

local ProfUtil = require("Game/Profession/ProfUtil")
local TwelveGodCfg = require("TableCfg/TwelveGodCfg")


---@class LoginRoleGodVM : UIViewModel
local LoginRoleGodVM = LuaClass(UIViewModel)


function LoginRoleGodVM:Ctor()
    self.GodName = _G.LSTR(980052)
    self.GodDesc = _G.LSTR(980052)
    self.GodBGLogo = ""

    --该阶段的数据
    self.CurrentGodCfg = nil
    self.CurrentGodID = 1
    --该阶段的数据
end

function LoginRoleGodVM:OnInit()
    self.TotalProbability = 0
end

function LoginRoleGodVM:OnBegin()
end

function LoginRoleGodVM:OnEnd()
end

function LoginRoleGodVM:OnShutdown()
end

function LoginRoleGodVM:DiscardData()
    FLOG_INFO("LoginRoleGodVM:DiscardData")
    self.CurrentGodCfg = nil
    self.CurrentGodID = 1
end

function LoginRoleGodVM:Restore()
	local SaveData = _G.LoginUIMgr.LoginReConnectMgr.SaveData
    self.CurrentGodID = SaveData.GodID
    
    local GodList = TwelveGodCfg:FindAllCfg()
    if GodList then
        local Cnt = #GodList
        for index = 1, Cnt do
            if GodList[index].GodID == SaveData.GodID then
                self.CurrentGodCfg = GodList[index]
                self:SelectGod(SaveData.GodID, self.CurrentGodCfg)
                break
            end
        end
    end
end

function LoginRoleGodVM:RandomGod(GodID)
    if self.CurrentGodCfg then
        FLOG_WARNING("LoginRoleGodVM:RandomGod already has CurrentGodCfg")
        return self.CurrentGodID
    end

    local GodList = TwelveGodCfg:FindAllCfg()
    if GodList then
        local Cnt = #GodList
        -- body
        self.TotalProbability = self.TotalProbability or 0
        if self.TotalProbability == 0 then
            for index = 1, Cnt do
                FLOG_INFO("Login index:%d, GodID:%d, Probablity:%d"
                    , index, GodList[index].GodID, GodList[index].Probability)
                if GodList[index].Probability > 0 then
                    self.TotalProbability = self.TotalProbability + GodList[index].Probability
                end
            end
        end

        local RandomValue = math.random(1, self.TotalProbability)
        FLOG_INFO("======= Login RandomGod Random[1, %d] = %d ======", self.TotalProbability, RandomValue)

        for index = 1, Cnt do
            if GodList[index].Probability > 0 then
                RandomValue = RandomValue - GodList[index].Probability

                if RandomValue <= 0 or index == Cnt then
                    FLOG_INFO("Login RandomGod  index:%d, ID = %d", index, GodList[index].GodID)
                    self:SelectGod(GodList[index].GodID)
                    break
                end
            end
        end
    end

    return self.CurrentGodID
end

function LoginRoleGodVM:SelectGod(GodID, GodCfg)
    if not GodCfg then
        GodCfg = TwelveGodCfg:FindCfgByKey(GodID)
        if not GodCfg then
            FLOG_ERROR("LoginRoleGodVM, GodID %d isn't config", GodID)
            return
        end
    end

    _G.LoginUIMgr.LoginReConnectMgr:SaveValue("GodID", GodID)

    self.CurrentGodID = GodID
    self.CurrentGodCfg = GodCfg

    self.GodName = GodCfg.Name
    self.GodDesc = GodCfg.Desc
    self.GodBGLogo = GodCfg.GodBGIcon
    FLOG_INFO("LoginRoleGodVM:SelectGod GodID = %d", GodID)
end

function LoginRoleGodVM:GetCurGodCfg()
    if not self.CurrentGodCfg then
        self:RandomGod()
    end

    return self.CurrentGodCfg
end

return LoginRoleGodVM