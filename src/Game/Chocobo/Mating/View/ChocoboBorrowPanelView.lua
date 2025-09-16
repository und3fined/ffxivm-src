---
--- Author: Administrator
--- DateTime: 2024-01-02 12:36
--- Description: 陆行鸟租借
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local ScoreMgr = require("Game/Score/ScoreMgr")
local UIViewID = require("Define/UIViewID")
local UIDefine = require("Define/UIDefine")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local OVERVIEW_FILTER_TYPE = ChocoboDefine.OVERVIEW_FILTER_TYPE
local ChocoboMgr = nil
local ChocoboMainVM = nil
local ChocoboShowModelMgr = nil
local LSTR = nil
local MsgTipsUtil = nil
local ChocoboBorrowPanelVM = nil

---@class ChocoboBorrowPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bkg CommonBkg01View
---@field BorderSwitchBirdColor UBorder
---@field BtnAdd UFButton
---@field BtnBorrow CommBtnMView
---@field BtnBorrowed UFButton
---@field BtnChange CommBtnMView
---@field BtnClose CommonCloseBtnView
---@field BtnHelp CommInforBtnView
---@field BtnSub UFButton
---@field ChangePage ChocoboBorrowChangePageView
---@field CheckBoxFemale UToggleButton
---@field CheckBoxMale UToggleButton
---@field CommGesture_UIBP CommGestureView
---@field FImg_Box UFImage
---@field FImg_Box_1 UFImage
---@field FImg_Check UFImage
---@field FImg_Check_1 UFImage
---@field HorizontalChangePrice UFHorizontalBox
---@field HorizontalPrice UFHorizontalBox
---@field ImageRole UFImage
---@field ImgBorrowPrice UFImage
---@field ImgChangePrice UFImage
---@field ImgColor UFImage
---@field ImgGender UFImage
---@field LevelItem ChocoboLevelItemView
---@field MoneySlot CommMoneySlotView
---@field RadialProcess URadialImage
---@field TableViewSwitchStar UTableView
---@field TextBorrowedNum UFTextBlock
---@field TextBoxGeneration UEditableText
---@field TextChangePrice UFTextBlock
---@field TextColor UFTextBlock
---@field TextDetailTitle UFTextBlock
---@field TextGender UFTextBlock
---@field TextGeneration UFTextBlock
---@field TextName UFTextBlock
---@field TextPrice UFTextBlock
---@field TextStat UFTextBlock
---@field TextTitle UFTextBlock
---@field ToggleGroupCheck UToggleGroup
---@field AnimIn UWidgetAnimation
---@field AnimSwitchBird UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboBorrowPanelView = LuaClass(UIView, true)

function ChocoboBorrowPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bkg = nil
	--self.BorderSwitchBirdColor = nil
	--self.BtnAdd = nil
	--self.BtnBorrow = nil
	--self.BtnBorrowed = nil
	--self.BtnChange = nil
	--self.BtnClose = nil
	--self.BtnHelp = nil
	--self.BtnSub = nil
	--self.ChangePage = nil
	--self.CheckBoxFemale = nil
	--self.CheckBoxMale = nil
	--self.CommGesture_UIBP = nil
	--self.FImg_Box = nil
	--self.FImg_Box_1 = nil
	--self.FImg_Check = nil
	--self.FImg_Check_1 = nil
	--self.HorizontalChangePrice = nil
	--self.HorizontalPrice = nil
	--self.ImageRole = nil
	--self.ImgBorrowPrice = nil
	--self.ImgChangePrice = nil
	--self.ImgColor = nil
	--self.ImgGender = nil
	--self.LevelItem = nil
	--self.MoneySlot = nil
	--self.RadialProcess = nil
	--self.TableViewSwitchStar = nil
	--self.TextBorrowedNum = nil
	--self.TextBoxGeneration = nil
	--self.TextChangePrice = nil
	--self.TextColor = nil
	--self.TextDetailTitle = nil
	--self.TextGender = nil
	--self.TextGeneration = nil
	--self.TextName = nil
	--self.TextPrice = nil
	--self.TextStat = nil
	--self.TextTitle = nil
	--self.ToggleGroupCheck = nil
	--self.AnimIn = nil
	--self.AnimSwitchBird = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboBorrowPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bkg)
	self:AddSubView(self.BtnBorrow)
	self:AddSubView(self.BtnChange)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnHelp)
	self:AddSubView(self.ChangePage)
	self:AddSubView(self.CommGesture_UIBP)
	self:AddSubView(self.LevelItem)
	self:AddSubView(self.MoneySlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboBorrowPanelView:OnInit()
    ChocoboMgr = _G.ChocoboMgr
    ChocoboMainVM = _G.ChocoboMainVM
    ChocoboShowModelMgr = _G.ChocoboShowModelMgr
    LSTR = _G.LSTR
    MsgTipsUtil = _G.MsgTipsUtil
    ChocoboBorrowPanelVM = _G.ChocoboBorrowPanelVM

    self.ChocoboTableView = UIAdapterTableView.CreateAdapter(self, self.ChangePage.TableViewChocobo, nil, true)
    self.ChocoboTableView:SetScrollbarIsVisible(false)
    self.InfoPageStarTable = UIAdapterTableView.CreateAdapter(self, self.TableViewSwitchStar, nil, nil)
end

function ChocoboBorrowPanelView:OnDestroy()

end

function ChocoboBorrowPanelView:OnShow()
    self:InitConstInfo()
    UIUtil.SetIsVisible(self.ChangePage, false)
    local Icon = ScoreMgr:GetScoreIconName(SCORE_TYPE.SCORE_TYPE_KING_DEE)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgChangePrice, Icon)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgBorrowPrice, Icon)
    self.MoneySlot:UpdateView(SCORE_TYPE.SCORE_TYPE_KING_DEE, false, nil, true)

    self.ToggleGroupCheck:SetCheckedIndex(0, true)
    self.TextBoxGeneration:SetText(1)

    self:ShowChocoboModelActor()
    ChocoboBorrowPanelVM:SetGender(0)
    ChocoboBorrowPanelVM:SetGeneration(1)
    ChocoboMgr:RentInfoReq(0, 1)
    _G.LightMgr:EnableUIWeather(ChocoboDefine.ChocoboBorrowLightID)
end

function ChocoboBorrowPanelView:InitConstInfo()
    if self.IsInitConstInfo then
        return
    end

    self.IsInitConstInfo = true

    -- LSTR string: 陆行鸟配种租借
    self.TextTitle:SetText(_G.LSTR(420035))
    -- LSTR string: 陆行鸟特质预期
    self.TextDetailTitle:SetText(_G.LSTR(420036))
    -- LSTR string: 性别
    self.TextGender:SetText(_G.LSTR(420037))
    -- LSTR string: 血统代数
    self.TextGeneration:SetText(_G.LSTR(420038))
    -- LSTR string: 属性星级
    self.TextStat:SetText(_G.LSTR(420039))
    -- LSTR string: 换一只
    self.BtnChange:SetText(_G.LSTR(420040))
end

function ChocoboBorrowPanelView:OnHide()
    _G.LightMgr:DisableUIWeather()
    local bHideModel = true
    if self.Params ~= nil and self.Params.FromViewID ~= nil then
        if self.Params.FromViewID == UIViewID.ChocoboMainPanelView then
            -- 交互打开界面，关闭后不会清理掉InteractiveMgr.CurrentFunctionViewID，会有问题, 临时这样处理一下
            if _G.InteractiveMgr.CurrentFunctionViewID == UIViewID.ChocoboBorrowPanelView then
                _G.InteractiveMgr:ClearFunctionViewID()
            end

            bHideModel = false
        end
    end

    if bHideModel then
        ChocoboShowModelMgr:OnHide()
    end
end

function ChocoboBorrowPanelView:OnRegisterUIEvent()
    self.ChangePage.CommSidebarFrameS_UIBP.BtnClose:SetCallback(self, self.OnClickBtnClose)
    UIUtil.AddOnSelectionChangedEvent(self, self.ChangePage.DropDownSort, self.OnSelectionChangedSortList)
    UIUtil.AddOnClickedEvent(self, self.ChangePage.BtnRandom, self.OnClickBtnRandom)

    UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupCheck, self.OnToggleGroupCheckChanged)
    UIUtil.AddOnFocusLostEvent(self, self.TextBoxGeneration, self.OnTextChangedGeneration)
    UIUtil.AddOnClickedEvent(self, self.BtnSub, self.OnClickBtnSub)
    UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnClickBtnAdd)

    UIUtil.AddOnClickedEvent(self, self.BtnBorrow.Button, self.OnClickBtnBorrow)
    UIUtil.AddOnClickedEvent(self, self.BtnChange, self.OnClickBtnChange)
    UIUtil.AddOnClickedEvent(self, self.BtnBorrowed, self.OnClickBtnBorrowed)
end

function ChocoboBorrowPanelView:OnRegisterGameEvent()
    
end

function ChocoboBorrowPanelView:OnRegisterBinder()
    self.Binders = {
        { "CanBtnSub", UIBinderSetIsEnabled.New(self, self.BtnSub, false, true) },
        { "CanBtnAdd", UIBinderSetIsEnabled.New(self, self.BtnAdd, false, true) },
        
        { "CanRefresh", UIBinderValueChangedCallback.New(self, nil, self.OnCanRefreshChange) },
        { "CanBorrow", UIBinderValueChangedCallback.New(self, nil, self.OnCanBorrowChange) },
        
        { "RentCostText", UIBinderSetText.New(self, self.TextPrice) },
        { "RentCostTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextPrice) },
        { "BtnBorrowText", UIBinderSetText.New(self, self.BtnBorrow) },
        { "RefreshCostText", UIBinderSetText.New(self, self.TextChangePrice) },
        
        { "TextLevel", UIBinderSetText.New(self, self.LevelItem.TextLevel) },
        { "TextName", UIBinderSetText.New(self, self.TextName) },
        { "TextColor", UIBinderSetText.New(self, self.TextColor) },
        { "Color", UIBinderSetColorAndOpacity.New(self, self.ImgColor) },
        { "GenderPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgGender) },

        { "RadialProcess", UIBinderSetPercent.New(self, self.RadialProcess) },
        { "TextBorrowedNum", UIBinderSetText.New(self, self.TextBorrowedNum) },

        { "AttrVMList", UIBinderUpdateBindableList.New(self, self.InfoPageStarTable) },
        { "StainID", UIBinderValueChangedCallback.New(self, nil, self.OnBorrowStainIDChanged) },
    }

    self.BorrowedBinders = {
        { "BorrowedChocoboVMList", UIBinderUpdateBindableList.New(self, self.ChocoboTableView) },
    }

    if ChocoboBorrowPanelVM ~= nil then
        self:RegisterBinders(ChocoboBorrowPanelVM, self.Binders)
    end

    if ChocoboMainVM ~= nil then
        self:RegisterBinders(ChocoboMainVM, self.BorrowedBinders)
    end
end

function ChocoboBorrowPanelView:ShowChocoboModelActor()
    local CallBack = function(View)
        ChocoboShowModelMgr:ShowMajor(false)
        ChocoboShowModelMgr:ResetChocoboModelScale()
        ChocoboShowModelMgr:SetModelDefaultPos()
        ChocoboShowModelMgr:SetChocoboArmorByPos(0, 0, 0)
        ChocoboShowModelMgr:SetChocoboColor(ChocoboBorrowPanelVM.StainID)
        ChocoboShowModelMgr:UpdateUIChocoboModel()
        ChocoboShowModelMgr:EnableRotator(true)
        ChocoboShowModelMgr:BindCommGesture(View.CommGesture_UIBP)
    end

    ChocoboShowModelMgr:SetUIType(ProtoRes.CHOCOBO_MODE_SHOW_UI_TYPE.CHOCOBO_MODE_SHOW_UITYPE_BORROW)
    ChocoboShowModelMgr:SetImageRole(self.ImageRole)
    if ChocoboShowModelMgr:IsCreateFinish() then
        CallBack(self)
    else
        ChocoboShowModelMgr:CreateModel(self, CallBack)
        ChocoboShowModelMgr:ShowMajor(false)
    end
end

function ChocoboBorrowPanelView:OnBorrowStainIDChanged(NewValue, OldValue)
    if not NewValue then
        return
    end

    if ChocoboShowModelMgr:IsCreateFinish() then
        ChocoboShowModelMgr:SetChocoboColor(NewValue)
        ChocoboShowModelMgr:UpdateUIChocoboModel()
    end
end

function ChocoboBorrowPanelView:OnToggleGroupCheckChanged(ToggleGroup, ToggleButton, Index, State)
    if UIUtil.IsToggleButtonChecked(State) then
        ChocoboBorrowPanelVM:SetGender(Index)
    end
end

function ChocoboBorrowPanelView:OnTextChangedGeneration()
    local RawText = self.TextBoxGeneration:GetText()
    local CleanText = RawText:gsub("[^%d]", ""):gsub("^%s*(.-)%s*$", "%1")

    if CleanText == "" then
        self.TextBoxGeneration:SetText(tostring(ChocoboBorrowPanelVM.Generation))
        return
    end

    local NewGen = tonumber(CleanText)
    NewGen = math.clamp(NewGen or ChocoboBorrowPanelVM.Generation, 1, ChocoboDefine.GENERATION_MAX)

    if NewGen == ChocoboBorrowPanelVM.Generation then
        self.TextBoxGeneration:SetText(tostring(NewGen))
        return
    end

    ChocoboBorrowPanelVM:SetGeneration(NewGen)

    if tostring(NewGen) ~= CleanText then
        self.TextBoxGeneration:SetText(tostring(NewGen))
    end
end

function ChocoboBorrowPanelView:OnClickBtnSub()
    local CurrentGen = ChocoboBorrowPanelVM.Generation
    local NewGen = math.max(CurrentGen - 1, 1)
    ChocoboBorrowPanelVM:SetGeneration(NewGen)
    self.TextBoxGeneration:SetText(tostring(NewGen))
end

function ChocoboBorrowPanelView:OnClickBtnAdd()
    local CurrentGen = ChocoboBorrowPanelVM.Generation
    local NewGen = math.min(CurrentGen + 1, ChocoboDefine.GENERATION_MAX)
    ChocoboBorrowPanelVM:SetGeneration(NewGen)
    self.TextBoxGeneration:SetText(tostring(NewGen))
end

function ChocoboBorrowPanelView:OnClickBtnBorrow()
    local ScoreValue = ScoreMgr:GetScoreValueByID(SCORE_TYPE.SCORE_TYPE_KING_DEE)
    if ScoreValue < ChocoboBorrowPanelVM.RentCost then
        -- LSTR string: 你拥有的金碟币不足，无法租借！
        local strContent = LSTR(420143)
        MsgTipsUtil.ShowTips(strContent)
        return
    end

    if not ChocoboBorrowPanelVM.CanBorrow then
        local Count = _G.ChocoboMainVM:GetBorrowCount()
        if Count >= ChocoboMgr.RentLimit then
            -- LSTR string: 租借陆行鸟数量已达上限！
            local strContent = LSTR(420142)
            MsgTipsUtil.ShowTips(strContent)
            return
        end
    else
        local function Callback()
            ChocoboMgr:ReqRent(1, ChocoboBorrowPanelVM.CurChocoboID, ChocoboBorrowPanelVM.Gender, ChocoboBorrowPanelVM.Generation)
        end

        local Params = { CostItemID = SCORE_TYPE.SCORE_TYPE_KING_DEE, CostNum = ChocoboBorrowPanelVM.RentCost }
        -- LSTR string: 确定要租借陆行鸟吗？
        local MsgContent = LSTR(420144)
        -- LSTR string: 陆行鸟配种租借
        _G.MsgBoxUtil.ShowMsgBoxTwoOp(nil, LSTR(420035), MsgContent, Callback, nil, LSTR(10003), LSTR(10002), Params)  --租借陆行鸟
    end
end

function ChocoboBorrowPanelView:OnClickBtnChange()
    local ScoreValue = ScoreMgr:GetScoreValueByID(SCORE_TYPE.SCORE_TYPE_KING_DEE)
    if ScoreValue < ChocoboBorrowPanelVM.RefreshCost then
        -- LSTR string: 你拥有的金碟币不足，无法更换！
        MsgTipsUtil.ShowTips(LSTR(420145))
        return
    end

    ChocoboMgr:RentRefreshReq(ChocoboBorrowPanelVM.Gender, ChocoboBorrowPanelVM.Generation)
end

function ChocoboBorrowPanelView:OnClickBtnBorrowed()
    if not UIUtil.IsVisible(self.ChangePage) then
        UIUtil.SetIsVisible(self.ChangePage, true)

        local Types = ChocoboDefine.OVERVIEW_FILTER_TYPE
        local FilterTypes = { Types.STAR, Types.MAX_SPEED, Types.SPRINT_SPEED, Types.ACCELERATION, Types.STAMINA, Types.SKILL_STRENGTH }
        local FilterTypeList = {}
        for Index, FilterType in ipairs(FilterTypes) do
            FilterTypeList[Index] = {}
            FilterTypeList[Index].Name = ChocoboDefine.OVERVIEW_FILTER_TYPE_NAME[FilterType]
        end
        self.ChangePage.DropDownSort:UpdateItems(FilterTypeList, 1)
        ChocoboMainVM:InitBorrowChocoboList()
    end
end

function ChocoboBorrowPanelView:OnCanRefreshChange(NewValue, OldValue)
    if NewValue then
        self.BtnChange:SetIsNormalState(true)
    else
        self.BtnChange:SetIsDisabledState(true, true)
    end
end

function ChocoboBorrowPanelView:OnCanBorrowChange(NewValue, OldValue)
    if NewValue then
        self.BtnBorrow:SetIsNormalState(true)
    else
        self.BtnBorrow:SetIsDisabledState(true, true)
    end
end

function ChocoboBorrowPanelView:OnSelectionChangedSortList(Index)
    local FilterType = { OVERVIEW_FILTER_TYPE.STAR, OVERVIEW_FILTER_TYPE.MAX_SPEED, OVERVIEW_FILTER_TYPE.SPRINT_SPEED,
                         OVERVIEW_FILTER_TYPE.ACCELERATION, OVERVIEW_FILTER_TYPE.STAMINA, OVERVIEW_FILTER_TYPE.SKILL_STRENGTH }
    self.ChangePage:PlayAnimRefresh()
    ChocoboMainVM:SetCurRentFilterType(FilterType[Index])
end

function ChocoboBorrowPanelView:OnClickBtnRandom()
    self.ChangePage:PlayAnimRefresh()
    ChocoboMainVM:RefreshRentByFilter()
end

function ChocoboBorrowPanelView:OnClickBtnClose()
    if UIUtil.IsVisible(self.ChangePage) then
        UIUtil.SetIsVisible(self.ChangePage, false)
    end
end

function ChocoboBorrowPanelView:PlayAnimSwitchBird()
    self:PlayAnimation(self.AnimSwitchBird)
end

return ChocoboBorrowPanelView