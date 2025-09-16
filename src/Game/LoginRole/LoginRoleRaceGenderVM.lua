local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

local ProfUtil = require("Game/Profession/ProfUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local RaceCfg = require("TableCfg/RaceCfg")

---@class LoginRoleRaceGenderVM : UIViewModel
local LoginRoleRaceGenderVM = LuaClass(UIViewModel)


function LoginRoleRaceGenderVM:Ctor()
    self.RaceName = ""
    self.RaceDesc = ""
    self.RaceNameList = {}
    self.SelectRaceIndex = nil
	self:SetNoCheckValueChange("SelectRaceIndex", true)

    --该阶段的数据
    -- self.RaceID = ProtoCommon.race_type.RACE_TYPE_Hyur  --默认 人族 男
    -- self.Gender = ProtoCommon.role_gender.GENDER_MALE
    self.CurrentRaceCfg = nil   --默认 人族 男 --这个在选部族的时候也会变更
    self.CurrentSelectIndex = 1 --默认 人族 男
    self.CurGender = ProtoCommon.role_gender.GENDER_MALE
    self.LastSelectIndex = 0
    self.bUseCfgTribe = true
    --该阶段的数据

    self.RaceDescLogo = ""
end

function LoginRoleRaceGenderVM:OnInit()
    --[RaceID, RaceList（该种族所有的Cfg，有4个）]
    self.RaceMap = {}
    self.RaceList = {}  --每个种族，只有1个
    --[RaceID, GenderTypes]
    self.GenderTypesMap = {}
    --[RaceID, TotalProbability]
    -- self.TotalProbabilityMap = {}
    
    --以上这些数据，都是持续存在的，不清
end

function LoginRoleRaceGenderVM:OnBegin()
end

function LoginRoleRaceGenderVM:OnEnd()
end

function LoginRoleRaceGenderVM:OnShutdown()
end

function LoginRoleRaceGenderVM:DiscardData()
    FLOG_INFO("LoginRoleRaceGenderVM:DiscardData")
    self.CurrentSelectIndex = 1 --默认 人族 男
    self.CurGender = ProtoCommon.role_gender.GENDER_MALE
    self.CurrentRaceCfg = nil
    self.LastSelectIndex = 0
    self.bUseCfgTribe = true
end

function LoginRoleRaceGenderVM:Restore()
    --莫名其妙脚本报错，重新初始化一次
    self.RaceMap = {}
    self.RaceList = {}
    self.GenderTypesMap = {}
    self.RaceNameList = {}

    self:InitRaceList()
    
	local SaveData = _G.LoginUIMgr.LoginReConnectMgr.SaveData
	local RaceID = SaveData.RaceID
	local Gender = SaveData.Gender
	local TribID = SaveData.TribID

    if self.RaceList then
        for index = 1, #self.RaceList do
            local RaceCfg = self.RaceList[index]
            if RaceCfg and RaceCfg.RaceID == RaceID then
                self.CurrentSelectIndex = index
                break
            end
        end
    end
    
    local RaceList = self.RaceMap[RaceID]
    if RaceList then
        for index = 1, #RaceList do
            local RaceCfg = RaceList[index]
            if RaceCfg and RaceCfg.Gender == Gender and RaceCfg.Tribe == TribID then
                self:SelectRoleSetCurrentRaceCfg(RaceCfg)
                break
            end
        end
    end
    
    self.CurGender = Gender
    self.LastSelectIndex = 0
    self.bUseCfgTribe = true
end

function LoginRoleRaceGenderVM:InitRaceList()
    if #self.RaceNameList > 0 then
        return
    end

    local RaceNameTab = {}

	-- local SearchConditions = string.format("Gender == %d", LoginRoleRaceGenderVM:GetGender())
	local RaceList = RaceCfg:FindAllCfg()--SearchConditions)
    if RaceList then
        for index = 1, #RaceList do
            local RaceCfg = RaceList[index]
            if RaceCfg and RaceCfg.IsCanCreate == 1 then
                self.RaceMap[RaceCfg.RaceID] = self.RaceMap[RaceCfg.RaceID] or {}
                table.insert(self.RaceMap[RaceCfg.RaceID], RaceCfg)
            end
        end

        for _, value in pairs(self.RaceMap) do
            table.insert(self.RaceList, value[1])
            table.insert(RaceNameTab, value[1])
        end
    end

    self.RaceNameList = RaceNameTab
end

function LoginRoleRaceGenderVM:AsyncLoadRaceIcons()
    self:InitRaceList()

    for index = 1, #self.RaceList do
        local RaceCfg = self.RaceList[index]
        if RaceCfg then
            _G.ObjectMgr:LoadObjectAsync(RaceCfg.RaceIcon, 0)

            if index == 1 then
                _G.ObjectMgr:LoadObjectAsync(RaceCfg.RaceIconSelected, 0)
            end
        end
    end
end

--按概率，随机一个性别
function LoginRoleRaceGenderVM:GetGenderByRaceID(RaceID)
    local RaceList = self.RaceMap[RaceID]
    if not RaceList then
        FLOG_ERROR("Login GetGenderByRaceID, RaceList is nil")
        return ProtoCommon.role_gender.GENDER_MALE
    end

    local Cnt = #RaceList
    if Cnt == 0 then
        FLOG_ERROR("Login GetGenderByRaceID, RaceList Cnt = 0")
        return ProtoCommon.role_gender.GENDER_MALE
    end

    -- local TotalProbability = self.TotalProbabilityMap[RaceID] or 0
    local GenderTypes = self.GenderTypesMap[RaceID] or 0   --该种族的性别类型，有的种族只有1个性别
    if GenderTypes == 0 then--or TotalProbability == 0 then
        for index = 1, Cnt do
            FLOG_INFO("Login index:%d, Gender:%d, GenderProbablity:%d"
                , index, RaceList[index].Gender, RaceList[index].GenderProbability)
            if RaceList[index].IsCanCreate == 1 then
                -- TotalProbability = TotalProbability + RaceList[index].GenderProbability

                if RaceList[index].Gender == ProtoCommon.role_gender.GENDER_MALE then
                    GenderTypes = GenderTypes | ProtoCommon.role_gender.GENDER_MALE
                end

                if RaceList[index].Gender == ProtoCommon.role_gender.GENDER_FEMALE then
                    GenderTypes = GenderTypes | ProtoCommon.role_gender.GENDER_FEMALE
                end
            end
        end

        -- self.TotalProbabilityMap[RaceID] = TotalProbability
        self.GenderTypesMap[RaceID] = GenderTypes
    end

    --如果是VM已经记录了，并且
    if self.CurrentRaceCfg and self.CurrentRaceCfg.RaceID == RaceID then
        self:UpdateInfo(self.CurrentRaceCfg)
        return self.CurrentRaceCfg.Gender, GenderTypes
    end

    -- if TotalProbability == 0 then
    --     TotalProbability = 1
    -- end
    
    -- local RandomValue = math.random(1, TotalProbability)
    -- FLOG_INFO("======= Login GetGenderByRaceID Random[1, %d] = %d ======", TotalProbability, RandomValue)

    local bHaveCurGender = false
    local NewGender = self.CurGender
    for index = 1, Cnt do
        if RaceList[index].Gender == NewGender then
            bHaveCurGender = true
            self:SelectRoleSetCurrentRaceCfg(RaceList[index])
            break
        end
    end

    if not bHaveCurGender then
        self:SelectRoleSetCurrentRaceCfg(RaceList[1])
        NewGender = RaceList[1].Gender
        self.CurGender = NewGender
    end

    self:UpdateInfo(self.CurrentRaceCfg)

    FLOG_INFO("Login NewGender:%d, GendersTypes = %d", NewGender, GenderTypes)
	return NewGender, GenderTypes
end

function LoginRoleRaceGenderVM:UpdateInfo(CurrentRaceCfg)
    if CurrentRaceCfg then
        self.RaceName = self.CurrentRaceCfg.RaceName
        self.RaceDesc = self.CurrentRaceCfg.RaceDesc
    end
end

function LoginRoleRaceGenderVM:ChangeGender(NewGender)
    if not self.CurrentRaceCfg then
        return false
    end

    if self.CurrentRaceCfg.Gender == NewGender then
        return false
    end

    self.CurGender = NewGender

    local RaceList = self.RaceMap[self.CurrentRaceCfg.RaceID]
    if RaceList then
        local Tribe = self:GetTribeID()
        for index = 1, #RaceList do
            if RaceList[index].Tribe == Tribe and RaceList[index].Gender == NewGender then
                self:SelectRoleSetCurrentRaceCfg(RaceList[index])
                break
            end
        end
    end
    
    self:UpdateInfo(self.CurrentRaceCfg)

    return true
end

--z1c1星空专用
function LoginRoleRaceGenderVM:GetCurRaceLightAttachType()
    if not self.CurrentRaceCfg then
        return nil
    end

    local RaceList = self.RaceMap[self.CurrentRaceCfg.RaceID]
    if RaceList then
        for index = 1, #RaceList do
            if RaceList[index].Gender == self.CurrentRaceCfg.Gender then
                return self.CurrentRaceCfg.AttachType
            end
        end
    end

    return nil
end

function LoginRoleRaceGenderVM:GetTribeID()
    if self.bUseCfgTribe then
        if not self.CurrentRaceCfg then 
            return -1
        end
        
        return self.CurrentRaceCfg.Tribe
    end

    return _G.LoginRoleTribePageVM.TribeID
end

function LoginRoleRaceGenderVM:GetRoleCfgByRoleSimple(RoleSimple)
    self:InitRaceList()

    local RaceCfg = nil
    local RaceList = self.RaceMap[RoleSimple.Race]
    if RaceList then
        for index = 1, #RaceList do
            if RaceList[index].Tribe == RoleSimple.Tribe 
                and RaceList[index].Gender == RoleSimple.Gender then
                    RaceCfg = RaceList[index]
                break
            end
        end
    end

    return RaceCfg
end

function LoginRoleRaceGenderVM:SelectRoleSetCurrentRaceCfg(CurCfg)
    -- if self.CurrentRaceCfg ~= CurCfg then
        self.CurrentRaceCfg = CurCfg
        -- _G.EventMgr:SendEvent(_G.EventID.LoginCurRaceCfgChange, CurCfg)
    -- end
end

function LoginRoleRaceGenderVM:ResSetCurrentRaceCfgByMajor()
    local RoleSimple = MajorUtil.GetMajorRoleSimple()
    if RoleSimple then
        local RaceID = RoleSimple.Race
        local Gender = RoleSimple.Gender
        local TribeID = RoleSimple.Tribe
        
        local RaceList = self.RaceMap[RaceID]
        if RaceList then
            for index = 1, #RaceList do
                if RaceList[index].Tribe == TribeID and RaceList[index].Gender == Gender then
                    self:SelectRoleSetCurrentRaceCfg(RaceList[index])
                    break
                end
            end
        end
    end
end

--给捏脸使用的
function LoginRoleRaceGenderVM:ChangeRenderActor(RaceID, TribeID, Gender, bReadAvatarRecord)
    local RaceList = self.RaceMap[RaceID]
    if RaceList then
        for index = 1, #RaceList do
            if RaceList[index].Tribe == TribeID and RaceList[index].Gender == Gender then
                self:SelectRoleSetCurrentRaceCfg(RaceList[index])
                break
            end
        end
    end
    
    if self.RaceList then
        for index = 1, #self.RaceList do
            local RaceCfg = self.RaceList[index]
            if RaceCfg and RaceCfg.RaceID == RaceID then
                FLOG_INFO("login ChangeRenderActor to index:%d, Name:%s", index, RaceCfg.RaceName)
                self.SelectRaceIndex = {Idx = index, bReadAvatarRecord = bReadAvatarRecord}
                self.CurrentSelectIndex = index
                self.SelectRaceIndex = nil  --立即重置
                break
            end
        end
    end

    self:UpdateInfo(self.CurrentRaceCfg)
end

return LoginRoleRaceGenderVM