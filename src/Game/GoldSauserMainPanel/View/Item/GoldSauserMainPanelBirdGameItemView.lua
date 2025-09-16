---
--- Author: Administrator
--- DateTime: 2023-12-29 20:12
--- Description:
---

--local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS =  require("Protocol/ProtoCS")
local MiniGameType = ProtoCS.MiniGameType
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local GoldSauserMainPanelBaseItemView = require("Game/GoldSauserMainPanel/View/Item/GoldSauserMainPanelBaseItemView")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoRes =  require("Protocol/ProtoRes")
local GoldSauserGameClientType = ProtoRes.GoldSauserGameClientType

local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR

---@class GoldSauserMainPanelBirdGameItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bomb1 GoldSauserBirdGameBombView
---@field Bomb10 GoldSauserBirdGameBombView
---@field Bomb11 GoldSauserBirdGameBombView
---@field Bomb2 GoldSauserBirdGameBombView
---@field Bomb3 GoldSauserBirdGameBombView
---@field Bomb4 GoldSauserBirdGameBombView
---@field Bomb5 GoldSauserBirdGameBombView
---@field Bomb6 GoldSauserBirdGameBombView
---@field Bomb7 GoldSauserBirdGameBombView
---@field Bomb8 GoldSauserBirdGameBombView
---@field Bomb9 GoldSauserBirdGameBombView
---@field BombListPanel UFCanvasPanel
---@field GoldSauserWonderSquareItem_UIBP GoldSauserMainPanelWonderSquareItemView
---@field PanelChicks UFCanvasPanel
---@field PanelSuccess UFCanvasPanel
---@field TableViewItem UTableView
---@field AnimCrash UWidgetAnimation
---@field AnimInManual UWidgetAnimation
---@field AnimLoop1 UWidgetAnimation
---@field AnimStart UWidgetAnimation
---@field AnimSuccess UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelBirdGameItemView = LuaClass(GoldSauserMainPanelBaseItemView, true)

function GoldSauserMainPanelBirdGameItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bomb1 = nil
	--self.Bomb10 = nil
	--self.Bomb11 = nil
	--self.Bomb2 = nil
	--self.Bomb3 = nil
	--self.Bomb4 = nil
	--self.Bomb5 = nil
	--self.Bomb6 = nil
	--self.Bomb7 = nil
	--self.Bomb8 = nil
	--self.Bomb9 = nil
	--self.BombListPanel = nil
	--self.GoldSauserWonderSquareItem_UIBP = nil
	--self.PanelChicks = nil
	--self.PanelSuccess = nil
	--self.TableViewItem = nil
	--self.AnimCrash = nil
	--self.AnimInManual = nil
	--self.AnimLoop1 = nil
	--self.AnimStart = nil
	--self.AnimSuccess = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelBirdGameItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bomb1)
	self:AddSubView(self.Bomb10)
	self:AddSubView(self.Bomb11)
	self:AddSubView(self.Bomb2)
	self:AddSubView(self.Bomb3)
	self:AddSubView(self.Bomb4)
	self:AddSubView(self.Bomb5)
	self:AddSubView(self.Bomb6)
	self:AddSubView(self.Bomb7)
	self:AddSubView(self.Bomb8)
	self:AddSubView(self.Bomb9)
	self:AddSubView(self.GoldSauserWonderSquareItem_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelBirdGameItemView:OnInit()
	self.AdapterBombList = UIAdapterTableView.CreateAdapter(self, self.TableViewItem)
	self.Binders = {
		{"IsGameStart", UIBinderSetIsVisible.New(self, self.PanelChicks)},
		{"IsGameStart", UIBinderValueChangedCallback.New(self, nil, self.OnIsGameStartChanged)},
		--{"BombListVMs", UIBinderUpdateBindableList.New(self, self.AdapterBombList)},
		{"GameResult", UIBinderValueChangedCallback.New(self, nil, self.OnGameResultChanged)},
		{"RoundCounter", UIBinderValueChangedCallback.New(self, nil, self.OnRoundStart)},
		{"SingleRoundStep", UIBinderValueChangedCallback.New(self, nil, self.OnRoundBombTurnRedStepChange)},
	}

	self.RoundAutonExplodeTimer = nil -- 回合内变红炸弹未清除计时器
	self.ViewGameStart = false -- 分离与VM的GameStart判断，处理游戏过程中EntanceClick回调触发导致的游戏错乱问题
end

function GoldSauserMainPanelBirdGameItemView:OnDestroy()
	--self:DestroyTheBombListViewModel()
end

function GoldSauserMainPanelBirdGameItemView:OnShow()

end

function GoldSauserMainPanelBirdGameItemView:BindExtraParams()
	self:BindTheBombListViewModel()
end

function GoldSauserMainPanelBirdGameItemView:BindTheBombListViewModel()
	local EntranceVM = GoldSauserMainPanelMainVM:GetEntranceItemVMByBtnID(GoldSauserGameClientType.GoldSauserGameTypeGateMagic)
	if not EntranceVM then
		return
	end
	local BombListVMs = EntranceVM.BombListVMs
	if not BombListVMs or not next(BombListVMs) then
		return
	end
	for Index = 1, #BombListVMs do
		local BombVM = BombListVMs[Index]
		if BombVM then
			local BombViewKey = string.format("Bomb%s", Index)
			local BombView = self[BombViewKey]
			if BombView then
				BombView:SetParams({Data = BombVM})
			end
		end
	end
end

function GoldSauserMainPanelBirdGameItemView:DestroyTheBombListViewModel()
	local EntranceVM = GoldSauserMainPanelMainVM:GetEntranceItemVMByBtnID(GoldSauserGameClientType.GoldSauserGameTypeGateMagic)
	if not EntranceVM then
		return
	end
	EntranceVM:DestoryBirdGameBombListViewModel()
end

function GoldSauserMainPanelBirdGameItemView:OnHide()
	local EntranceVM = self.ItemVM
	if not EntranceVM then
		return
	end

	local IsGameExist = EntranceVM:GetIsGameStart()
	if IsGameExist then
		EntranceVM:SetGameResult(nil)
	end
	EntranceVM:SetIsGameStart(false)
end

function GoldSauserMainPanelBirdGameItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.GoldSauserWonderSquareItem_UIBP.BtnWonderSquare, self.OnBtnClicked)
end

---@设置游戏开始
function GoldSauserMainPanelBirdGameItemView:SetGameStart()
	--- 小雏鸟出现动画
	self:PlayAnimation(self.AnimInManual)
	local EntranceVM = self.ItemVM
	if not EntranceVM then
		return
	end
	EntranceVM:InitBirdGameBombList()
	UIUtil.SetIsVisible(self.BombListPanel, false)
end

------ 拯救雏鸟小游戏相关内容 ------
function GoldSauserMainPanelBirdGameItemView:OnMiniGameBtnClicked()
	local ViewGameStart = self.ViewGameStart
	if ViewGameStart then
		return
	end
	self:PlayAnimation(self.AnimStart)
	local EntranceVM = self.ItemVM
	if not EntranceVM then
		return
	end
	EntranceVM:AddRoundCounter()
	UIUtil.SetIsVisible(self.BombListPanel, true)
	self.ViewGameStart = true
	GoldSauserMainPanelMgr:SetIsInPanelMiniGame(true)
	self:PlayAnimation(self.AnimLoop1, 0, 0)
end

function GoldSauserMainPanelBirdGameItemView:BombTurnRedByRoundStep()
	local EntranceVM = self.ItemVM
	if not EntranceVM then
		return
	end
	local DelayShowBombToRed = 0.3 -- 炸弹变红动画时长
	self:RegisterTimer(function()
		EntranceVM:NotifyBirdGameBombsTurnRed()
		local RoundExplodeTime = EntranceVM:GetRedToExplodeTime()
		self.RoundAutonExplodeTimer = self:RegisterTimer(function()
			EntranceVM:CheckTheStepResult()
			FLOG_INFO("BirdBombExplode: Time up")
		end, RoundExplodeTime)
	end, DelayShowBombToRed)
end

function GoldSauserMainPanelBirdGameItemView:OnRoundStart(NewValue)
	if not NewValue or NewValue == 0 then
		return
	end

	local RoundCheckTimer = self.RoundAutonExplodeTimer
	if RoundCheckTimer then
		self:UnRegisterTimer(RoundCheckTimer)
		self.RoundAutonExplodeTimer = nil
	end

	local EntranceVM = self.ItemVM
	if not EntranceVM then
		return
	end

	self:PlayAnimation(self.AnimStart)
	local CreateDelayTime = 0.5 -- 炸弹清除动画时长
	self:RegisterTimer(function()
		EntranceVM:CreateBirdGameBombs()
		self:BombTurnRedByRoundStep()
	end, CreateDelayTime)
end


function GoldSauserMainPanelBirdGameItemView:OnRoundBombTurnRedStepChange(NewValue, OldValue)
	if not NewValue or NewValue == 0 or OldValue == 0 then
		return
	end

	local RoundCheckTimer = self.RoundAutonExplodeTimer
	if RoundCheckTimer then
		self:UnRegisterTimer(RoundCheckTimer)
		self.RoundAutonExplodeTimer = nil
	end

	self:BombTurnRedByRoundStep()
end

function GoldSauserMainPanelBirdGameItemView:OnRegisterGameEvent()

end

function GoldSauserMainPanelBirdGameItemView:OnIsGameStartChanged(IsGameStart)
	if IsGameStart then
		self:SetGameStart()
	else
		--- 游戏结束清空状态
		local EntranceVM = self.ItemVM
		if EntranceVM then
			EntranceVM:SetGameResult(nil)
			self.ViewGameStart = false
			GoldSauserMainPanelMgr:SetIsInPanelMiniGame(false)
		end
		self:StopAnimation(self.AnimLoop1)
	end
end

function GoldSauserMainPanelBirdGameItemView:OnGameResultChanged(NewRlt)
	if NewRlt == nil then
		return
	end

	local RoundCheckTimer = self.RoundAutonExplodeTimer
	if RoundCheckTimer then
		self:UnRegisterTimer(RoundCheckTimer)
		self.RoundAutonExplodeTimer = nil
	end

	local ItemVM = self.ItemVM
	if not ItemVM then
		return
	end

	local DelayTimeForAnimEnd = 0.3
	self:PauseAnimation(self.AnimLoop1)
	self:RegisterTimer(function()
		if NewRlt then
			ItemVM:ChangeTheBombCreatedToDefault()
			self:PlayAnimation(self.AnimSuccess, 0, 1, nil, 1.0, true)
			GoldSauserMainPanelMainVM.MiniGameSuccess = true
			GoldSauserMainPanelMgr:SendGoldSauserMainGameFinishedNumMsg(MiniGameType.MiniGameTypeCliffHanger)
			--MsgTipsUtil.ShowTips(LSTR(350024))
		else
			ItemVM:NotifyRedBirdGameBombsExplode()
			self:PlayAnimation(self.AnimCrash, 0, 1, nil, 1.0, true)
			--MsgTipsUtil.ShowTips(LSTR(350025))
		end
	end, DelayTimeForAnimEnd)
	GoldSauserMainPanelMgr:SendTlogMsgForGameResult(MiniGameType.MiniGameTypeCliffHanger, NewRlt)
end

function GoldSauserMainPanelBirdGameItemView:GetTheSelectedPanel()
	return self.GoldSauserWonderSquareItem_UIBP.PanelFocus
end

function GoldSauserMainPanelBirdGameItemView:GetTheHighlightPanel()
	return self.GoldSauserWonderSquareItem_UIBP.PanelTobeViewed
end

function GoldSauserMainPanelBirdGameItemView:GetTheRedDotWidget()
	return self.GoldSauserWonderSquareItem_UIBP.RedDot
end

function GoldSauserMainPanelBirdGameItemView:GetTheAnimClick()
	return self.GoldSauserWonderSquareItem_UIBP.AnimClick
end

function GoldSauserMainPanelBirdGameItemView:GetTheAnimOwner()
	return self.GoldSauserWonderSquareItem_UIBP
end

function GoldSauserMainPanelBirdGameItemView:OnAnimationFinished(Anim)
	if Anim == self.AnimSuccess or Anim == self.AnimCrash then
		local ItemVM = self.ItemVM
		if not ItemVM then
			return
		end
		ItemVM:SetIsGameStart(false)
	end
end

return GoldSauserMainPanelBirdGameItemView