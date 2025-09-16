
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local TipQueueCfg = require("TableCfg/TipQueueCfg")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local TipsQueue = require("Game/TipsQueue/TipsQueue")
local TipsQueueDefine = require("Game/TipsQueue/TipsQueueDefine")

local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr

local FLOG_INFO = _G.FLOG_INFO

---@class TipsQueueMgr : MgrBase
local TipsQueueMgr = LuaClass(MgrBase)

function TipsQueueMgr:OnInit()
	self.bUseQueue = true
	self.bPause = false
	self.TipsCount = 0
	self.PredictTickTime = 0
	self.TipsList = {}
	self.PriorityList = {}
	self:OnInitLocalAllCfg()
end

function TipsQueueMgr:OnBegin()
	if self.Timer ~= nil then
		self:UnRegisterTimer(self.Tick)
		self.Timer = nil
	end
	self.Timer = self:RegisterTimer(self.Tick, 0, 0.5, 0)
end

function TipsQueueMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldMapExit) 	-- 退出副本地图
end

-- 切地图的时候清空队列
function TipsQueueMgr:OnGameEventPWorldMapExit(Params)
	self.bPause = false
	self:Clear()
	if self.CurTipsUnit then
		self.CurTipsUnit:StopTips(0, TipsQueueDefine.STOP_REASON.PWORLDCHANGE, true)
	end
	-- 切场景了不管怎么样都去掉当前提示
	self.CurTipsUnit = nil
end

function TipsQueueMgr:OnEnd()
	if self.Timer ~= nil then
		self:UnRegisterTimer(self.Tick)
		self.Timer = nil
	end
end

function TipsQueueMgr:OnInitLocalAllCfg()
	local AllCfg = TipQueueCfg:FindAllCfg()
	if AllCfg == nil then
		return
	end

	for _, value in pairs(AllCfg) do
		local Config = {
			Type = value.Type,
			InterRule = value.InterRule,
			ExterRule = value.ExterRule,
			Duration = value.ShowTime,
			LifeTime = value.LifeTime,
			LeastTime = value.LeastTime,
			Priority = value.Priority,
		}
		self.TipsList[value.Type] = TipsQueue.New(Config)
		table.insert(self.PriorityList, value.Type)
	end
	table.sort(self.PriorityList, function(TypeA, TypeB)
		return self.TipsList[TypeA].Priority < self.TipsList[TypeB].Priority
	end)
end

function TipsQueueMgr:Pause(bPause)
	if self.bPause == bPause then
		return
	end
	self.bPause = bPause
end

function TipsQueueMgr:Stop(bStop, bForce, StopReason)
	if bStop and self.CurTipsUnit then
		local NowTime = TimeUtil.GetGameTimeMS()
		if self.CurTipsUnit:StopTips(NowTime, StopReason, bForce) then
			self.CurTipsUnit = nil
		end
	end
end

function TipsQueueMgr:Clear()
	for _, Queue in pairs(self.TipsList) do
		Queue:ClearQueue()
	end
end

function TipsQueueMgr:EnableUseQueue(bEnable)
	self.bUseQueue = bEnable
end

---是否配置了对应类型的提示队列
---@param Type number @提示类型
---@return boolean
function TipsQueueMgr:ContainTipsType(Type)
	return self.TipsList ~= nil and self.TipsList[Type] ~= nil
end

---添加消息提示, 在MsgTipsUtil里面有不同类型的封装接口, 尽量用封装好的接口
---@param Config.Type			@对应的ProtoRes.tip_class_type
---@param Config.Duration		@Tips持续时间, 默认使用表格配置ShowTime
---@param Config.LifeTime		@Tips有效时间，默认使用表格配置LifeTime
---@param Config.LeastTime		@Tips最少播放的时间, 默认使用表格配置LeastTime, 如果LeastTime>=Duration消息提示不会被打断
---@param Config.Callback		@回调方法, 消息提示开始播放的时候回调, 必须配置, 返回false会直接跳过当前提示
---@param Config.UpdateCallback @回调方法, 消息提示刷新的时候回调, 可选配置
---@param Config.StopCallback	@回调方法, 消息提示结束的时候回调, 可选配置, 返回false不会继续当前提示
---@param Config.Params			@回调参数，自定义
---@param Config.InterRule		@如果设置了TIP_RULE_REPLACE, 加入类型队列的时候会先清掉当前的队列
---@param Config.ExterRule		@如果设置了TIP_RULE_REPLACE, 加入类型队列的时候会清掉优先级高的队列
function TipsQueueMgr:AddPendingShowTips(Config)
	if Config == nil or Config.Callback == nil then
		return
	end
	-- 关闭了消息队列的情况下直接触发消息提示
	if not self.bUseQueue then
		Config.Callback(Config.Params)
		return
	end
	local Type = Config.Type
	-- 没有配置该类型, 不受轮播队列管理, 直接播放回调
	if self.TipsList[Type] == nil then
		-- FLOG_INFO("[TipsQueueMgr]Cant find Type config, Type=%d", Type)
		Config.Callback(Config.Params)
		return
	end
	-- 已经在播放同样的提示直接跳过
	if self.TipsList[Type]:IsEmpty() and
		(self.CurTipsUnit ~= nil and self.CurTipsUnit.Type == Type and self.CurTipsUnit:IsEqual(Config)) then
		-- FLOG_INFO("[TipsQueueMgr]Tips already playing, Type=%d", Type)
		return
	end
	local Priority = self.TipsList[Type].Priority
	-- 提示加入队列
	local bIsDuplicate = not self.TipsList[Type]:PushTipsToQueue(Config)
	if bIsDuplicate then
		return
	end
	FLOG_INFO("[TipsQueueMgr]AddPendingShowTips, Type=%d", Type)
	self.TipsCount = self.TipsCount + 1
	-- 处理ExterRule
	local bCanReplace = Config.ExterRule == ProtoRes.tip_rule_type.TIP_RULE_REPLACE
	if bCanReplace then
		-- 顶替规则下只保留优先级更大的队列, 其余队列清空
		self.TipsCount = 0
		for _, Queue in pairs(self.TipsList) do
			if (Queue.Priority < Priority) or (Type ~= Queue.Type and Queue.Priority == Priority) then
				Queue:ClearQueue()
			else
				self.TipsCount = self.TipsCount + Queue:GetQueueSize()
			end
		end
	end
	-- 有些提示并不能保证顺序, 如果第一个提示加入队列的时候刚好Tick了可能会导致顺序出错
	-- 在队列这里保护一下, 加入第一个提示的时候会重置一下Tick的时机
	if self.Timer ~= nil and self.TipsCount == 1 then
		_G.TimerMgr:FlushTimer(self.Timer)
	end
	-- 空队列加入提示的话直接刷新一次
	--[[
	if self.CurTipsUnit == nil and self.TipsCount == 1 then
		self:Tick()
	end
	--]]
end

function TipsQueueMgr:CheckNeedInterupt(Priority)
	for _, Queue in pairs(self.TipsList) do
		if Queue.Priority <= Priority and not Queue:IsEmpty() then
			return true
		end
	end
	return false
end

function TipsQueueMgr:RefreshQueue(NowTime, Queue)
	if Queue == nil then
		return false
	end
	while not Queue:IsEmpty() do
		local CurTipsUnit = Queue:PopTipsFromQueue()
		local bIsLast = Queue:IsEmpty()
		self.TipsCount = self.TipsCount - 1
		if CurTipsUnit then
			FLOG_INFO("[TipsQueueMgr]BeginPlayTips, Type=%d", CurTipsUnit.Type)
		end
		if CurTipsUnit and CurTipsUnit:BeginPlay(NowTime, bIsLast) then
			self.CurTipsUnit = CurTipsUnit
			return true
		end
	end
	return false
end

function TipsQueueMgr:ProcessCurrentUnit(NowTime)
	local bNeedInterupt = (self.TipsCount > 0)
	-- 如果目前不允许结束, 直接返回
	if not self.CurTipsUnit:Update(NowTime, bNeedInterupt) then
		return
	end
	-- 有别的提示在等待就强行结束掉
	if bNeedInterupt and self.CurTipsUnit:StopTips(NowTime, TipsQueueDefine.STOP_REASON.NEWTIPS) then
		FLOG_INFO("[TipsQueueMgr]StopTips newtips, Type=%d", self.CurTipsUnit.Type)
		self.CurTipsUnit = nil
		return
	end
	-- 没有其他提示的
	if self.CurTipsUnit:StopTips(NowTime, TipsQueueDefine.STOP_REASON.COMPLETE) then
		FLOG_INFO("[TipsQueueMgr]StopTips complete, Type=%d", self.CurTipsUnit.Type)
		self.CurTipsUnit = nil
		return
	end
end

function TipsQueueMgr:Tick()
	local NowTime = TimeUtil.GetGameTimeMS()
	if not self:ShouldProcess() then
		-- 恢复更新的第一帧可能很短, 会导致一些连续的提示还没全部加进队列就已经播放了
		self.PredictTickTime = NowTime + 1000
		return
	end
	if NowTime < self.PredictTickTime then
		return
	end
	self.PredictTickTime = 0
	if self.CurTipsUnit == nil and self.TipsCount == 0 then
		return
	end
	-- 先处理正在播放的消息
	if self.CurTipsUnit then
		self:ProcessCurrentUnit(NowTime)
	end
	-- 如果没有消息在播放, 刷新队列
	if not self.CurTipsUnit then
		for _, Type in pairs(self.PriorityList) do
			if self:RefreshQueue(NowTime, self.TipsList[Type]) then
				break
			end
		end
	end
end

function TipsQueueMgr:ShouldProcess()
	if self.bPause then
		return false
	end

	if (_G.LoadingMgr:IsLoadingView()) then
		return false
	end

	-- 等待NPC对话完成
	local bInDialog = _G.NpcDialogMgr:IsDialogPanelVisible()
	if bInDialog then
		return false
	end

	-- 获得物品全屏弹窗
	if UIViewMgr:IsViewVisible(UIViewID.CommonRewardPanel) then
		return false
	end

	-- 时尚品鉴评分过程界面
	if UIViewMgr:IsViewVisible(UIViewID.FashionEvaluationProgressPanel) then
		return false
	end

	-- 冒险游商团解围结算弹窗
	if UIViewMgr:IsViewVisible(UIViewID.MysterMerchantSettlementView) then
		return false
	end

	-- 播放Sequence
	-- 如果设置了bPauseAtEnd, 可能出现IsPlaying已经是false, 但是Sequence还没完全结束
	if _G.StoryMgr:SequenceIsPlaying() or _G.StoryMgr.SequencePlayer then
		return false
	end

	return true
end

return TipsQueueMgr