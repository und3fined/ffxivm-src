---
--- Author: Administrator
--- DateTime: 2024-12-06 11:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes =  require("Protocol/ProtoRes")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
local BirdBombState = GoldSauserMainPanelDefine.BirdBombState
local AudioType = GoldSauserMainPanelDefine.AudioType
local GoldSauserGameClientType = ProtoRes.GoldSauserGameClientType
local FLOG_INFO = _G.FLOG_INFO

---@class GoldSauserBirdGameBombView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FButtonClick UFButton
---@field ImgBombRed UFImage
---@field PanelBomb UFCanvasPanel
---@field AnimBoom UWidgetAnimation
---@field AnimClean UWidgetAnimation
---@field AnimInManual UWidgetAnimation
---@field AnimToRed UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserBirdGameBombView = LuaClass(UIView, true)

function GoldSauserBirdGameBombView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FButtonClick = nil
	--self.ImgBombRed = nil
	--self.PanelBomb = nil
	--self.AnimBoom = nil
	--self.AnimClean = nil
	--self.AnimInManual = nil
	--self.AnimToRed = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserBirdGameBombView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserBirdGameBombView:OnInit()
	self.Binders = {
		{"BombState", UIBinderValueChangedCallback.New(self, nil, self.OnBombStateChanged)},
	}
end

function GoldSauserBirdGameBombView:OnDestroy()

end

function GoldSauserBirdGameBombView:OnShow()

end

function GoldSauserBirdGameBombView:OnHide()

end

function GoldSauserBirdGameBombView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButtonClick, self.OnFButtonClickClicked)
end

function GoldSauserBirdGameBombView:OnRegisterGameEvent()

end

function GoldSauserBirdGameBombView:OnRegisterBinder()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

function GoldSauserBirdGameBombView:OnFButtonClickClicked()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	local EntranceVM = GoldSauserMainPanelMainVM:GetEntranceItemVMByBtnID(GoldSauserGameClientType.GoldSauserGameTypeGateMagic)
	if not EntranceVM then
		return
	end

	local CanClick = not EntranceVM:GetDisableClickBombByGameSettle()
	if not CanClick then
		return
	end

	local BombState = ViewModel:GetTheBombState()

	if BirdBombState.TurnToRed == BombState then
		local BombIndex = ViewModel.PosIndex
		if BombIndex then
			EntranceVM:CleanRedBirdGameBomb(BombIndex)
		end
	elseif BirdBombState.Created == BombState then
		EntranceVM:SetGameResult(false) -- 游戏过程中点错未变红的炸弹直接判负
		FLOG_INFO("BirdBombExplode: Wrong Click")
	end
end

function GoldSauserBirdGameBombView:OnBombStateChanged(NewState)
	if not NewState then
		return
	end

	-- 状态变化时都需要先清除动画
	self:StopAllAnimations()
	-- 默认不显示炸弹
	UIUtil.SetIsVisible(self.PanelBomb, BirdBombState.Default ~= NewState)
	if BirdBombState.Default == NewState then
		return
	end

	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	if BirdBombState.Created == NewState then
		UIUtil.SetIsVisible(self.ImgBombRed, false)
		self:PlayAnimation(self.AnimInManual, 0, 1, nil, 1.0, true)
	elseif BirdBombState.TurnToRed == NewState then
		UIUtil.SetIsVisible(self.ImgBombRed, true)
		self:PlayAnimation(self.AnimToRed, 0, 1, nil, 1.0, true)
		GoldSauserMainPanelMgr:PlayAudio(AudioType.BombReding)
		FLOG_INFO("BirdBomb: ItemView TurnRed %d", ViewModel.PosIndex)
	elseif BirdBombState.Exploded == NewState then
		self:PlayAnimation(self.AnimBoom, 0, 1, nil, 1.0, true)
		GoldSauserMainPanelMgr:PlayAudio(AudioType.BombExplode)
	elseif BirdBombState.Cleared == NewState then
		self:PlayAnimation(self.AnimClean, 0, 1, nil, 1.0, true)
	end
end

function GoldSauserBirdGameBombView:OnAnimationFinished(Anim)
	if Anim == self.AnimBoom or Anim == self.AnimClean then
		UIUtil.SetIsVisible(self.PanelBomb, false)
	end
end

return GoldSauserBirdGameBombView