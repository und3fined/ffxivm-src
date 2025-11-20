---
--- Author: skysong
--- DateTime: 2025-05-06 15:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local HouseDecoratePanelVM = require("Game/House/VM/HouseDecoratePanelVM")
local HouseCommon = require("Game/House/HouseCommon")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local UIDefine = require("Define/UIDefine")
local HouseMainPanelVM = require("Game/House/VM/HouseMainPanelVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")
local ProtoRes = require("Protocol/ProtoRes")
local HouseUtil = require("Game/House/HouseUtil")
local CommBtnColorType = UIDefine.CommBtnColorType

local LSTR = _G.LSTR
local UE = _G.UE
local UHousingMgr = _G.UE.UHousingMgr
local ZoneProtoDownGAME_Interior = _G.UE.ZoneProtoDownGAME_Interior
local YellowHex = "FFF4D0FF"

---@class HouseDecoratePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnOK UFButton
---@field BtnX UFButton
---@field CommTabs CommTabsView
---@field FourTabSpace USpacer
---@field IconOK UFImage
---@field IconOKDisab UFImage
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseDecoratePanelView = LuaClass(UIView, true)

function HouseDecoratePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnOK = nil
	--self.BtnX = nil
	--self.CommTabs = nil
	--self.FourTabSpace = nil
	--self.IconOK = nil
	--self.IconOKDisab = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseDecoratePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseDecoratePanelView:OnInit()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.TableViewAdapter:SetOnClickedCallback(self.OnItemClicked)
	self.Binders = {
		{"CurrentItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
	}
	self.ViewModel = HouseDecoratePanelVM.New()
	self.Parent = nil
end

function HouseDecoratePanelView:OnDestroy()
	self.ViewModel = nil
	self.Parent = nil
end

function HouseDecoratePanelView:OnShow()
	self:CreateTabs()
	local Index = HouseUtil.GetDecorateTabsIndexByMajorPosZ(_G.HousingMgr.HouseID)
	self.CommTabs:SetSelectedIndex(Index)
	self:UpdateOKBtnImage(CommBtnColorType.Disable)
end

function HouseDecoratePanelView:OnHide()

end

function HouseDecoratePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnOK, self.OnOK)
	UIUtil.AddOnClickedEvent(self, self.BtnX, self.OnCancel)
end

function HouseDecoratePanelView:OnRegisterGameEvent()
	self.CommTabs:SetCallBack(self, self.OnCommTabIndexChanged)
	self:RegisterGameEvent(EventID.RefreshDecoratePanelViewOKBtn,self.RefreshDecoratePanelViewOKBtn)
	self:RegisterGameEvent(EventID.UpdateDecorateSlotItem,self.UpdateDecorateSlotItem)
	self:RegisterGameEvent(EventID.SaveDecorateSucc,self.OnSaveDecorateSucc)
end

function HouseDecoratePanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function HouseDecoratePanelView:UpdateOKBtnImage(ColorType)
	if CommBtnColorType.Normal == ColorType then
		UIUtil.SetIsVisible(self.IconOK,true,false)
		UIUtil.SetIsVisible(self.IconOKDisab,false,false)
	elseif CommBtnColorType.Disable == ColorType then
		UIUtil.SetIsVisible(self.IconOK,false,false)
		UIUtil.SetIsVisible(self.IconOKDisab,true,false)
	end
end

--- 已装道具点击
function HouseDecoratePanelView:OnItemClicked(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end

	_G.EventMgr:SendEvent(EventID.HideHouseItemTips)
	_G.EventMgr:SendEvent(EventID.HouseMainPanelTabMenuChange, {ParentKey = HouseMainPanelVM.TabSelectIndex, ChildIndex = Index})

	if self.ViewModel.SelIndex ~= nil then
		local LastItem = self.ViewModel:GetItem(self.ViewModel.SelIndex)

		if LastItem ~= nil then
			LastItem.IsSelect = false
		end
	end

	local CurItem = self.ViewModel:GetItem(Index)

	if CurItem ~= nil then
		--空道具不显示ItemTips
		if CurItem.GID == 6 or CurItem.GID == 7 or CurItem.GID == 5 or CurItem.GID == 8 then
			return
		else
			self.ViewModel:SetCurItemIndex(Index)
			local Params = {ItemData = CurItem, SlotView = ItemView, HideCallback = nil, Side = 2,Index = Index,RightBarExpend = nil,IsPreviewItem = true}
			CurItem.IsSelect = true
			_G.EventMgr:SendEvent(EventID.ShowHouseItemTips,Params)
			--UIViewMgr:ShowView(UIViewID.HouseItemTips, Params)
		end
	end
end

function HouseDecoratePanelView:OnOK()
	FLOG_INFO("Save Decorate")

	if HouseMainPanelVM:CheckInterOrExterDataChange() then
		local DecorateInfo = HouseMainPanelVM:GetDecorateInfo()

		local function Callback()
			_G.HousingMgr:SendDecorateReq(DecorateInfo.FloorData, DecorateInfo.ChangePosOps)
			HouseMainPanelVM:ResetPreviewModelData()
		end

		if DecorateInfo.HaveUnBindItem then
			--弹二次确认
			local EnlargeRichText = RichTextUtil.GetText(string.format("%s", LSTR(1640069)), YellowHex)
			local Params = {FontSize = 22,TextAlignment = CommonBoxDefine.BtnType.Left}
			local DecorateText = string.format(LSTR(1640070), EnlargeRichText)

			MsgBoxUtil.ShowMsgBoxMTwoOp(self,LSTR(1640068),DecorateText,Callback,nil,nil,nil,Params)
		else
			_G.HousingMgr:SendDecorateReq(DecorateInfo.FloorData, DecorateInfo.ChangePosOps)
			HouseMainPanelVM:ResetPreviewModelData()
		end
	else
		self:OnSaveDecorateSucc()
	end
end

--取消装潢
function HouseDecoratePanelView:OnCancel()
	local HousingMgr = _G.HousingMgr
	if #HousingMgr.OptRecord > 0 then
		HousingMgr:ClearOptRecords()
	end

	if HouseMainPanelVM:CheckInterOrExterDataChange() then
		--恢复之前的设置
		_G.EventMgr:SendEvent(EventID.RefreshDecorateEffect,{HouseID = HousingMgr.HouseID ,Region = HousingMgr.Region})
	end

	self.Parent:OnBack()
end

function HouseDecoratePanelView:UpdateDecorateSlotItem(Params)
	self.ViewModel:UpdateItem(Params.Item,Params.Index)
end

function HouseDecoratePanelView:OnSaveDecorateSucc(Params)
	--MsgTipsUtil.ShowTips(LSTR(1640060))
	self:UpdateOKBtnImage(CommBtnColorType.Disable)
	HouseMainPanelVM:ResetPreviewModelData()
	--更新当前装修槽
	self:RecoverCurrentDecorateItem(_G.HousingMgr.SelectFloor)
end

function HouseDecoratePanelView:RefreshDecoratePanelViewOKBtn(Params)
	--有记录说明需要保存
	--当前的配件SLOT是不是有变化
	if HouseMainPanelVM:CheckInterOrExterDataChange() then
		self:UpdateOKBtnImage(CommBtnColorType.Normal)
	else
		self:UpdateOKBtnImage(CommBtnColorType.Disable)
	end
end

--装潢类型点击
function HouseDecoratePanelView:OnCommTabIndexChanged(Index)
	local HousingMgr = _G.HousingMgr
	local HouseModel = HousingMgr:GetHouseModel()

	if HouseModel ~= HouseCommon.HouseModel.None then
		if HouseModel == HouseCommon.HouseModel.IndoorTerritoryModel then
			-- 楼层映射表
			local FloorMap = {
				[HouseCommon.HouseSize.HOUSE_SIZE_S] = {
					[1] = HouseCommon.FloorCategory.FLOOR_CATEGORY_1F,
					[2] = HouseCommon.FloorCategory.FLOOR_CATEGORY_B1
				},
				[HouseCommon.HouseSize.HOUSE_SIZE_M] = {
					[1] = HouseCommon.FloorCategory.FLOOR_CATEGORY_2F,
					[2] = HouseCommon.FloorCategory.FLOOR_CATEGORY_1F,
					[3] = HouseCommon.FloorCategory.FLOOR_CATEGORY_B1
				},
				[HouseCommon.HouseSize.HOUSE_SIZE_L] = {
					[1] = HouseCommon.FloorCategory.FLOOR_CATEGORY_2F,
					[2] = HouseCommon.FloorCategory.FLOOR_CATEGORY_1F,
					[3] = HouseCommon.FloorCategory.FLOOR_CATEGORY_B1,
					[4] = HouseCommon.FloorCategory.FLOOR_CATEGORY_COMMON
				}
			}

			local HouseSize = HousingMgr:GetHouseSize(HousingMgr.HouseID)
			local TargetFloor = FloorMap[HouseSize] and FloorMap[HouseSize][Index] or HouseCommon.FloorCategory.FLOOR_CATEGORY_1F
			self:RecoverCurrentDecorateItem(TargetFloor)
		elseif HouseModel == HouseCommon.HouseModel.HouseTerritoryModel then
			HousingMgr:SelectHouseTerritory(Index)
			HouseMainPanelVM:UpdateTabList()
			self:RecoverCurrentDecorateItem(HouseCommon.FloorCategory.FLOOR_CATEGORY_1F)
			self.Parent:UpdateView()
		end
	end
end

--恢复当前层级的装修用于退出预览或者打开界面时
function HouseDecoratePanelView:RecoverCurrentDecorateItem(Floor)
    local HousingMgr = _G.HousingMgr
    HousingMgr:SelectIndoorTerritoryFloor(Floor)
	local Items = {}
	local HouseModel = HousingMgr:GetHouseModel()

	if HouseModel == HouseCommon.HouseModel.IndoorTerritoryModel then
		--没有预览数据这里要取预览数据
		if #HouseMainPanelVM.PreviewModelData.InternalData == 0 then
			HouseMainPanelVM:FillPreviewModelInternalData()
		end

		local InternalItems = HouseMainPanelVM.PreviewModelData.InternalData

        if Floor == HouseCommon.FloorCategory.FLOOR_CATEGORY_COMMON then
            table.insert(Items, InternalItems[10]) -- 中央大灯
		elseif Floor == HouseCommon.FloorCategory.FLOOR_CATEGORY_1F then
			table.insert(Items,InternalItems[1])
			table.insert(Items,InternalItems[2])
			table.insert(Items,InternalItems[3])
		elseif Floor == HouseCommon.FloorCategory.FLOOR_CATEGORY_2F then
			table.insert(Items,InternalItems[4])
			table.insert(Items,InternalItems[5])
			table.insert(Items,InternalItems[6])
		else
			table.insert(Items,InternalItems[7])
			table.insert(Items,InternalItems[8])
			table.insert(Items,InternalItems[9])
		end
	elseif HouseModel == HouseCommon.HouseModel.HouseTerritoryModel then
		if #HouseMainPanelVM.PreviewModelData.ExteriorData == 0 then
			HouseMainPanelVM:FillPreviewModelExteriorData()
		end

		local ExteriorItems = HouseMainPanelVM.PreviewModelData.ExteriorData

		if HousingMgr.TerritoryOptType == HouseCommon.TerritoryOptType.Base then
			table.insert(Items,ExteriorItems[1])
			table.insert(Items,ExteriorItems[2])
			table.insert(Items,ExteriorItems[3])
			table.insert(Items,ExteriorItems[4])
		else
			table.insert(Items,ExteriorItems[5])
			table.insert(Items,ExteriorItems[6])
			table.insert(Items,ExteriorItems[7])
			table.insert(Items,ExteriorItems[8])
		end
	end

	self.ViewModel:UpdateItems(Items)
end

function HouseDecoratePanelView:CreateTabs()
    local HousingMgr = _G.HousingMgr
    local HouseModel = HousingMgr:GetHouseModel()
	local TabList = {}

	if HouseModel ~= HouseCommon.HouseModel.None then

		if HouseModel == HouseCommon.HouseModel.IndoorTerritoryModel then
			-- 部队个人房间
			if HousingMgr.HouseID == HousingMgr:GetArmyPersonalHouseID() then
				table.insert(TabList, {Name = LSTR(1640016)})
			else
				local HouseFloor = HousingMgr:GetHouseFloorMinMax(HousingMgr.HouseID,ProtoRes.HouseRegionType.HouseRegionType_Room)
				if HouseFloor ~= nil then
					local FloorMin = HouseFloor[1]
					local FloorMax = HouseFloor[2]

					if FloorMin == FloorMax then
						table.insert(TabList, {Name = LSTR(1640016)})
					elseif FloorMin == HouseCommon.ServerFloorCategory.FLOOR_CATEGORY_B1 and FloorMax == HouseCommon.ServerFloorCategory.FLOOR_CATEGORY_1F then
						table.insert(TabList, {Name = LSTR(1640016)})
						table.insert(TabList, {Name = LSTR(1640018)})
					else
						table.insert(TabList, {Name = LSTR(1640017)})
						table.insert(TabList, {Name = LSTR(1640016)})
						table.insert(TabList, {Name = LSTR(1640018)})
					end

					local bOptionTab = HousingMgr:CanEditCenterLight(HousingMgr.HouseID)
					UIUtil.SetIsVisible(self.FourTabSpace, bOptionTab)
					if bOptionTab then
						table.insert(TabList, { Name = LSTR(1640147) })
					end
				end
			end
		elseif HouseModel == HouseCommon.HouseModel.HouseTerritoryModel then
			table.insert(TabList, {Name = LSTR(1640024)})
			table.insert(TabList, {Name = LSTR(1640025)})
		end

		self.CommTabs:UpdateItems(TabList)
	end
end

return HouseDecoratePanelView