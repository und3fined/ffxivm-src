---
--- Author: Administrator
--- DateTime: 2024-01-25 17:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PhotoDefine = require("Game/Photo/PhotoDefine")

local FVector2D = _G.UE.FVector2D

local PhotoMainUITabCfg = require("Game/Photo/Define/PhotoMainUITabCfg")
local UITabMainDef = PhotoDefine.UITabMain
local UITabSubDef = PhotoDefine.UITabSub
local CommonUtil = require("Utils/CommonUtil")
local PhotoActionItemVM = require("Game/Photo/VM/Item/PhotoActionItemVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")


local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")

local PhotoResetFunc = require("Game/Photo/Util/PhotoResetFunc")
local MajorUtil = require("Utils/MajorUtil")
local PhotoGiveAllFunc = require("Game/Photo/Util/PhotoGiveAllFunc")
local PhotoMediaUtil = require("Game/Photo/Util/PhotoMediaUtil")
local ActorUtil = require("Utils/ActorUtil")

local EventID
local EventMgr
local PhotoMgr
local UIViewMgr
local FVector2D = _G.UE.FVector2D
local PhotoVM
local PhotoCamVM
local PhotoFilterVM
local PhotoRoleSettingVM
local PhotoSceneVM
local PhotoTemplateVM
local PhotoActionVM
local PhotoEmojiVM
local PhotoRoleStatVM

local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetRenderTransformAngle = require("Binder/UIBinderSetRenderTransformAngle")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local AxisDef = {
	Up 		= 1,
	Down 	= 2,
	Left 	= 3,
	Right 	= 4,
}


---@class PhotoMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnDofDebug UButton
---@field BtnDown UFButton
---@field BtnLeft UFButton
---@field BtnReset UFButton
---@field BtnRight UFButton
---@field BtnTakePhoto UFButton
---@field BtnUp UFButton
---@field DOFDebug UFCanvasPanel
---@field DisOffInput CommInputBoxView
---@field PanelAssistLine UFCanvasPanel
---@field PanelContent UFCanvasPanel
---@field PanelExpand UFCanvasPanel
---@field PanelMove UFCanvasPanel
---@field PanelRight UFCanvasPanel
---@field PanelSelect01 UFCanvasPanel
---@field PanelSelect02 UFCanvasPanel
---@field PanelSelect03 UFCanvasPanel
---@field PanelSelect04 UFCanvasPanel
---@field PanelTab UFCanvasPanel
---@field PanelTabArrow UFCanvasPanel
---@field RegionInput CommInputBoxView
---@field TableViewPages UTableView
---@field TextSubtitle UFTextBlock
---@field TextTitleName UFTextBlock
---@field TogAllAct UToggleButton
---@field TogEye UToggleButton
---@field TogFace UToggleButton
---@field TogLineShow UToggleButton
---@field TogMovable UToggleButton
---@field TogPause UToggleButton
---@field TogRight3 UFHorizontalBox
---@field TogSelfAct UToggleButton
---@field TogSyncAll UToggleButton
---@field TogUIShow UToggleButton
---@field TogWeather UToggleButton
---@field ToggleButtonMove UToggleButton
---@field VerIconTabs CommVerIconTabsView
---@field AnimBtnMove UWidgetAnimation
---@field AnimExpandInOut UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoMainView = LuaClass(UIView, true)

function PhotoMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnDofDebug = nil
	--self.BtnDown = nil
	--self.BtnLeft = nil
	--self.BtnReset = nil
	--self.BtnRight = nil
	--self.BtnTakePhoto = nil
	--self.BtnUp = nil
	--self.DOFDebug = nil
	--self.DisOffInput = nil
	--self.PanelAssistLine = nil
	--self.PanelContent = nil
	--self.PanelExpand = nil
	--self.PanelMove = nil
	--self.PanelRight = nil
	--self.PanelSelect01 = nil
	--self.PanelSelect02 = nil
	--self.PanelSelect03 = nil
	--self.PanelSelect04 = nil
	--self.PanelTab = nil
	--self.PanelTabArrow = nil
	--self.RegionInput = nil
	--self.TableViewPages = nil
	--self.TextSubtitle = nil
	--self.TextTitleName = nil
	--self.TogAllAct = nil
	--self.TogEye = nil
	--self.TogFace = nil
	--self.TogLineShow = nil
	--self.TogMovable = nil
	--self.TogPause = nil
	--self.TogRight3 = nil
	--self.TogSelfAct = nil
	--self.TogSyncAll = nil
	--self.TogUIShow = nil
	--self.TogWeather = nil
	--self.ToggleButtonMove = nil
	--self.VerIconTabs = nil
	--self.AnimBtnMove = nil
	--self.AnimExpandInOut = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.DisOffInput)
	self:AddSubView(self.RegionInput)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoMainView:OnInit()
	self.AdpSubTab 				= UIAdapterTableView.CreateAdapter(self, self.TableViewPages, self.OnAdpItemSubTab)

	self.IndicatorIcon = {
		self.PanelSelect01,
		self.PanelSelect02,
		self.PanelSelect03,
		self.PanelSelect04,
	}

	self:InitExtern()
	self:InitUITab()
	-- self:InitMoveAxis()
	self:InitBinder()

	self:InitStickTouchItem()
end

function PhotoMainView:InitExtern()
	PhotoVM 				= _G.PhotoVM
	PhotoCamVM 				= _G.PhotoCamVM
	PhotoFilterVM 			= _G.PhotoFilterVM
	PhotoRoleSettingVM 		= _G.PhotoRoleSettingVM
	PhotoSceneVM 			= _G.PhotoSceneVM
	PhotoTemplateVM 		= _G.PhotoTemplateVM
	PhotoActionVM			= _G.PhotoActionVM
	PhotoRoleStatVM			= _G.PhotoRoleStatVM
	PhotoMgr				= _G.PhotoMgr
    UIViewMgr 				= _G.UIViewMgr
	EventMgr 				= _G.EventMgr
	EventID					= _G.EventID
end

function PhotoMainView:InitUITab()

	for Idx, Item in pairs(PhotoMainUITabCfg) do
		Item.CB = self.Set2ndTab
		Item.Params = Idx
	end

	-- self.SubTabAnim = {
	-- 	[UITabMainDef.Camera] = {
	-- 		[UITabSubDef[UITabMainDef.Camera].DOF]     = self.AnimPhotoSetUp,
	-- 		[UITabSubDef[UITabMainDef.Camera].FOV]     = self.AnimPhotoSetUp,
	-- 		[UITabSubDef[UITabMainDef.Camera].Rot]     = self.AnimPhotoSetUp,
	-- 	},

	-- 	[UITabMainDef.Role] = {
	-- 	 	[UITabSubDef[UITabMainDef.Role].Act]     	= self.AnimAction,
	-- 	 	[UITabSubDef[UITabMainDef.Role].Emo]     	= self.AnimEmoji,
	-- 	-- 	[UITabSubDef[UITabMainDef.Role].Act]     	= self.PanelAction,
	-- 	-- 	[UITabSubDef[UITabMainDef.Role].Emo]     	= self.PanelAction,
	-- 		[UITabSubDef[UITabMainDef.Role].Stat]     	= self.AnimState,
	-- 		[UITabSubDef[UITabMainDef.Role].Setting]    = self.AnimRole,

	-- 	 },

	-- 	[UITabMainDef.Eff] = {
	-- 		[UITabSubDef[UITabMainDef.Eff].Filer]     	= self.AnimFilter,
	-- 		[UITabSubDef[UITabMainDef.Eff].DarkFrame]   = self.AnimSpecialEffects,
	-- 		[UITabSubDef[UITabMainDef.Eff].Scene]     	= self.AnimTimeWeather,
	-- 	},

	-- 	[UITabMainDef.Mod] = {
	-- 		-- [UITabSubDef[UITabMainDef.Mod].Mod]     	= self.OnSubViewShowTemplate,
	-- 	},
	-- }

	local UIID = _G.UIViewID

	self.UITabSubView = {
		[UITabMainDef.Camera] = {
			[UITabSubDef[UITabMainDef.Camera].DOF]     = UIID.PhotoSetupPanel,
			[UITabSubDef[UITabMainDef.Camera].FOV]     = UIID.PhotoSetupPanel,
			[UITabSubDef[UITabMainDef.Camera].Rot]     = UIID.PhotoSetupPanel,
		},

		[UITabMainDef.Role] = {
			[UITabSubDef[UITabMainDef.Role].Act]     	= UIID.PhotoActionPanel,
			[UITabSubDef[UITabMainDef.Role].Emo]     	= UIID.PhotoEmojiPaenl,
			[UITabSubDef[UITabMainDef.Role].Stat]     	= UIID.PhotoStatePanel,
			[UITabSubDef[UITabMainDef.Role].Setting]    = UIID.PhotoRolePanel,
		},

		[UITabMainDef.Eff] = {
			[UITabSubDef[UITabMainDef.Eff].Filer]     	= UIID.PhotoFilterPanel,
			[UITabSubDef[UITabMainDef.Eff].DarkFrame]   = UIID.PhotoEffectPanel,
			[UITabSubDef[UITabMainDef.Eff].Scene]     	= UIID.PhotoWeatherPanel,
		},

		[UITabMainDef.Mod] = {
			[UITabSubDef[UITabMainDef.Mod].Mod]     	= UIID.PhotoTemplatePanel,
		},
	}

	self.LastSubView = nil
end

function PhotoMainView:InitMoveAxis()
	local View = self
	self.MoveComp = {
		View = View,

		[AxisDef.Up] = {
			X = 0,
			Y = 1,
			Widget = View.BtnUp,
		},

		[AxisDef.Down] = {
			X = 0,
			Y = -1,
			Widget = View.BtnDown,
		},

		[AxisDef.Left] = {
			X = -1,
			Y = 0,
			Widget = View.BtnLeft,
		},

		[AxisDef.Right] = {
			X = 1,
			Y = 0,
			Widget = View.BtnRight,
		},

		RegUIEvent = function(Comp)
			for _, Idx in pairs(AxisDef) do
				local Property = Comp[Idx]
				UIUtil.AddOnClickedEvent(Comp.View, Property.Widget, function(_, Tog, Stat)
					Comp:OnBtn(Idx)
				end)

				UIUtil.AddOnLongClickedEvent(Comp.View, Property.Widget, function()
					Comp:OnBtnLongStart(Idx)
				end)

				UIUtil.AddOnLongClickReleasedEvent(Comp.View, Property.Widget, function()
					Comp:OnBtnLongEnd(Idx)
				end)
    			-- UIUtil.AddOnLongClickReleasedEvent(self, self.BtnSprint, self.OnLongClickReleasedBtnSprint)
			end
		end,
		
		OnBtn = function(Comp, Def)
			local Property = Comp[Def]
			-- move offset
			if Property then
				PhotoCamVM:AddOffXY(Property.X, Property.Y)
			end

			-- check stat
			for _, Idx in pairs(AxisDef) do
				if Idx ~= Def then
					local Btn = Comp[Idx].Widget
				end
			end
		end,

		OnBtnLongStart = function(Comp, Def)
			-- print('Andre.OnBtnLongStart')
			local Property = Comp[Def]
			-- move offset
			if Property then
				Comp.View:StartMoveTimer(Property.X, Property.Y)
			end
		end,

		OnBtnLongEnd = function(Comp, Def)
			-- print('Andre.OnBtnLongStart')
			local Property = Comp[Def]
			-- move offset
			if Property then
				Comp.View:EndMoveTimer()
			end
		end,

		Reset = function(Comp)
			for _, Idx in pairs(AxisDef) do
				local Btn = Comp[Idx].Widget
				-- Btn:SetChecked(false)
			end
		end
	}
end

function PhotoMainView:InitStickTouchItem()
	self.StickItem.View = self
	self.StickItem.TouchStartCB = self.OnTouchStickStart
	self.StickItem.TouchMoveCB = self.OnTouchStickMove
	self.StickItem.TouchEndCB = self.OnTouchStickEnd

	self.StickOriPos = UIUtil.CanvasSlotGetPosition(self.StickPt)

	-- self:LogPos("InitStickTouchItem", self.StickOriPos)
end

function PhotoMainView:LogPos(Key, Pos)
	if not Pos then
		return
	end

	-- print(string.format('testinfo LogPos %s Pos X = %s, Y = %s', tostring(Key), tostring(Pos.X), tostring(Pos.Y)))
end

local STICK_IMG_NM = "PaperSprite'/Game/UI/Atlas/Photo/Frames/UI_Photo_Btn_Move01_png.UI_Photo_Btn_Move01_png'"
local STICK_IMG_HL = "PaperSprite'/Game/UI/Atlas/Photo/Frames/UI_Photo_Btn_Move02_png.UI_Photo_Btn_Move02_png'"


function PhotoMainView:OnMoveCamera(IsMove)
	if self.IsCameraMoving == IsMove then
		return
	end

	self.IsCameraMoving = IsMove

	UIUtil.SetIsVisible(self.PanelContent, not IsMove)
	UIUtil.SetIsVisible(self.TogRight3, not IsMove)

	if IsMove then
		UIViewMgr:HideView(self.LastSubView)
		if not PhotoVM.IsBanMove then
			CommonUtil.HideJoyStick()
        	CommonUtil.DisableShowJoyStick(true)
		end
	else
		UIViewMgr:ShowView(self.LastSubView)
		if not PhotoVM.IsBanMove then
			CommonUtil.DisableShowJoyStick(false)
			CommonUtil.ShowJoyStick()
		end
	end
end

function PhotoMainView:OnTouchStickStart(Pos)
	self.StickStartPos = Pos
	UIUtil.ImageSetBrushFromAssetPath(self.StickPt, STICK_IMG_HL)
	-- self:LogPos("OnTouchStickStart", Pos)
	-- UIUtil.SetIsVisible(self.ImgRotateLight, true)
	-- _G.FLOG_INFO('Andre.PhotoMainView:OnTouchStart X = ' .. tostring(Pos.X) .. " Y = " .. tostring(Pos.Y))
end

local StickR = 80
function PhotoMainView:OnTouchStickMove(Pos)
	-- 防断触
	self:OnMoveCamera(true)

	self.StickCurPos = Pos

	local DV = self.StickCurPos - self.StickStartPos
	local NDV = DV

	local IsOut = false
	if FVector2D.Size(NDV) > StickR then
		-- NDV = _G.UE.FVector.Normalize(DV)
		FVector2D.Normalize(NDV)
		NDV = NDV * StickR
		IsOut = true
	end

	local NewPtPos = self.StickOriPos + NDV

	local N = FVector2D(NDV.X, NDV.Y)
	
	FVector2D.Normalize(N)

	if IsOut then
		if not self.TickMoveVec then
			self:StartMoveTimer()
		end
		self.TickMoveVec = N
	else
		self.TickMoveVec = nil
		self:EndMoveTimer()
	end

	-- PhotoCamVM:AddOffXY(0, 1)
	if not self.TickMoveVec then
		PhotoCamVM:AddOffXY(N.X, -N.Y)
	end
	UIUtil.CanvasSlotSetPosition(self.StickPt, NewPtPos)

	-- self:LogPos("OnTouchStickMove", Pos)
	-- self:LogPos("OnTouchStickMove DV", DV)
	-- self:LogPos("OnTouchStickMove NDV", NDV)
	-- self:LogPos("OnTouchStickMove N", N)

end

function PhotoMainView:OnTouchStickEnd(Pos)
	UIUtil.ImageSetBrushFromAssetPath(self.StickPt, STICK_IMG_NM)
	UIUtil.CanvasSlotSetPosition(self.StickPt, self.StickOriPos)
	self:OnMoveCamera(false)
	self.TickMoveVec = nil
end

function PhotoMainView:InitBinder()
	self.Binder = 
	{
		{ "SubTabIdx", 			UIBinderValueChangedCallback.New(self, nil, self.OnBindTabSubIdx) },
		{ "MainTabIdx", 		UIBinderValueChangedCallback.New(self, nil, self.OnBindMainTabIdx) },
		{ "SubTitle", 			UIBinderSetText.New(self, self.TextSubtitle) },
		---
		{ "SubTabList",  		UIBinderUpdateBindableList.New(self, self.AdpSubTab) },
		{ "SubTabIdx",          UIBinderSetSelectedIndex.New(self, self.AdpSubTab)},
		--- Move Mode
		{ "IsShowLP", 			UIBinderSetIsVisible.New(self, self.PanelTab) },
		{ "IsShowRP", 			UIBinderSetIsVisible.New(self, self.PanelRight) },
		{ "IsInMoveMode", 		UIBinderSetIsVisible.New(self, self.PanelMove) },
		{ "IsInMoveMode", 		UIBinderSetIsChecked.New(self, self.ToggleButtonMove) },
		-- Hide All 
		{ "IsHideContent", 		UIBinderSetIsVisible.New(self, self.PanelContent, true) },
		{ "IsHideContent", 		UIBinderSetIsVisible.New(self, self.BtnShowUI, false, true) },
		{ "IsHideContent", 		UIBinderSetIsVisible.New(self, self.TogRight3, true) },
		{ "IsHideContent", 		UIBinderSetIsVisible.New(self, self.PanelTakePhoto, true) },
		
		{ "IsHideContent", 		UIBinderSetIsChecked.New(self, self.TogUIShow) },
		{ "IsHideContent", 		UIBinderValueChangedCallback.New(self, nil, self.OnBindHideContent) },
		--- 
		{ "IsFollowWithFace", UIBinderValueChangedCallback.New(self, nil, self.OnBindLookatValueChg) },
		{ "IsFollowWithFace", UIBinderValueChangedCallback.New(self, nil, self.OnBindLookatValueChg) },

		{ "IsFollowWithFace", UIBinderSetIsChecked.New(self, self.TogFace) },
		{ "IsFollowWithEye", UIBinderSetIsChecked.New(self, self.TogEye) },
		{ "IsShowCheckerboard", UIBinderSetIsChecked.New(self, self.TogLineShow) },
		{ "IsShowCheckerboard", UIBinderSetIsVisible.New(self, self.PanelAssistLine) },
		--- 
		{ "IsBanMove", 			UIBinderSetIsChecked.New(self, self.TogMovable, nil, nil) },
		--- Pause
		{ "IsShowPausePanel", 	UIBinderSetIsChecked.New(self, self.TogPause) },
		{ "IsShowPausePanel", 	UIBinderSetIsVisible.New(self, self.PanelExpand) },
		{ "IsPauseSelect", 		UIBinderSetIsChecked.New(self, self.TogSelfAct) },
		{ "IsPauseAll", 		UIBinderSetIsChecked.New(self, self.TogAllAct) },
		{ "IsPauseWeather", 	UIBinderSetIsChecked.New(self, self.TogWeather) },
		--- 
		{ "IsGiveAll", 			UIBinderSetIsChecked.New(self, self.TogSyncAll) },
	}
end

function PhotoMainView:OnBindLookatValueChg()
	self:RefreshCharacterLookAt()
end

function PhotoMainView:OnDestroy()

end

function PhotoMainView:OnShow()
	self:UpdUITab()

	PhotoRoleStatVM:UpdateVM()
	PhotoVM:UpdateVM()
	PhotoFilterVM:UpdateVM()
	PhotoRoleSettingVM:UpdateVM()
	PhotoCamVM:UpdateVM()
	PhotoActionVM:UpdateVM()

	_G.PhotoEmojiVM:UpdateVM()
	_G.PhotoDarkEdgeVM:ResetEdge()

	PhotoSceneVM:UpdateVM()
	PhotoSceneVM:ResetWeatherAndTime2Now()
	PhotoTemplateVM:Clear()

	self:RefreshCharacterLookAt()

	UIUtil.SetIsVisible(self.DOFDebug, false)

	-- UIUtil.SetIsVisible(self.FSafeZone, true)
	-- _G.UIViewMgr:ShowView(_G.UIViewID.PhotoSetupPanel)

	UIUtil.SetIsVisible(self.TogAllAct, false)
	UIUtil.SetIsVisible(self.TogSyncAll, false)
end

function PhotoMainView:OnHide()
	self:EndMoveTimer()
	_G.PhotoRoleSettingVM:ResetMajorAngleIdx()

	if self.LastSubView then
		UIViewMgr:HideView(self.LastSubView)
		self.LastSubView = nil
	end

    _G.PhotoMgr:PostClosePhotoUI()
end

function PhotoMainView:OnRegisterUIEvent()
	-- self.MoveComp:RegUIEvent()

	UIUtil.AddOnSelectionChangedEvent(self, 	self.VerIconTabs, 			self.OnTabChg)
	UIUtil.AddOnClickedEvent(self,              self.BtnClose.Btn_Close,    self.OnBtnClose)
	
	-- top right bar
	UIUtil.AddOnStateChangedEvent(self, 		self.TogFace, 				self.OnTogFace)
	UIUtil.AddOnStateChangedEvent(self, 		self.TogEye, 				self.OnTogEye)
	UIUtil.AddOnStateChangedEvent(self, 		self.TogLineShow, 			self.OnTogLineShow)
	UIUtil.AddOnStateChangedEvent(self, 		self.TogUIShow, 			self.OnTogUIShow)

	-- -- down right bar
	-- -- UIUtil.AddOnStateChangedEvent(self, 		self.TogSyncAll, 			self.OnTogSyncAll)
	UIUtil.AddOnStateChangedEvent(self, 		self.TogPause, 				self.OnTogPause)
	UIUtil.AddOnStateChangedEvent(self, 		self.TogSelfAct, 			self.OnTogPauseSelt)
	UIUtil.AddOnStateChangedEvent(self, 		self.TogAllAct, 			self.OnTogPauseAll)
	UIUtil.AddOnStateChangedEvent(self, 		self.TogWeather, 			self.OnTogPauseWeather)
	UIUtil.AddOnStateChangedEvent(self, 		self.TogMovable, 			self.OnTogMovable)
	UIUtil.AddOnStateChangedEvent(self,         self.TogSyncAll,    		self.OnTogGiveAll)
	UIUtil.AddOnClickedEvent(self,              self.BtnReset,    			self.OnBtnReset)
	
	UIUtil.AddOnClickedEvent(self,              self.BtnShowUI,    			self.OnBtnShowUI)

	-- take picture
	UIUtil.AddOnClickedEvent(self,              self.BtnTakePhoto,    		self.OnBtnTakePicture)

	UIUtil.AddOnClickedEvent(self,              self.BtnLensRefresh,    		self.OnBtnResetCameraPos)

	-- -- move mode
	UIUtil.AddOnStateChangedEvent(self, 		self.ToggleButtonMove, 		self.OnTogMoveMode)
end

function PhotoMainView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MajorFirstMove,              self.OnEveMajorMove)
	self:RegisterGameEvent(_G.EventID.InputFirstMove, 							self.OnEveInputFirstMove)
    self:RegisterGameEvent(_G.EventID.ActorVelocityUpdate, 			self.OnEveActorMove)
end

function PhotoMainView:OnEveInputFirstMove()
	_G.PhotoRoleStatVM:TryRptStat()
end

function PhotoMainView:OnEveMajorMove()
	_G.PhotoActionVM:ResetRoleActAni()
    _G.PhotoEmojiVM:ResetRoleActAni()
end

function PhotoMainView:OnEveActorMove(Params)
	local EntID = Params.ULongParam1

    -- todo 暂时先屏蔽掉非选中单位,后面会专门处理角色的状态
    if not EntID or EntID ~= PhotoMgr.SeltEntID then
        return
    end

	local IsMoveStart = not Params.BoolParam1 --bNowVelocityZero

	if EntID and IsMoveStart then
		local AnimComp = ActorUtil.GetActorAnimationComponent(EntID)
		if AnimComp then
			PhotoMgr:StopRoleAllAnim(AnimComp)
		end
	end
end

function PhotoMainView:OnRegisterBinder()
	self:RegisterBinders(PhotoVM, 				self.Binder)
end

-------------------------------------------------------------------------------------------------------
---@region Logic

---@group UITab

function PhotoMainView:UpdUITab()
	self.VerIconTabs:UpdateItems(PhotoMainUITabCfg, 1)
end

---@group 2nd Tab
function PhotoMainView:Set2ndTab(Params)
	_G.FLOG_INFO('[Photo][PhotoMainView][Set2ndTab] Params = ' .. tostring(Params))
	PhotoVM:SetMainTabIdx(Params)
	self:SetSubPanel(1)
end

function PhotoMainView:SetSubPanel(Idx)
	_G.FLOG_INFO('[Photo][PhotoMainView][SetSubPanel] Idx = ' .. tostring(Idx))
	PhotoVM:SetSubTabIdx(Idx)
end

-------------------------------------------------------------------------------------------------------
---@region UIEveHandle

-- local ClickTimeMap = {}
-- local ClickInv = 5

-- function PhotoMainView:CheckClick(Key)
-- 	if ClickTimeMap[Key] then
--         local Now = TimeUtil.GetLocalTime()
--         if Now - ClickTimeMap[Key] <= ClickInv then
--     		-- MsgTipsUtil.ShowTips(Content)
--             return false
--         end
--     end

--     ClickTimeMap[Key] = TimeUtil.GetLocalTime()
-- 	return true
-- end

function PhotoMainView:OnTabChg(Idx)
	local Item = PhotoMainUITabCfg[Idx]
	if Item and Item.CB then
		Item.CB(self, Item.Params)
	end
end

function PhotoMainView:OnBtnClose()
	_G.PhotoMgr:ClosePhotoUI()
end

function PhotoMainView:OnAdpItemSubTab(Idx, ItemVM)
	self:SetSubPanel(Idx)
end

function PhotoMainView:OnTogFace(Tog, Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	PhotoVM.IsFollowWithFace = IsChecked

	self:RefreshCharacterLookAt()

	MsgTipsUtil.ShowTips(PhotoVM.IsFollowWithFace and _G.LSTR(630036) or _G.LSTR(630004))
end

function PhotoMainView:OnTogEye(Tog, Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	PhotoVM.IsFollowWithEye = IsChecked
	self:RefreshCharacterLookAt()

	MsgTipsUtil.ShowTips(PhotoVM.IsFollowWithEye and _G.LSTR(630023) or _G.LSTR(630003))
end

function PhotoMainView:OnTogLineShow(Tog, Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	PhotoVM.IsShowCheckerboard = IsChecked

	if PhotoVM.IsShowCheckerboard then
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.ShowAuxLine, nil)
	else
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.HideAuxLine, nil)
	end
end

function PhotoMainView:OnTogUIShow(Tog, Stat)
	-- local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	PhotoVM:SetIsHideContent(IsChecked)

	if PhotoVM.IsHideContent then
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.HideView, nil)
	else
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.ShowView, nil)
	end
end

function PhotoMainView:OnTogGiveAll(Tog, Stat)
	-- _G.FLOG_INFO("Andre.PhotoMainView.OnBtnReset")
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)

	PhotoVM.IsGiveAll = IsChecked

	if PhotoVM.IsGiveAll then
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.EnableGiveAll, nil)
	else
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.DisableGiveAll, nil)
	end

	PhotoGiveAllFunc.CallGiveAllFuncAuto()
end

function PhotoMainView:OnTogPause(Tog, Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	local IsOpen = IsChecked
	if IsOpen then
		self:PlayAnimation(self.AnimExpandInOut)
	end
	PhotoVM.IsShowPausePanel = IsOpen
end

function PhotoMainView:OnTogPauseSelt(Tog, Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	PhotoVM:SetIsPauseSelect(IsChecked)

	PhotoActionVM:SetAmimIsPause(IsChecked)

	if PhotoVM.IsPauseSelect then
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.SelfPause, nil)
	else
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.SelfResume, nil)
	end
end

function PhotoMainView:OnTogPauseAll(Tog, Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	PhotoVM:SetIsPauseAll(IsChecked)


	if PhotoVM.IsPauseAll then
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.AllActorPause, nil)
	else
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.AllActorResume, nil)
	end
end

function PhotoMainView:OnTogPauseWeather(Tog, Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	PhotoVM:SetIsPauseWeather(IsChecked)

	if not PhotoVM.IsPauseWeather then
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.WeatherResume, nil)
	else
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.WeatherPause, nil)
	end
end

function PhotoMainView:OnTogMovable(Tog, Stat)
	-- if (PhotoVM.IsPauseSelect or PhotoVM.IsPauseAll) and (PhotoVM.IsBanMove) then
	-- 	return
	-- end

	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)

	PhotoVM:SetIsBanMove(IsChecked)

	if not IsChecked then
		PhotoVM:SetIsPauseSelect(IsChecked)
	end

	-- PhotoVM:SetIsPauseAll(not IsChecked)
	-- PhotoVM:SetIsPauseSelect(not IsChecked)

	if PhotoVM.IsBanMove then
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.MoveLock, nil)
	else
		MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.MoveUnlock, nil)
	end
end

function PhotoMainView:OnBtnResetCameraPos()
	MsgTipsUtil.ShowTips(_G.LSTR(630043))
	PhotoMgr:ResumeCameraPos()
	PhotoMgr:SetMajorLookCamera()
	PhotoCamVM:Reset2Default()
end

function PhotoMainView:OnBtnReset()
	-- _G.FLOG_INFO("Andre.PhotoMainView.OnBtnReset")
	local MainTy = PhotoVM.MainTabIdx
	local SubTy = PhotoVM.SubTabIdx
	PhotoResetFunc.CallResetFunc(MainTy, SubTy)

	MsgTipsUtil.ShowTipsByID(PhotoDefine.PhotoTipsID.ChangesUndo, nil)
end

function PhotoMainView:OnBtnTakePicture()
	PhotoMgr:TakePhoto()
end

function PhotoMainView:OnBtnShowUI()
	PhotoVM:SetIsHideContent(false)
	-- PhotoMediaUtil.TakePicture()
end

function PhotoMainView:OnTogMoveMode(Tog, Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)

	local IsOpen = IsChecked
	if IsOpen then
		self:PlayAnimation(self.AnimBtnMove)
	end

	PhotoVM:SetIsInMoveMode(IsOpen)
	-- self.MoveComp:Reset()
end

----------

function PhotoMainView:RefreshCharacterLookAt()
	PhotoMgr:RefreshCharacterLookAt()
end

-------------------------------------------------------------------------------------------------------
---@region UIBindHdl

function PhotoMainView:OnBindHideContent(Val)
	_G.EventMgr:SendEvent(_G.EventID.PhotoViewHideDetailView, Val)

	if not self.LastSubView then
		return
	end

	if Val then
		UIViewMgr:HideView(self.LastSubView)
	else
		UIViewMgr:ShowView(self.LastSubView)
	end
end

function PhotoMainView:OnBindMainTabIdx()
	self:UpdSubViewShow()
	
	local IsSingle = PhotoVM.MainTabIdx == UITabMainDef.Mod
	UIUtil.SetIsVisible(self.TableViewPages, not IsSingle)
	-- UIUtil.SetIsVisible(self.PanelTabArrow, not IsSingle)

	-- update indicator icon
	for Idx, Icon in pairs(self.IndicatorIcon) do
		UIUtil.SetIsVisible(Icon, MainIdx == Idx)
	end
end

function PhotoMainView:OnBindTabSubIdx()
	self:UpdSubViewShow()

	-- local MainIdx = PhotoVM.MainTabIdx
	-- local SubIdx = PhotoVM.SubTabIdx

	-- UIUtil.SetIsVisible(self.PanelSelect01, MainIdx == PhotoDefine.UITabMain.Camera)
	-- UIUtil.SetIsVisible(self.PanelSelect02, MainIdx == PhotoDefine.UITabMain.Role)
	-- UIUtil.SetIsVisible(self.PanelSelect03, MainIdx == PhotoDefine.UITabMain.Eff)
	-- UIUtil.SetIsVisible(self.PanelSelect04, MainIdx == PhotoDefine.UITabMain.Mod)

	_G.FLOG_INFO(string.format("[Photo][PhotoMainView][OnBindTabSubIdx] MainIdx = %s, SubIdx = %s", 
		tostring(MainIdx),
		tostring(SubIdx)
	))
	-- play anim
	-- if self.SubTabAnim[MainIdx] and self.SubTabAnim[MainIdx][SubIdx] then
	-- 	local Anim = self.SubTabAnim[MainIdx][SubIdx]
	-- 	self:PlayAnimation(Anim)
	-- end
end

function PhotoMainView:UpdSubViewShow()
	local MainIdx = PhotoVM.MainTabIdx
	local SubIdx = PhotoVM.SubTabIdx

	if not SubIdx then
		return
	end

	if self.UITabSubView[MainIdx] then
		local View = self.UITabSubView[MainIdx][SubIdx]
		if View then
			if self.LastSubView then
				if self.LastSubView ~= View then
					UIViewMgr:HideView(self.LastSubView)
				end
			end

			UIViewMgr:ShowView(View)
			self.LastSubView = View
		else
			_G.FLOG_ERROR('[Photo][PhotoMainView][UpdSubViewShow] MainIdx is Invalid')
		end
	end
end

-------------------------------------------------------------------------------------------------------
---@region CameraMove

function PhotoMainView:EndMoveTimer()
	if self.CamMoveHdl then
		self:UnRegisterTimer(self.CamMoveHdl)
	end
end

function PhotoMainView:StartMoveTimer()
	self:EndMoveTimer()
	local OnTimer = function()
		if self.TickMoveVec then
			PhotoCamVM:AddOffXY(self.TickMoveVec.X, -self.TickMoveVec.Y)
		end
	end

	self.CamMoveHdl = self:RegisterTimer(OnTimer, 0, 0.01, 0)
end

return PhotoMainView