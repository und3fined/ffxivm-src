---
--- Author: Alex
--- DateTime: 2024-02-28 17:29
--- Description:莫古抓球机
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local ItemVM = require("Game/Item/ItemVM")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local MoogleActBtnActiveType = GoldSaucerMiniGameDefine.MoogleActBtnActiveType
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig

---@class GoldSaucerMooglePawMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BottomPanel MainLBottomPanelView
---@field CloseBtn CommonCloseBtnView
---@field MainTeamPanel MainTeamPanelView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMooglePawMainPanelView = LuaClass(UIView, true)

function GoldSaucerMooglePawMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BottomPanel = nil
	--self.CloseBtn = nil
	--self.MainTeamPanel = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BottomPanel)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.MainTeamPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawMainPanelView:OnInit()
	self.Binders = {
		-- 游戏界面显示
		{"bShowGameOrSettlementPanel", UIBinderValueChangedCallback.New(self, nil, self.OnShowGameOrSettlementChanged)},

		-- 游戏状态变化
		{"GameState", UIBinderValueChangedCallback.New(self, nil, self.OnMiniGameStateChanged)},

		--- 队伍通用面板绑定
		{"GameName", UIBinderSetText.New(self, self.MainTeamPanel.TextGameName)},
		{"GoldPanelTitle", UIBinderSetText.New(self, self.MainTeamPanel.TextGameName_1)},
		{"TotalTimeTextTitle", UIBinderSetText.New(self, self.MainTeamPanel.TextTime)},
		{"RewardGot",  UIBinderSetText.New(self, self.MainTeamPanel.TextNumber)},
		{"RewardAdd",  UIBinderSetText.New(self, self.MainTeamPanel.TextNumber1)},
		{"bShowRewardAdd",  UIBinderSetIsVisible.New(self, self.MainTeamPanel.HorizontalObtain1)},
		{"bShowObtainPanel",  UIBinderSetIsVisible.New(self, self.MainTeamPanel.HorizontalGold)},
		{"bShowObtainPanel",  UIBinderSetIsVisible.New(self, self.MainTeamPanel.HorizontalObtain)},
		{"bShowPanelCountDown", UIBinderSetIsVisible.New(self, self.MainTeamPanel.PanelCountdown)}
	}
	-- 初始化相关数据
	self.MooglePawDCfg = MiniGameClientConfig[MiniGameType.MooglesPaw]
end

function GoldSaucerMooglePawMainPanelView:OnDestroy()

end

function GoldSaucerMooglePawMainPanelView:OnShow()
	self:InitPanelOnShowData()
	UIUtil.SetIsVisible(self.BottomPanel, false)
end

function GoldSaucerMooglePawMainPanelView:OnHide()
	self:StopAllAnimations()
	self:UnRegisterAllTimer()
	_G.UIViewMgr:HideView(UIViewID.MooglePawResultPanel)
	_G.UIViewMgr:HideView(UIViewID.MooglePawGamePanel)
end

function GoldSaucerMooglePawMainPanelView:OnRegisterUIEvent()
	self:BindBtnCloseCallBack()
end

function GoldSaucerMooglePawMainPanelView:OnRegisterGameEvent()
end

function GoldSaucerMooglePawMainPanelView:OnRegisterBinder()
    self.VM = self.Params and self.Params.Data
    self:RegisterBinders(self.VM, self.Binders)
end

-- 绑定一下退出按钮功能
function GoldSaucerMooglePawMainPanelView:BindBtnCloseCallBack()
	local function EnsureFailQuit()
		local GameInst = GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
		if GameInst == nil then
			return
		end

		GameInst:SetIsForceEnd(true)
		GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.MooglesPaw)
		GoldSaucerMiniGameMgr:SendMsgMooglePawExitReq()
		--self:StopAllAnimations()
	end

	local function RecoverGameLoop()
		local GameInst = GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
		if GameInst == nil then
			return
		end
		--GameInst:RecoverGameTimeLoop()
	end
	local function OnBtnCloseClick(View)
		if self.VM == nil then
			return
		end

		if self.VM.bShowGameOrSettlementPanel then
			local GameInst = GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
			if GameInst == nil then
				return
			end
			--GameInst:StopGameTimeLoop(true)
			GoldSaucerMiniGameMgr:ShowEnsureExitTip(MiniGameType.MooglesPaw, EnsureFailQuit, RecoverGameLoop)
		else
			GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.MooglesPaw)
		end
	end
	self.CloseBtn:SetCallback(self, OnBtnCloseClick)
end

-- 背景界面信息初始化
function GoldSaucerMooglePawMainPanelView:InitPanelOnShowData()
	--self.BottomPanel:SetButtonEmotionVisible(false)
	--self.BottomPanel:SetButtonPhotoVisible(false)
	self.MainTeamPanel:SetShowGameInfo()
	self:SetTheHelpInfoTips()
	
	--- 图标显示逻辑
	local GameIconWidget = self.MainTeamPanel.IconGame
	local ClientDef = self.MooglePawDCfg
	if GameIconWidget and ClientDef then
		UIUtil.ImageSetBrushFromAssetPath(GameIconWidget, ClientDef.IconGamePath)
	end
end

--- 设定功能说明信息
function GoldSaucerMooglePawMainPanelView:SetTheHelpInfoTips()
	local MainTeamPanel = self.MainTeamPanel
	if not MainTeamPanel then
		return
	end

	local nforBtn = MainTeamPanel.nforBtn
	if not nforBtn then
		return
	end
	nforBtn:SetHelpInfoID(GoldSaucerMiniGameMgr:GetThePanelHelpInfoID(MiniGameType.MooglesPaw) or -1)
end

-- 切换子界面显示, 游戏和结算界面分开
function GoldSaucerMooglePawMainPanelView:OnShowGameOrSettlementChanged(NewValue)
	if NewValue then
		_G.UIViewMgr:HideView(UIViewID.MooglePawResultPanel, true)
		_G.UIViewMgr:ShowView(UIViewID.MooglePawGamePanel, self.Params)
	else
		_G.UIViewMgr:HideView(UIViewID.MooglePawGamePanel, true)
		_G.UIViewMgr:ShowView(UIViewID.MooglePawResultPanel, self.Params)
	end
end

-- 游戏状态更新, 更新对应相关界面信息
function GoldSaucerMooglePawMainPanelView:OnMiniGameStateChanged(NewValue, OldValue)
    if OldValue == MiniGameStageType.Enter and NewValue == MiniGameStageType.Start then
        self:UpdateStartInfo()
    elseif OldValue == MiniGameStageType.Start and NewValue == MiniGameStageType.Update then
        self:UpdateRunTimeInfo()
    elseif OldValue == MiniGameStageType.End and NewValue == MiniGameStageType.Reward then
        self:UpdateRewardInfo()
    elseif OldValue == MiniGameStageType.Restart and NewValue == MiniGameStageType.Update then
        self:UpdateRunTimeInfo()
    end
end

--- 更新开始界面
function GoldSaucerMooglePawMainPanelView:UpdateStartInfo()
	if self.VM == nil then
		return
	end
	self.VM.bShowGameOrSettlementPanel = true
end

--- 显示奖励结算界面
function GoldSaucerMooglePawMainPanelView:UpdateRewardInfo()
	if self.VM == nil then
		return
	end
	GoldSaucerMiniGameMgr:SendMsgMooglePawExitReq() -- 进入结算界面就向服务器发起退出游戏协议
	self.VM.bShowGameOrSettlementPanel = false
end

--- 开始游戏循环
function GoldSaucerMooglePawMainPanelView:UpdateRunTimeInfo()
	local GameInst = self.VM.MiniGame
	if not GameInst then
		return
	end
	GameInst:SetMoogleMoveStateIdle()
end

return GoldSaucerMooglePawMainPanelView