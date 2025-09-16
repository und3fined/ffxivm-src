---
--- Author: chaooren
--- DateTime: 2022-03-16 14:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillUtil = require("Utils/SkillUtil")
local ActorUtil = require("Utils/ActorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")

local TimerInterval = 0.06

---@class SkillChantView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ProBarChant UProgressBar
---@field SkillChant UFCanvasPanel
---@field TextBreak UFTextBlock
---@field TextChantCD UFTextBlock
---@field TextName UFTextBlock
---@field AAnimIn UWidgetAnimation
---@field AAnimOut UWidgetAnimation
---@field AnimProBar UWidgetAnimation
---@field AnimStop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillChantView = LuaClass(UIView, true)

function SkillChantView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ProBarChant = nil
	--self.SkillChant = nil
	--self.TextBreak = nil
	--self.TextChantCD = nil
	--self.TextName = nil
	--self.AAnimIn = nil
	--self.AAnimOut = nil
	--self.AnimProBar = nil
	--self.AnimStop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillChantView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillChantView:OnInit()
	rawset(self, "bComplete", true)
	self.TextBreak:SetText(_G.LSTR(140096))
end

function SkillChantView:OnDestroy()

end

function SkillChantView:OnEntityIDUpdate(EntityID, bMajor)
	self.EntityID = EntityID
	self.bMajor = bMajor
end

function SkillChantView:Clear()
	self:StopAllAnimations()
	self.SkillChant:SetRenderOpacity(0)
	rawset(self, "bComplete", true)
end

function SkillChantView:OnShow()
	if not self.bMajor then
		-- 技能系统中, 防止下次打开界面出现动画残留
		self:Clear()
	end
end

function SkillChantView:OnHide()

end

function SkillChantView:OnRegisterUIEvent()

end

function SkillChantView:OnRegisterGameEvent()
	if self.bMajor then
		self:RegisterGameEvent(EventID.MajorUseSkill, self.OnMajorUseSkill)
		self:RegisterGameEvent(EventID.StartSkillSing, self.OnMajorSing)
		self:RegisterGameEvent(EventID.StopSkillSing, self.OnMajorBreakSing)
	else
		self:RegisterGameEvent(EventID.TrivialSkillStart, self.OnSkillStart)
		self:RegisterGameEvent(EventID.SkillSystemSing, self.OnSkillSystemSing)
	end
	self:RegisterGameEvent(EventID.MajorBreakSing, self.OnMajorBreakSing)
	self:RegisterGameEvent(EventID.SkillEnd, self.OnSkillEnd)
	self:RegisterGameEvent(EventID.MajorSing, self.OnMajorSing)
end

function SkillChantView:OnRegisterBinder()

end

function SkillChantView:OnMajorUseSkill(Params)
	if self.bMajor then
		local SkillID = Params.IntParam1
		local SubSkillID = Params.IntParam2
		if SkillID then
			self:StartSimulateSing(SkillID, SubSkillID)
		end
	end
end

function SkillChantView:OnSkillStart(Params)
	local SkillID = Params.IntParam2
	local SubSkillID = Params.IntParam1
	local EntityID = Params.ULongParam1
	if EntityID == self.EntityID and SkillID then
		-- 技能系统中, 单独屏蔽掉极限技
		if not self.bMajor and _G.SkillLimitMgr:IsLimitSkill(SkillID) then
			return
		end
		self:StartSimulateSing(SkillID, SubSkillID)
	end
end

function SkillChantView:StartSimulateSing(SkillID, SubSkillID)
	local SimulateSingTime = SkillUtil.GetSimulateSingTime(SkillID, SubSkillID)
	if SimulateSingTime and SimulateSingTime > 0 then
		local ShortActionTime = 0
		local AttributeComponent = ActorUtil.GetActorAttributeComponent(self.EntityID)
		if AttributeComponent then
			ShortActionTime = AttributeComponent:GetAttrValue(ProtoCommon.attr_type.attr_shorten_action_time) / 10000
		end
		SimulateSingTime = SimulateSingTime * (1 - ShortActionTime)
		local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
		local ReviseSkillAction = LogicData:GetReviseSkillAction(SkillID)
		SimulateSingTime = ReviseSkillAction == nil and SimulateSingTime or SimulateSingTime * (ReviseSkillAction / 10000)
		self:OnMajorSing({EntityID = self.EntityID, SkillID = SkillID, Time = SimulateSingTime})
	end
end

function SkillChantView:OnSkillSystemSing(Params)
	self:OnMajorSing(Params)
end

function SkillChantView:OnSkillEnd(Params)
	local SkillID = Params.IntParam2
	local SubSkillID = Params.IntParam1
	local EntityID = Params.ULongParam1

	if EntityID == self.EntityID and SkillID then
		local SimulateSingTime = SkillUtil.GetSimulateSingTime(SkillID, SubSkillID)
		if SimulateSingTime and SimulateSingTime > 0 then
			self:OnMajorBreakSing({EntityID = self.EntityID})
		end
	end
end

function SkillChantView:OnMajorSing(Params)
	if Params.EntityID ~= self.EntityID then
		return
	end
	rawset(self, "bComplete", false)
	local Time = (Params.Time) / 1000
	rawset(self, "Time", Time)

	local ChantTimer = rawget(self, "ChantTimer")
	if ChantTimer then
		self:UnRegisterTimer(ChantTimer)
	end
	self:StopAllAnimations()
	self:PlayAnimation(self.AAnimIn)
	self.ProBarChant:SetPercent(0)

	local IntTime = math.floor(Time)
	local ShowTime = string.format("%02d:%02d", IntTime, math.floor((Time - IntTime) * 100))
	self.TextChantCD:SetText(ShowTime)

	local SkillName = SkillMainCfg:FindValue(Params.SkillID, "SkillName") or ""
	self.TextName:SetText(LSTR(SkillName))

	rawset(self, "RecordTimestamp", TimeUtil.GetLocalTimeMS())
	rawset(self, "ChantTimer", self:RegisterTimer(self.ChantTick, 0, TimerInterval, 0))
	--进度条UMG动画默认时间是1s
	self:PlayAnimation(self.AnimProBar, 0, 1, 0, 1 / Time)
	if self.bMajor then
		EventMgr:PostEvent(EventID.SkillChantViewShow)
	end
end

function SkillChantView:OnMajorBreakSing(Params)
	if Params.EntityID ~= self.EntityID then
		return
	end
	if rawget(self, "bComplete") == true then
		return
	end
	rawset(self, "bComplete", true)

	local ChantTimer = rawget(self, "ChantTimer")
	if ChantTimer then
		self:UnRegisterTimer(ChantTimer)
		rawset(self, "ChantTimer", nil)
	end
	self:PlayAnimationToEndTime(self.AnimStop)

	--在停止动画后保持进度条进度
	local PreProbarValue = self.ProBarChant.Percent
	self:StopAnimation(self.AnimProBar)
	self.ProBarChant:SetPercent(PreProbarValue)

	if self.bMajor then
		EventMgr:PostEvent(EventID.SkillChantViewHide)
	end
end

function SkillChantView:ChantTick()
	local Time = rawget(self, "Time")
	if Time <= 0 then
		self:UnRegisterTimer(rawget(self, "ChantTimer"))
		rawset(self, "ChantTimer", nil)
		self:OnChantSuccess()
		return
	end
	--self.ProBarChant:SetPercent(self.ProBarChant.Percent + Params.Percent)
	local IntTime = math.floor(Time)
	local ShowTime = string.format("%02d:%02d", IntTime, math.floor((Time - IntTime) * 100))
	self.TextChantCD:SetText(ShowTime)

	local CurTimestamp = TimeUtil.GetLocalTimeMS()
	local Diff = (CurTimestamp - rawget(self, "RecordTimestamp")) / 1000
	rawset(self, "RecordTimestamp", CurTimestamp)
	rawset(self, "Time", Time - Diff)
end

function SkillChantView:OnChantSuccess()
	rawset(self, "bComplete", true)
	self:OnChainEnd()
	if self.bMajor then
		EventMgr:PostEvent(EventID.SkillChantViewHide)
	end
end

function SkillChantView:OnChainEnd()
	self:PlayAnimationToEndTime(self.AAnimOut)
end

return SkillChantView