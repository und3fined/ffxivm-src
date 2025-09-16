---
--- Author: chaooren
--- DateTime: 2022-04-07 14:28
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SkillUtil = require("Utils/SkillUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local ProSkillSpectrumBase = require("Game/Main/ProSkill/ProSkillSpectrumBase")
local ProfProSkillViewBase = require("Game/Main/ProSkill/ProfProSkillViewBase")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local SpectrumIDMap = ProSkillDefine.SpectrumIDMap

---@class JobSkillKnightView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Knight_Cursor UCanvasPanel
---@field Knight_Full UCanvasPanel
---@field MainUIMoveControl_UIBP MainUIMoveControlView
---@field ProgressBar_Blue UProgressBar
---@field ProgressBar_Mask UProgressBar
---@field ProgressBar_Purple UProgressBar
---@field Text_Value UTextBlock
---@field Value UFCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillKnightView = LuaClass(ProfProSkillViewBase, true)
local SkillSpectrum_PALADIN = LuaClass(ProSkillSpectrumBase, true)

local Knight_Cursor_Position_X = -5
local Knight_Cursor_Position_X_End = 240
local Knight_Cursor_Position_Y = 0

function JobSkillKnightView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Knight_Cursor = nil
	--self.Knight_Full = nil
	--self.MainUIMoveControl_UIBP = nil
	--self.ProgressBar_Blue = nil
	--self.ProgressBar_Mask = nil
	--self.ProgressBar_Purple = nil
	--self.Text_Value = nil
	--self.Value = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillKnightView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MainUIMoveControl_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillKnightView:OnInit()
	self.Super:OnInit()
	self:BindSpectrumBehavior(SpectrumIDMap.PALADIN, SkillSpectrum_PALADIN)
	self:BindSpectrumBehavior(SpectrumIDMap.PVP, SkillSpectrum_PALADIN)
	self.TextUnlock:SetText(_G.LSTR(140093))  -- 忠义量谱
end

function JobSkillKnightView:OnDestroy()

end

function JobSkillKnightView:OnShow()
	self.Super:OnShow()
end

function JobSkillKnightView:OnHide()

end

function JobSkillKnightView:OnRegisterUIEvent()

end

function JobSkillKnightView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RemoveBuff, self.OnRemoveBuff)
end

function JobSkillKnightView:OnRegisterBinder()

end

function JobSkillKnightView:OnRemoveBuff(Params)
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

local function KnightCursorPos(Value)
	return (Knight_Cursor_Position_X_End - Knight_Cursor_Position_X) * Value
end


function SkillSpectrum_PALADIN:OnInit()
	self.Super:OnInit()
	self:SkillSpectrumOff()
	self.BuffID = tonumber(_G.MainProSkillMgr:GetSpectrumTypeParams(self.SpectrumID)) or 0
end

function SkillSpectrum_PALADIN:SkillSpectrumOn()
	self.CurrentProgressBar = self.View.ProgressBar_Purple
	UIUtil.SetIsVisible(self.View.Knight_Cursor, true)
end

function SkillSpectrum_PALADIN:SkillSpectrumOff()
	self.View.ProgressBar_Purple:SetPercent(0)
	UIUtil.SetIsVisible(self.View.ProgressBar_Purple, true)
	self.View.ProgressBar_Blue:SetPercent(1)
	UIUtil.SetIsVisible(self.View.ProgressBar_Blue, false)
	UIUtil.SetIsVisible(self.View.ProgressBar_Mask, false)
	self.View.ProgressBar_Mask:SetPercent(0)
	UIUtil.SetIsVisible(self.View.Knight_Cursor, false)
	self.View.Knight_Cursor.Slot:SetPosition(_G.UE.FVector2D(Knight_Cursor_Position_X, Knight_Cursor_Position_Y))
	self.View.Text_Value:SetText("0")
end

function SkillSpectrum_PALADIN:ValueUpdateFunc(CurValue, TargetValue)
	self.View.Text_Value:SetText(tostring(math.floor(TargetValue / 100)))
end

function SkillSpectrum_PALADIN:ValueUpdateEachFunc(CurValue)
	local Value = CurValue / self.SpectrumMaxValue
	if Value >= 1 then
		if self.CurrentProgressBar ~= self.View.ProgressBar_Blue then
			self.CurrentProgressBar = self.View.ProgressBar_Blue
			UIUtil.SetIsVisible(self.View.ProgressBar_Purple, false)
			UIUtil.SetIsVisible(self.View.ProgressBar_Blue, true)
		end
		
		UIUtil.SetIsVisible(self.View.ProgressBar_Mask, true)
	elseif Value <= 0 then
		-- if self.CurrentProgressBar ~= self.View.ProgressBar_Purple then
		-- 	self.CurrentProgressBar = self.View.ProgressBar_Purple
		-- 	UIUtil.SetIsVisible(self.View.ProgressBar_Purple, true)
		-- 	UIUtil.SetIsVisible(self.View.ProgressBar_Blue, false)
		-- end
		--UIUtil.SetIsVisible(self.View.Mask3, false)
	end
	if UIUtil.IsVisible(self.View.ProgressBar_Mask) then
		self.View.ProgressBar_Mask:SetPercent(Value)
	end
	local CursorOffsetX = KnightCursorPos(Value)
	self.View.Knight_Cursor.Slot:SetPosition(_G.UE.FVector2D(CursorOffsetX + Knight_Cursor_Position_X, Knight_Cursor_Position_Y))

	self.View.ProgressBar_Blue:SetPercent(Value)
	self.View.ProgressBar_Purple:SetPercent(Value)
end

function SkillSpectrum_PALADIN:OnRemoveBuff(BuffInfo)
	UIUtil.SetIsVisible(self.View.ProgressBar_Mask, false)
	if self.CurrentProgressBar ~= self.View.ProgressBar_Purple then
		self.CurrentProgressBar = self.View.ProgressBar_Purple
		UIUtil.SetIsVisible(self.View.ProgressBar_Purple, true)
		UIUtil.SetIsVisible(self.View.ProgressBar_Blue, false)
	end
end

return JobSkillKnightView