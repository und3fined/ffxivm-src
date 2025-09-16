---
--- Author: Administrator
--- DateTime: 2024-02-22 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local WardrobePresetsPanelVM = require("Game/Wardrobe/VM/WardrobePresetsPanelVM")
local ClosetPresetSuitCfg = require("TableCfg/ClosetPresetSuitCfg")
local ClosetCfg = require("TableCfg/ClosetCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")

local LSTR = _G.LSTR
local EquipmentPartList = ProtoCommon.equip_part

---@class WardrobePresetsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAssociation UToggleButton
---@field BtnBack CommBackBtnView
---@field BtnEdit UFButton
---@field BtnSave CommBtnMView
---@field BtnUse CommBtnMView
---@field BtnUsed CommBtnMView
---@field CommonBkg CommonBkg01View
---@field CommonTitle CommonTitleView
---@field FHorizontal UFHorizontalBox
---@field FVertical UFVerticalBox
---@field PanelAssociation UFCanvasPanel
---@field PanelBg UFCanvasPanel
---@field PanelEdit UFCanvasPanel
---@field PanelTitle UFCanvasPanel
---@field TableViewList UTableView
---@field TableViewSlot UTableView
---@field TextJob UFTextBlock
---@field TextPresets UFTextBlock
---@field TextSubtitle URichTextBox
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobePresetsPanelView = LuaClass(UIView, true)

function WardrobePresetsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAssociation = nil
	--self.BtnBack = nil
	--self.BtnEdit = nil
	--self.BtnSave = nil
	--self.BtnUse = nil
	--self.BtnUsed = nil
	--self.CommonBkg = nil
	--self.CommonTitle = nil
	--self.FHorizontal = nil
	--self.FVertical = nil
	--self.PanelAssociation = nil
	--self.PanelBg = nil
	--self.PanelEdit = nil
	--self.PanelTitle = nil
	--self.TableViewList = nil
	--self.TableViewSlot = nil
	--self.TextJob = nil
	--self.TextPresets = nil
	--self.TextSubtitle = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobePresetsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.BtnUse)
	self:AddSubView(self.BtnUsed)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobePresetsPanelView:OnInit()
	self.VM = WardrobePresetsPanelVM.New()
	-- 装备菜单列表
	self.PresetsListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnPresetListChanged, true)
	self.EquipmentListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)

	self.Binders = {
		{ "PresetsList",  UIBinderUpdateBindableList.New(self, self.PresetsListAdapter)},
		{ "EquipmentList",  UIBinderUpdateBindableList.New(self, self.EquipmentListAdapter)},
		{ "SaveBtnVisible", UIBinderSetIsVisible.New(self, self.BtnSave)}, -- 保存按钮显隐
		{ "UseBtnVisible", UIBinderSetIsVisible.New(self, self.BtnUse, false, true)}, --使用按钮显隐
		-- { "BtnUseText", UIBinderSetText.New(self, self.BtnUse)},
		{ "UsingBtnVisible", UIBinderSetIsVisible.New(self, self.BtnUsed, false, true)}, --使用中按钮显隐
		{ "UsingBtnStatus", UIBinderSetIsEnabled.New(self, self.BtnUsed)},
		{ "RenameVisible", UIBinderSetIsVisible.New(self, self.PanelEdit)},
		{ "AssocaitionVisible", UIBinderSetIsVisible.New(self, self.PanelAssociation)},
		{ "AssociationCheck", UIBinderSetIsChecked.New(self, self.BtnAssociation)},
		{ "AssociationText", UIBinderSetText.New(self, self.TextJob)},
		{ "SuitName", UIBinderSetText.New(self, self.TextPresets)},
	}

	self.CurrentPresetID = nil
	self.Common_Render2D_UIBP = nil
	self.SuperView = nil
end

function WardrobePresetsPanelView:OnDestroy()
end

function WardrobePresetsPanelView:OnShow()

	if self.Params == nil then
		return
	end

	self.CurrentPresetID = 0
	UIUtil.SetIsVisible(self.PanelTitle, false)
	UIUtil.SetIsVisible(self.CommonBkg, false)
	self.Common_Render2D_UIBP = self.Params.SuperView.Common_Render2D_UIBP
	self.SuperView = self.Params.SuperView


	local ProfID = MajorUtil.GetMajorProfID()
	self.Common_Render2D_UIBP:OnProfSwitch({ProfID = ProfID})

	self.VM:InitPresetList()
	self.PresetsListAdapter:SetSelectedIndex(1)
	self.BtnBack:AddBackClick(self, function () 
		-- self.SuperView.PresetsPanelToMainPanel(self.SuperView)
		self.SuperView.ResetSelected(self.SuperView)
		self.SuperView.ShowMainPanel(self.SuperView,true)  self:Hide() end)

	self:InitText()
end

function WardrobePresetsPanelView:InitText()
	self.CommonTitle.TextTitleName:SetText(_G.LSTR(1080068))
	self.CommonTitle.TextSubtitle:SetText("")
	self.BtnSave:SetText(_G.LSTR(10011))
	self.BtnUse:SetText(_G.LSTR(1080066))
	self.BtnUsed:SetText(_G.LSTR(1080065))
end

function WardrobePresetsPanelView:OnHide()
end

function WardrobePresetsPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickedBtnSave)
	UIUtil.AddOnClickedEvent(self, self.BtnUse, self.OnClickedBtnUse)
	UIUtil.AddOnClickedEvent(self, self.BtnEdit, self.OnClickedBtnEdit)
	UIUtil.AddOnStateChangedEvent(self, self.BtnAssociation, self.OnClickedBtnAssociation)
end

function WardrobePresetsPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.WardrobePresetSuitUpdate, self.OnWardrobePresetSuitUpdate)
	self:RegisterGameEvent(EventID.WardrobeEnlagerPresets, self.OnWardrobeEnlargerPresets)
end

function WardrobePresetsPanelView:OnRegisterBinder()
	self:RegisterBinders(self.VM, self.Binders)
end


function WardrobePresetsPanelView:OnWardrobePresetSuitUpdate(Params)
	local SuitID = Params.SuitID

	--更新预设列表
	self.VM:UpdatePresetListByID(SuitID)
	--更新选中预设套装的装备
	self.VM:UpdateEquipementSlotList(self.CurrentPresetID)
	--更新选中预设套装的按钮状态
	self.VM:UpdateBtnStatus(self.CurrentPresetID)
	--更新预设模型
	self:UpdateSuit(SuitID)
end

function WardrobePresetsPanelView:OnWardrobeEnlargerPresets(Params)
	local EnlargeSuitID = Params.EnlargeSuitID
	self.VM:UpdateEnlargePresetList(EnlargeSuitID)
end

function WardrobePresetsPanelView:OnPresetListChanged(Index, ItemData, ItemView)

	local AddVisible = ItemData.AddVisible
	for i = 1, self.PresetsListAdapter:GetNum() do
		if not AddVisible then
			local ItemVM = self.PresetsListAdapter:GetItemDataByIndex(i)
			if ItemVM ~= nil then
				ItemVM.IsSelected = Index == i
			end
		end
	end
	if ItemData.AddVisible then
		-- ItemData.IsSelected = false
		self:OnClickedItemEnlargerBtn()
		return
	end


	self.CurrentPresetID = ItemData.ID
	self.VM:UpdateEquipementSlotList(ItemData.ID)
	self.VM:UpdateBtnStatus(ItemData.ID)
	self:UpdateSuit(ItemData.ID)
end

-- 保存预设套装信息
function WardrobePresetsPanelView:OnClickedBtnSave()
	local PresetID = self.CurrentPresetID
	local SuitInfo = WardrobeMgr:GetPresets(PresetID) or WardrobeMgr:GetPresetsClient(PresetID)
	-- 获取当前的装备数据
	local Suits = WardrobeMgr:GetCurAppearanceList()
	local UpSuits = {}
	local AppNum = 0

	for key, value in pairs(Suits) do
		if value.Avatar ~= 0 and WardrobeMgr:GetIsUnlock(value.Avatar) then
			UpSuits[key] = {}
			UpSuits[key].Avatar = value.Avatar
			local Color = WardrobeMgr:GetDyeColor(value.Avatar)
			UpSuits[key].Color = Color ~= 0 and Color or value.Color
			UpSuits[key].RegionDye = value.RegionDye
			AppNum = AppNum + 1
		else
			UpSuits[key] = {}
			UpSuits[key].Avatar = 0
			UpSuits[key].Color = 0
			UpSuits[key].RegionDye = {}
		end
	end

	if AppNum <= 0 then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(1080080))
		return
	end

	local MajorProfID = MajorUtil.GetMajorProfID()
	
	if SuitInfo ~= nil then
		local RelatedProf = SuitInfo.RelatedProf == MajorProfID and   SuitInfo.RelatedProf  or 0
		WardrobeMgr:SendClosetSuitSaveReq(UpSuits, PresetID, SuitInfo.SuitName, MajorProfID, RelatedProf)
	end

end

-- 使用当前的预设套装作为当前穿搭
function WardrobePresetsPanelView:OnClickedBtnUse()
	-- 外观行为
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_CLOSET_CLOTHING, true) then
		return
	end

	local PresetID = self.CurrentPresetID
	if PresetID ~= nil and PresetID ~= 0 then
		WardrobeMgr:SendClosetChooseSuitRep(PresetID)
	end
end

-- 修改名字
function WardrobePresetsPanelView:OnClickedBtnEdit()
	local PresetID = self.CurrentPresetID
	local Suit = WardrobeMgr:GetPresets(PresetID)
    local Params = {
        Title = LSTR(1080038),
        Desc = LSTR(1080039),
		Content = Suit == nil and string.format(LSTR(1080040), PresetID) or Suit.SuitName,
        MaxTextLength = 18,
        SureCallback = function(Text)
			if Text ~= "" then
				_G.JudgeSearchMgr:QueryTextIsLegal(Text, function( IsLegal )
					if not IsLegal then
						MsgTipsUtil.ShowTips(LSTR(10057)) 
						return
					end
            		WardrobeMgr:SendClosetSuitRenameReq(PresetID, Text)
				end)
			end
        end
    }

    UIViewMgr:ShowView(UIViewID.CommonPopupInput, Params)
end

--关联职业
function WardrobePresetsPanelView:OnClickedBtnAssociation(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	local PresetID = self.CurrentPresetID
	local MajorProfID = MajorUtil.GetMajorProfID()

	self.BtnAssociation:SetCheckedState(self.VM.AssociationCheck, false) 

	if IsChecked then
		--判断是否有关联职业，没有直接发送关联职业请求，有 打开二级确认框
		local LinkProfID = WardrobeMgr:GetPresetLinkProfID(PresetID)
		if not WardrobeMgr:CheckIsRepeatLinkProfID() then
			WardrobeMgr:SendClosetSuitLinkProfReq(PresetID, MajorProfID)
		else
			local CurLinkData =  WardrobeMgr:GetRepeatLinkProfData()
			MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1080041), 
											 string.format(LSTR(1080042), _G.EquipmentMgr:GetProfName(MajorProfID), CurLinkData.SuitName ),
											 function ()
											 	WardrobeMgr:SendClosetSuitLinkProfReq(PresetID, MajorProfID)
											 end, 
											 function ()
												self.BtnAssociation:SetChecked(false, false)
												self.VM.AssociationCheck = false
											 end,
											 LSTR(1080043),LSTR(1080044)
									   )
		end
	else
		WardrobeMgr:SendClosetSuitLinkProfReq(PresetID, 0)
	end
end

function WardrobePresetsPanelView:OnClickedItemEnlargerBtn()
	local CurID = WardrobeMgr:GetSuitUpperLimit() + 1
	local Cfg = ClosetPresetSuitCfg:FindCfgByKey(CurID)

	if Cfg == nil then
		return
	end

	_G.UIViewMgr:ShowView(UIViewID.WardrobeTipsWin, 
	{
		UIView = self, 
		Title = LSTR(1080045), 
		Message = LSTR(1080046),
		LeftCB = function () _G.UIViewMgr:HideView(UIViewID.WardrobeTipsWin) end, 
		RightCB = function () WardrobeMgr:SendClosetEnlargeSuitReq(CurID) end,
		Params = { CostItemID = Cfg.ScoreID, CostNum = Cfg.ScoreNum}
	})
	
end

-- 从主界面到预设界面，把当前的viewsuit 展示在预设界面。
-- 当切换预设的时候，更新的是预设套装里的外观穿戴在当前的Avatar.EquipList里。
-- 当保存/使用的时候，把viewsuit里可以穿戴的外观数据发送给服务器。根据服务器发送下来的数据更新当前模型。
-- 如果没有保存/使用 退出的时候。还是viewsuit的数据。
-- viewsuit只保存预览部位的，套装下的外观也只是保存的部位
function WardrobePresetsPanelView:UpdateSuit(PresetID)
	local Suit
	local ItemList = {}

	local IsCurrent = false
	
	-- 获取当前预设信息（PresetID == nil 的话）
	if PresetID == nil then
		Suit = WardrobeMgr:GetCurAppearanceList()
		IsCurrent = true
	else
		local ServerPresetData = WardrobeMgr:GetPresets(PresetID)
		local SuitInfo = ServerPresetData == nil and WardrobeMgr:GetPresetsClient(PresetID) or ServerPresetData
		if self.VM:IsPreInstallSuit(SuitInfo) then
			Suit = WardrobeMgr:GetCurAppearanceList()
		else
			Suit = SuitInfo.Suit
		end
	end
	 
	-- 预设套装上的装备
	for equip_part, v in pairs(Suit) do
		if v.Avatar ~= 0 then
			-- 这里还需要判断是否能穿戴
			if WardrobeMgr:CanPreviewAppearance(v.Avatar) then
				local EquipID = (IsCurrent and WardrobeMgr:IsRandomAppID(v.Avatar)) and WardrobeMgr:GetEquipIDByRandomApp(v.Avatar) or WardrobeUtil.GetEquipIDByAppearanceID(v.Avatar)
				local TempStainAera = {}
				if WardrobeUtil.GetRegionDye ~= nil then
					TempStainAera = WardrobeUtil.GetRegionDye(v.Avatar, v.RegionDye or {})
				end
				ItemList[equip_part] = {AppID = v.Avatar ,EquipID = EquipID, PartID = equip_part, ColorID = v.Color, RegionDye = TempStainAera}
			end
		end
	end
	
	--穿搭
	self:UpdateModel(ItemList)
end

-- 更新模型
function WardrobePresetsPanelView:UpdateModel(EquipList)
	for index, partID in pairs(WardrobeDefine.EquipmentTab) do
		-- 如果
		if EquipList[partID] ~= nil then
			local Equip = EquipList[partID]
			self.Common_Render2D_UIBP:PreViewEquipment(Equip.EquipID, Equip.PartID, Equip.ColorID)
			if EquipList[partID].RegionDye and not table.is_nil_empty(EquipList[partID].RegionDye) then
				self:StainPartForSection(EquipList[partID].AppID, partID, EquipList[partID].RegionDye )
			end
		else
			-- local MajorRoleDetail = MajorUtil.GetMajorRoleDetail()
			local AvatarEquipList = EquipmentVM.ItemList
			local IsExist = false
			for part, value in pairs(AvatarEquipList) do
				if part == partID then
					IsExist = true
					local TempEquip = value
					local EquipID = TempEquip.ResID
					local CurrentAppID = WardrobeMgr:GetEquipPartAppearanceID(part)
					local ColorID = 0
					local RegionDyes = {}
					if CurrentAppID ~= 0 then
						EquipID = WardrobeUtil.GetEquipIDByAppearanceID(CurrentAppID)
						ColorID = WardrobeMgr:GetCurAppearanceDyeColor(CurrentAppID)
						RegionDyes = WardrobeMgr:GetCurAppearanceRegionDyes(CurrentAppID)
					end
					self.Common_Render2D_UIBP:PreViewEquipment(EquipID, partID, ColorID)
					if #RegionDyes > 0 then
						self:StainPartForSection(CurrentAppID, partID, RegionDyes)
					end
				end
			end

			if not IsExist then
				self.Common_Render2D_UIBP:PreViewEquipment(nil, partID, 0)
			end

		end
	end
end

function WardrobePresetsPanelView:StainPartForSection(AppID, PartID, RegionDyes)
	for _, v in ipairs(RegionDyes) do
		local SectionList = WardrobeUtil.ParseSectionIDList(AppID, v.ID)
		for _, sectionID in ipairs(SectionList) do
			self.Common_Render2D_UIBP:StainPartForSection(WardrobeDefine.StainPartType[PartID], sectionID, v.ColorID)
		end
	end
end



return WardrobePresetsPanelView