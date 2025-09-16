---
--- Author: sammrli
--- DateTime: 2023-09-14 11:45
--- Description:金蝶游乐场主界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GateMainVM = require("Game/Gate/View/VM/GateMainVM")
local EventID = require("Define/EventID")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")
local UIViewID = require("Define/UIViewID")
local GameplayStaticsUtil = require("Utils/GameplayStaticsUtil")
local AudioUtil = require("Utils/AudioUtil")

local LSTR = _G.LSTR
local UE = _G.UE

---@class GateMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Aiming GateAimingItemView
---@field BtnQuit CommonCloseBtnView
---@field BtnScene UFButton
---@field CountDown GateCountDownItemView
---@field Gate UFCanvasPanel
---@field ImgPanelLampShoot UFImage
---@field ImgScene UFImage
---@field MarkView UTableView
---@field Score GatePointItemView
---@field ScoreView_1 UTableView
---@field AnimIn UWidgetAnimation
---@field AnimMainLoop UWidgetAnimation
---@field AnimScoreAdd UWidgetAnimation
---@field AnimScoreSubtract UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GateMainPanelView = LuaClass(UIView, true)

function GateMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Aiming = nil
	--self.BtnQuit = nil
	--self.BtnScene = nil
	--self.CountDown = nil
	--self.Gate = nil
	--self.ImgPanelLampShoot = nil
	--self.ImgScene = nil
	--self.MarkView = nil
	--self.Score = nil
	--self.ScoreView_1 = nil
	--self.AnimIn = nil
	--self.AnimMainLoop = nil
	--self.AnimScoreAdd = nil
	--self.AnimScoreSubtract = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.IsShow = false
end

function GateMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Aiming)
	self:AddSubView(self.BtnQuit)
	self:AddSubView(self.CountDown)
	self:AddSubView(self.Score)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GateMainPanelView:OnInit()
	self.AdapterScoreLeft = UIAdapterTableView.CreateAdapter(self, self.MarkView)
	self.AdapterScoreBottom = UIAdapterTableView.CreateAdapter(self, self.ScoreView_1)
end

function GateMainPanelView:OnDestroy()

end

function GateMainPanelView:OnShow()
	self:PlayAnimation(self.AnimIn)
	if self.TimerID then
		self:UnRegisterTimer(self.TimerID)
	end
	self.TimerID = self:RegisterTimer( self.OnFadeInFinish, 1.0)

	self.IsShow = true
	GateMainVM:ResetData()

	UIUtil.SetIsVisible(self.BtnQuit, true, true)
	UIUtil.SetIsVisible(self.Gate, true)
end

function GateMainPanelView:OnFadeInFinish()
	if self.IsShow then
		_G.GoldSauserMgr:ShowGoldSauserOpportunityForBegin(
			function()

                -- 机遇临门通用的新手引导
                _G.GoldSauserMgr:ShowOpportunityNewTutorial()
                -- 通用结束
			end
		)
	end
	self.TimerID = self:RegisterTimer(self.OnGameStart, 5.0)
end

function GateMainPanelView:OnGameStart()
	_G.RideShootingMgr:OnGameStart()
	GateMainVM:SetGameRunning(true)
	self.TimerID = nil
end

function GateMainPanelView:OnHide()
	self.IsShow = false
	self.TimerID = nil
end

function GateMainPanelView:OnRegisterUIEvent()
	self.BtnQuit:SetCallback(self, self.OnClickedQuitHandle)
end

function GateMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RideShootingReady, self.OnReady)
	self:RegisterGameEvent(EventID.RideShootingStartCountDown, self.OnStartCountDown)
	self:RegisterGameEvent(EventID.RideShootingUpdateScore, self.OnUpdateScore)
	self:RegisterGameEvent(EventID.RideShootingGameEnd, self.OnGameEventGameEnd)
	self:RegisterGameEvent(EventID.GoldSauserAirForceGameOver, self.OnGameEventGameEnd)
	self:RegisterGameEvent(EventID.RideShootingPlayCameraAnimation, self.OnGameEventPlayCameraAnimation)
end

function GateMainPanelView:OnRegisterBinder()
	local Binders = {
		{ "LeftScore", UIBinderUpdateBindableList.New(self, self.AdapterScoreLeft) },
		{ "BottomScore", UIBinderUpdateBindableList.New(self, self.AdapterScoreBottom) },
	}
	self:RegisterBinders(GateMainVM, Binders)
end

function GateMainPanelView:OnTouchStarted(InGeometry, InTouchEvent)
	if not GateMainVM:GetGameRunning() then
		UE.UWidgetBlueprintLibrary.UnHandled()
		return false
	end
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	if PointerIndex and PointerIndex > 0 then
		UE.UWidgetBlueprintLibrary.UnHandled()
		return false
	end
	local ScreenSpacePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local SelfGeometry = UE.UWidgetLayoutLibrary.GetViewportWidgetGeometry(self)
	local CurPos = UE.USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, ScreenSpacePosition)
	local DPIScale = UE.UWidgetLayoutLibrary.GetViewportScale(self)
	local TouchPos = CurPos * DPIScale
	local EventParams = _G.EventMgr:GetEventParams()
	EventParams.FloatParam1 = TouchPos.X
	EventParams.FloatParam2 = TouchPos.Y
	_G.EventMgr:SendCppEvent(_G.EventID.RideShootingShoot, EventParams)

	--sound
	local PlayerController = GameplayStaticsUtil.GetPlayerController()
	if PlayerController then
		local Location = PlayerController.PlayerCameraManager:GetCameraLocation()
		local Rotation = PlayerController.PlayerCameraManager:GetCameraRotation()
		AudioUtil.LoadAndPlaySoundAtLocation(GoldSauserDefine.AirForceShotSoundPath, Location, Rotation, UE.EObjectGC.Cache_Map)
	end

	local Handled = UE.UWidgetBlueprintLibrary.Handled()
	return UE.UWidgetBlueprintLibrary.CaptureMouse(Handled, self)
end

function GateMainPanelView:OnClickedQuitHandle()
	GateMainVM:SetGameRunning(false)
	local FuncRecover = function() GateMainVM:SetGameRunning(true) end
	local FuncEndGame = function()
		_G.LootMgr:SetDealyState(true)
		_G.GoldSauserMgr:EndGame(false)
	end

	local Params = {
        View = self,
        Title = LSTR(10004),
        Content = LSTR(570006), --570006("确定要退出吗？退出后按当前成绩结算。")
        ConfirmCallBack = FuncEndGame,
        CancelCallBack = FuncRecover,
        CloseCallBack = FuncRecover,
        TextYes = LSTR(10002),
        TextNo = LSTR(10003)
    }
	_G.UIViewMgr:ShowView(UIViewID.PlayStyleCommWin, Params)
end

function GateMainPanelView:OnReady()
	self:PlayAnimation(self.AnimMainLoop, 0, 0)
end

function GateMainPanelView:OnStartCountDown()
	self.CountDown:PlayAnim()
end

function GateMainPanelView:OnUpdateScore(Params)
	if Params.IntParam2 == 4 then
		self:PlayAnimation(self.AnimScoreSubtract)
		GateMainVM:SetScore(Params.IntParam1, false)
		--震动
		self:PlayLocalForceFeedback()
	else
		self:PlayAnimation(self.AnimScoreAdd)
		GateMainVM:SetScore(Params.IntParam1, true)
	end
	GateMainVM:AddKindNum(Params.IntParam2)
	self.Score:PlayAnim(Params.FloatParam1, Params.FloatParam2, Params.IntParam2)
end

function GateMainPanelView:OnGameEventGameEnd()
	UIUtil.SetIsVisible(self.BtnQuit, false)
end

function GateMainPanelView:OnGameEventPlayCameraAnimation()
	UIUtil.SetIsVisible(self.Gate, false)
end

function GateMainPanelView:PlayLocalForceFeedback()
	local ForceFeedback = _G.ObjectMgr:LoadObjectSync("ForceFeedbackEffect'/Game/ForceFeedback/BoomFeedBack.BoomFeedBack'")
	if ForceFeedback then
        local PlayerController = GameplayStaticsUtil.GetPlayerController()
        if PlayerController then
            PlayerController:K2_ClientPlayForceFeedback(ForceFeedback, "Boom", false, false, false)
        end
    end
end

return GateMainPanelView