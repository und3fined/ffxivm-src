---
--- Author: alexchen
--- DateTime: 2023-11-09 16:59
--- Description:孤树无援难度展示界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameDifficulty = GoldSaucerMiniGameDefine.MiniGameDifficulty
local AudioType = GoldSaucerMiniGameDefine.AudioType

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR

---@class OutOnALimbChooseItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ChoosePanel UFCanvasPanel
---@field ImgChoose UFImage
---@field P_DX_OutOnALimbChooseItem_1 UUIParticleEmitter
---@field P_DX_OutOnALimbChooseItem_2 UUIParticleEmitter
---@field TextChoose UFTextBlock
---@field AnimShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OutOnALimbChooseItemView = LuaClass(UIView, true)

function OutOnALimbChooseItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ChoosePanel = nil
	--self.ImgChoose = nil
	--self.P_DX_OutOnALimbChooseItem_1 = nil
	--self.P_DX_OutOnALimbChooseItem_2 = nil
	--self.TextChoose = nil
	--self.AnimShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OutOnALimbChooseItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OutOnALimbChooseItemView:OnInit()
	self.CallBack = nil
end

function OutOnALimbChooseItemView:OnDestroy()
	self.CallBack = nil
end

function OutOnALimbChooseItemView:OnShow()
	
end

function OutOnALimbChooseItemView:OnHide()

end

function OutOnALimbChooseItemView:OnRegisterUIEvent()

end

function OutOnALimbChooseItemView:OnRegisterGameEvent()

end

function OutOnALimbChooseItemView:OnRegisterBinder()

end

function OutOnALimbChooseItemView:UpdateMainPanel(ViewModel, CallBack)
	self.CallBack = CallBack

	local ViewModel = ViewModel
	if ViewModel == nil then
		FLOG_ERROR("OutOnALimbChooseItemView:UpdateMainPanel  ViewModel is nil")
		return
	end

	local MiniGameInst = ViewModel.MiniGame
    if MiniGameInst == nil then
		FLOG_ERROR("OutOnALimbChooseItemView:UpdateMainPanel  MiniGameInst is nil")
        return
    end

	local Difficulty = MiniGameInst:GetDifficulty()
	if Difficulty == nil then
		FLOG_ERROR("OutOnALimbChooseItemView:UpdateMainPanel  Difficulty is nil")
		return
	end
	local ClientDef = MiniGameClientConfig[MiniGameType.OutOnALimb]
	if ClientDef == nil then
		FLOG_ERROR("OutOnALimbChooseItemView:UpdateMainPanel  ClientDef is nil")
		return
	end

	local DifficultyIconPathDef = ClientDef.DifficultyIconPath
	if DifficultyIconPathDef == nil then
		FLOG_ERROR("OutOnALimbChooseItemView:UpdateMainPanel  DifficultyIconPathDef is nil")
		return
	end

	local ShowIconPath = DifficultyIconPathDef[Difficulty]
	if ShowIconPath then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgChoose, ShowIconPath)
	end

	local DifficultyText = self.TextChoose
	if MiniGameDifficulty.Sabotender == Difficulty then
		DifficultyText:SetText(LSTR(370043))
	elseif  MiniGameDifficulty.Morbol == Difficulty then
		DifficultyText:SetText(LSTR(370044))
	elseif  MiniGameDifficulty.Titan == Difficulty then
		DifficultyText:SetText(LSTR(370045))
	end
	self:PlayAnimation(self.AnimShow)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.DifficultChoosen)
end

--- 动画结束统一回调
function OutOnALimbChooseItemView:OnAnimationFinished(Animation)
	if Animation == self.AnimShow then
		local AniEndCallBack = self.CallBack
		if AniEndCallBack then
			AniEndCallBack()
		end
		self:ResetParticles()
	end
end

function OutOnALimbChooseItemView:ClearCallBack()
	self.CallBack = nil
end

function OutOnALimbChooseItemView:ResetParticles()
	self.P_DX_OutOnALimbChooseItem_1:ResetParticle()
	self.P_DX_OutOnALimbChooseItem_2:ResetParticle()
	_G.ObjectMgr:CollectGarbage(false)
end

return OutOnALimbChooseItemView