---
--- Author: Alex
--- DateTime: 2023-12-29 20:13
--- Description:
---


local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS =  require("Protocol/ProtoCS")
local GoldSauserMainPanelBaseItemView = require("Game/GoldSauserMainPanel/View/Item/GoldSauserMainPanelBaseItemView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = _G.UIViewID
local GoldSaucerMinigameCfg = require("TableCfg/GoldSaucerMinigameCfg")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
local BodyGuardSquareAnimState = GoldSauserMainPanelDefine.BodyGuardSquareAnimState
local MiniGameType = ProtoCS.MiniGameType
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
---@field ImgEventSquareNormal UFImage
---@field ImgEventSquareTobeViewed UFImage
---@field PanelBamboo UFCanvasPanel
---@field PanelBodyguard UFCanvasPanel
---@field PanelCactus UFCanvasPanel
---@field PanelEventSquareNormal UFCanvasPanel
---@field PanelEventTyphon UFCanvasPanel
---@field PanelFocus UFCanvasPanel
---@field PanelTobeViewed UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---@field AnimBodyguardIn UWidgetAnimation
---@field AnimBodyguardOut UWidgetAnimation
---@field AnimClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelEventSquareItemView = LuaClass(GoldSauserMainPanelBaseItemView, true)

function GoldSauserMainPanelEventSquareItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnEventSquare = nil
	--self.ImgEventSquareNormal = nil
	--self.ImgEventSquareTobeViewed = nil
	--self.PanelBamboo = nil
	--self.PanelBodyguard = nil
	--self.PanelCactus = nil
	--self.PanelEventSquareNormal = nil
	--self.PanelEventTyphon = nil
	--self.PanelFocus = nil
	--self.PanelTobeViewed = nil
	--self.RedDot = nil
	--self.TextName = nil
	--self.AnimBodyguardIn = nil
	--self.AnimBodyguardOut = nil
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

	self.GameTypeRunning = MiniGameType.MiniGameTypeNone -- 广场当前进行中的游戏
	self:InitConstStringInfo()
end

function GoldSauserMainPanelEventSquareItemView:OnDestroy()

end

function GoldSauserMainPanelEventSquareItemView:OnShow()
	
end

function GoldSauserMainPanelEventSquareItemView:OnHide()

end

function GoldSauserMainPanelEventSquareItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnEventSquare, self.OnBtnClicked)
end

function GoldSauserMainPanelEventSquareItemView:OnRegisterGameEvent()

end

function GoldSauserMainPanelEventSquareItemView:OnIsGameStartChanged(IsGameStart, OldValue)
	local EntranceItemVM = self.ItemVM
	if not EntranceItemVM then
		return
	end

	local RunningGameType = EntranceItemVM.MiniGameType
	if not RunningGameType or RunningGameType == MiniGameType.MiniGameTypeNone then
		FLOG_ERROR("GoldSauserMainPanelEventSquareItemView:OnIsGameStartChanged EntranceItemVM MiniGameType is invalid")
		return
	end
	if IsGameStart then
		self:StartNewGame(RunningGameType, OldValue == nil)
	else
		self:EndRunningGame()
	end
end

--- 小游戏启动统一UI监听事件
function GoldSauserMainPanelEventSquareItemView:OnMiniGameBtnClicked()
	local RunningGameType = self.GameTypeRunning
	if RunningGameType and RunningGameType ~= MiniGameType.MiniGameTypeNone then
		if RunningGameType == MiniGameType.MiniGameTypeTyphon then
			--[[local GoldSauserMainPanelTyphonGameItemVM = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelTyphonGameItemVM()
			local Info = {}
			Info.MiniGameType = MiniGameType.MiniGameTypeTyphon
			Info.MiniGameTime = GoldSaucerMinigameCfg:FindCfgByKey(GoldSauserMainPanelDefine.MiniGameEnum.TyphonEndTime).Value[1] /1000
			GoldSauserMainPanelTyphonGameItemVM:SetInfo(Info)
			UIViewMgr:ShowView(UIViewID.GoldSauserMainPanelTyphonGameItem)--]]
		elseif RunningGameType == MiniGameType.MiniGameTypeBodyGuard then
			self:EnterRunningGame()
		end
	end
end

function GoldSauserMainPanelEventSquareItemView:SetGameEnd()
	local EntranceItemVM = self.ItemVM
	if not EntranceItemVM then
		return
	end
	EntranceItemVM:SetIsGameStart(false)
end

--- 广场流程&游戏切换 ---

--- 触发开始新的游戏
---@param GameType MiniGameType@游戏类型
function GoldSauserMainPanelEventSquareItemView:StartNewGame(GameType, bEnterPanel)
	local RunningGameType = self.GameTypeRunning
	if RunningGameType and RunningGameType ~= MiniGameType.MiniGameTypeNone then
		FLOG_ERROR("GoldSauserMainPanelEventSquareItemView:StartNewGame Have Game Running")
		return
	end
	
	if GameType == MiniGameType.MiniGameTypeTyphon then
	elseif GameType == MiniGameType.MiniGameTypeBodyGuard then
		self:BodyGuardStart(bEnterPanel)
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
	GoldSauserMainPanelMgr:SetIsInPanelMiniGame(false)
	--self:SwitchBodyGuardAutoEndTimer(false)
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

function GoldSauserMainPanelEventSquareItemView:BodyGuardStart(bEnterPanel)
    local function ShowBodyGuardEntrance()
		UIUtil.SetIsVisible(self.PanelBodyguard, true) 
		UIUtil.SetIsVisible(self.PanelBamboo, true)
		self:PlayAnimation(self.AnimBodyguardIn)
	end

	if bEnterPanel then
		self:RegisterTimer(function()
			ShowBodyGuardEntrance()
		end, 0.4)
	else
		ShowBodyGuardEntrance()
	end
	
	--self:SwitchBodyGuardAutoEndTimer(true) -- 初始驻留计时器
end

function GoldSauserMainPanelEventSquareItemView:BodyGuardEnd()
	local OutAnim = self.AnimBodyguardOut
	if not OutAnim then
		return
	end
    self:PlayAnimation(OutAnim)
	local AnimEndTime = OutAnim:GetEndTime() or 0

	self:RegisterTimer(function()
		UIUtil.SetIsVisible(self.PanelBodyguard, false)
	    UIUtil.SetIsVisible(self.PanelBamboo, false)
	end, AnimEndTime)

end

function GoldSauserMainPanelEventSquareItemView:BodyGuardEnter()
	local EntranceItemVM = self.ItemVM
	if not EntranceItemVM then
		return
	end
	local GoldSauserMainPanelBodyguardGameItemVM = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelBodyguardGameItemVM()
	local Info = {}
	Info.MiniGameType = MiniGameType.MiniGameTypeBodyGuard
	Info.MiniGameTime = GoldSaucerMinigameCfg:FindCfgByKey(GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardEndTime).Value[1] /1000
	Info.Level = EntranceItemVM:GetCurLevel()
	Info.EntranceItemVM = EntranceItemVM	
	GoldSauserMainPanelBodyguardGameItemVM:SetInfo(Info)
	UIViewMgr:ShowView(UIViewID.GoldSauserMainPanelBodyguardGameItem, {Data = GoldSauserMainPanelBodyguardGameItemVM, EntranceItemVM = EntranceItemVM})
	--self:SwitchBodyGuardAutoEndTimer(false) -- 点击进入小游戏，关闭自然驻留计数器
	GoldSauserMainPanelMgr:SetIsInPanelMiniGame(true)
end
--- 保镖小游戏 MiniGameTypeBodyGuard end ---

return GoldSauserMainPanelEventSquareItemView