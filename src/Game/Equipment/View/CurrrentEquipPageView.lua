--[[
Author: luojiewen_ds luojiewen@dasheng.tv
Date: 2024-07-01 17:52:02
LastEditors: luojiewen_ds luojiewen@dasheng.tv
LastEditTime: 2024-07-11 15:09:22
FilePath: \Script\Game\Equipment\View\CurrrentEquipPageView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")

local ProtoCommon = require("Protocol/ProtoCommon")
local TipsUtil = require("Utils/TipsUtil")
local QuestHelper = require("Game/Quest/QuestHelper")

--VM
local EquipmentMainVM = require("Game/Equipment/VM/EquipmentMainVM")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")

--Binder
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")

local CurrrentEquipPageView = LuaClass(UIView, true)

local CommBtnColorType = {
	Normal = 0, -- 普通 灰色
	Recommend = 1, -- 推荐 绿色
	Disable = 2, -- 禁用状态
}

local COLOR_ENABLE = "fffcf1ff"
local COLOR_DISABLE = "828282ff"
 
function CurrrentEquipPageView:Ctor()
end

function CurrrentEquipPageView:OnRegisterSubView()
	self:AddSubView(self.BtnBestEquipment)
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
	self:AddSubView(self.EquipmentDetail)
	self:AddSubView(self.EquipmentListPage)
	self:AddSubView(self.RedDot)
	self:AddSubView(self.SoulRedPoint)
end

function CurrrentEquipPageView:OnInit()
	self.ViewModel = EquipmentMainVM--.New()
	self.EquipmentListPage.SuperView = self
	self.EquipmentListPage.OnEquipmentListSelect = self.OnEquipmentListSelect
end

function CurrrentEquipPageView:OnShow()
	self:PlayAnimation(self.AnimCurrrentEquipListIn)
	for _, v in pairs(ProtoCommon.equip_part) do
		self:UpdateSlotByItem(v, nil, nil, true)
	end

	--更新装备
	local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
	if not RoleDetail then
		FLOG_ERROR("GetMajorRoleDetail Is Nil")
	end
	if RoleDetail and RoleDetail.Equip then
		_G.EquipmentMgr:OnEquipInfo(RoleDetail.Equip)
	end
	for Part = ProtoCommon.equip_part.EQUIP_PART_NONE + 1, ProtoCommon.equip_part.EQUIP_PART_MAX - 1 do
		_G.EquipmentMgr:UpdateStrongestEquip(Part, nil)
	end
	if nil ~= EquipmentVM.ItemList then
		for Part, Item in pairs(EquipmentVM.ItemList) do
			_G.EquipmentMgr:UpdateStrongestEquip(Part, Item, true, true)
		end
		self:UpdateWhenEquipedChange()
	end
	_G.EquipmentMgr:CheckTipsForEndureDeg()
	self.RedDot:SetRedDotIDByID(7002)
	self.RedDot:SetStyle(1)
	self.SoulRedPoint:SetRedDotIDByID(7010)
	self.SoulRedPoint:SetStyle(1)
	self:UpdateRedDot()
	self.BtnBestEquipment.TextContent:SetText(LSTR(1050157))

	if not self.ViewModel.bEnableHelmetBtn then
		self.Btn_HatStyle:SetCheckedState(_G.UE.EToggleButtonState.Locked,false)
	end

end

function CurrrentEquipPageView:OnHide()
	--关闭界面重置一次动画
	self:StopAllAnimations()
	self:PlayAnimation(self.AnimListPanelIn, 0, 1, 0, 1.0, false)
end

function CurrrentEquipPageView:OnRegisterBinder()
    local Binders = {
		{ "bIsHoldWeapon", UIBinderSetIsChecked.New(self, self.Btn_Pose) },
		{ "bIsShowHead", UIBinderSetIsChecked.New(self, self.Btn_Hat) },
		{ "bIsShowWeapon", UIBinderSetIsChecked.New(self, self.Btn_Hand) },
		{ "bIsHelmetGimmickOn", UIBinderSetIsChecked.New(self, self.Btn_HatStyle) },
		{ "bStrongest", UIBinderValueChangedCallback.New(self, nil, self.OnStrongestChange)},
		{ "EquipScore", UIBinderValueChangedCallback.New(self, nil, self.OnEquipScoreChange) },
		{ "bIsAdvancedProf", UIBinderSetIsVisible.New(self, self.ImgEmpty, true) },
		{ "bIsAdvancedProf", UIBinderSetIsVisible.New(self, self.ImgSoulCrystal) },
		{ "bIsShowSoulCrystalIcon", UIBinderSetIsVisible.New(self, self.BtnSoulCrystal, false, true) },
		{ "SoulCrystalIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgSoulCrystal) },
	}

	self:RegisterBinders(self.ViewModel, Binders)
	local Binders1 = {
		{ "ItemList", UIBinderValueChangedCallback.New(self, nil, self.OnEquipInfoItemListChange) },
		{ "OnList", UIBinderValueChangedCallback.New(self, nil, self.OnEquipOnChange) },
		{ "OffList", UIBinderValueChangedCallback.New(self, nil, self.OnEquipOffChange) },
	}

	self:RegisterBinders(EquipmentVM, Binders1)
end

function CurrrentEquipPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnQuality, self.OnQualityClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnBestEquipment, self.OnStrongestClick)
	UIUtil.AddOnClickedEvent(self, self.BtnSoulCrystal, self.OnSoulCrystalClicked)
	
	UIUtil.AddOnStateChangedEvent(self, self.Btn_Hand, self.OnBtnHandClick)
	UIUtil.AddOnStateChangedEvent(self, self.Btn_Hat, self.OnBtnHatClick)
	UIUtil.AddOnStateChangedEvent(self, self.Btn_HatStyle, self.OnBtnHatStyleClick)
	UIUtil.AddOnStateChangedEvent(self, self.Btn_Pose, self.OnBtnPoseClick)
	UIUtil.AddOnStateChangedEvent(self, self.Btn_ShowAllModel, self.OnShowAllModelChange)
end

------------------------------------------父页面函数--------------------------------------------
--装分按钮，hold，等视觉
function CurrrentEquipPageView:OnQualityClicked()
	local BtnSize = UIUtil.GetWidgetSize(self.Icon_Class)
	TipsUtil.ShowSimpleTipsView({Title = _G.LSTR(1050059), Content = _G.LSTR(1050017)},
	 self.Icon_Class, _G.UE.FVector2D(-BtnSize.X - 10, 0), _G.UE.FVector2D(1, 0), false)
end

function CurrrentEquipPageView:OnStrongestClick()
	if self.SuperView then
		self.SuperView:OnStrongestClick()
	end
end

function CurrrentEquipPageView:OnEquipmentListSelect()
	if self.SuperView then
		self.SuperView:OnEquipmentListSelect()
	end
end

function CurrrentEquipPageView:OnSoulCrystalClicked()
	-- 还需要添加 职业
	local RoleInitCfg = require("TableCfg/RoleInitCfg")
	local ProtoRes = require("Protocol/ProtoRes")
	local ProfID = self.ViewModel.ProfID
	local Name = RoleInitCfg:FindRoleInitProfName(ProfID)
	local Level = RoleInitCfg:FindProfLevel(ProfID)
	local SoulDesc = RoleInitCfg:FindSoulDesc(ProfID)
	local IsBaseProf = Level ~= ProtoRes.prof_level.PROF_LEVEL_ADVANCED
	local StartQuestCfg = {}
	local CfgData = {}
	local CfgData1 = {}
	if IsBaseProf then
		--检查有没有特职
		local AdvencedProf = RoleInitCfg:FindProfAdvanceProf(ProfID)
		StartQuestCfg = _G.AdventureCareerMgr:GetCurProfChangeProfData(ProfID, AdvencedProf ~= nil)
		CfgData = _G.AdventureCareerMgr:GetQuestCfgData(StartQuestCfg.StartQuestID)
		CfgData1 = _G.AdventureCareerMgr:GetChapterCfgData(CfgData.ChapterID)
	end
	local ModuleID = ProtoCommon.ModuleID
	local MoudleOpen = _G.ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDAdventure)
	local ShowJumpButton = IsBaseProf and MoudleOpen
	local RoleRedTable = _G.EquipmentMgr:GetRoleRedDotData()
	local HasRolePoint  = RoleRedTable[ProfID]
	local BaseContent = {{Title = Name, Content = {self.ViewModel.ProfDescription}}}
	local AdvenceContent = {{Title =string.format(LSTR(1050230), Name), Content = {SoulDesc}}, {Title = Name, Content = {self.ViewModel.ProfDescription}}}
	local Data = {
		Title = Name,
		Content = IsBaseProf and BaseContent or AdvenceContent,
		SubTitle = IsBaseProf and  LSTR(1050175) or nil,
		HasJumpRedDot = HasRolePoint,
		JumpWay = ShowJumpButton and {
			JumpTitle = CfgData1.QuestName or "",
			JumpIcon = "Texture2D'/Game/Assets/Icon/071000HUD/UI_Icon_071341.UI_Icon_071341'",
			IsRedirect = true,
			View = self, 
			GoClickedCallback = function ()
				--清理红点数据
				_G.EquipmentMgr:SetSoulBtnClickTimeTable(ProfID)
				_G.AdventureCareerMgr:JumpToTargetProf(ProfID)
				_G.UIViewMgr:HideView(_G.UIViewID.CommHelpInfoJumpTipsView)
			end,
		} or nil
	}

	local BtnSize = UIUtil.CanvasSlotGetSize(self.BtnSoulCrystal)
	TipsUtil.ShowInfoJumpTips(Data, self.BtnSoulCrystal,_G.UE.FVector2D(-BtnSize.X, 0), _G.UE.FVector2D(1, 0), false)
end

function CurrrentEquipPageView:OnBtnHandClick(ToggleButton, ButtonState)
	if self.SuperView then
		self.SuperView:OnBtnHandClick(ToggleButton, ButtonState)
	end
end

function CurrrentEquipPageView:OnBtnHatClick(ToggleButton, ButtonState)
	local EntityID = MajorUtil.GetMajorEntityID()
	local AttrComponent = ActorUtil.GetActorAttributeComponent(EntityID)
	if nil ~= AttrComponent then
		local ChangeRoleID = AttrComponent:GetChangeRoleID()
        if ChangeRoleID ~= 0 then
			_G.MsgTipsUtil:ShowTips(LSTR(1050233))
			self.Btn_Hat:SetCheckedState(_G.UE.EToggleButtonState.Checked,false)
			return
        end
    end
	
	if self.SuperView then
		self.SuperView:OnBtnHatClick(ToggleButton, ButtonState)
	end
end

function CurrrentEquipPageView:OnBtnHatStyleClick(ToggleButton, ButtonState)
	if self.SuperView then
		self.SuperView:OnBtnHatStyleClick(ToggleButton, ButtonState)
	end
end

function CurrrentEquipPageView:OnShowAllModelChange(ToggleButton, ButtonState)
	if self.SuperView then
		self.SuperView:OnShowAllModelChange(ToggleButton, ButtonState)
	end
end

function CurrrentEquipPageView:OnBtnPoseClick(ToggleButton, ButtonState)
	if self.SuperView then
		self.SuperView:OnBtnPoseClick(ToggleButton, ButtonState)
	end
end
----------------------------------------------父页面函数E---------------------------------------
----------------------------------------------VM事件S---------------------------------------
function CurrrentEquipPageView:OnStrongestChange()
	local ColorHex = self.ViewModel.bStrongest and COLOR_DISABLE or COLOR_ENABLE
	_G.EquipmentMgr:SetRedDot(7002, not self.ViewModel.bStrongest)
	if not self.ViewModel.bStrongest then
		self.BtnBestEquipment:SetIsNormalState(true)
	else
		self.BtnBestEquipment:SetIsDisabledState(true, true)
	end
	
end

function CurrrentEquipPageView:OnEquipScoreChange(NewValue, OldValue)
	if NewValue == nil then
		return
	end
	self.Text_EquipScore:SetText(string.format("%d", self.ViewModel.EquipScore))
end

function CurrrentEquipPageView:OnEquipInfoItemListChange()
	local ItemList = EquipmentVM.ItemList
	if (ItemList == nil) then return end
	local HasPart = {}
	for Key,Item in pairs(ItemList) do
		HasPart[Key] = 1
		self:UpdateSlotByItem(Key, Item.ResID, Item.GID, false)
	end
	---初始化ItemList以为的装备Slot
	for _, v in pairs(ProtoCommon.equip_part) do
		if HasPart[v] == nil then
			self:UpdateSlotByItem(v, nil, nil, true)
		end
	end
	self:UpdateWhenEquipedChange()
end

function CurrrentEquipPageView:OnEquipOffChange()
	local OnOffList = EquipmentVM.OffList
	if (OnOffList == nil) then return end
	EquipmentVM.OffList = nil

	local Count = 0
	local Part
	for _,EquipInfo in pairs(OnOffList) do
		Count = Count + 1
		Part = EquipInfo.Part
		self:UpdateSlotByItem(EquipInfo.Part, nil, nil, false)
	end
	if (Count > 1) then
		self.SuperView:OnListPageBackClick()
	else
		self:OnSlotClick(Part)
	end
	self.EquipmentDetail:Refresh(true)
	self.EquipmentListPage.ViewModel:UpdateList()
	self:UpdateWhenEquipedChange()
end

function CurrrentEquipPageView:OnEquipOnChange()
	local OnOffList = EquipmentVM.OnList
	if (OnOffList == nil) then return end
	EquipmentVM.OnList = nil

	local Count = 0
	local Part
	for Key, Item in pairs(OnOffList) do
		Count = Count + 1
		Part = Key
		self:UpdateSlotByItem(Key, Item.ResID, Item.GID, false, true)
	end

	if (Count > 1) then
		---最强装备替换
		if self.SuperView and self.SuperView.SelectSlotPart then
			self:OnSlotClick(self.SuperView.SelectSlotPart)
		end
	elseif Count == 1 and self.SuperView and self.SuperView.SelectSlotPart then
		---单件装备替换&&有选中的插槽部位
		self:OnSlotClick(Part)
	end
	self.EquipmentDetail:Refresh(true)
	self.EquipmentListPage.ViewModel:UpdateList()
	self:UpdateWhenEquipedChange()
end

function CurrrentEquipPageView:UpdateWhenEquipedChange()
	self.ViewModel.EquipScore = _G.EquipmentMgr:CalculateEquipScore()
	self.ViewModel.bStrongest = _G.EquipmentMgr:IsStrongest()
end
----------------------------------------------VM事件E---------------------------------------
----------------------------------------------右侧装备栏函数S-------------------------------
function CurrrentEquipPageView:UpdateSlotByItem(Part, ResID, GID, bAddClick, bPlayAnim)
	local Key = "EquipSlotItem"..Part
	if self[Key] ~= nil then
		self[Key].ViewModel:SetPart(Part, ResID, GID)
		--self[Key].ViewModel.bShowProgress = false
		if bAddClick == true then
			self[Key].ViewModel.OnClick = function (ViewModel)
				self:OnSlotClick(ViewModel.Part)
			end
		end
		if bPlayAnim then
			self[Key].ViewModel.bPlayAnimChange = true
		end
	end
end

function CurrrentEquipPageView:OnSlotClick(Part)
	if self.SuperView then
		self.SuperView:OnSlotClick(Part)
	end
end

function CurrrentEquipPageView:GetSlotViewModel(Part)
	local Key = "EquipSlotItem"..Part
	if self[Key] ~= nil then
		return self[Key].ViewModel
	end
	return nil
end

function CurrrentEquipPageView:SetEquipmentDetailVsible(Visible)
	local Animation = Visible and self.AnimListPanelIn or self.AnimListPanelOut
	UIUtil.SetIsVisible(self.EquipmentDetail, Visible)
	UIUtil.SetIsVisible(self.EquipmentListPage, Visible)
	UIUtil.SetIsVisible(self.Btn_ShowAllModel, Visible, true)
	UIUtil.SetIsVisible(self.SettingBtnsPanel, not Visible)
end
----------------------------------------------右侧装备栏函数E-------------------------------
function CurrrentEquipPageView:UpdateRedDot()
	_G.EquipmentMgr:SetRedDot(7002, not self.ViewModel.bStrongest)
end

return CurrrentEquipPageView