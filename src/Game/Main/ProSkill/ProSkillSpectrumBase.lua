local LuaClass = require("Core/LuaClass")


local ProSkillSpectrumBase = LuaClass()

function ProSkillSpectrumBase:Ctor(View, SpectrumID)
	self.View = View
	self.SpectrumID = SpectrumID
	if not View then
		FLOG_ERROR("ProSkillSpectrumBase:OnInit View is invalid")
	end
	if not SpectrumID then
		FLOG_ERROR("ProSkillSpectrumBase:OnInit SpectrumID is invalid")
	end
end

function ProSkillSpectrumBase:InternalInit()
	self:OnInit()
	self:OnSpectrumStudy()
	self:SpectrumMaxValueUpdate(_G.MainProSkillMgr:GetSpectrumMaxValue(self.SpectrumID))
end

function ProSkillSpectrumBase:OnInit()
	self.Begin = false
	self.CurrentProgressBar = nil
	self.CurrentValue = 0
	self.SpectrumMaxValue = 0
    --self:SpectrumMaxValueUpdate(_G.MainProSkillMgr:GetSpectrumMaxValue(self.SpectrumID))
	self.bEnableUpdate = true
	self.bEnableAdvanceUpdate = true
	self.LoopCount = 10
	self.DeltaTime = 0.01
	self.Delay = 0
	self.Timer = {}
	--职业量谱初始化函数，初始化量谱信息时执行，可使用self.Super:OnInit()继承基类初始化函数
	--只做数据上的初始化，界面表现可在OnSpectrumStudy中初始化
end

function ProSkillSpectrumBase:SpectrumMaxValueUpdate(MaxValue)
	local CurValue = self.SpectrumMaxValue
	if CurValue ~= MaxValue then
		self.SpectrumMaxValue = MaxValue
		self:OnSpectrumMaxValueUpdate(MaxValue)
		--量谱值超过上限时修改
		if self.CurrentValue > MaxValue then
			_G.MainProSkillMgr:OnSpectrumUpdate(self.SpectrumID, MaxValue)
		end
	end
end

function ProSkillSpectrumBase:OnSpectrumStudy()

end

function ProSkillSpectrumBase:OnSpectrumDeStudy()

end

function ProSkillSpectrumBase:SkillSpectrumOn()
	--职业量谱开启函数，用于初始化量谱开启状态，该函数会在接收服务器量谱开启请求时执行
end

function ProSkillSpectrumBase:SkillSpectrumOff()
	--职业量谱关闭函数，主要用于重置各UI组件状态，该函数会在接收服务器量谱关闭请求时执行
end

function ProSkillSpectrumBase:ValueUpdateFunc( CurValue, TargetValue)
	--量谱资源每次更新时执行，用于处理资源更新时的逻辑与部分表现
end

function ProSkillSpectrumBase:ValueUpdateEachFunc(CurValue)
	--量谱资源插值更新函数，在量谱资源每次更新时，该函数会执行N次，CurValue = SourceValue +（TargetValue - SourceValue）*执行次数
	--该函数可用于量谱资源增长时，量谱UI平滑增长表现
end

function ProSkillSpectrumBase:OnCastBuff(BuffInfo)
	--接收buff时执行的函数
end

function ProSkillSpectrumBase:OnRemoveBuff(BuffInfo)
	--移除buff时执行的函数
end

function ProSkillSpectrumBase:OnSpectrumMaxValueUpdate(MaxValue)
	--量谱最大值更新时的表现
end

function ProSkillSpectrumBase:CreateLoopTimer(Listener, CallBack, Delay, Interval, Params)
	local TimerID = TimerMgr:AddTimer(Listener, CallBack, Delay, Interval, 0, Params)
	self.Timer[TimerID] = TimerID
	return TimerID
end

function ProSkillSpectrumBase:ReleaseLoopTimer(TimerID)
	if TimerID and TimerID > 0 and self.Timer[TimerID] then
		TimerMgr:CancelTimer(TimerID)
		self.Timer[TimerID] = nil
	end
end

function ProSkillSpectrumBase:OnHide()
	--在相应View Hide时调用，避免出现内存泄漏
	for _, value in pairs(self.Timer) do
		TimerMgr:CancelTimer(value)
	end
	self.Timer = {}
end

function ProSkillSpectrumBase:OnDestroy()
--在相应View Destroy时调用，避免出现内存泄漏
	for _, value in pairs(self.Timer) do
		TimerMgr:CancelTimer(value)
	end
end

return ProSkillSpectrumBase