---
--- Author: daniel
--- DateTime: 2023-03-16 09:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local GroupMemberCategoryCfg = require("TableCfg/GroupMemberCategoryCfg")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local ArmyMgr = require("Game/Army/ArmyMgr")
local RichTextUtil = require("Utils/RichTextUtil")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyTextColor = ArmyDefine.ArmyTextColor
local LSTR = _G.LSTR

---@class ArmyMemberEditClassItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAddClass UFButton
---@field BtnClose UFButton
---@field BtnDelete UFButton
---@field BtnDown UFButton
---@field BtnEdit UFButton
---@field BtnPreview UFButton
---@field BtnSetting UFButton
---@field BtnUP UFButton
---@field HorizontalOpenBtn UFHorizontalBox
---@field ImgAddBG UFImage
---@field ImgClassIcon UFImage
---@field PanelAdd UFCanvasPanel
---@field TextClassName UFTextBlock
---@field TextClassNum UFTextBlock
---@field ToggleBtn UToggleButton
---@field AnimBtnFold UWidgetAnimation
---@field AnimBtnUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberEditClassItemView = LuaClass(UIView, true)

function ArmyMemberEditClassItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAddClass = nil
	--self.BtnClose = nil
	--self.BtnDelete = nil
	--self.BtnDown = nil
	--self.BtnEdit = nil
	--self.BtnPreview = nil
	--self.BtnSetting = nil
	--self.BtnUP = nil
	--self.HorizontalOpenBtn = nil
	--self.ImgAddBG = nil
	--self.ImgClassIcon = nil
	--self.PanelAdd = nil
	--self.TextClassName = nil
	--self.TextClassNum = nil
	--self.ToggleBtn = nil
	--self.AnimBtnFold = nil
	--self.AnimBtnUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
    self.ViewModel = nil
end

function ArmyMemberEditClassItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberEditClassItemView:OnInit()
    self.bShow = false
    self.Binders = {
        {"Name", UIBinderSetText.New(self, self.TextClassName)},
        {"Num", UIBinderSetText.New(self, self.TextClassNum)},
        {"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgClassIcon)},
        {"bIcon", UIBinderSetIsVisible.New(self, self.ImgClassIcon)},
        {"bBtnPreview", UIBinderSetIsVisible.New(self, self.BtnPreview, false, true)},
        {"bBtnEdit", UIBinderSetIsVisible.New(self, self.BtnEdit, false, true)},
        {"bBtnSetting", UIBinderSetIsVisible.New(self, self.BtnSetting, false, true)},
        {"bBtnClose", UIBinderSetIsVisible.New(self, self.BtnClose, false, true)},
        {"bBtnDelete", UIBinderSetIsVisible.New(self, self.BtnDelete, false, true)},
        {"bBtnUp", UIBinderSetIsVisible.New(self, self.BtnUP, false, true)},
        {"bBtnDown", UIBinderSetIsVisible.New(self, self.BtnDown, false, true)},
        {"bEmpty", UIBinderValueChangedCallback.New(self, nil, self.OnStateChanged)},
    }
end

function ArmyMemberEditClassItemView:OnDestroy()
end

function ArmyMemberEditClassItemView:OnShow()
    UIUtil.SetIsVisible(self.HorizontalOpenBtn, false)
    local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
    ---onshow的时候重置一下动画状态
    if self.ViewModel.bBtnSetting then
        self:AnimInit()
    end
end

function ArmyMemberEditClassItemView:AnimInit()
    UIUtil.PlayAnimationTimePointPct(self, self.AnimBtnFold, 1, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, false)
end


function ArmyMemberEditClassItemView:SetButtonVisible(Visible)
    if Visible then
        self:PlayAnimation(self.AnimBtnUnfold)
    else
        self:PlayAnimation(self.AnimBtnFold)
    end
    UIUtil.SetIsVisible(self.HorizontalOpenBtn, Visible)
    UIUtil.SetIsVisible(self.BtnSetting, not Visible, true)
    UIUtil.SetIsVisible(self.BtnClose, Visible, true)
end

function ArmyMemberEditClassItemView:OnHide()
end

function ArmyMemberEditClassItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnClickedItem)
    UIUtil.AddOnClickedEvent(self, self.BtnEdit, self.OnClickedEditName)
    UIUtil.AddOnClickedEvent(self, self.BtnPreview, self.OnClickUpdatePreview)
    UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnClickedDelectCategory)
    UIUtil.AddOnClickedEvent(self, self.BtnSetting, self.OnClickedSetting)
    UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnClickedHideButton)
    UIUtil.AddOnClickedEvent(self, self.BtnUP, self.OnClickedUpChanged)
    UIUtil.AddOnClickedEvent(self, self.BtnDown, self.OnClickedDownChanged)
    UIUtil.AddOnClickedEvent(self, self.BtnAddClass, self.OnClickedAddClass)
end

function ArmyMemberEditClassItemView:OnRegisterGameEvent()
end

function ArmyMemberEditClassItemView:OnRegisterBinder()
    local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function ArmyMemberEditClassItemView:OnClickedItem()
    self.ToggleBtn:SetIsChecked(false, true)
    -- if self.ViewModel.ID == 0 then
    --     local Params = self.Params
    --     if nil == Params then
    --         return
    --     end
    --     local Adapter = Params.Adapter
    --     if nil == Adapter then
    --         return
    --     end
    --     Adapter:OnItemClicked(self, Params.Index)
    -- end
end

function ArmyMemberEditClassItemView:OnClickedAddClass()
    if self.ViewModel.ID == -1 then
        local Params = self.Params
        if nil == Params then
            return
        end
        local Adapter = Params.Adapter
        if nil == Adapter then
            return
        end
        Adapter:OnItemClicked(self, Params.Index)
    end
end

--- 编辑名称
function ArmyMemberEditClassItemView:OnClickedEditName()
    local PopInputParams = {
        -- LSTR string:分组名称修改
        Title = LSTR(910062),
        -- LSTR string:请输入新的分组名称
        HintText = LSTR(910229),
        MaxTextLength = 5,
        Content = self.TextClassName:GetText(),
        SureCallback = function(Name)
            if Name == "" then
                return
            end
            if Name ~= self.ViewModel.Name then
                ArmyMgr:SendArmyEditCategoryNameMsg(self.ViewModel.ID, Name)
			else
				-- LSTR string:该分组名称已存在
				_G.MsgTipsUtil.ShowTips(LSTR(910220))
			end
        end
    }
    _G.UIViewMgr:ShowView(_G.UIViewID.ArmyEditClassNamePanel, PopInputParams)
end

--- 编辑权限Icon
function ArmyMemberEditClassItemView:OnClickUpdatePreview()
    -- local ViewModel = self.ViewModel
    -- _G.UIViewMgr:ShowView(_G.UIViewID.ArmyEditCategoryIconPanel, {
    --     ID = ViewModel.ID,
    --     IconID = ViewModel.IconID,
    --     Callback = function(IconID)
    --         if IconID ~= ViewModel.IconID then
    --             local IconData =  GroupMemberCategoryCfg:GetCategoryIconByID(IconID)
    --             if IconData ~= nil then
    --                 ArmyMgr:SendArmyEditCategoryIconMsg(ViewModel.ID, IconID)
    --             else
    -- LSTR string:该图标不存在, 表未配置此图标
    --                 _G.MsgTipsUtil.ShowTips(LSTR(910221))
    --             end
    --         end
    --     end
    -- })

        local SelectedID = 1
		local IconData = {}
		local IconIDs = ArmyMgr:GetCategoryIconIDs()
		local CategoryIcons = GroupMemberCategoryCfg:GetAllCategoryCfg()
		for _, Data in ipairs(CategoryIcons) do
		    local IsEnabled = not table.contain(IconIDs, Data.ID)
			table.insert(IconData, {
			ID = Data.ID,
			IsSelected = SelectedID == Data.ID,
			Icon = Data.Icon,
			IsEnabled = IsEnabled
			})
		end

        local ViewModel = self.ViewModel
		local Params = {}
		Params.Data = IconData
		Params.SelectedIndex = ViewModel.IconID
		Params.ClickItemCallback = self.SelectedIcon
        Params.View = self
		TipsUtil.ShowIconListTips(Params, self.BtnPreview, _G.UE.FVector2D(-20, 0), _G.UE.FVector2D(1, 0), false)
end

function ArmyMemberEditClassItemView:SelectedIcon(Index, ItemData, ItemView)
    local ViewModel = self.ViewModel
    local IconID = ItemData.ID
    if IconID ~= ViewModel.IconID then
        if ItemData.IsEnabled then
            local IconData =  GroupMemberCategoryCfg:GetCategoryIconByID(IconID)
            if IconData ~= nil then
                ---改图标会刷新view和vm,先隐藏
                UIViewMgr:HideView(UIViewID.CommJumpWayIconTipsView)
                ArmyMgr:SendArmyEditCategoryIconMsg(ViewModel.ID, IconID)
            else
                -- LSTR string:该图标不存在, 表未配置此图标
                _G.MsgTipsUtil.ShowTips(LSTR(910221))
            end
        else
            -- LSTR string:该图标已被使用
            _G.MsgTipsUtil.ShowTips(LSTR(910222))
        end
    end
end

--- 删除分组
function ArmyMemberEditClassItemView:OnClickedDelectCategory()
    local SIndex = self.ViewModel.ShowIndex + 1
    local RichName = RichTextUtil.GetText(self.ViewModel.Name,  ArmyTextColor.BlueHex)
    local Message = string.format(_G.LSTR('确认删除分组%s %s 吗?'), SIndex, RichName)
    _G.MsgBoxUtil.ShowMsgBoxTwoOp(
        self,
        -- LSTR string:提示
        _G.LSTR(910144),
        Message,
        function()
			ArmyMgr:SendArmyDelCategoryMsg(self.ViewModel.ID)
        end,
		nil
    )
end

--- 上移
function ArmyMemberEditClassItemView:OnClickedUpChanged()
    ArmyMgr:SendEditClassSIndexMsg(self.ViewModel.ID, self.ViewModel.ShowIndex - 1)
end

--- 下移
function ArmyMemberEditClassItemView:OnClickedDownChanged()
    ArmyMgr:SendEditClassSIndexMsg(self.ViewModel.ID, self.ViewModel.ShowIndex + 1)
end

--- 设置
function ArmyMemberEditClassItemView:OnClickedSetting()
    self.bShow = true
    self:SetButtonVisible(self.bShow)
end

function ArmyMemberEditClassItemView:OnClickedHideButton()
    self.bShow = false
    self:SetButtonVisible(self.bShow)
end

function ArmyMemberEditClassItemView:OnStateChanged(IsEmpty)
	UIUtil.SetIsVisible(self.PanelAdd, IsEmpty)
    UIUtil.SetIsVisible(self.ToggleBtn, not IsEmpty, true)
end

return ArmyMemberEditClassItemView
