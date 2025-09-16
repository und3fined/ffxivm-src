---
--- Author: sammrli
--- DateTime: 2024-02-28 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapDefine = require("Game/Map/MapDefine")
local EObjCfg = require("TableCfg/EobjCfg")
local NpcCfg = require("TableCfg/NpcCfg")
local ChocoboTransportDefine = require("Game/Chocobo/Transport/ChocoboTransportDefine")

local MapMarkerType = MapDefine.MapMarkerType

---@class WorldMapMarkerTipsChocoboTransportView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTransfer UFButton
---@field Common_PopUpBG_UIBP CommonPopUpBGView
---@field IconChocobo UFImage
---@field IconQuest UFImage
---@field PanelRoot UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field TextName UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapMarkerTipsChocoboTransportView = LuaClass(UIView, true)

function WorldMapMarkerTipsChocoboTransportView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTransfer = nil
	--self.Common_PopUpBG_UIBP = nil
	--self.IconChocobo = nil
	--self.IconQuest = nil
	--self.PanelRoot = nil
	--self.PanelTips = nil
	--self.TextName = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsChocoboTransportView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_PopUpBG_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsChocoboTransportView:OnInit()

end

function WorldMapMarkerTipsChocoboTransportView:OnDestroy()

end

function WorldMapMarkerTipsChocoboTransportView:OnShow()
	local Params = self.Params
	if not Params then
		return
	end

	local ScreenPosition = Params.ScreenPosition
	local _, ViewportPosition = UIUtil.AbsoluteToViewport(ScreenPosition)
	UIUtil.CanvasSlotSetPosition(self.PanelTips, ViewportPosition)

	local MapMarker = Params.MapMarker
	if MapMarker then
		local MarkerType = MapMarker:GetType()
		UIUtil.SetIsVisible(self.IconQuest, MarkerType == MapMarkerType.ChocoboTransportPoint)
		UIUtil.SetIsVisible(self.IconChocobo, MarkerType == MapMarkerType.ChocoboStable)

		self.WorldPosX, self.WorldPoxY, self.WorldPoxZ = MapMarker:GetWorldPos()

		self.TextName:SetText(MapMarker:GetTipsName())
		if MarkerType == MapMarkerType.ChocoboTransportPoint then
			UIUtil.ImageSetBrushFromAssetPath(self.IconQuest, MapMarker:GetIconPath())
		end
	end
end

function WorldMapMarkerTipsChocoboTransportView:OnHide()

end

function WorldMapMarkerTipsChocoboTransportView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTransfer, self.OnClickedBtnTransfer)
end

function WorldMapMarkerTipsChocoboTransportView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ChocoboTransportBegin, self.OnGameEventChocoboTransportBegin)
end

function WorldMapMarkerTipsChocoboTransportView:OnRegisterBinder()

end

function WorldMapMarkerTipsChocoboTransportView:OnClickedBtnTransfer()
	local NpcID = 0
	local MapID = 0
	local Params = self.Params
	local SafeDistance = nil
	if Params and Params.MapMarker then
		NpcID = Params.MapMarker.NpcID
		MapID = Params.MapMarker.MapID

		local MarkerType = Params.MapMarker:GetType()
		if MarkerType == MapMarkerType.ChocoboTransportPoint then
			if not Params.MapMarker.IsHasAssistPos then
				-- 如果是npc
				local NaviNpcID = Params.MapMarker.NaviNpcID
				if NaviNpcID and NaviNpcID > 0 then
					local NpcCfgItem = NpcCfg:FindCfgByKey(NaviNpcID)
					if NpcCfgItem then
						SafeDistance = NpcCfgItem.InteractionRange
					end
				end
				-- 如果目标是水晶
				local CrystalID = Params.MapMarker.NaviCrystalID
				if CrystalID and CrystalID > 0 then
					local Crystal = _G.PWorldMgr:GetCrystalPortalMgr():GetCrystalByEntityId(CrystalID)
					if Crystal and Crystal.DBConfig then
						SafeDistance = Crystal.DBConfig.Distance
					end
				end
				-- 如果目标是交互物
				local EObjID = Params.MapMarker.NaviEObjID
				if EObjID and EObjID > 0 then
					local EObjCfgItem = EObjCfg:FindCfgByKey(EObjID)
					if EObjCfgItem then
						SafeDistance = EObjCfgItem.InteractDistance
					end
				end
			end
		elseif MarkerType == MapMarkerType.ChocoboTransportWharf then
			local WharfNpcID = Params.MapMarker.WharfNpcID
			if WharfNpcID and WharfNpcID > 0 then
				SafeDistance = ChocoboTransportDefine.DEFAULT_FINISH_SAFE_DISTANCE
			end
		elseif MarkerType == MapMarkerType.ChocoboTransportTransferLine then
			local TransferLineID = Params.MapMarker.TransferLineID
			if TransferLineID and TransferLineID > 0 then
				SafeDistance = ChocoboTransportDefine.TRANSFER_LINE_SAFE_DISTANCE
			end
		elseif MarkerType == MapMarkerType.ChocoboStable then
			local NpcCfgItem = NpcCfg:FindCfgByKey(NpcID)
			if NpcCfgItem then
				SafeDistance = NpcCfgItem.InteractionRange
			end
		end
	end
	--_G.ChocoboTransportMgr:StartTransport(MapID, NpcID, self.WorldPosX, self.WorldPoxY, self.WorldPoxZ, SafeDistance)
	_G.ChocoboTransportMgr:StartTransport(MapID, 0, self.WorldPosX, self.WorldPoxY, self.WorldPoxZ, SafeDistance)
end

function WorldMapMarkerTipsChocoboTransportView:OnGameEventChocoboTransportBegin()
	self:Hide()
end

return WorldMapMarkerTipsChocoboTransportView