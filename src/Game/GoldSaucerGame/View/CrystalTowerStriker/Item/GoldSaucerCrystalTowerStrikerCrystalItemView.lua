---
--- Author: Administrator
--- DateTime: 2024-03-08 19:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CrystalTowerInteractionCfg = require("TableCfg/CrystalTowerInteractionCfg")
local ProtoRes = require("Protocol/ProtoRes")
local CrystalTowerInteractionCategory = ProtoRes.CrystalTowerInteractionCategory
local CachePosY = 450
local StartClipPosY = 215
local SpecalStartClipPosY = 235
local ResetComboPosY = 360
local SwitchWidgetIndex = {Blue = 1, Purple = 2, Yellow = 3, Gray = 4, Red = 5, StarLight = 6}

local UE = _G.UE
---@class GoldSaucerCrystalTowerStrikerCrystalItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field EFFBlue1 UFCanvasPanel
---@field EFFGrey UFCanvasPanel
---@field EFFPanel01 UFCanvasPanel
---@field EFFPanel02 UFCanvasPanel
---@field EFFPurple UFCanvasPanel
---@field EFFRED UFCanvasPanel
---@field EFFStar UFCanvasPanel
---@field EFFYellow UFCanvasPanel
---@field FWidgetSwitcher_0 UFWidgetSwitcher
---@field IconCrystalBlue1 UProgressBar
---@field IconCrystalBlue1Click UProgressBar
---@field IconCrystalGrey UProgressBar
---@field IconCrystalPurple UProgressBar
---@field IconCrystalPurpleClick UProgressBar
---@field IconCrystalRad UProgressBar
---@field IconCrystalRadClick UProgressBar
---@field IconCrystalStar UProgressBar
---@field IconCrystalStarClick UProgressBar
---@field IconCrystalYellow UProgressBar
---@field IconCrystalYellowClick UProgressBar
---@field Image_114 UImage
---@field P_DX__CrystalTowerStriker_1 UUIParticleEmitter
---@field P_DX__CrystalTowerStriker_2 UUIParticleEmitter
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCrystalTowerStrikerCrystalItemView = LuaClass(UIView, true)

function GoldSaucerCrystalTowerStrikerCrystalItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.EFFBlue1 = nil
	--self.EFFGrey = nil
	--self.EFFPanel01 = nil
	--self.EFFPanel02 = nil
	--self.EFFPurple = nil
	--self.EFFRED = nil
	--self.EFFStar = nil
	--self.EFFYellow = nil
	--self.FWidgetSwitcher_0 = nil
	--self.IconCrystalBlue1 = nil
	--self.IconCrystalBlue1Click = nil
	--self.IconCrystalGrey = nil
	--self.IconCrystalPurple = nil
	--self.IconCrystalPurpleClick = nil
	--self.IconCrystalRad = nil
	--self.IconCrystalRadClick = nil
	--self.IconCrystalStar = nil
	--self.IconCrystalStarClick = nil
	--self.IconCrystalYellow = nil
	--self.IconCrystalYellowClick = nil
	--self.Image_114 = nil
	--self.P_DX__CrystalTowerStriker_1 = nil
	--self.P_DX__CrystalTowerStriker_2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:OnInit()
	self.ID = 0
	self.TrackIndex = 0
	self.bIsShowing = false
	self.DefaultSize = UE.FVector2D(112, 120)
	self.ShootProvider = nil
	self.AlreadyInteract = false
	self.Binders = {
		{"Category", UIBinderValueChangedCallback.New(self, nil, self.OnCategoryChange)},
	}
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:OnDestroy()

end

function GoldSaucerCrystalTowerStrikerCrystalItemView:OnShow()

end

function GoldSaucerCrystalTowerStrikerCrystalItemView:OnHide()

end

function GoldSaucerCrystalTowerStrikerCrystalItemView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.Btn, self.OnInteractBtnClick)
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:OnRegisterGameEvent()

end

function GoldSaucerCrystalTowerStrikerCrystalItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:OnInteractBtnClick()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	local Pos = UIUtil.CanvasSlotGetPosition(self)
	local GameInst = GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
	local InteractionRule = GameInst.InteractionRule
	if Pos.Y < InteractionRule.BeginExcellentInteractY or self.AlreadyInteract then
        return
    end
	self.AlreadyInteract = true
	self:OnInteractLocal(Pos.Y)
	GameInst:OnInteract(Pos.Y, ViewModel.Category, self.TrackIndex, self.ID)

	-- _G.FLOG_WARNING("OnInteract ID = %s", self.ID)

	-- if self.FallTimer ~= nil then
	-- 	self:UnRegisterTimer(self.FallTimer)
	-- end

	-- self:RegisterTimer(function()
	-- 	local Provider = GameInst:GetProviderByPos(self.TrackIndex)
	-- 	Provider:CachInteraction(self.ID)
	-- end, 0.5)
end

--- @type 设置交互物的配置
function GoldSaucerCrystalTowerStrikerCrystalItemView:Falling(Category)
    local Cfg = CrystalTowerInteractionCfg:FindCfgByKey(Category)
    if Cfg == nil then
        return
    end
    local Scale = Cfg.Scale ~= 0 and Cfg.Scale or 1
    self.Velocity = Cfg.Velocity
    local Acceleration = Cfg.Acceleration
	local DefaultSize = UE.FVector2D(112, 120)
    UIUtil.CanvasSlotSetSize(self, DefaultSize * Scale)
    UIUtil.SetIsVisible(self, true)
	local ViewModel = self:GetViewModel()
    local IntervalTime = 0.05
	local GameInst = GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()

	if GameInst == nil then
		return
	end

    local function Fall()
        local MoveDistance = self:GetDistance(self.Velocity, Acceleration, IntervalTime)
        self:UpdateVelocity(IntervalTime, Acceleration)
        local CurPos = UIUtil.CanvasSlotGetPosition(self)
		-- if self.ID == 1 then
		-- 	print(tostring(CurPos.Y))
		-- end
		if CurPos.Y > CachePosY then
			if self.FallTimer ~= nil then
				self:UnRegisterTimer(self.FallTimer)
			end
			if self.ShootProvider ~= nil then
				self.ShootProvider:CachInteraction(self)
			end
			if GameInst ~= nil then
				GameInst:CheckIsFinishRoundAndSend()
			end
			return
		end

		if ViewModel.Category ~= CrystalTowerInteractionCategory.CT_CATEGORY_ERROR and CurPos.Y >= ResetComboPosY and not self.AlreadyInteract then
			GameInst:ResetComboNum()
		end

        local TargetPos = CurPos + UE.FVector2D(0, MoveDistance)
        UIUtil.CanvasSlotSetPosition(self, TargetPos)
		if self.AlreadyInteract then
			self:UpdateProgress(CurPos.Y)
		end
    end

    self.FallTimer = self:RegisterTimer(Fall, 0, IntervalTime, 0)
end

--- @type 匀加速公式
function GoldSaucerCrystalTowerStrikerCrystalItemView:GetDistance(Velocity, Acceleration, Time)
    return Velocity * Time + 0.5 * Acceleration * Velocity * Velocity
end

--- @type 更新速度
function GoldSaucerCrystalTowerStrikerCrystalItemView:UpdateVelocity(Time, Acceleration)
    local Velocity = self.Velocity
    self.Velocity = Velocity + Time * Acceleration
end


function GoldSaucerCrystalTowerStrikerCrystalItemView:SetID(ID)
	self.ID = ID
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:GetID(ID)
	return self.ID
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:SetbShow(bShow)
	self.bIsShowing = bShow
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:GetbIsShowing()
	return self.bIsShowing
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:UpdateTrackIndex(TrackIndex)
	self.TrackIndex = TrackIndex
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:GetTrackIndex()
	return self.TrackIndex
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:GetViewModel()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	return ViewModel
end

--- @type 保存下来是哪个Provider发射的交互物
function GoldSaucerCrystalTowerStrikerCrystalItemView:SetShootProvider(Provider)
	self.ShootProvider = Provider
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:OnInteractLocal(PosY)
	self:ChangeClickImgVisible(true)
	self:UpdateProgress(PosY)
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:ChangeClickImgVisible(bVisible)
	UIUtil.SetIsVisible(self.IconCrystalBlue1Click, bVisible)
	UIUtil.SetIsVisible(self.IconCrystalPurpleClick, bVisible)
	UIUtil.SetIsVisible(self.IconCrystalYellowClick, bVisible)
	UIUtil.SetIsVisible(self.IconCrystalRadClick, bVisible)
	UIUtil.SetIsVisible(self.IconCrystalStarClick, bVisible)

	UIUtil.SetIsVisible(self.EFFBlue1, not bVisible)
	UIUtil.SetIsVisible(self.EFFPurple, not bVisible)
	UIUtil.SetIsVisible(self.EFFYellow, not bVisible)
	UIUtil.SetIsVisible(self.EFFGrey, not bVisible)
	UIUtil.SetIsVisible(self.EFFRED, not bVisible)	
	UIUtil.SetIsVisible(self.EFFStar, not bVisible)	

end

function GoldSaucerCrystalTowerStrikerCrystalItemView:UpdateProgress(PosY)
	local Size = UIUtil.CanvasSlotGetSize(self)
	local NeedStartClipPosY
	local ViewModel = self:GetViewModel()
	if ViewModel.Category > CrystalTowerInteractionCategory.CT_CATEGORY_ERROR then
		local GameInst = GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
		local ResultVal = GameInst:ConstructCenterResultData(PosY)
		if ResultVal.bProfectVisible then
			NeedStartClipPosY = SpecalStartClipPosY
		else
			NeedStartClipPosY = StartClipPosY
		end
	else	
		NeedStartClipPosY = StartClipPosY
	end
	local NeedEndClipPosY = NeedStartClipPosY + Size.Y
	local CurPos = UIUtil.CanvasSlotGetPosition(self)
	local ClipPro = CurPos.Y - NeedStartClipPosY
	local EndPro = math.clamp(1 - ClipPro / (NeedEndClipPosY - NeedStartClipPosY), 0, 1)

	-- _G.FLOG_ERROR("Provider:CachInteraction(self.ID) EndPro = %s ", EndPro)

	self.IconCrystalBlue1:SetPercent(EndPro)
	self.IconCrystalBlue1Click:SetPercent(EndPro)

	self.IconCrystalPurple:SetPercent(EndPro)
	self.IconCrystalPurpleClick:SetPercent(EndPro)

	self.IconCrystalYellow:SetPercent(EndPro)
	self.IconCrystalYellowClick:SetPercent(EndPro)

	self.IconCrystalGrey:SetPercent(EndPro)

	self.IconCrystalRad:SetPercent(EndPro)
	self.IconCrystalRadClick:SetPercent(EndPro)

	self.IconCrystalStar:SetPercent(EndPro)
	self.IconCrystalStarClick:SetPercent(EndPro)
end

--- @type 
function GoldSaucerCrystalTowerStrikerCrystalItemView:Reset()
	self.bIsShowing = false
	self.AlreadyInteract = false

	self.IconCrystalBlue1:SetPercent(1)
	self.IconCrystalBlue1Click:SetPercent(1)

	self.IconCrystalPurple:SetPercent(1)
	self.IconCrystalPurpleClick:SetPercent(1)

	self.IconCrystalYellow:SetPercent(1)
	self.IconCrystalYellowClick:SetPercent(1)

	self.IconCrystalGrey:SetPercent(1)

	self.IconCrystalRad:SetPercent(1)
	self.IconCrystalRadClick:SetPercent(1)
	self.IconCrystalStar:SetPercent(1)
	self.IconCrystalStarClick:SetPercent(1)

	UIUtil.SetIsVisible(self.EFFBlue1, true)
	UIUtil.SetIsVisible(self.EFFPurple, true)
	UIUtil.SetIsVisible(self.EFFYellow, true)
	UIUtil.SetIsVisible(self.EFFGrey, true)
	UIUtil.SetIsVisible(self.EFFRED, true)
	UIUtil.SetIsVisible(self.EFFStar, true)

	UIUtil.SetIsVisible(self.IconCrystalBlue1Click, false)
	UIUtil.SetIsVisible(self.IconCrystalPurpleClick, false)
	UIUtil.SetIsVisible(self.IconCrystalYellowClick, false)
	UIUtil.SetIsVisible(self.IconCrystalRadClick, false)
	UIUtil.SetIsVisible(self.IconCrystalStarClick, false)

	self:UnRegisterAllTimer()
	local ViewModel = self:GetViewModel()
	ViewModel:ResetVM()
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:UpdateParticle(Category)
	local bEffectVisible01 = Category and Category > 0
	UIUtil.SetIsVisible(self.EFFPanel01, bEffectVisible01)
	local bEffectVisible02 = Category and Category == 5--CT_CATEGORY_FINAL_ONE
	UIUtil.SetIsVisible(self.EFFPanel02, bEffectVisible02)
	if bEffectVisible01 then
		self.P_DX__CrystalTowerStriker_1:Play()
	else
		self.P_DX__CrystalTowerStriker_1:ResetParticle()
	end
	if bEffectVisible02 then
		self.P_DX__CrystalTowerStriker_2:Play()
	else
		self.P_DX__CrystalTowerStriker_2:ResetParticle()
	end
end

function GoldSaucerCrystalTowerStrikerCrystalItemView:OnCategoryChange(NewValue)
	local NewIndex = NewValue or 0
	self.FWidgetSwitcher_0:SetActiveWidgetIndex(NewIndex)
	self:UpdateParticle(NewIndex)
end

return GoldSaucerCrystalTowerStrikerCrystalItemView