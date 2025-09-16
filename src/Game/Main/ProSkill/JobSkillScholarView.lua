---
--- Author: chaooren
--- DateTime: 2022-08-22 17:14
--- Description:
---

--local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProSkillSpectrumBase = require("Game/Main/ProSkill/ProSkillSpectrumBase")
local ProfProSkillViewBase = require("Game/Main/ProSkill/ProfProSkillViewBase")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local SpectrumIDMap = ProSkillDefine.SpectrumIDMap
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")

---@class JobSkillScholarView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Common_ProSkillInteract_UIBP CommonProSkillInteractView
---@field FImg_Emerald UFImage
---@field FImg_Emerald_1 UFImage
---@field FImg_Emerald_2 UFImage
---@field FImg_FairyLeave UFImage
---@field Initial UFCanvasPanel
---@field JobSkill UFCanvasPanel
---@field PanelUnlock UFCanvasPanel
---@field ProgressBar_BW UProgressBar
---@field ProgressBar_YX UProgressBar
---@field ScholarNormal UFCanvasPanel
---@field TextUnlock UFTextBlock
---@field Text_Time UTextBlock
---@field Text_TimeWhite UTextBlock
---@field Time_White UFCanvasPanel
---@field Anim_Disable_In UWidgetAnimation
---@field Anim_Disable_Out UWidgetAnimation
---@field AnimBlueWingShineLoop UWidgetAnimation
---@field AnimEmeraldHidden1 UWidgetAnimation
---@field AnimEmeraldHidden2 UWidgetAnimation
---@field AnimEmeraldHidden3 UWidgetAnimation
---@field AnimEmeraldShineLoop UWidgetAnimation
---@field AnimEmeraldShow1 UWidgetAnimation
---@field AnimEmeraldShow2 UWidgetAnimation
---@field AnimEmeraldShow3 UWidgetAnimation
---@field AnimEmeraldShowAll UWidgetAnimation
---@field AnimProgressShineLoop UWidgetAnimation
---@field AnimProgressShineStop UWidgetAnimation
---@field AnimScholarOpen UWidgetAnimation
---@field AnimToBlueWing UWidgetAnimation
---@field AnimToGreenWing UWidgetAnimation
---@field AnimUnlock UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillScholarView = LuaClass(ProfProSkillViewBase, true)

local SkillSpectrum_Scholar_CL = LuaClass(ProSkillSpectrumBase, true)
local SkillSpectrum_Scholar_YX = LuaClass(ProSkillSpectrumBase, true)
local SkillSpectrum_Scholar_BlueWing = LuaClass(ProSkillSpectrumBase, true)

function JobSkillScholarView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Common_ProSkillInteract_UIBP = nil
	--self.FImg_Emerald = nil
	--self.FImg_Emerald_1 = nil
	--self.FImg_Emerald_2 = nil
	--self.FImg_FairyLeave = nil
	--self.Initial = nil
	--self.JobSkill = nil
	--self.PanelUnlock = nil
	--self.ProgressBar_BW = nil
	--self.ProgressBar_YX = nil
	--self.ScholarNormal = nil
	--self.TextUnlock = nil
	--self.Text_Time = nil
	--self.Text_TimeWhite = nil
	--self.Time_White = nil
	--self.Anim_Disable_In = nil
	--self.Anim_Disable_Out = nil
	--self.AnimBlueWingShineLoop = nil
	--self.AnimEmeraldHidden1 = nil
	--self.AnimEmeraldHidden2 = nil
	--self.AnimEmeraldHidden3 = nil
	--self.AnimEmeraldShineLoop = nil
	--self.AnimEmeraldShow1 = nil
	--self.AnimEmeraldShow2 = nil
	--self.AnimEmeraldShow3 = nil
	--self.AnimEmeraldShowAll = nil
	--self.AnimProgressShineLoop = nil
	--self.AnimProgressShineStop = nil
	--self.AnimScholarOpen = nil
	--self.AnimToBlueWing = nil
	--self.AnimToGreenWing = nil
	--self.AnimUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillScholarView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_ProSkillInteract_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillScholarView:OnInit()
	self.Super:OnInit()
	self:BindSpectrumBehavior(SpectrumIDMap.Scholar_CL, SkillSpectrum_Scholar_CL)
	self:BindSpectrumBehavior(SpectrumIDMap.Scholar_YX, SkillSpectrum_Scholar_YX)
	self:BindSpectrumBehavior(SpectrumIDMap.Scholar_BlueWing, SkillSpectrum_Scholar_BlueWing)
	self.TextUnlock:SetText(_G.LSTR(140080))  -- 以太超流&异想量谱

	self.CurProgressBar = self.ProgressBar_YX
end

function JobSkillScholarView:OnDestroy()
	self.Super:OnDestroy()
end

function JobSkillScholarView:OnShow()
	self.Super:OnShow()
end

function JobSkillScholarView:OnHide()
	self.Super:OnHide()
end

function JobSkillScholarView:OnRegisterUIEvent()

end

function JobSkillScholarView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateBuff, self.OnUpdateBuff)
	self:RegisterGameEvent(EventID.RemoveBuff, self.OnRemoveBuff)
	self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
	self:RegisterGameEvent(EventID.UseSkillNotSummonEvent, self.OnUseSkillNotSummon)
end

function JobSkillScholarView:OnRegisterBinder()

end

function JobSkillScholarView:OnGameEventMajorDead()
	self:SetSpectrumState(false)
end

function JobSkillScholarView:OnUpdateBuff(Params)
	local BuffID = Params.IntParam1
	local EntityID = Params.ULongParam1
	--只受自身buff影响
	if EntityID ~= MajorUtil.GetMajorEntityID() then
		return
	end
	for _, value in pairs(self.SpectrumPair) do
		if value and value.Begin and value.BuffID == BuffID then
			value:OnCastBuff(Params)
		end
	end
end

function JobSkillScholarView:OnRemoveBuff(Params)
	local BuffID = Params.IntParam1
	local EntityID = Params.ULongParam1
	--只受自身buff影响
	if EntityID ~= MajorUtil.GetMajorEntityID() then
		return
	end
	for _, value in pairs(self.SpectrumPair) do
		if value and value.Begin and value.BuffID == BuffID then
			value:OnRemoveBuff(Params)
		end
	end
end

function JobSkillScholarView:SetSpectrumState(State)
    if not State then
    	self:StopAnimation(self.AnimScholarOpen)
    end
    UIUtil.SetIsVisible(self.JobSkill, State)
	UIUtil.SetIsVisible(self.ScholarNormal, not State)
	if State  then
		self:PlayAnimationToEndTime(self.AnimScholarOpen)
	end
end

function JobSkillScholarView:OnUseSkillNotSummon()
	self:PlayAnimation(self.AnimPoint)
end

local function GetBuffInfo(InBuffID)
	return _G.SkillBuffMgr:GetBuffInfo(InBuffID)
end


function SkillSpectrum_Scholar_CL:ClearBuffPile()
	for i = 1, self.CurPile do
		self.View:PlayAnimationToEndTime(self.View[string.format("AnimEmeraldHidden%d", i)])
	end
	self.CurPile = 0
end

function SkillSpectrum_Scholar_CL:OnInit()
	self.Super:OnInit()
	self.bEnableUpdate = false
	self.bEnableAdvanceUpdate = false
	self.BuffID = tonumber(_G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID)) or 0
	self.CurPile = 0
	self:ClearBuffPile()
end

function SkillSpectrum_Scholar_CL:SkillSpectrumOn()
	local BuffInfo = GetBuffInfo(self.BuffID)
	if BuffInfo then
		local Pile = BuffInfo.Pile
		self:SetBuffPile(Pile)
	end
	self.View:PlayAnimation(self.View.AnimEmeraldShineLoop, 0, 0)
end

function SkillSpectrum_Scholar_CL:SkillSpectrumOff()
	--self.CurPile = 0
	self.View:StopAnimation(self.View.AnimEmeraldShineLoop)
	self:ClearBuffPile()
end

function SkillSpectrum_Scholar_CL:OnCastBuff(BuffInfo)
	local Pile = BuffInfo.IntParam2
	if Pile ~= self.CurPile then
		self:SetBuffPile(Pile)
	end
end

function SkillSpectrum_Scholar_CL:OnRemoveBuff(_)
	self:ClearBuffPile()
end

local MaxPile <const> = 3
function SkillSpectrum_Scholar_CL:SetBuffPile(Pile)
	local ValidPile = math.min(MaxPile, Pile)
	if self.CurPile < ValidPile then
		if self.CurPile == 0 and ValidPile == MaxPile then
			self.View:PlayAnimation(self.View.AnimEmeraldShowAll)
			for i = 1, MaxPile do
				self.View:StopAnimation(self.View[string.format("AnimEmeraldHidden%d", i)])
			end
		else
			for i = self.CurPile + 1, ValidPile do
				self.View:PlayAnimation(self.View[string.format("AnimEmeraldShow%d", i)])
				self.View:StopAnimation(self.View[string.format("AnimEmeraldHidden%d", i)])
			end
		end
	elseif self.CurPile > ValidPile then
		for i = self.CurPile, ValidPile + 1, -1 do
			self.View:PlayAnimationToEndTime(self.View[string.format("AnimEmeraldHidden%d", i)])
		end
	end
	self.CurPile = ValidPile
end

function SkillSpectrum_Scholar_YX:OnInit()
	self.Super:OnInit()
	self.View:SetSpectrumState(false)
end

function SkillSpectrum_Scholar_YX:OnSpectrumDeStudy()
	self.View.ProgressBar_YX:SetPercent(0)
	self.View.Text_Time:SetText("0")
	UIUtil.SetIsVisible(self.View.FImg_FairyLeave, true)
	-- UIUtil.SetIsVisible(self.View.Initial, false)
end

function SkillSpectrum_Scholar_YX:SkillSpectrumOn()
	UIUtil.SetIsVisible(self.View.FImg_FairyLeave, false)
	self.View:SetSpectrumState(true)
	-- UIUtil.SetIsVisible(self.View.Initial, true)
	self.View:PlayAnimation(self.View.AnimProgressShineLoop, 0, 0)
end

function SkillSpectrum_Scholar_YX:ValueUpdateFunc(_, TargetValue)
	local Precent = TargetValue / (self.SpectrumMaxValue or 10000)
	self.View.CurProgressBar:SetPercent(Precent)
	self.View.Text_Time:SetText(tostring(math.floor(TargetValue / 100)))
end

-- function SkillSpectrum_Scholar_YX:ValueUpdateEachFunc(CurValue, TargetValue)

-- end

function SkillSpectrum_Scholar_YX:SkillSpectrumOff()
	self.View.ProgressBar_YX:SetPercent(0)
	self.View.Text_Time:SetText("0")
	UIUtil.SetIsVisible(self.View.FImg_FairyLeave, true)
	-- UIUtil.SetIsVisible(self.View.Initial, false)
	self.View:StopAnimation(self.View.AnimProgressShineLoop)
	self.View:SetSpectrumState(false)
end

function SkillSpectrum_Scholar_BlueWing:OnInit()
	self.Super:OnInit()
	self.BuffID = tonumber(_G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID)) or 0
	self.View.ProgressBar_BW:SetPercent(0)
	self.TimerID = 0
end

function SkillSpectrum_Scholar_BlueWing:SkillSpectrumOn()
	self.View:PlayAnimation(self.View.AnimToBlueWing)
	self.View:PlayAnimation(self.View.AnimBlueWingShineLoop, 0, 0)
	local BuffInfo = GetBuffInfo(self.BuffID)
	if BuffInfo then
		local ExpdTime = BuffInfo.ExpdTime
		local Time = (ExpdTime - TimeUtil.GetServerTimeMS()) / 1000
		local IntTime = math.ceil(Time)
		self.View.Text_TimeWhite:SetText(IntTime)
		self.TimerID = self:CreateLoopTimer(self, self.BuffCountDown, IntTime - Time, 1)
	end
	self.View.ProgressBar_BW:SetPercent(self.View.CurProgressBar.Percent)
	self.View.CurProgressBar = self.View.ProgressBar_BW
end

function SkillSpectrum_Scholar_BlueWing:OnCastBuff(BuffInfo)
	local ExpdTime = BuffInfo.ULongParam3
	local Time = (ExpdTime - TimeUtil.GetServerTimeMS()) / 1000
	local IntTime = math.ceil(Time)
	self.View.Text_TimeWhite:SetText(IntTime)
	if self.TimerID > 0 then
		self:ReleaseLoopTimer(self.TimerID)
	end
	self.TimerID = self:CreateLoopTimer(self, self.BuffCountDown, IntTime - Time, 1)
end

function SkillSpectrum_Scholar_BlueWing:BuffCountDown()
	local Widget = self.View.Text_TimeWhite
	if Widget ~= nil then
		local Time = tonumber(Widget:GetText())
		if Time > 0 then
			Time = Time - 1
			Widget:SetText(tostring(Time))
			return
		end
	end
end

function SkillSpectrum_Scholar_BlueWing:SkillSpectrumOff()
	self.View:StopAnimation(self.View.AnimBlueWingShineLoop)
	self.View:PlayAnimation(self.View.AnimToGreenWing)
	self.View.ProgressBar_YX:SetPercent(self.View.CurProgressBar.Percent)
	self.View.CurProgressBar = self.View.ProgressBar_YX
	self:ReleaseLoopTimer(self.TimerID)
	self.TimerID = 0
end

return JobSkillScholarView