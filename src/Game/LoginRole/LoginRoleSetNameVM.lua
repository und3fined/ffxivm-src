local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")

local ProfUtil = require("Game/Profession/ProfUtil")
local RandomNameCfg = require("TableCfg/RandomNameCfg")
local ProtoRes = require("Protocol/ProtoRes")
local RaceType = ProtoCommon.race_type
local LSTR = _G.LSTR

---@class LoginRoleSetNameVM : UIViewModel
local LoginRoleSetNameVM = LuaClass(UIViewModel)
local MAX_NAME_LEN = 7

function LoginRoleSetNameVM:Ctor()
    self.RaceName = ""
    self.TribeName = ""
    self.Birthday = ""
    self.GodName = ""
    self.TitleName = ""
    self.ProfName = ""
    self.RecordRoleNameFunc = false
    self.SetInputText = ""

    --中文、韩文是特殊的规则；其他预约是另外一套规则
    self.IsChineseVersion = true
    self.MaxRandomCfgNum = 1

    self.CheckNameRsp = false

    --该阶段的数据
    self.RoleName = ""
    self.bSetNameError = false
    self.SetBtnEnable = false
    --该阶段的数据
end

function LoginRoleSetNameVM:OnInit()
	self:SetNoCheckValueChange("RecordRoleNameFunc", true)
	self:SetNoCheckValueChange("SetInputText", true)
	self:SetNoCheckValueChange("SetBtnEnable", true)
end

function LoginRoleSetNameVM:OnBegin()
    local RandomNameCfgList = RandomNameCfg:FindAllCfg()
    self.MaxRandomCfgNum = #RandomNameCfgList
    -- FLOG_ERROR("Login self.MaxRandomCfgNum :%d", self.MaxRandomCfgNum)
end

function LoginRoleSetNameVM:OnEnd()
end

function LoginRoleSetNameVM:OnShutdown()
end

function LoginRoleSetNameVM:DiscardData()
    FLOG_INFO("LoginRoleSetNameVM:DiscardData")
    self.RoleName = ""
    self:SetInputTextRoleName(self.RoleName)
    self.RecordRoleNameFunc = false
    self.bSetNameError = false
end

function LoginRoleSetNameVM:Restore()
	local SaveData = _G.LoginUIMgr.LoginReConnectMgr.SaveData
    self.RoleName = SaveData.RoleName
    self:SetInputTextRoleName(self.RoleName)
end

function LoginRoleSetNameVM:OnShow()
    local CurRaceCfg = _G.LoginRoleRaceGenderVM.CurrentRaceCfg
    if CurRaceCfg then
        if CurRaceCfg.Gender == ProtoCommon.role_gender.GENDER_MALE then
            self.RaceName = string.format(LSTR(980067), CurRaceCfg.RaceName)--%s 男
        else
            self.RaceName = string.format(LSTR(980068), CurRaceCfg.RaceName)--%s 女
        end

        self.TribeName = CurRaceCfg.TribeName
    end

    self.Birthday = _G.LoginRoleBirthdayVM.TextDateStr
    self.GodName = _G.LoginRoleGodVM.GodName
    self.ProfName = _G.LoginRoleProfVM.ProfName
    self.TitleName = _G.LoginRoleGodVM:GetCurGodCfg().Title

    self:SetInputTextRoleName(self.RoleName)
end

function LoginRoleSetNameVM:SetInputTextRoleName(RoleName)
    self.SetInputText = RoleName
end

function LoginRoleSetNameVM:RecordRoleName()
    self.RecordRoleNameFunc = true
    
    _G.LoginUIMgr.LoginReConnectMgr:SaveValue("RoleName", self.RoleName)
end

function LoginRoleSetNameVM:OnFinishName()
    if not _G.LoginMgr:CheckRoleName(self.RoleName) then
        return false
    end

    return _G.LoginUIMgr:OnFinishName(self.RoleName)
end

function LoginRoleSetNameVM:OnMakeNameCheckRsp(bError)
    self.CheckNameRsp = true
    self.bSetNameError = bError
	if bError then
        self:SetMakeNameBtnEnable(false)
    else
        self:SetMakeNameBtnEnable(true)
	end
    
    self.CheckNameRsp = false
end

function LoginRoleSetNameVM:SetMakeNameBtnEnable(bEnable)
	if bEnable then
        self.SetBtnEnable = true
		-- _G.LoginUIMgr:SetNextBtnEnable(true)
    else
        self.SetBtnEnable = false
		-- _G.LoginUIMgr:SetNextBtnEnable(false)
	end
end

function LoginRoleSetNameVM:GetRandomName()
    local RaceCfg = _G.LoginRoleRaceGenderVM.CurrentRaceCfg
    if not RaceCfg then
        return ""
    end

    if self.IsChineseVersion then
        return self:RandomChineseName(RaceCfg.RaceID, RaceCfg.Gender, RaceCfg.Tribe)
    end

    return ""
end

function LoginRoleSetNameVM:RandomChineseName(RaceID, Gender, Tribe)
    if self.MaxRandomCfgNum <= 1 then
        local RandomNameCfgList = RandomNameCfg:FindAllCfg()
        self.MaxRandomCfgNum = #RandomNameCfgList
    end

    local RandMax = self.MaxRandomCfgNum - 1
    local TribeIndex = math.fmod(Tribe, 2)  --1是第一个种族  0是第2个种族
    local RltName = ""

    if RaceID == RaceType.RACE_TYPE_Lalafell then   --拉拉肥
        local LalaFirst, LalaRhyme
        while(RandMax > 0) do
            local Idx = math.random(1, RandMax)
            local FirstCfg = RandomNameCfg:FindCfgByKey(Idx)

            local Idx2 = math.random(1, RandMax)
            while Idx2 == Idx do
                Idx2 = math.random(1, RandMax)
            end
            local RhymeCfg = RandomNameCfg:FindCfgByKey(Idx2)

            if not FirstCfg or not RhymeCfg then
                return ""
            end

            if TribeIndex == 1 then
                if Gender == 1 then --男性
                    if not LalaFirst and string.len(FirstCfg.LAPxxxMF) > 0 then
                        LalaFirst = FirstCfg.LAPxxxMF
                    end

                    if not LalaRhyme and string.len(RhymeCfg.LAPxxxMR) > 0 then
                        LalaRhyme = RhymeCfg.LAPxxxMR
                    end

                    if LalaFirst and LalaRhyme then
                        RltName = string.format("%s%s", LalaFirst, LalaRhyme)
                        break
                    end
                else    --女性
                    if not LalaFirst and string.len(FirstCfg.LADxxxFN) > 0 then
                        LalaFirst = FirstCfg.LADxxxFN
                    end

                    if not LalaRhyme and string.len(RhymeCfg.LADxxxFR) > 0 then
                        LalaRhyme = RhymeCfg.LADxxxFR
                    end

                    if LalaFirst and LalaRhyme then
                        RltName =  string.format("%s%s%s", LalaFirst, LalaRhyme, LalaRhyme)
                        break
                    end
                end
            else
                if Gender == 1 then --男性
                    if not LalaFirst and string.len(FirstCfg.LADxxxMN) > 0 then
                        LalaFirst = FirstCfg.LADxxxMN
                    end

                    if not LalaRhyme and string.len(RhymeCfg.LADxxxMR) > 0 then
                        LalaRhyme = RhymeCfg.LADxxxMR
                    end

                    if LalaFirst and LalaRhyme then
                        RltName =  string.format("%s%s", LalaFirst, LalaRhyme)
                        break
                    end
                else    --女性
                    if not LalaFirst and string.len(FirstCfg.LADxxxFN) > 0 then
                        LalaFirst = FirstCfg.LADxxxFN
                    end

                    if not LalaRhyme and string.len(RhymeCfg.LADxxxFR) > 0 then
                        LalaRhyme = RhymeCfg.LADxxxFR
                    end

                    if LalaFirst and LalaRhyme then
                        RltName =  string.format("%s%s%s", LalaFirst, LalaFirst, LalaRhyme)
                        break
                    end
                end
            end

            RandMax = RandMax - 1
        end
    else    --其他种族
        local FirstName
        while(RandMax > 0) do
            local Idx = math.random(0, RandMax)
            local FirstCfg = RandomNameCfg:FindCfgByKey(Idx)
            if not FirstCfg then
                return ""
            end

            if not FirstName or string.len(FirstName) > 0 then
                if RaceID == RaceType.RACE_TYPE_Hyur then       --人族
                    if TribeIndex == 1 then
                        if Gender == 1 then
                            FirstName = FirstCfg.HUMxxxM
                        else
                            FirstName = FirstCfg.HUMxxxF
                        end
                    else
                        if Gender == 1 then
                            FirstName = FirstCfg.HUHxxxM
                        else
                            FirstName = FirstCfg.HUHxxxF
                        end
                    end
                elseif RaceID == RaceType.RACE_TYPE_Elezen then --精灵族
                    if Gender == 1 then
                        FirstName = FirstCfg.ELxxxM
                    else
                        FirstName = FirstCfg.ELxxxF
                    end
                elseif RaceID == RaceType.RACE_TYPE_Miqote then   --猫魅族
                    if TribeIndex == 1 then
                        if Gender == 1 then
                            FirstName = FirstCfg.MQSxxxM
                        else
                            FirstName = FirstCfg.MQSxxxF
                        end
                    else
                        if Gender == 1 then
                            FirstName = FirstCfg.MQMxxxM
                        else
                            FirstName = FirstCfg.MQMxxxF
                        end
                    end
                elseif RaceID == RaceType.RACE_TYPE_Roegadyn then   --鲁加族
                    if TribeIndex == 1 then
                        if Gender == 1 then
                            FirstName = FirstCfg.ROZxxxMF
                        else
                            FirstName = FirstCfg.ROZxxxFF
                        end
                    else
                        FirstName = FirstCfg.RORxxxF
                    end
                elseif RaceID == RaceType.RACE_TYPE_AuRa then       --敖龙族
                    if TribeIndex == 1 then
                        if Gender == 1 then
                            FirstName = FirstCfg.AURxxxMF
                        else
                            FirstName = FirstCfg.AURxxxFF
                        end
                    else
                        if Gender == 1 then
                            FirstName = FirstCfg.AUXxxxMF
                        else
                            FirstName = FirstCfg.AUXxxxFF
                        end
                    end
                elseif RaceID == RaceType.RACE_TYPE_Viera then      --维埃拉族
                    if TribeIndex == 1 then
                        FirstName = FirstCfg.HRHxxxF
                    else
                        FirstName = FirstCfg.HRTxxxF
                    end
                elseif RaceID == RaceType.RACE_TYPE_Hrothgar then      --硌狮族
                    FirstName = FirstCfg.VIxxxF
                    -- if TribeIndex == 1 then
                    --     FirstName = FirstCfg.VIxxxF
                    -- else
                    --     FirstName = FirstCfg.VIxxxF
                    -- end
                end
            end

            if string.len(FirstName) == 0 then
                FirstName = nil
            end

            if not FirstName then
                RandMax = RandMax - 1
            else
                if _G.UE.UKismetStringLibrary.Len(FirstName) > MAX_NAME_LEN then
                    FirstName = nil
                    RandMax = RandMax - 1
                else
                    RltName = FirstName
                    break
                end
            end
        end
    end

    return RltName
end

return LoginRoleSetNameVM