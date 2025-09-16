---
--- Author: Administrator
--- DateTime: 2023-12-28 19:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")

local ChocoboMainVM = nil

---@class ChocoboRelationPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field DadAvatar ChocoboAvatarItemView
---@field FTextBlock UFTextBlock
---@field FTextBlock_1 UFTextBlock
---@field FTextBlock_142 UFTextBlock
---@field ImgGender UFImage
---@field MomAvatar ChocoboAvatarItemView
---@field PanelChildInfo UFCanvasPanel
---@field PanelOffspring UFCanvasPanel
---@field PanelParent UFCanvasPanel
---@field TableViewChildInfo UTableView
---@field TableViewOffspring UTableView
---@field TextChildName UFTextBlock
---@field TextDadName UFTextBlock
---@field TextMomName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboRelationPageView = LuaClass(UIView, true)

function ChocoboRelationPageView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSidebarFrameS_UIBP = nil
	--self.DadAvatar = nil
	--self.FTextBlock = nil
	--self.FTextBlock_1 = nil
	--self.FTextBlock_142 = nil
	--self.ImgGender = nil
	--self.MomAvatar = nil
	--self.PanelChildInfo = nil
	--self.PanelOffspring = nil
	--self.PanelParent = nil
	--self.TableViewChildInfo = nil
	--self.TableViewOffspring = nil
	--self.TextChildName = nil
	--self.TextDadName = nil
	--self.TextMomName = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboRelationPageView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	self:AddSubView(self.DadAvatar)
	self:AddSubView(self.MomAvatar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboRelationPageView:OnInit()
    ChocoboMainVM = _G.ChocoboMainVM
    self.AttrAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewChildInfo, nil, nil)
    self.ChildAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewOffspring, nil, nil)
end

function ChocoboRelationPageView:OnDestroy()

end

function ChocoboRelationPageView:OnShow()
    self:InitConstInfo()
end

function ChocoboRelationPageView:InitConstInfo()
    -- LSTR string: 家族关系
    self.CommSidebarFrameS_UIBP.CommonTitle:SetTextTitleName(_G.LSTR(420015))
    
    if self.IsInitConstInfo then
        return
    end

    self.IsInitConstInfo = true

    -- LSTR string: 父鸟
    self.FTextBlock:SetText(_G.LSTR(420162))
    -- LSTR string: 母鸟
    self.FTextBlock_1:SetText(_G.LSTR(420163))
    -- LSTR string: 后代鸟
    self.FTextBlock_142:SetText(_G.LSTR(420164))
end

function ChocoboRelationPageView:OnHide()

end

function ChocoboRelationPageView:OnRegisterUIEvent()
end

function ChocoboRelationPageView:OnRegisterGameEvent()

end

function ChocoboRelationPageView:OnRegisterBinder()
    self.ChocoboBinders = {
        { "Name", UIBinderSetText.New(self, self.TextChildName) },
        { "FatherName", UIBinderSetText.New(self, self.TextDadName) },
        { "FatherName", UIBinderSetText.New(self, self.TextDadName_1) },
        { "MotherName", UIBinderSetText.New(self, self.TextMomName) },
        { "MotherName", UIBinderSetText.New(self, self.TextMomName_1) },
        --{ "HasFather", UIBinderSetIsVisible.New(self, self.TextDadName) },
        --{ "HasFather", UIBinderSetIsVisible.New(self, self.TextDadName_1, true) },
        --{ "HasMother", UIBinderSetIsVisible.New(self, self.TextMomName) },
        --{ "HasMother", UIBinderSetIsVisible.New(self, self.TextMomName_1, true) },
        { "HasChild", UIBinderSetIsVisible.New(self, self.PanelOffspring) },
        { "GenderPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgGender) },
        { "AttrVMList", UIBinderUpdateBindableList.New(self, self.AttrAdapter) },
        { "ChildVMList", UIBinderUpdateBindableList.New(self, self.ChildAdapter) },
        { "HasFather", UIBinderSetIsVisible.New(self, self.DadAvatar.ImgUnknown, true) },
        { "HasMother", UIBinderSetIsVisible.New(self, self.MomAvatar.ImgUnknown, true) },
        { "FatherColor", UIBinderSetColorAndOpacity.New(self, self.DadAvatar.ImgColor) },
        { "MotherColor", UIBinderSetColorAndOpacity.New(self, self.MomAvatar.ImgColor) },
    }

    local PanelBinders = {
        { "CurSelectEntryID", UIBinderValueChangedCallback.New(self, nil, self.OnSelectGeneIDValueChanged) },
    }
    self:RegisterBinders(ChocoboMainVM, PanelBinders)
end

function ChocoboRelationPageView:OnSelectGeneIDValueChanged(NewValue, OldValue)
    if nil ~= OldValue then
        local ViewModel = ChocoboMainVM:FindChocoboVM(OldValue)
        if nil ~= ViewModel then
            self:UnRegisterBinders(ViewModel, self.ChocoboBinders)
        end
    end

    if nil ~= NewValue then
        local ViewModel = ChocoboMainVM:FindChocoboVM(NewValue)
        if nil ~= ViewModel then
            self:RegisterBinders(ViewModel, self.ChocoboBinders)
            ViewModel:ResetAttrVMList()
            ViewModel:ResetChildList()
        end
    end
end

return ChocoboRelationPageView