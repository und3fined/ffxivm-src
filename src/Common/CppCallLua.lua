--
-- Author: anypkvcai
-- Date: 2020-09-11 20:41:55
-- Description: Cpp调用的函数在此添加
--

local PworldCfg = require("TableCfg/PworldCfg")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local ClientActorFactory = require("Game/Actor/ClientActorFactory")
local VisionMeshCountLimiter = require("Game/Actor/VisionMeshCountLimiter")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local DialogueUtil = require("Utils/DialogueUtil")
local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
local NpcCfgTable = require("TableCfg/NpcCfg")
local MonsterCfgTable = require("TableCfg/MonsterCfg")
local CommonUtil = require("Utils/CommonUtil")
local SaveKey = require("Define/SaveKey")
local UPWorldMgr = _G.UE.UPWorldMgr:Get()
local ChatDefine = require("Game/Chat/ChatDefine")
local SelectTargetBase = require("Game/Skill/SelectTarget/SelectTargetBase")
local ActorUIUtil = require("Utils/ActorUIUtil")
local SkillUtil = require("Utils/SkillUtil")
local TipsUtil = require("Utils/TipsUtil")
local SettingsTabRole = require("Game/Settings/SettingsTabRole")
local DataReportUtil = require("Utils/DataReportUtil")
local AudioUtil = require("Utils/AudioUtil")
-- local ActorUtil = require("Utils/ActorUtil")

local LSTR = _G.LSTR
local UIViewMgr

local CppCallLua = {

}

function CppCallLua.Init()
	UIViewMgr = require("UI/UIViewMgr")
end

function CppCallLua.GetWorldID()
	return _G.LoginMgr:GetWorldID()
end

function CppCallLua.GetMapleNodeName(WorldID)
	return _G.LoginMgr:GetMapleNodeName(WorldID)
end

---ShowViewByName
---@param ViewName string
---@param Params table
function CppCallLua.ShowViewByName(ViewName, Params)
	local ViewID = _G.UIViewMgr:GetViewIDByName(ViewName)

	Params = Params or {}
	if Params.ToTable ~= nil then
		Params = Params:ToTable()
	end
	if ViewID > 0 then
		_G.UIViewMgr:ShowView(ViewID, Params)
	end
end

---HideViewByName
---@param ViewName string
function CppCallLua.HideViewByName(ViewName)
	local ViewID = _G.UIViewMgr:GetViewIDByName(ViewName)

	if ViewID > 0 then
		_G.UIViewMgr:HideView(ViewID)
	end
end

---@param ViewID number
---@param Params table
function CppCallLua.ShowViewByID(ViewID, Params)
	Params = Params or {}
	if Params.ToTable ~= nil then
		Params = Params:ToTable()
	end
	if ViewID > 0 then
		_G.UIViewMgr:ShowView(ViewID, Params)
	end
end

---@param ViewID number
function CppCallLua.HideViewByID(ViewID)
	if ViewID > 0 then
		_G.UIViewMgr:HideView(ViewID)
	end
end

---HideAllUI
function CppCallLua.HideAllUI()
	_G.UIViewMgr:HideAllUI()
end

function CppCallLua.ShowMapReigonTitle(MapID, ShowDuration)
	local Params = { ShowType = ProtoRes.sysnotice_show_type.SYSNOTICE_SHOWTYPE_PWORLD_ENTER, MapResID = MapID}
	_G.UIViewMgr:ShowView(_G.UIViewID.InfoAreaTipsInCutScene, Params)
end

function CppCallLua.HideMapReigonTitle()
	local View = _G.UIViewMgr:FindView(_G.UIViewID.InfoAreaTipsInCutScene)
	if View then
		View:PlayPWorldOutAnimation()
	end
end

function CppCallLua.ChangeBGMVolume(VolumeRate, Channel)
	_G.PWorldMgr:ChangeBGMVolume(VolumeRate, Channel)
end

function CppCallLua.SetContentBGM(BgmID, Channel)
	_G.PWorldMgr:SetContentBGM(BgmID, Channel)
end

--- 当前要进的地图为主城/野外才能保留BGM
--- 如果从副本中出来进主城/野外, 也不能保留场景BGM
---@return boolean
function CppCallLua.ShouldKeepSceneBGM()
	local PWorldMgr = _G.PWorldMgr
	return (PWorldMgr:CurrIsInMainCity() or PWorldMgr:CurrIsInField()) and not PWorldMgr:CurrIsFromDungeonExit()
end

--- 返回切换关卡时, 需要保留的BGM通道
function CppCallLua.GetRetainedBGMChannelsOnWorldChange()
	local EBGMChannel = UE.EBGMChannel
	return EBGMChannel.BaseZone  -- # TODO - 后续坐骑EBGMChannel.Mount可能也需要跨地图
end

function CppCallLua.PauseSequence(bDelay)
	_G.StoryMgr:PauseSequence(bDelay)
end

function CppCallLua.StopSequence()
	_G.StoryMgr:StopSequence()
end

function CppCallLua.GetCurrentDialogueContentDuration()
	return _G.StoryMgr:GetCurrentDialogueContentDuration()
end

function CppCallLua.UpdateDialogueAudioDuration(CurrentAudioDuration)
	_G.StoryMgr:UpdateDialogueAudioDuration(CurrentAudioDuration)
end

function CppCallLua.OnChangeLayerSet(bPause)
	if (bPause) then
		_G.FLOG_INFO("OnChangeLayerSet : PauseSequence")
		_G.StoryMgr:PauseSequence(false)
	end
	_G.LoadingMgr:ShowLoadingView(true, true)
end

function CppCallLua.UpdateDialogueTopWidget(SkipType, FadeColorType, bCanSkip)
	_G.StoryMgr:UpdateDialogueTopWidget(SkipType, FadeColorType, bCanSkip)
end

--World相关
--加载前事件
function CppCallLua.PreLoadWorld(CurWorldName, NextWorldName)
	_G.FLOG_INFO("CppCallLua.PreLoadWorld CurWorldName:%s NextWorldName:%s", CurWorldName, NextWorldName)
	local WorldMsgMgr = _G.WorldMsgMgr
	WorldMsgMgr:PreLoadWorld(CurWorldName, NextWorldName)
end

--加载后事件
function CppCallLua.PostLoadWorld(LastWorldName, CurWorldName, bChangeMap, LoadWorldReason)
	_G.FLOG_INFO("CppCallLua.PostLoadWorld LastWorldName:%s, CurWorldName:%s, bChangeMap:%s, LoadWorldReason:%s", LastWorldName, CurWorldName, tostring(bChangeMap), tostring(LoadWorldReason))
	local WorldMsgMgr = _G.WorldMsgMgr
	WorldMsgMgr:PostLoadWorld(LastWorldName, CurWorldName, LoadWorldReason)
end

--获取当前地图玩家出生点
function CppCallLua.GetMajorBirthTransformInCurrMap()
	local Translation = _G.PWorldMgr:GetMajorBirthPos()
	local Rotator = _G.PWorldMgr:GetMajorBirthRot()
	return _G.UE.FTransform(Rotator:ToQuat(), Translation, _G.UE.FVector(1.0, 1.0, 1.0))
end

function CppCallLua.IsNeedStreamingLevelInViewLocation()
	return _G.PWorldMgr:IsNeedStreamingLevelInViewLocation()
end

--获取地图编辑器导出的地图数据路径
function CppCallLua.GetMapDataFilePath(MapResID)
	local MapTableCfg = _G.PWorldMgr:GetMapTableCfg(MapResID)
	if (MapTableCfg == nil or MapTableCfg.MapEditFile == nil) then
		return ""
	end
	return MapTableCfg.MapEditFile
end

function CppCallLua.GetMonsterIsAdjustFloor(MonListID)
	return _G.MapEditDataMgr:GetMonsterIsAdjustFloor(MonListID)
end

function CppCallLua.GetMonsterIsFindFloorBySweep(MonListID)
	return _G.MapEditDataMgr:GetMonsterIsFindFloorBySweep(MonListID)
end

function CppCallLua.GetMonsterResIDList(MonSubType)
	return _G.MapEditDataMgr:GetMonsterResIDList(MonSubType)
end

--获取复活规则ID
function CppCallLua.GetReviveRuleID()
	local PWorldTableCfg = _G.PWorldMgr:GetCurrPWorldTableCfg()
	if (PWorldTableCfg == nil) then
		return 0;
	end
	return PWorldTableCfg.ReviveRuleID;
end


--目标选择
function CppCallLua.CppCastSkillSelectTargets(SkillID, SubSkillID, HitIdx, Executor, bUseFaultTolerantRange, bForbidChangeTarget, SelectedPos, DirAngle)
	return _G.SelectTargetMgr:CppCastSkillSelectTargets(SkillID, SubSkillID, HitIdx, Executor, bUseFaultTolerantRange, bForbidChangeTarget, SelectedPos, DirAngle)
end

--目标是否能被选中
function CppCallLua.IsCanBeSelect(Target, IsSkillSelect)
	return _G.SelectTargetMgr:IsCanBeSelect(Target, IsSkillSelect)
end

function CppCallLua.SkillIsTeamMember(Target)
	return SelectTargetBase:IsTeamMember(Target)
end

function CppCallLua.GetMonstersInSameTaunt(ListID)
	return _G.MapEditDataMgr:GetMonstersInSameTaunt(ListID)
end

function CppCallLua.GetMonsterNormalAIByListID(ListID)
	local MonsterData =  _G.MapEditDataMgr:GetMonsterByListID(ListID)
	if (MonsterData ~= nil) then
		return MonsterData.NormalAI
	end

	return 0
end

--接收蓝图发送的事件
function CppCallLua.OnReceiveBPEvent(EventID, Params)
	if EventID == nil then
		return
	end

	_G.EventMgr:SendEvent(EventID, Params)
end

---IsShowNetworkLog
---是否显示网络收发包日志
---@param MsgID number @ProtoCS.CS_CMD
---@param SubMsgID number
function CppCallLua.IsShowNetworkLog(MsgID, SubMsgID)
	--除了编辑器暂时不打印C++网络日志
	if not CommonUtil.IsWithEditor() then
		return false
	end

	return _G.GameNetworkMgr:IsShowNetworkLog(MsgID, SubMsgID)
end

---IsMsgRegistered
---是否注册了消息
---@param MsgKey number
function CppCallLua.IsMsgRegistered(MsgKey)
	return _G.GameNetworkMgr:IsMsgRegistered(MsgKey)
end

---IsMsgEnableResend
---是可以重发
---@param MsgID number
---@param SubMsgID number
function CppCallLua.IsMsgEnableResend(MsgID, SubMsgID)
	return _G.GameNetworkMgr:IsMsgEnableResend(MsgID, SubMsgID)
end

---GetMoveConfig
---获取移动配置
---@param Name string
function CppCallLua.GetMoveConfig(Name)
	local MoveConfig = require("Define/MoveConfig")
	local Config = MoveConfig[Name]
	if Config == nil then
		local GlobalCfg = require("TableCfg/GlobalCfg")
		local Key = ProtoRes.global_cfg_id[Name]
		if Key then
			local CfgResult = GlobalCfg:FindCfgByKey(Key)
			Config = CfgResult and CfgResult.Value[1]
		end
	end
	return Config
end

---GetCommonDefine
---获取通用配置
---@param Name string
function CppCallLua.GetCommonDefine(Name)
	local CommonDefine = require("Define/CommonDefine")
	return CommonDefine[Name]
end

---GetRaceAdaptationConfig
---获取种族适配配置
---@param Name string，当前种族
---@return string, 变形源种族
function CppCallLua.GetRaceAdaptationConfig(Name)
	local RaceAdaptationConfig = require("Define/RaceAdaptationConfig")
	local Table = RaceAdaptationConfig[Name]
	-- 默认使用c0101
	if Table == nil and Name ~= "c0101" and string.sub(Name, 1, 1)== "c" then
		Table =  {"c0101"}
	end
	if Table == nil then return nil end
	local Array = UE.TArray(UE.FString)
	for _, v in ipairs(Table) do
		Array:Add(v)
	end
	return Array
end

function CppCallLua.GetPlayerIdleAnimPath(IdleType, Actor, IdleAnimType, AnimStage)
	return EmotionAnimUtils.GetPlayerIdleAnimPath(IdleType, Actor, IdleAnimType, AnimStage)
end

function CppCallLua.GetEmotAnimPath(EntityID, AnimName)
	local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
	return EmotionAnimUtils.GetEmotionAnimPath(AnimName, EntityID, EmotionDefines.AnimType.EMOT)
end

function CppCallLua.IsEmotionResExist(EntityID, EmotionID)
	return EmotionAnimUtils.IsEmotionResExist(EntityID, EmotionID)
end

---ShowSystemTips
---显示系统提示
---@param Content string
function CppCallLua.ShowSystemTips(Content, bIsDebugTips)
	if (bIsDebugTips and not _G.GMMgr:IsShowDebugTips()) then
		return
	end
	_G.MsgTipsUtil.ShowTips(Content)
end

---ShowMessageBox
---显示对话框
---@param Content string
function CppCallLua.ShowMessageBox(Content)
	MsgBoxUtil.MessageBox(Content, LSTR(10033), nil
	, nil, nil
	, false)
end

---ShowNpcDialog
---显示副本对话
---@param DialogLibID
function CppCallLua.ShowNpcDialog(DialogLibID)
	_G.MsgTipsUtil.ShowTipsByID(DialogLibID)
end

---IsShowNetworkLog
---是否显示选中描边
---@param MsgID number @ProtoCS.CS_CMD
function CppCallLua.IsShowSelectOutline()
	return _G.SettingsMgr:GetValueBySaveKey("ShowSelectOutline") == 1
end

--获取在线配置文件回调
local bIsShownLoginDownloadAutoWidget = false
function CppCallLua.SetOnlineConfig(Content)
	--Editor中屏蔽更新请求
	if CommonUtil.IsWithEditor() then
        return
    end
	--20230714：取消名字黑名单配置功能
	--print ("OnlineCfg:"..Content)
	--local LocalBlacklist = require("Define/NameBlacklist")
	--local OnlineBlackList = string.split(string.lower(Content), ',')
	--for i = 1, #(OnlineBlackList) do
	--	table.insert(LocalBlacklist, OnlineBlackList[i])
	--end

	--20230714：临时资源更新方案，可以下载任意类型资源
	local ConfigStr = string.gsub(Content, ' ', '')
	ConfigStr = string.gsub(ConfigStr, '\t', '')
	ConfigStr = string.gsub(ConfigStr, '\r\n', '')

	local ConfigList = string.split(ConfigStr, ',')
	local ConfigInfo = ''
	local PlatformName = CommonUtil.GetPlatformName()  -- Android, IOS
	local LocalAppVersion = _G.UE.UVersionMgr.GetAppVersion()
	local LocalSrcVersion = _G.UE.UVersionMgr.GetResourceVersion()
	--目前SrcVersion不能用，临时用SaveMgr建一个
	-- local LocalSrcVersion = _G.UE.USaveMgr.GetString(SaveKey.SourceVersion, LocalAppVersion, false)

	--矫正资源号，前3位必须与app版本号一致
	local LocalAppVerParams = string.split(LocalAppVersion, '.')
	local LocalSrcVerParams = string.split(LocalSrcVersion, '.')
	if LocalAppVerParams[1] ~= LocalSrcVerParams[1]
	or LocalAppVerParams[2] ~= LocalSrcVerParams[2]
	or LocalAppVerParams[3] ~= LocalSrcVerParams[3]
	then
		print('update info: rewrite local srcversion, old: '..LocalSrcVersion..', new: '..LocalAppVersion)
		LocalSrcVersion = LocalAppVersion
		_G.UE.USaveMgr.SetString(SaveKey.SourceVersion, LocalSrcVersion, false)
	end

	for i = 1, #(ConfigList) do
		local Config = ConfigList[i]
		Config = string.gsub(Config, '{', '')
		Config = string.gsub(Config, '}', '')

		if string.sub(Config, 1, #PlatformName) == PlatformName then
			ConfigInfo = Config
			break
		end
	end

	print('update info: local appversion: '..LocalAppVersion..', local srcversion: '..LocalSrcVersion)

	--找到本版本的更新信息，进行更新
	if ConfigInfo ~= '' then
		local ParamsList = string.split(ConfigInfo, '#')
		local SrcVersionTo = ParamsList[2]
		local SrcURL = ParamsList[3]
		local MD5 = ParamsList[4]
		local FileSize = ParamsList[5]

		print('update info, find new config:'..ConfigInfo)

		if bIsShownLoginDownloadAutoWidget then
			return
		end

		bIsShownLoginDownloadAutoWidget = true

		--提审版本的app版本号不能变，否则会清理掉资源
		--只用资源号进行更新，包括apk和pak的下载
		if not (SrcVersionTo ~= '' and SrcVersionTo > LocalSrcVersion) then
			return
		end

		local UIUserWidget = nil
		local UIUserWidgetScript = nil

		if SrcURL == 'all' then
			--初始资源包
			local UIClass = ObjectMgr:LoadClassSync("WidgetBlueprint'/Game/UI/BP/Login/LoginDownloadPakWidget_UIBP.LoginDownloadPakWidget_UIBP_C'")
			if UIClass == nil then
				return
			end

			UIUserWidget = _G.UE.UWidgetBlueprintLibrary.Create(FWORLD(), UIClass)
			UIUserWidget:AddToViewport()
			UIUserWidgetScript = UIUserWidget:Cast(_G.UE.UFLoginDownloadPakWidget)
			if UIUserWidgetScript ~= nil then
				UIUserWidgetScript:ShowDownloadAllProgress(SrcVersionTo)
			end
		else
			--热更新资源包
			local UIClass = ObjectMgr:LoadClassSync("WidgetBlueprint'/Game/UI/BP/Login/LoginDownloadAutoWidget_UIBP.LoginDownloadAutoWidget_UIBP_C'")
			if UIClass == nil then
				return
			end

			UIUserWidget = _G.UE.UWidgetBlueprintLibrary.Create(FWORLD(), UIClass)
			UIUserWidget:AddToViewport()
			UIUserWidgetScript = UIUserWidget:Cast(_G.UE.UFLoginDownloadAutoWidget)
			if UIUserWidgetScript ~= nil then
				SrcURL = string.gsub(SrcURL, 'http://dlied5.qq.com/ffom/fmgame/simulator/' .. LocalAppVersion .. '/', '')
				SrcURL = string.gsub(SrcURL, 'http://dlied5.qq.com/ffom/fmgame/shipping/' .. LocalAppVersion .. '/', '')
				SrcURL = string.gsub(SrcURL, 'http://dlied5.qq.com/ffom/fmgame/', '')
				SrcURL = SrcURL..'#'..MD5..'#'..FileSize..'#'..SrcVersionTo
				UIUserWidgetScript:InitItemAndDownload(SrcURL)
				print('update info: download pakinfo: '..SrcURL)
			end
		end
	else
		print('update info, none config found')
	end
end

function CppCallLua.SendGM(Content)
	_G.GMMgr:ReqGM(Content)
end

--指定单位播放蓄力特效与动画
function CppCallLua.PlayStorageEffect(EntityID, SkillID)
	local SkillStorageSync = require("Game/Skill/SkillStorage/SkillStorageSync")
	SkillStorageSync.PlayStorageEffectbySkillID(EntityID, SkillID)
end
--打断指定单位蓄力特效与动画
function CppCallLua.BreakStorageEffect(EntityID)
	local SkillStorageSync = require("Game/Skill/SkillStorage/SkillStorageSync")
	SkillStorageSync.BreakStorageEffect(EntityID)
end

---GetSelectDecalColor
---@param EntityID number
---@return string
function CppCallLua.GetSelectDecalColor(EntityID)
	return ActorUIUtil.GetUIColor(EntityID).ActorDecal
end

--处理AutoTest消息
function CppCallLua.OnReceiveAutoTest(CmdType, CmdString)
	_G.AutoTest.OnReceiveAutoTest(CmdType, CmdString)
end

--播放吟唱效果
function CppCallLua.PlaySingEffect(EntityID, SingID, TargetIDs, PlayRate)
	if type(TargetIDs) == "userdata" and TargetIDs["__name"] == "TArray" then
		TargetIDs = TargetIDs:ToTable()
	end

	return _G.SkillSingEffectMgr:PlaySingEffect(EntityID, SingID, TargetIDs, PlayRate)
end

--打断指定吟唱效果
function CppCallLua.BreakSingEffect(EntityID, SingEffectID)
	_G.SkillSingEffectMgr:BreakSingEffect(EntityID, SingEffectID)
end

function CppCallLua.PlayerSingBegin(EntityID, SkillID)
	_G.SkillSingEffectMgr:PlayerSingBegin(EntityID, SkillID)
end

function CppCallLua.PlayerSingBreak(EntityID)
	_G.SkillSingEffectMgr:PlayerSingBreak(EntityID)
end

--获取队伍成员RoleID列表
function CppCallLua.GetMemberRoleIDList()
	local MemberIDTable = _G.TeamMgr:GetMemberRoleIDList()
	local MemberIDArray = _G.UE.TArray(_G.UE.uint64)

	for _, MemberID in ipairs(MemberIDTable) do
		MemberIDArray:Add(MemberID)
	end

	return MemberIDArray
end

--luamodule

function CppCallLua.LuaInit(mgrName, _)--TickTimerID)
	_G[mgrName]:Init()
	-- FLOG_INFO("CppCallLua.LuaInit: %s TickTimerID:%d", mgrName, TickTimerID)
end

function CppCallLua.LuaBegin(mgrName)
	-- FLOG_INFO("CppCallLua.LuaBegin: %s", mgrName)
	_G[mgrName]:Begin()
end

function CppCallLua.LuaEnd(mgrName)
	-- FLOG_INFO("CppCallLua.LuaEnd: %s", mgrName)
	_G[mgrName]:End()
end

function CppCallLua.LuaShutdown(mgrName)
	-- FLOG_INFO("CppCallLua.LuaShutdown: %s", mgrName)
	_G[mgrName]:Shutdown()
end

function CppCallLua.OnAsyncCanvasPanelChildCreate(InParent, InChild)
	_G.UIViewMgr:OnAsyncCanvasPanelChildCreate(InParent, InChild)
end

function CppCallLua.OnAsyncCanvasPanelChildVisibilityChanged(InChild, InVisibility)
	InChild:SetVisibility(InVisibility)
end

--本地actor创建流程中，使用lua对属性组件填充，抛enterview的事件
--如同服务器视野那样的逻辑
function CppCallLua.OnClientActorInit(EntityID, bCache)
	ClientActorFactory:OnClientActorInit(EntityID, bCache)
end

--本地actor创建完成
function CppCallLua.OnClientActorCreated(EntityID, bCache)
	ClientActorFactory:OnClientActorCreated(EntityID, bCache)
end

function CppCallLua.GetMultiSkillReplaceResult(SkillID, CasterEntityID)
	return _G.SkillLogicMgr:GetMultiSkillReplaceResult(SkillID, CasterEntityID)
end

function CppCallLua.GetSubSkillIDForSkillSystem(SkillID)
	return SkillUtil.GetSubSkillIDForSkillSystem(SkillID)
end

function CppCallLua.GetSkillMoveToTargetParams(SubSkillID)
	return SkillUtil.GetSkillMoveToTargetParams(SubSkillID)
end

function CppCallLua.GetSkillResetToTargetParams(SubSkillID)
	return SkillUtil.GetSkillResetToTargetParams(SubSkillID)
end

function CppCallLua.GetSkillAnimationParams(SubSkillID)
	return SkillUtil.GetSkillAnimationParams(SubSkillID)
end

function CppCallLua.AddSkillFlowData(SkillID, SubSkillID)
	return SkillUtil.AddSkillFlowData(SkillID, SubSkillID)
end

function CppCallLua.SlatePreTick(DeltaTime)
	local SlatePreTick = require("Game/Skill/SlatePreTick")
	SlatePreTick.DoSlatePreTick(DeltaTime)
end

function CppCallLua.IsSkillSystem(EntityID)
	return SkillLogicMgr:IsSkillSystem(EntityID)
end

function CppCallLua.GetMajorClientSetupValue(SetupKey)
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	local SetupValue = _G.ClientSetupMgr:GetConfigValue(MajorRoleID, SetupKey)
	return SetupValue or ""
end

function CppCallLua.OnFishDropEnd(EntityID)
	_G.FishMgr:AnimNotify_OnFishDropEnd(EntityID)
end
function CppCallLua.OnFishFightStart(EntityID)
	_G.FishMgr:AnimNotify_OnFishFightStart(EntityID)
end
function CppCallLua.OnFishFightEnd(EntityID)
	_G.FishMgr:AnimNotify_OnFishFightEnd(EntityID)
end
function CppCallLua.OnFishHookEnd(EntityID)
	_G.FishMgr:AnimNotify_OnFishHookEnd(EntityID)
end
function CppCallLua.OnFishHookFailEnd(EntityID)
	_G.FishMgr:AnimNotify_OnFishHookFailEnd(EntityID)
end


function CppCallLua.GetEntityEffectLOD(EntityID, Rule)
	local EffectUtil = require("Utils/EffectUtil")
	return EffectUtil.GetEntityEffectLODInternal(EntityID, Rule)
end

-- 对话框富文本解析标签
function CppCallLua.CallLabelFuncion(FuncName, Params)
	if DialogueUtil.FuncList[FuncName] ~= nil then
		return DialogueUtil.FuncList[FuncName](Params)
	end
end

function CppCallLua.ContainsLabelFunction(FuncName)
	return DialogueUtil ~= nil and DialogueUtil.FuncList[FuncName] ~= nil
end

function CppCallLua.GetWeatherID()
	return _G.MapMgr:GetWeatherID()
end

--判定该采集物是否能被当前职业采集
function CppCallLua.IsCanGather(GatherType, ProfID)
	return _G.GatherMgr:IsCanGather(GatherType, ProfID)
end

function CppCallLua.GetVisionPriority(EntityID)
	if VisionMeshCountLimiter == nil then return 0 end
	return VisionMeshCountLimiter.GetVisionPriority(EntityID)
end

function CppCallLua.IsActorAlwaysVisible(EntityID)
	if VisionMeshCountLimiter == nil then return false end
	return VisionMeshCountLimiter.IsActorAlwaysVisible(EntityID)
end

function CppCallLua.OnVirtualKeyboardShown(Params)
	_G.UIViewMgr:OnVirtualKeyboardShown(Params)
end

function CppCallLua.OnVirtualKeyboardReturn(Params)
	_G.UIViewMgr:OnVirtualKeyboardReturn(Params)
end

function CppCallLua.OnVirtualKeyboardHidden()
	_G.UIViewMgr:OnVirtualKeyboardHidden()
end

---GetPayConfig 获取支付配置
---@param Key string 配置关键字
---@return string 配置值
function CppCallLua.GetPayConfig(Key)
	local PayConfig = require("Define/PayConfig")
	if nil == PayConfig then
		return ""
	end
	return PayConfig[Key]
end

function CppCallLua.ShowMidasPayFinishedTips(PayReturnData)
	_G.RechargingMgr:ShowMidasPayFinishedTips(PayReturnData)
end

function CppCallLua.ExeGM(GMStr)
	_G.GMMgr:ReqGM1(GMStr)
end

function CppCallLua.GetNpcMonsterResByGM()
	_G.FieldTestMgr:GetNpcMonsterResByGM()
end

function CppCallLua.DebugGetMapResIDList(TypeName)
	return _G.FieldTestMgr:DebugGetMapResIDList(TypeName)
end

function CppCallLua.DebugGetMapResPosList(TypeName, ResID)
	return _G.FieldTestMgr:DebugGetMapResPosList(TypeName, ResID)
end

function CppCallLua.DebugGetMapResName(TypeName, ResID)
	return _G.FieldTestMgr:DebugGetMapResName(TypeName, ResID)
end

function CppCallLua.GetNpcCfg(NpcResID)
	return NpcCfgTable:FindCfgByKey(NpcResID)
end

function CppCallLua.GetCurrentTimeSlot()
	return _G.HeartBeatMgr.CurrentTimeSlot or 0
end

function CppCallLua.UpdateRidePath(TableStr)
	_G.RideShootingMgr:UpdateRidePath(TableStr)
end

function CppCallLua.EndGame()
	_G.GoldSauserMgr:EndGame(true)
end

function CppCallLua.GetVoiceFileStoreMaxNums()
	return ChatDefine.MaxNumVoiceFileStorePublic, ChatDefine.MaxNumVoiceFileStorePrivate
end

function CppCallLua.GetCampRelation(FromActor, TargetActor)
	return SelectTargetBase:GetCampRelation(FromActor, TargetActor)
end

function CppCallLua.CheckCanClickSelect(FromActor, TargetActor)
	return _G.SwitchTarget:CheckCanClickSelect(FromActor, TargetActor)
end

function CppCallLua.ShowBalloonUI(EntityID, BalloonID, Duration)
	_G.SpeechBubbleMgr:ShowBalloonByID(EntityID, BalloonID, Duration)
end

function CppCallLua.HideBalloonUI(EntityID)
	_G.SpeechBubbleMgr:HideBalloonByID(EntityID)
end

--- 获取宠物已解锁动作
---@param ID uint32 宠物ID
function CppCallLua.GetCompanionAction(ID)
	local ActionTable = _G.CompanionMgr:GetCompanionAction(ID)
	local ActionArray = _G.UE.TArray(_G.UE.uint64)

	for _, MemberID in ipairs(ActionTable) do
		ActionArray:Add(MemberID)
	end

	return ActionArray
end

function CppCallLua.GetHUDObject(EntityID)
	return _G.HUDMgr:GetActorInfoObject(EntityID)
end

function CppCallLua.UpdateHUDNameInfo(EntityID)
	return _G.HUDMgr:UpdateNameInfo(EntityID)
end

function CppCallLua.UpdateHUDIsDraw(EntityID)
	return _G.HUDMgr:UpdateIsDraw(EntityID)
end

function CppCallLua.SetClientWeather(WeatherID, TransitionTime, Time, bIsFixed)
	_G.WeatherMgr:SetClientWeather(WeatherID, TransitionTime, Time, bIsFixed)
end

function CppCallLua.SetCutSceneWeather(WeatherID, TransitionTime, Time, bIsFixed)
	_G.WeatherMgr:SetCutSceneWeather(WeatherID, TransitionTime, Time, bIsFixed)
end

function CppCallLua.RestoreCutSceneWeather()
	_G.WeatherMgr:RestoreCutSceneWeather()
end

function CppCallLua.ChangeMapForCutScene(MapPath, bShowLoading, LoadWorldReason, bSkipLoadLayerSet, bSkipLoadLevelStreaming)
	_G.PWorldMgr:ChangeMapForCutScene(MapPath, bShowLoading, LoadWorldReason, bSkipLoadLayerSet, bSkipLoadLevelStreaming)
end

function CppCallLua.GetMajorPerchRadiusThreshold(MapID)
	return _G.PWorldMgr:GetMajorPerchRadiusThreshold(MapID)
end

function CppCallLua.ReplaySequenceAfterChangeMap(SequencePath, StartFrameNumber)
	_G.StoryMgr:ReplaySequenceAfterChangeMap(SequencePath, StartFrameNumber)
end

function CppCallLua.GetSceneCharacterShowType()
	return _G.StoryMgr:GetSceneCharacterShowType()
end

function CppCallLua.CurrentPlayingIsNCut()
	return _G.StoryMgr:CurrentPlayingIsNCut()
end

function CppCallLua.GetChocoboServerPathL()
	return _G.ChocoboRaceMgr:GetServerPathL()
end

function CppCallLua.GetChocoboServerPathR()
	return _G.ChocoboRaceMgr:GetServerPathR()
end

---@param QuestID int32
function CppCallLua.IsQuestAcceptQualified(QuestID)
	local QuestHelper = require("Game/Quest/QuestHelper")
	return QuestHelper.CheckCanActivate(QuestID, nil, nil, true)
		and QuestHelper.CheckCanAccept(QuestID)
end

---@param QuestID int32
function CppCallLua.IsQuestAccepted(QuestID)
	local ProtoCS = require("Protocol/ProtoCS")
	local Status = _G.QuestMgr:GetQuestStatus(QuestID)
	return Status == ProtoCS.CS_QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS
		or Status == ProtoCS.CS_QUEST_STATUS.CS_QUEST_STATUS_CAN_SUBMIT
end

---@param QuestID int32
function CppCallLua.IsQuestCompleted(QuestID)
	local ProtoCS = require("Protocol/ProtoCS")
	local Status = _G.QuestMgr:GetQuestStatus(QuestID)
	return Status == ProtoCS.CS_QUEST_STATUS.CS_QUEST_STATUS_FINISHED
end

function CppCallLua.IsSequenceWaitingToChangeMap()
	return _G.StoryMgr:IsSequenceWaitingToChangeMap()
end

function CppCallLua.GetSummonScale()
	return _G.SummonMgr.SummonScale
end

function CppCallLua.SetViewDis(Value)
	SettingsTabRole.ViewDis = Value
end

---@param MenuInfo _G.UE.FMenuSetupInfo
function CppCallLua.OpenMenuInSeq(MenuInfo)
	_G.StoryMgr:OpenMenuInSeq(MenuInfo)
end

---@return number
function CppCallLua.GetMenuChoiceIndex()
	return _G.StoryMgr:GetMenuChoiceIndex()
end

function CppCallLua.BeginStaffRollPlay()
	_G.StoryMgr:BeginStaffRollPlay()
end

function CppCallLua.EndStaffRollPlay()
	_G.StoryMgr:EndStaffRollPlay()
end

function CppCallLua.ShowStaffRollImage(Image)
	_G.StoryMgr.ShowStaffRollImage(Image)
end

function CppCallLua.HideStaffRollImage(Image)
	_G.StoryMgr.HideStaffRollImage(Image)
end

function CppCallLua.ShowStaffScroll(StaffList, ScrollTime)
	local StaffTable = StaffList:ToTable()
	if StaffTable then
		_G.StoryMgr.ShowStaffScroll(StaffTable, ScrollTime)
	end
end

function CppCallLua.InitializeCGMovie(MovieName)
	_G.StoryMgr:PlayCGMovie(MovieName)
end

function CppCallLua.FinalizeCGMovie()
	_G.StoryMgr:StopCGMovie()
end

function CppCallLua.GetMonsterIDOfBuddy()
	local BuddyDefine = require("Game/Buddy/BuddyDefine")
	return BuddyDefine.MonsterID
end

---@return boolean
function CppCallLua.PreloadUIView(ViewName)
	local ViewID = UIViewMgr:GetViewIDByName(ViewName)
	return UIViewMgr:PreLoadWidgetByViewID(ViewID)
end

function CppCallLua.GetRTT()
	return _G.NetworkRTTMgr:GetRTT()
end

-------------技能Action相关-----------------
local SkillObjectMgr = require("Game/Skill/SkillAction/SkillObjectMgr")
local ProtoBuff = require("Network/Protobuff")

function CppCallLua.CheckSkillWeight(EntityID, SkillWeight)
	return SkillObjectMgr:CheckSkillWeight(EntityID, SkillWeight)
end

function CppCallLua.BreakSkill(EntityID)
	return SkillObjectMgr:BreakSkill(EntityID)
end

function CppCallLua.OnControlStateChange(EntityID)
	return _G.SkillStorageMgr:OnControlStateChange(EntityID)
end

function CppCallLua.SendQuitSkill(EntityID)
	return SkillObjectMgr:SendQuitSkill(EntityID)
end

function CppCallLua.StopCurSkillSingleCell(EntityID, CellType)
	return SkillObjectMgr:StopCurSkillSingleCell(EntityID, CellType)
end

function CppCallLua.CreateSkillObjectAndCast(...)
	return SkillObjectMgr:CreateSkillObjectAndCast(...)
end

function CppCallLua.OnActionPresent(EntityID, Buffer)
	local ActionData = ProtoBuff:Decode("csproto.CombatActionS", Buffer)
	return SkillObjectMgr:OnActionPresent(EntityID, ActionData)
end

function CppCallLua.OnAttackPresent(EntityID, SubSkillID, Buffer)
	local AttackData = ProtoBuff:Decode("csproto.CombatAttackS", Buffer)
	return SkillObjectMgr:OnAttackPresent(EntityID, SubSkillID, AttackData)
end

function CppCallLua.SetSkillObjectSelectPos(EntityID, SelectPos)
	return SkillObjectMgr:SetSkillObjectSelectPos(EntityID, SelectPos)
end

function CppCallLua.RecordSkillEffectID(EntityID, EffectID)
	return SkillObjectMgr:RecordSkillEffectID(EntityID, EffectID)
end

function CppCallLua.MajorReceiveSkillAction(EntityID, SkillID, SubSkillID)
	return SkillObjectMgr:MajorReceiveSkillAction(EntityID, SkillID, SubSkillID)
end

-------------------------------------------
---

--获取当前正在跟角色交互的EntityID
function CppCallLua.GetCurInteractEntityID()
	return _G.InteractiveMgr.CurInteractEntityID
end

function CppCallLua.IsEnterInteractive()
	return _G.InteractiveMgr.IsEnterInteractiveState
end

function CppCallLua.IsEquiped(GID)
	return _G.EquipmentMgr:IsEquiped(GID)
end

function CppCallLua.MagicCardCompetitionIsActive()
	return _G.MagicCardTourneyMgr:IsTourneyActive()
end

function CppCallLua.IsMoundOpened(ID)
	return _G.WildBoxMoundMgr:IsMoundOpened(ID)
end

function CppCallLua.IsInActiveFate(Position)
	return _G.FateMgr:IsInActiveFate(Position)
end

function CppCallLua.DestroyClientActor(EntityID, ActorType)
	_G.ClientVisionMgr:DestoryClientActor(EntityID, ActorType)
end

function CppCallLua.IsInFate()
	return _G.FateMgr:GetCurrentFate() ~= nil
end

function CppCallLua.GetActiveFateProgress(FateId)
	return _G.FateMgr:GetActiveFateProgress(FateId)
end

function CppCallLua.IsNearDeskPlaying(NPCEntityID, NearDistance)
	return _G.MagicCardTourneyMgr:IsNearDeskPlaying(NPCEntityID, NearDistance)
end

function CppCallLua.IsNearDeskEndPlay(NPCEntityID)
	return _G.MagicCardTourneyMgr:IsNearDeskEndPlay(NPCEntityID)
end

function CppCallLua.IsHasTrackingQuestCurrentMap()
	return _G.ChocoboTransportMgr:GetIsHasTrackingQuestCurrentMap()
end

function CppCallLua.IsInMagicCardGame(NPCEntityID)
	return _G.MagicCardMgr:IsInMagicCardGame(NPCEntityID)
end


-------------MirrorEffect相关-----------------
---PlayMirrorEffect
---@param EffectParam UE.FMirrorEffectParam
function CppCallLua.PlayMirrorEffect(EffectParam)
	return _G.MirrorEffectMgr:PlayEffect(EffectParam)
end


-------------文本点击相关-----------------
local TipsTimerID
function CppCallLua.OnTextBlockTouchedStart(InWidget, TextContent)
	--_G.FLOG_INFO(" CppCallLua.OnTextBlockTouchedStart, %s", TextContent)

	function ShowDetailTextTips()
		TipsUtil.ShowInfoTips(TextContent, InWidget, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0), true)
	end

	TipsTimerID = _G.TimerMgr:AddTimer(nil, ShowDetailTextTips, 0.5, 1, 1)
end

function CppCallLua.OnTextBlockTouchedEnd(InWidget, TextContent)
	--_G.FLOG_INFO(" CppCallLua.OnTextBlockTouchedEnd, %s", TextContent)
	_G.TimerMgr:CancelTimer(TipsTimerID)
	if UIViewMgr:IsViewVisible(_G.UIViewID.CommHelpInfoTipsView) then
		UIViewMgr:HideView(_G.UIViewID.CommHelpInfoTipsView)
	end
end

function CppCallLua.OnTextBlockClipped(InWidget, IsClipped)
	--_G.FLOG_INFO("CppCallLua.OnTextBlockClipped, IsClipped:%s", tostring(IsClipped))
end

function CppCallLua.OnRichTextBoxClipped(InWidget, IsClipped)
	--_G.FLOG_INFO("CppCallLua.OnRichTextBoxClipped, IsClipped:%s", tostring(IsClipped))
end

---GetTargetOfMonster
---@return number 返回主目标或者一仇
function CppCallLua.GetTargetOfMonster(EntityID)
	return _G.TargetMgr:GetTargetOfMonster(EntityID)
end

---GetTarget
---@return number 对于玩家来说，返回选中的目标；对于怪物来说，返回主目标或者一仇
function CppCallLua.GetTarget(EntityID)
	return _G.TargetMgr:GetTarget(EntityID)
end

function CppCallLua.CollectPSO(...)
	local PSOUtil = require("PSO/PSOUtil")
	PSOUtil.CollectPSO(...)
end

function CppCallLua.GetNpcActorName(ResID)
	return NpcCfgTable:FindValue(ResID,"Name")
end
function CppCallLua.GetMonsterName(ResID)
	return MonsterCfgTable:FindValue(ResID,"Name")
end

function CppCallLua.GetGrandCompanyID()
	local CompanyInfo = _G.CompanySealMgr:GetCompanySealInfo()
	return CompanyInfo and CompanyInfo.GrandCompanyID or 0
end

--获取当前语音
function CppCallLua.GetCurrentVoiceName()
	return AudioUtil.GetCurrentCulture()
end

function CppCallLua.SetForceGC()
	local UIDefine = require("Define/UIDefine")
	UIDefine.bForceGC = true
	_G.FLOG_INFO("CppCallLua.SetForceGC")
end

function CppCallLua.GetAutoMovePitch()
	local NavigationConfigCfg = require("TableCfg/NavigationConfigCfg")
	local Pitch = -20
	local Cfg = NavigationConfigCfg:FindCfgByKey(ProtoRes.navigation_config_type.AUTOPATH_CAMERA_PITCH)
	if (Cfg ~= nil) then
    	Pitch = Cfg.Value
    end
	return Pitch
end

function CppCallLua.GetAutoMoveLagValue()
	if _G.ChocoboTransportMgr:GetIsTransporting() then
		return _G.ChocoboTransportMgr:GetAutoMoveLagValue()
	end
	local NavigationConfigCfg = require("TableCfg/NavigationConfigCfg")
	local LagValue = 10
	local Cfg = NavigationConfigCfg:FindCfgByKey(ProtoRes.navigation_config_type.AUTOPATH_CAMERA_LAGVALUE)
	if (Cfg ~= nil) then
		LagValue = Cfg.Value
	end
	return LagValue
end

function CppCallLua.ShowRecordID()
	_G.EventMgr:SendEvent(EventID.Show_RecordID)
end

function CppCallLua.UpLoadLog()
	_G.LevelRecordMgr:UpLoadLog()
end

function CppCallLua.MountCancelCall()
	_G.MountMgr:ForceSendMountCancelCall()
end

local TargetMgr

function CppCallLua.StartHardLockEffect()
	if not TargetMgr then
		TargetMgr = _G.TargetMgr
	end
	return TargetMgr:StartHardLockEffect()
end

function CppCallLua.EndHardLockEffect()
	return TargetMgr:EndHardLockEffect()
end

function CppCallLua.SendASAAdInfo(ASAAdInfo)
	DataReportUtil.SendASAAdInfo(ASAAdInfo)
end

function CppCallLua.ShowCommonTips(TipsContent)

end

function CppCallLua.DisableCurrentLightPreset()
	local LightMgr = require("Game/Light/LightMgr")
	LightMgr:DisableCurrentLightPreset()
end

function CppCallLua.OnEntityDieCombatLog(EntityID, KillerID)
	_G.SkillLogicMgr:OnEntityDieCombatLog(EntityID, KillerID)
end

function CppCallLua.GetTargetActorIsExistInInteractiveList(EntityID, ResID)
	return _G.InteractiveMgr:GetTargetActorIsExistInInteractiveList(EntityID, ResID)
end

function CppCallLua.SetCanForceFly(bForceFly)
	if bForceFly then
		_G.MountMgr:SetbForceCanFly()
	else
		_G.MountMgr:CancelForceCanFly()
	end
end

function CppCallLua.GetSeqDynParam(KeyName)
	return _G.SeqDynParamsMgr:GetSeqDynParam(KeyName)
end

function CppCallLua.SetSettingsValueBySaveKey(InSaveKey, InValue)
	_G.SettingsMgr:SetValueBySaveKey(InSaveKey, InValue)
end

function CppCallLua.ShowTipsByID(TipID)
	_G.MsgTipsUtil.ShowTipsByID(TipID)
end

function CppCallLua.IsViewVisible(ViewID)
	return UIViewMgr:IsViewVisible(ViewID)
end

function CppCallLua.OnGameBotCallBack(Params)
	_G.FLOG_INFO("CppCallLua.OnGameBotCallBack, Params:%s", Params)
	local JumpUtil = require("Utils/JumpUtil")
	JumpUtil.OnGameBotJump(Params)
end

function CppCallLua.GetQuestSetEObjState(EObjID)
	return _G.QuestMgr:GetQuestSetEObjState(EObjID)
end

-----------------Pandora相关-----------------
function CppCallLua.OnRecievedPandoraMsg(Msg)
	_G.FLOG_INFO("CppCallLua.OnRecievedPandoraMsg, Msg:%s", Msg)
	_G.PandoraMgr:OnRecievedPandoraMsg(Msg)
end

function CppCallLua.PandoraClosePanel(AppId)
	_G.FLOG_INFO("CppCallLua.PandoraClosePanel, AppId:%s", AppId)
	_G.PandoraMgr:CloseMainPanel(AppId)
end

function CppCallLua.PandoraShowActivityRedDot(AppId, IsShow)
	_G.FLOG_INFO("CppCallLua.PandoraShowActivityRedDot, AppId:%s, IsShow:%s", AppId, tostring(IsShow))
	_G.PandoraMgr:ShowActivityRedDot(AppId, IsShow)
end

function CppCallLua.PandoraGoSystem(Params)
	_G.FLOG_INFO("CppCallLua.PandoraGoSystem, Params:%s", Params)
	_G.PandoraMgr:GoToSystem(Params)
end

function CppCallLua.PandoraShowReceivedItems(ReceivedItems)
	_G.FLOG_INFO("CppCallLua.PandoraShowReceivedItems, ReceivedItems:%s", ReceivedItems)
	_G.PandoraMgr:ShowReceivedItems(ReceivedItems)
end

function CppCallLua.PandoraShareMiniApp(Params)
	_G.FLOG_INFO("CppCallLua.PandoraShareMiniApp, Params:%s", Params)
	_G.PandoraMgr:PandoraShareMiniApp(Params)
end

function CppCallLua.PandoraGetUserInfo(OpenIDs, Source)
	_G.FLOG_INFO("CppCallLua.PandoraGetUserInfo, OpenIds:%s, Source:%s", OpenIDs, Source)
	_G.PandoraMgr:GetUserInfo(OpenIDs, Source)
end

function CppCallLua.PandoraIsPopPanelAllowed(AppId, AppName, ActivityClassification)
	_G.FLOG_INFO("CppCallLua.PandoraIsPopPanelAllowed, AppId:%s, AppName:%s, ActivityClassification:%s", AppId, AppName, ActivityClassification)
	_G.PandoraMgr:PandoraIsPopPanelAllowed(AppId, AppName, ActivityClassification)
end

function CppCallLua.PandoraOpenAnotherPandoraApp(TargetAppId, OpenArgs)
	-- _G.FLOG_INFO("CppCallLua.PandoraOpenAnotherPandoraApp, TargetAppId:%s, OpenArgs:%s", TargetAppId, OpenArgs)
	-- _G.PandoraMgr:OpenAnotherPandoraApp(TargetAppId, OpenArgs)
end

function CppCallLua.PandoraNotifySinkToBottom(AppId, AppName)
	_G.FLOG_INFO("CppCallLua.PandoraNotifySinkToBottom, AppId:%s, AppName:%s", AppId, AppName)
	_G.PandoraMgr:NotifyActivitySinkToBottom(AppId, AppName)
end

function CppCallLua.PandoraShowItemDetailTips(ItemID, ScreenPosition)
	_G.FLOG_INFO("CppCallLua.PandoraShowItemDetailTips, ItemID:%d, ScreenOffset:(%f, %f)", ItemID, ScreenPosition.X, ScreenPosition.Y)
	_G.PandoraMgr:ShowItemDetailTips(ItemID, ScreenPosition)
end

function CppCallLua.PandoraGetItemIconId(ItemID)
	_G.FLOG_INFO("CppCallLua.PandoraGetItemIconId, ItemID:%d", ItemID)
	return _G.PandoraMgr:GetItemIconId(ItemID)
end
-----------------Pandora相关-----------------

return CppCallLua