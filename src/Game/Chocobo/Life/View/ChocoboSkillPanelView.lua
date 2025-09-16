---
--- Author: Administrator
--- DateTime: 2023-12-14 10:54
--- Description:
---
---
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ItemUtil = require("Utils/ItemUtil")

local ChocoboMainVM
local LSTR

---@class ChocoboSkillPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnConfigureSkill CommBtnMView
---@field CheckAgain UFHorizontalBox
---@field ChocoboSkill ChocoboSkillPanelItemView
---@field CommBackpackEmpty CommBackpackEmptyView
---@field CommonBkg01_UIBP CommonBkg01View
---@field DropDown CommDropDownListView
---@field FImg_Box UFImage
---@field FImg_Check_1 UFImage
---@field HorizontalCD UFHorizontalBox
---@field HorizontalUse UFHorizontalBox
---@field PanelConfigure UFCanvasPanel
---@field PanelGetWay UFCanvasPanel
---@field PanelRight UFCanvasPanel
---@field RichTextCD URichTextBox
---@field RichTextDetail02 URichTextBox
---@field RichTextUse URichTextBox
---@field ScrollBox_35 UScrollBox
---@field SingleBox CommSingleBoxView
---@field TableViewLable UTableView
---@field TableViewSkill UTableView
---@field TableViewWayList UTableView
---@field Tag UFVerticalBox
---@field TextCD01 UFTextBlock
---@field TextConfigure UFTextBlock
---@field TextGetWay UFTextBlock
---@field TextHad UFTextBlock
---@field TextSkillName UFTextBlock
---@field TextUse UFTextBlock
---@field ToggleButtonCheck UToggleButton
---@field AnimChangeFilter UWidgetAnimation
---@field AnimChangeSkill UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboSkillPanelView = LuaClass(UIView, true)

function ChocoboSkillPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnConfigureSkill = nil
	--self.CheckAgain = nil
	--self.ChocoboSkill = nil
	--self.CommBackpackEmpty = nil
	--self.CommonBkg01_UIBP = nil
	--self.DropDown = nil
	--self.FImg_Box = nil
	--self.FImg_Check_1 = nil
	--self.HorizontalCD = nil
	--self.HorizontalUse = nil
	--self.PanelConfigure = nil
	--self.PanelGetWay = nil
	--self.PanelRight = nil
	--self.RichTextCD = nil
	--self.RichTextDetail02 = nil
	--self.RichTextUse = nil
	--self.ScrollBox_35 = nil
	--self.SingleBox = nil
	--self.TableViewLable = nil
	--self.TableViewSkill = nil
	--self.TableViewWayList = nil
	--self.Tag = nil
	--self.TextCD01 = nil
	--self.TextConfigure = nil
	--self.TextGetWay = nil
	--self.TextHad = nil
	--self.TextSkillName = nil
	--self.TextUse = nil
	--self.ToggleButtonCheck = nil
	--self.AnimChangeFilter = nil
	--self.AnimChangeSkill = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboSkillPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnConfigureSkill)
	self:AddSubView(self.ChocoboSkill)
	self:AddSubView(self.CommBackpackEmpty)
	self:AddSubView(self.CommonBkg01_UIBP)
	self:AddSubView(self.DropDown)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboSkillPanelView:OnInit()
    ChocoboMainVM = _G.ChocoboMainVM
    LSTR = _G.LSTR
    self.ShowSkillVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSkill, nil, nil)
    self.SkillTypeTagAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewLable, nil, nil)
    self.SkillGetWayAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewWayList, nil, nil)
    self.ShowSkillVMAdapter:SetOnSelectChangedCallback(self.OnSkillItemSelectChange)
end

function ChocoboSkillPanelView:OnDestroy()

end

function ChocoboSkillPanelView:OnShow()
    self:InitConstInfo()
    ChocoboMainVM:GetSkillPanelVM():InitSkillList()
    -- LSTR string: 全部技能类型
    local DropDownItems = { { Name = LSTR(420072) }, { Name = LSTR(420073) }, 
                            -- LSTR string: 稀有技能类型
                            { Name = LSTR(420074) }, { Name = LSTR(420075) }, { Name = LSTR(420076) } }
    self.DropDown:UpdateItems(DropDownItems, 1)

    if self.ViewModel.IsShowAll then
        self.ToggleButtonCheck:SetCheckedState(_G.UE.EToggleButtonState.Unchecked)
    else
        self.ToggleButtonCheck:SetCheckedState(_G.UE.EToggleButtonState.Checked)
    end
    self.ViewModel:FilterGroupVMByType(nil, nil)
    self.ShowSkillVMAdapter:SetSelectedIndex(1)
    UIUtil.SetIsVisible(self.ChocoboSkill.ImgSelect, false)
end

function ChocoboSkillPanelView:InitConstInfo()
    if self.IsInitConstInfo then
        return
    end

    self.IsInitConstInfo = true

    -- LSTR string: 已拥有
    self.TextHad:SetText(_G.LSTR(420022))
    -- LSTR string: 冷却：
    self.TextCD01:SetText(_G.LSTR(420024))
    -- LSTR string: 消耗：
    self.TextUse:SetText(_G.LSTR(420025))
    -- LSTR string: 主要获取方式
    self.TextGetWay:SetText(_G.LSTR(420055))
    -- LSTR string: 配置技能
    self.BtnConfigureSkill:SetText(_G.LSTR(420023))
    self.CommBackpackEmpty:SetTipsContent(LSTR(420166))
end

function ChocoboSkillPanelView:OnHide()

end

function ChocoboSkillPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnConfigureSkill, self.OnClickBtnConfigureSkill)
    UIUtil.AddOnSelectionChangedEvent(self, self.DropDown, self.OnSelectionChangedDropDownList)
    UIUtil.AddOnStateChangedEvent(self, self.ToggleButtonCheck, self.ToggleButtonCheckClick)
end

function ChocoboSkillPanelView:OnRegisterGameEvent()

end

function ChocoboSkillPanelView:OnRegisterBinder()
    self.ViewModel = ChocoboMainVM:GetSkillPanelVM()
    local Binders = {
        { "ShowSkillVMList", UIBinderUpdateBindableList.New(self, self.ShowSkillVMAdapter) },
        { "SkillTypeTagList", UIBinderUpdateBindableList.New(self, self.SkillTypeTagAdapter) },
        { "Name", UIBinderSetText.New(self, self.TextSkillName) },
        { "CD", UIBinderSetText.New(self, self.RichTextCD) },
        { "Cost", UIBinderSetText.New(self, self.RichTextUse) },
        { "Desc", UIBinderSetText.New(self, self.RichTextDetail02) },
        { "IsShowCost", UIBinderSetIsVisible.New(self, self.HorizontalUse) },
        { "IsShowCD", UIBinderSetIsVisible.New(self, self.HorizontalCD) },
        { "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ChocoboSkill.ImgIcon) },
        { "IsLock", UIBinderValueChangedCallback.New(self, nil, self.OnIsLockValueChanged) },
        { "ItemID", UIBinderValueChangedCallback.New(self, nil, self.OnItemIDValueChanged) },
        { "IsSkillVMListNotEmpty", UIBinderValueChangedCallback.New(self, nil, self.OnSkillVMListEmpty) },
    }
    self:RegisterBinders(self.ViewModel, Binders)
end

function ChocoboSkillPanelView:OnIsLockValueChanged(Value)
    UIUtil.SetIsVisible(self.ChocoboSkill.ImgMask, Value)
    UIUtil.SetIsVisible(self.PanelGetWay, Value)
    UIUtil.SetIsVisible(self.PanelConfigure, not Value)
    
    local Size = UIUtil.CanvasSlotGetSize(self.ScrollBox_35)
    if Value then
        UIUtil.CanvasSlotSetSize(self.ScrollBox_35, _G.UE.FVector2D(Size.X, 270))
    else
        UIUtil.CanvasSlotSetSize(self.ScrollBox_35, _G.UE.FVector2D(Size.X, 370))
    end
end

function ChocoboSkillPanelView:OnItemIDValueChanged(Value)
    if UIUtil.IsVisible(self.PanelGetWay) then
        local GetWayItems = ItemUtil.GetItemGetWayList(Value)
        if GetWayItems ~= nil then
            self.SkillGetWayAdapter:UpdateAll(GetWayItems)
        end
    end
end

function ChocoboSkillPanelView:OnSkillVMListEmpty(NewValue, OldValue)
    UIUtil.SetIsVisible(self.PanelRight, NewValue)
    UIUtil.SetIsVisible(self.CommBackpackEmpty, not NewValue)
end

function ChocoboSkillPanelView:OnSkillItemSelectChange(Index, ItemData, ItemView, IsByClick)
    self.ViewModel:ChangeSelectSkillID(ItemData.SkillID)
    self:PlayAnimation(self.AnimChangeSkill)
end

function ChocoboSkillPanelView:OnSelectionChangedDropDownList(Index)
    self.ViewModel:FilterGroupVMByType(nil, Index)
    self.ShowSkillVMAdapter:SetSelectedIndex(1)
    self:PlayAnimation(self.AnimChangeFilter)
end

function ChocoboSkillPanelView:ToggleButtonCheckClick(ToggleButton, ButtonState)
    local IsShowAll = ButtonState == _G.UE.EToggleButtonState.Unchecked
    self.ViewModel:FilterGroupVMByType(IsShowAll, nil)
    self.ShowSkillVMAdapter:SetSelectedIndex(1)
    self:PlayAnimation(self.AnimChangeFilter)
end

function ChocoboSkillPanelView:OnClickBtnConfigureSkill()
    UIViewMgr:ShowView(UIViewID.ChocoboSkillSideWinView, { ChocoboID = ChocoboMainVM.CurRaceEntryID })
end

return ChocoboSkillPanelView