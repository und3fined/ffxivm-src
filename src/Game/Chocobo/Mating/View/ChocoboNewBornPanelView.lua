---
--- Author: Administrator
--- DateTime: 2024-01-17 13:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ChocoboNewBornPanelVM = require("Game/Chocobo/Mating/VM/ChocoboNewBornPanelVM")

---@class ChocoboNewBornPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnName CommBtnLView
---@field FeatherStage ChocoboFeatherStageItemView
---@field ImgGender UFImage
---@field LevelItem ChocoboLevelItemView
---@field PanelBottom UFCanvasPanel
---@field PanelChildDetailInfo UFCanvasPanel
---@field PanelChildInfo UFCanvasPanel
---@field PanelParentInfo UFCanvasPanel
---@field TableViewChildDetailInfo UTableView
---@field TableViewChildInfo UTableView
---@field TableViewFatherInfo UTableView
---@field TableViewMotherInfo UTableView
---@field TextDadName UFTextBlock
---@field TextFeatherStage UFTextBlock
---@field TextMomName UFTextBlock
---@field TextTempName UFTextBlock
---@field AnimDetailInfoIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboNewBornPanelView = LuaClass(UIView, true)

function ChocoboNewBornPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnName = nil
	--self.FeatherStage = nil
	--self.ImgGender = nil
	--self.LevelItem = nil
	--self.PanelBottom = nil
	--self.PanelChildDetailInfo = nil
	--self.PanelChildInfo = nil
	--self.PanelParentInfo = nil
	--self.TableViewChildDetailInfo = nil
	--self.TableViewChildInfo = nil
	--self.TableViewFatherInfo = nil
	--self.TableViewMotherInfo = nil
	--self.TextDadName = nil
	--self.TextFeatherStage = nil
	--self.TextMomName = nil
	--self.TextTempName = nil
	--self.AnimDetailInfoIn = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboNewBornPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnName)
	self:AddSubView(self.FeatherStage)
	self:AddSubView(self.LevelItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboNewBornPanelView:OnInit()
	self.ViewModel = ChocoboNewBornPanelVM.New()
	self.FatherStarTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewFatherInfo, nil, true)
	self.MotherStarTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewMotherInfo, nil, true)
	self.ChildStarTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewChildInfo, nil, true)
	self.ChildDetailTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewChildDetailInfo, nil, true)
end

function ChocoboNewBornPanelView:OnDestroy()

end

function ChocoboNewBornPanelView:OnShow()
	self:InitConstInfo()
	
	local ChocoboID = _G.ChocoboMainVM:GetCurChildID()
	local ChocoboVM = _G.ChocoboMainVM:FindChocoboVM(ChocoboID)

	if ChocoboVM == nil then
		return
	end

	if ChocoboVM.Mating == nil then
		return
	end
	
	UIUtil.SetIsVisible(self.BtnClose, false)
	self:PlayAnimation(self.AnimIn)
	local MaleChocoboID = ChocoboVM.Mating.Father 
	local MaleChocoboVM = _G.ChocoboMainVM:FindChocoboVM(MaleChocoboID)
	if MaleChocoboVM ~= nil then 
		self:RegisterBinders(MaleChocoboVM, self.MaleBinders)
		MaleChocoboVM:ResetAttrVMList()
	end

	local FemaleChocoboID = ChocoboVM.Mating.Mother 
	local FemaleChocoboVM = _G.ChocoboMainVM:FindChocoboVM(FemaleChocoboID)
	if FemaleChocoboVM ~= nil then 
		self:RegisterBinders(FemaleChocoboVM, self.FemaleBinders)
		FemaleChocoboVM:ResetAttrVMList()
	end

	self.ViewModel:UpdatePanel(ChocoboVM)
end

function ChocoboNewBornPanelView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true
	
	-- LSTR string: 新生的雏鸟
	self.TextTempName:SetText(_G.LSTR(420052))
	-- LSTR string: 羽力值
	self.TextFeatherStage:SetText(_G.LSTR(420005))
	-- LSTR string: 取名
	self.BtnName:SetButtonText(_G.LSTR(420157))
end

function ChocoboNewBornPanelView:OnHide()

end

function ChocoboNewBornPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnName, self.OnClickBtnName)
end

function ChocoboNewBornPanelView:OnRegisterGameEvent()

end

function ChocoboNewBornPanelView:OnRegisterBinder()
	self.Binders = {
		{"ChildLevel", UIBinderSetText.New(self, self.LevelItem.TextLevel)},
		{"GenderPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgGender) },

		{ "FeatherRankText", UIBinderSetText.New(self, self.FeatherStage.TextNumber) },
        { "FeatherIconPath", UIBinderSetBrushFromAssetPath.New(self, self.FeatherStage.ImgBG) },
        { "FeatherValue", UIBinderSetText.New(self, self.TextFeatherStage) },

		{"PanelParentInfoVisible", UIBinderSetIsVisible.New(self, self.PanelParentInfo) },
		{"PanelChildVisible", UIBinderSetIsVisible.New(self, self.PanelChildInfo) },
		{"PanelChildDetailVisible", UIBinderSetIsVisible.New(self, self.PanelChildDetailInfo) },

		{"PanelBottomVisible", UIBinderSetIsVisible.New(self, self.PanelBottom) },
		{"BtnNameVisible", UIBinderSetIsVisible.New(self, self.BtnName) },

		{ "ChildStarList", UIBinderUpdateBindableList.New(self, self.ChildStarTableView) },
		{ "ChildDetailList", UIBinderUpdateBindableList.New(self, self.ChildDetailTableView) },
	}
	self.MaleBinders = {
		{"Name", UIBinderSetText.New(self, self.TextDadName)},
		{"AttrVMList", UIBinderUpdateBindableList.New(self, self.FatherStarTableView) },
	}

	self.FemaleBinders = {
		{"Name", UIBinderSetText.New(self, self.TextMomName)},
		{"AttrVMList", UIBinderUpdateBindableList.New(self, self.MotherStarTableView) },
	}
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ChocoboNewBornPanelView:OnClickBtnName()
	_G.StoryMgr:StopSequence()
end

function ChocoboNewBornPanelView:OnAnimationFinished(Animation)
	if Animation == self.AnimIn then
		self:PlayAnimation(self.AnimDetailInfoIn)
		self.ViewModel:UpdateChildDetail()
	end
end

return ChocoboNewBornPanelView