local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local EffectUtil = require("Utils/EffectUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local CommonUtil = require("Utils/CommonUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local AudioUtil = require("Utils/AudioUtil")
local ObjectGCType = require("Define/ObjectGCType")
local InterpretTreasureMapCfg = require("TableCfg/InterpretTreasureMapCfg")
local TreasureHuntMapSItemVM = require("Game/TreasureHunt/VM/TreasureHuntMapSItemVM") 
local TreasureHuntBtnItemVM = require("Game/TreasureHunt/VM/TreasureHuntBtnItemVM") 

local UE = nil
local LSTR = nil

local TreasureHuntSkillPanelVM = LuaClass(UIViewModel)
function TreasureHuntSkillPanelVM:Ctor()
	self.CurMapData = nil
	self.bIsPanelClosedByOtherUI = false
end

function TreasureHuntSkillPanelVM:OnInit()
	UE = _G.UE
    LSTR = _G.LSTR
	self.SkillPanelMapVM = TreasureHuntMapSItemVM.New()
	self.BtnItemVM = TreasureHuntBtnItemVM.New()
end

function TreasureHuntSkillPanelVM:OnShutdown()
    self.SkillPanelMapVM = nil

	self.bIsPanelClosedByOtherUI = false
end

function TreasureHuntSkillPanelVM:GetMapItemVM()
	return self.SkillPanelMapVM
end

function TreasureHuntSkillPanelVM:SetMarkTreasureMap()
	if self.CurMapData == nil then return end
	
	self.CurMapData.MarkPoint = true
end

function TreasureHuntSkillPanelVM:SetCurMapData(MapData)
	self.CurMapData = MapData
end

function TreasureHuntSkillPanelVM:GetCurMapData()
	return self.CurMapData
end

-- 启动定时器
function TreasureHuntSkillPanelVM:AddPositionTimer()
	self:ClosePositionTimer()
	self.PositionTimer = _G.TimerMgr:AddTimer(self, self.UpdatePosition, 0, 0.1, -1)
end

-- 关闭定时器
function TreasureHuntSkillPanelVM:ClosePositionTimer()
	if self.PositionTimer ~= nil then
		_G.TimerMgr:CancelTimer(self.PositionTimer)
		self.PositionTimer = nil
	end
end

function TreasureHuntSkillPanelVM:UpdateSkillPanel()
	if self.CurMapData == nil then return end
	
	local mapData = {}
	local TreasureMapCfg = InterpretTreasureMapCfg:FindCfgByKey(self.CurMapData.ID)
	if TreasureMapCfg == nil then return end

	mapData.Number = TreasureMapCfg.Number
	mapData.ID = TreasureMapCfg.ID 
	mapData.UnDecodeMapID = TreasureMapCfg.UnReadID 

	mapData.MapResID = self.CurMapData.MapResID 
	mapData.Pos = self.CurMapData.Pos
	mapData.PosID = self.CurMapData.PosID

	mapData.OwnerName = LSTR("")
	local function Callback(_, RoleVM)
		if RoleVM ~= nil then
			mapData.OwnerName = RoleVM.Name
		end
	end
	RoleInfoMgr:QueryRoleSimple(self.CurMapData.RoleID, Callback)

	if self.SkillPanelMapVM ~= nil then
		self.SkillPanelMapVM:UpdateSkillPanel(mapData)
	end
end

function TreasureHuntSkillPanelVM:UpdatePosition()
	if self.SkillPanelMapVM ==  nil or self.CurMapData == nil then
		self:ClosePositionTimer()
		return
	end

	local sameMap = true
	local distance = 0
	local localMapID = _G.PWorldMgr:GetCurrMapResID()
	if localMapID ~= self.CurMapData.MapResID then 
		sameMap = false 
	else 
		local MajorPos =  MajorUtil.GetMajor():FGetActorLocation()
		local Pos = self.CurMapData.Pos
	    local _targetPos = _G.UE.FVector(Pos.X,Pos.Y,Pos.Z)
	    distance = _G.UE.FVector.Dist(MajorPos, _targetPos)/100
	end

	self.SkillPanelMapVM:UpdateDist(sameMap,distance)
	if sameMap then
		if distance <= _G.TreasureHuntMgr:GetTreasureHuntRadius() then
			if self.bIsPanelClosedByOtherUI then
				UIViewMgr:HideView(UIViewID.TreasureHuntBtnItem)
			else	
				local MajorEntityID = MajorUtil.GetMajorEntityID()
				local IsDeadState = ActorUtil.IsDeadState(MajorEntityID)
				
				if not IsDeadState then
					if not UIViewMgr:IsViewVisible(UIViewID.TreasureHuntBtnItem) then
						UIViewMgr:ShowView(UIViewID.TreasureHuntBtnItem)
						self.BtnItemVM:UpdateBtnItem()
					end
				else 
					UIViewMgr:HideView(UIViewID.TreasureHuntBtnItem)
				end
			end
		elseif distance > _G.TreasureHuntMgr:GetTreasureHuntRadius() then 
			UIViewMgr:HideView(UIViewID.TreasureHuntBtnItem)
		end
	else
	    UIViewMgr:HideView(UIViewID.TreasureHuntBtnItem)
	end
	if self.bIsPanelClosedByOtherUI then
		UIViewMgr:HideView(UIViewID.TreasureHuntBtnItem)
	end
end
-----------------------------------------------------------------
function TreasureHuntSkillPanelVM:ShowSkillPanel(MapData)
	self:CloseSkillPanel()
	
	if _G.TreasureHuntMgr:IsInDungeon(false) then return end

	self:SetCurMapData(MapData)
	self:UpdateSkillPanel()
	UIViewMgr:ShowView(UIViewID.TreasureHuntSkillPanel)
end

function TreasureHuntSkillPanelVM:CloseSkillPanel()
	if UIViewMgr:IsViewVisible(UIViewID.TreasureHuntSkillPanel) then
		UIViewMgr:HideView(UIViewID.TreasureHuntSkillPanel)	
		UIViewMgr:HideView(UIViewID.TreasureHuntBtnItem)			
	end
end

function TreasureHuntSkillPanelVM:MarkTreasureMapReq()	
	if self.CurMapData == nil then return end
	
	local Major = MajorUtil.GetMajor()
	if Major:IsInFly() then 
		_G.MsgTipsUtil.ShowTips(LSTR(640019)) --飞行状态下，无法标记
		return 
	end

	local StateCom = MajorUtil.GetMajorStateComponent()
	if StateCom ~= nil then
		if StateCom:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_DEAD) then
			_G.MsgTipsUtil.ShowTips(LSTR(640020)) --死亡状态下，无法标记
			return
		end
		if StateCom:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT) then
			_G.MsgTipsUtil.ShowTips(LSTR(640021)) --战斗状态下，无法标记
			return 
		end
	end

	local function CancelCallback()
		_G.TreasureHuntMgr:TreasureMarkPointReq(self.CurMapData.ID)
    end

	local RideCom = Major:GetRideComponent()
	if RideCom and RideCom:IsInRide() then
        _G.MountMgr:SendMountCancelCall(CancelCallback)
	else
		CancelCallback()
	end
end

function TreasureHuntSkillPanelVM:SetPanelClosedByOtherUI(Flag)
	self.bIsPanelClosedByOtherUI = Flag
end

function TreasureHuntSkillPanelVM:IsPanelClosedByOtherUI()
	return self.bIsPanelClosedByOtherUI
end

return TreasureHuntSkillPanelVM