---
--- Author: daniel
--- DateTime: 2023-03-08 09:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgBoxUtil = _G.MsgBoxUtil
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local LSTR = _G.LSTR
local RichTextUtil = require("Utils/RichTextUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local PersonInfoMgr = require("Game/PersonInfo/PersonInfoMgr")

local MajorUtil = require("Utils/MajorUtil")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyTextColor = ArmyDefine.ArmyTextColor
local ProtoRes = require("Protocol/ProtoRes")
local GlobalCfgType = ArmyDefine.GlobalCfgType
local CategoryUIType = ArmyDefine.CategoryUIType
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyMgr = require("Game/Army/ArmyMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local ArmyMemberPanelVM = nil
local ArmyMemberPageVM = nil

---@class ArmyMemberPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelMember UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberPageView = LuaClass(UIView, true)

function ArmyMemberPageView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelMember = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

local SelectedMemberVM = nil

function ArmyMemberPageView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberPageView:OnInit()
    self.MemberListView = nil
    self.MemberAskForView = nil
    self.MemberCategoryView = nil
    ArmyMemberPanelVM = ArmyMainVM:GetMemberPanelVM()
    ArmyMemberPageVM = ArmyMemberPanelVM:GetArmyMemberPageVM()
    self.Binders = {
        { "bApplyPanel", UIBinderValueChangedCallback.New(self, nil, self.OnbApplyPanelChanged) },
        { "bMemberPanel", UIBinderValueChangedCallback.New(self, nil, self.OnbMemberPanelChanged) },
        { "bCategoryPanel", UIBinderValueChangedCallback.New(self, nil, self.OnbCategoryPanelChanged) },
    }
end

function ArmyMemberPageView:OnbMemberPanelChanged(bMemberPanel)
    if bMemberPanel then
        self:ShowMemberList()
        if self.MemberListView then
            self.MemberListView:SetOwner(self)
            self.MemberListView:SetExitCallBack(self.OnClickedQuitArmy)
            self.MemberListView:SetSelectMemberCallBack(self.OnClickedSelectMemberItem)
            self.MemberListView:PlayAnimation(self.MemberListView.AnimShowPanel)
        end
    else
        self:HideMemberSubView( self.MemberListView)
        self.MemberListView = nil
    end
end

function ArmyMemberPageView:ShowMemberList()
    if self.MemberListView == nil then
        self.MemberListView = UIViewMgr:CreateViewByName("Army/ArmyMemberListPage_UIBP", nil, self, true, true)
        if self.MemberListView then
            self.PanelMember:AddChildToCanvas(self.MemberListView)
            local Anchor = _G.UE.FAnchors()
            Anchor.Minimum = _G.UE.FVector2D(0, 0)
            Anchor.Maximum = _G.UE.FVector2D(1, 1)
            UIUtil.CanvasSlotSetAnchors(self.MemberListView, Anchor)
            UIUtil.CanvasSlotSetSize(self.MemberListView, _G.UE.FVector2D(0, 0))
        end
    end
end

function ArmyMemberPageView:OnbApplyPanelChanged(bApplyPanel)
    if bApplyPanel then
        self:ShowAskForView()
        if self.MemberAskForView then
            self.MemberAskForView:PlayAnimation(self.MemberAskForView.AnimShowPanel)
        end
    else
        self:HideMemberSubView( self.MemberAskForView)
        self.MemberAskForView = nil
    end
end

function ArmyMemberPageView:ShowAskForView()
    if self.MemberAskForView == nil then
        self.MemberAskForView = UIViewMgr:CreateViewByName("Army/ArmyMemberAskForPage_UIBP", nil, self, true, true)
        if self.MemberAskForView then
            self.PanelMember:AddChildToCanvas(self.MemberAskForView)
            local Anchor = _G.UE.FAnchors()
            Anchor.Minimum = _G.UE.FVector2D(0, 0)
            Anchor.Maximum = _G.UE.FVector2D(1, 1)
            UIUtil.CanvasSlotSetAnchors(self.MemberAskForView, Anchor)
            UIUtil.CanvasSlotSetSize(self.MemberAskForView, _G.UE.FVector2D(0, 0))
        end
    end
end

function ArmyMemberPageView:OnbCategoryPanelChanged(bCategoryPanel)
    if bCategoryPanel then
        self:ShowMemberCategoryView()
        if self.MemberCategoryView then
            self.MemberCategoryView:PlayAnimation(self.MemberCategoryView.AnimShowPanel)
        end
    else
        self:HideMemberSubView(self.MemberCategoryView)
        self.MemberCategoryView = nil
    end
end

function ArmyMemberPageView:ShowMemberCategoryView()
    if self.MemberCategoryView == nil then
        self.MemberCategoryView = UIViewMgr:CreateViewByName("Army/ArmyMemberClassPage_UIBP", nil, self, true, true)
        if self.MemberCategoryView then
            self.PanelMember:AddChildToCanvas(self.MemberCategoryView)
            local Anchor = _G.UE.FAnchors()
            Anchor.Minimum = _G.UE.FVector2D(0, 0)
            Anchor.Maximum = _G.UE.FVector2D(1, 1)
            UIUtil.CanvasSlotSetAnchors(self.MemberCategoryView, Anchor)
            UIUtil.CanvasSlotSetSize(self.MemberCategoryView, _G.UE.FVector2D(0, 0))
        end
    end
end

function ArmyMemberPageView:HideMemberSubView(View)
	if View ~= nil then
		self.PanelMember:RemoveChild(View)
		UIViewMgr:RecycleView(View)
	end
end

function ArmyMemberPageView:OnClickedSelectMemberItem(Index, ItemData, ItemView)
    --- 选中成员弹个人信息面板
    local IsChecked = UIUtil.IsToggleButtonChecked(ItemView.ToggleBtn:GetCheckedState())
    if IsChecked then
        --self:PopupMenu(ItemData.RoleID, ItemData.CategoryID, ItemView)
        ---替换为个人信息面板
        PersonInfoMgr:ShowPersonalSimpleInfoView(ItemData.RoleID)
    end
    if IsChecked then
        SelectedMemberVM = ItemData
    else
        SelectedMemberVM = nil
    end
end



function ArmyMemberPageView:OnSelectChangedCategory(Index, ItemData, ItemView)
    self:PlayAnimation(self.AnimUpdateDisplay)
    ArmyMemberPageVM:SelectedCategoryPermissionsInfo(Index, ItemData)
end

function ArmyMemberPageView:OnDestroy()
end

function ArmyMemberPageView:OnShow()
    if self.BtnClassEdit then
	    -- LSTR string:分组编辑
	    self.BtnClassEdit:SetText(LSTR(910065))
    end
end

function ArmyMemberPageView:OnDissolveArmy()

end

function ArmyMemberPageView:OnTransferLeaer()
    if SelectedMemberVM == nil then
        _G.FLOG_ERROR("ArmyMemberPageView:OnTransferLeaer", "SelectedMemberVM is nil")
        return
    end
    --- 转让部队长
    local Callback = function()
        local CurrentTime = _G.TimeUtil.GetServerTime()
        local TransferSpace = GroupGlobalCfg:GetValueByType(GlobalCfgType.TransferLeaderTimeInterval)
        local PassedTime = CurrentTime - ArmyMemberPanelVM.MyArmyInfo.TransferLeaderTime - TransferSpace * ArmyDefine.Day
        local bTransferLeader = PassedTime >= ArmyDefine.Zero
        local Day = math.floor((CurrentTime - SelectedMemberVM.JoinTime) / ArmyDefine.Day)
        local JoinTimeSpace = GroupGlobalCfg:GetValueByType(GlobalCfgType.NewLeaderJoinedTimeMinLimit)
        local bMemberJoinTime = Day >= JoinTimeSpace
        if bTransferLeader and bMemberJoinTime then
            ArmyMgr:SendArmyTransferLeaderMsg(SelectedMemberVM.RoleID)
        else
            if not bTransferLeader then
                -- LSTR string:%s天仅能进行一次转让单个部队操作
                _G.MsgTipsUtil.ShowTips(string.format(LSTR(910015), TransferSpace))
            elseif not bMemberJoinTime then
                -- LSTR string:必须为加入部队%s天及以上的成员
                _G.MsgTipsUtil.ShowTips(string.format(LSTR(910123), JoinTimeSpace))
            end
        end
    end
    MsgBoxUtil.ShowMsgBoxTwoOp(
        self,
        -- LSTR string:提示
        LSTR(910144),
        -- LSTR string:确认转让部队长权限给 %s 吗？
        string.format(LSTR(910194), RichTextUtil.GetText(SelectedMemberVM.RoleName,  ArmyTextColor.BlueHex)),
        Callback,
        nil,
        -- LSTR string:取消
        LSTR(910083),
        -- LSTR string:转让
        LSTR(910236)
    )
end

function ArmyMemberPageView:OnCategorySetting()
    if SelectedMemberVM == nil then
        _G.FLOG_ERROR("ArmyMemberPageView:OnCategorySetting", "SelectedMemberVM is nil")
        return
    end
    local CategoryData = table.find_by_predicate(ArmyMemberPageVM.MyArmyInfo.Categories, function(Element)
        return Element.ID == SelectedMemberVM.CategoryID
    end)
    --- 分组设置
    local Params = {
        RoleName = SelectedMemberVM.RoleName,
        CategoryName = SelectedMemberVM.CategoryName,
        CategoryID = SelectedMemberVM.CategoryID,
        CategoryIcon = SelectedMemberVM.CategoryIcon,
        ShowIndex = CategoryData.ShowIndex,
        Categories = table.find_all_by_predicate(ArmyMemberPageVM.MyArmyInfo.Categories, function(Element)
            return Element.ID ~= ArmyDefine.LeaderCID --默认ID == 1是部队长
        end),
        Callback = function(ChangedID)
            ArmyMgr:SendArmySetMemberCategoryMsg(SelectedMemberVM.RoleID, ChangedID)
        end
    }
    UIViewMgr:ShowView(UIViewID.ArmyMemClassSettingPanel, Params)
end

function ArmyMemberPageView:DelectMember()
    if SelectedMemberVM == nil then
        _G.FLOG_ERROR("ArmyMemberPageView:DelectMember", "SelectedMemberVM is nil")
        return
    end
    --- 删除成员
    MsgBoxUtil.ShowMsgBoxTwoOp(
        self,
        -- LSTR string:提示
        LSTR(910144),
        -- LSTR string:确认除名部队成员 %s 吗?
        string.format(LSTR(910195), RichTextUtil.GetText(SelectedMemberVM.RoleName,  ArmyTextColor.BlueHex)),
        function()
            ArmyMgr:SendKickMemberMsg(SelectedMemberVM.RoleID)
        end
    )
end

function ArmyMemberPageView:CancelSelecedPopup()
	local VisibleMenu = UIViewMgr:IsViewVisible(UIViewID.TeamMenu)
	if VisibleMenu then
		UIViewMgr:HideView(UIViewID.TeamMenu)
	end
	self.Params.Adapter:CancelSelected()
	self.ViewModel:SetIsSelected(false)
end

function ArmyMemberPageView:OnHide()
    ArmyMemberPageVM:ReSetSort()
    self:HideAllSubView()
    UIViewMgr:HideView(UIViewID.TeamMenu)
end

function ArmyMemberPageView:HideAllSubView()
    self:HideMemberSubView(self.MemberListView)
    self.MemberListView = nil
    self:HideMemberSubView(self.MemberAskForView)
    self.MemberAskForView = nil
    self:HideMemberSubView(self.MemberCategoryView)
    self.MemberCategoryView = nil
end

function ArmyMemberPageView:OnRegisterUIEvent()
end

function ArmyMemberPageView:OnRegisterGameEvent()
end

function ArmyMemberPageView:OnRegisterBinder()
    self:RegisterBinders(ArmyMemberPageVM, self.Binders)
end

--- 分组权限信息Tabs
function ArmyMemberPageView:OnGroupStateChangedCategory(ToggleGroup, ToggleButton, Index, State)
    ArmyMemberPageVM:SetPermssionPageIndex(Index + 1)
end

--- 分组权限编辑
function ArmyMemberPageView:OnClickedOpenPowerEdit()
    ArmyMemberPageVM:OpenCategoryTab(CategoryUIType.Power)
end

--- 查看成员并编辑
function ArmyMemberPageView:OnClickedMemberEdit()
    ArmyMemberPageVM:OpenCategoryTab(CategoryUIType.Part)
end

--- 分组编辑
-- function ArmyMemberPageView:OnClickedCategoryEdit()
--     --ArmyMemberPageVM:OpenCategoryTab(CategoryUIType.Sort)
--     ArmyMemberPageVM:OpenCategoryEditPanel()
-- end

--- 规则提示
function ArmyMemberPageView:OnClickedInfoTips()
    _G.UIViewMgr:ShowView(_G.UIViewID.ArmyRuleWinPage)
end

--- 退出部队
function ArmyMemberPageView:OnClickedQuitArmy()
    if ArmyMemberPageVM.bLeader then
        if #ArmyMemberPageVM.Members == ArmyDefine.One then
            MsgBoxUtil.ShowMsgBoxTwoOp(
                self,
                -- LSTR string:提示
                LSTR(910144),
                -- LSTR string:确认解散部队?
                LSTR(910192),
                ArmyMgr.SendArmyDisbandMsg,
                nil,
                -- LSTR string:取消
                LSTR(910083),
                -- LSTR string:解散
                LSTR(910215)
            )
        else
            -- LSTR string:提示
            MsgBoxUtil.ShowMsgBoxOneOpRight(self, LSTR(910144), LSTR(910217))
        end
    else
        MsgBoxUtil.ShowMsgBoxTwoOp(
            self,
            -- LSTR string:提示
            LSTR(910144),
            -- LSTR string:确认要退出部队?
            LSTR(910191),
            ArmyMgr.SendArmyQuitMsg,
            nil,
            -- LSTR string:取消
            LSTR(910083),
            -- LSTR string:退出
            LSTR(910240)
        )
    end
end

--- 动效处理
function ArmyMemberPageView:OnPanelShowChanged(IsShowPanel)
    if IsShowPanel then
        self:PlayAnimation(self.AnimShowPanel)
    end
end

--- 分组排序
function ArmyMemberPageView:OnClickedSwitchCategorySort()
    ArmyMemberPageVM:MembersCategorySort()
end

--- 等级排序
function ArmyMemberPageView:OnClickedSwitchLevelSort()
    ArmyMemberPageVM:MembersLevelSort()
end

return ArmyMemberPageView
