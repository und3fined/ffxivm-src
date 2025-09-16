---
--- Author: xingcaicao
--- DateTime: 2023-04-24 10:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ItemCfg = require("TableCfg/ItemCfg")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local PersonInfoMgr = require("Game/PersonInfo/PersonInfoMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local EquipmentTipsUtil = require("Game/Equipment/EquipmentTipsUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TogStat = _G.UE.EToggleButtonState
local LSTR = _G.LSTR
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ProfUtil = require("Game/Profession/ProfUtil")

local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class PersonInfoEquiPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EquipSlotBox UFWrapBox
---@field EquipSlotItem1 EquipmentSlotItemView
---@field EquipSlotItem10 EquipmentSlotItemView
---@field EquipSlotItem11 EquipmentSlotItemView
---@field EquipSlotItem12 EquipmentSlotItemView
---@field EquipSlotItem2 EquipmentSlotItemView
---@field EquipSlotItem3 EquipmentSlotItemView
---@field EquipSlotItem4 EquipmentSlotItemView
---@field EquipSlotItem5 EquipmentSlotItemView
---@field EquipSlotItem6 EquipmentSlotItemView
---@field EquipSlotItem7 EquipmentSlotItemView
---@field EquipSlotItem8 EquipmentSlotItemView
---@field EquipSlotItem9 EquipmentSlotItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoEquiPanelView = LuaClass(UIView, true)

function PersonInfoEquiPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EquipSlotBox = nil
	--self.EquipSlotItem1 = nil
	--self.EquipSlotItem10 = nil
	--self.EquipSlotItem11 = nil
	--self.EquipSlotItem12 = nil
	--self.EquipSlotItem2 = nil
	--self.EquipSlotItem3 = nil
	--self.EquipSlotItem4 = nil
	--self.EquipSlotItem5 = nil
	--self.EquipSlotItem6 = nil
	--self.EquipSlotItem7 = nil
	--self.EquipSlotItem8 = nil
	--self.EquipSlotItem9 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoEquiPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EquipSlotItem1)
	self:AddSubView(self.EquipSlotItem10)
	self:AddSubView(self.EquipSlotItem11)
	self:AddSubView(self.EquipSlotItem12)
	self:AddSubView(self.EquipSlotItem2)
	self:AddSubView(self.EquipSlotItem3)
	self:AddSubView(self.EquipSlotItem4)
	self:AddSubView(self.EquipSlotItem5)
	self:AddSubView(self.EquipSlotItem6)
	self:AddSubView(self.EquipSlotItem7)
	self:AddSubView(self.EquipSlotItem8)
	self:AddSubView(self.EquipSlotItem9)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoEquiPanelView:OnInit()
	self.Binders = {
		{ "IsShowFacade", UIBinderValueChangedCallback.New(self, nil, self.OnShowFacadeChanged) },
		{ "OnEquipList", UIBinderValueChangedCallback.New(self, nil, self.OnOnEquipListChanged) },
		{ "EquipScore", UIBinderSetText.New(self, self.Text_EquipScore) },
		{ "bIsHoldWeapon", 	UIBinderSetIsChecked.New(self, self.BtnPose) },
		{ "bIsShowHead", 	UIBinderSetIsChecked.New(self, self.BtnHat) },
		{ "IsMajor", 	UIBinderSetIsVisible.New(self, self.BtnPose, nil, true) },
		{ "IsMajor", 	UIBinderSetIsVisible.New(self, self.BtnHat, nil, true) },
	}
end

function PersonInfoEquiPanelView:OnDestroy()

end

local function FillMajorEquip(T, Part, EquipID, ResID, Color)
	if not T[Part] then
		T[Part] = {}
		T[Part].Part = Part
	end

	if EquipID then
		T[Part].EquipID = EquipID
	end

	if ResID then
		T[Part].ResID = ResID
	end

	if Color then
		T[Part].Color = Color
	end
end

function PersonInfoEquiPanelView:OnShow()
	self.ItemList = {}
	if PersonInfoVM.RoleID == MajorUtil.GetMajorRoleID() then
		local Res = {}

		local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
		local SourceEquip = RoleDetail.Equip.EquipList
		for k, v in pairs(SourceEquip or {}) do
			FillMajorEquip(Res, k, v.ResID)
		end

		local AppList = _G.WardrobeMgr:GetCurAppearanceList()

		for k, v in pairs(AppList or {}) do
			FillMajorEquip(Res, k, nil, v.Avatar, v.Color)
		end

		PersonInfoVM.OnEquipList = Res
	else
		_G.RoleInfoMgr:QueryRoleSimple(PersonInfoVM.RoleID, function(_, RoleVM)
		end, nil, false)
	end

	UIUtil.SetIsVisible(self.TextName, false)
	self:CancelSeltItem()

	local Prof = PersonInfoVM.RoleVM.Prof
	if Prof then
		local IsSpe = ProfUtil.IsProductionProf(Prof)
		UIUtil.SetIsVisible(self.BtnPose, not IsSpe, true)
	end

end

function PersonInfoEquiPanelView:OnHide()
	self.ItemList = {}
end

function PersonInfoEquiPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, 		self.BtnPose, 				self.OnBtnPoseClick)
	UIUtil.AddOnStateChangedEvent(self, 		self.BtnHat, 				self.OnBtnHatClick)

	UIUtil.AddOnStateChangedEvent(self, self.BtnSwitch, self.OnStateChangedToggleSwitch)
end

function PersonInfoEquiPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.EquipDetailViewClose, self.OnEveEquipDetailClose)
end

function PersonInfoEquiPanelView:OnEveEquipDetailClose()
	self:CancelSeltItem()
end

function PersonInfoEquiPanelView:CancelSeltItem()
	self:OnSeltItem(nil)
end

function PersonInfoEquiPanelView:OnSeltItem(Item)
	local NameText = self.TextName

	if Item and Item == self.SeltItem then
		self.SeltItem.bSelect = false
		self.SeltItem = nil
		UIUtil.SetIsVisible(NameText, false)
		return
	end

	if self.SeltItem then
		self.SeltItem.bSelect = false
		self.SeltItem = nil
	end

	if not Item then
		UIUtil.SetIsVisible(NameText, false)
		return
	end

	Item.bSelect = true
	local ItemName = PersonInfoVM.IsShowFacade and WardrobeUtil.GetEquipmentAppearanceName(Item.ResID) or ItemCfg:GetItemName(Item.ResID)

	NameText:SetText(ItemName)
	UIUtil.SetIsVisible(NameText, true)
	self.SeltItem = Item
end

function PersonInfoEquiPanelView:OnRegisterBinder()
	self:RegisterBinders(PersonInfoVM, self.Binders)
end

-------------------------------------------------------------------------------------------------------
---@region expand weapon/hat, copy from EquipmentNewMainView

-- weapon
function PersonInfoEquiPanelView:OnBtnPoseClick(ToggleButton, ButtonState)
	local IsShow = ButtonState == _G.UE.EToggleButtonState.Checked
	PersonInfoVM.bIsHoldWeapon = IsShow
	self:ShowPoseStyleTips(IsShow)
end

function PersonInfoEquiPanelView:ShowPoseStyleTips(IsShow)
	local Contnet = (LSTR(1050028))
	--_G.MsgTipsUtil.ShowTips(Contnet)
end

-- hat
function PersonInfoEquiPanelView:OnBtnHatClick(ToggleButton, ButtonState)
	local IsShow = ButtonState == _G.UE.EToggleButtonState.Checked 
	PersonInfoVM.bIsShowHead = IsShow
	self:ShowHatTips(IsShow)
end

function PersonInfoEquiPanelView:ShowHatTips(bHideHead)
	local OpenContent = (LSTR(1050060))
	local CloseContnet = (LSTR(1050023))
	local Text = bHideHead and CloseContnet or OpenContent
	--_G.MsgTipsUtil.ShowTips(Text)
end

--[[

message GemCarryInfo {
        map<int32, Gem> Gems = 1;
}

message Gem {
        uint64 GID = 1;
        int32 ResID = 2;
        uint32 CreateTime = 3;
        bool IsBind = 4;
}

]]

function PersonInfoEquiPanelView:UpdateSlotByItem(Part, ResID, GID)
	local Slot = self["EquipSlotItem" .. Part]
	if nil == Slot then
		return
	end

	local ViewModel = Slot.ViewModel
	if nil == ViewModel then
		return
	end

	ViewModel:SetPart(Part, ResID, GID, PersonInfoVM.IsShowFacade)
	ViewModel.bShowProgress = false
	ViewModel.OnClick = function (VM)
		if not ResID or ResID == -1 then
			return
		end

		if VM and VM.Part then
			local Item = table.find_item(self.ItemList, Part, 'Part') or {} --self.ItemList[VM.Part]
			if Item then

				self:OnSeltItem(VM)

				if PersonInfoVM.IsShowFacade then
					return
				end

				if nil == self.TipsOffset then
					self.TipsOffset = _G.UE.FVector2D(20, -18)
				end
				
				local TipsItem = table.clone(Item)
				TipsItem.ResID = Item.EquipID

				--- show gems
				if PersonInfoVM.GemMap then
					local GemInfo = PersonInfoVM.GemMap[Part]
					local GemMap = {}
					if GemInfo then
						for K, V in pairs(GemInfo.Gems) do
							GemMap[K] = V.ResID
						end
					end

					TipsItem.Attr = {
						Equip = {
							GemInfo = {
								CarryList = GemMap
							}
						}
					}
				end

				

				EquipmentTipsUtil.ShowTipsByItem(TipsItem, self.EquipSlotBox, self.TipsOffset)
			end
		end
	end
end

function PersonInfoEquiPanelView:OnStateChangedToggleSwitch(_, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	PersonInfoVM.IsShowFacade = IsChecked
end

function PersonInfoEquiPanelView:OnShowFacadeChanged(Value)
	local Stat = (Value == true) and TogStat.Checked or TogStat.Unchecked
	local Title = (Value == true) and LSTR(620115) or LSTR(620116)
	local Tips = (Value == true) and LSTR(620117) or LSTR(620118) 

	self.TextTitle:SetText(Title)
	self.BtnSwitch:SetCheckedState(Stat)
	self:UpdateEuipList()
	-- MsgTipsUtil.ShowTips(Tips)
end

function PersonInfoEquiPanelView:OnOnEquipListChanged(Value)
	self:UpdateEuipList()
	self:CalculateEquipScore()
end

function PersonInfoEquiPanelView:UpdateEuipList()
	self:CancelSeltItem()

	local EquipItemList = {}
	local Data = PersonInfoVM.OnEquipList
	-- print('testinfo data = ' .. table.tostring_block(Data))
	local IsShowFacade = PersonInfoVM.IsShowFacade
	if Data and not table.empty(Data) then
		for ItemKey, Item in pairs(Data) do
			-- EquipItemList[ItemKey] = Item
			table.insert(EquipItemList, Item)
		end
	end

	self.ItemList = EquipItemList 
	for _, v in pairs(ProtoCommon.equip_part) do
		local Item = table.find_item(EquipItemList, v, 'Part') or {}
		local ResID = Item.EquipID
		if IsShowFacade then
			local AppData = Item
			if AppData and next(AppData) and AppData.ResID and AppData.ResID ~= 0 then
				ResID =  AppData.ResID
			else
				ResID = 0
			end
			-- print('testinfo facade id = ' .. tostring(Item.ResID))
			-- print('testinfo facade equip id = ' .. tostring(ResID))
		end

		if (not ResID) or ResID == 0 then
			ResID = -1
		end

		self:UpdateSlotByItem(v, ResID, Item.GID)
	end
end

---计算已穿戴装备的装备评分
function PersonInfoEquiPanelView:CalculateEquipScore()
	local ItemList = PersonInfoVM.OnEquipList
	local Score = 0
	if nil == ItemList then
		PersonInfoVM.EquipScore = Score
		return
	end
	for _, Item in pairs(ItemList) do
		local ItemCfg = ItemCfg:FindCfgByKey(Item.EquipID)
		if (ItemCfg) then
			Score = Score + ItemCfg.ItemLevel
		end
	end
	Score = math.ceil(Score / self:GetPartCount())
	PersonInfoVM.EquipScore = Score
end

function PersonInfoEquiPanelView:GetPartCount()
	local RoleVM = PersonInfoVM.RoleVM
	local Prof = RoleVM and RoleVM.Prof or nil
	local SubWeapon = RoleInitCfg:FindSubWeaponItemType(Prof)
	if SubWeapon == 0 then
		return 11
	end
	return 12
end
return PersonInfoEquiPanelView