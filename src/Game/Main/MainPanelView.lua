--
-- Author: anypkvcai
-- Date: 2020-09-01 16:16:50
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MainPanelVM = require("Game/Main/MainPanelVM")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsVisibleNoAnimOut = require("Binder/UIBinderSetIsVisibleNoAnimOut")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local LoginMgr = require("Game/Login/LoginMgr")
local TeamVM = require("Game/Team/VM/TeamVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local FashionDecoVM = require("Game/FashionDeco/VM/FashionDecoVM")
local ModuleOpenMgr = require("Game/ModuleOpen/ModuleOpenMgr")
local MountVM = require("Game/Mount/VM/MountVM")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local CommonUtil = require("Utils/CommonUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local SpecialUislotCfg = require("TableCfg/SpecialUislotCfg")
local MainFunctionDefine = require("Game/Main/FunctionPanel/MainFunctionDefine")
local TimeDefine = require("Define/TimeDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local OperationUtil = require("Utils/OperationUtil")
local DanmakuVM = require("Game/Danmaku/DanmakuVM")

local ModuleType = ProtoRes.module_type
local EnumRidePurposeType = ProtoRes.EnumRidePurposeType
local EventID = _G.EventID
local PWorldWarringMgr = _G.PWorldWarningMgr

---@class MainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AdventureTaskTips AdventureRecommendTaskTipsView
---@field BtnChannels UFButton
---@field BtnWelfare UFButton
---@field ButtonGM UFButton
---@field ButtonSkip UFButton
---@field ButtonTarget UFButton
---@field CardsTourneyInfoPanel CardContestStageInfoView
---@field ControlPanel MainControlPanelView
---@field DanmakuPanel MainDanmakuPanelView
---@field ExclusiveBattleQuestInfoPanel ExclusiveBattleQuestInfoPanelView
---@field FTextBlock_67 UFTextBlock
---@field FashionDecoSkillPanel FashionDecoSkillPanelView
---@field FatePanel FateStageInfoPanelNewView
---@field HatredPanel MainHatredPanelView
---@field IconTarget UFImage
---@field IconTargetBg UFImage
---@field JumboCactpotInfoPanel JumboCactpotInfoPanelView
---@field MainActorInfoPanel MainActorInfoPanelView
---@field MainEntrance MainEntranceItemView
---@field MainFunctionList MainFunctionListView
---@field MainLBottomPanel MainLBottomPanelView
---@field MainMajorInfoPanel MainMajorInfoPanelView
---@field MainTeamPanel MainTeamPanelView
---@field MiniMapPanel MainMiniMapPanelView
---@field MountPanel MainMountPanelView
---@field MysterMerchantInfoPanel MainLimitedTimeInfoItemView
---@field PWorldProBar MainPWorldProBarItemView
---@field PWorldProBar02 MainPWorldProBar02ItemView
---@field PWorldStagePanel PWorldStagePanelView
---@field PWorldTeachingLevelSettings PWorldTeachingLevelSettingsItemView
---@field PanelBoss UFCanvasPanel
---@field PanelTarget UFCanvasPanel
---@field PanelTopRight UFCanvasPanel
---@field PlayStyleInfoPanel PlayStyleInfoPanelView
---@field RegionClearInfoPanel RegionClearInfoPanelView
---@field TableViewSkillCD UTableView
---@field TextChannels UFTextBlock
---@field TextTime2 UFTextBlock
---@field TextTime_1 UFTextBlock
---@field TextWelfare UFTextBlock
---@field WeatherTimeBar WeatherTimeBarItemView
---@field AnimFadeIn UWidgetAnimation
---@field AnimFadeOut UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimMiniMapIn UWidgetAnimation
---@field AnimMiniMapOut UWidgetAnimation
---@field AnimMountIn UWidgetAnimation
---@field AnimMountOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainPanelView = LuaClass(UIView, true)

function MainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AdventureTaskTips = nil
	--self.BtnChannels = nil
	--self.BtnWelfare = nil
	--self.ButtonGM = nil
	--self.ButtonSkip = nil
	--self.ButtonTarget = nil
	--self.CardsTourneyInfoPanel = nil
	--self.ControlPanel = nil
	--self.DanmakuPanel = nil
	--self.ExclusiveBattleQuestInfoPanel = nil
	--self.FTextBlock_67 = nil
	--self.FashionDecoSkillPanel = nil
	--self.FatePanel = nil
	--self.HatredPanel = nil
	--self.IconTarget = nil
	--self.IconTargetBg = nil
	--self.JumboCactpotInfoPanel = nil
	--self.MainActorInfoPanel = nil
	--self.MainEntrance = nil
	--self.MainFunctionList = nil
	--self.MainLBottomPanel = nil
	--self.MainMajorInfoPanel = nil
	--self.MainTeamPanel = nil
	--self.MiniMapPanel = nil
	--self.MountPanel = nil
	--self.MysterMerchantInfoPanel = nil
	--self.PWorldProBar = nil
	--self.PWorldProBar02 = nil
	--self.PWorldStagePanel = nil
	--self.PWorldTeachingLevelSettings = nil
	--self.PanelBoss = nil
	--self.PanelTarget = nil
	--self.PanelTopRight = nil
	--self.PlayStyleInfoPanel = nil
	--self.RegionClearInfoPanel = nil
	--self.TableViewSkillCD = nil
	--self.TextChannels = nil
	--self.TextTime2 = nil
	--self.TextTime_1 = nil
	--self.TextWelfare = nil
	--self.WeatherTimeBar = nil
	--self.AnimFadeIn = nil
	--self.AnimFadeOut = nil
	--self.AnimIn = nil
	--self.AnimMiniMapIn = nil
	--self.AnimMiniMapOut = nil
	--self.AnimMountIn = nil
	--self.AnimMountOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AdventureTaskTips)
	self:AddSubView(self.CardsTourneyInfoPanel)
	self:AddSubView(self.ControlPanel)
	self:AddSubView(self.DanmakuPanel)
	self:AddSubView(self.ExclusiveBattleQuestInfoPanel)
	self:AddSubView(self.FashionDecoSkillPanel)
	self:AddSubView(self.FatePanel)
	self:AddSubView(self.HatredPanel)
	self:AddSubView(self.JumboCactpotInfoPanel)
	self:AddSubView(self.MainActorInfoPanel)
	self:AddSubView(self.MainEntrance)
	self:AddSubView(self.MainFunctionList)
	self:AddSubView(self.MainLBottomPanel)
	self:AddSubView(self.MainMajorInfoPanel)
	self:AddSubView(self.MainTeamPanel)
	self:AddSubView(self.MiniMapPanel)
	self:AddSubView(self.MountPanel)
	self:AddSubView(self.MysterMerchantInfoPanel)
	self:AddSubView(self.PWorldProBar)
	self:AddSubView(self.PWorldProBar02)
	self:AddSubView(self.PWorldStagePanel)
	self:AddSubView(self.PWorldTeachingLevelSettings)
	self:AddSubView(self.PlayStyleInfoPanel)
	self:AddSubView(self.RegionClearInfoPanel)
	self:AddSubView(self.WeatherTimeBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainPanelView:OnActive()
	_G.EventMgr:SendEvent(EventID.TutorialMainPanelReActive, self.ViewID)

	self:ShowMountPanel(MainPanelVM.bIsNeedShowMountPanel)

	_G.MapMgr:SetUpdateMap(true, 1)
end

function MainPanelView:OnInactive()
	_G.MapMgr:SetUpdateMap(false, 1)
	_G.EventMgr:SendEvent(EventID.TutorialMainPanelInActive, self.ViewID)
end

function MainPanelView:OnInit()
	--print("MainPanelView:OnInit")
	self.MainTeamPanel:SetShowQuest()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSkillCD, nil, false)
	self.MultiBinders = {
		{
			ViewModel = MainPanelVM,
			Binders = {
				{"WarningSkillCDItemList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter)},
				{"WarningSkillCDItemListVisibile", UIBinderSetIsVisible.New(self, self.TableViewAdapter, false)},
				{ "MiniMapPanelVisible", UIBinderValueChangedCallback.New(self, nil, self.OnMiniMapPanelVisibleChange) },
				{ "TopLeftMainTeamPanelVisible", UIBinderSetIsVisibleNoAnimOut.New(self, self.MainTeamPanel) },

				{ "PanelTopRightVisible", UIBinderSetIsVisible.New(self, self.PanelTopRight) },
				{ "FateStageInfoVisible", UIBinderSetIsVisible.New(self, self.FatePanel) },
				{ "PlayStyleInfoVisible", UIBinderSetIsVisible.New(self, self.PlayStyleInfoPanel)},
				{ "JumboInfoVisible", UIBinderSetIsVisible.New(self, self.JumboCactpotInfoPanel)},
				{ "FunctionVisible", UIBinderSetIsVisible.New(self, self.MainFunctionList) },
				--{ "AdventureVisible", UIBinderSetIsVisible.New(self, self.ButtonAdventure, false, true)},
				--{ "RideVisible", UIBinderSetIsVisible.New(self, self.ControlPanel.ButtonRide, false, true)},
				--{ "ShopVisible", UIBinderSetIsVisible.New(self, self.ButtonShop, false, true)},
				--{ "TutorialVisible", UIBinderSetIsVisible.New(self, self.ButtonActivity, false, true)},
				-- { "TutorialVisible",  UIBinderSetIsVisible.New(self, self.MainLBottomPanel.ButtonShow, false, true)},
				{ "MagicCardTourneyInfoVisible",  UIBinderSetIsVisible.New(self, self.CardsTourneyInfoPanel)},
				{ "MysterMerchantTaskVisible",  UIBinderSetIsVisible.New(self, self.MysterMerchantInfoPanel)},
				--{ "IsTestVersion", UIBinderSetIsVisible.New(self, self.MountPanel, true)},
				--{ "IsTestVersion", UIBinderSetIsVisible.New(self, self.MainLBottomPanel, true)},
				{ "PWorldStageVisible", UIBinderSetIsVisible.New(self, self.PWorldStagePanel) },
				{ "ControlPanelVisible", UIBinderSetIsVisible.New(self, self.ControlPanel) },
				{ "ProBarVisible", UIBinderSetIsVisible.New(self, self.PWorldProBar) },
				{ "ProBar02Visible", UIBinderSetIsVisible.New(self, self.PWorldProBar02) },
				{ "TeachingLevelVisible", UIBinderValueChangedCallback.New(self, nil, self.OnTeachingLevelVisibleChanged)},
				{ "FunctionVisible", UIBinderValueChangedCallback.New(self, nil, self.OnFunctionVisibleChanged) },
				{ "ExclusiveBattleQuestVisible", UIBinderSetIsVisible.New(self, self.ExclusiveBattleQuestInfoPanel)},
				{ "IsTimeBarVisible", UIBinderSetIsVisible.New(self, self.WeatherTimeBar)},
				{ "IsEnmityPanelVisible", UIBinderValueChangedCallback.New(self, nil, self.OnIsEnmityPanelVisibleChanged)},
			}
		},
		{
			ViewModel = TeamVM,
			Binders = {
				{ "JoinRedDotVisible", UIBinderSetIsVisible.New(self, self.ImageApplyRedDot) },
			}
		},
		{
			ViewModel = MountVM,
			Binders = {
				{ "IsInRide", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateIsInRide) },
				{ "IsCombatState", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateIsCombatState) },
				{ "IsPanelVisible", UIBinderSetIsVisible.New(self, self.MountPanel) },
			}
		},
		{
			ViewModel = FashionDecoVM,
			Binders = {
				{ "IsInFashionDecorateState", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateIsInFashionDecorateState) },
			}
		},
		{
			ViewModel = DanmakuVM,
			Binders = {
				{ "MainPanelDanmakuVisible", UIBinderSetIsVisible.New(self, self.DanmakuPanel) },
			}
		}
	}

	MainPanelVM.MainPanelView = self
end

function MainPanelView:OnDestroy()
	--print("MainPanelView:OnDestroy")
end

function MainPanelView:OnShow()
	UIUtil.SetIsVisible(self.TextTime2, true)
	UIUtil.TextBlockSetFontSize(self.TextTime2, 12)
	self:OnPlayFadeAnim(true)
	--print("MainPanelView:OnShow")
	--提审版本不显示GM按钮
	_G.GMMgr:OpenGMPanel()
	
	-- UIUtil.SetIsVisible(self.ButtonActivity, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMonthCard), true)
	-- UIUtil.SetIsVisible(self.ButtonActivity, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDActivitySystem), true)
	-- UIUtil.SetIsVisible(self.ButtonActivity, false, false)
	-- UIUtil.SetIsVisible(self.ButtonAdventure, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDAdventure), true)
	-- UIUtil.SetIsVisible(self.ButtonShop, false)
	-- UIUtil.SetIsVisible(self.ButtonShop, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMall), true)
	-- UIUtil.SetIsVisible(self.ButtonBag, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBattlePass), true)
	-- UIUtil.SetIsVisible(self.ButtonBag, false, false)
	-- UIUtil.SetIsVisible(self.AdventureTaskTips, false)

	-- Todo 首测分支需要开关
	--UIUtil.SetIsVisible(self.ButtonActivity, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMonthCard) and _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MONTHLY_CARD), true)
	-- UIUtil.SetIsVisible(self.ButtonBag, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBattlePass) and _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_PASSPORT), true)

	--UIUtil.SetIsVisible(self.ControlPanel, not MainPanelVM.bIsNeedShowMountPanel)
	--UIUtil.SetIsVisible(self.MountPanel.PanelMount, MainPanelVM.bIsNeedShowMountPanel)
	self:ShowMountPanel(MainPanelVM.bIsNeedShowMountPanel)
	MainPanelVM:SetSubViewsHideByConfig(self)
	-- self.MainLBottomPanel:SetButtonEmotionVisible(true)
	-- self.MainLBottomPanel:SetButtonPhotoVisible(true)
	-- local AdventureDefine = require("Game/Adventure/AdventureDefine")
	-- local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
	-- local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
	-- self.AdventureRedDot:SetRedDotIDByID(AdventureDefine.RedDefines.Entrance)

	-- self.CommonRedDot5:SetRedDotIDByID(OpsActivityDefine.RedDotID)
	-- self.CommonRedDot2:SetRedDotIDByID(8000)

	self.TextTime_1:SetText(_G.LSTR(1440016)) --1440016("跳过新手场景")

	_G.EventMgr:SendEvent(EventID.MainPanelShow, { bShow = true })

	_G.MapMgr:SetUpdateMap(true, 1)

	self:CheckMajorLevel()

	UIUtil.SetIsVisible(self.MainEntrance, true)

	local TimeType = TimeDefine.TimeType
	local TimeTypeList = {
		TimeType.Aozy,
		TimeType.Server,
	}
	self.WeatherTimeBar:SetTypeList(TimeTypeList)

	_G.BuoyMgr:ShowAllBuoys(true)

	MainPanelVM:SetMainPanelEmotionVisible(true)
	MainPanelVM:SetMainPanelPhotoVisible(true)
end

function MainPanelView:OnHide()
	--print("MainPanelView:OnHide")
	if self.RecommendTipsTimer ~= nil then
		self:UnRegisterTimer(self.RecommendTipsTimer)
		self.RecommendTipsTimer = nil
	end
end

function MainPanelView:OnRegisterUIEvent()
	--print("MainPanelView:OnRegisterUIEvent")

	-- UIUtil.AddOnClickedEvent(self, self.ButtonBag, self.OnClickButtonBag)
	-- UIUtil.AddOnClickedEvent(self, self.ButtonSwitch, self.OnClickButtonSwitch)
	-- UIUtil.AddOnClickedEvent(self, self.ButtonActor, self.OnClickButtonActor)
	-- UIUtil.AddOnClickedEvent(self, self.ButtonActivity, self.OnClickButtonActivity)
	-- UIUtil.AddOnClickedEvent(self, self.ButtonAdventure, self.OnClickAdventure)

	-- UIUtil.AddOnClickedEvent(self, self.ButtonShop, self.OnClickButtonShop)
	UIUtil.AddOnClickedEvent(self, self.ButtonSkip, self.OnClickButtonSkip)

	-- UIUtil.AddOnClickedEvent(self, self.ButtonQuestionnaire, self.OnClickButtonQuestionnaire)

	UIUtil.AddOnClickedEvent(self, self.BtnWelfare, self.OnOpenPlatformWelfare)
	UIUtil.AddOnClickedEvent(self, self.BtnChannels, self.OnOpenPlatformWelfare)
end

function MainPanelView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.ModuleOpenGMBtnEvent, self.OnChangeBtnState)
	self:RegisterGameEvent(EventID.RecommendTaskNewTip, self.ShowNewRecommendTask)
	self:RegisterGameEvent(EventID.GMShowWeatherInfoPanel,self.OnShowGMWeatherInfoPanel)
	self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldEnter)

	self:RegisterGameEvent(EventID.ShowSubViews, self.OnShowSubViews)
	self:RegisterGameEvent(EventID.PWorldProgressSlot,self.OnProgressSlotChanged)
	self:RegisterGameEvent(EventID.PWorldProgressSlotHide,self.OnHidePWorldProBar)
	self:RegisterGameEvent(EventID.GMShowRTT,self.OnGameEventShowRTT)
	self:RegisterGameEvent(EventID.ShowMURSurveyEntrance,self.OnShowMURSurveyEntrance)
	self:RegisterGameEvent(EventID.ShowMURSurveyRedDot,self.OnShowMURSurveyRedDot)
	self:RegisterGameEvent(EventID.ModuleOpenMainPanelFadeAnim,self.OnPlayFadeAnim)
	self:RegisterGameEvent(EventID.AdvenCareerTaskGuide,self.OnShowAdvCareerGuideTips)
	self:RegisterGameEvent(EventID.MajorLevelUpdate, self.CheckMajorLevel)
	self:RegisterGameEvent(EventID.PWorldWarningDuring, self.OnPWorldWarningDuring)
	self:RegisterGameEvent(EventID.PWorldWarningEnd, self.OnPWorldWarningEnd)
	self:RegisterGameEvent(EventID.FightSkillPanelShowed, self.OnFightSkillPanelOpened)
end

-- 放到OnActive里判断
-- function MainPanelView:OnHideView(ViewID)
-- 	if ViewID == UIViewID.MountPanel then
-- 		self:ShowMountPanel(MainPanelVM.bIsNeedShowMountPanel)
-- 	end
-- end

function MainPanelView:OnRegisterTimer()
	--print("MainPanelView:OnRegisterTimer")
	self:RegisterTimer(self.UpdateRTT, 0, 0.5, 0)
end

function MainPanelView:OnRegisterBinder()
	--print("MainPanelView:OnRegisterBinder")
	self:RegisterMultiBinders(self.MultiBinders)
end

--  修复这个：bug=136911063 【主干】【主界面】用gm解锁金蝶游乐场之后，然后传送到游乐场内的水晶传送点主界面UI就消失了
function MainPanelView:OnPWorldEnter()
	self:OnPlayFadeAnim(true)

	-- 切图刷新一次仇恨列表
	self:OnIsEnmityPanelVisibleChanged(MainPanelVM.IsEnmityPanelVisible)
end

-- function MainPanelView:OnTeamRollItemViewShowStatus(IsShow)
	-- if IsShow then
	-- 	UIUtil.SetIsVisible(self.ControlPanel, false)
	-- else
	-- 	UIUtil.SetIsVisible(self.ControlPanel, true)
	-- end
-- end

function MainPanelView:OnMiniMapPanelVisibleChange(Value)
	--print("MainPanelView:OnMiniMapPanelVisibleChange")
	if Value then
		self:PlayAnimation(self.AnimMiniMapIn)
		self.IsMapMOpen = false
	else
		self:PlayAnimation(self.AnimMiniMapOut)
		self.IsMapMOpen = true
		self.AdventureTaskTips:HidePanel()
	end
end

-- function MainPanelView:OnClickButtonBag()
-- 	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_PASSPORT, true) then
-- 		return
-- 	end
-- 	UIViewMgr:ShowView(UIViewID.BattlePassMainView)
-- end

-- function MainPanelView:OnClickButtonActivity()
-- 	-- if _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MONTHLY_CARD, true) then
-- 	-- 	UIViewMgr:ShowView(UIViewID.MonthCardMainPanel)
-- 	-- 	return
-- 	-- end
-- 	UIViewMgr:ShowView(UIViewID.OpsActivityMainPanel)
-- end

-- function MainPanelView:OnClickButtonSwitch()
--     --提审版本未下载全量资源时禁用二级菜单
--     if CommonUtil.ShouldDownloadRes() then
--         CommonUtil.ShowDownloadResMsgBox()
--         return
--     end

-- 	-- 打开二级界面
-- 	UIViewMgr:ShowView(UIViewID.Main2ndPanel)
-- end

-- function MainPanelView:OnClickButtonActor()
-- 	if not LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_ROLE, true) then
-- 		return
-- 	end

-- 	UIViewMgr:ShowView(UIViewID.EquipmentMainPanel)
-- end

-- function MainPanelView:OnClickAdventure()
-- 	if not ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDAdventure) then
-- 		return
-- 	end
-- 	if not LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_ROLE, true) then
-- 		return
-- 	end


-- 	local DataReportUtil = require("Utils/DataReportUtil")
-- 	local AdventureDefine = require("Game/Adventure/AdventureDefine")
-- 	DataReportUtil.ReportSystemFlowData("ReTasksInfo", tostring(AdventureDefine.ReportAdventureRecommendTaskType.EnterMethod), _G.UIViewID.MainPanel)
-- 	UIViewMgr:ShowView(UIViewID.AdventruePanel)
-- end

-- function MainPanelView:OnClickButtonTarget()
-- 	local Major = _G.UE.UActorManager:Get():GetMajor()
-- 	_G.SwitchTarget:SwitchTargets(Major)
-- end

-- 系统解锁时 计算按钮位置
-- function MainPanelView:OnRefushEndPos()
-- 	local BtnSwitchPos = self:OnCalculateWidgetPos(self.ButtonSwitch)		-- 二级界面按钮
-- 	ModuleOpenMgr:SetMain2ndBtnPos(BtnSwitchPos)
-- 	local BtnAdvPos = self:OnCalculateWidgetPos(self.ButtonAdventure)		-- 挑战笔记按钮
-- 	ModuleOpenMgr:SetAdventureBtnPos(BtnAdvPos)
-- 	-- local BtnMallPos = self:OnCalculateWidgetPos(self.ButtonShop)			-- 商城按钮
-- 	-- ModuleOpenMgr:SetMallBtnPos(BtnMallPos)
-- 	local BtnActivity = self:OnCalculateWidgetPos(self.ButtonActivity)		-- 活动按钮位置
-- 	ModuleOpenMgr:SetActivityBtnPos(BtnActivity)
-- 	local ButtonBagPos = self:OnCalculateWidgetPos(self.ButtonBag)			-- 背包按钮位置(现战令)
-- 	ModuleOpenMgr:SetBagBtnPos(ButtonBagPos)
-- 	local ScreenSize = UIUtil.GetScreenSize()
-- 	local BtnPos = UIUtil.CanvasSlotGetPosition(self.MiniMapPanel.ToggleBtnSwitch)
-- 	local BtnSize = UIUtil.CanvasSlotGetSize(self.MiniMapPanel.ToggleBtnSwitch)
-- 	local MiniMapBtnPos = _G.UE.FVector2D(ScreenSize.X / 2 + BtnPos.X + BtnSize.X / 2, BtnPos.Y - ScreenSize.Y / 2 + BtnSize.Y / 2)
-- 	ModuleOpenMgr:SetMiniMapBtnPos(MiniMapBtnPos)
-- end

-- 主界面按钮坐标转换
-- function MainPanelView:OnCalculateWidgetPos(Widget)
-- 	local ScreenSize = UIUtil.GetScreenSize()
-- 	local BtnLocalPos = UIUtil.CanvasSlotGetPosition(Widget)
-- 	local BtnSize = UIUtil.CanvasSlotGetSize(Widget)
-- 	local ParentPanelPos = UIUtil.CanvasSlotGetPosition(self.Function)
-- 	local ParentPanelSize = UIUtil.CanvasSlotGetSize(self.Function)
-- 	local EndPosX = ParentPanelPos.X + ParentPanelSize.X + ScreenSize.X / 2 + BtnSize.X / 2 + BtnLocalPos.X
-- 	-- local EndPosY = ParentPanelPos.Y + ParentPanelSize.Y - ScreenSize.Y / 2 - BtnSize.Y / 2 + BtnLocalPos.Y
-- 	local EndPosY = ParentPanelPos.Y - ScreenSize.Y / 2 + BtnLocalPos.Y + BtnSize.Y / 2
-- 	if self.IsMapMOpen then
-- 		EndPosX = EndPosX - 120
-- 	end
-- 	return _G.UE.FVector2D(EndPosX, EndPosY)
-- end

-- function MainPanelView:OnChangeBtnState()
	-- UIUtil.SetIsVisible(self.ButtonAdventure, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDAdventure) or ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDDailyRand), true)
	-- UIUtil.SetIsVisible(self.ButtonShop, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMall), true)
	-- UIUtil.SetIsVisible(self.MountPanel.ToggleBtnRide, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMount), true)
	-- UIUtil.SetIsVisible(self.ButtonBag, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBattlePass), true)
	-- UIUtil.SetIsVisible(self.ButtonBag, false, false)
	-- UIUtil.SetIsVisible(self.ButtonActivity, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDActivitySystem), true)
	--UIUtil.SetIsVisible(self.ButtonActivity,false, false)

	-- UIUtil.SetIsVisible(self.ButtonBag, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBattlePass) and _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_PASSPORT), true)
	-- UIUtil.SetIsVisible(self.ButtonActivity, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMonthCard) and  _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MONTHLY_CARD), true)
-- end

-- function MainPanelView:OnClickButtonShop()
-- 	if _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MALL, true) then
-- 		UIViewMgr:ShowView(UIViewID.StoreMainPanel)
-- 	end
-- end

function MainPanelView:OnClickButtonSkip()
	if _G.QuestMgr.EndChapterMap[14028] then
		_G.GMMgr:ReqGM("scene enter 1001005")
	else
		-- _G.GMMgr:ReqGM("role quest clear")
		-- _G.GMMgr:ReqGM("role quest accept 140224")
		
		if _G.DemoMajorType == 0 then
			_G.GMMgr:ReqGM("role quest dochapter 14028")
		else
			local function DelayShowMakeNameUI()
				local UIViewConfig = require("Define/UIViewConfig")
				local UILayer = require("UI/UILayer")
				local ViewConfig = UIViewConfig[UIViewID.LoginCreateMakeName]
				ViewConfig.Layer = UILayer.BelowNormal
				UIViewMgr:ShowView(UIViewID.LoginCreateMakeName, {ShowBg = true})
				self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGMRoleLoginRes)
			end
			_G.TimerMgr:AddTimer(nil, DelayShowMakeNameUI, 1, 1, 1)
		end
	end
	MsgTipsUtil.ShowTips("设置昵称后才会真正创建角色")
end

function MainPanelView:OnGMRoleLoginRes()
	local UIViewConfig = require("Define/UIViewConfig")
	local UILayer = require("UI/UILayer")
	local ViewConfig = UIViewConfig[UIViewID.LoginCreateMakeName]
	ViewConfig.Layer = UILayer.Exclusive

	UIViewMgr:HideView(UIViewID.LoginCreateMakeName)
	self:UnRegisterGameEvent(EventID.RoleLoginRes, self.OnGMRoleLoginRes)
	_G.GMMgr:ReqGM("role quest dochapter 14028")
end

function MainPanelView:OnClickButtonQuestionnaire()
	_G.MURSurveyMgr:OpenMURSurvey(1, false, true, "", false)
end

function MainPanelView:ShowButtonSkill()
end

function MainPanelView:OnFunctionVisibleChanged()
	if not MainPanelVM.FunctionVisible then
		if self.RecommendTipsTimer ~= nil then
			self:UnRegisterTimer(self.RecommendTipsTimer)
			self.RecommendTipsTimer = nil
		end
	end

	UIUtil.SetIsVisible(self.AdventureTaskTips, false)
	self.AdventureTaskTips:HidePanel()
end

function MainPanelView:OnTeachingLevelVisibleChanged(Value)
	UIUtil.SetIsVisible(self.PWorldTeachingLevelSettings, Value, true)
	if self.PWorldStagePanel ~= nil and self.PWorldStagePanel.BtnFold ~= nil then
		UIUtil.SetIsVisible(self.PWorldStagePanel.BtnFold, not Value, true)
	end
end

function MainPanelView:OnShowMURSurveyEntrance(Params)
	--print("MainPanelView:OnShowMURSurveyEntrance")
	local bShow = (nil ~= Params and nil ~= Params.bIsShow and Params.bIsShow == true)
	-- if bShow then
	-- 	UIUtil.SetIsVisible(self.ButtonQuestionnaire, true, true)
	-- else
	-- 	UIUtil.SetIsVisible(self.ButtonQuestionnaire, false)
	-- end
end

function MainPanelView:OnShowMURSurveyRedDot(Params)
	--print("MainPanelView:OnShowMURSurveyRedDot")
	local bShow = (nil ~= Params and nil ~= Params.bIsShow and Params.bIsShow == true)
	--FLOG_INFO("MainPanelView:OnShowMURSurveyRedDot, bShow:%s", tostring(bShow))
	--self.CommonRedDot1_1:SetIsCustomizeRedDot(true)
	--self.CommonRedDot1_1:SetRedDotUIIsShow(true)
	--UIUtil.SetIsVisible(self.CommonRedDot1_1, bShow)
end

function MainPanelView:OnPlayFadeAnim(IsIn)
	FLOG_INFO("MainPanelView:OnPlayFadeAnim IsIn = %s", IsIn)
	local TempAnim = IsIn and self.AnimFadeIn or self.AnimFadeOut
	local TempStopAnim = IsIn and self.AnimFadeOut or self.AnimFadeIn
	self:PlayAnimation(TempAnim)
	self:StopAnimation(TempStopAnim)
end

function MainPanelView:IsCanShowAdventureTips(ModuleID)
	-- local ButtonAdventure = self.ButtonAdventure
	local FunctionPanel =  self.MainFunctionList

	-- if not UIUtil.IsVisible(ButtonAdventure) then
	-- 	return false
	-- end

	if not UIUtil.IsVisible(FunctionPanel) then
		return false
	end

	-- if not UIUtil.IsVisible(ButtonAdventure:GetParent()) then
	-- 	return false
	-- end

	if not ModuleOpenMgr:CheckOpenState(ModuleID) then
		return false
	end

	if self.RecommendTipsTimer ~= nil then
		return false
	end

	if self.IsMapMOpen then
		return false
	end
		
	return true
end

function MainPanelView:GetAdvtureGuideTipsPos()
	local PosX, PosY = self.MainFunctionList:GetItemPosition(MainFunctionDefine.ButtonType.ADVENTURE)

	if PosX ~= nil and PosY ~= nil then
		-- Tips需要一个相对于屏幕右上角的坐标
		local ScreenSize = UIUtil.GetScreenSize()
		local ResultX = PosX - ScreenSize.X + 50  -- 数字项是Tips蓝图箭头居中需要的偏移，TODO 改蓝图
		local ResultY = PosY + 40  -- 数字项是半个按钮的大小
		return ResultX, ResultY
	end

	return 0, 0
end

function MainPanelView:OnShowAdvCareerGuideTips()
	if not self:IsCanShowAdventureTips(ProtoCommon.ModuleID.ModuleIDJobQuest) then
		return
	end

	local Callback = function()
		UIUtil.SetIsVisible(self.AdventureTaskTips, false)
	end

	local EndPosX, EndPosY = self:GetAdvtureGuideTipsPos()
	self.AdventureTaskTips:SetType(2, Callback)
	self.AdventureTaskTips:SetTipsPosition(_G.UE.FVector2D(EndPosX, EndPosY))
	UIUtil.SetIsVisible(self.AdventureTaskTips, true)
end

function MainPanelView:ShowNewRecommendTask()
	if not self:IsCanShowAdventureTips(ProtoCommon.ModuleID.ModuleIDAdviseTask) then
		return
	end
	
	local EndPosX, EndPosY = self:GetAdvtureGuideTipsPos()
	self.AdventureTaskTips:SetType(1)
	self.AdventureTaskTips:SetTipsPosition(_G.UE.FVector2D(EndPosX, EndPosY))
	UIUtil.SetIsVisible(self.AdventureTaskTips, true)
	self.AdventureTaskTips:PlayAnimIn()

	local DataValue = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_RECOMMEND_TASK_SHOW_TIME)
	local HideTime = DataValue.Value[1]
	self.RecommendTipsTimer = self:RegisterTimer(function ()
		self.AdventureTaskTips:PlayAnimOut()
		self:UnRegisterTimer(self.RecommendTipsTimer)
		self.RecommendTipsTimer = nil
		UIUtil.SetIsVisible(self.AdventureTaskTips, false)
	end, HideTime)
end

function MainPanelView:OnUpdateIsInRide()
	self:ShowMountPanel(MountVM.IsInRide)
end
function MainPanelView:OnUpdateIsInFashionDecorateState()
	self:ShowFashionDecoSkillPanel(FashionDecoVM.IsInFashionDecorateState)
end
function MainPanelView:ShowFashionDecoSkillPanel(bIsFashionDecoSkillPanel)
	UIUtil.SetIsVisible(self.FashionDecoSkillPanel, bIsFashionDecoSkillPanel)
end
function MainPanelView:OnUpdateIsCombatState()
	if MountVM.IsInRide then
		self:ShowMountPanel(MountVM.IsInRide)
	end
end

function MainPanelView:ShowMountPanel(bIsShowMountPanel)
	MainPanelVM.bIsNeedShowMountPanel = bIsShowMountPanel
	if UIUtil.IsVisible(self) then
		if bIsShowMountPanel then
			local PurposeType = _G.MountMgr:GetPurposeType(MountVM.CurRideResID)
			if PurposeType == EnumRidePurposeType.Call then
				-- UIUtil.SetIsVisible(self.MountPanel.PanelRide, MountVM.IsInOtherRide)
				-- UIUtil.SetIsVisible(self.MountPanel.PanelCalled, not MountVM.IsInOtherRide)
				if not MainPanelVM.IsMountPanelVisible then
					--self:PlayMountInOutAnim(self, self.AnimMountIn, self.AnimMountOut, true)
					self:PlayMountInOutAnim(self.ControlPanel, self.ControlPanel.AnimMountIn, self.ControlPanel.AnimMountOut, true)
					self:PlayMountInOutAnim(self.MountPanel, self.MountPanel.AnimMountIn, self.MountPanel.AnimMountOut, true)
					MainPanelVM.IsMountPanelVisible = true
				end
				UIUtil.SetIsVisible(self.MountPanel.PanelCalled, true)
				UIUtil.SetIsVisible(self.MountPanel.PanelMount, true)
			else
				self.MountPanel:StopInOutAnim()
				MainPanelVM:SetControlPanelVisible(false)
				UIUtil.SetIsVisible(self.MountPanel.PanelCalled, false)
				UIUtil.SetIsVisible(self.MountPanel.PanelMount, false)
				UIViewMgr:ShowView(UIViewID.ChocoboTransportSkill)
			end
			UIViewMgr:HideView(UIViewID.GatherDrugSkillPanel)
		else
			MainPanelVM:SetControlPanelVisible(true)
			if MainPanelVM.IsMountPanelVisible then
				--self:PlayMountInOutAnim(self, self.AnimMountIn, self.AnimMountOut, false)
				self:PlayMountInOutAnim(self.ControlPanel, self.ControlPanel.AnimMountIn, self.ControlPanel.AnimMountOut, false)
				self:PlayMountInOutAnim(self.MountPanel, self.MountPanel.AnimMountIn, self.MountPanel.AnimMountOut, false)
				MainPanelVM.IsMountPanelVisible = false
			end
			UIUtil.SetIsVisible(self.MountPanel.PanelMount, false)
			UIViewMgr:HideView(UIViewID.ChocoboTransportSkill)
		end
		_G.EventMgr:SendEvent(EventID.OnShowMountPanel, { bIsShowMountPanel = bIsShowMountPanel } )
	end

	--MainPanelVM:SetControlPanelVisible(not bIsShowMountPanel)
end

function MainPanelView:PlayMountInOutAnim(Widget, InAnim, OutAnim, bIn)
	if Widget == nil then return end
	if bIn == nil then return end
	if bIn then
		Widget:StopAnimation(OutAnim)
		Widget:PlayAnimation(InAnim)
	elseif not bIn then
		Widget:StopAnimation(InAnim)
		Widget:PlayAnimation(OutAnim)
	end
end

function MainPanelView:OnShowGMWeatherInfoPanel(bShow)
	if bShow then
		if self.GMWeatherInfoView ~= nil then
			return
		end

		local GMWeatherInfoView = UIViewMgr:CreateView(UIViewID.GMWeatherInfoPanel, self, true, true)
		local ParentView = self.PanelTopRight

		if ParentView == nil then
			return
		end

		ParentView:AddChild(GMWeatherInfoView)

		local ScreenSize = UIUtil.GetScreenSize()
		UIUtil.CanvasSlotSetSize(GMWeatherInfoView, ScreenSize)
		UIUtil.CanvasSlotSetPosition(GMWeatherInfoView, _G.UE.FVector2D(0, 0))
		--GMWeatherInfoView:OnShow()
		self.GMWeatherInfoView = GMWeatherInfoView
	else
		if self.GMWeatherInfoView ~= nil then
			self.GMWeatherInfoView:RemoveFromParent()
			UIViewMgr:RecycleView(self.GMWeatherInfoView)
			self.GMWeatherInfoView = nil
		end
	end

	--临时加一些chairmaker的测试,后面会删除
	---_G.UE.UEnvMgr:Get():TestCharkMarker()
end

function MainPanelView:OnGameEventPWorldExit(LeaveWorldResID)
	if self.IsShowView then
		MainPanelVM:SetSubViewsShowByConfig(self, LeaveWorldResID)
	end

	if MainPanelVM:GetPWorldProBarVisible() == true then
		self.PWorldProBar:Hide()
		MainPanelVM.ProBarVisible = false
	end
	if MainPanelVM:GetPWorldProBar02Visible() == true then
		self.PWorldProBar02:Hide()
		MainPanelVM.ProBar02Visible = false
	end
end

function MainPanelView:OnShowSubViews()
	MainPanelVM:SetSubViewsShowByConfig(self, 1424020)
end

function MainPanelView:OnHidePWorldProBar(Param)
	MainPanelVM.ProBarVisible = false
	MainPanelVM.ProBar02Visible = false
end

function MainPanelView:OnGameEventShowRTT(Param)
	UIUtil.SetIsVisible(self.TextTime2, Param)
end

function MainPanelView:OnProgressSlotChanged(Params)
	local ProgressSlot = Params.Content

	if ProgressSlot.ID == 0 then
		if MainPanelVM:GetPWorldProBarVisible() == true then
			self.PWorldProBar:HideAll()
			MainPanelVM.ProBarVisible = false
		end
		if MainPanelVM:GetPWorldProBar02Visible() == true then
			self.PWorldProBar02:HideAll()
			MainPanelVM.ProBar02Visible = false
		end
	else
		local Cfg = SpecialUislotCfg:FindCfgByID(ProgressSlot.ID)

		if Cfg == nil then
			return
		end

		if Cfg.BPPath == "" then
			if MainPanelVM:GetPWorldProBar02Visible() then
				MainPanelVM.ProBar02Visible = false
			end
			if MainPanelVM:GetPWorldProBarVisible() then
				MainPanelVM.ProBarVisible = false
			end
			self.PWorldStagePanel:OnBattleProgressSlot(Cfg.UIName,ProgressSlot.CurValue,ProgressSlot.MaxValue)
			return
		end

		local substr = "02"

		local start_pos, end_pos = string.find(Cfg.BPPath, substr)

		if start_pos then
			self.PWorldProBar02:SetContent(ProgressSlot.ID,ProgressSlot.Order,ProgressSlot.CurValue,ProgressSlot.MaxValue)
			if not MainPanelVM:GetPWorldProBar02Visible() then
				MainPanelVM.ProBar02Visible = true
				self.PWorldProBar02:PlayAnimIn()
			end
		else
			self.PWorldProBar:SetContent(ProgressSlot.ID,ProgressSlot.Order,ProgressSlot.CurValue,ProgressSlot.MaxValue)
			if not MainPanelVM:GetPWorldProBarVisible() then
				MainPanelVM.ProBarVisible = true
				self.PWorldProBar:PlayAnimIn()
			end
		end
	end
end

function MainPanelView:CheckMajorLevel(Params)
    local MajorMaxLevel = self:GetMajorMaxLevel()
    if MajorMaxLevel >= 8 then
		self:ShowWelfareEntrance()
	end
end

function MainPanelView:OnFightSkillPanelOpened(IsShow)
	self.IsFightSkillPanelShowed = IsShow
	self:ShowWelfareEntrance()
end

function MainPanelView:ShowWelfareEntrance()
	if nil ~= self.IsFightSkillPanelShowed and self.IsFightSkillPanelShowed == true then
		UIUtil.SetIsVisible(self.BtnWelfare, false)
		UIUtil.SetIsVisible(self.BtnChannels, false)
		return
	end

	local Cfg = OperationUtil.GetOperationChannelFuncConfig()
	if _G.LoginMgr:IsWeChatLogin() then
		if nil ~= Cfg and Cfg.IsEnableWeChatWelfareEntrance == 0 then
			UIUtil.SetIsVisible(self.BtnWelfare, false)
		else
			self.TextWelfare:SetText("Dump")
			UIUtil.SetIsVisible(self.BtnWelfare, true, true)
		end
	elseif _G.LoginMgr:IsQQLogin() then
		if nil ~= Cfg and Cfg.IsEnableQQWelfareEntrance == 0 then
			UIUtil.SetIsVisible(self.BtnChannels, false)
		else
			self.TextChannels:SetText(_G.LSTR(100067))
			UIUtil.SetIsVisible(self.BtnChannels, true, true)
		end
	else
		UIUtil.SetIsVisible(self.BtnWelfare, false)
		UIUtil.SetIsVisible(self.BtnChannels, false)
	end
end

function MainPanelView:GetMajorMaxLevel()
    local MaxLevel = 1
	local RoleVM = MajorUtil.GetMajorRoleVM()
    if nil ~= RoleVM then
        local ProfList = RoleVM.ProfSimpleDataList
        if nil ~= ProfList and #ProfList > 0 then
            for _, Value in pairs(ProfList) do
                if ProfUtil.IsCombatProf(Value.ProfID) and Value.Level > MaxLevel then
                    MaxLevel = Value.Level
                end
            end
        end
    end
    return MaxLevel
end

function MainPanelView:OnOpenPlatformWelfare()
  local U2pmMgr = _G.U2.U2pmMgr
  if U2pmMgr ~= nil then -- export module
    U2pmMgr:ScanFullSource()
  else
    ChatMgr:AddSysChatMsg("Mising U2pmMgr module")
  end
end

-- 临时功能，方便看网络延迟 不考虑多语言和性能
function MainPanelView:UpdateRTT()
	local Value = _G.NetworkRTTMgr:GetSRTT()
	if Value <= 100 then
		--UIUtil.TextBlockSetColorAndOpacityHex(self.TextTime, "#89bd88ff")
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextTime2, "#89bd88ff")
	elseif Value <= 200 then
		--UIUtil.TextBlockSetColorAndOpacityHex(self.TextTime, "#d1906dff")
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextTime2, "#d1906dff")
	else
		--UIUtil.TextBlockSetColorAndOpacityHex(self.TextTime, "#dc5868ff")
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextTime2, "#dc5868ff")
	end

	local Text = string.format("%dms", Value);
	--self.TextTime:SetText(Text)
	self.TextTime2:SetText(Text)
end

function MainPanelView:OnIsEnmityPanelVisibleChanged(Value)
	UIUtil.SetIsVisible(self.HatredPanel, Value and _G.PWorldMgr:CurrIsInDungeon())  -- 副本内才显示仇恨列表
end

function MainPanelView:OnPWorldWarningDuring(Params)
	local AttrComp = MajorUtil.GetMajorAttributeComponent()
	---_G.FLOG_INFO("kof PWorldStagePanelView:OnPWorldWarningDuring")


	if AttrComp ~= nil then
		local EarlyWarningItems = PWorldWarringMgr:GetWarningItems(AttrComp:GetClassType())
		if #EarlyWarningItems == 0 then
			self:OnPWorldWarningEnd()
		else
			self.TableViewSkillCD:SetVisibility(_G.UE.ESlateVisibility.Visible)

			local ServerTime = TimeUtil.GetServerTimeMS()
			local StartTime = PWorldWarringMgr:GetStartTime()
			local ShowEarlyWaringItems = {}

			for _,WarningItem in pairs(EarlyWarningItems) do
				local fRemainTime = (StartTime + (WarningItem.StartTime + WarningItem.LastTime) * 1000 - ServerTime) / 1000.0
				fRemainTime = (fRemainTime - fRemainTime%0.1)
				local fPercent = fRemainTime / WarningItem.LastTime
				table.insert(ShowEarlyWaringItems,{IconID=WarningItem.Param,Percent=fPercent,RemainTime=fRemainTime,Name=WarningItem.Name,MultilingualID=WarningItem.MultilingualID})
			end
			MainPanelVM:UpdateWaringItems(ShowEarlyWaringItems)
			for _,v in pairs(ShowEarlyWaringItems) do
				local WarningSkillCDItemVM = MainPanelVM.WarningSkillCDItemList:Get(_)
				if WarningSkillCDItemVM ~= nil then
					WarningSkillCDItemVM:UpdateVM(v)
				end
			end
		end
	end
end

function MainPanelView:OnPWorldWarningEnd(Params)
	MainPanelVM:Clear()
	self.TableViewSkillCD:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
end

return MainPanelView
