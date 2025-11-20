---
--- Author: Administrator
--- DateTime: 2025-07-14 10:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBindableList = require("UI/UIBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ItemVM = require("Game/Item/ItemVM")
local ItemDefine = require("Game/Item/ItemDefine")
local SidePopUpDefine = require("Game/SidePopUp/SidePopUpDefine")
local AudioUtil = require("Utils/AudioUtil")
local SoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_Prize.Play_FM_Prize'"
local ItemDelayTime = 0.16
local OneRowDelayTime = 1.5
local LSTR = _G.LSTR

local RewardsType = {
	Appearance = 1,
	HairStyle = 2,
}


---@class CommRewardAppearancePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck CommBtnLView
---@field BtnClose CommBtnLView
---@field CommonPopUpBG CommonPopUpBGView
---@field PanelBtn UFHorizontalBox
---@field PanelBtnCheck UFCanvasPanel
---@field PanelBtnClose UFCanvasPanel
---@field RichTextHint URichTextBox
---@field TableViewRewardHairstyleList UTableView
---@field TableViewRewardList1 UTableView
---@field TableViewRewardList2 UTableView
---@field TextCloseTips UFTextBlock
---@field TextReward UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommRewardAppearancePanelView = LuaClass(UIView, true)

function CommRewardAppearancePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.BtnClose = nil
	--self.CommonPopUpBG = nil
	--self.PanelBtn = nil
	--self.PanelBtnCheck = nil
	--self.PanelBtnClose = nil
	--self.RichTextHint = nil
	--self.TableViewRewardHairstyleList = nil
	--self.TableViewRewardList1 = nil
	--self.TableViewRewardList2 = nil
	--self.TextCloseTips = nil
	--self.TextReward = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommRewardAppearancePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCheck)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommRewardAppearancePanelView:OnInit()
	self.ItemList =
	UIBindableList.New(
	ItemVM,
	{
		Source = ItemDefine.ItemSource.MatchReward,
		IsCanBeSelected = false,
		IsShowNum = true,
		IsDaily = false,
		IsShowSelectStatus = false,
	}
	)
	self.TableViewAdapter1 =
		UIAdapterTableView.CreateAdapter(self, self.TableViewRewardList1, nil, true, false)
	self.TableViewAdapter2 =
		UIAdapterTableView.CreateAdapter(self, self.TableViewRewardList2, nil, true, false)
	self.TableViewAdapter3 =
		UIAdapterTableView.CreateAdapter(self, self.TableViewRewardHairstyleList, nil, true, false)

	self.CommonPopUpBG:SetHideOnClick(true)
	self.BtnLeft = self.BtnClose
	self.BtnRight = self.BtnCheck
end

function CommRewardAppearancePanelView:OnDestroy()

end

function CommRewardAppearancePanelView:OnShow()
    self.TextReward:SetText(LSTR(100033))     -- "获得物品"
    self.TextCloseTips:SetText(LSTR(100034))  -- "点击空白处关闭"
    -- self.CommCheckBox:SetText(LSTR(100014))   -- "跳过动画"

	-- self:ClearDrawReset()
	-- _G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.CommRewardPanel, true)

	local Params = self.Params 
    if Params == nil then
        return
    end
    self.CloseCallback = Params.CloseCallback
    self.HideClickItem = Params.HideClickItem

	if (Params.Title or "") ~= "" then
        self.TextReward:SetText(Params.Title)
    end

    UIUtil.SetIsVisible(self.PanelBtn, Params.ShowBtn == true , false)
    UIUtil.SetIsVisible(self.TextCloseTips, Params.TextCloseTips == true )
    UIUtil.SetIsVisible(self.PanelBtnClose, Params.ShowBtnLeft == true )
    UIUtil.SetIsVisible(self.PanelBtnCheck, Params.ShowBtnRight == true )
    UIUtil.SetIsVisible(self.RichTextHint, Params.ShowHint == true )
	self.CommonPopUpBG:SetHideOnClick(not (Params.HideBGCloseBC == true))
	self.BtnLeft:SetText(Params.BtnLeftText or "")
    self.BtnRight:SetText(Params.BtnRightText or "")
    self.BtnRightCB = Params.BtnRightCB
    self.BtnLeftCB = Params.BtnLeftCB
    self.RichTextHint:SetText(Params.HintText or "")
    AudioUtil.LoadAndPlayUISound(SoundPath)

	-- 外观列表
	if Params.AppearanceVMList then
		self:TableUpdateAll(RewardsType.Appearance, Params.AppearanceVMList)
		if Params.AppearanceVMList:Length() <= 6 then
			self:AutoPlayItemIn(RewardsType.Appearance, Params.AppearanceVMList)
		else
			self:AutoScrollDown(Params.AppearanceVMList, self.TableViewRewardList2, self.TableViewAdapter2)
		end
	end

	-- 发型列表
	if Params.HairStyleVMList then
		self:TableUpdateAll(RewardsType.HairStyle, Params.HairStyleVMList)
		self:AutoPlayItemIn(RewardsType.HairStyle, Params.HairStyleVMList)
	end
end

function CommRewardAppearancePanelView:OnHide()
    self.List3Timer = nil
end

function CommRewardAppearancePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnLeft, self.OnClickLeftBtnOp)
	UIUtil.AddOnClickedEvent(self, self.BtnRight, self.OnClickRightBtnOp)
end

function CommRewardAppearancePanelView:OnRegisterGameEvent()
end

function CommRewardAppearancePanelView:OnRegisterBinder()
end

function CommRewardAppearancePanelView:InitText()
end

function CommRewardAppearancePanelView:OnClickLeftBtnOp()
	if self.BtnLeftCB ~= nil then
		self.BtnLeftCB()
	end 
end

function CommRewardAppearancePanelView:OnClickRightBtnOp()
	if self.BtnRightCB ~= nil then
		self.BtnRightCB()
	end 
end

function CommRewardAppearancePanelView:TableUpdateAll(AdapterIndex, ItemVMList)
    local ItemNum = ItemVMList:Length() or 0
    UIUtil.SetIsVisible(self.TableViewRewardList1, false)
    UIUtil.SetIsVisible(self.TableViewRewardList2, false)
	--发型
    UIUtil.SetIsVisible(self.TableViewRewardHairstyleList, false)
    for i = 1, ItemNum do
        local ItemVM = ItemVMList:Get(i)
        ItemVM.RewardItemPlayAnimIn = false
        -- ItemVM:UpdateRewardItemPlayAnimIn(false)
    end
    if AdapterIndex == RewardsType.Appearance then
        if ItemNum > 6 then
            self.TableViewAdapter2:UpdateAll(ItemVMList)
            UIUtil.SetIsVisible(self.TableViewRewardList2, true, true)
            if ItemNum > 12 then
                self:AutoScrollDown(ItemVMList, self.TableViewRewardList2, self.TableViewAdapter2)
            else
                self:AutoPlayItemIn(RewardsType.Appearance, ItemVMList)
            end
        else
            self.TableViewAdapter1:UpdateAll(ItemVMList)
            UIUtil.SetIsVisible(self.TableViewRewardList1, true, true)
            self:AutoPlayItemIn(RewardsType.Appearance, ItemVMList)
        end
    else
        -- 发型
        self.TableViewAdapter3:UpdateAll(ItemVMList)
        UIUtil.SetIsVisible(self.TableViewRewardHairstyleList, true, true)
        self:AutoPlayItemIn(RewardsType.HairStyle, ItemVMList)
    end
end

function CommRewardAppearancePanelView:AutoScrollDown(ItemVMList, TableViewList, TableViewAdapter)
    local ItemNum = TableViewAdapter:GetNum()
    if ItemNum <= 0 then return end
    self.PlayedAnimFirstIn = true
	TableViewList:SetScrollEnabled(false)
    TableViewAdapter:ScrollToBottom()
    local ScrollLength = TableViewList:GetScrollOffset()
    TableViewAdapter:ScrollToTop()
    local LoopNum = math.ceil(ItemNum/6)
    local UnitOffset = (1 / LoopNum) * ScrollLength
    local SetOffset = 0
    local CutNum = 0
    local TimeCount = 0.0
    if self.List3Timer == nil then
    self.List3Timer = self:RegisterTimer(function()
        TimeCount = TimeCount + ItemDelayTime
        if CutNum ~= 0 and CutNum % 6 == 0 and TimeCount <= OneRowDelayTime then
            if TimeCount >= OneRowDelayTime then
                TimeCount = 0.0
            else
                return
            end
        end
        CutNum = CutNum + 1

        local ChildVM = ItemVMList:Get(CutNum)
        if ChildVM ~= nil then
            ChildVM.RewardItemPlayAnimIn = true
            -- ChildVM:UpdateRewardItemPlayAnimIn(true)
        end
        if CutNum % 6 == 1 and CutNum >= 12 then
            SetOffset = SetOffset + UnitOffset
			TableViewList:SetScrollOffset(SetOffset)
        end
        if CutNum >= ItemNum then
            TableViewList:ScrollToBottom()
			TableViewList:SetScrollEnabled(true)
            self.PlayedAnimFirstIn = nil
            self:UnRegisterTimer(self.List3Timer)
            self.List3Timer = nil
        end
    end, 0.05, ItemDelayTime, 0)
    end
end

-- 只有一列的时候出现的奖励列表不会超过6个
function CommRewardAppearancePanelView:AutoPlayItemIn(AdapterIndex, ItemVMList)
    local ItemNum = ItemVMList:Length()
    if ItemNum <= 0 then return end
    local CurTableViewRewardList
    local CurTableViewAdapter
    if AdapterIndex == RewardsType.Appearance then
        CurTableViewAdapter = self.TableViewAdapter1
        CurTableViewRewardList = self.TableViewRewardList1
    else
        CurTableViewAdapter = self.TableViewAdapter3
        CurTableViewRewardList = self.TableViewRewardHairstyleList
    end

    CurTableViewRewardList:SetScrollEnabled(false)
    local CutNum = 0 
    self.PlayedAnimFirstIn = true 
    
    self:RegisterTimer(function()
        CutNum = CutNum + 1
        local ChildVM = ItemVMList:Get(CutNum)
        if ChildVM ~= nil then
            ChildVM.RewardItemPlayAnimIn = true
        end
        if CutNum >= ItemNum then
            CurTableViewRewardList:SetScrollEnabled(true)
            self.PlayedAnimFirstIn = nil
        end
    end, 0.05, ItemDelayTime, ItemNum)
end

return CommRewardAppearancePanelView