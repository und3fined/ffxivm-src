
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local HUDType = require("Define/HUDType")
local HUDConfig = require("Define/HUDConfig")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local CommonDefine = require("Define/CommonDefine")
local MapCfg = require("TableCfg/MapCfg")

local UHUDMgr
local EventMgr ---@type EventMgr
local PWorldMgr ---@type PWorldMgr
local GoldSauserMgr ---@type GoldSauserMgr
local FLOG_INFO


---@class BuoyMgr : MgrBase
local BuoyMgr = LuaClass(MgrBase)

function BuoyMgr:OnInit()

end

function BuoyMgr:OnBegin()
	UHUDMgr = _G.UE.UHUDMgr:Get()
	EventMgr = _G.EventMgr
	PWorldMgr = _G.PWorldMgr
	GoldSauserMgr = _G.GoldSauserMgr
	FLOG_INFO = _G.FLOG_INFO

	self.BuoyUID = 1
	self:ClearAllBuoys()

	self.TimerInterval = 0.3

	self.bModuleBegin = true

	local QuestTrackMgr = _G.QuestTrackMgr
	local BuoyParam = QuestTrackMgr.DelayCreateBuoyParam
	if BuoyParam then
		QuestTrackMgr:UpdateQuestBuoy(BuoyParam.Pos, BuoyParam.IsAdjacentMap, BuoyParam.MapID)
	end

	-- 附近未解锁水晶追踪
	self.UnActivatedCrystalPortalInfo = nil
	self.UnActivatedCrystalBuoyUID = nil

	-- 金蝶地图机遇任务开启时NPC追踪
	self.CurrGoldGameNPC = nil
	self.GoldGameNPCBuoyUID = nil
	self.GoldGameNPCFollowState = true

	-- 浮标显隐引用计数
	self.HideAllBuoysRefCount = 0
end

function BuoyMgr:OnEnd()
	FLOG_INFO("BuoyMgr OnEnd")
	self.bModuleBegin = false
	self:ClearAllBuoys()
	self.HideAllBuoysRefCount = 0
end

function BuoyMgr:OnShutdown()
end

function BuoyMgr:OnRegisterNetMsg()
end

function BuoyMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)

	self:RegisterGameEvent(EventID.ClickScreenPosition, self.OnClickScreenPosition)
end

function BuoyMgr:OnRegisterTimer()
	self:RegisterTimer(self.OnTimerUpdateBuoy, 0, 1.0, 0)
end

function BuoyMgr:OnGameEventPWorldExit(Params)
	FLOG_INFO("BuoyMgr PWorldExit")
	self:ClearAllBuoys()
	self.HideAllBuoysRefCount = 0
end

local PixelPosition = _G.UE.FVector2D(0, 0)

function BuoyMgr:OnClickScreenPosition(Params)
	PixelPosition.X = Params.FloatParam1
	PixelPosition.Y = Params.FloatParam2
	--print("[BuoyMgr:OnClickScreenPosition] PixelPosition", PixelPosition)

	self:ProcessBuoyClick(PixelPosition)
end


--region 创建浮标

---一般是任务Npc使用
---@deprecated
---@param BuoyType HUDType|nil 浮标类型，默认为BuoyQuest
---@return number,number,number 返回BuoyUID
function BuoyMgr:AddBuoyByNpcID(NpcID, MapID, BuoyType)
	FLOG_INFO("BuoyMgr:AddBuoyByNpcID: %d", NpcID)
	BuoyType = BuoyType or HUDType.BuoyQuest
    local LocationMapType, MapNpc, BuoyPos, FindMapID = _G.MapEditDataMgr:GetNpcIncludeAdjacentMap(NpcID, MapID)
    if MapNpc then
		local IsAdjacentMap = true
		if not BuoyPos then	--表示本地图已经查到了
			local BP = MapNpc.BirthPoint
			BuoyPos = _G.UE.FVector(BP.X, BP.Y, BP.Z)
			IsAdjacentMap = false
		end

		MapID = MapID or FindMapID
		if self:CreateBuoy(BuoyPos, BuoyType, NpcID, IsAdjacentMap, MapID) then
			-- self.BuoyNPCMap[NpcID] = {BuoyObj = BuoyObj, BuoyUID = self.BuoyUID}
			return LocationMapType, self.BuoyUID, BuoyPos
		end
	end

	return nil
end

function BuoyMgr:AddBuoyByArea(AreaID, MapID, BuoyType)
	FLOG_INFO("BuoyMgr:AddBuoyByArea: %d", AreaID)
	BuoyType = BuoyType or HUDType.BuoyQuest
	local LocationMapType, MapArea, BuoyPos, FindMapID = _G.MapEditDataMgr:GetAreaByAdjacentMap(AreaID, MapID)
	if MapArea then
		local IsAdjacentMap = true
		if not BuoyPos then	--表示本地图已经查到了
			BuoyPos = _G.MapEditDataMgr:GetAreaPos(MapArea)
			IsAdjacentMap = false
		end

		MapID = MapID or FindMapID
		if self:CreateBuoy(BuoyPos, BuoyType, nil, IsAdjacentMap, MapID) then
			return LocationMapType, self.BuoyUID, BuoyPos
		end
	end

	return nil
end

---创建浮标
---@param BuoyPos Vector 浮标位置
---@param BuoyType HUDType 浮标类型
---@param IsAdjacentMap boolean 是否指向相邻地图。如果是相邻地图，此时BuoyPos是传送点位置，非最终目标点位置
---@param MapID number 浮标指向的地图ID，当前地图或相邻地图
function BuoyMgr:AddBuoyByPos(BuoyPos, BuoyType, IsAdjacentMap, MapID)
	FLOG_INFO("BuoyMgr:AddBuoyByPos BuoyPos:%s BuoyType:%d IsAdjacentMap:%s MapID:%s", tostring(BuoyPos), BuoyType, IsAdjacentMap, MapID)
	BuoyType = BuoyType or HUDType.BuoyQuest
	IsAdjacentMap = IsAdjacentMap or false
	MapID = MapID or 0

	if self:CreateBuoy(BuoyPos, BuoyType, nil, IsAdjacentMap, MapID) then
		return self.BuoyUID
	end

	return nil
end

-- 支持跨地图的坐标，目前接口未使用
function BuoyMgr:AddBuoyByPos2(Pos, MapID, BuoyType)
	BuoyType = BuoyType or HUDType.BuoyQuest
	local LocationMapType, Result, BuoyPos = _G.MapEditDataMgr:GetMapByAdjacentMap(MapID)
	if Result then
		local IsAdjacentMap = true
		if not BuoyPos then
			BuoyPos = Pos
			IsAdjacentMap = false
		end

		if self:CreateBuoy(BuoyPos, BuoyType, nil, IsAdjacentMap, MapID) then
			return LocationMapType, self.BuoyUID, BuoyPos
		end
	end

	return nil
end

---@deprecated
function BuoyMgr:AddBuoyByPoint(PointID, MapID, BuoyType)
	FLOG_INFO("BuoyMgr:AddBuoyByPoint: %d", PointID)
	BuoyType = BuoyType or HUDType.BuoyQuest
	local LocationMapType, PointInfo, BuoyPos, FindMapID = _G.MapEditDataMgr:GetPointByAdjacentMap(PointID, MapID)
	if PointInfo then
		local IsAdjacentMap = true
		if not BuoyPos then	--表示本地图已经查到了
			local VecPoint = _G.UE.FVector(0.0, 0.0, 0.0)
			VecPoint.X = PointInfo.Point.X
			VecPoint.Y = PointInfo.Point.Y
			VecPoint.Z = PointInfo.Point.Z

			BuoyPos = VecPoint
			IsAdjacentMap = false
		end

		MapID = MapID or FindMapID
		if self:CreateBuoy(BuoyPos, BuoyType, nil, IsAdjacentMap, MapID) then
			return LocationMapType, self.BuoyUID, BuoyPos
		end
	end

	return nil
end

---怪物用ListID而非ResID，因为一个地图可能有多个同ResID怪物
function BuoyMgr:AddBuoyByMonsterListID(MonsterListID, MapID, BuoyType)
	FLOG_INFO("BuoyMgr:AddBuoyByMonsterListID: %d", MonsterListID)
	BuoyType = BuoyType or HUDType.BuoyQuest
    local LocationMapType, MapMonster, BuoyPos, FindMapID = _G.MapEditDataMgr:GetMonsterByAdjacentMap(MonsterListID, MapID)
    if MapMonster then
		local IsAdjacentMap = true
		if not BuoyPos then	--表示本地图已经查到了
			local BP = MapMonster.BirthPoint
			BuoyPos = _G.UE.FVector(BP.X, BP.Y, BP.Z)
			IsAdjacentMap = false
		end

		MapID = MapID or FindMapID
		if self:CreateBuoy(BuoyPos, BuoyType, nil, IsAdjacentMap, MapID) then
			return LocationMapType, self.BuoyUID, BuoyPos
		end
	end

	return nil
end

---怪物组用ListID
function BuoyMgr:AddBuoyByMonsterGroupListID(MonGroupListID, MapID, BuoyType)
	FLOG_INFO("BuoyMgr:AddBuoyByMonsterGroupListID: %d", MonGroupListID)
	BuoyType = BuoyType or HUDType.BuoyQuest
    local LocationMapType, MapMonGroup, BuoyPos, FindMapID = _G.MapEditDataMgr:GetMonsterGroupByAdjacentMap(MonGroupListID, MapID)
    if MapMonGroup then
		local IsAdjacentMap = true
		if not BuoyPos then	--表示本地图已经查到了
			BuoyPos = _G.UE.FVector()
			local MonstersNum = #MapMonGroup.Monsters
			for _, Monster in ipairs(MapMonGroup.Monsters) do
				local BP = Monster.BirthPoint
				BuoyPos = BuoyPos + (_G.UE.FVector(BP.X, BP.Y, BP.Z) / MonstersNum)
			end
			IsAdjacentMap = false
		end

		MapID = MapID or FindMapID
		if self:CreateBuoy(BuoyPos, BuoyType, nil, IsAdjacentMap, MapID) then
			return LocationMapType, self.BuoyUID, BuoyPos
		end
	end

	return nil
end

function BuoyMgr:AddBuoyByEObjID(EObjID, MapID, BuoyType)
	FLOG_INFO("BuoyMgr:AddBuoyByEObjID: %d", EObjID)
	BuoyType = BuoyType or HUDType.BuoyQuest
    local LocationMapType, MapEObj, BuoyPos, FindMapID = _G.MapEditDataMgr:GetEObjIncludeAdjacentMap(EObjID, MapID)
    if MapEObj then
		local IsAdjacentMap = true
		if not BuoyPos then	--表示本地图已经查到了
			local BP = MapEObj.Point
			BuoyPos = _G.UE.FVector(BP.X, BP.Y, BP.Z)
			IsAdjacentMap = false
		end

		MapID = MapID or FindMapID
		if self:CreateBuoy(BuoyPos, BuoyType, nil, IsAdjacentMap, MapID) then
			return LocationMapType, self.BuoyUID, BuoyPos
		end
	end

	return nil
end

function BuoyMgr:AddBuoyByCrystalID(CrystalID, MapID, BuoyType)
	FLOG_INFO("BuoyMgr:AddBuoyByCrystalID: %d", CrystalID)
	BuoyType = BuoyType or HUDType.BuoyQuest
	local LocationMapType, CrystalInfo, BuoyPos, FindMapID = _G.MapEditDataMgr:GetCrystalIncludeAdjacentMap(CrystalID, MapID)
	if CrystalInfo then
		local IsAdjacentMap = true
		if not BuoyPos then	--表示本地图已经查到了
			local VecPoint = _G.UE.FVector(0.0, 0.0, 0.0)
			VecPoint.X = CrystalInfo.Pos.X
			VecPoint.Y = CrystalInfo.Pos.Y
			VecPoint.Z = CrystalInfo.Pos.Z

			BuoyPos = VecPoint
			IsAdjacentMap = false
		end

		MapID = MapID or FindMapID
		if self:CreateBuoy(BuoyPos, BuoyType, nil, IsAdjacentMap, MapID) then
			return LocationMapType, self.BuoyUID, BuoyPos
		end
	end

	return nil
end

--endregion


function BuoyMgr:RemoveBuoyByUID(BuoyUID)
	if self.BuoyList == nil then return end

	local BuoyInfo = self.BuoyList[BuoyUID]
	if BuoyInfo == nil then
		FLOG_INFO("BuoyMgr:RemoveBuoyByUID BuoyUID:%d not exist in BuoyList", BuoyUID)
		return
	end

	FLOG_INFO("BuoyMgr:RemoveBuoyByUID BuoyUID:%d", BuoyUID)
	UHUDMgr:ReleaseObject(BuoyInfo.BuoyObj)
	self.BuoyList[BuoyUID] = nil
end

function BuoyMgr:UpdateBuoyPos(BuoyUID, Pos, IsAdjacentMap, MapID)
	if self.BuoyList == nil then return end

	local BuoyInfo = self.BuoyList[BuoyUID]
	if BuoyInfo and BuoyInfo.BuoyObj then
		BuoyInfo.Pos = Pos
		BuoyInfo.BuoyObj:SetTargetLocation(Pos)
		BuoyInfo.IsAdjacentMap = IsAdjacentMap
		BuoyInfo.MapID = MapID
	end
end

--Pos是世界坐标
function BuoyMgr:CreateBuoy(Pos, BuoyType, NpcID, IsAdjacentMap, MapID)
	UHUDMgr = _G.UE.UHUDMgr:Get()
	if not UHUDMgr then
		FLOG_INFO("BuoyMgr:CreateBuoy UHUDMgr invalid")
		return nil
	end

	if CommonDefine.Buoy.Disable then
		FLOG_INFO("BuoyMgr:CreateBuoy but disable")
		return nil
	end

	BuoyType = BuoyType or HUDType.BuoyQuest
	local Path = HUDConfig:GetPath(BuoyType)
	if nil == Path then
		FLOG_INFO("BuoyMgr:CreateBuoy path is nil")
		return nil
	end

	if not self.TimerID then
		local TimerID = _G.TimerMgr:AddTimer(self, self.UpdateBuoys, 0, self.TimerInterval, 0)
		self.TimerID = TimerID
	end

	local WorldOriginLoc = _G.PWorldMgr:GetWorldOriginLocation()
	local BuoyPos = Pos - WorldOriginLoc

	--[[
	local BuoyList = self.BuoyList
	if BuoyList then
		for _, BuoyInfo in pairs(BuoyList) do
			if BuoyInfo and BuoyInfo.Pos == BuoyPos then
				-- 同一个位置如果存在优先级更高的浮标，则取消当前浮标，创建优先级更高的浮标；否则跳过不创建
				-- 追踪优先级：任务追踪＞地图手动追踪＞业务自动追踪
				if BuoyType < BuoyInfo.BuoyType then
					FLOG_INFO("BuoyMgr:CreateBuoy")
					self:CancelBuoyTrack(BuoyInfo.BuoyType, true)
					break
				else
					FLOG_INFO("BuoyMgr:CreateBuoy pos exist buoy, BuoyType=%d BuoyInfo.BuoyType=%d", BuoyType, BuoyInfo.BuoyType)
					return
				end
			end
		end
	end
	--]]

	local TargetLocation = _G.UE.FVector(BuoyPos.X, BuoyPos.Y, BuoyPos.Z + CommonDefine.Buoy.TargetLocationAddZ)
	local BuoyObj = UHUDMgr:CreateBuoy(BuoyType, Path, NpcID, TargetLocation
						, CommonDefine.Buoy.HideDistanceInView, CommonDefine.Buoy.EllipseWidthMargin, CommonDefine.Buoy.EllipseHeightMargin)
	local TextWidget = nil
	if BuoyObj then
		self.BuoyUID = self.BuoyUID + 1
		FLOG_INFO("BuoyMgr:CreateBuoy BuoyUID:%d", self.BuoyUID)

		TextWidget = BuoyObj:FindWidget("DistanceText")
		--[[
		if IsAdjacentMap then
			local MapEditCfg = _G.MapEditDataMgr:GetAdjacentMapInfo(MapID)
			if MapEditCfg then
				local MapCfg = _G.PWorldMgr:GetMapTableCfg(MapID)
				if MapCfg then
					UHUDMgr:SetText(TextWidget, string.format("%s", MapCfg.DisplayName))
					UHUDMgr:SetVisible(TextWidget, true)
					UHUDMgr:SetTextOutlineColorHex(TextWidget, "000000B3")--B7821CB2
				end
			end
		end
		--]]

		if self:CanClickSelect(BuoyType) then
			-- 将浮标Icon重置为Normal图标，因为缓存池的原因
			local BuoyIcon = BuoyObj:FindWidget("BuoyIcon")
			local IconPath = HUDConfig:GetNormalStateTexturePath(BuoyType)
			UHUDMgr:SetTextureFromAssetPath(BuoyIcon, IconPath)
		end

		BuoyObj:UpdateLayout()
	else
		FLOG_ERROR("BuoyMgr:CreateBuoy failed")
	end

	self.BuoyList[self.BuoyUID] =
	{
		BuoyType = BuoyType,
		BuoyObj = BuoyObj,
		IsAdjacentMap = IsAdjacentMap,
		MapID = MapID,
		TextWidget = TextWidget,
		Pos = BuoyPos,
	}

	self:UpdateAllBuoysShow()

	return BuoyObj
end

function BuoyMgr:ClearAllBuoys()
	if self.BuoyList then
		for BuoyUID, BuoyInfo in pairs(self.BuoyList) do
			if BuoyInfo then
				FLOG_INFO("BuoyMgr:ClearAllBuoys BuoyUID:%d", BuoyUID)
				UHUDMgr:ReleaseObject(BuoyInfo.BuoyObj)
			end
		end
	end

	-- 列表置空前，先要把创建的浮标释放掉
	self.BuoyList = {}

	if self.TimerID then
		_G.TimerMgr:CancelTimer(self.TimerID)
		self.TimerID = nil
	end
end

function BuoyMgr:ShowAllBuoys(bShow)
	self.HideAllBuoysRefCount = self.HideAllBuoysRefCount or 0
	if not bShow then
		self.HideAllBuoysRefCount = self.HideAllBuoysRefCount + 1
	else
		self.HideAllBuoysRefCount = self.HideAllBuoysRefCount - 1
	end
	_G.FLOG_INFO("BuoyMgr:ShowAllBuoys: %s CurHideAllBuoysRefCount:%d", tostring(bShow), self.HideAllBuoysRefCount)

	self:UpdateAllBuoysShow()
end

function BuoyMgr:UpdateAllBuoysShow()
	local bShow = true
	if self.HideAllBuoysRefCount > 0 then
		bShow = false
	else
		self.HideAllBuoysRefCount = 0
		bShow = true
	end

	if self.BuoyList == nil then return end

	for _, BuoyInfo in pairs(self.BuoyList) do
		if BuoyInfo and BuoyInfo.BuoyObj then
			BuoyInfo.BuoyObj:SetIsDraw(bShow)
		end
	end
end

function BuoyMgr:UpdateBuoys()
	if self.BuoyList == nil then return end

	local BuoysCnt = 0
	local Major = MajorUtil.GetMajor()
	if Major == nil then return end
	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)

	for _, BuoyInfo in pairs(self.BuoyList) do
		BuoysCnt = BuoysCnt + 1

		if BuoyInfo and self:IsNeedShowDistance(BuoyInfo.BuoyType) then
			local TextWidget = BuoyInfo.TextWidget
			if TextWidget then
				local Dist = _G.UE.FVector.Dist(MajorPos, BuoyInfo.Pos) / 100 -- CM到M
				local FmtText = HUDConfig:GetText(BuoyInfo.BuoyType)
				Dist = math.floor(Dist)
				local DistanceStr = string.format(FmtText, Dist)

				-- 跨地图显示
				if BuoyInfo.IsAdjacentMap then
					local ServerTime = TimeUtil.GetServerTimeMS()
					local ShowTextTime = BuoyInfo.ShowTextTime or 0
					local LastShowTextType = BuoyInfo.ShowTextType
					if ServerTime - ShowTextTime > CommonDefine.Buoy.TurnDisplayTime then
						-- 相邻地图的名称和与目标点的距离，轮流显示
						BuoyInfo.ShowTextType = (BuoyInfo.ShowTextType == 1) and 2 or 1
						BuoyInfo.ShowTextTime = ServerTime
					end

					-- 轮流显示切换时播放动效
					if LastShowTextType ~= BuoyInfo.ShowTextType then
						BuoyInfo.BuoyObj:PlayAnimation("AnimChange", false, 1.0)
					end
				end

				if BuoyInfo.ShowTextType == 2 and BuoyInfo.IsAdjacentMap and BuoyInfo.MapID then
					-- 显示相邻地图的名称
					local MapTableCfg = _G.PWorldMgr:GetMapTableCfg(BuoyInfo.MapID)
					if MapTableCfg then
						local MapName = MapTableCfg.DisplayName
						local MapStrLen = string.len(MapName)
						UHUDMgr:SetText(TextWidget, string.format("%s", MapName))
						UHUDMgr:SetTextOutlineColorHex(TextWidget, "000000B3")

						if not BuoyInfo.StrLen or BuoyInfo.StrLen ~= MapStrLen then
							BuoyInfo.StrLen = MapStrLen
							BuoyInfo.BuoyObj:UpdateLayout()
						end
					end

				else
					-- 显示与目标点的距离
					local DistanceStrLen = string.len(DistanceStr)
					UHUDMgr:SetText(TextWidget, DistanceStr)
					UHUDMgr:SetTextOutlineColorHex(TextWidget, "000000B3")

					if not BuoyInfo.StrLen or BuoyInfo.StrLen ~= DistanceStrLen then
						BuoyInfo.StrLen = DistanceStrLen
						BuoyInfo.BuoyObj:UpdateLayout()
					end
				end

				if self:CanCancelTrackByDistance(BuoyInfo.BuoyType)
					and not BuoyInfo.IsAdjacentMap
					and Dist < CommonDefine.Buoy.CancelTrackDistance / 100 then
					-- 当前地图，给定距离内，自动取消追踪
					-- 跨地图追踪时，不能用中间传送点Pos计算的距离，判断取消追踪
					FLOG_INFO("BuoyMgr:UpdateBuoys CancelBuoyTrack")
					self:CancelBuoyTrack(BuoyInfo.BuoyType, true)
				end
			end
		end
	end

	if BuoysCnt == 0 and self.TimerID then
		_G.TimerMgr:CancelTimer(self.TimerID)
		self.TimerID = nil
	end
end

-- 给定浮标类型是否需要显示距离
function BuoyMgr:IsNeedShowDistance(BuoyType)
	if BuoyType == HUDType.BuoyQuest
		or BuoyType == HUDType.BuoyAetherCurrent
		or BuoyType == HUDType.BuoyMapFollow
		or BuoyType == HUDType.BuoyUnActivatedCrystal
		or BuoyType == HUDType.BuoyGoldGameNPC then
		return true
	end

	return false
end

-- 给定浮标类型是否可以手动点击取消追踪
function BuoyMgr:CanClickSelect(BuoyType)
	if BuoyType == HUDType.BuoyQuest
		or BuoyType == HUDType.BuoyMapFollow
		or BuoyType == HUDType.BuoyGoldGameNPC then
		return true
	end

	return false
end

-- 给定浮标类型不可见距离内是否自动取消追踪
function BuoyMgr:CanCancelTrackByDistance(BuoyType)
	if BuoyType == HUDType.BuoyMapFollow
		or BuoyType == HUDType.BuoyGoldGameNPC then
		return true
	end

	return false
end

-- 给定浮标类型取消追踪
---@param BuoyType HUDType 浮标类型
---@param AutoCancel boolean 是否自动取消追踪
function BuoyMgr:CancelBuoyTrack(BuoyType, AutoCancel)
	FLOG_INFO("BuoyMgr:CancelBuoyTrack BuoyType:%d, AutoCancel:%s", BuoyType, tostring(AutoCancel))
	if BuoyType == HUDType.BuoyQuest then
		local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
		QuestMainVM.QuestTrackVM:TrackQuest(nil)
	elseif BuoyType == HUDType.BuoyMapFollow then
		_G.WorldMapMgr:CancelMapFollow(AutoCancel)
	elseif BuoyType == HUDType.BuoyUnActivatedCrystal then
		self.UnActivatedCrystalPortalInfo = nil
		self:RemoveUnActivatedCrystalBuoy()
	elseif BuoyType == HUDType.BuoyGoldGameNPC then
		BuoyMgr:SetGoldGameNPCFollowState(false)
	end
end

-- 浮标点击处理
function BuoyMgr:ProcessBuoyClick(LocalPosition)
	local BuoyList = self.BuoyList
	if BuoyList == nil then
		return
	end
	for _, BuoyInfo in pairs(BuoyList) do
		if BuoyInfo and self:CanClickSelect(BuoyInfo.BuoyType) then
			local Size = UHUDMgr:GetSize(BuoyInfo.BuoyObj)
			local Postion = UHUDMgr:GetPosition(BuoyInfo.BuoyObj)
			--FLOG_INFO("[BuoyMgr:ProcessBuoyClick] BuoyObj Size %d,%d, Postion %d,%d", Size.X, Size.Y, Postion.X, Postion.Y)
			local BuoyIcon = BuoyInfo.BuoyObj:FindWidget("BuoyIcon")
			local BuoyType = BuoyInfo.BuoyType

			if (LocalPosition.X >= Postion.X - Size.X/2
				and LocalPosition.X <= Postion.X + Size.X/2
				and LocalPosition.Y >= Postion.Y - Size.Y/2
				and LocalPosition.Y <= Postion.Y + Size.Y/2) then
				-- 点击位置在浮标区域内
				--FLOG_INFO("[BuoyMgr:ProcessBuoyClick] click in buoy box, BuoyType=%d IsSelect=%s", BuoyType, BuoyInfo.IsSelect)
				if BuoyInfo.IsSelect then
					-- 二次点击，取消跟踪
					FLOG_INFO("[BuoyMgr:ProcessBuoyClick] click in buoy box again, cancel buoy track")
					self:CancelBuoyTrack(BuoyType)
					break
				end

				-- 首次点击，切位选中状态
				BuoyInfo.IsSelect = true
				local IconPath = HUDConfig:GetSelectStateTexturePath(BuoyType)
				UHUDMgr:SetTextureFromAssetPath(BuoyIcon, IconPath)
				BuoyInfo.BuoyObj:UpdateLayout()

				-- 一次点击只能选择一个浮标
				break

			else
				-- 点击位置在浮标区域外
				--FLOG_INFO("[BuoyMgr:ProcessBuoyClick] click out buoy box, BuoyType=%d IsSelect=%s", BuoyType, BuoyInfo.IsSelect)
				if BuoyInfo.IsSelect then
					-- 取消选择
					BuoyInfo.IsSelect = false
					local IconPath = HUDConfig:GetNormalStateTexturePath(BuoyType)
					UHUDMgr:SetTextureFromAssetPath(BuoyIcon, IconPath)
					BuoyInfo.BuoyObj:UpdateLayout()
				end
			end
		end
	end
end


function BuoyMgr:OnTimerUpdateBuoy()
	self:CheckUnActivatedCrystal()
	self:CheckGoldGameNPC()
	self:UpdateMapFollowBuoy()
end

-- 更新地图追踪浮标
function BuoyMgr:UpdateMapFollowBuoy()
	local BuoyList = self.BuoyList
	if BuoyList == nil then
		return
	end
	for _, BuoyInfo in pairs(BuoyList) do
		if BuoyInfo and BuoyInfo.BuoyType == HUDType.BuoyMapFollow
			and not BuoyInfo.IsAdjacentMap
			and _G.WorldMapMgr:IsMapFollowPlaced()
			and _G.WorldMapMgr:IsMapFollowCurrUIMap() then
			-- 手动标记点，浮标改用主角当前的Z坐标
			local Major = MajorUtil.GetMajor()
			if Major == nil then return end
			local MajorPos = Major:FGetActorLocation()
			BuoyInfo.Pos.Z = MajorPos.Z
			BuoyInfo.BuoyObj:SetTargetLocation(BuoyInfo.Pos)
			--local NameLocation = _G.UE.FVector(0, 0, 0)
			--BuoyInfo.BuoyObj:GetTargetLocation(NameLocation)
			--print("BuoyMgr:UpdateMapFollowBuoy", NameLocation)
		end
	end
end


--region 附近未解锁水晶追踪浮标

function BuoyMgr:CheckUnActivatedCrystal()
	local CrystalPortalInfo = PWorldMgr:GetCrystalPortalMgr():FindCrystalByDistance(CommonDefine.Buoy.UnActivatedCrystalDistance, false)
	if CrystalPortalInfo == nil then
		self.UnActivatedCrystalPortalInfo = nil
		self:RemoveUnActivatedCrystalBuoy()
		return
	end

	if CrystalPortalInfo == self.UnActivatedCrystalPortalInfo then
		return
	end
	self.UnActivatedCrystalPortalInfo = CrystalPortalInfo

	self:RemoveUnActivatedCrystalBuoy()
	local BuoyUID = self:AddBuoyByPos(CrystalPortalInfo.Pos, HUDType.BuoyUnActivatedCrystal)
	if BuoyUID then
		self.UnActivatedCrystalBuoyUID = BuoyUID
		EventMgr:SendEvent(EventID.MapFollowTargetUpdate)
	end
end

function BuoyMgr:RemoveUnActivatedCrystalBuoy()
	if self.UnActivatedCrystalBuoyUID ~= nil then
		self:RemoveBuoyByUID(self.UnActivatedCrystalBuoyUID)
		self.UnActivatedCrystalBuoyUID = nil
		EventMgr:SendEvent(EventID.MapFollowTargetUpdate)
	end
end

--endregion


--region 金蝶地图机遇任务开启时NPC追踪浮标

local JDMapID = 12060 -- 金蝶的地图ID

function BuoyMgr:CheckGoldGameNPC()
	if PWorldMgr == nil or GoldSauserMgr == nil then
		return
	end
	if PWorldMgr:GetCurrMapResID() ~= JDMapID then
		return
	end

	local bCanSignUp = GoldSauserMgr:CanSignUp()
	if not bCanSignUp then
		self.CurrGoldGameNPC = nil
		self:RemoveGoldGameNPCBuoy()
		return
	end

	local GameNPC = GoldSauserMgr:GetCurGameNpc()
	if GameNPC == nil then
		self.CurrGoldGameNPC = nil
		self:RemoveGoldGameNPCBuoy()
		return
	end

	if not self.GoldGameNPCFollowState then
		self.CurrGoldGameNPC = nil
		self:RemoveGoldGameNPCBuoy()
		return
	end

	if GameNPC == self.CurrGoldGameNPC then
		return
	end
	self.CurrGoldGameNPC = GameNPC

	self:RemoveGoldGameNPCBuoy()
	local NpcData = _G.MapEditDataMgr:GetNpc(GameNPC.NpcID)
	if NpcData == nil then
		return
	end
	local Point = NpcData.BirthPoint
	local Pos = _G.UE.FVector(Point.X, Point.Y, Point.Z)
	local BuoyUID = self:AddBuoyByPos(Pos, HUDType.BuoyGoldGameNPC)
	if BuoyUID then
		self.GoldGameNPCBuoyUID = BuoyUID
		EventMgr:SendEvent(EventID.MapFollowTargetUpdate)
	end
end

function BuoyMgr:RemoveGoldGameNPCBuoy()
	if self.GoldGameNPCBuoyUID ~= nil then
		self:RemoveBuoyByUID(self.GoldGameNPCBuoyUID)
		self.GoldGameNPCBuoyUID = nil
		EventMgr:SendEvent(EventID.MapFollowTargetUpdate)
	end
end

---获取金蝶地图机遇任务开启时NPC追踪信息
---@return boolean, GameNPC 是否追踪状态，追踪NPC信息
function BuoyMgr:GetGoldGameNPCFollowInfo()
	if self.GoldGameNPCFollowState and self.CurrGoldGameNPC then
		return true, self.CurrGoldGameNPC
	end
	return false
end

---设置金蝶地图机遇任务开启时NPC追踪状态
---@param FollowState boolean 是否追踪状态
function BuoyMgr:SetGoldGameNPCFollowState(FollowState)
	self.GoldGameNPCFollowState = FollowState
	self:CheckGoldGameNPC()
end

--endregion


return BuoyMgr
