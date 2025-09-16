local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
-- local RaceDBCfg = require("TableCfg/RaceCfg")
local ProtoRes = require("Protocol/ProtoRes")
-- local ModuleType = ProtoRes.module_type
local EquipmentType = ProtoRes.EquipmentType

local EventID = require("Define/EventID")
-- local EventMgr = require("Event/EventMgr")
local UIViewMgr = require("UI/UIViewMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewID = require("Define/UIViewID")
local UIUtil = require("Utils/UIUtil")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local EquipmentProfSuitCfg = require("TableCfg/EquipmentProfSuitCfg")
-- local EquipmentRaceSuitCfg = require("TableCfg/EquipmentRaceSuitCfg")
local HairCfg = require("TableCfg/HairCfg")
local MajorUtil = require("Utils/MajorUtil")

local LoginRoleRaceGenderVM = require("Game/LoginRole/LoginRoleRaceGenderVM")
local LoginRoleTribePageVM = require("Game/LoginRole/LoginRoleTribePageVM")
local LoginCreateAvatarVM = require("Game/LoginCreate/LoginCreateAvatarVM")
local LoginCreateCustomizeVM = require("Game/LoginCreate/LoginCreateCustomizeVM")
local LoginRoleBirthdayVM = require("Game/LoginRole/LoginRoleBirthdayVM")
local LoginRoleGodVM = require("Game/LoginRole/LoginRoleGodVM")
local LoginRoleProfVM = require("Game/LoginRole/LoginRoleProfVM")
local LoginRoleSetNameVM = require("Game/LoginRole/LoginRoleSetNameVM")
local ProtoCommon = require("Protocol/ProtoCommon")

local LoginRoleShowPageVM = require("Game/LoginRole/LoginRoleShowPageVM")
local LoginRoleMainPanelVM = require("Game/LoginRole/LoginRoleMainPanelVM")

local EmotionCfg = require("TableCfg/EmotionCfg")
local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")

local LoginFeedbackAnimCfg = require("TableCfg/LoginFeedbackAnimCfg")

local LoginConfig = require("Define/LoginConfig")
local RaceFaceCfg = require("TableCfg/RaceFaceCfg")
local ActorUtil = require("Utils/ActorUtil")
local CommonUtil = require("Utils/CommonUtil")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")
local SaveKey = require("Define/SaveKey")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local DataReportUtil = require("Utils/DataReportUtil")

_G.IsNewLoginVersion = true
-- _G.IsDemoMajor = false
_G.DemoMajorType = 0	-- 0：正式主角 1: 技能演示场景的DemoMajor   2：出生场景的临时角色的DemoMajor
local LSTR = _G.LSTR
--
--1、创建角色的流程管理
--2、记录进度条上 各个阶段的选择数据，以及相关ui，已方便隐藏以及退出创建
--3、记录创角和选角的场景，统一在此，只有1份
--4、创角和选角的角色模型统一在此，只有1份，也方便各个阶段直接使用

_G.LoginRolePhase = _G.LoginRolePhase or
{
	SelectRole = 0,		--角色选择	--- 下面是创建角色的
	RaceGender = 1,		--选择种族、性别
	Tribe = 2,
	--捏脸的跳过，等后续处理的时候，这里需要将数字重新按顺序调整
	Avatar = 3,         --选择外貌
	CustomAppearance = 4, -- 自定义外貌（捏脸）
	Birthday = 5,		--选择创建日
	God = 6,			--选择守护神
	Prof = 7,			--选择职业
	SetName = 8,		--设置昵称
	Finishment = 9,		--确认和完成（幻想药）
}

local LoginRolePhase = _G.LoginRolePhase

--由于增加了幻想药的流程，PhaseType的值不一定等于PhaseIndex了，
--也无法直接通过+1/-1的方式获取下一个/上一个阶段，因此需要几张表进行一个转换
--具体转换逻辑封装在函数中以供拓展和使用PhaseTypeToIndex/PhaseIndexToType/GetNextPhaseType
--
--下面两张表用于PhaseType和PhaseIndex的转换，主要用于流程进度条相关的逻辑，那里更关注第几个和不是具体类型
--如果表中没有对应的Type或Index，则说明Type和Index相等
--函数： PhaseTypeToIndex, PhaseIndexToType
PhaseTypeToIndexTable_ForFantasia = PhaseTypeToIndexTable_ForFantasia or
{
	[LoginRolePhase.Finishment] = 7,	--幻想药模式下，Finishment是第7个Phase
}
PhaseIndexToTypeTable_ForFantasia = PhaseIndexToTypeTable_ForFantasia or
{
	[7] = LoginRolePhase.Finishment,	--幻想药模式下，第7个Phase是Finishment
}
--下面两张表是用映射表的方式决定当前阶段的Next和Pre阶段是什么
--如果映射表中没有对应的阶段，则其Next和Pre阶段为其+1和-1对应的阶段
--函数： GetNextPhaseType, GetPrePhaseType
NextPhaseJumpTable_ForFantasia = NextPhaseJumpTable_ForFantasia or
{
	[LoginRolePhase.God] = LoginRolePhase.Finishment,	--幻想药模式下，God阶段下一阶段是Finishment
}
PrePhaseJumpTable_ForFantasia = PrePhaseJumpTable_ForFantasia or
{
	[LoginRolePhase.Finishment] = LoginRolePhase.God,	--幻想药模式下，Finishment阶段上一阶段是God
}

--幻想药入睡、苏醒动画
Fantasia_Sequence_Sleep = Fantasia_Sequence_Sleep or
{
	["s1ti"] = 21600111,
	["w1ti"] = 21600112,
	["f1ti"] = 21600113,
}
Fantasia_Sequence_Wakeup = Fantasia_Sequence_Wakeup or
{
	["s1ti"] = 21600114,
	["w1ti"] = 21600115,
	["f1ti"] = 21600116,
}

LoginShowType = LoginShowType or
{
	Suit = 1,	--套装
	Action = 2, --动作
	Map = 3,	--环境
	Time = 4,	--时间
	Weather = 5,--天气
}

--LoginRoleRender2D和LoginFixPage是各个阶段都需要的，所以就不专门配置了，默认是必然带上的
--每个阶段都可能从后面的阶段或者别的界面跳回来，所以需要保持原来VM中的数据，除非VM被DiscardData
--每个VM实现如下接口
	--DiscardData：把玩家该阶段的数据丢弃掉，回到初始化数据
	--FillRoleRegisterMsg：将自己阶段的数据填充到协议中
_G.CreateRoleConfig = _G.CreateRoleConfig or
{
	[LoginRolePhase.RaceGender] = {Title = LSTR(980075), VM = LoginRoleRaceGenderVM , Views = {UIViewID.LoginCreateRaceGender}},--选择种族&性别
	[LoginRolePhase.Tribe] = {Title = LSTR(980076), VM = LoginRoleTribePageVM, Views = {UIViewID.LoginCreateTribe} },--选择部族
	[LoginRolePhase.Avatar] = {Title = LSTR(980077), VM = LoginCreateAvatarVM, Views = {UIViewID.LoginCreateAppearance} },--选择外貌
	[LoginRolePhase.CustomAppearance] = {Title = LSTR(980061), VM = LoginCreateCustomizeVM, Views = {UIViewID.LoginCreateAppearanceCustomize} },--外貌细节
	[LoginRolePhase.Birthday] = {Title = LSTR(980078), VM = LoginRoleBirthdayVM, Views = {UIViewID.LoginRoleBirthday} },--选择创建日
	[LoginRolePhase.God] = {Title = LSTR(980079), VM = LoginRoleGodVM, Views = {UIViewID.LoginRoleGod} },--选择守护神
	[LoginRolePhase.Prof] = {Title = LSTR(980080), VM = LoginRoleProfVM, Views = {UIViewID.LoginRoleProf} },--选择职业
	[LoginRolePhase.SetName] = {Title = LSTR(980062), NextBtnText = LSTR(980093), VM = LoginRoleSetNameVM, Views = {UIViewID.LoginRoleName} },--设置昵称 --完成创建
	--Finishment为幻想药的完成创建阶段，复用设置昵称的View
	[LoginRolePhase.Finishment] = {Title = LSTR(980036), NextBtnText = LSTR(980081), VM = nil, Views = {UIViewID.LoginRoleName} },--确认信息--完成编辑
}
local CreateRoleConfig = _G.CreateRoleConfig
--选部族，也会更新LoginRoleRaceGenderVM.CurrentRaceCfg，也就是说这个Cfg是最新的种族、性别、部族

---@class LoginUIMgr : MgrBase
local LoginUIMgr = LuaClass(MgrBase)

function LoginUIMgr:OnInit()
	self.RoleRender2DViewID = UIViewID.LoginRoleRender2D

	self.ProfSuitList = {}
	self.RaceSuitList = {}
	self.FeedbackAnimList = {}

	-- FeedbackAnimType 1：试穿  2：点击职业按钮
	self.FeedbackAnimType = 0
	self.LoginReConnectMgr = require("Game/LoginRole/LoginReConnectMgr")
	self.LoginReConnectMgr:OnInit()
end

function LoginUIMgr:OnBegin()
	--记录共用的ui
	self.Common_Render2D_UIBP = nil
	self.Render2DView = nil
	self.ProgressPage = nil
	self.FixPageView = nil

	--记录是创建还是选角，记录创建阶段
	self.IsCreateRole = false
	self:SetCurLoginRolePhase(LoginRolePhase.SelectRole)
	--记录是不是在幻想药模式
	self.IsInFantasia = false

	--记录当前最多的进度到哪里了，控制阶段跳转
	self.MaxDonePhase = LoginRolePhase.SelectRole
	--当前的套装
	self.RoleWearSuitCfg = nil
	--记录当前的职业装
	self.CurProfSuitCfg = nil
	self.RecordProfSuitCfg = nil	--只要穿过职业装，就会始终记录，而CurProfSuitCfg可能会变为nil（哪怕选过职业了）

	self.IsFixPageClickBtnMore = false

	--记录是否正在打开预览界面
	self.IsShowPreviewPage = false
	--_G.UE.USaveMgr.GetInt(SaveKey.ShowPreviewPage, 0, true) == 1

	self.RenderActorCreated = false
	self.IsGaze = false

	--默认显示种族套装
	self.CurrentSuitType = ProtoRes.suit_type.SUIT_TYPE_RACE

	self.LoginReConnectMgr:OnBegin()
end

function LoginUIMgr:OnEnd()
	self:ResetRecordUI()

	self:Reset()
	self.LoginReConnectMgr:OnEnd()
end

function LoginUIMgr:OnShutdown()
	self.LoginReConnectMgr:OnShutdown()
end

function LoginUIMgr:ResetRecordUI()
	self.Common_Render2D_UIBP = nil
	self.Render2DView = nil
	self.ProgressPage = nil
	self.FixPageView = nil

	-- self:ReleaseCameraActor()
end

function LoginUIMgr:Reset()
	self.IsCreateRole = false
	self:SetCurLoginRolePhase(LoginRolePhase.SelectRole)

	self.MaxDonePhase = LoginRolePhase.SelectRole
	self.RoleWearSuitCfg = nil
	self.CurProfSuitCfg = nil
	self.RecordProfSuitCfg = nil

	self.FeedbackAnimType = 0
	self.ForceWear = true
	
	self.IsInFantasia = false

	self.CurrentSuitType = ProtoRes.suit_type.SUIT_TYPE_RACE

	self.HairCutMajorEquipList = nil
	-- 捏脸界面数据清理
	_G.LoginAvatarMgr:Reset()
end

function LoginUIMgr:GetCurRolePhase()
	return self.CurLoginRolePhase
end

function LoginUIMgr:GetFeedbackAnimType()
	return self.FeedbackAnimType or 0
end

function LoginUIMgr:SetFeedbackAnimType(AnimType)
	self.FeedbackAnimType = AnimType
end
------------------- 流程管理 begin--------------------------

function LoginUIMgr:ShowPhaseView(Phase)
	if Phase == LoginRolePhase.SelectRole or Phase > #CreateRoleConfig then
		return
	end

	FLOG_INFO("Login ShowPhaseView phase=%d", Phase)
	--得要先显示，否则会脚本报错，self的Common_Render2D_UIBP是nil
	UIViewMgr:ShowView(self.RoleRender2DViewID)
	if self.Common_Render2D_UIBP then
		if Phase == LoginRolePhase.God then
			self.Common_Render2D_UIBP:HidePlayer(true)
		else
			self.Common_Render2D_UIBP:HidePlayer(false)
		end
	end

	UIViewMgr:ShowView(UIViewID.LoginFixPage)

	-- if self.CurLoginRolePhase == LoginRolePhase.Avatar then
	-- 	LoginRoleShowPageVM.CurrentSuitIndex = 1
	-- end

	--隐藏副标题
	self:SetSubTitle()

	local PhaseConfig = CreateRoleConfig[Phase]
	if PhaseConfig then
		for index = 1, #PhaseConfig.Views do
			UIViewMgr:ShowView(PhaseConfig.Views[index])
		end
	end

	if self.ProgressPage then
		self.ProgressPage:OnPhaseChage(self.CurLoginRolePhase)
	end

	if self.FixPageView then
		self.FixPageView:OnPhaseChage(self.CurLoginRolePhase)
	end

	-- 相机复位
	if self.CurLoginRolePhase ~= LoginRolePhase.Avatar and self.CurLoginRolePhase ~= LoginRolePhase.CustomAppearance then
		_G.LoginAvatarMgr:SetCameraFocus(0, true, false)
	end
end

function LoginUIMgr:HidePhaseView(Phase)
	if Phase == LoginRolePhase.SelectRole or Phase > #CreateRoleConfig
		or Phase < 0 then
		return
	end

	FLOG_INFO("Login HidePhaseView phase=%d", Phase)

	local PhaseConfig = CreateRoleConfig[Phase]
	for index = 1, #PhaseConfig.Views do
		UIViewMgr:HideView(PhaseConfig.Views[index])
	end
end

function LoginUIMgr:OnSendRoleLoginReqAfterRegister(bStopBGM)
	_G.WorldMsgMgr:ShowLoadingView("", LoginConfig.BirthWorldName)

	if bStopBGM then
		_G.LoginMapMgr:StopBGM()
	end
end

-- 是否提示玩家未修改数据
function LoginUIMgr:IsShowFaceTips()
	local bShowTips = false
	if self.CurLoginRolePhase == LoginRolePhase.CustomAppearance then
		local AvatarFace = _G.LoginAvatarMgr:GetCurAvatarFace()
		local PhaseFace = _G.LoginAvatarMgr:GetPhaseAvatarFace()
        if AvatarFace~= nil and PhaseFace ~= nil and table.compare_table(PhaseFace, AvatarFace) then
            bShowTips = true
        end
	end
	return bShowTips
end

function LoginUIMgr:SwitchToNextPhase()
	if self.CurLoginRolePhase == LoginRolePhase.SetName then
		-- LoginRoleSetNameVM:RecordRoleName()

		-- if not LoginRoleSetNameVM:OnFinishName() then
		-- 	return
		-- end
		local TipContent = string.format(LSTR(980115))--确认要完成创角，进入游戏吗？
		local function OkCallBack()
			self:OnEnterBornScene()
		end
		
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(980022), TipContent, OkCallBack
		    , nil, LSTR(980087), LSTR(980088))--取 消--确 认

		return
	end

	--如果当前阶段是Finishment，点击下一步（完成创建）则会弹出确认框
	if _G.LoginMapMgr.CurLoginMapType == _G.LoginMapType.Fantasia
			and self.CurLoginRolePhase == LoginRolePhase.Finishment then
		local changed, reason = self:CheckFantasiaAvatarChanged()
		if changed then
			FLOG_INFO("Avatar was changed! Reason: {1}", reason)
			UIViewMgr:ShowView(UIViewID.FantasiaFinishWin)
		else
			local TipContent = string.format(LSTR(980082))--当前未进行修改，确认要退出角色编辑吗？
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(980083), TipContent, self.DoExitFantasia)--退出角色编辑
		end
		return
	end

	local LastPhase = self.CurLoginRolePhase
	FLOG_INFO("=====Login SwitchToNextPhase Curphase=%d", self.CurLoginRolePhase)
	self:HidePhaseView(self.CurLoginRolePhase)

	local CurPhase = self:GetNextPhaseType(self.CurLoginRolePhase)
	self:SetCurLoginRolePhase(CurPhase, true)

	self:PlaySwitchAnim(self.CurLoginRolePhase)

	if self.CurLoginRolePhase > self.MaxDonePhase then
		self.MaxDonePhase = self.CurLoginRolePhase
	end
	
	--现在保留预览界面切换的地图
	-- if LastPhase == LoginRolePhase.Avatar then
	-- 	local Rlt = _G.LoginMapMgr:BackToOrignMap()
	-- 	if Rlt and Rlt == -1 then
	-- 	else
	-- 		_G.LoginUIMgr:SetFeedbackAnimType(6)
	-- 		_G.WorldMsgMgr:ShowLoadingView("", "")
	-- 	end
	-- end

	self:ShowPhaseView(self.CurLoginRolePhase)

	if self.CurLoginRolePhase == LoginRolePhase.CustomAppearance then
		-- 页面数据清空
		_G.LoginAvatarMgr:ResetPhaseData()
		_G.LoginAvatarMgr:RecordPhaseAvatar()
	end
	-- if self.ProgressPage then
	-- 	self.ProgressPage:OnPhaseChage(self.CurLoginRolePhase)
	-- end
	
	self:ReportLoginCreateData(self.CurLoginRolePhase)

	_G.ObjectMgr:CollectGarbage(false)
end

function LoginUIMgr:ReportLoginCreateData(CurLoginRolePhase)
	if _G.LoginMapMgr:IsRealLoginMap() then
		local AppStartTime = CommonUtil.GetAppStartTime()

		if CurLoginRolePhase >= LoginRolePhase.RaceGender and CurLoginRolePhase <= LoginRolePhase.SetName then
			DataReportUtil.ReportLoginCreateData(tostring(20 + CurLoginRolePhase), _G.UE.UPlatformUtil.GetDeviceName()
				, _G.LoginMgr.OpenID, tostring(AppStartTime))

			_G.UE.UGPMMgr.Get():PostLoginStepEvent(_G.DataReportLoginPhase.LoginCreateRaceGender + CurLoginRolePhase - 1
				, 0, 0, "Success", "", false, false)
		end
	end
end

function LoginUIMgr:PlaySwitchAnim(CurPhase, bForce)
	if bForce or CurPhase == LoginRolePhase.Tribe
		or CurPhase == LoginRolePhase.Avatar
		or CurPhase == LoginRolePhase.CustomAppearance
		or CurPhase == LoginRolePhase.SetName then
		local RaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
		if RaceCfg then
			self:PlayEmotionAnim(RaceCfg.EnterAnimID)
		end
	end
end

function LoginUIMgr:PlayEmotionAnim(EmotionID, CallBack)
	local UIComplexCharacter = self:GetUIComplexCharacter()
	if not UIComplexCharacter then
		return
	end

	local Cfg = EmotionCfg:FindCfgByKey(EmotionID)
	if Cfg then
		local AnimPath = EmotionAnimUtils.GetActorEmotionAnimPath(Cfg.AnimPath
							, UIComplexCharacter, EmotionDefines.AnimType.EMOT)
		local Render2DView = self.Common_Render2D_UIBP
		if Render2DView then
			Render2DView:PlayAnyAsMontage(AnimPath, "WholeBody", CallBack, nil, "")
		end
	end
end

function LoginUIMgr:SwitchToPhase(ToPhase)
	--临时代码，avatar跳过
	-- if ToPhase == 3 or ToPhase == 4 then
	-- 	MsgTipsUtil.ShowTips(LSTR("暂未支持，敬请期待"))
	-- 	return
	-- end

	if ToPhase > self.MaxDonePhase then
		FLOG_WARNING("=====Login SwitchToPhase ToPhase=%d, but greate MaxPhase %d", ToPhase, self.MaxDonePhase)
		return
	end

	if ToPhase == self.CurLoginRolePhase then
		return
	end

	-- if self.CurLoginRolePhase == LoginRolePhase.SetName then
	-- 	LoginRoleSetNameVM:RecordRoleName()
	-- end

	FLOG_INFO("=====Login SwitchToPhase ToPhase=%d", ToPhase)

	self:HidePhaseView(self.CurLoginRolePhase)

	self:SetCurLoginRolePhase(ToPhase, true)
	self:ShowPhaseView(self.CurLoginRolePhase)
end

function LoginUIMgr:SwitchToPrePhase()
	FLOG_INFO("=====Login SwitchToPrePhase Curphase=%d", self.CurLoginRolePhase)

	local LastPhase = self.CurLoginRolePhase
	-- if self.CurLoginRolePhase == LoginRolePhase.SetName then
	-- 	LoginRoleSetNameVM:RecordRoleName()
	-- end

	if self.CurLoginRolePhase == LoginRolePhase.RaceGender then
		local function OkBtnCallback()
			self:DoCleanCurPhase()
			--重置数据、状态
			self:DoExitCreateRole()
		end

		local TipContent = string.format(LSTR(980084))--确认要退出角色创建吗？
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(980022), TipContent, OkBtnCallback)--提示
		return
	end

	self:DoCleanCurPhase(true)

	self:ShowPhaseView(self.CurLoginRolePhase)

	-- if LastPhase == LoginRolePhase.Avatar then
	-- 	_G.LoginMapMgr:BackToOrignMap()
	-- 	-- _G.LoginUIMgr:SetFeedbackAnimType(6)
	-- end
	-- if self.ProgressPage then
	-- 	self.ProgressPage:OnPhaseChage(self.CurLoginRolePhase)
	-- end

	self:ReportLoginCreateData(self.CurLoginRolePhase)
end

function LoginUIMgr:DoCleanCurPhase(bSaveForReconnect)
	self:HidePhaseView(self.CurLoginRolePhase)
	local CurPhase = self:GetPrePhaseType(self.CurLoginRolePhase)
	self:SetCurLoginRolePhase(CurPhase, bSaveForReconnect)

	--当前阶段VM中的数据就不用管DiscardData了，会保持着，除非退出创建
end

--退出创角过程:比如右上角的关闭按钮
--重置数据，状态
function LoginUIMgr:ExitCreateRole()
	--幻想药有特殊的终止逻辑
	if _G.LoginMapMgr.CurLoginMapType == _G.LoginMapType.Fantasia then
		local TipContent = string.format(LSTR(980085))--确认要退出角色编辑吗？
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(980083), TipContent, self.DoExitFantasia)--退出角色编辑
		return
	end
	local TipContent = string.format(LSTR(980084))--确认要退出角色创建吗？
	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(980022), TipContent, self.PreExitCreateRole)--提示
end

function LoginUIMgr:PreExitCreateRole()
	_G.LoginMgr:QueryRoleList()
	_G.LoginMgr.bBackToSelectRoleFromCreate = true
end

function LoginUIMgr:DoExitCreateRole()
	self:HideCreateRoleView()
	self:ResetRecordUI()

	UIViewMgr:HideAllUI()
	UIViewMgr:ReleaseAllPoolWidgets()

	self:Reset()	--要在后面，否则之前的view没有hide掉

	self:DiscardCreateRoleData()
	self.LoginReConnectMgr:ExitCreateRole()

	if _G.LoginMgr:HasRoleCount() == 0 then
		_G.LifeMgrModule.ShutdownAccountLife()

		if not _G.LoginMapMgr:IsSelectRoleMap() then
			_G.PWorldMgr:ChangeToLocalMap("/Game/Maps/Login", true)
		end
		
		-- 没有角色，则返回到登录界面，而不是选角界面
		UIViewMgr:ShowView(_G.LoginMgr:GetLoginMainViewId())
		_G.LoginMgr:ShowBackLoginAnim()
	else
		-- 有角色，则返回选人界面
		self:ShowSelectRoleView()
		self:ResetRenderActorCamera(false)
	end
	
	local function DelayCollectGarbage()
		_G.ObjectMgr:CollectGarbage(false)
	end

	_G.TimerMgr:AddTimer(nil, DelayCollectGarbage, 1, 1, 1)
end

function LoginUIMgr:DiscardCreateRoleData()
	local PhaseNum = #CreateRoleConfig
	for index = 1, PhaseNum do
		local VM = CreateRoleConfig[index].VM
		if VM and VM.DiscardData then
			--重置各阶段数据
			VM:DiscardData()
		end
	end

	LoginRoleShowPageVM:DiscardData()
end

function LoginUIMgr:GetCurPhaseConfig()
	local Phase = self.CurLoginRolePhase
	if Phase == LoginRolePhase.SelectRole or Phase > #CreateRoleConfig then
		return
	end

	local PhaseConfig = CreateRoleConfig[Phase]
	return PhaseConfig
end

function LoginUIMgr:SetNextBtnEnable(IsEnable)
	if self.FixPageView then
		-- self.FixPageView.BtnStart:SetIsEnabled(IsEnable)
		if IsEnable then
			UIUtil.SetIsVisible(self.FixPageView.BtnStart, true, true)
			UIUtil.SetIsVisible(self.FixPageView.BtnStartDisableImg, false)
			UIUtil.SetIsVisible(self.FixPageView.TextStart, true)
			UIUtil.TextBlockSetColorAndOpacityHex(self.FixPageView.TextStart, "#FFFFFF")
			self.FixPageView.TextStart:SetColorAndOpacity(self.TextRawColorAndOpacity)
		else
			UIUtil.SetIsVisible(self.FixPageView.BtnStartDisableImg, true)
			UIUtil.SetIsVisible(self.FixPageView.BtnStart, false)
			UIUtil.SetIsVisible(self.FixPageView.TextStart, true)
			UIUtil.TextBlockSetColorAndOpacityHex(self.FixPageView.TextStart, "#828282")
			self.FixPageView.TextStart:SetColorAndOpacity(self.TextRawColorAndOpacity)
		end
	end
end

function LoginUIMgr:SetNextBtnVisible(IsShow)
	if self.FixPageView then
		if not IsShow then
			UIUtil.SetIsVisible(self.FixPageView.BtnStart, IsShow, IsShow)
			UIUtil.SetIsVisible(self.FixPageView.BtnStartDisableImg, IsShow)
			UIUtil.SetIsVisible(self.FixPageView.TextStart, IsShow)
		else
			local IsDisable = UIUtil.IsVisible(self.FixPageView.BtnStartDisableImg)
			if IsDisable then
				self:SetNextBtnEnable(false)
			else
				self:SetNextBtnEnable(true)
			end
		end
	end
end

function LoginUIMgr:ClickMakeNameBtn()
	LoginRoleSetNameVM:OnFinishName()
end

--昵称确定后，就创建角色了
function LoginUIMgr:OnFinishName(RoleName)
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if not CurrentRaceCfg then
		FLOG_ERROR("LoginUIMgr:OnFinishName, CurrentRaceCfg is nil")
		return false
	end

	FLOG_INFO("LoginUIMgr:OnFinishName: %s", RoleName)
	if CommonUtil.GetPlatformName() == "Windows" then
		_G.LoginMgr.IsClickFinishCreateBtn = false
	end

	local RoleRegister = _G.LoginMgr.DemoRoleRegister	--{Name = RoleName}
	RoleRegister.Name = RoleName
	-- self:FillRegisterMsg(RoleRegister)
	_G.LoginMgr:SendRegisterRoleReq(RoleRegister)
	return true
end

--幻想药完成确认，收集角色信息并提交
function LoginUIMgr:OnConfirmFantasiaProfileUpdate()
	if self.HasSendReqCmd then
		--可能因为断线重连，实际已经发送了请求(可能后台也处理了)，但没有收到回包，
		--此时没有离开幻想药界面，仍然可以点击确认，直接提示网络异常
		MsgTipsUtil.ShowTips(LSTR(1260001))
		return false
	end
	self.HasSendReqCmd = true
	local Profile = {}
	self:FillFantasiaProfileUpdateMsg(Profile)
	_G.LoginMgr:SendUseFantasyMedicineReq(Profile)
	return true
end

--创建演示技能的角色（IsNewbie：false）以及进出生场景的临时角色（IsNewbie：true）
function LoginUIMgr:CreateDemoMajor(IsNewbie)
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if not CurrentRaceCfg then
		FLOG_ERROR("LoginUIMgr:CreateDemoMajor, CurrentRaceCfg is nil")
		return
	end

	FLOG_INFO("LoginUIMgr:CreateDemoMajor :%s", tostring(IsNewbie))
	local RoleRegister = {Name = ""}
	RoleRegister.IsNewbie = IsNewbie
	self:FillRegisterMsg(RoleRegister)

	local EquipList = {}
	if self.RoleWearSuitCfg then
		for idx = 1, #self.RoleWearSuitCfg.EquipList do
			local EquipID = self.RoleWearSuitCfg.EquipList[idx]
			local EquipCfg = EquipmentCfg:FindCfgByEquipID(EquipID)
			if EquipCfg then
				FLOG_WARNING("LoginProf Equip: part:%d, EquipID:%d", EquipCfg.Part, EquipID)
				table.insert(EquipList, {EquipID = EquipID, Part = EquipCfg.Part, ResID = 0, ColorID = 0})
			end
		end

	end

	local ProfID = LoginRoleProfVM.CurrentProf.Prof
	if #self.ProfSuitList > 0 then
		if self.RoleWearSuitCfg and self.RoleWearSuitCfg.Prof and self.RoleWearSuitCfg.Prof > 0 then
			--之前已经是职业装了，所以会带武器的
		else
			for index = 1, #self.ProfSuitList do
				local SuitCfg = self.ProfSuitList[index]
				if ProfID == SuitCfg.Prof and SuitCfg.IsDefault == 1 then
					local WeaponID = SuitCfg.EquipList[1]
					local EquipCfg = EquipmentCfg:FindCfgByEquipID(WeaponID)
					if EquipCfg then
						FLOG_WARNING("====LoginProf Equip Weapon: part:%d, EquipID:%d", EquipCfg.Part, WeaponID)
						table.insert(EquipList, 1, {EquipID = WeaponID, Part = EquipCfg.Part, ResID = 0, ColorID = 0})
					end

					break
				end
			end
		end
	end

	RoleRegister.Avatar.EquipList = EquipList
	_G.LoginMgr:SendRegisterDemoRoleReq(RoleRegister)

	return true
end

function LoginUIMgr:FillRegisterMsg(RoleRegister)
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	local ProfID = LoginRoleProfVM.CurrentProf.Prof
	local Gender = CurrentRaceCfg.Gender
	local RaceID = CurrentRaceCfg.RaceID
	local TribeID = CurrentRaceCfg.Tribe

	local Scale = 1
	local FaceCfg = RaceFaceCfg:FindCfgByTribeIDAndGender(TribeID, Gender)
	if FaceCfg ~= nil then
		Scale = FaceCfg.DefaultScale * 1000
		Scale = math.floor(Scale)
	end
	--local HairID = HairCfg:GetFirstHairByTribeAndGender(TribeID, Gender)

	local Avatar = {}
	local face = {}
	--捏脸数据加入
	local CurFace = _G.LoginAvatarMgr:GetCurAvatarFace()
	if CurFace == nil or table.size(CurFace) == 0 then
		-- 确保有捏脸数据
		_G.LoginAvatarMgr:EnsureCurAvatarFace()
		face = _G.LoginAvatarMgr:GetCurAvatarFace()
	else
		face = CurFace
	end
	--face[ProtoCommon.avatar_personal.AvatarPersonalHeight] = Scale
	--face[ProtoCommon.avatar_personal.AvatarPersonalHair] = HairID

	Avatar.Face = face

	--基本数据
	RoleRegister.Gender = Gender
	RoleRegister.Race = RaceID
	RoleRegister.Tribe = TribeID

	--Avatar
	RoleRegister.Avatar = Avatar

	--创建日
	RoleRegister.CreateMoon = LoginRoleBirthdayVM.SelectMonthIndex
	RoleRegister.CreateStar = LoginRoleBirthdayVM.SelectDayIndex

	--十二神
	local GodID = ProtoCommon.twelve_god_type.TWELVE_GOD_Halone
	if LoginRoleGodVM.CurrentGodCfg then
		GodID = LoginRoleGodVM.CurrentGodCfg.GodID
		RoleRegister.GodType = GodID
	else
		FLOG_ERROR("LoginUIMgr, CurrentGodCfg nil")
	end

	--职业
	RoleRegister.Prof = ProfID
end

--使用幻想药时，上报的角色数据
--RoleProfile结构参考 csfantasymedicine.proto 中的ProfileUpdate
function LoginUIMgr:FillFantasiaProfileUpdateMsg(RoleProfile)
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	local Gender = CurrentRaceCfg.Gender
	local RaceID = CurrentRaceCfg.RaceID
	local TribeID = CurrentRaceCfg.Tribe

	local Scale = 1
	local FaceCfg = RaceFaceCfg:FindCfgByTribeIDAndGender(TribeID, Gender)
	if FaceCfg ~= nil then
		Scale = FaceCfg.DefaultScale * 1000
		Scale = math.floor(Scale)
	end
	--local HairID = HairCfg:GetFirstHairByTribeAndGender(TribeID, Gender)

	-- local Avatar = {}
	local face = {}
	--捏脸数据加入
	local CurFace = _G.LoginAvatarMgr:GetCurAvatarFace()
	if CurFace == nil or table.size(CurFace) == 0 then
		-- 确保有捏脸数据
		_G.LoginAvatarMgr:EnsureCurAvatarFace()
		face = _G.LoginAvatarMgr:GetCurAvatarFace()
	else
		face = CurFace
	end
	--face[ProtoCommon.avatar_personal.AvatarPersonalHeight] = Scale
	--face[ProtoCommon.avatar_personal.AvatarPersonalHair] = HairID

	-- Avatar.Face = face

	--基本数据
	RoleProfile.Gender = Gender
	RoleProfile.Race = RaceID
	RoleProfile.Tribe = TribeID

	--Avatar
	RoleProfile.Avatar = face

	--创建日
	RoleProfile.CreateMoon = LoginRoleBirthdayVM.SelectMonthIndex
	RoleProfile.CreateStar = LoginRoleBirthdayVM.SelectDayIndex

	--十二神
	local GodID = ProtoCommon.twelve_god_type.TWELVE_GOD_Halone
	if LoginRoleGodVM.CurrentGodCfg then
		GodID = LoginRoleGodVM.CurrentGodCfg.GodID
	else
		FLOG_ERROR("LoginUIMgr, CurrentGodCfg nil")
	end
	RoleProfile.GodType = GodID
end

--体验角色，开始进入演示场景
function LoginUIMgr:OnEnterDemoSkill()
	FLOG_INFO("LoginUIMgr:OnEnterDemoSkill")
	-- local TeXiaoTest = _G.ObjectMgr:LoadObjectSync(LoginConfig.DemoSkillLevelPath, 0)
    -- if not TeXiaoTest then
	-- 	-- MsgTipsUtil.ShowTips("TeXiaoTest failed")
    -- end

	-- local RenderActor = _G.ObjectMgr:LoadObjectSync("Blueprint'/Game/UI/Render2D/BP_Render2DSkillSystemActor.BP_Render2DSkillSystemActor_C'", 0)
    -- if not RenderActor then
	-- 	-- MsgTipsUtil.ShowTips("RenderActor failed")
    -- end
	-- local da = _G.ObjectMgr:LoadObjectSync("SkillSystemDataAsset'/Game/BluePrint/Skill/SkillSystem/SkillSystemConfig.SkillSystemConfig''", 0)
    -- if not da then
	-- 	-- MsgTipsUtil.ShowTips("SkillSystemDataAsset failed")
    -- end

	-- _G.IsDemoMajor = true
	_G.DemoMajorType = 1
	LoginRoleProfVM.bBackFromPreview = true

	self:CreateDemoMajor(false)
	self:HideCreateRoleView()

	_G.WorldMsgMgr:ShowLoadingView("", LoginConfig.DemoSkillWorldName)
end

--临时角色（还没命名的），开始进入出生场景
function LoginUIMgr:OnEnterBornScene()
	FLOG_INFO("LoginUIMgr:OnEnterBornScene")

	_G.DemoMajorType = 2

	self:CreateDemoMajor(true)
	self:HideCreateRoleView()

	self:OnSendRoleLoginReqAfterRegister(true)
end


--Role的LogOut已经回包了
function LoginUIMgr:OnExitDemoSkill()
	-- if _G.IsDemoMajor then
	-- 	FLOG_INFO("LoginUIMgr:OnExitDemoSkill")

	-- 	--返回到选职业界面
	-- 	_G.PWorldMgr:ChangeToLocalMap("/Game/Maps/Login", true)
	-- 	_G.LifeMgrModule.ShutdownRoleLife()
	-- end
end

--等待login加载完成，再_G.IsDemoMajor = false
function LoginUIMgr:OnLoginLoadFinish()
	FLOG_INFO("LoginUIMgr:OnLoginLoadFinish")
	-- if not _G.IsDemoMajor then
	if _G.DemoMajorType == 0 then
		return
	end

	self:ShowPhaseView(self.CurLoginRolePhase)

	--local ProfID = LoginRoleProfVM.CurrentProf.Prof
	self:CreateRenderActor()
	self:ChangeGender()
	self.ForceWear = true
	-- self:SetProfEquips(ProfID)

	local function DelaySetViewTarget()
		if self.Common_Render2D_UIBP then
			self.Common_Render2D_UIBP:ChangeUIState(false)
		end
	end
	_G.TimerMgr:AddTimer(nil, DelaySetViewTarget, 0, 1, 1)

	_G.DemoMajorType = 0
end

------------------- 流程管理 end --------------------------

---------------------------------------------

function LoginUIMgr:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.ExitDemoSkill, self.OnExitDemoSkill)
	self:RegisterGameEvent(EventID.RoleLogoutRes, self.OnGameEventRoleLogoutRes)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.NetworkReconnected, self.OnNetworkReconnected)
    -- self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldMapExit)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldMapExit)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
end

function LoginUIMgr:OnRegisterNetMsg()
end

function LoginUIMgr:OnGameEventRoleLogoutRes(Params)
	if not Params or Params.LogOutReason ~= ProtoCS.LogoutReason.ExitDemo and Params.LogOutReason ~= ProtoCS.LogoutReason.HelloOverTime then
		self:DiscardCreateRoleData()
		self:Reset()
	end
end

-----------------断线重连 begin---------------
function LoginUIMgr:OnGameEventLoginRes(Params)
    local bReconnect = Params and Params.bReconnect
    --处理断线重连 回复到上一操作信息界面
    if bReconnect and self.IsInFantasia then
        -- self:CreateCameraActor()
		-- 断线重连要返回上一界面，闪断重连保持在预览界面
		self.IsShowPreviewPage = false
		UIViewMgr:HideView(_G.LoginMapMgr:GetPreViewPageID())
		self:ReturnCurPhaseView(true)
		self:CreateRenderActor()
		self:ResetMorePageBtnState()
		CommonUtil.HideJoyStick()
	else
		-- 非重连情况，不管是不是幻想药，都要退出预览界面
		-- self.IsShowPreviewPage = false
		-- _G.UE.USaveMgr.SetInt(SaveKey.ShowPreviewPage, 0, true)
    end
end
function LoginUIMgr:OnNetworkReconnected(Params)
    local bRelay = Params and Params.bRelay
    --处理断线重连 回复到上一操作信息界面
    if bRelay and self.IsInFantasia then
        -- self:CreateCameraActor()
		-- 断线重连要返回上一界面，闪断重连保持在预览界面
		if self.IsShowPreviewPage then
			self:OnShowPreviewPage()
		else
			self:ReturnCurPhaseView(true)
		end
		self:CreateRenderActor()
		self:ResetMorePageBtnState()
		CommonUtil.HideJoyStick()
    end
end

-----------------断线重连 end----------------

function LoginUIMgr:SetCurLoginRolePhase(CurPhase, bSaveForReconnect)
	self.CurLoginRolePhase = CurPhase

	if bSaveForReconnect then
		self.LoginReConnectMgr:SaveValue("CurPhase", CurPhase)
	end
end

--开始创建角色
function LoginUIMgr:ShowCreateRoleView(bFromeLogin)
	self.bFromLoginCreate = bFromeLogin
	if self.LoginReConnectMgr:HaveNotFinishCreate() and _G.LoginMapMgr.CurLoginMapType == _G.LoginMapType.Login then
		local TipContent = string.format(LSTR(980086))--是否继续未完成的创建角色流程？
		local function OkCallBack()
			self:DoShowCreateRoleView(nil, nil, true)
		end

		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(980022), TipContent, OkCallBack
		    , self.DoShowCreateRoleView, LSTR(980087), LSTR(980088), {CloseClickCB = self.DoShowCreateRoleView})--取 消--确 认
	else
		self:DoShowCreateRoleView()
	end
end

function LoginUIMgr:DoRestore()
	local SaveData = self.LoginReConnectMgr.SaveData
	if not SaveData then
		return
	end

	local RaceID = SaveData.RaceID
	local Gender = SaveData.Gender
	local TribID = SaveData.TribID
	
	local PhaseNum = SaveData.MaxDonePhase
	if PhaseNum then
		for index = 1, PhaseNum do
			local VM = CreateRoleConfig[index].VM
			if VM and VM.Restore then
				VM:Restore()
			end
		end
		-- 恢复捏脸数据
		_G.LoginAvatarMgr:SetRecoverFlag()
	end
end

--LoginMap是打开创建界面使用的演示地图索引，对应【C创角表】中的ID，默认为LoginConfig.SelectRoleMap
function LoginUIMgr:DoShowCreateRoleView(LoginMap, NotResetRaceCfg, bReCover)
	if not LoginMap or type(LoginMap) ~= 'number' then
		LoginMap = LoginConfig.SelectRoleMap
	end
	self.IsCreateRole = true

	if not NotResetRaceCfg and not self.IsInFantasia then
    	LoginRoleRaceGenderVM:SelectRoleSetCurrentRaceCfg(nil)
	end

	if _G.IsNewLoginVersion then
		self:ClearRoleWearSuit()

		local CurPhase = LoginRolePhase.RaceGender
		self.MaxDonePhase = LoginRolePhase.RaceGender
		--进入恢复的过程
		if bReCover then
			local SaveCurPhase = self.LoginReConnectMgr.SaveData.CurPhase
			if SaveCurPhase then
				CurPhase = self.LoginReConnectMgr.SaveData.CurPhase
				self.MaxDonePhase = self.LoginReConnectMgr.SaveData.MaxDonePhase
				self:DoRestore()
			else
				bReCover = false
				self.LoginReConnectMgr:ExitCreateRole()
			end
		end

		if _G.LoginMapMgr:IsFantasiaAvatarPhase() then
			CurPhase = LoginRolePhase.Avatar
		end

		if _G.LoginMapMgr:IsRealLoginMap() then
			self.BeginCreateRoleTime = _G.TimeUtil.GetServerTime()
		end

		-- 捏脸界面转入自定义外貌界面
		if CurPhase == LoginRolePhase.CustomAppearance then
			CurPhase = LoginRolePhase.Avatar
		end

		-- 第一次直接再选角界面，需要提前更新数据
		if CurPhase == LoginRolePhase.Avatar then
			_G.LoginAvatarMgr:RecoverPlayerData()
		end

		self:SetCurLoginRolePhase(CurPhase, true)

		self.ForceWear = true
		local CurTime0 = _G.TimeUtil.GetServerTimeMS()
		local Rlt = -1
		
		if not self.IsInFantasia then
			Rlt = _G.LoginMapMgr:ChangeLoginMap(LoginMap)
		end

		if Rlt < 0 then
			if self.bFromLoginCreate then
				self.bFromLoginCreate = false
				_G.LoginMapMgr:PostLoadWorld(_G.LoginMapMgr.LastWorldName, _G.LoginMapMgr.CurWorldName)
			end

			if bReCover and CurPhase ~= LoginRolePhase.RaceGender then
				self:CreateRenderActor()
			end

			FLOG_INFO("Login ChangeLoginMap cost:%d", _G.TimeUtil.GetServerTimeMS() - CurTime0)
			CurTime0 = _G.TimeUtil.GetServerTimeMS()
			LoginRoleRaceGenderVM:AsyncLoadRaceIcons()
			FLOG_INFO("Login AsyncLoadRaceIcons cost:%d", _G.TimeUtil.GetServerTimeMS() - CurTime0)
			CurTime0 = _G.TimeUtil.GetServerTimeMS()

			_G.ObjectMgr:LoadObjectSync("SeAnimDataAsset'/Game/Assets/Character/Human/Animation/DataAsset/SeDataAsset/c0101a0001.c0101a0001'", 0)
			_G.ObjectMgr:LoadObjectSync("AnimMontage'/Game/Assets/Character/Action/emote/make_act.make_act'", 0)
			_G.ObjectMgr:LoadObjectSync("AnimBlueprint'/Game/BluePrint/Animation/AnimBP_LookAt.AnimBP_LookAt_C'", 2)
			_G.ObjectMgr:LoadObjectSync("AnimSequence'/Game/Assets/Character/Human/Animation/c0101/a0001/face_pose/A_c0101a0001f0003_face_pose-cfxf_pose_stunned.A_c0101a0001f0003_face_pose-cfxf_pose_stunned'", 0)
			_G.ObjectMgr:LoadObjectSync("AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/emot/timeline/base/b0001/cbem_act_emot01.cbem_act_emot01'", 0)
			_G.ObjectMgr:LoadObjectSync("AnimComposite'/Game/Assets/Character/Human/Animation/c0101/a0001/emot/timeline/base/b0001/cbem_make_act.cbem_make_act'", 0)

			FLOG_INFO("Login sync some anims cost:%d", _G.TimeUtil.GetServerTimeMS() - CurTime0)
			CurTime0 = _G.TimeUtil.GetServerTimeMS()

			self.bFirstShowRaceGenderView = true

			self:ShowPhaseView(self.CurLoginRolePhase)
			self.bFirstShowRaceGenderView = false
			FLOG_INFO("Login ShowPhaseView cost:%d", _G.TimeUtil.GetServerTimeMS() - CurTime0)
			
			if self.FixPageView and self.FixPageView.MorePage then
				self.FixPageView.MorePage:ResetIsGaze(self.IsGaze)
			end

			self:ReportLoginCreateData(self.CurLoginRolePhase)
			-- self:PreLoadOnCreate()
		-- else 成功切图的话，会在切图完成后再显示选角相关ui
		end

		self:ResetRenderActorCamera(false)
		_G.LoginUIMgr:SetFeedbackAnimType(5)
		--_G.UE.UTimerMgr:Get():StartHeartBeat()
	end
end

function LoginUIMgr:PreLoadOnCreate()
	local CacheType = _G.UE.EObjectGC.NoCache
	local CurTime = _G.TimeUtil.GetServerTimeMS()
	_G.LoginMapMgr:PreLoadRenderActors(CacheType)
	FLOG_INFO("Login Preload PreLoadRenderActors cost:%d", _G.TimeUtil.GetServerTimeMS() - CurTime)

	--对LoginConfig.PreloadPaths中的资源路径进行去重，减少异步加载的请求数量
	local seen = {}
	local result = {}
	for _, value in ipairs(LoginConfig.PreloadPaths) do
		if not seen[value] then
			seen[value] = true
			table.insert(result, value)
		end
	end
	local PathsNum = #result
	FLOG_INFO("Login Preload paths Num:%d", PathsNum)
	local CurTickCount = 1
	local CurIndex = 1
	local TickCount = 10
	local function DelayPreLoad()
		local Num = math.floor(PathsNum / TickCount)
		if CurTickCount == TickCount then
			Num = PathsNum - CurIndex
		end
		FLOG_INFO("Login Preload paths Num:%d CurIndex:%d", Num, CurIndex)
		CurTime = _G.TimeUtil.GetServerTimeMS()

		for index = CurIndex, CurIndex + Num do
			_G.ObjectMgr:LoadObjectAsync(result[index], nil, CacheType)
		end

		CurIndex = CurIndex + Num
		FLOG_INFO("Login Preload paths end Cost:%d", _G.TimeUtil.GetServerTimeMS() - CurTime)
	end

	_G.TimerMgr:AddTimer(nil, DelayPreLoad, 2, 0.2, TickCount)
end

--隐藏创建角色界面（可能在任何一个阶段，所以这里要保证所有相关view的hide）
function LoginUIMgr:HideCreateRoleView()
	if _G.IsNewLoginVersion then
		-- UIViewMgr:HideView(UIViewID.LoginCreateRaceGender)
		self:HidePhaseView(self.CurLoginRolePhase)
		UIViewMgr:HideView(self.RoleRender2DViewID)
		UIViewMgr:HideView(UIViewID.LoginFixPage)
	end
end

function LoginUIMgr:HideMakeNameView()
	_G.LoginUIMgr:HidePhaseView(LoginRolePhase.SetName)
	UIViewMgr:HideView(UIViewID.LoginFixPage)
end

function LoginUIMgr:ShowSelectRoleView(bFromLogin)
	self.IsCreateRole = false

	local bLoginScene = _G.WorldMsgMgr:IsLogin()
	if not bLoginScene then
		FLOG_INFO("Login bLoginScene = false")
		return
	end
	
	_G.LoginUIMgr:SetFeedbackAnimType(0)

	self:SetCurLoginRolePhase(LoginRolePhase.SelectRole)
	self.MaxDonePhase = LoginRolePhase.SelectRole
	self.IsFixPageClickBtnMore = false

	local RoleSimpleList = _G.LoginMgr.tbRoleSimple
	if RoleSimpleList then
		for index = 1, #RoleSimpleList do
			local RoleSimple = RoleSimpleList[index]
			local RoleCfg = LoginRoleRaceGenderVM:GetRoleCfgByRoleSimple(RoleSimple)
			if RoleCfg then
				local AttachType = RoleCfg.AttachType
				local RenderActorPathForRace = string.format(LoginConfig.RenderActorPath, AttachType, AttachType)
				_G.ObjectMgr:LoadObjectSync(RenderActorPathForRace, 0)
			end
		end
    end

	local LoginMapMgr = _G.LoginMapMgr
	local Rlt = LoginMapMgr:ChangeLoginMap(LoginConfig.SelectRoleMap)
	if Rlt < 0 then
		if bFromLogin then
			LoginMapMgr:PostLoadWorld(LoginMapMgr.LastWorldName, LoginMapMgr.CurWorldName)
		end

		UIViewMgr:ShowView(self.RoleRender2DViewID)
		--LoginRoleRender2D要先，否则self.Render2DView是nil
		UIViewMgr:ShowView(UIViewID.LoginSelectRoleNew)
	-- else 成功切图的话，会在切图完成后再显示选角相关ui
	end
end

function LoginUIMgr:ShowSelectRoleModel()
	local Cfg = LoginRoleMainPanelVM.CurSelectRoleCfg
	if nil ~= Cfg then
		local AttachType = Cfg.AttachType

		if not self.Render2DView then
			FLOG_ERROR("LoginUIMgr:ShowSelectRoleView Render2DView is nil")
			return
		end

		if self.Common_Render2D_UIBP then
			self.Common_Render2D_UIBP:ReleaseActor()
		end

		--内部资源异步加载后，再SetUICharacterByRaceCfg创建角色actor
		self.Render2DView:CreateRenderActor(AttachType, Cfg)
		self.Common_Render2D_UIBP:CreateActor()

		self:SetUICharacterByRaceCfg(Cfg, true)
		-- self:SetEquipByRoleSimple()

		local UIComplexCharacter = self.Common_Render2D_UIBP.UIComplexCharacter
		local RoleSimple = LoginRoleMainPanelVM:GetSelectRoleSimple()
		if RoleSimple and UIComplexCharacter then
			ActorUtil.UpdateAvatar(UIComplexCharacter, RoleSimple)
			-- ActorUtil.SetCustomizeAvatarFace(UIComplexCharacter, RoleSimple.Avatar.Face)
		end
	else
		FLOG_ERROR("LoginUIMgr:ShowSelectRoleView Cfg is nil")
	end
end

function LoginUIMgr:SetEquipByRoleSimple()
	if self.CurProfSuitCfg then
		return
	end

	-- 理发屋角色装备初始化
	-- if _G.LoginMapMgr:GetCurLoginMapType() == _G.LoginMapType.HairCut then
	-- 	self:SetSuitInHaircut()
	-- 	return
	-- end

	if not _G.LoginMapMgr:IsRealLoginMap() then
		return
	end

	if self.CurLoginRolePhase ~= LoginRolePhase.SelectRole then
		return
	end

	local RoleSimple = LoginRoleMainPanelVM:GetSelectRoleSimple()
	local UIComplexCharacter = self:GetUIComplexCharacter()
	if RoleSimple and UIComplexCharacter then
		self:TakeOffWearSuit(UIComplexCharacter)

		local EquipList = RoleSimple.Avatar.EquipList
		for idx = 1, #EquipList do
			local Equip = EquipList[idx]
			--[sammrli] 投影和染色
			local EquipID = WardrobeUtil.GetEquipID(Equip.EquipID, Equip.ResID, Equip.RandomID)
			UIComplexCharacter:HandleAvatarEquipNoLoad(EquipID, Equip.Part, Equip.ColorID)
		end

		UIComplexCharacter:StartLoadAvatar()
	else
		FLOG_WARNING("LoginUIMgr:SetEquipByRoleSimple failed")
	end
end

-- 理发屋角色当前装备
function LoginUIMgr:SetSuitInHaircut(SuitCfg)
	if not SuitCfg then
		return
	end
	
	-- local RoleSimple = LoginRoleMainPanelVM:GetSelectRoleSimple()
	-- local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if not self.ForceWear and
		self.RoleWearSuitCfg and SuitCfg.ID == self.RoleWearSuitCfg.ID then
		--FLOG_WARNING("LoginUIMgr:WearSuit Wear Same Suit")
		return
	end
	local MajorRoleDetail = MajorUtil.GetMajorRoleDetail()
	local UIComplexCharacter = self:GetUIComplexCharacter()
	if MajorRoleDetail and UIComplexCharacter then
		self:TakeOffWearSuit(UIComplexCharacter)

		-- shuangteng: 使用EquipAvatar的外观ID和染色
		local EquipList = MajorRoleDetail.Simple.Avatar.EquipList
		local HairCutMajorEquipList = {}
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		local RegionDyesInfo = ActorUtil.GetActorRegionDyesInfo(MajorEntityID)
		for idx = 1, #EquipList do
			---@type EquipAvatar
			local Equip = EquipList[idx]
			local EquipID = WardrobeUtil.GetEquipID(Equip.EquipID, Equip.ResID, Equip.RandomID)
			if SuitCfg then
				table.insert(HairCutMajorEquipList, EquipID)
			end

			UIComplexCharacter:HandleAvatarEquipNoLoad(EquipID, Equip.Part, Equip.ColorID)
			ActorUtil.UpdateEquipRegionDyes(UIComplexCharacter, Equip.Part, RegionDyesInfo)
		end

		self.CurrentSuitType = SuitCfg.SuitType
		self.HairCutMajorEquipList = HairCutMajorEquipList

		UIComplexCharacter:StartLoadAvatar()
		-- if SuitCfg == nil then

		-- else
		   self.RoleWearSuitCfg = SuitCfg
		-- end
	else
		FLOG_WARNING("LoginUIMgr:SetEquipByRoleSimple failed")
	end
end

function LoginUIMgr:HideSelectRoleView()
	if _G.IsNewLoginVersion then
		_G.UIViewMgr:HideView(UIViewID.LoginSelectRoleNew)
		UIViewMgr:HideView(self.RoleRender2DViewID)
	end
end

function LoginUIMgr:SetCurPhaseOpacity(Opacity)
	local PhaseConfig = CreateRoleConfig[self.CurLoginRolePhase]
	if PhaseConfig then
		for index = 1, #PhaseConfig.Views do
			local View = UIViewMgr:FindVisibleView(PhaseConfig.Views[index])
			if nil ~= View then
				UIUtil.SetRenderOpacity(View, Opacity)
			end
		end

		local FixView = UIViewMgr:FindVisibleView(UIViewID.LoginFixPage)
		if FixView then
			UIUtil.SetRenderOpacity(FixView, Opacity)
			if Opacity < 1 then
				UIUtil.SetRenderOpacity(FixView.BtnBack, 0.3)
				UIUtil.SetRenderOpacity(FixView.BtnClose, 0.5)
			else
				UIUtil.SetRenderOpacity(FixView.BtnBack, 1)
				UIUtil.SetRenderOpacity(FixView.BtnClose, 1)
			end
		end
	end
end

function LoginUIMgr:HideRoleRender2DView()
	UIViewMgr:HideView(self.RoleRender2DViewID)
end

function LoginUIMgr:ReleaseRenderActor()
	if self.Common_Render2D_UIBP then
		self.Common_Render2D_UIBP:ReleaseActor()
	end
end

--创建场景模型actor
function LoginUIMgr:CreateRenderActor(bReadAvatarRecord)
	FLOG_INFO("LoginUIMgr:CreateRenderActor()")
	if self.Common_Render2D_UIBP then
		self.ForceWear = true
		self.Common_Render2D_UIBP:ReleaseActor()
	end
		
	-- self.IsAlreadySwitchCamera = false

	if not UIViewMgr:IsViewVisible(self.RoleRender2DViewID) then
		UIViewMgr:ShowView(self.RoleRender2DViewID)
	end
	
	local Cfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if nil ~= Cfg and self.Render2DView then
		local AttachType = Cfg.AttachType

		self.Render2DView:Reset()
		--内部资源异步加载后，再SetUICharacterByRaceCfg创建角色actor
		self.Render2DView:CreateRenderActor(AttachType, Cfg, bReadAvatarRecord)
	end
end

--给捏脸使用的，重置RenderActor和各个阶段数据的接口
function LoginUIMgr:ChangeRenderActor(RaceID, TribeID, Gender, bReadAvatarRecord)
	LoginRoleRaceGenderVM:ChangeRenderActor(RaceID, TribeID, Gender, bReadAvatarRecord)
	LoginRoleTribePageVM:ChangeRenderActor(RaceID, TribeID, Gender)

	self:CreateRenderActor(bReadAvatarRecord)
	if LoginRoleProfVM.CurrentProf and self.CurLoginRolePhase == LoginRolePhase.Prof then
		local ProfID = LoginRoleProfVM.CurrentProf.Prof
		self:SetProfEquips(ProfID)
	end
end

--释放角色actor，并按新种族、性别、部队进行创建新的角色actor
function LoginUIMgr:ChangeGender()
	if not self.Common_Render2D_UIBP or not self.Common_Render2D_UIBP.RenderActor then
		return
	end

	self:CreateRenderActor()
	-- self.Render2DView:SetModelSpringArmToDefault(true)
	-- self.Common_Render2D_UIBP:CreateActor()
	-- self:SetUICharacterByRaceCfg(LoginRoleRaceGenderVM.CurrentRaceCfg)
	-- self:UpdateRoleFacePreset()
	-- self.Common_Render2D_UIBP:ReCreateCharacter(LoginRoleRaceGenderVM.CurrentRaceCfg)
end

function LoginUIMgr:UpdateRoleFacePreset(bReadAvatarRecord)
	if not self.Common_Render2D_UIBP or not self.Common_Render2D_UIBP.UIComplexCharacter then
		return
	end

	local UIComplexCharacter = self.Common_Render2D_UIBP.UIComplexCharacter
	-- 理发屋无CurLoginRolePhase，初始化使用RoleSimple，否则使用自定义数据
	local PWorldInfo = _G.PWorldMgr:GetCurrPWorldTableCfg()
	local bCustomzieHaircut = PWorldInfo and PWorldInfo.MainPanelUIType == _G.LoginMapType.HairCut
	local CurAvatarFace = _G.LoginAvatarMgr:GetCurAvatarFace()
	if bCustomzieHaircut and (CurAvatarFace == nil or #CurAvatarFace == 0) then
		bCustomzieHaircut = false
	end

	if self.CurLoginRolePhase ~= LoginRolePhase.SelectRole or bCustomzieHaircut then
		local AttrComp = UIComplexCharacter:GetAttributeComponent()
		if AttrComp then
			-- _G.LoginAvatarMgr:SetAllAvatarCustomize()
			_G.LoginAvatarMgr:UpdateRoleFacePreset(AttrComp.TribeID, AttrComp.Gender, nil, nil, bReadAvatarRecord)
		end
	else
		local RoleSimple = LoginRoleMainPanelVM:GetSelectRoleSimple()
		if RoleSimple and UIComplexCharacter then
			if bReadAvatarRecord then
				RoleSimple.Avatar.Face = _G.LoginAvatarMgr:RecoverAvatarFace()
			end
			ActorUtil.SetCustomizeAvatarFace(UIComplexCharacter, RoleSimple.Avatar.Face)
		end
	end
end

function LoginUIMgr:ClearRoleSuitTryOn()
	LoginRoleShowPageVM.CurrentSuitIndex = 0
end

function LoginUIMgr:ClearRoleWearSuit()
	self.RoleWearSuitCfg = nil
end

--角色模型展示
--第一次显示模型、更换性别都会走到这里来
function LoginUIMgr:SetUICharacterByRaceCfg(RaceCfg, PassWearSuit)
    if (RaceCfg == nil or self.Common_Render2D_UIBP == nil) then
        FLOG_ERROR("Login SetUICharacterByRaceCfg is nil")
        return
    end

	local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
	if not ChildActor then
        FLOG_ERROR("Login SetUICharacterByRaceCfg ChildActor is nil")
		return
	end

	local UIComplexCharacter = ChildActor:Cast(_G.UE.AUIComplexCharacter)
    self.Common_Render2D_UIBP.UIComplexCharacter = UIComplexCharacter
    if (UIComplexCharacter == nil) then
        FLOG_ERROR("Login SetUICharacterByRaceCfg UIComplexCharacter is nil")
        return
    end

	self.HairCutMajorEquipList = nil
    --后续todo
	-- AttributeCom->ProfID = CopyAttrComp->ProfID;
	-- AttributeCom->Level = CopyAttrComp->Level;
    local AttributeComp = UIComplexCharacter:GetAttributeComponent()
    if not AttributeComp then
        return
    end

    AttributeComp.ObjType = _G.UE.EActorType.UIActor
    AttributeComp.EntityID = 0
    AttributeComp.Gender = RaceCfg.Gender
    AttributeComp.RaceID = RaceCfg.RaceID
	local TribeID = LoginRoleRaceGenderVM:GetTribeID()
	if TribeID > 0 then
		AttributeComp.TribeID = TribeID
	else
		AttributeComp.TribeID = RaceCfg.Tribe
	end

    FLOG_INFO("Login SetUICharacterByRaceCfg : %s TribeID:%d, Gender:%d"
        , RaceCfg.RaceName, TribeID, RaceCfg.Gender)

	self.Common_Render2D_UIBP:SetUICharacterAfterAttrSet()
	-- self.Common_Render2D_UIBP:PlayAnyAsMontage(RaceCfg.EnterAnim, "WholeBody", nil, nil, "")

	if not PassWearSuit then
		if _G.LoginMapMgr.bFirstEnterHairCutMap then
			local UnderCloseCfg = LoginRoleShowPageVM:GetUnderClothe(RaceCfg.RaceID, RaceCfg.Gender)
			if UnderCloseCfg then
				self:WearSuit(UnderCloseCfg)
				return
			end
		end
		-- 第一次进幻想药，显示裸模
		if self.IsInFantasia and self.bFirstShowUnderCloth then
			self.bFirstShowUnderCloth = false
			local UnderCloseCfg = LoginRoleShowPageVM:GetUnderClothe(RaceCfg.RaceID, RaceCfg.Gender)
			if UnderCloseCfg then
				self:WearSuit(UnderCloseCfg)
				return
			end
		end

		local SuitCfg = LoginRoleShowPageVM:GetSuitByType(RaceCfg.RaceID, RaceCfg.Gender, self.CurrentSuitType)
		if SuitCfg then
			self:WearSuit(SuitCfg)
			return
		end

		if self.CurProfSuitCfg and self.CurLoginRolePhase == LoginRolePhase.Prof then
			self:WearSuit(self.CurProfSuitCfg)
		elseif self.RoleWearSuitCfg then
			self:WearSuit(self.RoleWearSuitCfg)
		else
			self:SetRaceBornEquips(RaceCfg)
		end
	end
end

function LoginUIMgr:SetRaceBornEquips(RaceCfg)
	if not RaceCfg then
		return
	end

	local UIComplexCharacter = self:GetUIComplexCharacter()

	local RaceSuitCfgList = LoginRoleShowPageVM:GetAllRaceSuit()
	if RaceSuitCfgList then
        for index = 1, #RaceSuitCfgList do
			local SuitCfg = RaceSuitCfgList[index]
			if SuitCfg.IsDefault == 1 and SuitCfg.RaceID == RaceCfg.RaceID
				and SuitCfg.Gender == RaceCfg.Gender then
				FLOG_INFO("LoginUIMgr:Setdefault Race Equips")
				self:WearSuit(SuitCfg, true)
				break
			end
        end
	end
end

function LoginUIMgr:GetUIComplexCharacter()
	if not self.Common_Render2D_UIBP then
		return nil
	end

	return self.Common_Render2D_UIBP.UIComplexCharacter
end

function LoginUIMgr:GetCommonRender2DView()
	return self.Common_Render2D_UIBP
end

function LoginUIMgr:RecordProfSuit(SuitCfg)
	self.CurProfSuitCfg = SuitCfg
end

function LoginUIMgr:SetProfEquips(ProfID)
	local RaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if not RaceCfg then
		return
	end

	local UIComplexCharacter = self:GetUIComplexCharacter()

	FLOG_INFO("LoginUIMgr:SetProfEquips Prof:%d", ProfID)

	if #self.ProfSuitList == 0 then
		local SuitList = EquipmentProfSuitCfg:FindAllCfg()
		if SuitList then
			for index = 1, #SuitList do
				table.insert(self.ProfSuitList, SuitList[index])
			end
		end
	end

	if #self.ProfSuitList > 0 then
		for index = 1, #self.ProfSuitList do
			local SuitCfg = self.ProfSuitList[index]
			if ProfID == SuitCfg.Prof and SuitCfg.IsDefault == 1 then
				--默认职业装
				self.RecordProfSuitCfg = SuitCfg
				self:WearSuit(SuitCfg)
				self:RecordProfSuit(SuitCfg)
				break
			end
		end

	end
end

-- PlayType 1：试穿  2：点击职业按钮 3：切换种族 4：切图点头 5:刚进入创角 6:点头
function LoginUIMgr:PlayFeedbackAnim(PlayType)
	local RaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if not RaceCfg then
		return
	end

	if #self.FeedbackAnimList == 0 then
		local AnimList = LoginFeedbackAnimCfg:FindAllCfg()
		if AnimList then
			for index = 1, #AnimList do
				table.insert(self.FeedbackAnimList, AnimList[index])
			end
		end
	end

	if #self.FeedbackAnimList > 0 then
		for index = 1, #self.FeedbackAnimList do
			local AnimCfg = self.FeedbackAnimList[index]
			if RaceCfg.RaceID == AnimCfg.RaceID and AnimCfg.Tribe == RaceCfg.Tribe
				and AnimCfg.Gender == RaceCfg.Gender then
					if self.FeedbackAnimType == 1 then
						self:PlayEmotionAnim(AnimCfg.TryOnAnim)
					elseif self.FeedbackAnimType == 2 then
						self:PlayEmotionAnim(AnimCfg.ProfAnim)
					elseif self.FeedbackAnimType == 3 then
						self:PlayEmotionAnim(AnimCfg.RaceAnim)
					elseif self.FeedbackAnimType == 4 then
						self:PlayEmotionAnim(AnimCfg.ChangeMapAnim)
						-- self:PlaySwitchAnim(nil, true)
					elseif self.FeedbackAnimType == 5 then
						self:PlayEmotionAnim(AnimCfg.EnterCreateRoleAnim)
					elseif self.FeedbackAnimType == 6 then
						self:PlayEmotionAnim(RaceCfg.EnterAnimID)
					end
				break
			end
		end

	end
end

function LoginUIMgr:TakeOffWearSuit(UIComplexCharacter)
	if UIComplexCharacter then
		if self.RoleWearSuitCfg then
			local EquipList = self.RoleWearSuitCfg.EquipList
			if #EquipList == 0 then
				if self.HairCutMajorEquipList then
					EquipList = self.HairCutMajorEquipList
				end
			end

			-- UIComplexCharacter:TakeOffAllAvatarPart(false)
			-- UIComplexCharacter:GetAvatarComponent():UpdateDefaultBody()
			for idx = 1, #EquipList do
				local EquipID = EquipList[idx]
				local EquipCfg = EquipmentCfg:FindCfgByEquipID(EquipID)
				if EquipCfg then
					-- FLOG_INFO("LoginUIMgr TakeOff Equip:%d part:%d", EquipID, EquipCfg.EquipmentType)
					UIComplexCharacter:TakeOffAvatarEquip(EquipCfg.EquipmentType, false)
				end
			end

			self.HairCutMajorEquipList = nil
			UIComplexCharacter:TakeOffAvatarEquip(EquipmentType.WEAPON_MASTER_HAND, false)
			UIComplexCharacter:TakeOffAvatarEquip(EquipmentType.WEAPON_SLAVE_HAND, false)
		end
	end
end

--试穿
function LoginUIMgr:WearSuit(SuitCfg, bUseProfCfgWeapon)
	local UIComplexCharacter = self:GetUIComplexCharacter()
	if not SuitCfg or not UIComplexCharacter then
		FLOG_WARNING("LoginUIMgr:WearSuit nil")
		return
	end

	if not self.ForceWear and
		self.RoleWearSuitCfg and SuitCfg.ID == self.RoleWearSuitCfg.ID then
		FLOG_WARNING("LoginUIMgr:WearSuit Wear Same Suit")
		return
	end

	self.CurrentSuitType = SuitCfg.SuitType

	FLOG_INFO("LoginUIMgr:WearSuit SuitID:%d", SuitCfg.ID)
	self:TakeOffWearSuit(UIComplexCharacter)

	if not SuitCfg.EquipList then
		FLOG_ERROR("LoginUIMgr:WearSuit EquipList is nil")
		return
	end

	if #SuitCfg.EquipList == 0 then
		self:SetSuitInHaircut(SuitCfg)

		self.RoleWearSuitCfg = SuitCfg
		self.ForceWear = false
	
		return
	end

	self.ForceWear = false
	self.RoleWearSuitCfg = SuitCfg

	for idx = 1, #SuitCfg.EquipList do
		local EquipID = SuitCfg.EquipList[idx]
		-- if EquipID == 59999001 then
		-- 	EquipID = 50010543
		-- end
		local EquipCfg = EquipmentCfg:FindCfgByEquipID(EquipID)
		if EquipCfg then
			-- FLOG_INFO("LoginUIMgr:WearSuit HandleAvatarEquipNoLoad:%d part:%d", EquipID, EquipCfg.Part)
			UIComplexCharacter:HandleAvatarEquipNoLoad(EquipID, EquipCfg.Part)
		end
	end

	if self.CurrentSuitType ~= ProtoRes.suit_type.SUIT_TYPE_PROF then
		if _G.LoginMapMgr:GetCurLoginMapType() == _G.LoginMapType.Login
			and (self.CurLoginRolePhase ~= LoginRolePhase.Prof or self.IsShowPreviewPage or bUseProfCfgWeapon)
			and self.RecordProfSuitCfg then
				local EquipID = self.RecordProfSuitCfg.MasterdWeapon
				local EquipCfg = EquipmentCfg:FindCfgByEquipID(EquipID)
				if EquipCfg then
					UIComplexCharacter:HandleAvatarEquipNoLoad(EquipID, EquipCfg.Part)
				end
	
				EquipID = self.RecordProfSuitCfg.SlaveWeapon
				EquipCfg = EquipmentCfg:FindCfgByEquipID(EquipID)
				if EquipCfg then
					UIComplexCharacter:HandleAvatarEquipNoLoad(EquipID, EquipCfg.Part)
				end
		end
	end

	UIComplexCharacter:StartLoadAvatar()
end

function LoginUIMgr:ChangeTribe(NewTribeID)
    if (self.Common_Render2D_UIBP == nil) then
        FLOG_ERROR("Login ChangeTribe is nil")
        return
    end

	-- self:ClearRoleWearSuit()
	self.ForceWear = true
	self:CreateRenderActor()

	-- self:UpdateRoleFacePreset()
	-- local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
	-- if not ChildActor then
    --     FLOG_ERROR("Login ChangeTribe ChildActor is nil")
	-- 	return
	-- end

	-- local UIComplexCharacter = ChildActor:Cast(_G.UE.AUIComplexCharacter)
    -- self.Common_Render2D_UIBP.UIComplexCharacter = UIComplexCharacter
    -- if (UIComplexCharacter == nil) then
    --     FLOG_ERROR("Login ChangeTribe UIComplexCharacter is nil")
    --     return
    -- end

    -- local AttributeComp = UIComplexCharacter:GetAttributeComponent()
    -- if not AttributeComp then
    --     return
    -- end

    -- AttributeComp.TribeID = NewTribeID
	-- self.Common_Render2D_UIBP:SetUICharacterAfterAttrSet()
	-- self:WearSuit(self.RoleWearSuitCfg)
	-- -- self.Common_Render2D_UIBP:PlayAnyAsMontage(RaceCfg.EnterAnim, "WholeBody", nil, nil, "")
end

--常驻功能
--试穿 --todel
function LoginUIMgr:OnSuitTryOn()
	UIViewMgr:HideView(UIViewID.LoginFixPage)
	self:HidePhaseView(self.CurLoginRolePhase)
	UIViewMgr:ShowView(_G.LoginMapMgr:GetPreViewPageID())
end

--打开预览界面
function LoginUIMgr:OnShowPreviewPage()
	_G.LoginAvatarMgr:ModelMoveToLeft(false, false)
	local FocusParam = {FocusType = CameraControlDefine.FocusType.WholeBody, bIgnoreAssember = false}
	_G.EventMgr:SendEvent(EventID.LoginCreateCameraChange, FocusParam)

	local PreviewPageID = _G.LoginMapMgr:GetPreViewPageID()
	if not self.IsCreateRole then	--从选角界面打开预览界面
		_G.UIViewMgr:HideView(UIViewID.LoginSelectRoleNew)
		UIViewMgr:ShowView(PreviewPageID)

		self.IsShowPreviewPage = true
		_G.UE.USaveMgr.SetInt(SaveKey.ShowPreviewPage, 1, true)
		return
	end

	self.IsShowPreviewing = true
	UIViewMgr:HideView(UIViewID.LoginFixPage)
	self:HidePhaseView(self.CurLoginRolePhase)
	UIViewMgr:ShowView(PreviewPageID)
	self.IsShowPreviewing = false

	self.IsShowPreviewPage = true
	_G.UE.USaveMgr.SetInt(SaveKey.ShowPreviewPage, 1, true)
end

--从试穿、动作界面返回到当前的phase
function LoginUIMgr:ReturnCurPhaseView(IsMapLoaded)--, bSameMap)
	local RaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if RaceCfg then
		self:PlayEmotionAnim(RaceCfg.EnterAnimID)
	end

	local CurLoginMapType = _G.LoginMapMgr:GetCurLoginMapType()
	--幻想药返回当前Phase
	if CurLoginMapType == _G.LoginMapType.Fantasia then
		self.IsShowPreviewPage = false
		_G.UE.USaveMgr.SetInt(SaveKey.ShowPreviewPage, 0, true)
		
		-- if bSameMap ~= nil and bSameMap or bSameMap == nil then
			self:ShowPhaseView(self.CurLoginRolePhase)
			UIViewMgr:ShowView(UIViewID.LoginFixPage)
		-- end

		return
	end

	if not _G.LoginMapMgr:IsRealLoginMap() then
		--创角演示场景
		self.IsShowPreviewPage = false
		_G.UE.USaveMgr.SetInt(SaveKey.ShowPreviewPage, 0, true)
		_G.LoginMapMgr:ShowLoginMapMainUI()
		return
	end

	if IsMapLoaded and self.IsShowPreviewPage then
		UIViewMgr:ShowView(self.RoleRender2DViewID)
		UIViewMgr:ShowView(_G.LoginMapMgr:GetPreViewPageID())
		return
	end

	if not self.IsCreateRole then	--从预览界面返回到选角界面
		--选角界面屏蔽了预览界面的入口，所以这里不需要了
		-- self.IsShowPreviewPage = false
		-- _G.UE.USaveMgr.SetInt(SaveKey.ShowPreviewPage, 0, true)
		if _G.LoginMgr:HasRoleCount() > 0 then
			self:ShowSelectRoleView()
		else
			self:DoShowCreateRoleView()
		end
		
		return
	end

	self.IsShowPreviewPage = false
	_G.UE.USaveMgr.SetInt(SaveKey.ShowPreviewPage, 0, true)
	
	-- if bSameMap ~= nil and bSameMap or bSameMap == nil then
		self:ShowPhaseView(self.CurLoginRolePhase)
		UIViewMgr:ShowView(UIViewID.LoginFixPage)
	-- end
end

--环境 也先HideView(UIViewID.LoginFixPage)

--隐藏UI
function LoginUIMgr:OnHideUI(IsHide)
	self.IsHideUI = IsHide
	if IsHide then
		self:HidePhaseView(self.CurLoginRolePhase)
		if self.FixPageView then
			UIUtil.SetIsVisible(self.FixPageView.BtnBack, false)
			UIUtil.SetIsVisible(self.FixPageView.BtnStart, false)
			-- UIUtil.SetIsVisible(self.FixPageView.BtnStartDisableImg, false)
			UIUtil.SetIsVisible(self.FixPageView.TextStart, false)
			UIUtil.SetIsVisible(self.FixPageView.BtnClose, false)
			UIUtil.SetIsVisible(self.FixPageView.ProgressPage, false)
			-- UIUtil.SetIsVisible(self.FixPageView.ButtonDownloadPak, false)
		end
	else
		if self.FixPageView then
			UIUtil.SetIsVisible(self.FixPageView.BtnBack, true)
			self:SetNextBtnVisible(true)
			-- UIUtil.SetIsVisible(self.FixPageView.BtnStart, true, true)
			-- UIUtil.SetIsVisible(self.FixPageView.TextStart, true)
			UIUtil.SetIsVisible(self.FixPageView.BtnClose, true, true)
			UIUtil.SetIsVisible(self.FixPageView.ProgressPage, true)
			if not self.IsInFantasia then				
				-- UIUtil.SetIsVisible(self.FixPageView.ButtonDownloadPak, true)
			end
		end
		
		self:ShowPhaseView(self.CurLoginRolePhase)

		if self.CurLoginRolePhase == LoginRolePhase.Prof then
			local View = UIViewMgr:FindVisibleView(UIViewID.LoginRoleProf)
			if View and View.RefreshNextBtn then
				View:RefreshNextBtn()
			end
		end
	end
end

--灵1月1日
function LoginUIMgr:GetBirthdayStr(Month, Day)
	return LoginRoleBirthdayVM:GetBirthdayStr(Month, Day)
end

function LoginUIMgr:GetRealBirthdayStr(Month, Day)
	return LoginRoleBirthdayVM:GetRealBirthdayStr(Month, Day)
end

function LoginUIMgr:SetSubTitle(SubTitle)
	if not self.FixPageView then
		FLOG_WARNING("LoginUIMgr:SetSubTitle FixPageView is nil")
		return
	end

	local SubTitleText = self.FixPageView.BtnBack.TextSubtile
	if not SubTitleText then
		return
	end

	if not SubTitle or string.len(SubTitle) == 0 then
		UIUtil.SetIsVisible(SubTitleText, false)
		return
	end

	UIUtil.SetIsVisible(SubTitleText, true)
	SubTitleText:SetText(SubTitle)
end

function LoginUIMgr:OnMakeNameCheckRsp(bError)
	local bUIShow = UIViewMgr:IsViewVisible(UIViewID.LoginCreateMakeName)
	FLOG_INFO("LoginUIMgr OnMakeNameCheckRsp(%s) LoginCreateMakeName bUIShow:%s", tostring(bError), tostring(bUIShow))
	-- if self.CurLoginRolePhase == LoginRolePhase.SetName then
	local AttrCmp = MajorUtil.GetMajorAttributeComponent()
	if AttrCmp then
		AttrCmp.ActorName = LoginRoleSetNameVM.RoleName
	end

	if bUIShow then
		LoginRoleSetNameVM:OnMakeNameCheckRsp(bError)
	end
end

function LoginUIMgr:SetMakeNameBtnEnable(bEnable)
	local bUIShow = UIViewMgr:IsViewVisible(UIViewID.LoginCreateMakeName)
	if bUIShow then
		LoginRoleSetNameVM:SetMakeNameBtnEnable(bEnable)
	end
end

function LoginUIMgr:ResetLightPreset(LightPresetPath)
	if self.Common_Render2D_UIBP then
		self.Common_Render2D_UIBP:ResetLightPreset(LightPresetPath)
	end
end

function LoginUIMgr:OnUIComplexCharacterLoaded(UIComplexCharacter)
	if UIComplexCharacter and self.bFirstCreate then
		self.bFirstCreate = false
		ActorUtil.SetUILookAt(UIComplexCharacter, self.IsGaze, _G.UE.ELookAtType.ALL)
		UIComplexCharacter:StartFadeIn(0.5, true)
	end
end

function LoginUIMgr:ResetHairBtnState()
	-- 重置束发按钮状态
	if self.FixPageView and self.FixPageView.MorePage then
		self.FixPageView.MorePage:ResetHairBtn()
	end
end

function LoginUIMgr:ResetMorePageBtnState()
	-- 重置按钮状态
	if self.FixPageView and self.FixPageView.MorePage then
		--隐藏UI的情况下，更新按钮状态
		if _G.LoginUIMgr.IsHideUI then
			self.FixPageView.MorePage.IsHideUI = _G.LoginUIMgr.IsHideUI
			self.FixPageView.MorePage:OnToggleBtnHideUI()
		end
	end
end

function LoginUIMgr:SetRenderActorCreated(IsCreated)
	self.RenderActorCreated = IsCreated

	if IsCreated then
		--这个时候RenderActor的资源已经异步加载过，并且创建了角色模型
		--而且已经组装完毕
		--所以不需要太等了
		_G.WorldMsgMgr:DelayHideLoadingView(0.1)
		--self.RenderActorCreated = false
	end
end

--在loading阶段，同步加载
--也需要在CreateRenderActor之前，待到角色创建完成后的Common_Render2D_UIBP:ChangeUIState使用
function LoginUIMgr:CreateCameraActor()
	FLOG_INFO("Login CreateCameraActor")
	-- self:ReleaseCameraActor()

	local CameraActorPath = LoginConfig.CameraActorPath
	local CameraClass = _G.ObjectMgr:LoadClassSync(CameraActorPath)
	if (CameraClass) then
		local Pos = _G.UE.FRotator(0, 0, 0)
		self.CameraActor = _G.CommonUtil.SpawnActor(CameraClass, Pos)
		if self.CameraActor then
			self.CameraActorRef = UnLua.Ref(self.CameraActor)
			self:ResetCreateCamersParams()
		end
	end
end

function LoginUIMgr:ReSwitchCamera()
	local Camera = self.CameraActor
	if Camera then
		local CameraMgr = _G.UE.UCameraMgr.Get()
		if CameraMgr then
			CameraMgr:SwitchCamera(Camera, 0)
		end
	end
end

function LoginUIMgr:ResetCreateCamersParams()
	if self.CameraActor then
		local ActorComponent = self.CameraActor:GetComponentByClass(_G.UE.USpringArmComponent)
		if ActorComponent then
			local SpringArmComponent = ActorComponent:Cast(_G.UE.USpringArmComponent)
			if SpringArmComponent then
				SpringArmComponent.TargetArmLength = 370
				local Location = _G.UE.FVector(0, 0, 89)
				SpringArmComponent:K2_SetRelativeLocation(Location, false, nil, false);
				-- (Pitch=-5,Yaw=-180,Roll=0) 
				SpringArmComponent:K2_SetRelativeRotation(_G.UE.FRotator(-5, -180, 0), false, nil, false)
			end
		end

		local CameraMgr = _G.UE.UCameraMgr.Get()
		if CameraMgr then
			CameraMgr:SetCurrentPlayerManagerLockedFOV(60)
			CameraMgr:SwitchCamera(self.CameraActor, 0)
		end
	end
end

--选角、创角阶段  点按钮恢复最初的状态，包括角色actor的旋转归位
function LoginUIMgr:ResetRenderActorCamera(bInterp)
	if self.Render2DView then
		self.Render2DView:ResetCamera(bInterp)
	end
	
	if self.Common_Render2D_UIBP then
		local Velocity = self.Common_Render2D_UIBP:GetZoomInterpVelocity() or 8
		self.Common_Render2D_UIBP:SetSpringArmRotation(-5, -180, 0, bInterp, Velocity)
		self.Common_Render2D_UIBP:SetModelRotation(0, 0, 0, bInterp)
	end
end

--比如理发屋断线，没离开场景，得手动ReleaseCameraActor  不放在Create内部线Release,没必要的开销
function LoginUIMgr:OnGameEventPWorldMapExit()
	self:ReleaseRenderActor()
	self:ReleaseCameraActor()
end

function LoginUIMgr:OnGameEventPWorldMapEnter(Params)
    --幻想药成功使用后，需要播放过场动画，过场动画要在PWorldMapEnter后才能播放，此时所有子关卡都加载完
	if self.LeaveFromFatasia then
		self.LeaveFromFatasia = false
		if self.ExitFantasiaSuccess then
			self.ExitFantasiaSuccess = false
		end
		--不管是否成功使用幻想药，都需要播放苏醒动画
		local UActorManager = _G.UE.UActorManager:Get()
		--从幻想药回来，需要先把主角显示出来
		UActorManager:HideMajor(false)
		local function SequenceCallBack()
			FLOG_INFO("Fantasia Play Sequence Wakeup End")
		end
		local PlaybackSettings = {
			bDisableMovementInput = true,
			bDisableLookAtInput = true,
			bPauseAtEnd = false,
		}
		-- 测试用ID
		local SequenceID = _G.Fantasia_Sequence_Wakeup[_G.WorldMsgMgr.CurWorldName]
		if SequenceID then
			FLOG_INFO("Fantasia Play Sequence Wakeup: %s, %d", _G.WorldMsgMgr.CurWorldName, SequenceID)
			_G.StoryMgr:PlayDialogueSequence(SequenceID, SequenceCallBack,
				SequenceCallBack, SequenceCallBack, PlaybackSettings)
		else
			SequenceCallBack()
		end
	end
end

function LoginUIMgr:CreateCamerAnim(RaceID)
end

function LoginUIMgr:ReleaseCameraActor()
	if not self.CameraActor then
		return
	end

	-- if self.Common_Render2D_UIBP then
	-- 	self.Common_Render2D_UIBP:ChangeUIState(true)
	-- end
	local CameraMgr = _G.UE.UCameraMgr.Get()
	if CameraMgr then
		CameraMgr:ResumeCamera(0, true, self.CameraActor)
	end

	if nil ~= self.CameraActor then
		UnLua.Unref(self.CameraActor)
		self.CameraActorRef = nil
		CommonUtil.DestroyActor(self.CameraActor)
	end

	self.IsAlreadySwitchCamera = false
	self.CameraActor = nil
end

function LoginUIMgr:GetCameraActor()
	return self.CameraActor
end

function LoginUIMgr:RotatorCameraActor(YawOffset)
	local Ratation = _G.UE.FRotator(0, _G.LoginMapMgr:GetActorYawOffset(), 0)
	if self.CameraActor then
		self.CameraActor:K2_SetActorRotation(Ratation, false)
	end
end

function LoginUIMgr:OnGazeStateChg(IsGaze)
	self.IsGaze = IsGaze
	if IsGaze then
		MsgTipsUtil.ShowTips(LSTR(980089))--注目功能已经开启
	else
		MsgTipsUtil.ShowTips(LSTR(980090))--注目功能已经关闭
	end
end

function LoginUIMgr:OnTieUpHairStateChg(IsTieUpHair)
	if IsTieUpHair then
		MsgTipsUtil.ShowTips(LSTR(980091))--已开启束发功能，将发型临时替换为不遮挡脸部的发型
	else
		MsgTipsUtil.ShowTips(LSTR(980092))--已关闭束发功能，将发型恢复为当前选中的发型
	end
end

--演示场景返回
function LoginUIMgr:BackToProfPhase(IsSendMsg)
	_G.SkillSystemMgr:ClearAllSkillSystemEffectWithoutFade()
	-- _G.LoginMgr:RoleLogOut(ProtoCS.LogoutReason.ExitDemo)
	if IsSendMsg then
		_G.LoginMgr:SendDemoRoleExit(ProtoCS.LogoutReason.ExitDemo)
	else
		_G.LoginMgr:OnNetMsgDemoLoginExit()
	end
end

--出生场景返回（临时角色）   断线重连后，返回到确认信息这个ui
function LoginUIMgr:BornSceneBackToLoginCreate()
	_G.LoginMgr:QueryRoleList()
	-- _G.LoginMgr:OnNetMsgDemoLoginExit()
end

---- 幻想药相关的转换逻辑 begin ----
function LoginUIMgr:PreFantasia()
	self:HideSelectRoleView()

	self.IsInFantasia = true
	self.HasSendReqCmd = false
	--初始裸模
	self.bFirstShowUnderCloth = true
	--幻想药第一次切换种族时需要弹窗提示
	self.bFirstChangeAvatar = true
	--幻想药流程中，如果中途退出，需要恢复这部分数据，所以这里先缓存下来
	self.CachedRaceCfgForFantasia = LoginRoleRaceGenderVM.CurrentRaceCfg
	--使用玩家当前的种族等信息初始化
	local RoleSimple = MajorUtil:GetMajorRoleSimple()
	--初始化种族、部族、性别和外貌
	-- 修改部族的接口
	local TribeID = RoleSimple.Tribe
	local RaceID = math.floor((TribeID - 1) / 2 + 1)
	-- self:ChangeRenderActor(RaceID, TribeID, RoleSimple.Gender, false)	
	LoginRoleRaceGenderVM:ChangeRenderActor(RaceID, TribeID, RoleSimple.Gender, false)
	LoginRoleTribePageVM:ChangeRenderActor(RaceID, TribeID, RoleSimple.Gender)
end

function LoginUIMgr:BeginFantasia()
	-- self.IsInFantasia = true
	-- --初始裸模
	-- self.bFirstShowUnderCloth = true
	-- --幻想药流程中，如果中途退出，需要恢复这部分数据，所以这里先缓存下来
	-- self.CachedRaceCfgForFantasia = LoginRoleRaceGenderVM.CurrentRaceCfg
	--使用玩家当前的种族等信息初始化
	local RoleSimple = MajorUtil:GetMajorRoleSimple()
	--初始化种族、部族、性别和外貌
	-- 修改部族的接口
	local TribeID = RoleSimple.Tribe
	local RaceID = math.floor((TribeID - 1) / 2 + 1)
	-- self:ChangeRenderActor(RaceID, TribeID, RoleSimple.Gender, false)
	self:CreateRenderActor(false)
	if LoginRoleProfVM.CurrentProf and self.CurLoginRolePhase == LoginRolePhase.Prof then
		local ProfID = LoginRoleProfVM.CurrentProf.Prof
		self:SetProfEquips(ProfID)
	end
	-- 设置外貌
	_G.LoginAvatarMgr.LastRoleInform = {Tribe = TribeID, Gender = RoleSimple.Gender}
	_G.LoginAvatarMgr:SetCurAvatarFace(RoleSimple.Avatar.Face)
	--初始化生日
	LoginRoleBirthdayVM:InitCalendarList();
	LoginRoleBirthdayVM.SelectMonthIndex = RoleSimple.CreateMoon
	LoginRoleBirthdayVM.SelectDayIndex = RoleSimple.CreateStar
	--初始化守护神
	LoginRoleGodVM:SelectGod(RoleSimple.GodType)

	local role = _G.TableToString(RoleSimple.Avatar.Face)
	FLOG_INFO("BeginFantasia: %s\n", role)
	
	--重置注目
	self.IsGaze = false
	if self.FixPageView then
		if self.FixPageView.MorePage then
			self.FixPageView.MorePage:ResetIsGaze(self.IsGaze)
		end
        -- --不显示下载按钮
		-- if self.FixPageView.ButtonDownloadPak then
		-- 	UIUtil.SetIsVisible(self.FixPageView.ButtonDownloadPak, false)
		-- end
	end
end

---@param Success boolean 是否成功使用幻想药
function LoginUIMgr:EndFantasia(Success, NewSimple)
	self.IsInFantasia = false
	self.bFirstShowUnderCloth = false
	self.bFirstChangeAvatar = false;
    _G.UE.UBGMMgr.Get():SetKeepBGMWhenWorldChange(false)
	_G.LoginUIMgr:DiscardCreateRoleData()
	--还原或更新LoginRoleRaceGenderVM的数据，理发屋会用到
	if not Success then
		LoginRoleRaceGenderVM:SelectRoleSetCurrentRaceCfg(self.CachedRaceCfgForFantasia)
	else
		local RaceCfg = LoginRoleRaceGenderVM:GetRoleCfgByRoleSimple(NewSimple)
		LoginRoleRaceGenderVM:SelectRoleSetCurrentRaceCfg(RaceCfg)
	end
	--在离开幻想药场景后，用于判断是否成功使用
	self.ExitFantasiaSuccess = Success
	--是否从幻想药场景离开
	self.LeaveFromFatasia = true
end

function LoginUIMgr:DoExitFantasia(Params)
	self:HideCreateRoleView()
	self:Reset()	--要在后面，否则之前的view没有hide掉

	-- self:DiscardCreateRoleData()
	self:EndFantasia(false)

	local ShouldLeavePWorld = true
	if Params and Params.ExitAfterLoadWorld == true then
		ShouldLeavePWorld = false
	end
	if ShouldLeavePWorld then
		-- 退出幻想药副本
		_G.PWorldMgr:SendLeavePWorld()
	end
    CommonUtil.ShowJoyStick()
end

--判断幻想药流程中角色是否实际发生了变化，无变化不需要消耗幻想药
function LoginUIMgr:CheckFantasiaAvatarChanged()
	local Profile = {}
	self:FillFantasiaProfileUpdateMsg(Profile)
	local RoleSimple = MajorUtil:GetMajorRoleSimple()
	local reason = 0
	if RoleSimple.Gender ~= Profile.Gender then
		return true, reason
	end
	reason = reason + 1
	if RoleSimple.Gender ~= Profile.Gender then
		return true, reason
	end
	reason = reason + 1
	if RoleSimple.Race ~= Profile.Race then
		return true, reason
	end
	reason = reason + 1
	if RoleSimple.Tribe ~= Profile.Tribe then
		return true, reason
	end
	reason = reason + 1
	if RoleSimple.CreateMoon ~= Profile.CreateMoon then
		return true, reason
	end
	reason = reason + 1
	if RoleSimple.CreateStar ~= Profile.CreateStar then
		return true, reason
	end
	reason = reason + 1
	if RoleSimple.GodType ~= Profile.GodType then
		return true, reason
	end
	reason = reason + 1
	if not table.compare_table(RoleSimple.Avatar.Face, Profile.Avatar) then
		local role = _G.TableToString(RoleSimple.Avatar.Face)
		local profile = _G.TableToString(Profile.Avatar)
		FLOG_INFO("Avatar was changed!\nRole: {1}\nProfile: {2}", role, profile)
		return true, reason
	end
	return false, reason
end

function LoginUIMgr:PhaseTypeToIndex(PhaseType)
	if _G.LoginMapMgr.CurLoginMapType == _G.LoginMapType.Fantasia then
		return PhaseTypeToIndexTable_ForFantasia[PhaseType] or PhaseType
	end
	return PhaseType
end

function LoginUIMgr:PhaseIndexToType(PhaseIndex)
	if _G.LoginMapMgr.CurLoginMapType == _G.LoginMapType.Fantasia then
		return PhaseIndexToTypeTable_ForFantasia[PhaseIndex] or PhaseIndex
	end
	return PhaseIndex
end

function LoginUIMgr:GetNextPhaseType(PhaseType)
	if _G.LoginMapMgr.CurLoginMapType == _G.LoginMapType.Fantasia then
		return NextPhaseJumpTable_ForFantasia[PhaseType] or PhaseType + 1
	end
	return PhaseType + 1
end

function LoginUIMgr:GetPrePhaseType(PhaseType)
	if _G.LoginMapMgr.CurLoginMapType == _G.LoginMapType.Fantasia then
		return PrePhaseJumpTable_ForFantasia[PhaseType] or PhaseType - 1
	end
	return PhaseType - 1
end
---- 幻想药相关的转换逻辑 end ----

return LoginUIMgr