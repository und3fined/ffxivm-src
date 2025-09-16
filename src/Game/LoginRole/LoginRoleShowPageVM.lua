local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local EquipmentProfSuitCfg = require("TableCfg/EquipmentProfSuitCfg")
local EquipmentRaceSuitCfg = require("TableCfg/EquipmentRaceSuitCfg")
local LoginAnimCfg = require("TableCfg/LoginAnimCfg")
local EmotionCfg = require("TableCfg/EmotionCfg")
local LoginShowMenuCfg = require("TableCfg/LoginShowMenuCfg")
local LoginMapCfg = require("TableCfg/LoginMapCfg")
local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local ProtoRes = require("Protocol/ProtoRes")
local CommonUtil = require("Utils/CommonUtil")

---@class LoginRoleShowPageVM : UIViewModel
local LoginRoleShowPageVM = LuaClass(UIViewModel)

local LoginRoleRaceGenderVM = require("Game/LoginRole/LoginRoleRaceGenderVM")

local LoginRoleProfVM = require("Game/LoginRole/LoginRoleProfVM")
local LSTR = _G.LSTR
function LoginRoleShowPageVM:Ctor()
    --一级菜单，对应于  演示一级菜单那个表
    self.MainMenuList = {}

    --二级菜单
    self.TextSecondMenuList = {}    --文本形式的
    --环境
    self.MapList = {}
    --天气
    self.WeatherList = {}

    self.TitleName = LSTR(980071)--("预览")
    self.SubTitleName = ""

    --试穿的
    self.RaceAndProfSuitList = {}
    --动作列表
    self.AnimList = {}
    self.TimeList = {LSTR(980072), LSTR(980074)} --("中午"), ("夜晚")}
        --{LSTR(980072), LSTR(980073), LSTR(980074)} --("中午"), ("傍晚"), ("夜晚")}

    --所有的种族装套装
    self.AllRaceSuit = nil
    --所有的职业装装套装
    self.AllProfSuit = nil
    --所有的动作
    self.AllAction = nil
    self.AllMap = nil

    --该阶段的数据 begin
    --试穿界面
    self.CurLoginShowType = _G.LoginShowType.Suit
    self.CurrentSuitIndex = 0       --默认装

    --动作界面
    self.CurrentActionIndex = 0
    self.CurMapIndex = 1
    self.CurTimeIndex = 1
    self.CurWeatherIndex = 1
    
    --该阶段的数据 end
end

function LoginRoleShowPageVM:OnInit()
end

function LoginRoleShowPageVM:OnBegin()
end

function LoginRoleShowPageVM:OnEnd()
end

function LoginRoleShowPageVM:OnShutdown()
end

function LoginRoleShowPageVM:DiscardData()
    --试穿界面
    self.CurLoginShowType = _G.LoginShowType.Suit
    self.CurrentSuitIndex = 0       --默认装

    --动作界面
    self.CurrentActionIndex = 0
end

function LoginRoleShowPageVM:InitAllMenu()
    -- if not self.MainMenuList or #self.MainMenuList == 0 then
    --     self.MainMenuList = LoginShowMenuCfg:FindAllCfg()
    -- end
    self.PlayAnimCount = 0
    self:RefreshTopMenus()

    -- self.CurTimeIndex = 1

    return self.MainMenuList
end

function LoginRoleShowPageVM:RefreshTopMenus()
    local MenuList = LoginShowMenuCfg:FindAllCfg()

    local AllWeathers = _G.LoginMapMgr:GetCurMapAllLoginWeatherCfgs()
    if #AllWeathers == 0 then
        table.remove(MenuList, 4)
        table.remove(MenuList, 4)
    end

    self.MainMenuList = MenuList
end

function LoginRoleShowPageVM:ClearSuit()
    self.AllRaceSuit = nil
end

function LoginRoleShowPageVM:GetAllRaceSuit()
    if not self.AllRaceSuit then
        self.AllRaceSuit = EquipmentRaceSuitCfg:FindAllNormalCfg()
    end

    return self.AllRaceSuit
end

function LoginRoleShowPageVM:GetUnderClothe(Race, Gender)
    local UnderClotheCfg = nil
    local AllRaceSuit = self:GetAllRaceSuit()
    if AllRaceSuit then
        for index = 1, #AllRaceSuit do
            local SuitCfg = AllRaceSuit[index]
            if SuitCfg.IsUnderClothes == 1 and SuitCfg.RaceID == Race and SuitCfg.Gender == Gender then
                UnderClotheCfg = SuitCfg
                break
            end
        end
    end

    return UnderClotheCfg
end

function LoginRoleShowPageVM:GetSuitByType(Race, Gender, Type)
    local Result = nil
    local AllSuits = nil
    if Type == ProtoRes.suit_type.SUIT_TYPE_PROF then
        AllSuits = self:GetAllProfSuit()
        local ProfID = LoginRoleProfVM.CurrentProf.Prof
        for index = 1, #AllSuits do
            local SuitCfg = AllSuits[index]
            if SuitCfg.Prof == ProfID then
                Result = SuitCfg
                break
            end
        end
    elseif Type ~= ProtoRes.suit_type.SUIT_TYPE_NONE and Type ~= ProtoRes.suit_type.SUIT_TYPE_CURRENT then
        AllSuits = self:GetAllRaceSuit()
        for index = 1, #AllSuits do
            local SuitCfg = AllSuits[index]
            if SuitCfg.SuitType == Type and SuitCfg.RaceID == Race and SuitCfg.Gender == Gender then
                Result = SuitCfg
                break
            end
        end
    end
    return Result
end

function LoginRoleShowPageVM:GetAllProfSuit()
    if not self.AllProfSuit then
        self.AllProfSuit = EquipmentProfSuitCfg:FindAllCfg()
    end

    return self.AllProfSuit
end

function LoginRoleShowPageVM:GetAllAction()
    if not self.AllAction then
        self.AllAction = LoginAnimCfg:FindAllCfg()
    end

    return self.AllAction
end

function LoginRoleShowPageVM:GetAllMaps()
    if not self.AllMap then
        self.AllMap = LoginMapCfg:FindAllCfg()
    end

    return self.AllMap
end

--1:试穿 2：动作 3：环境
function LoginRoleShowPageVM:OnRolePageViewShow(UIMode)
    self.CurLoginShowType = UIMode
    self.SubTitleName = self.MainMenuList[UIMode].Name
    -- FLOG_INFO("LoginRoleShowPageVM OnRolePageViewShow %d", UIMode)

    if UIMode == _G.LoginShowType.Suit then         --装备
        self:OnShowTryOn()
    elseif UIMode == _G.LoginShowType.Action then   --动作
        self:OnShowAnim()
    elseif UIMode == _G.LoginShowType.Map then      --环境
        self:OnShowMaps()
	elseif _G.LoginShowType.Time == UIMode then		--时间
        self:OnShowTimes()
	elseif _G.LoginShowType.Weather == UIMode then	--天气
        self:OnShowWeathers()
    end
end

function LoginRoleShowPageVM:OnShowTryOn()
    local RaceID = 0
    local Gender = 0

    local CurRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
    if not CurRaceCfg then
        local RoleSimple = _G.LoginRoleMainPanelVM:GetSelectRoleSimple()
        if RoleSimple then
            RaceID = RoleSimple.Race
            Gender = RoleSimple.Gender
        else
            FLOG_ERROR("LoginRoleShowPageVM:OnRolePageViewShow CurRaceCfg is nil")
            return 
        end
    else
        RaceID = CurRaceCfg.RaceID
        Gender = CurRaceCfg.Gender
    end
    
    --常规试穿，只需要种族装，不需要职业装
    local AllSuit = {}
    FLOG_INFO("====== LoginRoleShowPageVM Suit TryOn ======")
    local RaceSuitCfgList = self:GetAllRaceSuit()
    local DefaultCfg = nil
    for index = 1, #RaceSuitCfgList do
        local SuitCfg = RaceSuitCfgList[index]
        if SuitCfg.RaceID == RaceID 
            and SuitCfg.Gender == Gender then
            if SuitCfg.IsDefault == 1 then
                DefaultCfg = SuitCfg
            else
                FLOG_INFO("LoginRoleShowPageVM RaceSuitID:%d name:%s", SuitCfg.ID, SuitCfg.SuitName)
                table.insert(AllSuit, SuitCfg)
            end
        end
    end

    --幻想药没有选职业阶段，LoginRoleProfVM为nil，因此不显示职业装
    --只要到过选职业界面，都是种族装+职业装了
    if _G.LoginMapMgr.CurLoginMapType ~= _G.LoginMapType.Fantasia and LoginUIMgr.MaxDonePhase >= LoginRolePhase.Prof then
        --优先选职业的默认
        if DefaultCfg then
            FLOG_INFO("LoginRoleShowPageVM default RaceSuitID:%d name:%s", DefaultCfg.ID, DefaultCfg.SuitName)
            table.insert(AllSuit, 1, DefaultCfg)

            if self.CurrentSuitIndex == 0 then
                self.CurrentSuitIndex = 1
            end
        end

        --职业界面的试穿，要有职业装
        DefaultCfg = nil
        local ProfBeginIdx = #AllSuit + 1
        local ProfID = LoginRoleProfVM.CurrentProf and LoginRoleProfVM.CurrentProf.Prof or -1
        if _G.LoginMapMgr.CurLoginMapType == _G.LoginMapType.HairCut then
            ProfID = -1
        end
        local ProfSuitCfgList = self:GetAllProfSuit()
        for index = 1, #ProfSuitCfgList do
            local SuitCfg = ProfSuitCfgList[index]
            if SuitCfg.Prof == ProfID then
                if SuitCfg.IsDefault == 1 then
                    DefaultCfg = SuitCfg
                else
                    FLOG_INFO("LoginRoleShowPageVM ProfSuitID:%d name:%s", SuitCfg.ID, SuitCfg.SuitName)
                    table.insert(AllSuit, SuitCfg)
                end
            end
        end

        if DefaultCfg then
            FLOG_INFO("LoginRoleShowPageVM ProfSuitID:%d ProfBeginIdx:%d name:%s", DefaultCfg.ID, ProfBeginIdx, DefaultCfg.SuitName)
            table.insert(AllSuit, ProfBeginIdx, DefaultCfg)
            if self.CurrentSuitIndex == 0 then
                self.CurrentSuitIndex = ProfBeginIdx
            end
        end
    else
        --优先选职业的默认
        if DefaultCfg then
            FLOG_INFO("LoginRoleShowPageVM RaceSuitID:%d name:%s", DefaultCfg.ID, DefaultCfg.SuitName)
            table.insert(AllSuit, 1, DefaultCfg)

            if self.CurrentSuitIndex == 0 then
                self.CurrentSuitIndex = 1
            end
        end
    end

    -- 理发屋新增当前套装
    if _G.LoginMapMgr:GetCurLoginMapType() == _G.LoginMapType.HairCut then
        local BlankSuitCfg = EquipmentRaceSuitCfg:FindBlankCfg()
        for index = 1, #BlankSuitCfg do
            local SuitCfg = BlankSuitCfg[index]
            if SuitCfg.RaceID == RaceID 
                and SuitCfg.Gender == Gender then
                    table.insert(AllSuit, SuitCfg)
            end
        end
        if self.CurrentSuitIndex == 0 then
            self.CurrentSuitIndex = 1
        end
    end

    self.RaceAndProfSuitList = AllSuit
    if _G.LoginUIMgr.RoleWearSuitCfg ~= nil then
        local CurWearSuitID = _G.LoginUIMgr.RoleWearSuitCfg.ID
        for index = 1, #AllSuit do
            if AllSuit[index].ID == CurWearSuitID then
                self.CurrentSuitIndex = index
                break
            end
        end
    end
    

    local SuitNameList = {}
    for index = 1, #AllSuit do
        table.insert(SuitNameList, AllSuit[index].SuitName)
    end
    self.TextSecondMenuList = SuitNameList
end

function LoginRoleShowPageVM:OnShowAnim()
    local ActionList = {}
    local ActionNameList = {}
    local AllAction = self:GetAllAction()
    for index = 1, #AllAction do
        local Action = AllAction[index]
        table.insert(ActionList, Action)
        table.insert(ActionNameList, Action.Name)
    end

    self.AnimList = ActionList
    self.TextSecondMenuList = ActionNameList
end

function LoginRoleShowPageVM:OnShowMaps()
    local AllMaps = self:GetAllMaps()

    local Maps = {}
    if _G.LoginMapMgr:GetCurLoginMapType() ~= _G.LoginMapType.HairCut then
        for index = 1, #AllMaps do
            local MapCfg = AllMaps[index]
            if MapCfg.NotRealMap == 0 then  --现在当做是不是理发屋专用了
                table.insert(Maps, MapCfg)
            end
        end
        
        self.MapList = Maps
    else
        local Cnt = #AllMaps
        table.insert(Maps, AllMaps[Cnt])
        
        for index = 1, Cnt - 1 do
            local MapCfg = AllMaps[index]
            if MapCfg.NotRealMap == 0 then
                table.insert(Maps, MapCfg)
            end
        end

        self.MapList = Maps
    end

    local CurLoginMapCfgID = _G.LoginMapMgr:GetCurLoginMapCfgID()
    for index = 1, #self.MapList do
        if self.MapList[index].ID == CurLoginMapCfgID then
            self.CurMapIndex = index
            break
        end
    end
end

function LoginRoleShowPageVM:OnShowTimes()
    local AllWeathers = _G.LoginMapMgr:GetCurMapAllLoginWeatherCfgs()
    if #AllWeathers == 0 then
        self.TextSecondMenuList = {}
        return 
    end

    self.TextSecondMenuList = self.TimeList
end

function LoginRoleShowPageVM:SetTimeIndex(TimeIdx)
    self.CurTimeIndex = TimeIdx
end

function LoginRoleShowPageVM:GetTimeIndex(TimeIdx)
    return self.CurTimeIndex
end

function LoginRoleShowPageVM:OnShowWeathers()
    local AllWeathers = _G.LoginMapMgr:GetCurMapAllLoginWeatherCfgs()
    self.WeatherList = AllWeathers

    local CurWeatherID = _G.LoginMapMgr:GetCurWeatherID()
    for index = 1, #AllWeathers do
        if AllWeathers[index].WeatherID == CurWeatherID then
            self.CurWeatherIndex = index
            break
        end
    end

end

function LoginRoleShowPageVM:PlayAnim(Index)
    self.CurrentActionIndex = Index

    local Action = self.AnimList[Index]
    local EmotionCfg = EmotionCfg:FindCfgByKey(Action.AnimID)
    local UIComplexCharacter = _G.LoginUIMgr:GetUIComplexCharacter()
    if EmotionCfg and UIComplexCharacter then
        local AnimPath = EmotionAnimUtils.GetActorEmotionAnimPath(EmotionCfg.AnimPath
                            , UIComplexCharacter, EmotionDefines.AnimType.EMOT)
        local Render2DView = _G.LoginUIMgr:GetCommonRender2DView()
        if Render2DView then
            self.PlayAnimCount = self.PlayAnimCount + 1
            Render2DView:SetCanRotate(false)
            local function RestoreCanRotate()
                self.PlayAnimCount = self.PlayAnimCount - 1
                if self.PlayAnimCount <= 0 and Render2DView and Render2DView.RenderActor then
                    Render2DView:SetCanRotate(true)
                end
            end
            local Delegate = CommonUtil.GetDelegatePair(RestoreCanRotate, true)
            _G.AnimMgr:PlayActionTimeLineByActor(UIComplexCharacter, AnimPath, Delegate)
        end
    end
end

return LoginRoleShowPageVM