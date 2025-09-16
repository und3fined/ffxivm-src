---
--- Author: Administrator
--- DateTime: 2023-12-25 10:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local TipsUtil = require("Utils/TipsUtil")
local HelpInfoUtil = require("Utils/HelpInfoUtil")

local MajorUtil = require("Utils/MajorUtil")
local ProtoCS = require("Protocol/ProtoCS")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local ProtoCommon = require("Protocol/ProtoCommon")
local BuddyEquipCfg = require("TableCfg/BuddyEquipCfg")
local RideCfg = require("TableCfg/RideCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local CollectionAwardUtil = require("Game/Guide/CollectionAwardUtil")
local ModelDefine = require("Game/Model/Define/ModelDefine")

local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local EventID = require("Define/EventID")

local ChocoboMgr = nil
local ChocoboShowModelMgr = nil
local BuddyMgr = nil
local LSTR = nil

---@class ChocoboCodexArmorPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BodyGetWay UTableView
---@field Btn UFButton
---@field BtnAppearance UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnComment UFButton
---@field BtnInfor UFButton
---@field BtnReward UFButton
---@field BtnToGet UFButton
---@field CommGesture_UIBP CommGestureView
---@field EFF_Reward UFCanvasPanel
---@field EFF_RewardFull UFCanvasPanel
---@field Empty CommBackpackEmptyView
---@field EmptyArmors CommBackpackEmptyView
---@field HeadGetWay UTableView
---@field HorizontalName UFHorizontalBox
---@field ImageRole UFImage
---@field ImgChestIcon UImage
---@field LegGetWay UTableView
---@field PanelGetWayTips UFCanvasPanel
---@field PanelRight UFCanvasPanel
---@field RadialProcess URadialImage
---@field RichTextID URichTextBox
---@field SearchBar CommSearchBarView
---@field SingleBoxNotCollect CommSingleBoxView
---@field TableViewArmors UTableView
---@field TextArmorName UFTextBlock
---@field TextBody UFTextBlock
---@field TextGetWay UFTextBlock
---@field TextHead UFTextBlock
---@field TextLeg UFTextBlock
---@field TextName UFTextBlock
---@field TextProcess UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTitle02 UFTextBlock
---@field TextToGet UFTextBlock
---@field ToggleBtnRide UToggleButton
---@field ToggleBtnRole UToggleButton
---@field ToggleBtnSwitch UToggleButton
---@field VerticalBtns UFVerticalBox
---@field AnimChangeArmors UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimPanelGetWayTipsIn UWidgetAnimation
---@field AnimUpdateTableViewArmors UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboCodexArmorPanelView = LuaClass(UIView, true)

function ChocoboCodexArmorPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BodyGetWay = nil
	--self.Btn = nil
	--self.BtnAppearance = nil
	--self.BtnClose = nil
	--self.BtnComment = nil
	--self.BtnInfor = nil
	--self.BtnReward = nil
	--self.BtnToGet = nil
	--self.CommGesture_UIBP = nil
	--self.EFF_Reward = nil
	--self.EFF_RewardFull = nil
	--self.Empty = nil
	--self.EmptyArmors = nil
	--self.HeadGetWay = nil
	--self.HorizontalName = nil
	--self.ImageRole = nil
	--self.ImgChestIcon = nil
	--self.LegGetWay = nil
	--self.PanelGetWayTips = nil
	--self.PanelRight = nil
	--self.RadialProcess = nil
	--self.RichTextID = nil
	--self.SearchBar = nil
	--self.SingleBoxNotCollect = nil
	--self.TableViewArmors = nil
	--self.TextArmorName = nil
	--self.TextBody = nil
	--self.TextGetWay = nil
	--self.TextHead = nil
	--self.TextLeg = nil
	--self.TextName = nil
	--self.TextProcess = nil
	--self.TextTitle = nil
	--self.TextTitle02 = nil
	--self.TextToGet = nil
	--self.ToggleBtnRide = nil
	--self.ToggleBtnRole = nil
	--self.ToggleBtnSwitch = nil
	--self.VerticalBtns = nil
	--self.AnimChangeArmors = nil
	--self.AnimIn = nil
	--self.AnimPanelGetWayTipsIn = nil
	--self.AnimUpdateTableViewArmors = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboCodexArmorPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommGesture_UIBP)
	self:AddSubView(self.Empty)
	self:AddSubView(self.EmptyArmors)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.SingleBoxNotCollect)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboCodexArmorPanelView:OnInit()
	ChocoboMgr = _G.ChocoboMgr
	ChocoboShowModelMgr = _G.ChocoboShowModelMgr
	BuddyMgr = _G.BuddyMgr
	LSTR = _G.LSTR
	self.ViewModel = _G.ChocoboCodexArmorPanelVM
	self.SearchText = ""
	self.SelectedSuit = nil 

	self.ArmorsTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewArmors, self.OnArmorsSelectChange, true)
	self.ArmorsTableView:SetScrollbarIsVisible(false)

	self.HeadGetWayAdapter = UIAdapterTableView.CreateAdapter(self, self.HeadGetWay, nil, nil)
	self.BodyGetWayAdapter = UIAdapterTableView.CreateAdapter(self, self.BodyGetWay, nil, nil)
	self.LegGetWayAdapter = UIAdapterTableView.CreateAdapter(self, self.LegGetWay, nil, nil)

	local function OnClickedMap(ScreenPosition)
		self:OnClickBtnNone()
	end
	self.CommGesture_UIBP:SetOnPressCallback(OnClickedMap)

	self.Binders = {
		{"TextName", UIBinderSetText.New(self, self.TextName)},
		{"TextArmorName", UIBinderSetText.New(self, self.TextArmorName)},
		{"RichTextID", UIBinderSetText.New(self, self.RichTextID)},

		{"RadialProcess", UIBinderSetPercent.New(self, self.RadialProcess) },
		{"TextProcess", UIBinderSetText.New(self, self.TextProcess)},
		{"TextProcess", UIBinderSetText.New(self, self.TextTitle02)},
		{"ArmorList", UIBinderUpdateBindableList.New(self, self.ArmorsTableView) },
		{"EmptyVisible", UIBinderSetIsVisible.New(self, self.Empty,false,true) },
		{"EmptyArmorsVisible", UIBinderSetIsVisible.New(self, self.EmptyArmors,false,true) },
		{"BtnSwitchVisible", UIBinderSetIsVisible.New(self, self.ToggleBtnSwitch,false,true) },
        
		{"PanelRightVisible", UIBinderSetIsVisible.New(self, self.PanelRight,false,false) },
		{"GestureVisible", UIBinderSetIsVisible.New(self, self.CommGesture_UIBP,false,true) },
		{"BtnsVisible", UIBinderSetIsVisible.New(self, self.VerticalBtns,false,true) },
        {"ChocoboNameVisible", UIBinderSetIsVisible.New(self, self.HorizontalName,false,true) },

		{"ToggleSwitchChecked", UIBinderSetCheckedState.New(self, self.ToggleBtnSwitch)},
		{"ToggleShowRoleChecked", UIBinderSetCheckedState.New(self, self.ToggleBtnRole)},
		{"ToggleMountChecked", UIBinderSetCheckedState.New(self, self.ToggleBtnRide)},
	}
end

function ChocoboCodexArmorPanelView:OnDestroy()

end

function ChocoboCodexArmorPanelView:OnShow()
    self.TextTitle:SetText(LSTR(670001))
    self.TextBody:SetText(LSTR(670004))
	self.TextHead:SetText(LSTR(670003))
	self.TextLeg:SetText(LSTR(670005))	
    self.TextGetWay:SetText(LSTR(670002))	
	self.TextToGet:SetText(LSTR(670006))
	self.EmptyArmors:SetTipsContent(LSTR(670008))
    self.EmptyArmors:ShowPanelBtn(false)
	self.SingleBoxNotCollect:SetText(LSTR(670009))
	self.SearchBar:SetHintText(LSTR(670007))
	self.Empty:SetTipsContent(LSTR(670019))
	self.Empty:ShowPanelBtn(false)

	local _IsModuelOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBuddy)
	if _IsModuelOpen then
		BuddyMgr:ReqUsedColor()
		BuddyMgr:ReqUsedArmor()
		UIUtil.SetIsVisible(self.BtnAppearance, true, true)
	else
		UIUtil.SetIsVisible(self.BtnAppearance, false, false)
	end
	
	self:PlayAnimation(self.AnimIn)

	local ShowCollected = true
	self.SingleBoxNotCollect:SetChecked(not ShowCollected)
	self.ViewModel:SetShowCollected(ShowCollected)
    self.ViewModel:UpdateChocobo()
	self.ViewModel:SetSwitchChecked(false)

	self.SearchText = ""
	self.ViewModel:SearchData(self.SearchText)
    self.ViewModel:UpdateArmorList()  
	local SelectIndex = self.ViewModel:GetNewSuitIndex()
    self:OnSelectItemChanged(SelectIndex)
	_G.LightMgr:EnableUIWeather(ChocoboDefine.ChocoboCodexLightID)
end

function ChocoboCodexArmorPanelView:OnHide()
	_G.LightMgr:DisableUIWeather()
	_G.ChocoboCodexArmorPanelVM:RemoveAllRedDot()
	local Visible = UIUtil.IsVisible(self.PanelGetWayTips)
	if Visible then 
		UIUtil.SetIsVisible(self.PanelGetWayTips, false)
	end

	if UIViewMgr:IsViewVisible(UIViewID.BuddySurfacePanel) then
		ChocoboShowModelMgr:ShowChocobo(true)
	else
		ChocoboShowModelMgr:OnHide()
	end
end

function ChocoboCodexArmorPanelView:OnActive()
	self:ShowChocoboModelActor()
end

function ChocoboCodexArmorPanelView:OnInactive()
	ChocoboShowModelMgr:ShowChocobo(true)
end

function ChocoboCodexArmorPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAppearance, self.OnClickBtnAppearance)
	UIUtil.AddOnClickedEvent(self, self.BtnInfor, self.OnClickBtnInfor)
	UIUtil.AddOnClickedEvent(self, self.BtnComment, self.OnClickBtnComment)
	UIUtil.AddOnClickedEvent(self,self.BtnReward,self.OnClickBtnReward)
	UIUtil.AddOnClickedEvent(self, self.BtnToGet, self.OnClickBtnGetWay)
    UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickBtnNone)

	UIUtil.AddOnClickedEvent(self, self.ToggleBtnSwitch, self.OnToggleBtnSwitchClick)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnRide, self.OnToggleBtnRideClick)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnRole, self.OnToggleBtnRoleClick)

	self.SingleBoxNotCollect:SetStateChangedCallback(self, self.OnStateChangedCallback)
	self.SearchBar:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnClickCancelSearch)
	UIUtil.AddOnFocusLostEvent(self, self.SearchBar.TextInput, self.OnTextFocusLost)
end

function ChocoboCodexArmorPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ChocoboCodexArmorUpdate, self.OnGameEventArmorUpdate)
end

function ChocoboCodexArmorPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ChocoboCodexArmorPanelView:OnClickBtnAppearance()
	if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDChocoboArmorCollect) then
        return
    end

	if UIViewMgr:IsViewVisible(UIViewID.BuddySurfacePanel) then
		self:Hide()
	end
	
	local ID = BuddyMgr.BuddyID
	local IsCheckedBuddy = self.ViewModel:SwitchChecked()
	if IsCheckedBuddy then
		local ChocoboVM, IsSuc = ChocoboMgr:GetRaceChocoboVM()
		if IsSuc then
			ID = ChocoboVM.ChocoboID
		end
	end
	
	UIViewMgr:ShowView(UIViewID.BuddySurfacePanel, {ID = ID, FromViewID = self.ViewID})
end

function ChocoboCodexArmorPanelView:OnClickBtnInfor()
	local tipsContent = RichTextUtil.GetText(string.format("%s", self.ViewModel.TextArmorName), "d1ba8eff")..string.format("\n%s",self.ViewModel.Description)

	local Dir = 2
	local Offset, Alignment = HelpInfoUtil.GetOffsetAndAlignment(self.BtnInfor, Dir)
	TipsUtil.ShowInfoTips(tipsContent, self.BtnInfor, Offset, Alignment, false)
end

function ChocoboCodexArmorPanelView:OnClickBtnComment()
	local function Callback()
	end

	local MsgContent = LSTR(670011)   --留言板功能，敬请期待...
	MsgBoxUtil.MessageBox(MsgContent, LSTR(10002), LSTR(10003), Callback)
end

function ChocoboCodexArmorPanelView:OnToggleBtnSwitchClick()
	local IsCheckedBuddy = self.ViewModel:SwitchChecked()
	self.ViewModel:SetSwitchChecked(not IsCheckedBuddy)

	if IsCheckedBuddy then
		local Color = BuddyMgr:GetChocoboColor(BuddyMgr.BuddyID)
		if Color ~= nil then
			ChocoboShowModelMgr:SetChocoboColor(Color.RGB)
		end

		local BuddyName = _G.BuddyMgr:GetBuddyName()
		if string.isnilorempty(BuddyName) then
			self.ViewModel.TextName = LSTR(670010)  --陆行鸟搭档
		else
			self.ViewModel.TextName = BuddyName
		end
	else
		local ChocoboVM, IsSuc = ChocoboMgr:GetRaceChocoboVM()
		if IsSuc then
			self.ViewModel.TextName = ChocoboVM.Name
			ChocoboShowModelMgr:SetChocoboColor(ChocoboVM.ColorID)
		end
	end
	ChocoboShowModelMgr:SetChocoboArmor(self.Armor)
	ChocoboShowModelMgr:UpdateUIChocoboModel()
end

function ChocoboCodexArmorPanelView:OnToggleBtnRoleClick()
	local IsChecked = self.ViewModel:ShowRoleChecked()
	self.ViewModel:SetShowRoleChecked(not IsChecked)

	local IsMount = self.ViewModel:MountChecked()
	if IsMount then
		ChocoboShowModelMgr:ShowMajor(false)
	else
		ChocoboShowModelMgr:ShowMajor(not IsChecked)
	end
end

function ChocoboCodexArmorPanelView:OnToggleBtnRideClick()
	self.ViewModel:SetShowRoleChecked(true)	
	local IsChecked = self.ViewModel:MountChecked()
	self.ViewModel:SetMountChecked(not IsChecked)

	ChocoboShowModelMgr:ShowMajor(IsChecked)
end

function ChocoboCodexArmorPanelView:OnClickBtnReward()
	local CollectedAward = self.ViewModel:GetCollectedAward()

	local Params = {
		CollectedNum = self.ViewModel:GetPartOwnedCount(),
        MaxCollectNum = self.ViewModel:GetPartCount(),
        AwardList = CollectedAward,
	}
    
    local function OnGetAwardClicked(Index, ItemData, ItemView)
        if ItemData then
            local IsGetProgress = ItemData.IsGetProgress
            local IsCollectedAward = ItemData.IsCollectedAward
            local AwardID = ItemData.CollectTargetNum
            if IsGetProgress and not IsCollectedAward then
            	_G.ChocoboCodexArmorMgr:ChocoboGetPartProscessAwardReq(AwardID)
            end
        end
    end

    CollectionAwardUtil.ShowCollectionAwardView(UIViewID.ChocoboCodexArmorPanelView, Params.CollectedNum, Params.MaxCollectNum, 
                                                Params.AwardList,  OnGetAwardClicked)
end

function ChocoboCodexArmorPanelView:OnClickBtnGetWay()
	local Visible = UIUtil.IsVisible(self.PanelGetWayTips)
	UIUtil.SetIsVisible(self.PanelGetWayTips, not Visible)
	if not Visible then
		self:UpdateGetWayList()
		self:PlayAnimation(self.AnimPanelGetWayTipsIn) 
	end
end

function ChocoboCodexArmorPanelView:OnSelectItemChanged(Value)
	self.ArmorsTableView:SetSelectedIndex(Value)
	self.ArmorsTableView:ScrollToIndex(Value)
end


function ChocoboCodexArmorPanelView:OnClickBtnNone()
    UIUtil.SetIsVisible(self.PanelGetWayTips, false)
end

function ChocoboCodexArmorPanelView:UpdateGetWayList()
	if self.SelectedSuit == nil then return end
	local ArmorSuit = self.SelectedSuit

	if ArmorSuit.HeadItem ~= nil then 
		UIUtil.SetIsVisible(self.TextHead, true)
		local HeadGetWayItems = ItemUtil.GetItemGetWayList(ArmorSuit.HeadItem.ItemID)
		self.HeadGetWayAdapter:UpdateAll(HeadGetWayItems)
	else 
		self.HeadGetWayAdapter:ClearChildren()
		UIUtil.SetIsVisible(self.TextHead, false)
	end
	
	if ArmorSuit.BodyItem ~= nil then 
		UIUtil.SetIsVisible(self.TextBody, true)
		local BodyGetWayItems = ItemUtil.GetItemGetWayList(ArmorSuit.BodyItem.ItemID)	
		self.BodyGetWayAdapter:UpdateAll(BodyGetWayItems)
	else
		self.BodyGetWayAdapter:ClearChildren()
		UIUtil.SetIsVisible(self.TextBody, false)
	end 

	if ArmorSuit.FootItem ~= nil then 
		UIUtil.SetIsVisible(self.TextLeg, true)
		local FootGetWayItems = ItemUtil.GetItemGetWayList(ArmorSuit.FootItem.ItemID)
		self.LegGetWayAdapter:UpdateAll(FootGetWayItems)
	else
		self.LegGetWayAdapter:ClearChildren()
		UIUtil.SetIsVisible(self.TextLeg, false)
	end
end

function ChocoboCodexArmorPanelView:OnArmorsSelectChange(Index, ItemData, ItemView, IsByClick)
	local ArmorSuits = self.ViewModel:GetArmorSuits()
	if ArmorSuits == nil or ArmorSuits[Index] == nil then return end

	self.SelectedSuit = ArmorSuits[Index]
	local ArmorSuit = ArmorSuits[Index]

	self:PlayAnimation(self.AnimChangeArmors)

	self.ViewModel:UpdateSuit(ArmorSuit)	

    UIUtil.SetIsVisible(self.PanelGetWayTips, false)

	self.Armor = {}
	for i = 1,3 do
        local ArmorSlot = ItemData.ArmorPartList:Get(i)
		if ArmorSlot ~= nil then
			local ItemID = ArmorSlot.ItemID
			--if not ArmorSlot.IsMask then
			if ArmorSuit.IsSpoiler ~= 1 then
				if ArmorSlot.ChocoboArmorPos == ProtoCS.ChocoboArmorPos.ChocoboArmorPosHead then
					self.Armor.Head = ItemID
				elseif ArmorSlot.ChocoboArmorPos == ProtoCS.ChocoboArmorPos.ChocoboArmorPosBody then
					self.Armor.Body = ItemID
				elseif ArmorSlot.ChocoboArmorPos == ProtoCS.ChocoboArmorPos.ChocoboArmorPosLeg then
					self.Armor.Feet = ItemID
				end
			else
				if ArmorSlot.ChocoboArmorPos == ProtoCS.ChocoboArmorPos.ChocoboArmorPosHead then
					self.Armor.Head = 0
				elseif ArmorSlot.ChocoboArmorPos == ProtoCS.ChocoboArmorPos.ChocoboArmorPosBody then
					self.Armor.Body = 0
				elseif ArmorSlot.ChocoboArmorPos == ProtoCS.ChocoboArmorPos.ChocoboArmorPosLeg then
					self.Armor.Feet = 0
				end
			end
            if IsByClick then 
			    self.ViewModel:RemoveReddot(ItemID)
            end
		end
	end

	if ArmorSuit.IsSpoiler == 1 then  
		ChocoboShowModelMgr:ShowMajor(false)
		ChocoboShowModelMgr:ShowChocobo(false)
	else 
		ChocoboShowModelMgr:ShowChocobo(true)
		
		if IsByClick then
			ChocoboShowModelMgr:SetChocoboArmor(self.Armor)
			ChocoboShowModelMgr:UpdateUIChocoboModel()
		else
			self:ShowChocoboModelActor()
		end
	end
end

function ChocoboCodexArmorPanelView:ShowChocoboModelActor()
	local CallBack = function(View)
		if not View then
			return
		end
		
		ChocoboShowModelMgr:ShowMajor(false)

		local RaceChocoboVM, IsSuc = ChocoboMgr:GetRaceChocoboVM()
		local UseChocoboModel = false
		local IsSwitchVisible = View.ViewModel.BtnSwitchVisible
		local IsCheckedBuddy = View.ViewModel:SwitchChecked()

		if IsSwitchVisible then
			if IsSuc and IsCheckedBuddy then
				UseChocoboModel = true
			end
		else
			UseChocoboModel = IsSuc
		end
		
		if UseChocoboModel then
			-- 使用陆行鸟模型
			View.ViewModel.TextName = RaceChocoboVM.Name
			ChocoboShowModelMgr:SetChocoboColor(RaceChocoboVM.ColorID)
		else
			-- 使用搭档模型
			local Color = BuddyMgr:GetChocoboColor(BuddyMgr.BuddyID)
			if Color ~= nil then
				ChocoboShowModelMgr:SetChocoboColor(Color.RGB)
			else
				ChocoboShowModelMgr:SetChocoboColor(0)
			end

			local BuddyName = _G.BuddyMgr:GetBuddyName()
			if string.len(BuddyName) == 0 then
				View.ViewModel.TextName = LSTR(670010)  -- 陆行鸟搭档
			else
				View.ViewModel.TextName = BuddyName
			end
		end

		ChocoboShowModelMgr:ResetChocoboModelScale()
		ChocoboShowModelMgr:SetModelDefaultPos()
		ChocoboShowModelMgr:UpdateUIChocoboModel(function(InView)
			if not InView or not InView.ShowChocoboModel then
				return
			end
			InView:ShowChocoboModel()
		end)
		ChocoboShowModelMgr:EnableRotator(true)
		ChocoboShowModelMgr:BindCommGesture(View.CommGesture_UIBP)
		self:ShowChocoboModel()
	end
	
	ChocoboShowModelMgr:SetUIType(ProtoRes.CHOCOBO_MODE_SHOW_UI_TYPE.CHOCOBO_MODE_SHOW_UITYPE_CODEX)
	ChocoboShowModelMgr:SetImageRole(self.ImageRole)
	ChocoboShowModelMgr:SetChocoboArmor(self.Armor)
	if ChocoboShowModelMgr:IsCreateFinish() then
		CallBack(self)
	else
		ChocoboShowModelMgr:CreateModel(self, CallBack)
		ChocoboShowModelMgr:ShowMajor(false)
	end
end

function ChocoboCodexArmorPanelView:OnStateChangedCallback(IsChecked, Type)
	if self.ViewModel == nil then return end
	
	self.ViewModel:SetShowCollected(not IsChecked)
	self.ViewModel:SearchData(self.SearchText)
	self.ViewModel:UpdateArmorList()
	local SelectedIndex = self.ViewModel:FindSuitIndex(self.SelectedSuit)
    self:OnSelectItemChanged(SelectedIndex)
	self:ShowChocoboModel()
end

function ChocoboCodexArmorPanelView:OnTextChangeCallback(Text)
	if self.ViewModel == nil then return end

	self.SearchText = Text
	_G.ChocoboCodexArmorPanelVM:SearchData(Text)
	self.ViewModel:UpdateArmorList()
	local SelectedIndex = self.ViewModel:FindSuitIndex(self.SelectedSuit)
    self:OnSelectItemChanged(SelectedIndex)
	self:ShowChocoboModel()
end

function ChocoboCodexArmorPanelView:OnSearchTextCommitted(Text)
	if self.ViewModel == nil then return end

	--self.SingleBoxNotCollect:SetChecked(false)
	--self.ViewModel:SetShowCollected(false)

	self.SearchText = Text
	_G.ChocoboCodexArmorPanelVM:SearchData(Text)
	self.ViewModel:UpdateArmorList()
	local SelectedIndex = self.ViewModel:FindSuitIndex(self.SelectedSuit)
    self:OnSelectItemChanged(SelectedIndex)
	self:ShowChocoboModel()
end

function ChocoboCodexArmorPanelView:OnClickCancelSearch()
	if self.ViewModel == nil then return end

	self.SearchText = ""
	--self.SingleBoxNotCollect:SetChecked(false)
	--self.ViewModel:SetShowCollected(false)
	_G.ChocoboCodexArmorPanelVM:SearchData()
	self.ViewModel:UpdateArmorList()
    local SelectedIndex = self.ViewModel:FindSuitIndex(self.SelectedSuit)
    self:OnSelectItemChanged(SelectedIndex)
	self:ShowChocoboModel()
end

function ChocoboCodexArmorPanelView:OnGameEventArmorUpdate()
	if self.ViewModel == nil then return end

    self.ViewModel:SearchData()
    self.ViewModel:UpdateArmorList()  
	local SelectIndex = self.ViewModel:GetNewSuitIndex()
    self:OnSelectItemChanged(SelectIndex)
end

function ChocoboCodexArmorPanelView:ShowChocoboModel()
	if self.ViewModel == nil then return end

	if self.ViewModel.EmptyArmorsVisible or not self.ViewModel.ChocoboNameVisible then 
		ChocoboShowModelMgr:ShowMajor(false)
		ChocoboShowModelMgr:ShowChocobo(false)
	else
		ChocoboShowModelMgr:ShowChocobo(true)
	end
end

function ChocoboCodexArmorPanelView:OnTextFocusLost()
    UIUtil.SetIsVisible(self.SearchBar.BtnCancelNode, true,true)
end

return ChocoboCodexArmorPanelView