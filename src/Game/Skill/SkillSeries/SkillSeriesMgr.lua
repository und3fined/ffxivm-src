--
-- Author: anypkvcai , chaooren
-- Date: 2021-01-28 09:51:50
-- Description: 技能连招

-- chaooren:添加多队列连招，允许技能根据连招是否能被打断过滤上一连招状态
--21-2-26 chaooren:连招存储结构修改，添加连招信息获取接口

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local SkillUtil = require("Utils/SkillUtil")
local EventID = require("Define/EventID")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillSeriesCfg = require("TableCfg/SkillSeriesCfg")
local EventMgr = _G.EventMgr
local StringTools = _G.StringTools
local ESkillCastType = _G.UE.ESkillCastType
local ProtoCS = require ("Protocol/ProtoCS")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")

---@class SkillSeriesMgr : MgrBase
local SkillSeriesMgr = LuaClass(MgrBase)

---@field SkillIndex number                 @技能按钮索引
---@field SkillID number                    @初始技能ID
---@field QueueIndex number                 @连招队列索引
---@field QueueSkill number               @当前队列技能ID
---@field CfgID number                      @c_skill_series_cfg配置ID
---@field SkillQueue table                  @变招技能队列
---@field BeginTime table                   @变招开始时间
---@field EndTime table                     @变招结束时间
---@field LastCastTime number               @上次释放技能时间
function SkillSeriesMgr:OnInit()
	-- self.SkillIndex = 0
	-- self.SkillID = 0
	-- self.QueueIndex = 0
	-- self.QueueSkill = 0
	-- self.CfgID = 0
	-- self.SkillQueue = nil
	-- self.BeginTime = 0
	-- self.EndTime = 0
	-- self.LastCastTime = 0
	self.SeriesSkill = {}

	--cache all valid queue skills
	self.QueueSkills = {}
end

function SkillSeriesMgr:OnBegin()
end

function SkillSeriesMgr:OnEnd()
end

function SkillSeriesMgr:OnShutdown()

end

function SkillSeriesMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_RESET_SKILL_SERIES, self.OnNetMsgResetSkillSeries)
end

function SkillSeriesMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.WorldPreLoad, self.OnWorldPreLoad)
	self:RegisterGameEvent(EventID.MajorUseSkill, self.OnGameEventMajorUseSkill)
end

function SkillSeriesMgr:OnWorldPreLoad()
	self:ForceBreakAllSkill()
end

function SkillSeriesMgr:OnGameEventMajorUseSkill(Params)
	if Params.ULongParam2 == _G.UE.ESkillCastType.ComboType then
        self:OnMajorUseSkill(Params)
    else
        self:BreakSkillWithout(Params.IntParam1)
    end
end

function SkillSeriesMgr:ClearQueueSkillsCache()
	self.QueueSkills = {}
end

---OnMajorUseSkill
---@param Params FEventParams
function SkillSeriesMgr:OnMajorUseSkill(Params)
	local SkillID = Params.IntParam1
	for key, value in pairs(self.SeriesSkill) do
		if SkillID == value.QueueSkill then
			value.QueueIndex = value.QueueIndex + 1
			if value.QueueIndex > #value.SkillQueue then
				self:OnSkillEnd(key)
			else
				value.QueueSkill = value.SkillQueue[value.QueueIndex]
				local SkillUpdateParams = { SkillIndex = value.SkillIndex, SkillID = value.QueueSkill, Type = value.bReplaceAnim}
				EventMgr:SendEvent(EventID.SkillUpdate, SkillUpdateParams)
			end
		elseif value.IsCanBeBreak == 1 then
			self:OnSkillEnd(key)
		end
	end
end

function SkillSeriesMgr:OnNetMsgResetSkillSeries(MsgBody)
	local SkillSeriesID = MsgBody.ResetSkillSeries.SkillSeriesID
	self:BreakSkillbySeriesID(SkillSeriesID)
end

function SkillSeriesMgr:CastSkill(SkillID, SkillIndex, Params)
	local _ <close> = CommonUtil.MakeProfileTag("SkillSeriesMgr:CastSkill")
	local BaseSkillID = self:FindSeriesSkillBaseID(SkillID)
	if BaseSkillID ~= nil then
		local RetTemp = self:CastSkillInternal(BaseSkillID, Params)
		return RetTemp
	else
		local Cfg = SkillSeriesCfg:FindCfgByKey(SkillID)
		if nil ~= Cfg and nil ~= Cfg.ID then
			local SkillQueue = self.QueueSkills[SkillID]
			if not SkillQueue then
				SkillQueue = {}
				for _, value in ipairs(Cfg.SkillQueue) do
					local CurrentSkillID = value
					if not SkillUtil.IsMajorSkillLearned(CurrentSkillID) then
						break
					end
					
					table.insert(SkillQueue, CurrentSkillID)
				end
				self.QueueSkills[SkillID] = SkillQueue
			end

			if #SkillQueue == 0 then
				FLOG_ERROR("[SkillSeriesMgr]SeriesSkillQueue %d All locked", SkillID)
				return false
			end
			self.SeriesSkill[SkillID] = {SkillIndex = SkillIndex, CfgID = Cfg.ID, QueueIndex = 1, SkillQueue = SkillQueue
				, QueueSkill = SkillQueue[1], EndTime = Cfg.EndTime, IsCanBeBreak = Cfg.IsCanBeBreak, bReplaceAnim = Cfg.bReplaceAnim}
			local RetTemp = self:CastSkillInternal(SkillID, Params)
			return RetTemp
		end
	end
	return false
end

function SkillSeriesMgr:CastSkillInternal(SkillID, Params)
	local SeriesSkill = self.SeriesSkill[SkillID]
	SeriesSkill.LastCastTime = TimeUtil.GetLocalTimeMS()
	if SeriesSkill.Timer ~= nil then
		self:UnRegisterTimer(SeriesSkill.Timer)
	end

	SeriesSkill.Timer = self:RegisterTimer(self.OnSkillEnd, SeriesSkill.EndTime / 1000, 1, 1, SkillID)
	SkillUtil.SendCastSkillEvent(ESkillCastType.ComboType, SkillID, SeriesSkill.CfgID, SeriesSkill.QueueIndex, SeriesSkill.QueueSkill, SeriesSkill.SkillIndex, Params)
	return true
end

--根据技能ID查找该技能ID是否为当前激活的连招ID，并返回对应的BaseSkillID
function SkillSeriesMgr:FindSeriesSkillBaseID(SkillID)
	for key, value in pairs(self.SeriesSkill) do
		if SkillID == value.QueueSkill then
			return key
		end
	end
	return nil
end

--打断某一连招，无视IsCanBeBreak
function SkillSeriesMgr:BreakSkill(SkillID)
	if SkillID == nil or SkillID == 0 then return end
	local BaseSkillID = self:FindSeriesSkillBaseID(SkillID)
	if BaseSkillID ~= nil then
		self:OnSkillEnd(BaseSkillID)
	end
end

function SkillSeriesMgr:BreakSkillbyIndex(Index)
	for BaseSkillID, value in pairs(self.SeriesSkill) do
		if value.SkillIndex == Index then
			self:OnSkillEnd(BaseSkillID)
			break
		end
	end
end

function SkillSeriesMgr:BreakSkillbySeriesID(SeriesID)
	if not SeriesID then
		return
	end

	for key, value in pairs(self.SeriesSkill) do
		if value.CfgID == SeriesID then
			self:OnSkillEnd(key)
			return
		end
	end
end

--打断除输入SkillID之外的技能连招
function SkillSeriesMgr:BreakSkillWithout(SkillID)
	for key, value in pairs(self.SeriesSkill) do
		if key ~= nil and key ~= SkillID and value.QueueSkill ~= SkillID and value.IsCanBeBreak == 1 then
			self:OnSkillEnd(key)
		end
	end
end

function SkillSeriesMgr:OnSkillEnd(SkillID)
	local SeriesSkill = self.SeriesSkill[SkillID]
	if SeriesSkill == nil then
		FLOG_WARNING("[SkillSeriesMgr] SeriesSkill is nil with SkillID: " .. tostring(SkillID or 0))
		return
	end
	local Params = { SkillIndex = SeriesSkill.SkillIndex, SkillID = SkillID, Type = SeriesSkill.bReplaceAnim }
	EventMgr:SendEvent(EventID.SkillUpdate, Params)

	local Timer = SeriesSkill.Timer
	if Timer ~= nil then
		self:UnRegisterTimer(Timer)
	end
	self.SeriesSkill[SkillID] = nil
end

--转职时清理连招数据，但不推送更新
function SkillSeriesMgr:ClearSkill()
	if self.SeriesSkill then
		for _, value in pairs(self.SeriesSkill) do
			local Timer = value.Timer
			if Timer ~= nil then
				self:UnRegisterTimer(Timer)
			end
		end
	end
	self.SeriesSkill = {}
end

function SkillSeriesMgr:ClearSkillbyIndex(Index)
	for BaseSkillID, value in pairs(self.SeriesSkill) do
		if value.SkillIndex == Index then
			local Timer = value.Timer
			if Timer ~= nil then
				self:UnRegisterTimer(Timer)
			end
			self.SeriesSkill[BaseSkillID] = nil
			break
		end
	end
end

--切换地图时强制结束所有连招
function SkillSeriesMgr:ForceBreakAllSkill()
	for key, _ in pairs(self.SeriesSkill) do
		self:OnSkillEnd(key)
	end
	self.SeriesSkill = {}
end

function SkillSeriesMgr:ReconstructAllSeriesSkill()
	for key, value in pairs(self.SeriesSkill) do
		if #value.SkillQueue > 0 then
			local CurSkillID = value.QueueSkill
			local SkillUpdateParams = { SkillIndex = value.SkillIndex, SkillID = CurSkillID, Type = false }
			EventMgr:SendEvent(EventID.SkillUpdate, SkillUpdateParams)
		end
	end
end

return SkillSeriesMgr