---
--- Author: daniel
--- DateTime: 2023-03-07 18:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = _G.EventID

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyMgr = require("Game/Army/ArmyMgr")
local ChatDefine = require("Game/Chat/ChatDefine")
local UIViewMgr = require("UI/UIViewMgr")

---@class ArmyMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnHelp CommInforBtnView
---@field ChatMsg CommChatMsgPanelView
---@field ImgBG UFImage
---@field ImgMask UFImage
---@field PanelArmy UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field PanelRight UFCanvasPanel
---@field TableViewTabs CommMenuView
---@field TextTitle UFTextBlock
---@field AnimBGID1 UWidgetAnimation
---@field AnimBGID2 UWidgetAnimation
---@field AnimBGID3 UWidgetAnimation
---@field AnimBGLoop UWidgetAnimation
---@field AnimMaskIn UWidgetAnimation
---@field AnimMaskOut UWidgetAnimation
---@field AnimShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMainPanelView = LuaClass(UIView, true)

local ParentKey = nil
local ChildKey = nil
local Tabs = nil

function ArmyMainPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnHelp = nil
	--self.ChatMsg = nil
	--self.ImgBG = nil
	--self.ImgMask = nil
	--self.PanelArmy = nil
	--self.PanelEmpty = nil
	--self.PanelRight = nil
	--self.TableViewTabs = nil
	--self.TextTitle = nil
	--self.AnimBGID1 = nil
	--self.AnimBGID2 = nil
	--self.AnimBGID3 = nil
	--self.AnimBGLoop = nil
	--self.AnimMaskIn = nil
	--self.AnimMaskOut = nil
	--self.AnimShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMainPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnHelp)
	self:AddSubView(self.ChatMsg)
	self:AddSubView(self.TableViewTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMainPanelView:OnInit()
    ChildKey = ArmyDefine.One
    self.Binders = {
        --{"bCreatePanel", UIBinderSetIsVisible.New(self, self.CreatePanel)},
        {"bCreatePanel", UIBinderValueChangedCallback.New(self, nil, self.ShowArmyCreatePanel)},
        --{"bJoinPanel", UIBinderSetIsVisible.New(self, self.JoinPanel)},
        {"bJoinPanel", UIBinderValueChangedCallback.New(self, nil, self.ShowArmyJoinPanel)},
        --{"bMemberPanel", UIBinderSetIsVisible.New(self, self.MemberPanel)},
        {"bMemberPanel", UIBinderValueChangedCallback.New(self, nil, self.ShowArmyMemberPanel)},
        --{"bInfoPanel", UIBinderSetIsVisible.New(self, self.ArmyInfoPage_UIBP)},
        {"bInfoPanel", UIBinderValueChangedCallback.New(self, nil, self.ShowArmyInfoPanel)},
        --{"bStatePanel", UIBinderSetIsVisible.New(self, self.ArmyStatePanel)},
        {"bStatePanel", UIBinderValueChangedCallback.New(self, nil, self.ShowArmyStatePanel)},
        
        --{"bWelfarePanel", UIBinderSetIsVisible.New(self, self.WelfarePanel)},
        {"bWelfarePanel", UIBinderValueChangedCallback.New(self, nil, self.ShowArmyWelfarePanel)},

        {"bSignDataPanel", UIBinderValueChangedCallback.New(self, nil, self.ShowArmySignDataPanel)},

        {"bSignInvitePanel", UIBinderValueChangedCallback.New(self, nil, self.ShowArmySignInvitePanel)},

        {"bInformationPanel", UIBinderValueChangedCallback.New(self, nil, self.ShowArmyInformationPanel)},

        {"bEmptyPanel", UIBinderValueChangedCallback.New(self, nil, self.ShowArmyEmptyPanel)},

        {"BGIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBG)},
        {"GrandCompanyType", UIBinderValueChangedCallback.New(self, nil, self.OnGrandCompanyTypeChange)},
        --{"IsMask", UIBinderSetIsVisible.New(self, self.ImgMask)},
        {"IsMask", UIBinderValueChangedCallback.New(self, nil, self.OnMaskChange)},
        {"IsShowChat", UIBinderSetIsVisible.New(self, self.ChatMsg)},
        {"BGMaskColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgMask) },
    }
end

---署名数据界面显隐
function ArmyMainPanelView:ShowArmySignDataPanel(bSignDataPanel)
    if bSignDataPanel then
        if self.ArmySignDataPanelView == nil then
            self.ArmySignDataPanelView = self:ShowArmySubPanel(ArmyDefine.ArmyPanelPath.ArmySignDataPanel)
        end
    else
        if self.ArmySignDataPanelView then
            self:RemoveArmySubPanel(self.ArmySignDataPanelView)
            self.ArmySignDataPanelView = nil
        end
    end
end

---署名邀请界面显隐
function ArmyMainPanelView:ShowArmySignInvitePanel(bSignInvitePanel)
    if bSignInvitePanel then
        if self.ArmySignInvitePanelView == nil then
            self.ArmySignInvitePanelView = self:ShowArmySubPanel(ArmyDefine.ArmyPanelPath.ArmySignInvitePanel)
        end
    else
        if self.ArmySignInvitePanelView then
            self:RemoveArmySubPanel(self.ArmySignInvitePanelView)
            self.ArmySignInvitePanelView = nil
        end
    end
end

---信息界面显隐
function ArmyMainPanelView:ShowArmyInfoPanel(bInfoPanel)
    if bInfoPanel then
        if self.ArmyInfoPageView == nil then
            self.ArmyInfoPageView = self:ShowArmySubPanel(ArmyDefine.ArmyPanelPath.ArmyInfoPanel)
        end
    else
        if self.ArmyInfoPageView then
            self:RemoveArmySubPanel(self.ArmyInfoPageView)
            self.ArmyInfoPageView = nil
        end
    end
end

---创建界面显隐
function ArmyMainPanelView:ShowArmyCreatePanel(bCreatePanel)
    if bCreatePanel then
        if self.ArmyCreatePanelView == nil then
            self.ArmyCreatePanelView = self:ShowArmySubPanel(ArmyDefine.ArmyPanelPath.ArmyCreatePanel)
        end
    else
        if self.ArmyCreatePanelView then
            self:RemoveArmySubPanel(self.ArmyCreatePanelView)
            self.ArmyCreatePanelView = nil
        end
    end
end

---加入界面显隐
function ArmyMainPanelView:ShowArmyJoinPanel(bJoinPanel)
    if bJoinPanel then
        if self.ArmyJoinPanelView == nil then
            self.ArmyJoinPanelView = self:ShowArmySubPanel(ArmyDefine.ArmyPanelPath.ArmyJoinPanel)
        end
    else
        if self.ArmyJoinPanelView then
            self:RemoveArmySubPanel(self.ArmyJoinPanelView)
            self.ArmyJoinPanelView = nil
        end
    end
end

---成员界面显隐
function ArmyMainPanelView:ShowArmyMemberPanel(bMemberPanel)
    if bMemberPanel then
        if self.ArmyMemberPanelView == nil then
            self.ArmyMemberPanelView = self:ShowArmySubPanel(ArmyDefine.ArmyPanelPath.ArmyMemberPanel)
        end
    else
        if self.ArmyMemberPanelView then
            self:RemoveArmySubPanel(self.ArmyMemberPanelView)
            self.ArmyMemberPanelView = nil
        end
    end
end

---福利界面显隐
function ArmyMainPanelView:ShowArmyWelfarePanel(bWelfarePanel)
    if bWelfarePanel then
        if self.ArmyWelfarePanelView == nil then
            self.ArmyWelfarePanelView = self:ShowArmySubPanel(ArmyDefine.ArmyPanelPath.ArmyWelfarePanel)
        end
    else
        if self.ArmyWelfarePanelView then
            self:RemoveArmySubPanel(self.ArmyWelfarePanelView)
            self.ArmyWelfarePanelView = nil
        end
    end
end

---状态界面显隐
function ArmyMainPanelView:ShowArmyStatePanel(bStatePanel)
    if bStatePanel then
        if self.ArmyStatePanelView == nil then
            self.ArmyStatePanelView = self:ShowArmySubPanel(ArmyDefine.ArmyPanelPath.ArmyStatePanel)
        end
    else
        if self.ArmyStatePanelView then
            self:RemoveArmySubPanel(self.ArmyStatePanelView)
            self.ArmyStatePanelView = nil
        end
    end
end
---部队情报界面显隐
function ArmyMainPanelView:ShowArmyInformationPanel(bInformationPanel)
    if bInformationPanel then
        if self.ArmyInformationPanelView == nil then
            self.ArmyInformationPanelView = self:ShowArmySubPanel(ArmyDefine.ArmyPanelPath.ArmyInformationPanel)
        end
    else
        if self.ArmyInformationPanelView then
            self:RemoveArmySubPanel(self.ArmyInformationPanelView)
            self.ArmyInformationPanelView = nil
        end
    end
end

---部队空界面显隐
function ArmyMainPanelView:ShowArmyEmptyPanel(bEmptyPanel)
    if bEmptyPanel then
        if self.ArmyEmptyPanelView == nil then
            self.ArmyEmptyPanelView = self:ShowArmySubPanel(ArmyDefine.ArmyPanelPath.ArmyEmptyPanel, self.PanelEmpty)
            --- LSTR ：处于部队署名状态，无法组建部队
            self.ArmyEmptyPanelView:SetTextEmptyTip(LSTR(910358))
        end
    else
        if self.ArmyEmptyPanelView then
            self:RemoveArmySubPanel(self.ArmyEmptyPanelView, self.PanelEmpty)
            self.ArmyEmptyPanelView = nil
        end
    end
end

function ArmyMainPanelView:ShowArmySubPanel(PanelPath, PanelWidget)
    local PanelWidget = PanelWidget or self.PanelRight
    local ArmySubView = UIViewMgr:CreateViewByName(PanelPath, nil, self, true, true)
    PanelWidget:AddChildToCanvas(ArmySubView)
    local Anchor = _G.UE.FAnchors()
    Anchor.Minimum = _G.UE.FVector2D(0, 0)
    Anchor.Maximum = _G.UE.FVector2D(1, 1)
    UIUtil.CanvasSlotSetAnchors(ArmySubView, Anchor)
    UIUtil.CanvasSlotSetSize(ArmySubView, _G.UE.FVector2D(0, 0))
    return ArmySubView
end

function ArmyMainPanelView:RemoveArmySubPanel(View, PanelWidget)
    local PanelWidget = PanelWidget or self.PanelRight
    if View then
        PanelWidget:RemoveChild(View)
        UIViewMgr:RecycleView(View)
    end
end

function ArmyMainPanelView:OnSelectionChangedCommMenu(Index, ItemData, ItemView)
    local Key = ItemData.Key
    if Key == nil then
        return
    end
    if Tabs == nil then
        _G.FLOG_ERROR("ArmyMainPanelView:OnSelectionChangedCommMenu", "Tabs is nil")
        return
    end
    if Key < ArmyDefine.Ten then
        ParentKey = Key
        if Tabs and Tabs[ParentKey].Children then
            ChildKey = ArmyDefine.Zero
        end
    elseif Key > ArmyDefine.Ten then
        ParentKey = math.floor(Key / ArmyDefine.Ten)
        ChildKey = Key % ArmyDefine.Ten
    end
    if ParentKey and Tabs[ParentKey].Children then
        -- SelectedKey = tonumber(string.format("%d%d", ParentKey, ChildKey))
        if ChildKey > ArmyDefine.Zero then
            ArmyMainVM:SetMenuSelectedIndex(ParentKey, ChildKey)
        end
    else
        ArmyMainVM:SetMenuSelectedIndex(ParentKey, ChildKey)
    end
    ---同意放到vm里请求数据
    -- if ArmyMainVM.ArmyID == 0 then
    --     if Index == ArmyDefine.ArmyOutUIType.ArmyInvite then
    --         ArmyMgr:SendArmyGetInviteListMsg()
    --     end
    -- end
    if ArmyMainVM.bInfoPanel then
        --self.ArmyInfoPage_UIBP:PlayAnimShow()
        if  self.ArmyInfoPageView then
            self.ArmyInfoPageView:PlayAnimShow()
        end
    end
end

function ArmyMainPanelView:OnDestroy()
end

--- @param IsQuery boolean 是否直接查询部队信息
function ArmyMainPanelView:OnShow()
    -- LSTR string:部队
    self.TextTitle:SetText(LSTR(910308))
    UIUtil.SetIsVisible(self.BtnHelp, true)
    --- 获取简单公会仓库,有公会才处理
    local ArmyID = ArmyMgr.SelfArmyID
    if ArmyID then
        local bJoinedArmy = ArmyID > 0
        if bJoinedArmy then
            ArmyMgr:SendGroupStoreReqStoreBaseInfo()
        end
    end
    if self.Params and self.Params.IsArmyCreate then
        --self.ArmyInfoPage_UIBP:StopAnimShow()
        --self.ArmyInfoPage_UIBP:PlayAnimCreate()
        if  self.ArmyInfoPageView then
            self.ArmyInfoPageView:StopAnimShow()
            self.ArmyInfoPageView:PlayAnimCreate()
        end
    else
        self:PlayAnimation(self.AnimShow)
    end

    local SkipPanelID = ArmyMainVM:GetSkipPanelID()
    self.IsSkipOpen = true
    if SkipPanelID then
        self:SKipUI(SkipPanelID)
    else
        self.IsSkipOpen = false
        self:OnRefreshUI()
    end

    --- 背景动画循环播放
    self:PlayAnimation(self.AnimBGLoop, 0, 0)
    ---打开界面默认有遮罩
    --ArmyMainVM:SetIsMask(true)
    self.ChatMsg:SetCurViewID(self:GetViewID())
    self.ChatMsg:SetSource(ChatDefine.OpenSource.ArmyWin)
end

function ArmyMainPanelView:SKipUI(SkipPanelID)
    local bJoinedArmy = ArmyMgr:IsInArmy()
    if SkipPanelID == ArmyDefine.ArmySkipPanelID.CreatePanel then
        ---无公会才跳转到创建界面
        if not bJoinedArmy then
            self:OnRefreshUI(ArmyDefine.ArmyOutUIType.ArmyCreate)
        end
    elseif SkipPanelID == ArmyDefine.ArmySkipPanelID.InvitePanel then
        ---无公会才跳转到邀請界面
        local IsRestricted = ArmyMgr:GetIsRestrictedArmyPanel()
        if not bJoinedArmy then
            if IsRestricted then
                self:OnRefreshUI(ArmyDefine.ArmyInviteOutUIType.ArmyInvite)
            else
                self:OnRefreshUI(ArmyDefine.ArmyOutUIType.ArmyInvite)
            end
        end
    elseif SkipPanelID == ArmyDefine.ArmySkipPanelID.InviteSignPanel then
        ---无公会才跳转到署名邀請界面
        local IsRestricted = ArmyMgr:GetIsRestrictedArmyPanel()
        if not bJoinedArmy then
            if IsRestricted then
                self:OnRefreshUI(ArmyDefine.ArmyInviteOutUIType.ArmySign)
            else
                self:OnRefreshUI(ArmyDefine.ArmyOutUIType.ArmySign)
            end
        end
    end
end

function ArmyMainPanelView:OnRefreshUI(SelectedKey)
    local TableViewTabs = self.TableViewTabs
    TableViewTabs:CancelSelected()
    local SelectedIndex = SelectedKey or ArmyDefine.One
    if ArmyMgr.SelfArmyID > 0 then
        Tabs = ArmyDefine.ArmyTabs
    else
        local IsRestricted = ArmyMgr:GetIsRestrictedArmyPanel()
        if IsRestricted then
            Tabs = ArmyDefine.InvitedArmyTabs
        else
            Tabs = ArmyDefine.NoArmyTabs
        end
        ArmyMainVM:OnReset()
    end
    TableViewTabs:UpdateItems(Tabs, false)
    TableViewTabs:SetSelectedIndex(SelectedIndex)
    for i = 1, #Tabs do
        if Tabs[i].Children then
            TableViewTabs:SetIsExpansion(i, false)
        end
    end
end

function ArmyMainPanelView:OnHide()
    ArmyMainVM:SetArmyHideData()
    --self.TableViewTabs:CancelSelected()
end

function ArmyMainPanelView:OnRegisterUIEvent()
    UIUtil.AddOnSelectionChangedEvent(self, self.TableViewTabs, self.OnSelectionChangedCommMenu)
end

function ArmyMainPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ArmyUpdateMainView, self.OnRefreshUI)
end

function ArmyMainPanelView:OnRegisterBinder()
    self:RegisterBinders(ArmyMainVM, self.Binders)
end

function ArmyMainPanelView:OnTouchStarted(MyGeometry, MouseEvent)
    ---  部队状态tips处理
    if ArmyMainVM.bStatePanel == true and self.ArmyStatePanelView then
        self.ArmyStatePanelView:SetPanelTipsEnable(false)
    end
    return _G.UE.UWidgetBlueprintLibrary.CaptureMouse(_G.UE.UWidgetBlueprintLibrary.Handled(), self)
end

function ArmyMainPanelView:OnGrandCompanyTypeChange(GrandCompanyType)
    ---  部队背景动画处理
    if GrandCompanyType == ArmyDefine.GrandCompanyType.HeiWo then
        self:PlayAnimation(self.AnimBGID1)
    elseif GrandCompanyType == ArmyDefine.GrandCompanyType.ShuangShe then
        self:PlayAnimation(self.AnimBGID2)
    elseif GrandCompanyType == ArmyDefine.GrandCompanyType.HengHui then
        self:PlayAnimation(self.AnimBGID3)
    end
end

function ArmyMainPanelView:OnMaskChange(IsMask)
    if IsMask then
        if self:IsAnimationPlaying(self.AnimMaskOut) then
            self:StopAnimation(self.AnimMaskOut)
        end
        UIUtil.SetIsVisible(self.ImgMask, true)
        self:PlayAnimation(self.AnimMaskIn)
    else
        if self:IsAnimationPlaying(self.AnimMaskIn) then
            self:StopAnimation(self.AnimMaskIn)
        end
        self:PlayAnimation(self.AnimMaskOut)
        local HideTime = self.AnimMaskOut:GetEndTime()
        self:RegisterTimer(self.HideMask, HideTime, HideTime, 1)
    end
end

function ArmyMainPanelView:HideMask()
    if ArmyMainVM and not ArmyMainVM:GetIsMask() then
        UIUtil.SetIsVisible(self.ImgMask, false)
    end
end
return ArmyMainPanelView
