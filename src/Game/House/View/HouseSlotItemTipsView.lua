---
--- Author: skysong
--- DateTime: 2025-05-12 10:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseSlotItemTipsVM = require("Game/House/VM/HouseSlotItemTipsVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local HouseCommon = require("Game/House/HouseCommon")
local EventID = require("Define/EventID")
local UIDefine = require("Define/UIDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local BagMgr = require("Game/Bag/BagMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")
local HouseUtil = require("Game/House/HouseUtil")
local HouseMainPanelVM = require("Game/House/VM/HouseMainPanelVM")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")

local CommBtnColorType = UIDefine.CommBtnColorType
local LSTR = _G.LSTR
local UE = _G.UE
local UHousingMgr = _G.UE.UHousingMgr
local ZoneProtoDownGAME_InteriorFloor = _G.UE.ZoneProtoDownGAME_InteriorFloor
local UKismetInputLibrary = UE.UKismetInputLibrary
local ZoneProtoDownGAME_House = _G.UE.ZoneProtoDownGAME_House

---@class HouseSlotItemTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBtnBackBag CommBtnMView
---@field CommBtnMBackDopt CommBtnMView
---@field CommBtnMPlace CommBtnMView
---@field CommBtnReplace CommBtnMView
---@field ItemTipsFrameInterface ItemTipsFrameInterfaceView
---@field PanelBtn UFCanvasPanel
---@field PanelDetail UFCanvasPanel
---@field AnimMoreIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseSlotItemTipsView = LuaClass(UIView, true)

function HouseSlotItemTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBtnBackBag = nil
	--self.CommBtnMBackDopt = nil
	--self.CommBtnMPlace = nil
	--self.CommBtnReplace = nil
	--self.ItemTipsFrameInterface = nil
	--self.PanelBtn = nil
	--self.PanelDetail = nil
	--self.AnimMoreIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseSlotItemTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBtnBackBag)
	self:AddSubView(self.CommBtnMBackDopt)
	self:AddSubView(self.CommBtnMPlace)
	self:AddSubView(self.CommBtnReplace)
	self:AddSubView(self.ItemTipsFrameInterface)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseSlotItemTipsView:OnInit()
	self.ViewModel = HouseSlotItemTipsVM.New()
	self.Binders = {
		{"BtnPlaceVisible", UIBinderSetIsVisible.New(self, self.CommBtnMPlace, false, true) },
		{"BtnReplaceVisible", UIBinderSetIsVisible.New(self, self.CommBtnReplace, false, true) },
		{"BtnBackBagVisible", UIBinderSetIsVisible.New(self, self.CommBtnBackBag,false,true) },
		{"BtnMBackDepotVisible",UIBinderSetIsVisible.New(self,self.CommBtnMBackDopt,false,true)},

		{ "BtnReplaceEnable" , UIBinderSetIsEnabled.New(self, self.CommBtnReplace, false, true)}
	}
	self.CanBackDepot = true
	self.CanBackBag = true
end

function HouseSlotItemTipsView:OnDestroy()

end

function HouseSlotItemTipsView:OnShow()

end

function HouseSlotItemTipsView:OnHide()

end

function HouseSlotItemTipsView:UpdateView(Params)
	self.Params = Params

	if self.Params.ItemData ~= nil then

		if self.Params.Side == 1 then
			self.ViewModel:UpdateVM(self.Params.ItemData,true)
		else
			self.ViewModel:UpdateVM(self.Params.ItemData,false)
		end

		self.ItemTipsFrameInterface:UpdateUI(self.Params.ItemData)

		self.CanBackBag = true
		self.CanBackDepot = true

		--放回背包的按扭处理
		if _G.BagMgr:GetBagLeftNum() < 1 then
			self.CanBackBag = false
			self.CommBtnBackBag:SetIsEnabled(false,true)
		else
			if self.Params.IsPreviewItem then
				local Cfg = ItemCfg:FindCfgByKey(self.Params.ItemData.ResID)

				if Cfg ~= nil then
					--可选配件可以放回背包
					if Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.HOUSING_ROOFDECORATION or Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.HOUSING_EXTERNALWALLDECORATION or
							Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.HOUSING_DOORPLATE or Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.HOUSING_COURTYARDWALLS then
						self.CommBtnBackBag:SetColorType(CommBtnColorType.Normal)
					else
						self.CanBackBag = false
						self.CommBtnBackBag:SetIsEnabled(false,true)
					end
				end
			else
				self.CommBtnBackBag:SetIsEnabled(true,true)
			end
		end

		--放回仓库的按扭处理
		if self:IsDepotFull() then
			self.CanBackDepot = false
			self.CommBtnBackBag:SetIsEnabled(false,true)
		else
			if self.Params.IsPreviewItem then
				local Cfg = ItemCfg:FindCfgByKey(self.Params.ItemData.ResID)

				if Cfg ~= nil then
					--可选配件可以放回仓库
					if Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.HOUSING_ROOFDECORATION or Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.HOUSING_EXTERNALWALLDECORATION or
							Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.HOUSING_DOORPLATE or Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.HOUSING_COURTYARDWALLS then
						self.CommBtnMBackDopt:SetIsEnabled(true,true)
					else
						self.CanBackDepot = false
						self.CommBtnMBackDopt:SetIsEnabled(false,true)
					end
				end
			else
				self.CommBtnMBackDopt:SetColorType(CommBtnColorType.Normal)
			end
		end
	end
end

function HouseSlotItemTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtnBackBag.Button,self.OnClickBackBag)
	UIUtil.AddOnClickedEvent(self, self.CommBtnMBackDopt.Button,self.OnClickBackDepot)
	UIUtil.AddOnClickedEvent(self, self.CommBtnMPlace.Button,self.OnClickPlace)
	UIUtil.AddOnClickedEvent(self, self.CommBtnReplace.Button,self.OnClickReplace)
end

function HouseSlotItemTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function HouseSlotItemTipsView:OnRegisterBinder()
	self.CommBtnBackBag:SetButtonText(LSTR(1640032))
	self.CommBtnMBackDopt:SetButtonText(LSTR(1640033))
	self.CommBtnMPlace:SetButtonText(LSTR(1640038))
	self.CommBtnReplace:SetButtonText(LSTR(1640039))

	self:RegisterBinders(self.ViewModel, self.Binders)
end

--放回背包
function HouseSlotItemTipsView:OnClickBackBag()
	local BagCapacity = BagMgr:GetBagLeftNum()

	if BagCapacity >= 1 then
		--必选配件不能回到仓库
		if not self.CanBackBag then
			MsgTipsUtil.ShowTips(LSTR(1640055))
		else
			local ItemUse = false

			--已放置这里是收回家具
			if HouseMainPanelVM:GetTabSelectIndex() == HouseCommon.SelectHouseLeftBarType.Placed then
				_G.HousingMgr:SendBackFurnitureReq(self.Params.ItemData.GID,ProtoCS.HouseUseBagType.HouseUseBagType_RoleBag)
			else
				--是装修下面的SLOT触发
				if self.Params.IsPreviewItem then
					--ItemUse = HouseMainPanelVM:IsItemIsReplaced(self.Params.ItemData,HouseCommon.SelectHouseLeftBarType.DecorateSlot)
					--
					--if not ItemUse then
						local FloorData = {{Floor = _G.HousingMgr.SelectFloor,Pos = self:ItemTypeToPos(self.Params.ItemData),
											BagType = ProtoCS.HouseUseBagType.HouseUseBagType_RoleBag}}
						_G.HousingMgr:SendDecorateReq(FloorData)
					--else
					--	MsgTipsUtil.ShowTips(LSTR(1640067))
					--end
				else
					--从仓库到背包
					if HouseMainPanelVM.TabSelectIndex == HouseCommon.SelectHouseLeftBarType.StoreHouse then
						ItemUse = HouseMainPanelVM:IsItemIsReplaced(self.Params.ItemData,HouseCommon.SelectHouseLeftBarType.StoreHouse)

						if not ItemUse then
							_G.HousingMgr:SendItemMoveReq(ProtoCS.HouseUseBagType.HouseUseBagType_HouseDepot,self.Params.ItemData.GID,self.Params.ItemData.ResID)
						else
							MsgTipsUtil.ShowTips(LSTR(1640067))
						end
					end
				end
			end
		end
	else
		MsgTipsUtil.ShowTips(LSTR(1640050))
	end

	UIUtil.SetIsVisible(self,false,false)
end

function HouseSlotItemTipsView:IsDepotFull()
	local Depot = _G.HousingMgr:GetCurrentDepot()
	if Depot ~= nil then
		local IsDepotFull = false
		if Depot.ItemList ~= nil then
			if Depot.Capacity - #Depot.ItemList < 1 then
				IsDepotFull = true
			end
		end

		return IsDepotFull
	end
end

function HouseSlotItemTipsView:ItemTypeToPos(Item)
	local Cfg = ItemCfg:FindCfgByKey(Item.ResID)

	if Cfg ~= nil then
		if Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.HOUSING_ROOFDECORATION then
			return ProtoRes.HouseDoUpPos.HouseDoUpPos_YardRoofDecoration
		elseif Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.HOUSING_EXTERNALWALLDECORATION then
			return ProtoRes.HouseDoUpPos.HouseDoUpPos_YardWallDecoration
		elseif Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.HOUSING_DOORPLATE then
			return ProtoRes.HouseDoUpPos.HouseDoUpPos_YardDoorplateDecoration
		elseif Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.HOUSING_COURTYARDWALLS then
			return ProtoRes.HouseDoUpPos.HouseDoUpPos_YardFenceDecoration
		end
	end

	return ProtoCS.House.HouseDecorate.HouseDoUpPos.HouseDoUpPos_Start
end

--放回仓库
function HouseSlotItemTipsView:OnClickBackDepot()
	if not self:IsDepotFull() then
		--必选配件不能回到仓库
		if not self.CanBackDepot then
			MsgTipsUtil.ShowTips(LSTR(1640066))
		else
			--已放置这里是收回家具
			if HouseMainPanelVM:GetTabSelectIndex() == HouseCommon.SelectHouseLeftBarType.Placed then
				_G.HousingMgr:SendBackFurnitureReq(self.Params.ItemData.GID,ProtoCS.HouseUseBagType.HouseUseBagType_HouseDepot)
			else
				local ItemUse = false
				--是装修下面的SLOT触发
				if self.Params.IsPreviewItem then
					--ItemUse = HouseMainPanelVM:IsItemIsReplaced(self.Params.ItemData,HouseCommon.SelectHouseLeftBarType.DecorateSlot)
					--
					--if not ItemUse then
						local FloorData = {{Floor = _G.HousingMgr.SelectFloor,Pos = self:ItemTypeToPos(self.Params.ItemData),
											BagType = ProtoCS.HouseUseBagType.HouseUseBagType_HouseDepot}}
						_G.HousingMgr:SendDecorateReq(FloorData)
					--else
					--	MsgTipsUtil.ShowTips(LSTR(1640067))
					--end
				else
					--从背包往仓库移
					if HouseMainPanelVM.TabSelectIndex == HouseCommon.SelectHouseLeftBarType.Bag then
						ItemUse = HouseMainPanelVM:IsItemIsReplaced(self.Params.ItemData,HouseCommon.SelectHouseLeftBarType.Bag)

						if not ItemUse then
							_G.HousingMgr:SendItemMoveReq(ProtoCS.HouseUseBagType.HouseUseBagType_RoleBag,self.Params.ItemData.GID,self.Params.ItemData.ResID)
						else
							MsgTipsUtil.ShowTips(LSTR(1640067))
						end
					end
				end
			end
		end
	else
		MsgTipsUtil.ShowTips(LSTR(1640053))
	end

	UIUtil.SetIsVisible(self,false,false)
end

--放置
function HouseSlotItemTipsView:OnClickPlace()
	local HouseRegionCfg = _G.HousingMgr:GetHouseRegionCfg()
	local FurnitureList = _G.HousingMgr:GetFurnitureList(_G.HousingMgr.HouseID,_G.HousingMgr.Region)

	if FurnitureList ~= nil then
		if HouseRegionCfg ~= nil then
			--满了不能再放了
			if #FurnitureList.Entities == HouseRegionCfg.FurnitureLimit then
				MsgTipsUtil.ShowTips(LSTR(1640074))
			else
				local Cfg = HouseUtil.GetHousePartsCfg(self.Params.ItemData.ResID)
				if Cfg ~= nil then
					local HousingMgrInstance = UHousingMgr:Get()
					if HousingMgrInstance ~= nil then
						_G.HousingMgr.TemporaryHosingObjectGID = self.Params.ItemData.GID
						_G.HousingMgr.TemporaryHosingObjectResID = self.Params.ItemData.ResID
						HousingMgrInstance:SetMouseEnterReleased()
						HousingMgrInstance:JustPlace(self.Params.ItemData.GID, Cfg.ID, Cfg.Category, 5)
					end
				end
			end
		end
	end

	UIUtil.SetIsVisible(self,false,false)
end

--替换
function HouseSlotItemTipsView:OnClickReplace()
	local Cfg = HouseUtil.GetHousePartsCfg(self.Params.ItemData.ResID)
	HouseMainPanelVM:CheckPreviewModelAndFillData()

	if Cfg ~= nil then

		if _G.HousingMgr:IsInDoor() then
			--根据SelectFloor所选楼层
			--SelectInDoorPartsCategory选择的内装类型
			--self.Params.ItemData 当前选的ITEM(取真正的配件ID)

			local FloorData = ZoneProtoDownGAME_InteriorFloor()
			--LUA端与PC端枚举差1
			FloorData.Floor = _G.HousingMgr.SelectFloor -1
			FloorData.Category = _G.HousingMgr.SelectInDoorPartsCategory
			FloorData.InteriorId = Cfg.Key
			FloorData.ColorId = 0

			HouseMainPanelVM:ReplacePreviewItem(self.Params.ItemData)

			local HousingMgrInstance = UHousingMgr:Get()
			if HousingMgrInstance ~= nil then
				HousingMgrInstance:OnReceiveInteriorFloor(FloorData)
				--_G.HousingMgr:AddOptType({From = {GID = self.Params.ItemData.GID,ResID = self.Params.ItemData.ResID}})
				_G.EventMgr:SendEvent(EventID.RefreshDecoratePanelViewOKBtn)
			end
		else
			--SelectHousePartsCategory选择的外装类型
			--self.Params.ItemData 当前选的ITEM(取真正的配件ID)
			--BlockID也需要
			local ExteriorCfg = HouseUtil.GetHousePartsCfg(self.Params.ItemData.ResID)
			local HouseID = _G.HousingMgr.HouseID
			local HouseSize = _G.HousingMgr:GetHouseSize(HouseID)
			local HouseInfo = _G.HousingMgr:GetHouseInfo(HouseID,ProtoRes.HouseRegionType.HouseRegionType_Yard)

			if self:CanExteriorReplace(ExteriorCfg,HouseSize) then
				HouseMainPanelVM:ReplacePreviewItem(self.Params.ItemData)

				local HouseData = ZoneProtoDownGAME_House()
                HouseData.Block = HouseInfo.Addr.Number
                HouseData.Size = HouseSize
				HouseData.ExteriorIds = _G.UE.TArray(_G.UE.int32)
				HouseData.Colors = _G.UE.TArray(_G.UE.int32)

				local ExteriorIds = {}

				for i=1,8 do
					table.insert(ExteriorIds,0)
					HouseData.Colors:Add(0)
				end

				local SlotItemResIDs = {0,0,0,0,0,0,0,0}
				local Index = 1
				for k,v in pairs(HouseMainPanelVM.PreviewModelData.ExteriorData) do
					SlotItemResIDs[Index] = v.ResID
					Index = Index + 1
					
					--[yuhang] 注意：这里的 Index 和 Pos 很混乱
					if v.GID > 0 then
						local HousePartsCfg = HouseUtil.GetHousePartsCfg(v.ResID)
						if HousePartsCfg then
							local Pos = HouseUtil.GetOutDoorPosByIndex(k)
							local SlotItemPos =  HouseUtil.GetHouseDoUpPosToIndex(Pos)
							ExteriorIds[SlotItemPos] = HousePartsCfg.Key
						end
					end
				end

				--[yuhang]
				--for _,Floor in pairs(HouseInfo.DoUp.Floors) do
				--	for _,Entity in pairs(Floor.Entities) do
				--		if Entity.GID > 0 then
				--			local Pos = HouseUtil.GetOutDoorPosToIndex(Entity.Pos)
				--			local SlotItemPos =  HouseUtil.GetHouseDoUpPosToIndex(Entity.Pos)
				--
				--			local Cfg = HouseUtil.GetHousePartsCfg(SlotItemResIDs[SlotItemPos])
				--
				--			if Cfg ~= nil then
				--				ExteriorIds[Pos] = Cfg.Key
				--			end
				--		end
				--	end
				--end

				for k,v in ipairs(ExteriorIds) do
					HouseData.ExteriorIds:Add(v)
				end

				local HousingMgrInstance = UHousingMgr:Get()
				if HousingMgrInstance ~= nil then
					HousingMgrInstance:OnUpdateHouse(HouseData)
					_G.EventMgr:SendEvent(EventID.RefreshDecoratePanelViewOKBtn)
				end
			else
				MsgTipsUtil.ShowTips(LSTR(1640143))
			end
		end
	end

	UIUtil.SetIsVisible(self,false,false)
end

--点周空白处关闭
function HouseSlotItemTipsView:OnPreprocessedMouseButtonDown(MouseEvent)
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelDetail, MousePosition) == false then
		_G.EventMgr:SendEvent(EventID.HideHouseItemTips)
	end
end

--外装要判断房屋的SIZE与配件是否匹配
function HouseSlotItemTipsView:CanExteriorReplace(Cfg,Size)
	if Cfg ~= nil then
		return Cfg.Size == Size or Cfg.Size == ProtoRes.HOUSING_SIZE_TYPE.HOUSING_SIZE_ALL
	end

	return false
end

return HouseSlotItemTipsView