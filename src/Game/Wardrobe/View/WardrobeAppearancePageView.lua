---
--- Author: Administrator
--- DateTime: 2024-02-22 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsVisibleByBit = require("Binder/UIBinderSetIsVisibleByBit")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local TipsUtil = require("Utils/TipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local ItemCfg = require("TableCfg/ItemCfg")

---@class WardrobeAppearancePageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FVerticalBox UFVerticalBox
---@field FVerticalJob UFVerticalBox
---@field ImgLine UFImage
---@field ImgLine2 UFImage
---@field ImgLine3 UFImage
---@field ImgLine3_1 UFImage
---@field PanelBind UFCanvasPanel
---@field PanelConsume UFCanvasPanel
---@field PanelLegendaryWeapon UFCanvasPanel
---@field TableViewBind UTableView
---@field TableViewConsume UTableView
---@field TableViewSwitchList UTableView
---@field TextAchievement_1 URichTextBox
---@field TextAchievement_2 URichTextBox
---@field TextBind URichTextBox
---@field TextConsume URichTextBox
---@field TextConsume_1 URichTextBox
---@field TextGender URichTextBox
---@field TextJob URichTextBox
---@field TextJobLevel URichTextBox
---@field TextName UFTextBlock
---@field TextRace URichTextBox
---@field TextUnlock URichTextBox
---@field WardrobeJob WardrobeJobItemView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeAppearancePageView = LuaClass(UIView, true)

function WardrobeAppearancePageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FVerticalBox = nil
	--self.FVerticalJob = nil
	--self.ImgLine = nil
	--self.ImgLine2 = nil
	--self.ImgLine3 = nil
	--self.ImgLine3_1 = nil
	--self.PanelBind = nil
	--self.PanelConsume = nil
	--self.PanelLegendaryWeapon = nil
	--self.TableViewBind = nil
	--self.TableViewConsume = nil
	--self.TableViewSwitchList = nil
	--self.TextAchievement_1 = nil
	--self.TextAchievement_2 = nil
	--self.TextBind = nil
	--self.TextConsume = nil
	--self.TextConsume_1 = nil
	--self.TextGender = nil
	--self.TextJob = nil
	--self.TextJobLevel = nil
	--self.TextName = nil
	--self.TextRace = nil
	--self.TextUnlock = nil
	--self.WardrobeJob = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeAppearancePageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.WardrobeJob)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeAppearancePageView:OnInit()

	self.ConsumeListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewConsume)
	self.BindListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBind, self.OnBindListChanged, true)
	self.SwitchListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSwitchList, self.OnSwitchListChanged, true)

	local BitData1, BitData2 = {}, {}
	self.Binders = {
		{ "TitleName", UIBinderSetText.New(self, self.TextName)},
		{ "GenderCondText", UIBinderSetText.New(self, self.WardrobeJob.TextGender) },
		{ "ProfCondText", UIBinderSetText.New(self, self.WardrobeJob.TextJob) },
		{ "ProfLevelText", UIBinderSetText.New(self, self.WardrobeJob.TextJobLevel) },
		{ "RaceCondText", UIBinderSetText.New(self, self.WardrobeJob.TextRace) },
		{ "UnlockTxt", UIBinderSetText.New(self, self.WardrobeJob.TextUnlock)},

		{ "GenderCondColor", UIBinderSetColorAndOpacityHex.New(self, self.WardrobeJob.TextGender) },
		{ "ProfCondColor", UIBinderSetColorAndOpacityHex.New(self, self.WardrobeJob.TextJob) },
		{ "ProfLevelColor", UIBinderSetColorAndOpacityHex.New(self, self.WardrobeJob.TextJobLevel) },
		{ "RaceCondColor", UIBinderSetColorAndOpacityHex.New(self, self.WardrobeJob.TextRace) },
		{ "UnlockTxtColor", UIBinderSetColorAndOpacityHex.New(self, self.WardrobeJob.TextUnlock) },
		{ "DetailProfVisible", UIBinderSetIsVisible.New(self, self.WardrobeJob.BtnInfo2, false, true)},

		{ "bAnyItemSelected", UIBinderSetIsVisibleByBit.New(self, self.WardrobeJob.ImgArrow1, BitData1) },
		{ "bAnyItemSelected", UIBinderSetIsVisibleByBit.New(self, self.WardrobeJob.ImgArrow2, BitData2) },
		{ "ProfImproveVisible", UIBinderSetIsVisibleByBit.New(self, self.WardrobeJob.ImgArrow1, BitData1)},
		{ "LevelImproveVisible", UIBinderSetIsVisibleByBit.New(self, self.WardrobeJob.ImgArrow2, BitData2)},

		{ "ConsumeList",  UIBinderUpdateBindableList.New(self, self.ConsumeListAdapter)},
		{ "BindList",  UIBinderUpdateBindableList.New(self, self.BindListAdapter)},
		{ "SwitchList",  UIBinderUpdateBindableList.New(self, self.SwitchListAdapter)},
		{ "SwitchListSelectedIndex", UIBinderValueChangedCallback.New(self, nil, self.OnSwitchListSelectedIndexChanged)},
		{ "BindListSelectedIndex", UIBinderValueChangedCallback.New(self, nil, self.OnBindListSelectedIndexChanged)},

		{"PanelConsumeVisible", UIBinderSetIsVisible.New(self, self.PanelLegendaryWeapon, true)},
		{"PanelConsumeVisible", UIBinderSetIsVisible.New(self, self.PanelConsume)},
		{"PanelBindVisible", UIBinderSetIsVisible.New(self, self.PanelBind)},

		{"AchievementVisible1", UIBinderSetIsVisible.New(self, self.TextAchievement_1)},
		{"AchievementVisible2", UIBinderSetIsVisible.New(self, self.TextAchievement_2)},

		{"AchievementTxt1", UIBinderSetText.New(self, self.TextAchievement_1)},
		{"AchievementTxt2", UIBinderSetText.New(self, self.TextAchievement_2)},



		{ "CurAppUnlockLevelConditon", UIBinderSetIsVisible.New(self, self.WardrobeJob.SizeBoxX)},
		{ "CurAppUnlockProfCondVisible", UIBinderSetIsVisible.New(self, self.WardrobeJob.SizeBoxX2)},
		{ "CurAppUnlockGenderCondVisible", UIBinderSetIsVisible.New(self, self.WardrobeJob.SizeBoxX3)},
		{ "CurAppUnlockRaceCondVisible", UIBinderSetIsVisible.New(self, self.WardrobeJob.SizeBoxX4)},
		{ "CurAppUnlockStainCondVisible", UIBinderSetIsVisible.New(self, self.WardrobeJob.SizeBoxX5)},
	


	}

	self.CurEquipID = 0
	self.CurAppearanceID = 0

end

function WardrobeAppearancePageView:OnDestroy()

end

function WardrobeAppearancePageView:OnShow()
	self.WardrobeJob:SetCallback(self, self.OnClickedBtnInfo2)
	self.WardrobeJob:SetButtonStyle(HelpInfoUtil.HelpInfoType.NewTips)

	self:InitText()
end

function WardrobeAppearancePageView:InitText()
	self.TextJob:SetText(_G.LSTR(1080086))
	self.TextJobLevel:SetText(_G.LSTR(1080087))
	self.TextGender:SetText(_G.LSTR(1080088))
	self.TextRace:SetText(_G.LSTR(1080089))
	self.TextUnlock:SetText(_G.LSTR(1080090))
	self.TextConsume:SetText(_G.LSTR(1080091))
	self.TextBind:SetText(_G.LSTR(1080092))
	self.TextConsume_1:SetText(_G.LSTR(1080093))
end


function WardrobeAppearancePageView:OnHide()
	self.CurEquipID = 0
	self.CurAppearanceID = 0
	self.VM.bAnyItemSelected = false
end

function WardrobeAppearancePageView:OnRegisterUIEvent()

end

function WardrobeAppearancePageView:OnRegisterGameEvent()

end

function WardrobeAppearancePageView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self.VM = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
	self.WardrobeJob:SetButtonStyle(HelpInfoUtil.HelpInfoType.NewTips)
end

function WardrobeAppearancePageView:OnSwitchListSelectedIndexChanged()
	if self.VM.SwitchListSelectedIndex ~= nil then
		self.SwitchListAdapter:SetSelectedIndex(self.VM.SwitchListSelectedIndex)
	end
end

function WardrobeAppearancePageView:OnBindListSelectedIndexChanged()
	if self.VM.BindListSelectedIndex ~= nil then
		self.BindListAdapter:SetSelectedIndex(self.VM.BindListSelectedIndex)
	end
end

function WardrobeAppearancePageView:SetCurAppearanceID(AppearanceID)
	self.CurAppearanceID = AppearanceID
end

function WardrobeAppearancePageView:ClearBindSelected()
	if self.VM then
		self.VM.bAnyItemSelected = false
	end
	self.BindListAdapter:CancelSelected()
end

function WardrobeAppearancePageView:ClearSwitchList()
	if self.VM then
		self.VM:ClearSwitchList()
	end
end

function WardrobeAppearancePageView:OnBindListChanged(Index, ItemData, ItemView)
	if self.VM == nil then
		return
	end

	local ID = ItemData.ID
	self.VM:UpdateImproveFlag(self.CurAppearanceID, ID)
	self.VM.bAnyItemSelected = true
	if not ItemData.IsSwitch then
		-- self.BindListAdapter:CancelSelected()
		local ResID = ItemData.GID
		if ResID ~= nil and ResID ~= 0 then
			self:RegisterTimer(function()
				if _G.BagMgr:FindItem(ResID) ~= nil then 
				ItemTipsUtil.ShowTipsByGID(ResID, self.BindListAdapter, {X = 8, Y = 0})
				else
				local Item, Part = _G.EquipmentMgr:GetEquipedItemByGID(ResID)
					ItemTipsUtil.ShowTipsByItem(Item, self.BindListAdapter)
				end
			end, 0.3, 0, 1)
		end
		return
	end

	self.CurEquipID = ID
	self.VM:UpdateSwitchList(ID)
end

function WardrobeAppearancePageView:OnSwitchListChanged(Index, ItemData, ItemView)
	--指定绑定Gid
	local BindList = self.VM.BindList
	local SwitchGID = ItemData.GID
	for i = 1, BindList:Length() do
		local BindItemVM = BindList:Get(i)
		if BindItemVM.ID == self.CurEquipID then
			local BindGID = BindItemVM.GID
			BindItemVM:UpdateBindItemGID(SwitchGID)
			ItemData.GID = BindGID
		end
	end
end

function WardrobeAppearancePageView:OnClickedBtnInfo2()
	local ID = self.CurAppearanceID

	if ID == nil then
		return
	end

	local Content
	local ProfLimit = {}
	local ClassLimit = {}
	if WardrobeMgr:GetIsUnlock(ID) then
		local Data = WardrobeMgr:GetUnlockAppearanceDataByID(ID)
		local ProfLimit = WardrobeMgr:GetProfLimit(Data)
		local ClassLimit = WardrobeMgr:GetClassLimits(Data)
		Content = WardrobeUtil.GetDetailProfCondText(ProfLimit, ClassLimit)
	end

	if not WardrobeUtil.GetIsSpecial(ID) then
		local BindList = self.VM.BindList
		for i = 1, BindList:Length() do
			local BindItemVM = BindList:Get(i)
			if BindItemVM then
				local Cfg = ItemCfg:FindCfgByKey(BindItemVM.ID)
				if Cfg ~= nil then
					for _, v in ipairs(Cfg.ProfLimit) do
						table.insert(ProfLimit, v)
					end
					if Cfg.ClassLimit then
						table.insert(ClassLimit, Cfg.ClassLimit)
					end
				end
			end
		end
	else
		local Cfg = ItemCfg:FindCfgByKey(WardrobeUtil.GetUnlockCostItemID(ID))
		if Cfg ~= nil then
			for _, v in ipairs(Cfg.ProfLimit) do
				table.insert(ProfLimit, v)
			end
			if Cfg.ClassLimit then
				table.insert(ClassLimit, Cfg.ClassLimit)
			end
		end
	end

	Content =  WardrobeUtil.GetDetailProfCondText(ProfLimit, table.is_nil_empty(ClassLimit) and 0 or ClassLimit) 

	TipsUtil.ShowInfoTips(Content, self.WardrobeJob.BtnInfo2, _G.UE.FVector2D(
		-70, 50),  _G.UE.FVector2D(1, 1))
end

return WardrobeAppearancePageView