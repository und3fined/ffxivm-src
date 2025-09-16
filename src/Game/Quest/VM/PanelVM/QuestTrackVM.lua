---
--- Author: lydianwang
--- DateTime: 2021-09-02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestDefine = require("Game/Quest/QuestDefine")

local MapDefine = require("Game/Map/MapDefine")
local AutoMoveTargetType = require("Define/AutoMoveTargetType")

local ProtoRes = require("Protocol/ProtoRes")

local ChapterVM = require("Game/Quest/VM/DataItemVM/ChapterVM")

local QUEST_TYPE = ProtoRes.QUEST_TYPE
local TARGET_TYPE = ProtoRes.QUEST_TARGET_TYPE

local CHAPTER_STATUS = QuestDefine.CHAPTER_STATUS
local TRACK_STATUS = QuestDefine.TRACK_STATUS

local QuestMgr = nil
local QuestMainVM = nil

---@class QuestTrackVM : UIViewModel
local QuestTrackVM = LuaClass(UIViewModel)

function QuestTrackVM:Ctor()
	self.CurrTrackChapterID = nil
	self.PreTrackChapterID = nil

	self.CurrTrackQuestVM = nil
	self.PreTrackQuestVM = nil

	self.CurrTrackNearestItem = nil

	QuestMgr = _G.QuestMgr
	QuestMainVM = _G.QuestMainVM

	self:SetNoCheckValueChange("CurrTrackQuestVM", true)
	self:SetNoCheckValueChange("PreTrackQuestVM", true)
end

function QuestTrackVM:OnEnd()
	self.CurrTrackChapterID = nil
	self.PreTrackChapterID = nil

	self.CurrTrackQuestVM = nil
	self.PreTrackQuestVM = nil

	self.CurrTrackNearestItem = nil
end

-- --------------------------------------------------
-- 任务追踪栏
-- --------------------------------------------------

---@param ChapterID int32
function QuestTrackVM:OnQuestAccept(ChapterID)
	if ChapterID == nil then return end
	local test = 0
	if (self.CurrTrackChapterID ~= ChapterID) then
		if (self.CurrTrackChapterID == nil) then
			test = 1
		elseif QuestMgr.bQuestDataInit then -- 初始化前不展示PreTrack
			test = 2
		end
	end
	print("QuestTrackVM:OnQuestAccept", test, self.CurrTrackChapterID, ChapterID)

	if (self.CurrTrackChapterID ~= ChapterID) then
		if (self.CurrTrackChapterID == nil) then
			self:TrackQuest(ChapterID, TRACK_STATUS.ACCEPT)
		elseif QuestMgr.bQuestDataInit then -- 初始化前不展示PreTrack
			self:PreTrackQuest(ChapterID, TRACK_STATUS.ACCEPT)
		end
	end
end

---@param ChapterID int32
function QuestTrackVM:OnQuestUpdate(ChapterID)
	if ChapterID == nil then return end
	local bTracking = (self.CurrTrackChapterID ~= nil)
	local bSameMainline = QuestMainVM.DisplayMainlineVM
		and (ChapterID == QuestMainVM.DisplayMainlineVM.ChapterID)
	local test = 0
	if bTracking and (self.CurrTrackChapterID ~= ChapterID) then
		if not bSameMainline then
			test = 1
		else
			test = 2
		end
	elseif bTracking or (not bSameMainline) then
		test = 3
	end
	print("QuestTrackVM:OnQuestUpdate", test, self.CurrTrackChapterID, ChapterID, bTracking, bSameMainline)

	if bTracking and (self.CurrTrackChapterID ~= ChapterID) then
		if not bSameMainline then
			self:PreTrackQuest(ChapterID, TRACK_STATUS.UPDATE)
		end
	elseif bTracking or (not bSameMainline) then
		self:TrackQuest(ChapterID, TRACK_STATUS.UPDATE)
	end
end

---@param ChapterID int32
function QuestTrackVM:OnQuestFinish(ChapterID)
	if ChapterID == nil then return end
	local test = 0
	if (self.CurrTrackChapterID == ChapterID) then
		if QuestMainVM.DisplayMainlineVM then
			test = 1
		else
			test = 2
		end
	else
		test = 3
	end
	print("QuestTrackVM:OnQuestFinish", test, self.CurrTrackChapterID, ChapterID)

	if (self.CurrTrackChapterID == ChapterID) then
		self:TrackQuest(nil, TRACK_STATUS.FINISH)
		-- 如果玩家正在追踪主线任务,默认追踪下一个可接取任务
		local MainlineVM = QuestMainVM.DisplayMainlineVM
		if MainlineVM and MainlineVM.bActivatedMainline then
			self:TrackCanAcceptQuest(MainlineVM.ChapterID)
		end
	else
		self:PreTrackQuest(nil, TRACK_STATUS.FINISH)
	end
end

---@param ChapterID int32
function QuestTrackVM:OnQuestGiveUp(ChapterID)
	if ChapterID == nil then return end

	if (self.CurrTrackChapterID == ChapterID) then
		self:TrackQuest(nil)
	elseif (self.PreTrackChapterID == ChapterID) then
		self:PreTrackQuest(nil)
	end
end

function QuestTrackVM:OnTrackPre()
	if self.PreTrackChapterID == nil then return end
	QuestMgr.QuestReport:ReportReplaceTaskTracking(self.PreTrackChapterID) --[sammrli] add before PreTrackQuest
	self:TrackQuest(self.PreTrackChapterID)
	self:PreTrackQuest(nil)
end

local function ConstructTrackEventParam(ChapterVMItem)
	local Param = {
		QuestID = nil,
		PartRequirementMap = nil,
	}
	if ChapterVMItem == nil then return Param end

	if _G.QuestFaultTolerantMgr:CheckQuestFault(ChapterVMItem.QuestID) then --任务已经失败
		return Param
	end

	Param.QuestID = ChapterVMItem.QuestID

	local Quest = QuestMgr.QuestMap[Param.QuestID]
	if Quest == nil then return Param end

	for _, Target in pairs(Quest.Targets) do
		local TargetType = Target.Cfg.m_iTargetType
		if TargetType == TARGET_TYPE.QUEST_TARGET_TYPE_EQUIP then
			Param.PartRequirementMap = Target.PartRequirementMap
			break -- 假设一个任务只有一个穿戴装备目标
		end
	end
	for _, StateRestriction in pairs(Quest.StateRestrictions) do
		local ReqMap = StateRestriction.PartRequirementMap
		if ReqMap ~= nil then -- 任务限制类不包含类型数据，用这个判断是否属于装备限制
			Param.PartRequirementMap = ReqMap
			break
		end
	end

	return Param
end

---@param ChapterID int32|nil
---@param TrackStatus TRACK_STATUS
---@param bOnNetMsg boolean
function QuestTrackVM:TrackQuest(ChapterID, TrackStatus, bOnNetMsg)
	QuestHelper.PrintQuestInfo("Track Chapter #%d at TrackStatus %d", ChapterID or 0, TrackStatus or 0)
    if not bOnNetMsg then
		QuestMgr:SendTrackQuest(ChapterID or 0)
		if ChapterID ~= nil and TrackStatus == nil then
			print(debug.traceback())
		end
	end

	self.CurrTrackChapterID = ChapterID

	if self.CurrTrackQuestVM ~= nil then
		self.CurrTrackQuestVM.bTracking = false
		self.CurrTrackQuestVM.TrackTargetID = nil
	end

	local ChapterVMItem = QuestMainVM:GetChapterVM(ChapterID)
	if ChapterVMItem ~= nil then
		ChapterVMItem.bTracking = true
		ChapterVMItem.TrackStatus = TrackStatus or TRACK_STATUS.UPDATE

		if QuestHelper.CheckIsMainline(ChapterVMItem.ChapterID) then
			QuestMainVM.DisplayMainlineVM = ChapterVMItem
		end

	elseif self.CurrTrackQuestVM ~= nil then
		if TrackStatus == TRACK_STATUS.FINISH then
			self.CurrTrackQuestVM.Status = CHAPTER_STATUS.FINISHED
			self.CurrTrackQuestVM.TrackStatus = TrackStatus
			self.CurrTrackQuestVM:UpdateLogIcon()
		end

		if self.CurrTrackQuestVM and QuestHelper.CheckIsMainline(self.CurrTrackQuestVM.ChapterID) then
			local DisplayVM = self.CurrTrackQuestVM
			if TrackStatus == TRACK_STATUS.FINISH then
				DisplayVM = nil
			end
			QuestMainVM:UpdateDisplayMainlineVM(DisplayVM)
		end
	end

	self.CurrTrackQuestVM = ChapterVMItem

	_G.QuestTrackMgr:NaviToQuest(ChapterVMItem)

	local Param = ConstructTrackEventParam(ChapterVMItem)
	_G.EventMgr:SendEvent(_G.EventID.UpdateQuestTrack, Param)
end

---@param ChapterID int32|nil
---@param TrackStatus TRACK_STATUS
function QuestTrackVM:PreTrackQuest(ChapterID, TrackStatus)
	QuestHelper.PrintQuestInfo("PreTrack chapter #%d at TrackStatus %d", ChapterID or 0, TrackStatus or 0)
	if (self.PreTrackChapterID == ChapterID) then return end

	self.PreTrackChapterID = ChapterID

	local ChapterVMItem = QuestMainVM:GetChapterVM(ChapterID)
	if ChapterVMItem ~= nil then
		ChapterVMItem.TrackStatus = TrackStatus or TRACK_STATUS.UPDATE

		if ChapterVMItem.Type == QUEST_TYPE.QUEST_TYPE_MAIN then --如果是主线,会常驻第一栏,不赋值PreTrackQuestVM
			FLOG_INFO("[QuestTrackVM] PreTrackQuest return because track mainline")
			return
		end
	end

	self.PreTrackQuestVM = ChapterVMItem
end

---打开任务接取的地图并弹出追踪提示
---@param ChapterID number@任务章节ID
---@param CanOepnSameMap boolean@同地图是否打开
function QuestTrackVM:ShowMapTrackQuest(ChapterID, CanOepnInSameMap)
	if not ChapterID then
		return
	end
	local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
	if ChapterCfgItem then
		local QuestCfgItem = QuestHelper.GetQuestCfgItem(ChapterCfgItem.StartQuest)
		if QuestCfgItem then
			local UIMapID = QuestCfgItem.AcceptUIMapID
			local MappingMapCfgItem = WorldMapMgr:FindMappingMapCfgByUIMapID(UIMapID)
			if MappingMapCfgItem then
				--有映射数据,比如沙之家
				local InUIMapID = _G.MapMgr:GetUIMapID()
				if CanOepnInSameMap then
					--如果在地图或映射地图,打开当前所在地图
					if InUIMapID == UIMapID or InUIMapID == MappingMapCfgItem.MappingUIMapID then
						local InMapID = _G.MapMgr:GetMapID()
						_G.WorldMapMgr:ShowWorldMapTrackQuest(InMapID, InUIMapID, QuestCfgItem.id, QuestCfgItem.TargetParamID[1])
					else
						--否则打开映射的地图
						_G.WorldMapMgr:ShowWorldMapTrackQuest(MappingMapCfgItem.MappingMapID, MappingMapCfgItem.MappingUIMapID, QuestCfgItem.id, QuestCfgItem.TargetParamID[1])
					end
				else
					--判断当前是否在沙之家或者映射地图，如果都不在，才打开地图，打开的地图是映射的地图
					if InUIMapID ~= UIMapID and InUIMapID ~= MappingMapCfgItem.MappingUIMapID then
						_G.WorldMapMgr:ShowWorldMapTrackQuest(MappingMapCfgItem.MappingMapID, MappingMapCfgItem.MappingUIMapID, QuestCfgItem.id, QuestCfgItem.TargetParamID[1])
					end
				end
			else
				--没映射数据，允许打开所在地图或者不在所在地图打开
				if CanOepnInSameMap or _G.MapMgr:GetUIMapID() ~= QuestCfgItem.AcceptUIMapID then
					_G.WorldMapMgr:ShowWorldMapTrackQuest(QuestCfgItem.AcceptMapID, QuestCfgItem.AcceptUIMapID, QuestCfgItem.id, QuestCfgItem.TargetParamID[1])
				end
			end
		end
	end
end

function QuestTrackVM:ShowMapQuestByLog(ChapterID)
	if not ChapterID then
		return
	end
	local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
	if ChapterCfgItem then
		local StartQuestID = ChapterCfgItem.StartQuest
		local QuestCfgItem = QuestHelper.GetQuestCfgItem(StartQuestID)
		if QuestCfgItem then
			_G.WorldMapMgr:ShowWorldMapQuest(QuestCfgItem.AcceptMapID, QuestCfgItem.AcceptUIMapID, StartQuestID,  MapDefine.MapOpenSource.QuestLog)
		end
	end
end

---推进追踪的任务
function QuestTrackVM:PushTrackQuest()
	if not self.TrackQuestLock then
		_G.QuestTrackMgr:ForceNaviTick()
		self.TrackQuestLock = _G.TimerMgr:AddTimer(nil, function()
			self.TrackQuestLock = nil
		end, 0.5)
	end

	local CurrTrackQuestVM = self.CurrTrackQuestVM
	if CurrTrackQuestVM then
		local Quest = QuestMgr.QuestMap[CurrTrackQuestVM.QuestID]
		if Quest then
			if Quest.StateRestrictions then
				local Key = next(Quest.StateRestrictions)
				local FirstRestriction= Quest.StateRestrictions[Key]
				if FirstRestriction then
					if FirstRestriction.CheckAllAndNofity then
						FirstRestriction:CheckAllAndNofity()
					end
				end
			end

			if Quest.Targets then
				for _, Target in pairs(Quest.Targets) do
					if Target:PushTrack() then
						return
					end
				end
			end

			if _G.AutoPathMoveMgr:IsAutoPathMoveEnable() then
				if self.CurrTrackNearestItem then
					-- 开启自动寻路
					if self.CurrTrackNearestItem.MapID and self.CurrTrackNearestItem.Pos then
						local TargetPos = self.CurrTrackNearestItem.Pos
						local IsDstPosRejust = true
						if self.CurrTrackNearestItem.NaviType == QuestDefine.NaviType.NpcResID then
							local OffsetPos = _G.NavigationPathMgr.GetNavigationPosByNpcID(self.CurrTrackNearestItem.MapID, self.CurrTrackNearestItem.NaviObjID)
							if OffsetPos then
								TargetPos = OffsetPos
							end
							IsDstPosRejust = false
						end
						_G.QuestTrackMgr.AutoPathTrackChapterID = CurrTrackQuestVM.ChapterID
						_G.WorldMapMgr:StartMapAutoPathMove(self.CurrTrackNearestItem.MapID, TargetPos, AutoMoveTargetType.Task, IsDstPosRejust)
					end
				else
					if _G.AutoPathMoveMgr:IsAutoPathMoveOpen() then
						if next(_G.QuestTrackMgr.NaviItemList) then --存在导航点
							_G.MsgTipsUtil.ShowTipsByID(40195) --提示无法寻路
						end
					end
				end
			end
		end
	end
end

--- 当前最近目标
---@param NearestItem NaviItemClass
function QuestTrackVM:SetCurrTrackTarget(NearestItem)
	self.CurrTrackNearestItem = NearestItem
	if self.CurrTrackQuestVM then
		if NearestItem then
			self.CurrTrackQuestVM.TrackTargetID = NearestItem.TargetID
		else
			self.CurrTrackQuestVM.TrackTargetID = nil
		end
	end
end

--- 追踪可接取的(主线)任务
---@param ChapterID number
---@param bOnNetMsg boolean
function QuestTrackVM:TrackCanAcceptQuest(ChapterID, bOnNetMsg)
	local ChapterStatus = QuestMgr:GetChapterStatus(ChapterID)
	if ChapterStatus ~= CHAPTER_STATUS.NOT_STARTED then
		QuestHelper.PrintQuestWarning("TrackCanAcceptQuest wrong status, chapter #%d status %d", ChapterID or 0, ChapterStatus)
		return
	end

	local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
	if not ChapterCfgItem then
		FLOG_ERROR(string.format("[QuestTrack] TrackCanAcceptQuest ChapterID=%s is invaild", tostring(ChapterID)))
		return
	end
	local AcceptMapID = ChapterCfgItem.MapID
	local StartQuestCfgItem = QuestHelper.GetQuestCfgItem(ChapterCfgItem.StartQuest)
	if StartQuestCfgItem then
		if StartQuestCfgItem.AcceptMapID > 0 then
			AcceptMapID = StartQuestCfgItem.AcceptMapID
		end
	end
	local ChapterVMItem = ChapterVM.New()
	ChapterVMItem:UpdateVM({ ChapterID = ChapterID })
	ChapterVMItem.MapIDList[AcceptMapID] = true
	ChapterVMItem.bActivatedMainline = true

    if not bOnNetMsg then
	    QuestMgr:SendTrackQuest(ChapterID)
    end

	self.CurrTrackChapterID = nil --这里为nil，如果赋值ChapterID，接取后有表现问题

	if self.CurrTrackQuestVM ~= nil then
		self.CurrTrackQuestVM.bTracking = false
		self.CurrTrackQuestVM.TrackTargetID = nil
	end

	self.CurrTrackQuestVM = ChapterVMItem

	_G.QuestTrackMgr:NaviToQuest(ChapterVMItem)

	local Param = ConstructTrackEventParam(ChapterVMItem)
	_G.EventMgr:SendEvent(_G.EventID.UpdateQuestTrack, Param)
end

function QuestTrackVM:StartCanAcceptQuestAutoPathMove(ChapterID)
	if not self.CurrTrackNearestItem then
		if _G.AutoPathMoveMgr:IsAutoPathMoveOpen() then
			if next(_G.QuestTrackMgr.NaviItemList) then --存在导航点
				_G.MsgTipsUtil.ShowTipsByID(40195) --提示无法寻路
			end
		end
		return
	end

	local ChapterStatus = QuestMgr:GetChapterStatus(ChapterID)
	if ChapterStatus ~= CHAPTER_STATUS.NOT_STARTED then
		return
	end

	local ChapterCfgItem = QuestHelper.GetChapterCfgItem(ChapterID)
	if not ChapterCfgItem then
		return
	end

	local QuestParamList = _G.QuestTrackMgr:GetMapQuestParam(ChapterCfgItem.MapID, ChapterCfgItem.StartQuest)
	if QuestParamList and #QuestParamList > 0 then
		local QuestParam = QuestParamList[1]
		local TargetPos = QuestParam.Pos
		local IsDstPosRejust = true
		if QuestParam.NaviType == QuestDefine.NaviType.NpcResID then
			local OffsetPos = _G.NavigationPathMgr.GetNavigationPosByNpcID(QuestParam.MapID, QuestParam.NaviObjID)
			if OffsetPos then
				TargetPos = OffsetPos
			end
			IsDstPosRejust = false
		end
		_G.QuestTrackMgr.AutoPathTrackChapterID = ChapterID
		_G.WorldMapMgr:StartMapAutoPathMove(QuestParam.MapID, TargetPos, AutoMoveTargetType.Task, IsDstPosRejust)
	end
end


return QuestTrackVM