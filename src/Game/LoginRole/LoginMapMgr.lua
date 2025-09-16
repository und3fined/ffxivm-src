local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
-- local ProtoRes = require("Protocol/ProtoRes")

local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewID = require("Define/UIViewID")
local MajorUtil = require ("Utils/MajorUtil")

-- local ProtoCommon = require("Protocol/ProtoCommon")

local LoginRoleShowPageVM = require("Game/LoginRole/LoginRoleShowPageVM")
local LoginRoleRaceGenderVM = require("Game/LoginRole/LoginRoleRaceGenderVM")

-- local LoginFeedbackAnimCfg = require("TableCfg/LoginFeedbackAnimCfg")
local LoginMapCfg = require("TableCfg/LoginMapCfg")
local MapCfg = require("TableCfg/MapCfg")
local MapResCfg = require("TableCfg/MapresCfg")
local WeatherFuncCfg = require("TableCfg/WeatherFuncCfg")
local LoginWeatherCfg = require("TableCfg/LoginWeatherCfg")
local LoginTimeCfg = require("TableCfg/LoginTimeCfg")

local LoginConfig = require("Define/LoginConfig")
-- local RaceFaceCfg = require("TableCfg/RaceFaceCfg")
local CommonUtil = require("Utils/CommonUtil")
local LoginMapTodparamCfg = require("TableCfg/LoginMapTodparamCfg")

local ProtoRes = require ("Protocol/ProtoRes")

local LSTR = _G.LSTR
local UAudioMgr = _G.UE.UAudioMgr
local CEnvMgr = _G.UE.UEnvMgr

_G.LoginMapType = _G.LoginMapType or
{
	Login = 1,		--常规登录流程
	HairCut = 2,	--理发 屋
	Fantasia = 3,	--幻想 药
}

local LoginMapType = _G.LoginMapType
--理发屋的 装备界面场景的MapID
local EquipmentMapID = LoginConfig.EquipmentMapID

---@class LoginMapMgr : MgrBase
local LoginMapMgr = LuaClass(MgrBase)

LoginMapMgr.LoginMapMainUIPanelConfig =
{
	[LoginMapType.HairCut] = UIViewID.HaircutMainPanel,
	[LoginMapType.Fantasia] = UIViewID.LoginFixPage,
}

LoginMapMgr.RoleShowPageConfig =
{
	[LoginMapType.Login] = UIViewID.LoginRoleShowPage,
	[LoginMapType.HairCut] = UIViewID.HaircutPreviewPanel,
	[LoginMapType.Fantasia] = UIViewID.LoginRoleShowPage,
}

function LoginMapMgr:OnInit()
    -- self.MajorBirthPos = _G.UE.FVector(0, 0, 0) --主角出生点
    -- self.MajorBirthRotator = _G.UE.FVector(0, 0, 0) --主角出生朝向

	-- self.ClientMajor = nil

	self.CurLoginMapCfg = nil
	self.CurMapCfg = nil
	self.CurMapID = 0
	self.CurLevelPath = ""
	self.LoginMapCfgID = 0	--从1开始，是创建表里配置的那几个场景的cfg的id
	self.LastMapCfgID = 0	--创角的体验技能专用

	--[创角地图MapID, LoginMapCfg]
	self.LoginMaps = {}
	--[WeatherID, LoginWeatherCfg]
	self.LoginWeathers = {}

	--[创角地图MapID， {天气运转表的天气方案Cfg的list}]
	self.AllMapWeathersList = {}
	--[创角地图MapID， {天气ID的list}]
	self.AllMapWeatherIDList = {}

	--LoginWeatherCfg的所有配置
	self.LoginWeatherCfgList = {}

	self.WeatherID = 0
	self.WeatherStartFrameNum = 0
	self.WeatherTimeHourList = {}

	self.CurrBGMSceneID = 0
	self.CurLoginMapType = _G.LoginMapType.Login --理发屋、幻想药的登录场景才会是true
	
	self.bFirstEnterHairCutMap = nil
	self.bFirstEnterFantasiaMap = nil
end

function LoginMapMgr:OnBegin()
	local AllLoginMaps = LoginMapCfg:FindAllCfg()
	for index = 1, #AllLoginMaps do
		local Cfg = AllLoginMaps[index]
		self.LoginMaps[Cfg.MapID] = Cfg
	end

	self.LoginWeatherCfgList = LoginWeatherCfg:FindAllCfg()
	for index = 1, #self.LoginWeatherCfgList do
		local LoginWeather = self.LoginWeatherCfgList[index]
		self.LoginWeathers[LoginWeather.WeatherID] = LoginWeather
	end


	local AllMapWeatherIDMap = {}

	local Cfgs = WeatherFuncCfg:FindAllCfg()
    if Cfgs ~= nil then
		for index = 1, #Cfgs do
			local WeatherCfg = Cfgs[index]
			local MapID = WeatherCfg.MapID
			if self.LoginMaps[MapID] then	--是创角地图
				local MapWeathers = self.AllMapWeathersList[MapID] or {}
				table.insert(MapWeathers, WeatherCfg)
				table.sort(MapWeathers,
					function(Left, Right)
						return Left.WeatherID < Right.WeatherID
					end
				)

				self.AllMapWeathersList[MapID] = MapWeathers

				local WeatherIDMap = AllMapWeatherIDMap[MapID] or {}
				WeatherIDMap[WeatherCfg.WeatherID] = true
				AllMapWeatherIDMap[MapID] = WeatherIDMap
			end
		end

		for MapID, WeatherIDMap in pairs(AllMapWeatherIDMap) do
			local WeatherIDs = table.indices(WeatherIDMap)
			self.AllMapWeatherIDList[MapID] = WeatherIDs
		end

		FLOG_INFO("LoginMapMgr:OnBegin over")
	end

	local TimeCfgs = LoginTimeCfg:FindAllCfg()
    if TimeCfgs ~= nil then
		self.WeatherTimeHourList = {}
		for index = 1, #TimeCfgs do
			local Hour = TimeCfgs[index].Hour
			table.insert(self.WeatherTimeHourList, Hour)
		end
	end
end

function LoginMapMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MajorCreate, self.OnMajorCreate)
    self:RegisterGameEvent(EventID.MapChanged, self.OnGameEventMapChange)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventMapChange)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldMapExit)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldMapExit)
end

function LoginMapMgr:OnMajorCreate(Params)
    if nil == Params then
        return
    end

	--创角演示场景：理发屋、幻想药
	local Major = MajorUtil.GetMajor()
	if Major then
		if self.CurLoginMapType ~= _G.LoginMapType.Login then
			Major:SetVisibility(false, _G.UE.EHideReason.LoginMap, true)
			-- _G.UE.UActorManager:Get():HideActor(MajorUtil.GetMajorEntityID(), true)
		else
			Major:SetVisibility(true, _G.UE.EHideReason.LoginMap, true)
		end
	end
end

function LoginMapMgr:OnEnd()
	-- self:ReleaseActor()
	self:Reset()
end

function LoginMapMgr:OnShutdown()
end

function LoginMapMgr:Reset()
    -- self.MajorBirthPos = _G.UE.FVector(0, 0, 0) --主角出生点
    -- self.MajorBirthRotator = _G.UE.FVector(0, 0, 0) --主角出生朝向
	self.CurLoginMapCfg = nil
	self.CurMapCfg = nil
	self.CurMapID = 0
	self.CurLevelPath = ""
	self.LoginMapCfgID = 0

	self.bFirstEnterHairCutMap = nil
	self.bFirstEnterFantasiaMap = nil

	_G.LoginUIMgr:RecordProfSuit(nil)
	LoginRoleShowPageVM:DiscardData()
	self:StopBGM()
	
	self.CurLoginMapType = _G.LoginMapType.Login
end

function LoginMapMgr:GetCurMapAllLoginWeatherCfgs()
	--NotRealMap现在当做是不是理发屋专用了
	if self.CurLoginMapCfg and self.CurLoginMapCfg.NotRealMap == 1  then	-- 装备界面背景
		return {}
	end
	
	local IDList = self.AllMapWeatherIDList[self.CurMapID] or {}
	if #IDList == 1 then
		return {}
	end

	local LoginWeatherCfgs = {}

	for index = 1, #IDList do
		local ID = IDList[index]
		local Cfg = self.LoginWeathers[ID]

		table.insert(LoginWeatherCfgs, Cfg)
	end

	return LoginWeatherCfgs
end

function LoginMapMgr:GetCurMapID()
	return self.CurMapID
end

function LoginMapMgr:IsInRoomMap()
	return self.CurMapID == 1057
end

function LoginMapMgr:IsSelectRoleMap()
	return self.CurLoginMapCfg and self.CurLoginMapCfg.ID == LoginConfig.SelectRoleMap or false
end

function LoginMapMgr:IsHaircutDefaultMap()
	return self.CurLoginMapCfg and self.CurLoginMapCfg.ID == LoginConfig.EquipmentMapID or false
end

function LoginMapMgr:IsNeedShadowActorMap()
	if not self.CurLoginMapCfg then
		return false
	end

	if self.CurLoginMapCfg.ID == LoginConfig.SelectRoleMap or self.CurLoginMapCfg.ID == LoginConfig.EquipmentMapID then
		return true
	end

	return false
end

function LoginMapMgr:GetCurLoginMapCfgID()
	return self.CurLoginMapCfg.ID
end

function LoginMapMgr:IsFantasiaAvatarPhase()
	if self.bFirstEnterFantasiaMap and self:GetCurLoginMapCfgID() ~= LoginConfig.SelectRoleMap then
		return true
	end

	return false
end
	
function LoginMapMgr:GetCurWeatherID()
	return self.WeatherID
end

function LoginMapMgr:GetCurLoginMapType()
	return self.CurLoginMapType
end

function LoginMapMgr:SetMainPanelUIType(MainPanelUIType)
	if MainPanelUIType == _G.LoginMapType.HairCut then
		self.CurLoginMapType = _G.LoginMapType.HairCut
	elseif MainPanelUIType == _G.LoginMapType.Fantasia then
		self.CurLoginMapType = _G.LoginMapType.Fantasia
	else
		self.CurLoginMapType = _G.LoginMapType.Login
	end
end

function LoginMapMgr:IsRealLoginMap()
	return self.CurLoginMapType == _G.LoginMapType.Login
end

function LoginMapMgr:GetPreViewPageID()
	return self.RoleShowPageConfig[self.CurLoginMapType]
end

-- function LoginMapMgr:IsRealLoginMapID(MapID)
-- 	if self.LoginMaps[MapID] then
-- 		return true
-- 	end

-- 	return false
-- end

function LoginMapMgr:GetActorYawOffset()
	if self.CurLoginMapCfg then
		return self.CurLoginMapCfg.ActorYawOffset
	end

	return 0
end

--创角进入体验技能场景后，返回登录界面，以及恢复选职业的界面
function LoginMapMgr:RestorLoginMap()
	self:ChangeLoginMap(self.LastMapCfgID, true)
end

--============ 服务器触发切图 ==================
--记录地图相关数据
function LoginMapMgr:OnSvrChangeLoginMap(bPostLoad)
    local MapID = 0

	_G.LoginUIMgr.ForceWear = true
    if _G.PWorldMgr.BaseInfo and _G.PWorldMgr.BaseInfo.CurrMapResID then
        MapID = _G.PWorldMgr.BaseInfo.CurrMapResID

		if self.CurMapID == MapID then
			return
		end
	end

	if MapID > 0 then
		self:RecordLoginMapData(MapID, bPostLoad)
	end
end

--============ 客户端触发 服务器切图 ==================
function LoginMapMgr:RequestChangeLoginMap(LoginMapCfgID, bNoAnim)
	if LoginMapCfgID == self.LoginMapCfgID then
		FLOG_WARNING("LoginMapMgr:RequestChangeLoginMap already in")

		self:RestoreBGM()
		return -1
	end

	local Cfg = LoginMapCfg:FindCfgByKey(LoginMapCfgID)
	if not Cfg then
		--非副本场景，装备界面的那个场景
		FLOG_ERROR("LoginMapMgr:RequestChangeLoginMap LoginMapCfg not Config %d", LoginMapCfgID)
		return
	end

	FLOG_INFO("LoginMapMgr RequestChangeLoginMap PWorldID:%d/%d, MapID:%d"
		, Cfg.PWorldIDHaircut, Cfg.PWorldIDFantasy, Cfg.MapID)

	_G.LoginUIMgr.ForceWear = true
	if not bNoAnim then
		_G.LoginUIMgr:SetFeedbackAnimType(4)
	else
		_G.LoginUIMgr:SetFeedbackAnimType(6)
	end

	-- if Cfg.NotRealMap == 1 then	--从正常的场景，切换到装备界面背景
	-- 	self:RefreshRenderActor(UIViewID.HairCutRoleRender2D)

	-- 	self.CurLoginMapCfg = Cfg
	-- 	self.LoginMapCfgID = self.CurLoginMapCfg.ID
	-- 	self.LastMapCfgID = self.CurLoginMapCfg.ID
	-- 	return
	-- elseif self.CurLoginMapCfg.NotRealMap == 1 and Cfg.MapID == self.CurMapID then
	-- 	--从装备界面背景回退到刚刚正常的场景
	-- 	self.CurLoginMapCfg = Cfg
	-- 	self.LoginMapCfgID = self.CurLoginMapCfg.ID
	-- 	self.LastMapCfgID = self.CurLoginMapCfg.ID

	-- 	self:RefreshRenderActor(UIViewID.LoginRoleRender2D)

	-- 	self:PostLoadWorld(self.LastWorldName, self.CurWorldName)
	-- 	return
	-- end
	local PWorldID = Cfg.PWorldIDHaircut
	if self.CurLoginMapType == _G.LoginMapType.Fantasia then
		self:SendFantasyChangeBGMap(Cfg.PWorldIDFantasy, Cfg.MapID)
	elseif self.CurLoginMapType == _G.LoginMapType.HairCut then
		_G.HaircutMgr:SendChangeBGMap(PWorldID, Cfg.MapID)
	end

	return 0
end

--幻想药切图
function LoginMapMgr:SendFantasyChangeBGMap(PWorldID, MapID)
	local MsgID = ProtoCS.CS_CMD.CS_CMD_FANTASY_MEDICINE
	local SubMsgID = ProtoCS.FantasyMedicineCmd.FantasyMedicineCmdChangeMap

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.ChangeReq = {SceneResID = PWorldID}

	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function LoginMapMgr:RefreshRenderActor(RoleRender2DViewID)
	-- _G.LoginUIMgr:ReleaseRenderActor()
	_G.LoginUIMgr:HideRoleRender2DView()

	_G.LoginUIMgr.RoleRender2DViewID = RoleRender2DViewID

	_G.LoginUIMgr:CreateRenderActor()

	--不同系统的主界面是不同的
	self:ShowLoginMapMainUI()
end

--返回到进入预览界面之前的地图：创角、理发屋、幻想药
-- function LoginMapMgr:BackToOrignMap()
-- 	local OrignMapID = 0
	
-- 	if self.CurLoginMapType == _G.LoginMapType.Fantasia
-- 		or self.CurLoginMapType == _G.LoginMapType.Login then
-- 		OrignMapID = LoginConfig.SelectRoleMap
-- 	elseif self.CurLoginMapType == _G.LoginMapType.HairCut then
-- 		OrignMapID = LoginConfig.EquipmentMapID
-- 	end
	
-- 	local bSameMap = nil
-- 	if OrignMapID > 0 then
-- 		if self:IsRealLoginMap() then
-- 			bSameMap = self:ChangeLoginMap(OrignMapID, nil , true)
-- 		else
-- 			bSameMap = self:RequestChangeLoginMap(OrignMapID, true)
-- 		end
-- 	end

-- 	return bSameMap
-- end

--============ 客户端触发 本地切图 ==================
--正常情况下，刚启动游戏进入选角需要用这个进地图，然后地图加载完成的时候显示选角界面相关
--当从创角过程中取消，回到选角的时候，地图没变，所以返回了-1，所以就没有显示选角界面的机会了
--其他错误返回，也会没有显示选角界面的机会
function LoginMapMgr:ChangeLoginMap(LoginMapCfgID, bForce, bNoAnim)
	if LoginMapCfgID == self.LoginMapCfgID and not bForce then
		FLOG_WARNING("LoginMapMgr:ChangeLoginMap already in")

		self:RestoreBGM()

		return -1
	end

	if not LoginMapCfgID then
		LoginMapCfgID = LoginConfig.SelectRoleMap
	end

	local Cfg = LoginMapCfg:FindCfgByKey(LoginMapCfgID)
	if not Cfg then
		FLOG_ERROR("LoginMapMgr:ChangeLoginMap LoginMapCfg not Config %d", LoginMapCfgID)
		return -2
	end

	FLOG_INFO("LoginMapMgr ChangeLoginMap MapID:%d", Cfg.MapID)

	local Rlt = self:RecordLoginMapData(Cfg.MapID)
	if Rlt < 0 then
		return Rlt
	end

	-- self:Reset()
	-- self:ReleaseActor()
	if not bNoAnim then
		_G.LoginUIMgr:SetFeedbackAnimType(4)
	else
		_G.LoginUIMgr:SetFeedbackAnimType(6)
	end

	_G.LoginUIMgr:OnSendRoleLoginReqAfterRegister(false)

	_G.PWorldMgr:ChangeToLocalMap(self.CurLevelPath, true)

	return 0
end

function LoginMapMgr:PreLoadRenderActors(CacheType)
	--预先加载
	local CurTime = _G.TimeUtil.GetServerTimeMS()
	FLOG_INFO("Login1 Preload RenderActors CurTime:%d", CurTime)
	local RenderActorPathForRace = ""
	for index = 1, 12 do
		RenderActorPathForRace = string.format(LoginConfig.RenderActorPreloadPath, index, index)
		_G.ObjectMgr:LoadObjectAsync(RenderActorPathForRace, nil, CacheType)
		-- local RenderActor = CommonUtil.SpawnActor(_G.ObjectMgr:GetClass(RenderActorPathForRace)
		-- 	, _G.UE.FVector(0, 0, -10000), _G.UE.FRotator(0, 0, 0))
		-- CommonUtil.DestroyActor(RenderActor)
	end

	FLOG_INFO("Login1 Preload RenderActors end Cost:%d", _G.TimeUtil.GetServerTimeMS() - CurTime)
end

function LoginMapMgr:RecordLoginMapData(MapID, bPostLoad)
	local CurrMapCfg = MapCfg:FindCfgByKey(MapID)
	if not CurrMapCfg then
		FLOG_ERROR("LoginMapMgr MapCfg not Config %d", MapID)
		return -3
	end

	self.CurLoginMapCfg = self.LoginMaps[MapID]
	if self.CurLoginMapCfg then
		self.LoginMapCfgID = self.CurLoginMapCfg.ID
		self.LastMapCfgID = self.CurLoginMapCfg.ID
	end

	self.CurMapCfg = CurrMapCfg;

	self.CurMapID = CurrMapCfg.ID
	local CurrMapresCfg = MapResCfg:FindCfgByKey(self.CurMapCfg.LevelID)
	if not CurrMapresCfg then
		FLOG_ERROR("LoginMapMgr:LevelID is Error LeveID is %d", self.CurMapCfg.LevelID)
		return -3
	end

	self.CurLevelPath = CurrMapresCfg.PersistentLevelPath

	if self.CurLoginMapType == _G.LoginMapType.HairCut then
		return 0
	end

	if bPostLoad then
		local MusicSceneID = tonumber(CurrMapCfg.BGMusic)
		if MusicSceneID then
			if self.CurrBGMSceneID > 0 and self.CurrBGMSceneID ~= MusicSceneID then
				self:StopBGM()
			end
	
			UAudioMgr.Get():PlaySceneBGM(MusicSceneID)
			self.CurrBGMSceneID = MusicSceneID
		else
			self:StopBGM()
		end
	end

	return 0
end

function LoginMapMgr:StopBGM()
	UAudioMgr.Get():StopSceneBGM()
	self.CurrBGMSceneID = 0
end

function LoginMapMgr:RestoreBGM()
	if self.CurLoginMapType == _G.LoginMapType.HairCut then
		return
	end

	if self.CurMapCfg then
		local MusicSceneID = tonumber(self.CurMapCfg.BGMusic)
		if MusicSceneID then
			if self.CurrBGMSceneID ~= MusicSceneID then
				self:StopBGM()
			end

			UAudioMgr.Get():PlaySceneBGM(MusicSceneID)
			self.CurrBGMSceneID = MusicSceneID
		end
	end
end

--登录界面的ui show的时候
function LoginMapMgr:OnLoginMainShow()
	--self:StopBGM()

	local CurTime = _G.TimeUtil.GetServerTimeMS()
	local AttachType = "c0101"
	local RenderActorPathForRace = string.format(LoginConfig.RenderActorPath, AttachType, AttachType)
	_G.ObjectMgr:LoadObjectAsync(RenderActorPathForRace, nil, 3)
	-- FLOG_INFO("Login RenderActorPath:%d", _G.TimeUtil.GetServerTimeMS() - CurTime)

	-- CurTime = _G.TimeUtil.GetServerTimeMS()
	_G.ObjectMgr:LoadObjectAsync(LoginConfig.CameraActorPath, nil, 0)	
	-- FLOG_INFO("Login CameraActorPath and make act:%d", _G.TimeUtil.GetServerTimeMS() - CurTime)

	LoginRoleRaceGenderVM:AsyncLoadRaceIcons()
	
	FLOG_INFO("Login OnLoginMainShow Total:%d", _G.TimeUtil.GetServerTimeMS() - CurTime)
end

function LoginMapMgr:ShowLoginMapMainUI()
    if self.CurLoginMapType ~= LoginMapType.Login then
		local ViewID = self.LoginMapMainUIPanelConfig[self.CurLoginMapType]

		if _G.LoginUIMgr.IsShowPreviewPage then
			ViewID = self:GetPreViewPageID()
		end

		if ViewID then
			UIViewMgr:ShowView(ViewID)
		end
    end
end

function LoginMapMgr:OnGameEventPWorldMapExit(Params)
	_G.LuaCameraMgr:UpdateAmbientOcclusionParam(false)
end

function LoginMapMgr:SetLockDirLight(bLock)
	local TodMainActor = _G.UE.UEnvMgr:Get():GetTodSystem()
	if TodMainActor then
		TodMainActor:SetLockDirLight(bLock)
		FLOG_INFO("LoginMapMgr:SetLockDirLight %s", tostring(bLock))
	end
end

function LoginMapMgr:PostLoadWorld(LastWorldName, CurWorldName, bFirstLogin)
	self.LastWorldName = LastWorldName
	self.CurWorldName = CurWorldName
	
	self:SetLockDirLight(false)
	--真实的切图都会走到这里，所以这里就不会是装备界面背景的场景
	-- if self.CurLoginMapCfg.NotRealMap == 1 and self.CurLoginMapType == _G.LoginMapType.HairCut then
	-- 	_G.LoginUIMgr.RoleRender2DViewID = UIViewID.HairCutRoleRender2D
	-- else
	-- 	_G.LoginUIMgr.RoleRender2DViewID = UIViewID.LoginRoleRender2D
	-- end
	_G.LoginUIMgr.RoleRender2DViewID = UIViewID.LoginRoleRender2D

	_G.ObjectMgr:LoadClassAsync(LoginConfig.CharacterAnimClass, nil, 1)

	if self.CurLoginMapType == _G.LoginMapType.HairCut then
		if self.bFirstEnterHairCutMap == nil then
			self.bFirstEnterHairCutMap = true
			
			LoginRoleRaceGenderVM:ResSetCurrentRaceCfgByMajor()
		elseif self.bFirstEnterHairCutMap == true then
			self.bFirstEnterHairCutMap = false
		end
	elseif self.CurLoginMapType == _G.LoginMapType.Fantasia then
		if self.bFirstEnterFantasiaMap == nil then
			self.bFirstEnterFantasiaMap = true
		elseif self.bFirstEnterFantasiaMap == true then
			self.bFirstEnterFantasiaMap = false
		end
	end

	_G.LoginUIMgr:RotatorCameraActor(self:GetActorYawOffset())

    --不同系统的主界面是不同的
	self:ShowLoginMapMainUI()

	_G.LuaCameraMgr:UpdateAmbientOcclusionParam(true)
	
	-- local WeatherList = self.AllMapWeathersList[self.CurMapID]
	-- if WeatherList then
	-- 	self.CurMapWeatherCount = #WeatherList
	-- 	if self.CurMapWeatherCount > 1 then
	-- 		self.bCurMapCanChangeWeather = true
	-- 	elseif self.CurMapWeatherCount == 0 then
	-- 		FLOG_ERROR("LoginMapMgr:PostLoadWorld CurMap %d No Weather", self.CurMapID)
	-- 		return -2
	-- 	else
	-- 		self.bCurMapCanChangeWeather = false
	-- 	end

	-- 	local Weather = WeatherList[1]
	-- 	local IsFixed = Weather.LockTime == 1 or false
	-- 	FLOG_INFO("LoginMapMgr:PostLoadWorld WeatherID:%d, StartTime:%d"
	-- 		, Weather.WeatherID, Weather.StartFrameNumber)

	-- 	_G.UE.UEnvMgr:Get():SetIgnoreTargetArmLength(true)

	-- 	self.WeatherID = Weather.WeatherID
	-- 	self.WeatherPlanID = Weather.WeatherPlanID
	-- 	self:SetWeatherStartFrameNum(Weather.StartFrameNumber)

	-- 	_G.WeatherMgr:PlaySpecialClientWeatherEffect(Weather.WeatherID, 0, Weather.StartFrameNumber, IsFixed)
	-- end
	self:OnGameEventMapChange(nil, bFirstLogin)

	-- 启动Login时不播放默认的BGM
	if CurWorldName ~= "Login" then
		self:RestoreBGM()
	end

	-- if self.CurLoginMapCfg.NotRealMap == 1 and self.CurLoginMapType == _G.LoginMapType.HairCut then
	-- 	self.LoginMapCfgID = 0
	-- 	self:RequestChangeLoginMap(EquipmentMapID)

	-- 	if self.bFirstEnterHairCutMap == true then
	-- 		_G.LoginUIMgr:SetFeedbackAnimType(5)
	-- 	end

	-- 	return -1
	-- end

	if self.bFirstEnterHairCutMap == true then
		_G.LoginUIMgr:SetFeedbackAnimType(5)
	end

	return 0
end

function LoginMapMgr:HideOtherActors()
    local ExcludeActorTypes = _G.UE.TArray(_G.UE.uint8)
    local ExcludeActorID = _G.UE.TArray(_G.UE.uint64)
    ExcludeActorTypes:Add(_G.UE.EActorType.Major)

    _G.UE.UActorManager:Get():HideAllActors(true, ExcludeActorID, ExcludeActorTypes)
end

function LoginMapMgr:OnGameEventMapChange(Params, bFirstLogin)
	if Params and Params.bFromCutScene then
		FLOG_INFO("LoginMapMgr bFromCutScene")
		return
	end

	local CurrMapResID = _G.PWorldMgr:GetCurrMapResID()
	if self.CurMapID == 0 or CurrMapResID > 0 and self.CurMapID ~= CurrMapResID then
		FLOG_INFO("LoginMapMgr CurMapID:%d", self.CurMapID)
		return
	end

	local WeatherList = self.AllMapWeathersList[self.CurMapID]
	if WeatherList then
		self.CurMapWeatherCount = #WeatherList
		if self.CurMapWeatherCount > 1 then
			self.bCurMapCanChangeWeather = true
		elseif self.CurMapWeatherCount == 0 then
			FLOG_ERROR("LoginMapMgr:PostLoadWorld CurMap %d No Weather", self.CurMapID)
			return -2
		else
			self.bCurMapCanChangeWeather = false
		end

		local Weather = WeatherList[1]
		local IsFixed = Weather.LockTime == 1 or false
		FLOG_INFO("LoginMapMgr:PostLoadWorld WeatherID:%d, StartTime:%d"
			, Weather.WeatherID, Weather.StartFrameNumber)

		_G.UE.UEnvMgr:Get():SetIgnoreTargetArmLength(true)

		self.WeatherID = Weather.WeatherID
		self.WeatherPlanID = Weather.WeatherPlanID
		self:SetWeatherStartFrameNum(Weather.StartFrameNumber)

		if not bFirstLogin then
			_G.WeatherMgr:PlaySpecialClientWeatherEffect(Weather.WeatherID, 0, Weather.StartFrameNumber, IsFixed)
		end
	end
end

function LoginMapMgr:GetWeatherPlanID(WeatherID, WeatherStartFrameNum)
	local WeatherList = self.AllMapWeathersList[self.CurMapID]
	if WeatherList then
		for index = 1, #WeatherList do
			local Weather = WeatherList[index]
			if Weather.WeatherID == WeatherID and Weather.StartFrameNumber == WeatherStartFrameNum then
				return Weather.WeatherPlanID
			end
		end
	end

	return nil
end

function LoginMapMgr:SetWeather(WeatherID)
	if WeatherID == self.WeatherID then
		return
	end

	self.WeatherID = WeatherID
	self.WeatherPlanID = self:GetWeatherPlanID(WeatherID, self.WeatherStartFrameNum)

	self:SetWeatherStartFrameNum(self.WeatherStartFrameNum)
	_G.WeatherMgr:PlaySpecialClientWeatherEffect(WeatherID, 0, self.WeatherStartFrameNum, true)
end

function LoginMapMgr:SetWeatherTime(Index)
	if Index <= 0 or Index > 3 then
		return
	end

	local Hour = self.WeatherTimeHourList[Index]
	local StartFrameNum = Hour * 3600

	if StartFrameNum == self.WeatherStartFrameNum then
		return
	end

	self.WeatherPlanID = self:GetWeatherPlanID(self.WeatherID, StartFrameNum)
	self:SetWeatherStartFrameNum(StartFrameNum)
	_G.WeatherMgr:PlaySpecialClientWeatherEffect(self.WeatherID, 2.0, self.WeatherStartFrameNum, true)
end

function LoginMapMgr:GetWeatherTimeHour()
	local Idx = LoginRoleShowPageVM:GetTimeIndex()
	if Idx >= 1 and Idx <= #self.WeatherTimeHourList then
		return self.WeatherTimeHourList[Idx]
	end

	return -1
end

--从WeatherStartFrameNum更新中午、傍晚、夜晚的index
function LoginMapMgr:SetWeatherStartFrameNum(FrameNum)
	self.WeatherStartFrameNum = FrameNum

	local Hour = self.WeatherStartFrameNum / 3600
	local Idx = 1
	for index = 1, #self.WeatherTimeHourList do
		if self.WeatherTimeHourList[index] >= Hour then
			Idx = index
			break
		end
	end

	LoginRoleShowPageVM:SetTimeIndex(Idx)

	local TodMainActor = _G.UE.UEnvMgr:Get():GetTodSystem()
	if TodMainActor and self.WeatherPlanID then
		local TodParamCfg = LoginMapTodparamCfg:FindCfgByKey(self.WeatherPlanID)
		if TodParamCfg and TodParamCfg.SunRiseAngle ~= 0 and TodParamCfg.ElevationPower ~= 0 then
			if CEnvMgr ~= nil then
				CEnvMgr:Get():SetTodLightParameter(TodParamCfg.SunRiseAngle
				, TodParamCfg.MainLightOrbitCurve, TodParamCfg.MainLightOrbitClamp
				, TodParamCfg.ElevationBias, TodParamCfg.ElevationPower, TodParamCfg.ElevationFade)
			end
			--TodMainActor:SetLightParam(TodParamCfg.SunRiseAngle
				--, TodParamCfg.MainLightOrbitCurve, TodParamCfg.MainLightOrbitClamp
				--, TodParamCfg.ElevationBias, TodParamCfg.ElevationPower, TodParamCfg.ElevationFade)
		end
	end

	local LightPresetPath = _G.LoginMapMgr:GetLightPresetPath()
	_G.LoginUIMgr:ResetLightPreset(LightPresetPath)
end

function LoginMapMgr:GetLightPresetPath()
	if not self.CurLoginMapCfg then
		return LoginConfig.DefaultLightConfig
	end

	local MapFolderName = self.CurLoginMapCfg.FolderName
	local Hour = self:GetWeatherTimeHour()
	local LightPresetPath = ""

	local WeatherEnglishName = ""
	local Cfg = self.LoginWeathers[self.WeatherID]
	if Cfg then
		WeatherEnglishName = Cfg.EnglishName
	end

	if Hour < 0 then
		FLOG_ERROR("Login lightpreset Hour is %d", Hour)
		-- LightPresetPath = string.format(LoginConfig.LightConfig, MapFolderName, MapFolderName, MapFolderName)
	else
		if self.CurLoginMapCfg.ID == LoginConfig.SelectRoleMap or self.CurLoginMapCfg.ID == LoginConfig.EquipmentMapID 
			or self.CurLoginMapCfg.ID == LoginConfig.RoomMapID then
			local AttachType = LoginRoleRaceGenderVM:GetCurRaceLightAttachType()
			if AttachType then
				LightPresetPath = string.format(LoginConfig.Z1C1Config, MapFolderName
					, MapFolderName, WeatherEnglishName, Hour, AttachType, MapFolderName, WeatherEnglishName, Hour, AttachType)

				if not _G.ObjectMgr:IsResExist(LightPresetPath) then
					FLOG_WARNING("Login lightpreset not Exist : %s", LightPresetPath)
					LightPresetPath = string.format(LoginConfig.LightHourConfig, MapFolderName
						, MapFolderName, WeatherEnglishName, Hour, MapFolderName, WeatherEnglishName, Hour)
				else
					FLOG_INFO("Login lightpreset : %s", LightPresetPath)
				end
			else
				LightPresetPath = string.format(LoginConfig.LightHourConfig, MapFolderName
					, MapFolderName, WeatherEnglishName, Hour, MapFolderName, WeatherEnglishName, Hour)

				FLOG_INFO("Login lightpreset : %s", LightPresetPath)
			end
		else
			LightPresetPath = string.format(LoginConfig.LightHourConfig, MapFolderName
				, MapFolderName, WeatherEnglishName, Hour, MapFolderName, WeatherEnglishName, Hour)
			FLOG_INFO("Login lightpreset : %s", LightPresetPath)
		end
		
		if not _G.ObjectMgr:IsResExist(LightPresetPath) then
			FLOG_ERROR("Login lightpreset not Exist: %s", LightPresetPath)
			-- LightPresetPath = string.format(LoginConfig.LightConfig, MapFolderName, MapFolderName, MapFolderName)
		end
	end

	return LightPresetPath
end

return LoginMapMgr