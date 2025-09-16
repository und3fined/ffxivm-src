---
--- Author: peterxie
--- DateTime:
--- Description: 战场态势，水晶状态显示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local PVPColosseumHeaderVM = require("Game/PVP/Colosseum/VM/PVPColosseumHeaderVM")
local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")
local ColosseumTeam = PVPColosseumDefine.ColosseumTeam
local ColosseumHeaderCrystalState = PVPColosseumDefine.ColosseumHeaderCrystalState
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")


---@class PVPColosseumCrystalItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EffectCrystalBreach UFCanvasPanel
---@field IconCrystal UFImage
---@field ImgArrowL UFImage
---@field ImgArrowR UFImage
---@field ImgCrystalBreach UFImage
---@field PanelArrow UFCanvasPanel
---@field AnimArrowLLoop UWidgetAnimation
---@field AnimArrowRLoop UWidgetAnimation
---@field AnimCompletion UWidgetAnimation
---@field AnimCrystalBreachBlueLoop UWidgetAnimation
---@field AnimCrystalBreachRedLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumCrystalItemView = LuaClass(UIView, true)

function PVPColosseumCrystalItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EffectCrystalBreach = nil
	--self.IconCrystal = nil
	--self.ImgArrowL = nil
	--self.ImgArrowR = nil
	--self.ImgCrystalBreach = nil
	--self.PanelArrow = nil
	--self.AnimArrowLLoop = nil
	--self.AnimArrowRLoop = nil
	--self.AnimCompletion = nil
	--self.AnimCrystalBreachBlueLoop = nil
	--self.AnimCrystalBreachRedLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumCrystalItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumCrystalItemView:OnInit()
	self.Binders =
	{
        { "IconCrystal", UIBinderSetBrushFromAssetPath.New(self, self.IconCrystal) },
        { "IconCrystalLeft", UIBinderSetBrushFromAssetPath.New(self, self.ImgArrowL, nil, nil, true) },
        { "IconCrystalRight", UIBinderSetBrushFromAssetPath.New(self, self.ImgArrowR, nil, nil, true) },
		{ "IconCrystalBreaking", UIBinderSetBrushFromAssetPath.New(self, self.ImgCrystalBreach, nil, nil, true) },

		{ "CrystalState", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCrystalState) },
	}
end

function PVPColosseumCrystalItemView:OnDestroy()

end

function PVPColosseumCrystalItemView:OnShow()

end

function PVPColosseumCrystalItemView:OnHide()

end

function PVPColosseumCrystalItemView:OnRegisterUIEvent()

end

function PVPColosseumCrystalItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PVPColosseumCheckPointUpdate, self.OnGameEventPVPColosseumCheckPointUpdate)
end

function PVPColosseumCrystalItemView:OnRegisterBinder()
	self:RegisterBinders(PVPColosseumHeaderVM, self.Binders)
end

---水晶突破完成，播放对应动效
function PVPColosseumCrystalItemView:OnGameEventPVPColosseumCheckPointUpdate(Params)
	self:PlayAnimation(self.AnimCompletion)
end

---水晶UI状态变化，播放对应动效
function PVPColosseumCrystalItemView:OnValueChangedCrystalState(Value)
	local LastAnim = self.CurrAnim
	if LastAnim then
		self:StopAnimation(LastAnim)
	end

	local IsTeamB = (_G.PVPColosseumMgr:GetTeamIndex() == ColosseumTeam.COLOSSEUM_TEAM_2)
	local CurrStateAnim

	local crstate = Value
	if crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_INACTIVE then

	elseif crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_NEUTRAL then

	elseif crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_DEADLOCK then

	elseif crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMA then
		CurrStateAnim = self.AnimArrowRLoop

	elseif crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMA_CHECK then
		CurrStateAnim = IsTeamB and self.AnimCrystalBreachRedLoop or self.AnimCrystalBreachBlueLoop

	elseif crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMB then
		CurrStateAnim = self.AnimArrowLLoop

	elseif crstate == ColosseumHeaderCrystalState.PVPCOLOSSEUM_HEADER_CRYSTAL_STATE_TEAMB_CHECK then
		CurrStateAnim = IsTeamB and self.AnimCrystalBreachBlueLoop or self.AnimCrystalBreachRedLoop
	end

	self.CurrAnim = CurrStateAnim
	if self.CurrAnim then
		self:PlayAnimation(self.CurrAnim, 0, 0)
	end
end

return PVPColosseumCrystalItemView