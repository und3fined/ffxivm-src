local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

local ProfUtil = require("Game/Profession/ProfUtil")
local RaceCfg = require("TableCfg/RaceCfg")

local LoginRoleRaceGenderVM = require("Game/LoginRole/LoginRoleRaceGenderVM")

---@class LoginRoleTribePageVM : UIViewModel
local LoginRoleTribePageVM = LuaClass(UIViewModel)


function LoginRoleTribePageVM:Ctor()
    self.TribeName = ""
    self.TribeDesc = ""
    self.TribeNameList = {}
    self.RefreshUI = false
	self:SetNoCheckValueChange("RefreshUI", true)

    --该阶段的数据
    self.RaceListByRaceAndGender = {}   --按种族ID和性别过滤出来的所有cfg，也就是说有部族
    self.RaceID = 0
    self.Gender = 0
    self.TribeID = 0
    self.CurrentSelectIndex = 0
    self.NeedReCreateActor = true
    --该阶段的数据
    
    self.RaceDescLogo = ""
    self.TribeIcon1 = ""
    self.TribeIcon2 = ""
end

function LoginRoleTribePageVM:OnInit()
    self.RaceListByRaceAndGender = {}   --按种族ID和性别过滤出来的所有cfg，也就是说有部族
    self.RaceID = 0
    self.Gender = 0
    self.TribeID = 0
    self.CurrentSelectIndex = 0
end

function LoginRoleTribePageVM:OnBegin()
end

function LoginRoleTribePageVM:OnEnd()
end

function LoginRoleTribePageVM:OnShutdown()
end

function LoginRoleTribePageVM:DiscardData()
    FLOG_INFO("LoginRoleTribePageVM:DiscardData")
    self.TribeNameList = {}
    self.RaceListByRaceAndGender = {}

    self.RaceID = 0
    self.Gender = 0
    self.CurrentSelectIndex = 0
    self.TribeID = 0
    self.NeedReCreateActor = true
end

--可以不用做啥了，选种族界面的时候，会FilterAllCfgByRaceIDAndGender（集中提前做，反而增加了开销）
--而FilterAllCfgByRaceIDAndGender完全根据LoginRoleRaceGenderVM中的数据做依据的
function LoginRoleTribePageVM:Restore()
end

--第2阶段view onshow的时候会过来
--第一次过来、跳转过来、回到第一阶段改完种族过来
function LoginRoleTribePageVM:FilterAllCfgByRaceIDAndGender()
    if LoginRoleRaceGenderVM.CurrentRaceCfg then
        --种族变了，才更新部族，否则同一种族下，不同性别的时候，部族还保持，不清
        if self.RaceID == LoginRoleRaceGenderVM.CurrentRaceCfg.RaceID and
            self.Gender == LoginRoleRaceGenderVM.CurrentRaceCfg.Gender then
            FLOG_INFO("LoginRoleTribePageVM FilterAllCfgByRaceIDAndGender, don't need filter")

            if self.TribeID ~= LoginRoleRaceGenderVM.CurrentRaceCfg.Tribe then
                for index = 1, #self.RaceListByRaceAndGender do
                    local Cfg = self.RaceListByRaceAndGender[index]
                    if Cfg.Tribe == LoginRoleRaceGenderVM.CurrentRaceCfg.Tribe then
                        self.CurrentSelectIndex = index
                        break
                    end
                end
        
                self:SelectTribe(self.CurrentSelectIndex)
            end

            return
        end

        local TribeNameTab = {}
        self.RaceListByRaceAndGender = {}

        -- local SearchConditions = string.format("Gender == %d", LoginRoleTribePageVM:GetGender())
        local RaceList = RaceCfg:FindAllCfg()--SearchConditions)
        if RaceList then
            for index = 1, #RaceList do
                local Cfg = RaceList[index]
                if Cfg.RaceID == LoginRoleRaceGenderVM.CurrentRaceCfg.RaceID and
                    Cfg.Gender == LoginRoleRaceGenderVM.CurrentRaceCfg.Gender then
                    table.insert(self.RaceListByRaceAndGender, Cfg)
                    table.insert(TribeNameTab, Cfg.TribeName)
                end
            end
        end
    
        self.RaceID = LoginRoleRaceGenderVM.CurrentRaceCfg.RaceID
        self.Gender = LoginRoleRaceGenderVM.CurrentRaceCfg.Gender
        self.TribeNameList = TribeNameTab

        --先默认为1； 如果种族变了，则肯定匹配不到，所以会默认选第一个种族
        if self.CurrentSelectIndex < 1 then
            self.CurrentSelectIndex = 1
        end

        for index = 1, #self.RaceListByRaceAndGender do
            local Cfg = self.RaceListByRaceAndGender[index]
            if Cfg.Tribe == LoginRoleRaceGenderVM.CurrentRaceCfg.Tribe then
                self.CurrentSelectIndex = index
                break
            end
        end

        self:SelectTribe(self.CurrentSelectIndex)
    else
        FLOG_ERROR("LoginRoleTribePageVM:Filter Tribe error, CurrentRaceCfg is nil")
    end
end

function LoginRoleTribePageVM:SelectTribe(SelectIndex)
    if not SelectIndex or not self.RaceListByRaceAndGender[SelectIndex] then
        FLOG_ERROR("LoginRoleTribePageVM nil SelectIndex:%d", tostring(SelectIndex))
        return 
    end

    self.CurrentSelectIndex = SelectIndex
    self.TribeID = self.RaceListByRaceAndGender[SelectIndex].Tribe

    LoginRoleRaceGenderVM.bUseCfgTribe = false
    LoginRoleRaceGenderVM:SelectRoleSetCurrentRaceCfg(self.RaceListByRaceAndGender[SelectIndex])

    self.RaceDescLogo = LoginRoleRaceGenderVM.CurrentRaceCfg.RaceDescLogo

    FLOG_INFO("Login SelectTribe : %s Tribe:%s, Gender:%d"
        , LoginRoleRaceGenderVM.CurrentRaceCfg.RaceName
        , LoginRoleRaceGenderVM.CurrentRaceCfg.TribeName
        , LoginRoleRaceGenderVM.CurrentRaceCfg.Gender)

    self.TribeName = self.RaceListByRaceAndGender[SelectIndex].TribeName
    self.TribeDesc = self.RaceListByRaceAndGender[SelectIndex].TribeDesc or "todo"
end

--给捏脸使用的
function LoginRoleTribePageVM:ChangeRenderActor(RaceID, TribeID, Gender)
    self:FilterAllCfgByRaceIDAndGender()
    self.RefreshUI = true
    self.RefreshUI = false  --刷新过后立即恢复
end

return LoginRoleTribePageVM