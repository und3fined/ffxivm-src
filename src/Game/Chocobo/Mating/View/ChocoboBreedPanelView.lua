---
--- Author: Administrator
--- DateTime: 2024-01-02 12:34
--- Description: 陆行鸟养成配种
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")

local ChocoboRentCfg  = require("TableCfg/ChocoboRentCfg")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ChocoboBreedPanelVM = require("Game/Chocobo/Mating/VM/ChocoboBreedPanelVM")

local OVERVIEW_FILTER_TYPE = ChocoboDefine.OVERVIEW_FILTER_TYPE

local SCORE_TYPE = ProtoRes.SCORE_TYPE
local EquipmentMgr = nil
local BuddyMgr = nil
local ChocoboMainVM = nil
local LSTR = nil
local ChocoboBreedLightSystemID = 21 -- 天气表里的ID

---@class ChocoboBreedPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bkg CommonBkg01View
---@field BtnClose CommonCloseBtnView
---@field BtnConfirmBreed CommBtnLView
---@field BtnFemaleChange UFButton
---@field BtnMaleChange UFButton
---@field ChangePage ChocoboBreedChangePageView
---@field ChildLevel ChocoboLevelItemView
---@field FemaleLevel ChocoboLevelItemView
---@field FemaleModel ChocoboRenderToTextureView
---@field ForbidLevel ChocoboLevelItemView
---@field HorizontalForbid UFHorizontalBox
---@field HorizontalPrice UFHorizontalBox
---@field HorizontalText UFHorizontalBox
---@field ImgBlackMask UFImage
---@field ImgColor1 UFImage
---@field ImgColor2 UFImage
---@field ImgFemaleLease UFImage
---@field ImgMaleLease UFImage
---@field ImgPrice UFImage
---@field MaleLevel ChocoboLevelItemView
---@field MaleModel ChocoboRenderToTextureView
---@field MoneySlot CommMoneySlotView
---@field TableViewChildInfo UTableView
---@field TableViewFemaleInfo UTableView
---@field TableViewMaleInfo UTableView
---@field TextChildPreview UFTextBlock
---@field TextColor1 UFTextBlock
---@field TextColor2 UFTextBlock
---@field TextFemaleName UFTextBlock
---@field TextGeneration UFTextBlock
---@field TextMaleName UFTextBlock
---@field TextPrice UFTextBlock
---@field TextReason UFTextBlock
---@field TextReason1 UFTextBlock
---@field TextReason2 UFTextBlock
---@field TextSlant UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimBGLoop UWidgetAnimation
---@field AnimChangeFemale UWidgetAnimation
---@field AnimChangeMale UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimMating UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboBreedPanelView = LuaClass(UIView, true)

function ChocoboBreedPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bkg = nil
	--self.BtnClose = nil
	--self.BtnConfirmBreed = nil
	--self.BtnFemaleChange = nil
	--self.BtnMaleChange = nil
	--self.ChangePage = nil
	--self.ChildLevel = nil
	--self.FemaleLevel = nil
	--self.FemaleModel = nil
	--self.ForbidLevel = nil
	--self.HorizontalForbid = nil
	--self.HorizontalPrice = nil
	--self.HorizontalText = nil
	--self.ImgBlackMask = nil
	--self.ImgColor1 = nil
	--self.ImgColor2 = nil
	--self.ImgFemaleLease = nil
	--self.ImgMaleLease = nil
	--self.ImgPrice = nil
	--self.MaleLevel = nil
	--self.MaleModel = nil
	--self.MoneySlot = nil
	--self.TableViewChildInfo = nil
	--self.TableViewFemaleInfo = nil
	--self.TableViewMaleInfo = nil
	--self.TextChildPreview = nil
	--self.TextColor1 = nil
	--self.TextColor2 = nil
	--self.TextFemaleName = nil
	--self.TextGeneration = nil
	--self.TextMaleName = nil
	--self.TextPrice = nil
	--self.TextReason = nil
	--self.TextReason1 = nil
	--self.TextReason2 = nil
	--self.TextSlant = nil
	--self.TextTitle = nil
	--self.AnimBGLoop = nil
	--self.AnimChangeFemale = nil
	--self.AnimChangeMale = nil
	--self.AnimIn = nil
	--self.AnimMating = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboBreedPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bkg)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnConfirmBreed)
	self:AddSubView(self.ChangePage)
	self:AddSubView(self.ChildLevel)
	self:AddSubView(self.FemaleLevel)
	self:AddSubView(self.FemaleModel)
	self:AddSubView(self.ForbidLevel)
	self:AddSubView(self.MaleLevel)
	self:AddSubView(self.MaleModel)
	self:AddSubView(self.MoneySlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboBreedPanelView:OnInit()
	EquipmentMgr = _G.EquipmentMgr
	BuddyMgr = _G.BuddyMgr
	ChocoboMainVM = _G.ChocoboMainVM
    LSTR = _G.LSTR
	
	self.ViewModel = ChocoboBreedPanelVM.New()
	self.FemaleStarTable = UIAdapterTableView.CreateAdapter(self, self.TableViewFemaleInfo, nil, nil)
	self.MaleStarTable = UIAdapterTableView.CreateAdapter(self, self.TableViewMaleInfo, nil, nil)
	self.ChildStarTable = UIAdapterTableView.CreateAdapter(self, self.TableViewChildInfo, nil, nil)

	self.ChocoboTableView = UIAdapterTableView.CreateAdapter(self, self.ChangePage.TableViewChocobo, self.OnChocoboSelectChange, true)
	self.ChocoboTableView:SetScrollbarIsVisible(false)
end

function ChocoboBreedPanelView:OnDestroy()

end

function ChocoboBreedPanelView:OnShow()
	self:InitConstInfo()
	if self.Params == nil then
		return
	end

	self.MaleChocoboID = self.Params.MaleChocoboID
	self.FemaleChocoboID = self.Params.FemaleChocoboID
	local MatesChocoboVM = ChocoboMainVM:FindChocoboVM(self.MaleChocoboID)
	local FemaleChocoboVM = ChocoboMainVM:FindChocoboVM(self.FemaleChocoboID)

	if MatesChocoboVM == nil or FemaleChocoboVM == nil then
		return
	end
	
	self:PlayAnimIn()
	self:PlayAnimMating()
	self.MoneySlot:UpdateView(SCORE_TYPE.SCORE_TYPE_KING_DEE, false, nil, true)

	local Icon = ScoreMgr:GetScoreIconName(SCORE_TYPE.SCORE_TYPE_KING_DEE)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgPrice, Icon)

	self:UpdateBreedPanel(self.FemaleChocoboID,self.MaleChocoboID)

	_G.LightMgr:EnableUIWeather(ChocoboBreedLightSystemID)
	self:ChangeFemaleModel(self.FemaleChocoboID)
	self:ChangeMaleModel(self.MaleChocoboID)
end

function ChocoboBreedPanelView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true
	
	-- LSTR string: 竞赛陆行鸟配种
	self.TextTitle:SetText(_G.LSTR(420043))  --竞赛陆行鸟配种
	-- LSTR string: 子鸟属性预想
	self.TextChildPreview:SetText(_G.LSTR(420044))
	-- LSTR string: 血统代数
	self.TextGeneration:SetText(_G.LSTR(420038))
	-- LSTR string: 确认配种
	self.BtnConfirmBreed:SetBtnName(_G.LSTR(420047))
	self.TextSlant:SetText("/")
end

function ChocoboBreedPanelView:OnHide()
	self.MaleModel:Release()
	self.FemaleModel:Release()
	_G.LightMgr:DisableUIWeather()
end

function ChocoboBreedPanelView:OnRegisterUIEvent()
	self.ChangePage.CommSidebarFrameS_UIBP.BtnClose:SetCallback(self, self.OnClickBtnCloseChangePage)
	UIUtil.AddOnSelectionChangedEvent(self, self.ChangePage.DropDownSort, self.OnSelectionChangedSortList)
	UIUtil.AddOnClickedEvent(self, self.ChangePage.BtnRandom, self.OnClickBtnRandom)
	UIUtil.AddOnClickedEvent(self, self.ChangePage.BtnSelect, self.OnClickBtnSelect)

	UIUtil.AddOnClickedEvent(self, self.BtnMaleChange, self.OnClickMaleChange)
	UIUtil.AddOnClickedEvent(self, self.BtnFemaleChange, self.OnClickFemaleChange)
	UIUtil.AddOnClickedEvent(self, self.BtnConfirmBreed, self.OnClickedConfirmBreed)
end

function ChocoboBreedPanelView:OnRegisterGameEvent()

end

function ChocoboBreedPanelView:OnRegisterBinder()
	self.FemaleBinders = {
		{"Name", UIBinderSetText.New(self, self.TextFemaleName)},
		{"Generation", UIBinderSetText.New(self, self.FemaleLevel.TextLevel)},
		{"IsRent", UIBinderSetIsVisible.New(self, self.ImgFemaleLease) },
		{"AttrVMList", UIBinderUpdateBindableList.New(self, self.FemaleStarTable) },
	}

	self.MaleBinders = {
		{"Name", UIBinderSetText.New(self, self.TextMaleName)},
		{"Generation", UIBinderSetText.New(self, self.MaleLevel.TextLevel)},
		{"IsRent", UIBinderSetIsVisible.New(self, self.ImgMaleLease) },
		{"AttrVMList", UIBinderUpdateBindableList.New(self, self.MaleStarTable) },
	}
		
	self.ChildBinders = {
		{"ChildLevel", UIBinderSetText.New(self, self.ChildLevel.TextLevel)},
		{"ChildColor1Name", UIBinderSetText.New(self, self.TextColor1)},
		{"ChildColor2Name", UIBinderSetText.New(self, self.TextColor2)},
		{"ChildColor1", UIBinderSetColorAndOpacity.New(self, self.ImgColor1)},
		{"ChildColor2", UIBinderSetColorAndOpacity.New(self, self.ImgColor2)},
		{"ChildDetailList", UIBinderUpdateBindableList.New(self, self.ChildStarTable) },
		{"TextPrice", UIBinderSetText.New(self, self.TextPrice)},
		{"BtnBreedEnabled", UIBinderSetIsEnabled.New(self,self.BtnConfirmBreed)},

		{"ForbidVisible", UIBinderSetIsVisible.New(self,self.HorizontalForbid)},
		{"PriceVisible", UIBinderSetIsVisible.New(self,self.HorizontalPrice)},
		{"ReasonVisible", UIBinderSetIsVisible.New(self, self.HorizontalText)},
		{"ForbidLevel", UIBinderSetText.New(self, self.ForbidLevel.TextLevel)},
		{"ForbidLevelVisible", UIBinderSetIsVisible.New(self, self.ForbidLevel)},
		{"TextReason", UIBinderSetText.New(self, self.TextReason)},
		{"TextReason1", UIBinderSetText.New(self, self.TextReason1)},
		{"TextReason2", UIBinderSetText.New(self, self.TextReason2)},
	}

	self:RegisterBinders(self.ViewModel, self.ChildBinders)

	self.Binders = {
		{ "MatesChocoboVMList", UIBinderUpdateBindableList.New(self, self.ChocoboTableView) },
	}

	if ChocoboMainVM ~= nil then
		self:RegisterBinders(ChocoboMainVM, self.Binders)
	end
end

function ChocoboBreedPanelView:OnClickFemaleChange()
	if not UIUtil.IsVisible(self.ChangePage) then
		self.SelectedChocoboID = self.FemaleChocoboID
		self.ChocoboTableView:SetSelectedIndex(nil)
		UIUtil.SetIsVisible(self.ChangePage,true)
		-- LSTR string: 更换母鸟
		self.ChangePage.CommSidebarFrameS_UIBP.CommonTitle:SetTextTitleName(LSTR(420131))

		self.ChangeFemale = true
		ChocoboMainVM:InitMatesChocoboList(self.MaleChocoboID)
		self:InitDropDownSort()
	end
end

function ChocoboBreedPanelView:OnClickMaleChange()
	if not UIUtil.IsVisible(self.ChangePage) then
		self.SelectedChocoboID = self.MaleChocoboID
		self.ChocoboTableView:SetSelectedIndex(nil)
		UIUtil.SetIsVisible(self.ChangePage,true)
		-- LSTR string: 更换父鸟
		self.ChangePage.CommSidebarFrameS_UIBP.CommonTitle:SetTextTitleName(LSTR(420132))

		self.ChangeFemale = false
		ChocoboMainVM:InitMatesChocoboList(self.FemaleChocoboID)	
		self:InitDropDownSort()
	end
end

function ChocoboBreedPanelView:InitDropDownSort()
	local Types = ChocoboDefine.OVERVIEW_FILTER_TYPE
	local FilterTypes = {  Types.STAR,Types.MAX_SPEED, Types.SPRINT_SPEED, Types.ACCELERATION, Types.STAMINA, Types.SKILL_STRENGTH }
	local FilterTypeList = {}
    for Index, FilterType in ipairs(FilterTypes) do
        FilterTypeList[Index] = {}
        FilterTypeList[Index].Name = ChocoboDefine.OVERVIEW_FILTER_TYPE_NAME[FilterType]
    end
    self.ChangePage:PlayAnimRefresh()
    self.ChangePage.DropDownSort:UpdateItems(FilterTypeList, 1)
end

function ChocoboBreedPanelView:OnClickedConfirmBreed()
	local Generation = self.ViewModel.Generation
	local RentData = ChocoboRentCfg:FindCfgByKey(Generation)
	if RentData == nil then return end
	local CoupleCost = RentData.CoupleCost

	local function Callback()
		self:PlayAnimMating()
		_G.ChocoboMgr:ReqMating(self.MaleChocoboID, self.FemaleChocoboID)
		_G.UIViewMgr:HideView(_G.UIViewID.ChocoboBreedPanelView)
	end
	local Params = { CostItemID = SCORE_TYPE.SCORE_TYPE_KING_DEE, CostNum = CoupleCost}
	-- LSTR string: 确定进行陆行鸟配种吗？
	local MsgContent = LSTR(420149)
	-- LSTR string: 陆行鸟配种确认
	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(420150), MsgContent, Callback, nil,  LSTR(10003), LSTR(10002), Params)
end

function ChocoboBreedPanelView:OnClickBtnCloseChangePage()
	if UIUtil.IsVisible(self.ChangePage) then
		UIUtil.SetIsVisible(self.ChangePage,false)

		local IsBreedChanged = false
		if self.ChangeFemale then
			IsBreedChanged = (self.FemaleChocoboID ~= self.SelectedChocoboID)
		else
			IsBreedChanged = (self.MaleChocoboID ~= self.SelectedChocoboID)
		end
		if not IsBreedChanged then
			return
		end

		-- 没有选择就还原父母和幼鸟
		self:UpdateBreedPanel(self.FemaleChocoboID,self.MaleChocoboID)
		if self.ChangeFemale then
			self:ChangeFemaleModel(self.FemaleChocoboID)
		else
			self:ChangeMaleModel(self.MaleChocoboID)
		end
	end
end

function ChocoboBreedPanelView:ChangeFemaleModel(FemaleID)
	local FemaleChocoboVM = ChocoboMainVM:FindChocoboVM(FemaleID)
	if FemaleChocoboVM == nil then return end
	if self.FemaleModel:IsCreateFinish() then
		self.FemaleModel:UpdateUIChocoboModel(FemaleChocoboVM.Armor, FemaleChocoboVM.ColorID)
	else
		local FCallBack = function()
			self.FemaleModel:UpdateUIChocoboModel(FemaleChocoboVM.Armor, FemaleChocoboVM.ColorID)
	    end

	    self.FemaleModel:CreateRenderRActor(FCallBack)
	end
end

function ChocoboBreedPanelView:ChangeMaleModel(MaleID)
	local MaleChocoboVM = ChocoboMainVM:FindChocoboVM(MaleID)
	if MaleChocoboVM == nil then return end

	if self.MaleModel:IsCreateFinish() then 
		self.MaleModel:UpdateUIChocoboModel(MaleChocoboVM.Armor, MaleChocoboVM.ColorID)
	else
		local MCallBack = function()
			self.MaleModel:UpdateUIChocoboModel(MaleChocoboVM.Armor, MaleChocoboVM.ColorID)
	    end
	    self.MaleModel:CreateRenderLActor(MCallBack)
	end
end

function ChocoboBreedPanelView:UpdateBreedPanel(FemaleID,MaleID)
	local FemaleChocoboVM = ChocoboMainVM:FindChocoboVM(FemaleID)
	if FemaleChocoboVM ~= nil then
		self:RegisterBinders(FemaleChocoboVM,self.FemaleBinders)
		FemaleChocoboVM:ResetAttrVMList()
	end
	local MaleChocoboVM = ChocoboMainVM:FindChocoboVM(MaleID)
	if MaleChocoboVM ~= nil then 
		self:RegisterBinders(MaleChocoboVM,self.MaleBinders)
		MaleChocoboVM:ResetAttrVMList()
	end
	
	if MaleChocoboVM ~= nil and FemaleChocoboVM ~= nil then
		self.ViewModel:UpdatePanel(FemaleChocoboVM,MaleChocoboVM)
	end
end

function ChocoboBreedPanelView:OnClickBtnSelect()
	if UIUtil.IsVisible(self.ChangePage) then
		UIUtil.SetIsVisible(self.ChangePage,false)

		if self.SelectedChocoboID ~= nil then
			if self.ChangeFemale then
				self:PlayAnimChangeFemale()
				self.FemaleChocoboID = self.SelectedChocoboID
			else
				self:PlayAnimChangeMale()
				self.MaleChocoboID = self.SelectedChocoboID
			end
		end
	end
end

function ChocoboBreedPanelView:OnChocoboSelectChange(Index, ItemData, ItemView)
	if ItemData == nil or self.SelectedChocoboID == ItemData.ChocoboID then 
		return 
	end

	self.SelectedChocoboID = ItemData.ChocoboID
	if self.ChangeFemale then
		self:UpdateBreedPanel(self.SelectedChocoboID,self.MaleChocoboID)
		self:ChangeFemaleModel(self.SelectedChocoboID)
	else 
		self:UpdateBreedPanel(self.FemaleChocoboID,self.SelectedChocoboID)
		self:ChangeMaleModel(self.SelectedChocoboID)
	end
end

function ChocoboBreedPanelView:OnSelectionChangedSortList(Index)
	local FilterType = { OVERVIEW_FILTER_TYPE.STAR,OVERVIEW_FILTER_TYPE.MAX_SPEED,OVERVIEW_FILTER_TYPE.SPRINT_SPEED,
		OVERVIEW_FILTER_TYPE.ACCELERATION,OVERVIEW_FILTER_TYPE.STAMINA,OVERVIEW_FILTER_TYPE.SKILL_STRENGTH}
	ChocoboMainVM:SetCurMateFilterType(FilterType[Index])
	self.ChangePage:PlayAnimRefresh()
	ChocoboMainVM:RefreshMateByFilter()
end

function ChocoboBreedPanelView:OnClickBtnRandom()
	self.ChangePage:PlayAnimRefresh()
	ChocoboMainVM:RefreshMateByFilter()
end

function ChocoboBreedPanelView:PlayAnimIn()
	self:PlayAnimation(self.AnimIn)
end

function ChocoboBreedPanelView:PlayAnimChangeFemale()
	self:PlayAnimation(self.AnimChangeFemale,0,0)
end

function ChocoboBreedPanelView:PlayAnimChangeMale()
	self:PlayAnimation(self.AnimChangeMale,0,0)
end

function ChocoboBreedPanelView:PlayAnimMating()
	self:PlayAnimation(self.AnimChangeFemale,0,0)
	self:PlayAnimation(self.AnimChangeMale,0,0)
end

return ChocoboBreedPanelView