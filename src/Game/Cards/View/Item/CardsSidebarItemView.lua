---
--- Author: MichaelYang_LightPaw
--- DateTime: 2023-11-10 20:26
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class CardsSidebarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDefault CommBtnSView
---@field BtnEdit CommBtnSView
---@field BtnUse CommBtnSView
---@field ImgSelect UFImage
---@field ImgWarning UFImage
---@field ImgYes UFImage
---@field PanelFold UFCanvasPanel
---@field PanelFoldContent UFCanvasPanel
---@field PanelIcon UFCanvasPanel
---@field PanelUnfold UFCanvasPanel
---@field TableViewCardList UTableView
---@field TableViewFold UTableView
---@field TextFoldName UFTextBlock
---@field TextUnfoldName UFTextBlock
---@field AnimAotoCard UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsSidebarItemView = LuaClass(UIView, true)

function CardsSidebarItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnClick = nil
    -- self.BtnDefault = nil
    -- self.BtnEdit = nil
    -- self.BtnUse = nil
    -- self.ImgSelect = nil
    -- self.ImgWarning = nil
    -- self.ImgYes = nil
    -- self.PanelBtn = nil
    -- self.PanelFold = nil
    -- self.PanelFoldContent = nil
    -- self.PanelIcon = nil
    -- self.PanelUnfold = nil
    -- self.TableViewFold = nil
    -- self.TableViewUnfold = nil
    -- self.TextFoldName = nil
    -- self.TextUnfoldName = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsSidebarItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnDefault)
    self:AddSubView(self.BtnEdit)
    self:AddSubView(self.BtnUse)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsSidebarItemView:OnInit()
    UIUtil.SetIsVisible(self.PanelUnfold, false)
    UIUtil.SetIsVisible(self.PanelFold, true)
    UIUtil.SetIsVisible(self.ImgSelect, false)

    self.TableViewCardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCardList, nil, true)
    self.TableViewFoldAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewFold, nil, true)
    local Binders = {
        {
            "GroupCardList",
            UIBinderUpdateBindableList.New(self, self.TableViewCardListAdapter)
        },
        {
            "GroupCardList",
            UIBinderUpdateBindableList.New(self, self.TableViewFoldAdapter)
        },
        {
            "IsCurrentSelect",
            UIBinderValueChangedCallback.New(self, nil, self.OnIsCurrentSelectChange)
        },
        {
            "IsAutoGroup",
            UIBinderValueChangedCallback.New(self, nil, self.OnIsAutoGroupChange)
        },
        {
            "IsAllRulePass",
            UIBinderValueChangedCallback.New(self, nil, self.OnIsAllRulePassChange)
        },
        {
            "IsDefaultGroup",
            UIBinderValueChangedCallback.New(self, nil, self.OnIsDefaultGroupChange)
        },
        {
            "GroupName",
            UIBinderSetText.New(self, self.TextUnfoldName)
        },
        {
            "GroupName",
            UIBinderSetText.New(self, self.TextFoldName)
        }
    }
    self.Binders = Binders
end

function CardsSidebarItemView:OnIsAllRulePassChange(NewValue, OldValue)
    if (not self.ViewModel.IsAllRulePass) then
        UIUtil.SetIsVisible(self.ImgWarning, true)
    else
        UIUtil.SetIsVisible(self.ImgWarning, false)
    end
    self:CheckAllBtnStatus()
end

function CardsSidebarItemView:CheckAllBtnStatus()
    local _canSetUse = self.ViewModel.IsAllRulePass and not self.ViewModel.IsDefaultGroup
    if (_canSetUse) then
        self.BtnUse:SetIsNormal(true)
        self.BtnUse:SetIsEnabled(true, true)
        self.BtnDefault:SetIsNormal(true)
        self.BtnDefault:SetIsEnabled(true, true)
    else
        self.BtnUse:SetIsNormal(false)
        self.BtnUse:SetIsEnabled(false, false)
        self.BtnDefault:SetIsNormal(false)
        self.BtnDefault:SetIsEnabled(false, false)
    end
end

function CardsSidebarItemView:OnIsDefaultGroupChange(NewValue, OldValue)
    if (NewValue) then
        UIUtil.SetIsVisible(self.ImgYes, true)
    else
        UIUtil.SetIsVisible(self.ImgYes, false)
    end

    self:CheckAllBtnStatus()
end

-- 是否为自动组卡
function CardsSidebarItemView:OnIsAutoGroupChange(NewValue, OldValue)
    if (NewValue) then
        if(self.ViewModel.ShouldPlayAnimAutoCard) then
            self.ViewModel.ShouldPlayAnimAutoCard = false
            self:PlayAnimation(self.AnimAotoCard)
        end
        UIUtil.SetIsVisible(self.BtnEdit, false)
        UIUtil.SetIsVisible(self.BtnDefault, false)
        UIUtil.SetIsVisible(self.BtnUse, true)
    else
        UIUtil.SetIsVisible(self.BtnEdit, true)
        UIUtil.SetIsVisible(self.BtnDefault, true)
        UIUtil.SetIsVisible(self.BtnUse, false)
    end

    self:CheckAllBtnStatus()
end

function CardsSidebarItemView:OnIsCurrentSelectChange(NewValue, OldValue)
    if (NewValue) then
        UIUtil.SetIsVisible(self.PanelUnfold, true)
        UIUtil.SetIsVisible(self.PanelFold, false)
        UIUtil.SetIsVisible(self.ImgSelect, true)
    else
        UIUtil.SetIsVisible(self.PanelUnfold, false)
        UIUtil.SetIsVisible(self.PanelFold, true)
        UIUtil.SetIsVisible(self.ImgSelect, false)
    end
end

function CardsSidebarItemView:OnDestroy()

end

function CardsSidebarItemView:SetLSTR()
    self.BtnDefault.TextContent:SetText(_G.LSTR(1130090))--("设为默认")
    self.BtnUse.TextContent:SetText(_G.LSTR(1130088))--("使  用")
    self.BtnEdit.TextContent:SetText(_G.LSTR(1130089))--("编辑卡组")
end

function CardsSidebarItemView:OnShow()
    self:SetLSTR()
end

function CardsSidebarItemView:OnHide()

end

function CardsSidebarItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnUse, self.OnClickBtnUse)
    UIUtil.AddOnClickedEvent(self, self.BtnDefault, self.OnClickBtnDefault)
    UIUtil.AddOnClickedEvent(self, self.BtnEdit, self.OnClickBtnEdit)
end

function CardsSidebarItemView:OnClickBtnUse()
    self:SetUse()
end

function CardsSidebarItemView:SetUse()
    local _isAllOk = self.ViewModel.IsAllRulePass
    if (not _isAllOk) then
        -- 这里弹出提示，编组没有OK的，就直接掠过
        return
    end

    self.ViewModel:SetCurrentSelectItemDefault()
end

function CardsSidebarItemView:OnClickBtnDefault()
    self:SetUse()
end

function CardsSidebarItemView:OnClickBtnEdit()
    if (self.ViewModel.IsAutoGroup) then
        -- 弹出提示，自动组卡的不支持编辑
        return
    end

    -- 这里去打开一下，传入的参数要带当前选择的编辑卡组信息
    _G.UIViewMgr:ShowView(
        _G.UIViewID.MagicCardEditPanel, {
            Data = self.ViewModel
        }
    )
end

function CardsSidebarItemView:OnRegisterGameEvent()

end

---@self.ViewModel CardsGroupCardVM
function CardsSidebarItemView:OnRegisterBinder()
    self.ViewModel = self.Params.Data
    if (self.ViewModel == nil) then
        _G.FLOG_ERROR("ViewModel is nil , please check!")
        return
    end
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return CardsSidebarItemView
