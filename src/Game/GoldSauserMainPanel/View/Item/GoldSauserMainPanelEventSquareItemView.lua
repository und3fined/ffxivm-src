---
--- Author: Alex
--- DateTime: 2023-12-29 20:13
--- Description:
---


local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSauserMainPanelBaseItemView = require("Game/GoldSauserMainPanel/View/Item/GoldSauserMainPanelBaseItemView")
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoCS =  require("Protocol/ProtoCS")
local MiniGameType = ProtoCS.MiniGameType
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = _G.UIViewID
local GoldSaucerMinigameCfg = require("TableCfg/GoldSaucerMinigameCfg")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local BodyGuardSquareAnimState = GoldSauserMainPanelDefine.BodyGuardSquareAnimState

local FLOG_ERROR = _G.FLOG_ERROR
local LSTR = _G.LSTR

local BambooBatchCfg = 
{
	[1] = GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardOneBambooPool,
	[2] = GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardTwoBambooPool,
	[3] = GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardThreeBambooPool,
	[4] = GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardFourBambooPool,
}

---@class GoldSauserMainPanelEventSquareItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnEventSquare UFButton
---@field FImageGrain1 UFImage
---@field FImageGrain101 UFImage
---@field FImageGrain102 UFImage
---@field FImageGrain103 UFImage
---@field FImageGrain2 UFImage
---@field FImageGrain31 UFImage
---@field FImageGrain32 UFImage
---@field FImageGrain4 UFImage
---@field FImageGrain51 UFImage
---@field FImageGrain52 UFImage
---@field FImageGrain61 UFImage
---@field FImageGrain62 UFImage
---@field FImageGrain63 UFImage
---@field FImageGrain71 UFImage
---@field FImageGrain72 UFImage
---@field FImageGrain73 UFImage
---@field FImageGrain81 UFImage
---@field FImageGrain82 UFImage
---@field FImageGrain83 UFImage
---@field FImageGrain91 UFImage
---@field FImageGrain92 UFImage
---@field FImageGrain93 UFImage
---@field ImgEventSquareNormal UFImage
---@field ImgEventSquareTobeViewed UFImage
---@field PanelBamboo UFCanvasPanel
---@field PanelBamboo_1 UFCanvasPanel
---@field PanelBamboo_10 UFCanvasPanel
---@field PanelBamboo_2 UFCanvasPanel
---@field PanelBamboo_3 UFCanvasPanel
---@field PanelBamboo_4 UFCanvasPanel
---@field PanelBamboo_5 UFCanvasPanel
---@field PanelBamboo_6 UFCanvasPanel
---@field PanelBamboo_7 UFCanvasPanel
---@field PanelBamboo_8 UFCanvasPanel
---@field PanelBamboo_9 UFCanvasPanel
---@field PanelBodyguard UFCanvasPanel
---@field PanelCactus UFCanvasPanel
---@field PanelEventSquareNormal UFCanvasPanel
---@field PanelEventTyphon UFCanvasPanel
---@field PanelFocus UFCanvasPanel
---@field PanelTobeViewed UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelEventSquareItemView = LuaClass(GoldSauserMainPanelBaseItemView, true)

function GoldSauserMainPanelEventSquareItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnEventSquare = nil
	--self.FImageGrain1 = nil
	--self.FImageGrain101 = nil
	--self.FImageGrain102 = nil
	--self.FImageGrain103 = nil
	--self.FImageGrain2 = nil
	--self.FImageGrain31 = nil
	--self.FImageGrain32 = nil
	--self.FImageGrain4 = nil
	--self.FImageGrain51 = nil
	--self.FImageGrain52 = nil
	--self.FImageGrain61 = nil
	--self.FImageGrain62 = nil
	--self.FImageGrain63 = nil
	--self.FImageGrain71 = nil
	--self.FImageGrain72 = nil
	--self.FImageGrain73 = nil
	--self.FImageGrain81 = nil
	--self.FImageGrain82 = nil
	--self.FImageGrain83 = nil
	--self.FImageGrain91 = nil
	--self.FImageGrain92 = nil
	--self.FImageGrain93 = nil
	--self.ImgEventSquareNormal = nil
	--self.ImgEventSquareTobeViewed = nil
	--self.PanelBamboo = nil
	--self.PanelBamboo_1 = nil
	--self.PanelBamboo_10 = nil
	--self.PanelBamboo_2 = nil
	--self.PanelBamboo_3 = nil
	--self.PanelBamboo_4 = nil
	--self.PanelBamboo_5 = nil
	--self.PanelBamboo_6 = nil
	--self.PanelBamboo_7 = nil
	--self.PanelBamboo_8 = nil
	--self.PanelBamboo_9 = nil
	--self.PanelBodyguard = nil
	--self.PanelCactus = nil
	--self.PanelEventSquareNormal = nil
	--self.PanelEventTyphon = nil
	--self.PanelFocus = nil
	--self.PanelTobeViewed = nil
	--self.RedDot = nil
	--self.TextName = nil
	--self.AnimClick = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelEventSquareItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelEventSquareItemView:InitConstStringInfo()
	self.TextName:SetText(LSTR(350056))
end

function GoldSauserMainPanelEventSquareItemView:OnInit()
	self.Binders = {
		{ "IsGameStart", UIBinderValueChangedCallback.New(self, nil, self.OnIsGameStartChanged)},
	}

	--- 保镖小游戏的Binder
	self.BindersBodyGuard = {
		{ "SquareAnimState", UIBinderValueChangedCallback.New(self, nil, self.OnBodyGuardAnimStateChange)},
		{ "RandomBambooWithSignIndex", UIBinderValueChangedCallback.New(self, nil, self.OnBambooPanelShownChange)},
	}

	self.GameTypeRunning = MiniGameType.MiniGameTypeNone -- 广场当前进行中的游戏
	self:InitConstStringInfo()
end

function GoldSauserMainPanelEventSquareItemView:OnDestroy()

end

function GoldSauserMainPanelEventSquareItemView:OnShow()
	self:ClearSquareItemGamePanel()
end

function GoldSauserMainPanelEventSquareItemView:OnHide()

end

function GoldSauserMainPanelEventSquareItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnEventSquare, self.OnEventSquareBtnClicked)
end

function GoldSauserMainPanelEventSquareItemView:OnRegisterGameEvent()

end

function GoldSauserMainPanelEventSquareItemView:OnIsGameStartChanged(IsGameStart)
	if IsGameStart then
		self:StartNewGame(GoldSauserMainPanelMainVM.MiniGameType)
	else
		self:EndRunningGame()
	end
end

function GoldSauserMainPanelEventSquareItemView:OnEventSquareBtnClicked()
	if self.ItemVM:GetIsGameStart() then
		GoldSauserMainPanelMainVM:SetIsEventSquareCenter(true)
		if GoldSauserMainPanelMainVM.MiniGameType == MiniGameType.MiniGameTypeTyphon then
			local GoldSauserMainPanelTyphonGameItemVM = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelTyphonGameItemVM()
			local Info = {}
			Info.MiniGameType = MiniGameType.MiniGameTypeTyphon
			Info.MiniGameTime = GoldSaucerMinigameCfg:FindCfgByKey(GoldSauserMainPanelDefine.MiniGameEnum.TyphonEndTime).Value[1] /1000
			GoldSauserMainPanelTyphonGameItemVM:SetInfo(Info)
			UIViewMgr:ShowView(UIViewID.GoldSauserMainPanelTyphonGameItem)
		elseif  GoldSauserMainPanelMainVM.MiniGameType == MiniGameType.MiniGameTypeBodyGuard then
			self:EnterRunningGame()
		end
	else
		self:OnBtnClicked()
	end
end

function GoldSauserMainPanelEventSquareItemView:SetGameEnd()
	self.ItemVM:SetIsGameStart(false)
	---计时器销毁
	self:SwitchBodyGuardAutoEndTimer(false)
end



--- 广场流程&游戏切换 ---

function GoldSauserMainPanelEventSquareItemView:ClearSquareItemGamePanel()
	UIUtil.SetIsVisible(self.PanelBodyguard, false)
	UIUtil.SetIsVisible(self.PanelEventTyphon, false)
	UIUtil.SetIsVisible(self.PanelBamboo, false)
	UIUtil.SetIsVisible(self.PanelCactus, false)
end

--- 触发开始新的游戏
---@param GameType MiniGameType@游戏类型
function GoldSauserMainPanelEventSquareItemView:StartNewGame(GameType)
	local RunningGameType = self.GameTypeRunning
	if RunningGameType and RunningGameType ~= MiniGameType.MiniGameTypeNone then
		FLOG_ERROR("GoldSauserMainPanelEventSquareItemView:StartNewGame Have Game Running")
		return
	end
	
	if GameType == MiniGameType.MiniGameTypeTyphon then
	elseif GameType == MiniGameType.MiniGameTypeBodyGuard then
		self:BodyGuardStart()
	end
	self.GameTypeRunning = GameType
end

--- 结束当前进行中的游戏
---@param GameType MiniGameType@游戏类型
function GoldSauserMainPanelEventSquareItemView:EndRunningGame()
	local RunningGameType = self.GameTypeRunning
	if not RunningGameType or RunningGameType == MiniGameType.MiniGameTypeNone then
		-- 仅在存在小游戏的情况下才处理，避免初始化绑定处理相关小游戏
		return
	end

	if RunningGameType == MiniGameType.MiniGameTypeTyphon then
	elseif RunningGameType == MiniGameType.MiniGameTypeBodyGuard then
		self:BodyGuardEnd()
	end
	self.GameTypeRunning = MiniGameType.MiniGameTypeNone
end

--- 结束当前进行中的游戏
---@param GameType MiniGameType@游戏类型
function GoldSauserMainPanelEventSquareItemView:EnterRunningGame()
	local RunningGameType = self.GameTypeRunning
	if not RunningGameType or RunningGameType == MiniGameType.MiniGameTypeNone then
		FLOG_ERROR("GoldSauserMainPanelEventSquareItemView:EnterRunningGame No Game is Running")
		return
	end

	if RunningGameType == MiniGameType.MiniGameTypeTyphon then
	elseif RunningGameType == MiniGameType.MiniGameTypeBodyGuard then
		self:BodyGuardEnter()
	end
end

--- 广场流程&游戏切换 end ---

--- 保镖小游戏 MiniGameTypeBodyGuard ---

--- 控制保镖小游戏自然驻留计时器开关
---@param bStart boolean@是否打开
function GoldSauserMainPanelEventSquareItemView:SwitchBodyGuardAutoEndTimer(bStart)
	local RemainTimer = self.RemainTimer
	if bStart then
		-- 启动自然驻留计时器
		if RemainTimer then
			_G.TimerMgr:CancelTimer(self.RemainTimer)
		end
		local RemainTime = GoldSaucerMinigameCfg:FindCfgByKey(GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardStartTime).Value[1] /1000
		self.RemainTimer = _G.TimerMgr:AddTimer(self, self.SetGameEnd, RemainTime, nil, 1, GoldSauserMainPanelDefine.MiniGameEndCondition.Interrupt)
	else
		if not RemainTimer then
			return
		end
		_G.TimerMgr:CancelTimer(self.RemainTimer)
		self.RemainTimer = nil
	end
end

function GoldSauserMainPanelEventSquareItemView:HideTheBambooWithSign()
	for index, _ in ipairs(GoldSauserMainPanelDefine.BambooStyleList) do
		local Panel = string.format("PanelBamboo_%s", tostring(index))
		UIUtil.SetIsVisible(self[Panel], false)
	end
end

function GoldSauserMainPanelEventSquareItemView:BodyGuardStart()
	UIUtil.SetIsVisible(self.PanelBodyguard, true) 
	UIUtil.SetIsVisible(self.PanelBamboo, true)
	self:HideTheBambooWithSign()
	self:SwitchBodyGuardAutoEndTimer(true) -- 初始驻留计时器
end

function GoldSauserMainPanelEventSquareItemView:BodyGuardEnd()
	UIUtil.SetIsVisible(self.PanelBodyguard, false)
	UIUtil.SetIsVisible(self.PanelBamboo, false)
	local GoldSauserMainPanelBodyguardGameItemVM = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelBodyguardGameItemVM()
	local BindersBodyGuard = self.BindersBodyGuard
	if GoldSauserMainPanelBodyguardGameItemVM and BindersBodyGuard then
		self:UnRegisterBinders(GoldSauserMainPanelBodyguardGameItemVM, BindersBodyGuard)
	end
end

function GoldSauserMainPanelEventSquareItemView:BodyGuardEnter()
	local GoldSauserMainPanelBodyguardGameItemVM = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelBodyguardGameItemVM()
	local Info = {}
	Info.MiniGameType = MiniGameType.MiniGameTypeBodyGuard
	Info.MiniGameTime = GoldSaucerMinigameCfg:FindCfgByKey(GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardEndTime).Value[1] /1000
	GoldSauserMainPanelBodyguardGameItemVM:SetInfo(Info)
	local function GameEnd()
		self:SetGameEnd()
	end
	UIViewMgr:ShowView(UIViewID.GoldSauserMainPanelBodyguardGameItem, {ParentGameEnd = GameEnd})
	self:SwitchBodyGuardAutoEndTimer(false) -- 点击进入小游戏，关闭自然驻留计数器
	local BindersBodyGuard = self.BindersBodyGuard
	if GoldSauserMainPanelBodyguardGameItemVM and BindersBodyGuard then
		self:RegisterBinders(GoldSauserMainPanelBodyguardGameItemVM, BindersBodyGuard)
	end
end

function GoldSauserMainPanelEventSquareItemView:OnBodyGuardAnimStateChange(AnimState)
	if AnimState == BodyGuardSquareAnimState.Idle then
		-- TODO 播放待机动画
	elseif AnimState == BodyGuardSquareAnimState.Act then
	elseif AnimState == BodyGuardSquareAnimState.ActSuccess then
	elseif AnimState == BodyGuardSquareAnimState.ActFail then
		
	end
end

--- 界面砍伐竹子面板显隐控制
function GoldSauserMainPanelEventSquareItemView:OnBambooPanelShownChange(BambooIndex, BambooIndexToHide)
	if BambooIndexToHide then
		local Panel = string.format("PanelBamboo_%s", tostring(BambooIndexToHide))
		FLOG_INFO("OnBambooPanelShownChange: HideTheBambooPanel %s", Panel)
		UIUtil.SetIsVisible(self[Panel], false)
	end

	if BambooIndex then
		local Panel = string.format("PanelBamboo_%s", tostring(BambooIndex))
		FLOG_INFO("OnBambooPanelShownChange: ShowTheBambooPanel %s", Panel)
		UIUtil.SetIsVisible(self[Panel], true)
	end
end
--- 保镖小游戏 MiniGameTypeBodyGuard end ---

return GoldSauserMainPanelEventSquareItemView