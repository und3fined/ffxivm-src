local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")

local ProfProSkillViewBase = LuaClass(UIView, true)

local AutoRaiseTickInterval = 0.5

function ProfProSkillViewBase:OnInit()
	self.SpectrumPair = {}
    self.SpectrumTimer = {}
	self.UnLearnSpectrumPair = {}

end

function ProfProSkillViewBase:OnShow()
	local SpectrumIDs = self.Params
	if not SpectrumIDs then
		FLOG_ERROR("ProfProSkillViewBase:OnShow Falid")
		return
	end

	local SubViews = self.SubViews
	if SubViews then
		for i = 1, #SubViews do
			local v = SubViews[i]
			if v["OnEntityIDUpdate"] ~= nil then
				v:OnEntityIDUpdate(MajorUtil.GetMajorEntityID(), true)
			end
		end
	end

	local NewSpectrumIDs = {}
	local SpectrumPair = {}
	for _, value in ipairs(SpectrumIDs) do
		if value ~= 0 then
			local ViewData = self.SpectrumPair[value]
			if ViewData then
				--切图后清空HUD导致武僧量谱拳意条不可见
				--这里先调用一次量谱学习修复下
				ViewData:OnSpectrumStudy()

				local IsBegin = _G.MainProSkillMgr:GetSpectrumStart(value)
				if IsBegin == true then
					if ViewData.Begin == false then
						self:OnSpectrumOn(value)
					else
						self:UpdateToTargetValue(value, 0, _G.MainProSkillMgr:GetCurrentResource(value))
					end
				elseif IsBegin == false and ViewData.Begin == true then
					self:OnSpectrumOff(value)
				end
				
				SpectrumPair[value] = ViewData
			else
				table.insert(NewSpectrumIDs, value)
			end
			self.SpectrumPair[value] = nil
		end
	end

	--这里先取消学习、再学习新量谱，避免处理相同资源带来的表现错误
	for key, value in pairs(self.SpectrumPair) do
		if value.Begin == true then
			self:OnSpectrumOff(key)
		end
		value:OnSpectrumDeStudy()
		value:OnDestroy()
		self.UnLearnSpectrumPair[key] = value
	end

	self.SpectrumPair = SpectrumPair

	local ReadyToStartList = {}
	for _, value in ipairs(NewSpectrumIDs) do
		local SpectrumInstance = self.UnLearnSpectrumPair[value]
		if SpectrumInstance then
			SpectrumInstance:InternalInit()
			self.SpectrumPair[value] = SpectrumInstance
			local IsBegin = _G.MainProSkillMgr:GetSpectrumStart(value)
			--这里要等所有量谱都init完成后再开启
			if IsBegin then
				table.insert(ReadyToStartList, value)
				--self:OnSpectrumOn(value)
			end
		end
	end

	for _, value in ipairs(ReadyToStartList) do
		self:OnSpectrumOn(value)
	end
end

function ProfProSkillViewBase:OnHide()
	for key, value in pairs(self.SpectrumPair) do
		if value.Begin == true then
			self:OnSpectrumOff(key)
		end
		value:OnSpectrumDeStudy()
		value:OnDestroy()
	end
end

function ProfProSkillViewBase:OnDestroy()
	for _, value in pairs(self.SpectrumPair) do
		value:OnDestroy()
	end
end

function ProfProSkillViewBase:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.MajorUseSkill, self.OnMajorUseSkill)
	self:RegisterGameEvent(EventID.SkillSpectrumUpdate, self.OnSpectrumUpdate)
	self:RegisterGameEvent(EventID.SkillSpectrumOn, self.OnSpectrumOn)
	self:RegisterGameEvent(EventID.SkillSpectrumOff, self.OnSpectrumOff)
	self:RegisterGameEvent(EventID.SkillSpectrumValueUpdate, self.OnSpectrumMaxValueUpdate)
	self:RegisterGameEvent(EventID.SpectrumsUnlock, self.OnSpectrumsUnlock)
	--self:RegisterGameEvent(EventID.UpdateBuff, self.OnCastBuff)
	--self:RegisterGameEvent(EventID.RemoveBuff, self.OnRemoveBuff)
end

function ProfProSkillViewBase:BindSpectrumBehavior(SpectrumID, BehaviorClass)
	if self.UnLearnSpectrumPair == nil then
        FLOG_ERROR("[ProSkill] view miss super::oninit")
		return
	end
	local SpectrumInstance = BehaviorClass.New(self, SpectrumID)
	SpectrumInstance:OnSpectrumDeStudy()
	self.UnLearnSpectrumPair[SpectrumID] = SpectrumInstance
end

function ProfProSkillViewBase:OnSpectrumOn(SpectrumID)
	local SpectrumData = self.SpectrumPair[SpectrumID]
	if SpectrumData then
        SpectrumData.Begin = true
		SpectrumData:SkillSpectrumOn()
		self:UpdateToTargetValue(SpectrumID, 0, _G.MainProSkillMgr:GetCurrentResource(SpectrumID))
	end
end

function ProfProSkillViewBase:UpdateToTargetValue(SpectrumID, CurValue, TargetValue)
	if CurValue == TargetValue then
		return
	end
	TargetValue = TargetValue or 0
	local SpectrumData = self.SpectrumPair[SpectrumID]
	if SpectrumData and SpectrumData.Begin then
		if SpectrumData.bEnableAdvanceUpdate then
			--直接跳到目标值
			SpectrumData:ValueUpdateEachFunc(TargetValue, TargetValue)
		end
		if SpectrumData.bEnableUpdate then
			SpectrumData:ValueUpdateFunc(CurValue, TargetValue)
		end
		SpectrumData.CurrentValue = TargetValue
	end
end

function ProfProSkillViewBase:OnSpectrumUpdate(Params)
	local SpectrumID = Params.SpectrumID
	local CurValue = Params.CurValue
	local TargetValue = Params.TargetValue
	if CurValue == TargetValue then
		return
	end
	local SpectrumData = self.SpectrumPair[SpectrumID]
	if SpectrumData and SpectrumData.Begin then
		if SpectrumData.bEnableAdvanceUpdate then
			self:OnSpectrumUpdate_EachTimer(SpectrumID, CurValue, TargetValue)
		end
		if SpectrumData.bEnableUpdate then
			SpectrumData:ValueUpdateFunc(CurValue, TargetValue)
		end
		SpectrumData.CurrentValue = TargetValue
	end
end

function ProfProSkillViewBase:OnSpectrumUpdate_EachTimer(SpectrumID, CurValue, TargetValue)
	local SpectrumData = self.SpectrumPair[SpectrumID]
	local SpectrumTimer = self.SpectrumTimer

	local LoopCount = SpectrumData.LoopCount
	local TimerDeltaTime = SpectrumData.DeltaTime
	local TimerDelay = SpectrumData.Delay
	local EachValue = CurValue
	local function SpectrumUpdateInternal()
		if _G.MainProSkillMgr:GetSpectrumStart(SpectrumID) == false then
            local TimerID = SpectrumTimer[SpectrumID]
			if TimerID ~= 0 then
				self:UnRegisterTimer(TimerID)
                SpectrumTimer[SpectrumID] = 0
			end
			return
		end
		EachValue = EachValue + (TargetValue - CurValue) / LoopCount
		if SpectrumData then
			SpectrumData:ValueUpdateEachFunc(EachValue, TargetValue)
		end
	end
    local SpectrumTimerID = SpectrumTimer[SpectrumID]
    if SpectrumTimerID and SpectrumTimerID ~= 0 then
		self:UnRegisterTimer(SpectrumTimerID)
    end
	SpectrumTimer[SpectrumID] = self:RegisterTimer(SpectrumUpdateInternal, TimerDelay, TimerDeltaTime, LoopCount)
end

function ProfProSkillViewBase:OnSpectrumOff(SpectrumID)
	local SpectrumData = self.SpectrumPair[SpectrumID]
	if SpectrumData then
		SpectrumData.Begin = false
		SpectrumData:SkillSpectrumOff()
	end
end

function ProfProSkillViewBase:OnSpectrumMaxValueUpdate(Params)
	local SpectrumID = Params.SpectrumID
	local ResourceMax = Params.ResourceMax
	local SpectrumData = self.SpectrumPair[SpectrumID]
	if SpectrumData then
		SpectrumData:SpectrumMaxValueUpdate(ResourceMax)
	end
end

function ProfProSkillViewBase:UpdateView(Params)
	self:SetParams(Params)

	if self.IsShowView then
		self:OnShow()
		self:UpdateSubView()
	end
end

function ProfProSkillViewBase:UpdateSubView()
	local SubViews = self.SubViews
	if nil == SubViews then
		return
	end

	for i = 1, #SubViews do
		local v = SubViews[i]
		if v:IsVisible() then
			local Fun = v.UpdateView
			if nil ~= Fun then
				Fun(v, self.Params)
			end
		end
	end
end

--量谱解锁
function ProfProSkillViewBase:OnSpectrumsUnlock(SpectrumID)
	local SpectrumData = self.SpectrumPair[SpectrumID]
	if SpectrumData and SpectrumData.View.PanelUnlock then
		_G.EventMgr:SendEvent(EventID.SkillUnLockView)
		SpectrumData.View:PlayAnimationToEndTime(SpectrumData.View.AnimUnlock)
	end
end
return ProfProSkillViewBase