---
--- Author: Administrator
--- DateTime: 2024-07-08 10:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")

local EToggleButtonState = _G.UE.EToggleButtonState
local TouringBandMgr = nil
local LSTR = nil

---@class TouringBandGuidePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field BkgContent TouringBandContentItemView
---@field CloseBtn CommonCloseBtnView
---@field CommTab CommHorTabsView
---@field CommonTitle CommonTitleView
---@field GuideCondition TouringBandContentItemView
---@field ImgPaper UFImage
---@field PanelBookUI UFCanvasPanel
---@field Poster TouringBandPosterItemView
---@field Poster2 TouringBandPosterItemView
---@field StoryContent1 TouringBandContentItemView
---@field StoryContent2 TouringBandContentItemView
---@field SwitcherContent UFWidgetSwitcher
---@field TableViewMember UTableView
---@field TableViewSongList UTableView
---@field TableViewTab UTableView
---@field TableViewTab2 UTableView
---@field TextCondition UFTextBlock
---@field TextEmpty UFTextBlock
---@field TextMember UFTextBlock
---@field TextSongPlayback UFTextBlock
---@field TextStory1 UFTextBlock
---@field TextStory2 UFTextBlock
---@field TextTitleBkg UFTextBlock
---@field ToggleBtnSwitch UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimSwitchOff UWidgetAnimation
---@field AnimSwitchOn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TouringBandGuidePanelView = LuaClass(UIView, true)

function TouringBandGuidePanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.BkgContent = nil
	--self.CloseBtn = nil
	--self.CommTab = nil
	--self.CommonTitle = nil
	--self.GuideCondition = nil
	--self.ImgPaper = nil
	--self.PanelBookUI = nil
	--self.Poster = nil
	--self.Poster2 = nil
	--self.StoryContent1 = nil
	--self.StoryContent2 = nil
	--self.SwitcherContent = nil
	--self.TableViewMember = nil
	--self.TableViewSongList = nil
	--self.TableViewTab = nil
	--self.TableViewTab2 = nil
	--self.TextCondition = nil
	--self.TextEmpty = nil
	--self.TextMember = nil
	--self.TextSongPlayback = nil
	--self.TextStory1 = nil
	--self.TextStory2 = nil
	--self.TextTitleBkg = nil
	--self.ToggleBtnSwitch = nil
	--self.AnimIn = nil
	--self.AnimSwitchOff = nil
	--self.AnimSwitchOn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TouringBandGuidePanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.BkgContent)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommTab)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.GuideCondition)
	self:AddSubView(self.Poster)
	self:AddSubView(self.Poster2)
	self:AddSubView(self.StoryContent1)
	self:AddSubView(self.StoryContent2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TouringBandGuidePanelView:OnInit()
    TouringBandMgr = _G.TouringBandMgr
    LSTR = _G.LSTR
    self.SelectIndex = 1
    self.BandID = 0
    self.BandTabVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, nil, nil)
    self.BandTabVMAdapter:SetOnSelectChangedCallback(self.OnBandTabSelectChange)
    self.BandTabVMAdapter2 = UIAdapterTableView.CreateAdapter(self, self.TableViewTab2, nil, nil)
    self.BandTabVMAdapter2:SetOnSelectChangedCallback(self.OnBandTabSelectChange)

    self.BandMemberVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewMember, nil, nil)
    self.BandSongVMAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSongList, nil, nil)
end

function TouringBandGuidePanelView:OnDestroy()
end

function TouringBandGuidePanelView:OnShow()
    TouringBandMgr:QueryCollectionReq()
    self:InitConstInfo()

    local TabList = {}
    table.insert(TabList, {Name = LSTR(450003)})
    table.insert(TabList, {Name = LSTR(450020)})
    table.insert(TabList, {Name = LSTR(450032)})

    self.CommTab:UpdateItems(TabList)

    if self.CommTab ~= nil and self.CommTab.AdapterTabs ~= nil then
        local Child = self.CommTab.AdapterTabs:GetChildren(2)
        if Child then
            self.RedDotStory = Child.RedDot
            self.RedDotStory:SetIsCustomizeRedDot(true)
            self.RedDotStory:SetStyle(RedDotDefine.RedDotStyle.SecondStyle)
        end
    end
    
    local FromViewID = (self.Params or {}).FromViewID
    UIUtil.SetIsVisible(self.CloseBtn, FromViewID == nil)
    UIUtil.SetIsVisible(self.BackBtn, FromViewID ~= nil)
    self.ViewModel:InitBandTabList()
    UIUtil.SetIsVisible(self.SwitcherContent, true)

    local MostRecentBandID = TouringBandMgr:GetMostRecentBandID()
    local AllBandData = TouringBandMgr:GetAllBandData()
    for Index, Value in ipairs(AllBandData) do
        if Value.BandID == MostRecentBandID then
            self.SelectIndex = tonumber(Value.BandNumber) or Index  -- 排序过的Index已经不一样了
        end
    end

    --UIUtil.SetIsVisible(self.Poster2, false)
    local SoftPath = _G.UE.FSoftObjectPath()
    SoftPath:SetPath("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_UI_Band_List.Play_UI_Band_List'")
    self.TableViewTab.SoundPathOnClick = SoftPath
    self.TableViewTab2.SoundPathOnClick = SoftPath

    local ToggleSoftPath = _G.UE.FSoftObjectPath()
    ToggleSoftPath:SetPath("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_UI_Band_List_Switch.Play_UI_Band_List_Switch'")
    self.ToggleBtnSwitch.SoundPathOnClick = ToggleSoftPath
    
    UIUtil.SetIsVisible(self.TableViewTab, true, true)
    UIUtil.SetIsVisible(self.TableViewTab2, false, false)
    self.BandTabVMAdapter:SetSelectedIndex(self.SelectIndex)
    self.BandTabVMAdapter:ScrollToIndex(self.SelectIndex)
    self.BandTabVMAdapter2:SetSelectedIndex(self.SelectIndex)
    self.BandTabVMAdapter2:ScrollToIndex(self.SelectIndex)

    self.Poster:PlayPosterIn()
    AudioUtil.LoadAndPlayUISound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_UI_Band_Archive.Play_UI_Band_Archive'")
end

function TouringBandGuidePanelView:InitConstInfo()
    if self.IsInitConstInfo then
        return
    end

    self.IsInitConstInfo = true

    -- LSTR string: 乐团图鉴
    self.CommonTitle:SetTextTitleName(LSTR(450001))
    -- LSTR string: 相遇
    local CurNum, AllNum = TouringBandMgr:GetCurUnlockBandNum()
    local TextJob = LSTR(450002) .. ":" .. CurNum .. "/" .. AllNum
    self.CommonTitle:SetTextSubtitle(TextJob)
    -- LSTR string: 背景
    self.TextTitleBkg:SetText(LSTR(450004))
    -- LSTR string: 粉丝互动条件
    self.TextCondition:SetText(LSTR(450005))
    -- LSTR string: 和乐团相遇后解锁
    self.TextEmpty:SetText(LSTR(450006))
    -- LSTR string: 成员
    self.TextMember:SetText(LSTR(450019))
    -- LSTR string: 故事1
    self.TextStory1:SetText(LSTR(450021))
    -- LSTR string: 故事2
    self.TextStory2:SetText(LSTR(450022))
    -- LSTR string: 歌曲
    self.TextSongPlayback:SetText(LSTR(450032))
end

function TouringBandGuidePanelView:OnHide()
    TouringBandMgr:StopBandSong()
end

function TouringBandGuidePanelView:OnRegisterUIEvent()
    self.BackBtn:AddBackClick(self, self.OnClickedBack)
    self.CloseBtn:SetCallback(self, self.OnClickedBack)
    UIUtil.AddOnSelectionChangedEvent(self, self.CommTab, self.OnGroupStateChangedTab)
    UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnSwitch, self.OnToggleSwitchStateChangedEvent)
end

function TouringBandGuidePanelView:OnRegisterGameEvent()

end

function TouringBandGuidePanelView:OnRegisterBinder()
    self.ViewModel = TouringBandMgr:GetTouringBandGuideVM(true)
    local Binders = {
        { "BandTabVMList", UIBinderUpdateBindableList.New(self, self.BandTabVMAdapter) },
        { "BandTabVMList", UIBinderUpdateBindableList.New(self, self.BandTabVMAdapter2) },
        { "BandMemberVMList", UIBinderUpdateBindableList.New(self, self.BandMemberVMAdapter) },
        { "BandSongVMList", UIBinderUpdateBindableList.New(self, self.BandSongVMAdapter) },
    }
    self:RegisterBinders(self.ViewModel, Binders)
end

function TouringBandGuidePanelView:OnBandTabSelectChange(Index, ItemData, ItemView, IsByClick)
    _G.TouringBandMgr:StopBandSong()
    self.SelectIndex = Index
    self.BandID = ItemData.BandID
    self.BandSongVMAdapter:CancelSelected()
    self.ViewModel:UpdateSelectBand(self.BandID)

    local IsUnLock = TouringBandMgr:IsBandUnLockByID(self.BandID)
    UIUtil.SetIsVisible(self.CommTab, IsUnLock)
    if IsUnLock then
        local IsFans = TouringBandMgr:IsBandFansByID(self.BandID)
        if IsFans then
            local Ret = self.CommTab:SetSelectedIndex(3)
            if not Ret then
                self:OnGroupStateChangedTab(3)
            end
        else
            local Ret = self.CommTab:SetSelectedIndex(1)
            if not Ret then
                self:OnGroupStateChangedTab(1)
            end
        end
    else
        self.SwitcherContent:SetActiveWidgetIndex(3)
    end

    self.BkgContent:GetViewModel():UpdateContent(self.BandID)
    self.StoryContent1:GetViewModel():UpdateStory(self.BandID, 1)
    self.StoryContent2:GetViewModel():UpdateStory(self.BandID, 2)
    self.GuideCondition:GetViewModel():UpdateGuideCondition(self.BandID)
    self:UpdateRedDot()
end

function TouringBandGuidePanelView:OnGroupStateChangedTab(Index)
    self.SwitcherContent:SetActiveWidgetIndex(Index - 1)

    if Index == 2 then
        self:DelRedDot()
    end
end

function TouringBandGuidePanelView:OnToggleSwitchStateChangedEvent(ToggleButton, NewState, LastState)
    if NewState == EToggleButtonState.Unchecked then
        local IsUnLock = TouringBandMgr:IsBandUnLockByID(self.BandID)
        UIUtil.SetIsVisible(self.CommTab, IsUnLock)
        self:PlayAnimation(self.AnimSwitchOn)
    else
        self:PlayAnimation(self.AnimSwitchOff)
    end
    self.BandTabVMAdapter:SetSelectedIndex(self.SelectIndex)
    self.BandTabVMAdapter:ScrollToIndex(self.SelectIndex)
    self.BandTabVMAdapter2:SetSelectedIndex(self.SelectIndex)
    self.BandTabVMAdapter2:ScrollToIndex(self.SelectIndex)
end

function TouringBandGuidePanelView:OnClickedBack()
    self:Hide()
end

function TouringBandGuidePanelView:UpdateRedDot()
    if self.ViewModel == nil or self.ViewModel.SelectBandID == nil then
        return
    end

    local IsShow = false
    local RedDotList = TouringBandMgr:GetCustomizeRedDotList()
    local StoryStateList = TouringBandMgr:GetBandStoryLockState(self.ViewModel.SelectBandID)
    for Index = 1, #StoryStateList do
        if StoryStateList[Index].Lock == false then
            local RedDotName = "TouringBand" .. self.ViewModel.SelectBandID .. "StoryIndex" .. Index
            local IsSave = false
            for __, ItemName in pairs(RedDotList) do
                if RedDotName == ItemName then
                    IsSave = true
                end
            end
            IsShow = not IsSave
        end
    end

    if self.RedDotStory and self.RedDotStory.ItemVM then
        self.RedDotStory.ItemVM.IsVisible = IsShow
    end
end

function TouringBandGuidePanelView:DelRedDot()
    if self.ViewModel == nil or self.ViewModel.SelectBandID == nil then
        return
    end

    if self.RedDotStory == nil or self.RedDotStory.ItemVM == nil then
        return
    end

    local IsShow = self.RedDotStory.ItemVM.IsVisible
    if IsShow then
        local StoryStateList = TouringBandMgr:GetBandStoryLockState(self.ViewModel.SelectBandID)
        for Index = 1, #StoryStateList do
            if StoryStateList[Index].Lock == false then
                local RedDotName = "TouringBand" .. self.ViewModel.SelectBandID .. "StoryIndex" .. Index
                TouringBandMgr:AddCustomizeRedDotName(RedDotName)
            end
        end
        self.RedDotStory.ItemVM.IsVisible = false
    end
end

return TouringBandGuidePanelView