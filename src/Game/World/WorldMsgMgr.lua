--
-- Author: anypkvcai
-- Date: 2020-08-28 20:48:23
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local CommonUtil = require("Utils/CommonUtil")
local ProtoRes = require ("Protocol/ProtoRes")
local MajorUtil = require ("Utils/MajorUtil")
local ObjectGCType = require("Define/ObjectGCType")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local LoginConfig = require("Define/LoginConfig")
local SaveKey = require("Define/SaveKey")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local GameDataKey = require("Define/GameDataKey")

---@class WorldMsgMgr : MgrBase
local WorldMsgMgr = LuaClass(MgrBase)

local BeginLoadTime = 0
local LoadingTimer = 0
local LuaFixTimer = 0

WorldMsgMgr.IsShowLoadingView = false
function WorldMsgMgr:OnInit()
	print("WorldMsgMgr:OnInit")
    self.IsClosePlayLoadingScreen = false
    self.HasMarkLevelLoad = false
    self.LastLoadingMapResID = 0
end

function WorldMsgMgr:OnBegin()
end

function WorldMsgMgr:OnEnd()
end

function WorldMsgMgr:OnShutdown()
    --确保Editor下PIE结束时加载参数会被还原
    local GameInstance = _G.UE.UFGameInstance.Get()
    if CommonUtil.IsWithEditor() then
        GameInstance:UpdateAsyncLoadingArgs(false)
    end

    -- local SettingsTabPicture = SettingsUtils.GetSettingTabs("SettingsTabPicture")
    -- if SettingsTabPicture then
    --     SettingsTabPicture:RefreshMaxFps()
    -- end
end

function WorldMsgMgr:OnRegisterNetMsg()

end

function WorldMsgMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
    self:RegisterGameEvent(_G.EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
end

function WorldMsgMgr:OnGameEventAppEnterBackground()
end

function WorldMsgMgr:OnGameEventAppEnterForeground()
    -- 从后台切回前台的时候刷新一下计时器, 不然会被提前关闭Loading界面
    if self.CheckLoadingTimerID then
        _G.TimerMgr:FlushTimer(self.CheckLoadingTimerID)
    end
end

--在DelayHideLoading期间，服务器又下发了进入新副本协议，导致加载期间把loading关闭，所以先强制关闭上一个loading，清除定时器，重新开启流程
function WorldMsgMgr:ForceMarkLastLevelLoadCompleted()
    if (self.IsShowLoadingView and self.DelayLoadingTimerID ~= nil) then
        FLOG_INFO("WorldMsgMgr:ForceMarkLastLevelLoadCompleted")
        self:MarkLevelLoadCompleted() 
    end
end

--检测loading是否超时，超时后强制关闭，防止卡loading
function WorldMsgMgr:ForceHideLoading()
    FLOG_INFO("WorldMsgMgr:ForceHideLoading")
    if (self.IsShowLoadingView) then
        self:HideLoadingView()
    end
end

function WorldMsgMgr:ShowLoadingView(CurWorldName, NextWorldName)
    WorldMsgMgr.IsShowLoadingView = true

    local CurrMapResID = _G.PWorldMgr:GetCurrMapResID()
    local LastMapResID = self.LastLoadingMapResID or 0
    FLOG_INFO("WorldMsgMgr.ShowLoadingView(): From %s(%d) to %s(%d)", CurWorldName, LastMapResID, NextWorldName, CurrMapResID)
    local UseDefault = self.IsClosePlayLoadingScreen
        or (CurrMapResID == LastMapResID)  -- 同地图传送只显示黑屏Loading
        or (NextWorldName == LoginConfig.DemoSkillWorldName)
        or (NextWorldName == "Login")
        or _G.PWorldMgr:GetIsDailyRandom() -- 日随只显示黑屏Loading

    self.LastLoadingMapResID = CurrMapResID

    _G.LoadingMgr:ShowLoadingView(UseDefault)

    local MaxLoadingTime = 120
    if CommonUtil.IsWithEditor() then
        MaxLoadingTime = 300
    end
    if self.CheckLoadingTimerID then
		_G.TimerMgr:CancelTimer(self.CheckLoadingTimerID)
		self.CheckLoadingTimerID = nil
	end
    self.CheckLoadingTimerID = _G.TimerMgr:AddTimer(self, self.ForceHideLoading, MaxLoadingTime, 1, 1)
end

function WorldMsgMgr:DelayHideLoadingView(DelayTime)
    if LoginUIMgr.RenderActorCreated == false then
        return
    end

    if self.DelayLoadingTimerID then
		_G.TimerMgr:CancelTimer(self.DelayLoadingTimerID)
		self.DelayLoadingTimerID = nil
	end
    self.DelayLoadingTimerID = _G.TimerMgr:AddTimer(self, self.HideLoadingView, DelayTime, 0.1, 1)
end

function WorldMsgMgr:HideLoadingView()
    --FLOG_INFO("WorldMsgMgr:HideLoadingView")
    WorldMsgMgr.IsShowLoadingView = false

    if self.CheckLoadingTimerID then
		_G.TimerMgr:CancelTimer(self.CheckLoadingTimerID)
		self.CheckLoadingTimerID = nil
	end

    if self.DelayLoadingTimerID then
		_G.TimerMgr:CancelTimer(self.DelayLoadingTimerID)
		self.DelayLoadingTimerID = nil
	end

    --sequence还在加载资源，不用实际隐藏loading界面
    if (not _G.StoryMgr:SequenceIsLoading()) then
        local bOK = _G.LoadingMgr:HideLoadingView()

        -- 显示黑屏渐隐
        if bOK then  -- and not _G.UIViewMgr:IsViewVisible(UIViewID.CommonFadePanel) then
            local Params = {}
            Params.FadeColorType = 1
            Params.Duration = 1
            Params.bAutoHide = true
            _G.UIViewMgr:ShowView(UIViewID.CommonFadePanel, Params)
            -- FLOG_INFO("loiafeng debug: WorldMsgMgr Show CommonFadePanel")
        end
    else
        FLOG_INFO("WorldMsgMgr:HideLoadingView SequenceIsLoading!!!!")
    end

end

function WorldMsgMgr:OnEnterMapFinish()
    FLOG_INFO("WorldMsgMgr:OnEnterMapFinish")

    local DefaultWidget = UIViewID.MainPanel

    local CurrPWorldType = _G.PWorldMgr:GetCurrPWorldType()
    if CurrPWorldType == ProtoRes.pworld_type.PWORLD_CATEGORY_DEMO then
        local PWorldInfo = _G.PWorldMgr:GetCurrPWorldTableCfg()
        if PWorldInfo then
            if PWorldInfo.MainPanelUIType and PWorldInfo.MainPanelUIType ~= 0 then
                DefaultWidget = nil
            end
        end
        --LoginMapMgr:PostLoadWorld中会显示演示场景的主界面
    elseif CurrPWorldType == ProtoRes.pworld_type.PWORLD_CATEGORY_DUNGEON then
        if _G.RideShootingMgr:IsRideShootingDungeon()
            or _G.PWorldMgr:CurrIsInPVPColosseum() then
            DefaultWidget = nil
        end
    end

    -- 设置消息轮播模式
    if _G.PWorldMgr:CurrIsInPVPColosseum() then
		_G.MsgTipsUtil.SetSliderMode("PVP")
	else
		_G.MsgTipsUtil.SetSliderMode("Normal")
	end

    local DelayTime = 0.5  -- loiafeng: 等待0.5秒，等Loading界面走完进度条
    -- if _G.IsDemoMajor then
    if _G.DemoMajorType == 1 then
        DelayTime = 1
        UIViewMgr:ShowView(UIViewID.LoginDemoSkill)
    else
        if (DefaultWidget) then
            if not _G.PWorldMgr:CurrIsInDungeon() and not _G.PWorldMgr:IsReconnectInSameMap() then
                self:RegisterTimer(function()
                    if not UIViewMgr:IsViewVisible(UIViewID.InfoJobNulockTipsView) then
                        _G.BusinessUIMgr:ShowMainPanel(DefaultWidget)
                    end
                    _G.DeepLinkMgr:TryDoActionManual()
                end, 0.5)
                -- 切地图后进入地图提示
                _G.MsgTipsUtil.ShowEnterMapTips()
            else
                _G.BusinessUIMgr:ShowMainPanel(DefaultWidget)
            end
        end
    end

    if _G.LoginMapMgr:GetCurMapID() > 0 then
        DelayTime = 3
    end

    self.DelayLoadingTimerID = _G.TimerMgr:AddTimer(self, self.MarkLevelLoadCompleted, DelayTime, 0.1, 1)

	-- self:HideLoadingView()
end

--function WorldMsgMgr:OnGameEventMajorEntityIDUpdate(Params)
--	--_G.BusinessUIMgr:HideMainPanel(UIViewID.MainPanel)
--	BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel)
--end

--切换地图开始
function WorldMsgMgr:PreLoadWorld(CurWorldName, NextWorldName)
	BeginLoadTime = _G.TimeUtil.GetLocalTimeMS()
	_G.TimerMgr:CancelTimer(LoadingTimer)
	LoadingTimer = 0

	if CurWorldName == "z1c1" and _G.LoginMapMgr:IsRealLoginMap() then
        LoginUIMgr:HideCreateRoleView()
        LoginUIMgr:HideSelectRoleView()
	end

    if (_G.PWorldMgr:LoadWorldInClientRestore()) then
        self:ShowLoadingView(CurWorldName, NextWorldName)

    elseif _G.PWorldMgr:IsChangeLine()
        or _G.PWorldMgr:IsChangePhaseMap()
        or _G.PWorldMgr:IsCrossWorld() then
        -- 不显示loading界面：地图切线、跨界传送、相位副本
        -- loiafeng: 没显示Loading也要记录一下LastLoadingMapResID
        self.LastLoadingMapResID = _G.PWorldMgr:GetCurrMapResID()
    else
        self:ShowLoadingView(CurWorldName, NextWorldName)
    end

    local bChangeMap = (CurWorldName ~= NextWorldName)
    FLOG_INFO("WorldMsgMgr:PreLoadWorld CurWorldName=%s, NextWorldNam=%s, bChangeMap=%s", CurWorldName, NextWorldName, tostring(bChangeMap))

    --切换新地图前, 发送离开旧地图事件
    local Params = _G.EventMgr:GetEventParams()
	Params.BoolParam1 = bChangeMap
    _G.EventMgr:SendCppEvent(EventID.PWorldMapExit, Params)
    _G.EventMgr:SendEvent(EventID.PWorldMapExit, bChangeMap)

    self:MarkLevelLoad()

    --放到PWorldMapExit后执行，一些清除操作依赖于MajorEntityID
    _G.PWorldMgr:UpdateMajorEntityID()

    --跟PWorldMapExit和PWorldMapEnter配对使用
    _G.CommonUtil.DisableShowJoyStick(true)
    --清除虚拟摇杆
    _G.CommonUtil.HideJoyStick()

    LifeMgrModule.ShutdownLevelLife()

	--切图前清理一波缓存
	collectgarbage("collect")
	_G.ObjectMgr:UnloadAll(false, true)
end

--切换地图结束
function WorldMsgMgr:PostLoadWorld(LastWorldName, CurWorldName, LoadWorldReason)
    FLOG_INFO("WorldMsgMgr:PostLoadWorld LastWorldName=%s, CurWorldName=%s, LoadWorldReason=%d", LastWorldName, CurWorldName, LoadWorldReason)
    self.CurWorldName = CurWorldName

    --  --TODO[chaooren] 临时修改究极神兵假想作战副本内怪物数量上限
    -- local CommonDefine = require("Define/CommonDefine")
    -- if CurWorldName == "w1fb" then
    --     CommonDefine.VisionMonsterMaxCountDungeon = 25
    --     CommonDefine.VisionTotalMaxCount = 30
    --     _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(2, true, 25)
    --     _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(0, true, 30)
    -- else
    --     --TODO[shuangteng] 现在通过机型定级从表格读取视野的配置，由于之前针对究极神兵做了特殊处理，所以读取逻辑写在这里
    --     local VisionCountLodCfg = require("TableCfg/VisionCountLodCfg")
    --     local Level = _G.UE.USettingUtil.GetDefaultQualityLevel()
    --     local FinialLevel = Level
    --     if Level < 0 or Level > 4 then
    --         FinialLevel = 2
    --     end
    --     local Cfg = VisionCountLodCfg:FindCfgByKey(FinialLevel)
    --     if Cfg then
    --         CommonDefine.VisionTotalMaxCount = Cfg.VisionTotalMaxCount
    --         CommonDefine.VisionPlayerMaxCount = Cfg.VisionPlayerMaxCount
    --         CommonDefine.VisionMonsterMaxCount = Cfg.VisionMonsterMaxCount
    --         CommonDefine.VisionMonsterMaxCountDungeon = Cfg.VisionMonsterMaxCountDungeon
    --         CommonDefine.VisionNPCMaxCount = Cfg.VisionNPCMaxCount
    --         CommonDefine.VisionCompanionMaxCount = Cfg.VisionCompanionMaxCount
    --         CommonDefine.VisionPlayerMaxCacheCount = Cfg.VisionPlayerMaxCacheCount
    --         CommonDefine.VisionMonsterMaxCacheCount = Cfg.VisionMonsterMaxCacheCount
    --         CommonDefine.VisionNPCMaxCacheCount = Cfg.VisionNPCMaxCacheCount
    --         CommonDefine.VisionCompanionMaxCacheCount = Cfg.VisionCompanionMaxCacheCount

    --         _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(0, false, Cfg.VisionTotalMaxCount)
    --         _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(1, false, Cfg.VisionPlayerMaxCount)
    --         _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(2, false, Cfg.VisionMonsterMaxCount)
    --         _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(2, true, Cfg.VisionMonsterMaxCountDungeon)
    --         _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(3, false, Cfg.VisionNPCMaxCount)
    --         _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(4, false, Cfg.VisionCompanionMaxCacheCount)

    --         _G.UE.UConfigMgr.Get().VisionPlayerMaxCacheCount = Cfg.VisionPlayerMaxCacheCount
    --         _G.UE.UConfigMgr.Get().VisionMonsterMaxCacheCount = Cfg.VisionMonsterMaxCacheCount
    --         _G.UE.UConfigMgr.Get().VisionNPCMaxCacheCount = Cfg.VisionNPCMaxCacheCount
    --         _G.UE.UConfigMgr.Get().VisionCompanionMaxCacheCount = Cfg.VisionCompanionMaxCacheCount
    --     else
    --         -- 保底的默认配置
    --         FLOG_ERROR("read VisionCountLodCfg error", Level, FinialLevel)
    --         CommonDefine.VisionTotalMaxCount = 20
    --         CommonDefine.VisionPlayerMaxCount = 7
    --         CommonDefine.VisionMonsterMaxCount = 10
    --         CommonDefine.VisionMonsterMaxCountDungeon = 15
    --         CommonDefine.VisionNPCMaxCount = 7
    --         CommonDefine.VisionCompanionMaxCount = 3
    --         CommonDefine.VisionPlayerMaxCacheCount = 7
    --         CommonDefine.VisionMonsterMaxCacheCount = 5
    --         CommonDefine.VisionNPCMaxCacheCount = 3
    --         CommonDefine.VisionCompanionMaxCacheCount = 3

    --         _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(0, false, 20)
    --         _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(1, false, 7)
    --         _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(2, false, 10)
    --         _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(2, true, 15)
    --         _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(3, false, 7)
    --         _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(4, false, 3)

    --         _G.UE.UConfigMgr.Get().VisionPlayerMaxCacheCount = 7
    --         _G.UE.UConfigMgr.Get().VisionMonsterMaxCacheCount = 5
    --         _G.UE.UConfigMgr.Get().VisionNPCMaxCacheCount = 3
    --         _G.UE.UConfigMgr.Get().VisionCompanionMaxCacheCount = 3
    --     end
    -- end

    _G.LoginMapMgr.CurLoginMapType = _G.LoginMapType.Login

    --sequence内部切换场景是纯客户端切换，不走后续逻辑，否则获取的动态数据跟地图不匹配
    if (_G.UE.ELoadWorldReason and LoadWorldReason == _G.UE.ELoadWorldReason.CutScene) then
        _G.PWorldMgr:PostLoadWorldForCutScene()
        --切图后GC一波
        collectgarbage("collect")
        _G.ObjectMgr:ForceGarbageCollection(true)
        return
    end

    _G.UE.UEnvMgr:Get():SetIgnoreTargetArmLength(false)

    local bCreateRoleMap = false
    local DelayHideLoadingTime = 0.5
    local LoginUIMgr = _G.LoginUIMgr

	if CurWorldName == "Login" then
        self.bShowLogin = true
        -- _G.LoginUIMgr:ShowSelectRoleView()
        _G.LoginMapMgr:ChangeLoginMap(LoginConfig.SelectRoleMap, true)
        _G.LoginMapMgr:PostLoadWorld("Login", CurWorldName, true)
        --self:ShowLogin(LastWorldName)
    elseif self:IsCreateRoleMap(CurWorldName) then  --选角或者创角的场景
        if self.bShowLogin then
            FLOG_INFO("WorldMsgMgr:PostLoadWorld Show LoginView ")
            _G.LoginMgr:CreateLoginScene(true)
            self.bShowLogin = false
            self:ShowLogin(LastWorldName)
            LoginUIMgr:CreateCameraActor()

            --local IsMute = _G.UE.USaveMgr.GetInt(SaveKey.IsCGMute, 0, false) == 1
            --if not IsMute then
            --    _G.LoginMapMgr:RestoreBGM()
            --end
            return
        end
        FLOG_INFO("WorldMsgMgr:PostLoadWorld Show CreateRoleView ")

        bCreateRoleMap = true

        LoginUIMgr:CreateCameraActor() --要在LoginMapMgr:PostLoadWorld之前
        _G.LoginMapMgr:PostLoadWorld(LastWorldName, CurWorldName)
        _G.LoginMgr:CreateLoginScene()
        --从选职业到技能演示副本退回login
        if LoginUIMgr.CurLoginRolePhase > 0 then
            if _G.LoginMgr:GetLastRoleLogOutReason() == ProtoCS.LogoutReason.ExitDemo or _G.DemoMajorType == 1 then
                --将来会是别的场景名就不会有这个2次进入的问题（Login.cpp和WorldMgr.cpp都过来）
                --所以先临时处理下吧
                LoginUIMgr:OnLoginLoadFinish()

                self:DelayHideLoadingView(DelayHideLoadingTime)
            else
                LoginUIMgr:ReturnCurPhaseView(true)
                LoginUIMgr:CreateRenderActor()
                -- LoginUIMgr:UpdateRoleFacePreset()

                -- UIViewMgr:ShowView(UIViewID.LoginMain)
                CommonUtil.HideJoyStick()
                self:DelayHideLoadingView(DelayHideLoadingTime)
            end
        --返回到选角界面
        else
            if _G.LoginMgr:GetLastRoleLogOutReason() == ProtoCS.LogoutReason.SwitchRole then
                if not _G.LoginMgr:GetIsWaitRoleListMsg() then
                    _G.LoginMgr:QueryRoleList()
                end
            else
                LoginUIMgr:ReturnCurPhaseView(true)
                LoginUIMgr:CreateRenderActor()
                -- LoginUIMgr:UpdateRoleFacePreset()

                CommonUtil.HideJoyStick()

                self:DelayHideLoadingView(DelayHideLoadingTime)
            end
        end

        _G.LoginMgr:SetLastRoleLogOutReason(nil)
    elseif self:IsSpecialLoginMap(CurWorldName) then
        local PWorldInfo = _G.PWorldMgr:GetCurrPWorldTableCfg()
        if PWorldInfo then
            _G.LoginMapMgr:SetMainPanelUIType(PWorldInfo.MainPanelUIType)
        end
        -- _G.LoginMapMgr.CurLoginMapType = _G.LoginMapType.HairCut

        _G.LoginMapMgr:OnSvrChangeLoginMap(true)

        LoginUIMgr.IsShowPreviewPage = _G.UE.USaveMgr.GetInt(SaveKey.ShowPreviewPage, 0, true) == 1

        _G.LoginMgr:CreateLoginScene()
        LifeMgrModule.StartLevelLife("LevelLife")
        _G.PWorldMgr:PostLoadWorld()
        _G.UE.UBGMMgr.Get():SetKeepBGMWhenWorldChange(true)

        LoginUIMgr:CreateCameraActor()--要在LoginMapMgr:PostLoadWorld之前
        local Rlt = _G.LoginMapMgr:PostLoadWorld(LastWorldName, CurWorldName)
        if Rlt == -1 then   --第一次进入理发屋的装备界面场景
            DelayHideLoadingTime = 1
        else
        end
        local bFirstEnterHairCutMap = _G.LoginMapMgr.bFirstEnterHairCutMap
        if PWorldInfo and PWorldInfo.MainPanelUIType == _G.LoginMapType.Fantasia then
            --首次进入幻想药副本时调用ShowCreateRoleView进行展示，否则只是在幻想药流程中切换预览副本
            if not LoginUIMgr.IsInFantasia then
                --传入LoginMapCfgID的原因是，如果上次在幻想药预览场景中登出，再重新登录时仍然处在预览场景，直接显示对应的预览场景
                LoginUIMgr:PreFantasia()
                LoginUIMgr:ShowCreateRoleView()
                LoginUIMgr:BeginFantasia()

                if LoginUIMgr.IsShowPreviewPage then
                    LoginUIMgr:OnShowPreviewPage()
                end
            elseif not LoginUIMgr.IsShowPreviewPage then
                --当前不是预览界面，却发生了切地图，应该是在外貌界面进行了预览场景切换，需要返回当前阶段
                LoginUIMgr:ReturnCurPhaseView(true)
                LoginUIMgr:CreateRenderActor()
                LoginUIMgr:ResetMorePageBtnState()
            else
                --当前是预览界面，返回的时候已经调用了ReturnCurPhaseView，这里不需要处理
                LoginUIMgr:CreateRenderActor()
            end
        else
            if LoginUIMgr.IsShowPreviewPage then
                LoginUIMgr:OnShowPreviewPage()
            end
            if bFirstEnterHairCutMap then
                if _G.HaircutMgr.bReconnect then
                    LoginUIMgr:CreateRenderActor(true)
                else
                    LoginUIMgr:CreateRenderActor()
                end
            else
                LoginUIMgr:CreateRenderActor()
            end

        end

        -- LoginUIMgr:UpdateRoleFacePreset()

        self:DelayHideLoadingView(DelayHideLoadingTime)
        CommonUtil.HideJoyStick()
	else
        -- 从幻想药界面直接退出，比如副本匹配的情况，要进行清理
        if LoginUIMgr.IsInFantasia then
            LoginUIMgr:DoExitFantasia({ExitAfterLoadWorld = true})
        end

        LoginUIMgr:ReleaseCameraActor()
        LoginUIMgr:ResetRecordUI()
        _G.LoginMapMgr:Reset()
        _G.LoginMgr:ReleaseLoginScene()

		-- 临时, 缓存GM界面避免手机上加载时 crash
		-- 是有其他地方数据库未Destroy导致
		--UIViewMgr:ShowView(UIViewID.GMMain)
		--UIViewMgr:HideView(UIViewID.GMMain)

        LifeMgrModule.StartLevelLife("LevelLife")

        _G.PWorldMgr:PostLoadWorld()

        -- local SettingsTabPicture = SettingsUtils.GetSettingTabs("SettingsTabPicture")
        -- if SettingsTabPicture then
        --     SettingsTabPicture:RefreshMaxFps()
        -- end
	end

	--不需要创建Major的副本
	if WorldMsgMgr:IsSpecial() and not bCreateRoleMap then
		--起码使Loading显示够1秒
		-- local LoadTime = _G.TimeUtil.GetLocalTimeMS() - BeginLoadTime
		-- local DelayTime = 1000 - LoadTime
		-- if (DelayTime < 0) then
		-- 	DelayTime = 0
		-- end

        self:HideLoadingView()
	end

    --切图后GC一波
	collectgarbage("collect")
	_G.ObjectMgr:ForceGarbageCollection(true)

    --Lua热更功能
    WorldMsgMgr:LuaFix()
end

function WorldMsgMgr:ShowLogin(LastWorldName)
    -- _G.LoginMapMgr:Reset()

    --刚启动客户端的时候，进入登录界面
    local IsClientStartUp = false
    if not LastWorldName or string.len(LastWorldName) == 0 then
        IsClientStartUp = true
    end

    if IsClientStartUp and _G.LoginMgr:GetLastRoleLogOutReason() then
        return
    end

    UIViewMgr:ShowView(_G.LoginMgr:GetLoginMainViewId())
    _G.LoginMgr:ResetTodPostProcessComBlendWeight()
    UIViewMgr:HideView(UIViewID.LoginRoleRender2D)
    UIViewMgr:HideView(UIViewID.LoginSelectRoleNew)
    CommonUtil.HideJoyStick()

    self:HideLoadingView()

    _G.LoginMgr:SetLastRoleLogOutReason(nil)
end


--region 预加载资源

local MajorProfID = -1
local IsPreloadHoldFinish = false
local PreloadHoldList = {}
local PreloadMapList = {}
local ResSoftPath = _G.UE.FSoftObjectPath()

local function AddToPreloadList(LoadList, ResPath)
    if ResPath ~= nil and ResPath ~= "" and LoadList[ResPath] == nil then
        LoadList[ResPath] = 1
    end
end

local function PreLoadObject(ResPath, ResGCType)
	if ResPath == nil or ResPath == "" then
		return
	end

	ResSoftPath:SetPath(ResPath)
	if not _G.UE.UCommonUtil.IsObjectExist(ResSoftPath) then
		--角色、怪物等会走固定组装逻辑，有些资源本身就不存在，这部分不输出Log
		if string.find(ResPath, "/Game/Assets/Character") ~= nil then
			return
		end

		print("PreLoadObject not exist on disk: "..ResPath)
		return
	end
	_G.UE.UObjectMgr.PreLoadObject(ResPath, ResGCType)
end

function WorldMsgMgr:PreloadCharacterResources()
    local _ <close> = CommonUtil.MakeProfileTag("PreloadCharacterResources")
    -- 预加载加载角色相关的资源 从c++转移到lua
    if not self.IsPreloadCharacterFinished then
        self.IsPreloadCharacterFinished = true
        local CharacterPreloadHoldList = _G.ActorMgr:GetPreloadResources()
        for _, Path in ipairs(CharacterPreloadHoldList) do
            PreLoadObject(Path, ObjectGCType.Hold)
        end
    end
end

function WorldMsgMgr:PreLoadResources(bChangeMap)
    self:PreloadCharacterResources()

    -- iOS不预加载
	if CommonUtil.IsIOSPlatform() then
        return
    end

    if not bChangeMap then
        return
    end

    if WorldMsgMgr:IsSpecial() then
        return
    end

    local _ <close> = CommonUtil.MakeProfileTag("PreLoadResources")

    --临时扩大Lru池子容量
    _G.ObjectMgr:SetLruPoolMaxSize(300)
    print("LruPoolMaxSize: "..tostring(_G.ObjectMgr:GetLruPoolMaxSize()))

    local TotalMemStart = _G.UE.UPlatformUtil.GetUsedPhysicalMemory()

    --预加载资源 - Hold型
    --重新计算列表的条件：如换职业
    local MajorProfIDNew = MajorUtil.GetMajorProfID()
    if MajorProfID ~= MajorProfIDNew then
        IsPreloadHoldFinish = false
        MajorProfID = MajorProfIDNew
    end

    if not IsPreloadHoldFinish then
        IsPreloadHoldFinish = true
        PreloadHoldList = {}
        --1、手动配置的资源
        local PreLoadConfig = require("Define/PreLoadConfig")
		for _, value in pairs(PreLoadConfig[ObjectGCType.Hold]) do
			AddToPreloadList(PreloadHoldList, value)
		end

        --2、HUD
        local HUDType = require("Define/HUDType")
        local HUDConfig = require("Define/HUDConfig")
        for _, value in pairs(HUDType) do
            AddToPreloadList(PreloadHoldList, HUDConfig:GetPath(value))
        end

--[[ 之前配置的文件不存在了，需要预加载的要重新配置，暂时先配加I相关
        --3、Buff图标
        local BuffCfg = require("TableCfg/BuffCfg")
		local BuffIconList = BuffCfg:FindAllCfg("BuffIcon is not null and trim(BuffIcon) != ''")
        if BuffIconList ~= nil then
		    for _, value in pairs(BuffIconList) do
                AddToPreloadList(PreloadHoldList, value.BuffIcon)
		    end
        end

        --4、自己职业技能特效、动作
        local SkillEffects = _G.UE.USkillMgr.Get():GetEffectPathListByProfID(MajorProfID)
        if SkillEffects ~= nil then
            for i = SkillEffects:Length(), 1, -1 do
               AddToPreloadList(PreloadHoldList, SkillEffects:Get(i))
            end
        end

        local MajorAnims = _G.UE.USkillMgr.Get():GetAnimPathListByProfID(MajorProfID)
        if MajorAnims ~= nil then
            for i = MajorAnims:Length(), 1, -1 do
               AddToPreloadList(PreloadHoldList, MajorAnims:Get(i))
            end
        end

        --5、装备界面角色蓝图类
        local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
        AddToPreloadList(PreloadHoldList, EquipmentMgr:GetEquipmentCharacterClass())
        AddToPreloadList(PreloadHoldList, EquipmentMgr:GetLightConfig())
        --其它

        local SkillPreLoad = require("Game/Skill/SkillPreLoad")
        SkillPreLoad.PreLoadOnEnterGame()
--]]
    end

	--加载Hold型资源：每次都全部判定一次，避免手动unload了Hold的资源，导致下次加载卡顿
	do
        local _ <close> = CommonUtil.MakeProfileTag("PreLoadResources_Hold")
        local PreloadHoldNum = 0
        for key, _ in pairs(PreloadHoldList) do
            PreloadHoldNum = PreloadHoldNum + 1
            PreLoadObject(key, ObjectGCType.Hold)
            --print("Preload Hold Assets: "..key)
        end
        print("Preload Hold Assets: "..tostring(PreloadHoldNum))
    end

--[[ 之前配置的文件不存在了，需要预加载的要重新配置，暂时先配加I相关
    --预加载资源 - Map型：跟随副本
    --副本中
    if _G.PWorldMgr:CurrIsInDungeon() then
        PreloadMapList = {}
		local PWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
		--1、手动配置的资源
		local PreLoadConfig = require("Define/PreLoadConfig")
		for _, value in pairs(PreLoadConfig[ObjectGCType.Map]) do
			AddToPreloadList(PreloadMapList, value)
		end

        --2、队友技能特效、动作
        local TeamMgr = require("Game/Team/TeamMgr")
        local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
        local RoleList = TeamMgr:GetMemberRoleIDList()
        for i = #(RoleList), 1, -1 do
            if not MajorUtil.IsMajorByRoleID(RoleList[i]) then
                local RoleData, _ = RoleInfoMgr:FindRoleVM(RoleList[i], true)
                if RoleData ~= nil then
                    local ProfID = RoleData.Prof
                    if ProfID > 0 and ProfID ~= MajorProfID then
                        local SkillEffects = _G.UE.USkillMgr.Get():GetEffectPathListByProfID(ProfID)
                        if SkillEffects ~= nil then
                            for j = SkillEffects:Length(), 1, -1 do
                                AddToPreloadList(PreloadMapList, SkillEffects:Get(j))
                            end
                        end

                        local MajorAnims = _G.UE.USkillMgr.Get():GetAnimPathListByProfID(ProfID)
                        if MajorAnims ~= nil then
                            for j = MajorAnims:Length(), 1, -1 do
                                AddToPreloadList(PreloadMapList, MajorAnims:Get(j))
                            end
                        end
                    end
                end
            end
        end

        --3、Boss特效、动作（小怪的后续需策划配合实现）
        local BossEffects = _G.UE.USkillMgr.Get():GetCurEffectPathListByMonSubType(3)
        if BossEffects ~= nil then
            for i = BossEffects:Length(), 1, -1 do
                AddToPreloadList(PreloadMapList, BossEffects:Get(i))
            end
        end

        local BossAnim = _G.UE.USkillMgr.Get():GetCurAnimPathListByMonSubType(3)
        if BossAnim ~= nil then
            for i = BossAnim:Length(), 1, -1 do
                AddToPreloadList(PreloadMapList, BossAnim:Get(i))
            end
        end

        --4、Boss、小怪模型
        local ActorUtil = require ("Utils/ActorUtil")
        local ProtoRes = require ("Protocol/ProtoRes")
        local MonsterCfg = require("TableCfg/MonsterCfg")
        local BossIDList = _G.MapEditDataMgr:GetMonsterResIDList(ProtoRes.monster_sub_type.MONSTER_SUB_TYPE_BOSS, false)
        local NormalIDList = _G.MapEditDataMgr:GetMonsterResIDList(ProtoRes.monster_sub_type.MONSTER_SUB_TYPE_NORMAL, false)
        local MapMonsterList = {}
        if BossIDList ~= nil then
            for i = BossIDList:Length(), 1, -1 do
				local BossID = BossIDList:Get(i)
				if MapMonsterList[BossID] == nil then
					MapMonsterList[BossID] = 1
				else
					MapMonsterList[BossID] = MapMonsterList[BossID] + 1
				end
            end
        end

        if NormalIDList ~= nil then
            for i = NormalIDList:Length(), 1, -1 do
				local NormalID = NormalIDList:Get(i)
				if MapMonsterList[NormalID] == nil then
					MapMonsterList[NormalID] = 1
				else
					MapMonsterList[NormalID] = MapMonsterList[NormalID] + 1
				end
            end
        end

        --怪物是组装起来的，需获取资源列表
        for key, _ in pairs(MapMonsterList) do
            if key ~= '' then
                --用到的模型、材质
                local CfgRow = MonsterCfg:FindCfg("ID = "..tostring(key))
                if CfgRow ~= nil and CfgRow.ProfileName ~= '' then
                    local ResList = _G.UE.UAvatarEditorAssetMgr.CollectSoftPathOfProfile(CfgRow.AnatomyName, CfgRow.ProfileName)
                    if ResList ~= nil then
                        for i = ResList:Length(), 1, -1 do
                            AddToPreloadList(PreloadMapList, ResList:Get(i))
                        end
                    end
                end

                --用到的动作
                local AnimList = ActorUtil.GetMonsterAnimations(key)
                if AnimList ~= nil then
                    for i = #(AnimList), 1, -1 do
                        AddToPreloadList(PreloadMapList, AnimList[i])
                    end
                end
            end
        end

		--5、Buff特效
        local BuffCfg = require("TableCfg/BuffCfg")
		local BuffEffectList = BuffCfg:FindAllCfg("EffectPath is not null and trim(EffectPath) != ''")
        if BuffEffectList ~= nil then
		    for _, value in pairs(BuffEffectList) do
                AddToPreloadList(PreloadMapList, value.EffectPath)
		    end
        end

		--6、战斗状态动作
		local CombatStatCfg = require("TableCfg/CombatStatCfg")
		local CombatStatList = CombatStatCfg:FindAllCfg("Param != '{}' or ReviveActionID != ''")
        if CombatStatList ~= nil then
		    for _, value in pairs(CombatStatList) do
                AddToPreloadList(PreloadMapList, value.ReviveActionID)

			    if value.Param ~= nil and value.Param ~= "" and value.StateCompose == "1" then
                    for _, valueInner in pairs(value.Param) do
                        if valueInner ~= "" then
                            AddToPreloadList(PreloadMapList, valueInner)
                        end
                    end
			    end
		    end
        end

        --其它


		--加载Map型资源
        do
            local _ <close> = CommonUtil.MakeProfileTag("PreLoadResources_Map"..tostring(PWorldResID))
            local PreloadMapNum = 0
            for key, _ in pairs(PreloadMapList) do
                PreloadMapNum = PreloadMapNum + 1
                PreLoadObject(key, ObjectGCType.Map)
                --print(string.format("Preload Map%d Asset: %s", PWorldResID, key))
            end
            print(string.format("Preload Map%d Assets: %d", PWorldResID, PreloadMapNum))
        end

		--预创建Map型Actor：Boss、小怪
        --现在做了通用性的预创建，这块流程在预创建前，建议后续开启预加载后关闭这里的创建
        do
            local _ <close> = CommonUtil.MakeProfileTag("PreLoadResources_Map_CreateActor"..tostring(PWorldResID))
            local PrecreateActorNum = 0
            for key, value in pairs(MapMonsterList) do
                PrecreateActorNum = PrecreateActorNum + value
                UE.UActorManager:Get():CreateCacheActors(key, value, UE.EActorType.Monster)
                --print(string.format("Precreate Actor(Monster), ID: %d, Count: %d", key, value))
            end
            print("Precreate Actors(Monster): "..tostring(PrecreateActorNum))
        end

        --召唤兽
        local BuffSummonList = BuffCfg:FindAllCfg("SummonID > 0")
        local SummonCfg = require("TableCfg/SummonCfg")
        if BuffSummonList ~= nil then
            for _, value in pairs(BuffSummonList) do
                local Cfg = SummonCfg:FindCfgByKey(value.SummonID)
                if Cfg ~= nil then
                    local ResList = _G.UE.UAvatarEditorAssetMgr.CollectSoftPathOfProfile(Cfg.AnatomyName, Cfg.ProfileName)
                    if ResList ~= nil then
                        for i = ResList:Length(), 1, -1 do
                            AddToPreloadList(PreloadMapList, ResList:Get(i))
                        end
                    end
                end

                local Paths = _G.UE.UActorManager:Get():GetSummonAnimationPaths(value.SummonID)
                local AnimList = Paths:ToTable()
                if AnimList ~= nil then
                    for i = #(AnimList), 1, -1 do
                        AddToPreloadList(PreloadMapList, AnimList[i])
                    end
                end
            end
        end
    end


    --野外
    if _G.PWorldMgr:CurrIsInField() then

    end

    --其他Map级别的 (这个预加载功能是ok的，现在只考虑副本的，暂时屏蔽)
    -- local PreloadOtherMapList = {}

    -- --Npc的AnimDAName\ModelPath
    -- local NpcList = _G.MapEditDataMgr:GetNpcResIDList()
    -- local NpcCfg = require("TableCfg/NpcCfg")
    -- for index = 1, #NpcList do
    --     local Cfg = NpcCfg:FindCfgByKey(NpcList[index])
    --     if Cfg then
    --         if Cfg.AnimDAName ~= "" then
    --             local Path = string.format("NPCAnimDataAsset'/Game/Assets/Character/Human/Animation/DataAsset/NPC/{%s}.{%s}'"
    --                 , Cfg.AnimDAName, Cfg.AnimDAName)
    --             AddToPreloadList(PreloadOtherMapList, Path)
    --         end

    --         if Cfg.BodyEffectPath ~= "" then
    --             AddToPreloadList(PreloadOtherMapList, Cfg.BodyEffectPath)
    --         end
    --     end
    -- end
    -- --加载
    -- for key, _ in pairs(PreloadOtherMapList) do
    --     PreLoadObject(key, ObjectGCType.Map)
    --     --print("Preload Map Assets: "..key)
    -- end

    --预加载技能条件表、目标筛选表、技能范围表
    --目标筛选表
    local SkillTargetSelectCfg = require("TableCfg/SkillTargetSelectCfg")
    SkillTargetSelectCfg:FindAllCfg("true")
    --技能条件表
    local SkillConditionCfg = require("TableCfg/SkillConditionCfg")
    SkillConditionCfg:FindAllCfg("true")
    --技能范围表
    local SkillAreaCfg = require("TableCfg/SkillAreaCfg")
    SkillAreaCfg:FindAllCfg("true")
--]]
    --大概统计下变化
    local TotalMemInc = _G.UE.UPlatformUtil.GetUsedPhysicalMemory() - TotalMemStart
    if TotalMemInc < 0 then
        TotalMemInc = 0
    end
    FLOG_ERROR("PhysicalMemory Increasement After Preload ALL Resources: "..tostring(TotalMemInc))
end

--endregion 预加载资源


---设置是否显示地图切换视频
function WorldMsgMgr:SetPlayLoadingScreen(IsFlag)
    self.IsClosePlayLoadingScreen = IsFlag
end

--当前地图名称
function WorldMsgMgr:GetWorldName()
    return _G.UE.UWorldMgr.Get():GetWorldName()
end

--是否特殊地图
function WorldMsgMgr:IsSpecial(WorldName)
    if WorldName == nil then
        WorldName = self:GetWorldName()
    end

    if self:IsLogin(WorldName) or self:IsLightSpeed(WorldName) then
        return true
    end
    return false
end

--是否登录地图
function WorldMsgMgr:IsLogin(WorldName)
    if WorldName == nil then
        WorldName = self:GetWorldName()
    end

    if WorldName == "" or WorldName == "Login" or WorldName == "SelectCharacter"
        or self:IsCreateRoleMap(WorldName) then
        return true
    end
    return false
end

function WorldMsgMgr:NameIsLoginMap(WorldName)
    if string.find(WorldName, "z1c") then
        return true
    end

    return false
end

--是不是理发屋、幻想药场景
function WorldMsgMgr:IsSpecialLoginMap(WorldName)
    -- local NameIsLogin = self:NameIsLoginMap(WorldName)
    local PWorldInfo = _G.PWorldMgr:GetCurrPWorldTableCfg()
    if PWorldInfo then
        if PWorldInfo and PWorldInfo.Type and PWorldInfo.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_DEMO then
            --如果PWorldInfo.MainPanelUIType没配置的话，比如旅馆，也是演示场景的
            if PWorldInfo.MainPanelUIType and PWorldInfo.MainPanelUIType ~= 0 then
                return true
            end
        end
    end
    -- if _G.PWorldMgr:GetCurrPWorldType() == ProtoRes.pworld_type.PWORLD_CATEGORY_DEMO then
    --     return true
    -- end

    return false
end

--是不是选角、创角的场景
function WorldMsgMgr:IsCreateRoleMap(WorldName)
    local CurPWorldType = _G.PWorldMgr:GetCurrPWorldType()
    --PWORLD_CATEGORY_DEMO
    if CurPWorldType ~= ProtoRes.pworld_type.PWORLD_CATEGORY_NONE then
        return false
    end

    return self:NameIsLoginMap(WorldName)
end

--是否LightSpeed地图
function WorldMsgMgr:IsLightSpeed(WorldName)
    if WorldName == nil then
        WorldName = self:GetWorldName()
    end

    if WorldName == "" or WorldName == "LightSpeed" then
        return true
    end
    return false
end

function WorldMsgMgr:MarkLevelLoad()
    self:MarkLevelFinished()
    local DestinationMapID = _G.PWorldMgr:GetCurrMapResID()
	local MapCfgData = _G.PWorldMgr:GetMapTableCfg(DestinationMapID)
	local MapName = tostring(DestinationMapID)
	if (MapCfgData ~= nil) then
		MapName = MapCfgData.DisplayName
	end
    if string.isnilorempty(MapName) or MapName == "0" then
        return
    end
    FLOG_INFO("WorldMsgMgr:MarkLevelLoad, MapName:%s", MapName)
    _G.UE.UGPMMgr.Get():MarkLevelLoad(MapName)
	self.HasMarkLevelLoad = true
    CommonUtil.ReportSceneID(GameDataKey.ScenID.Default)
end

function WorldMsgMgr:MarkLevelLoadCompleted()
    self:HideLoadingView()
    FLOG_INFO("WorldMsgMgr:MarkLevelLoadCompleted")
    _G.UE.UGPMMgr.Get():MarkLevelLoadCompleted()
    CommonUtil.ReportSceneID(GameDataKey.ScenID.Gaming)
    CommonUtil.ReportSceneID(GameDataKey.ScenID.Transfer)
end

function WorldMsgMgr:MarkLevelFinished()
	if self.HasMarkLevelLoad then
        FLOG_INFO("WorldMsgMgr:MarkLevelFinished")
		_G.UE.UGPMMgr.Get():MarkLevelFinished()
		self.HasMarkLevelLoad = false
	end
end

--Lua免重启热更功能
--最坏情况：重新运行编辑器
local function FixFunc()
    _G.G6HotFix.HotFixModifyFile(false)

    --to do

end

function WorldMsgMgr:LuaFix()
    if _G.RunLuaFix ~= true then
        return
    end

    if _G.G6HotFix == nil then
        FLOG_ERROR("G6HotFix Print : G6HotFix == nil")
        return
    end

    if _G.ScanTime == nil then
        _G.ScanTime = 5
    end

    _G.TimerMgr:CancelTimer(LuaFixTimer)
    LuaFixTimer = _G.TimerMgr:AddTimer(nil, FixFunc, 1,  _G.ScanTime, 9999)
end

return WorldMsgMgr