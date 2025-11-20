---
--- Author: Administrator
--- DateTime: 2024-07-08 14:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PhotoDefine = require("Game/Photo/PhotoDefine")
local ActorUtil = require("Utils/ActorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local PhotoActorUtil = require("Game/Photo/Util/PhotoActorUtil")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local PhotoActionVM
local PhotoVM
local PhotoMgr
local ShowTips = MsgTipsUtil.ShowTips

---@class PhotoActionPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommTabs CommTabsView
---@field FTextBlock_112 UFTextBlock
---@field ImgBuySelect UFImage
---@field ImgGiftSelect UFImage
---@field ImgPlay UFImage
---@field PanelActBar UFCanvasPanel
---@field PanelAction UFCanvasPanel
---@field ProbarAct UFProgressBar
---@field RedDot CommonRedDot2View
---@field RedDot02 CommonRedDot2View
---@field Slider USlider
---@field TableView_76 UTableView
---@field TextSwitchBuy UFTextBlock
---@field TextSwitchGift UFTextBlock
---@field ToggleBtnBuy UToggleButton
---@field ToggleBtnGift UToggleButton
---@field ToggleBtnStart UToggleButton
---@field ToggleGroupSwitch UToggleGroup
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoActionPanelView = LuaClass(UIView, true)

function PhotoActionPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommTabs = nil
	--self.FTextBlock_112 = nil
	--self.ImgBuySelect = nil
	--self.ImgGiftSelect = nil
	--self.ImgPlay = nil
	--self.PanelActBar = nil
	--self.PanelAction = nil
	--self.ProbarAct = nil
	--self.RedDot = nil
	--self.RedDot02 = nil
	--self.Slider = nil
	--self.TableView_76 = nil
	--self.TextSwitchBuy = nil
	--self.TextSwitchGift = nil
	--self.ToggleBtnBuy = nil
	--self.ToggleBtnGift = nil
	--self.ToggleBtnStart = nil
	--self.ToggleGroupSwitch = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoActionPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommTabs)
	-- self:AddSubView(self.RedDot)
	-- self:AddSubView(self.RedDot02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoActionPanelView:OnInit()
	PhotoActionVM = _G.PhotoActionVM
	PhotoVM = _G.PhotoVM
	PhotoMgr = _G.PhotoMgr

	self.TableViewActionAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_76)
	self.TableViewActionAdapter:SetOnClickedCallback(self.OnActionItemClicked)

	self.BinderAction =
	{
		{ "CurSeltItemIdx",   UIBinderValueChangedCallback.New(self, nil, self.OnSeltItem) },
		{ "CurSeltItemIdx",   UIBinderSetSelectedIndex.New(self, self.TableViewActionAdapter, true)},
		{ "ActionItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewActionAdapter) },
		{ "IsPauseAnim",      UIBinderSetIsChecked.New(self, self.ToggleBtnStart) },
		{ "IsShowSlider", 	  UIBinderSetIsVisible.New(self, self.PanelActBar) },
		{ "CurAniPct",   	  UIBinderValueChangedCallback.New(self, nil, self.OnAniPctChg) },
	}

	self.CommTabs:SetCallBack(self, self.OnTabs)
end

function PhotoActionPanelView:OnSeltItem(Idx)
	if not Idx then
		self.LastIdx = nil
		-- self.TableViewActionAdapter:CancelSelected()
	end
end

function PhotoActionPanelView:OnTabs(Idx)
	PhotoActionVM:SetActionType(Idx - 1)
	self.LastIdx = PhotoActionVM.Type and PhotoActionVM.ItemIdxMap[PhotoActionVM.Type] or nil
end

function PhotoActionPanelView:OnDestroy()
	PhotoActionVM:ClearVMData()
end

local ListData = { { Name = _G.LSTR(630049) }, { Name = _G.LSTR(630050) }}
function PhotoActionPanelView:OnShow()
	self.CommTabs:SetTextColor("#d5d5d5")
	self.CommTabs:UpdateItems(ListData, 1)
	PhotoActionVM:UpdateListVM()
	PhotoActionVM:UpdateCurIdx(true)
end

function PhotoActionPanelView:OnHide()

end

function PhotoActionPanelView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 0.01, 0)
end

function PhotoActionPanelView:OnTimer()
	if PhotoActionVM.IsPauseAnim then
		return
	end

	local Pct = PhotoMgr:GetPlayingActionMontagePct() or 0
	PhotoActionVM.CurAniPct = Pct
end

function PhotoActionPanelView:OnRegisterUIEvent()
	UIUtil.AddOnValueChangedEvent(self, 		self.Slider, 				self.OnValueChangedScale)
	UIUtil.AddOnStateChangedEvent(self, 		self.ToggleBtnStart, 		self.OnTogPlay)

end

function PhotoActionPanelView:OnTogPlay(Tog, Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	PhotoActionVM:SetAmimIsPause(IsChecked)
	-- -- 暂停取消同步个人暂停
	if not IsChecked then
		PhotoVM:SetIsPauseSelect(false)
	end
end

function PhotoActionPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.EmotionRefreshItemUI, self.OnEveEmotionRefreshItemUI)
    self:RegisterGameEvent(_G.EventID.PhotoSeltEntChg, self.OnEvePhotoSeltChg)
end

function PhotoActionPanelView:OnEveEmotionRefreshItemUI()
	if PhotoMgr:IsCurSeltMajor() then
		PhotoActionVM:UpdateListVM()
		PhotoActionVM:UpdateCurIdx(true)
	else
		PhotoActionVM:ChangedSelecteActor()
	end
end

function PhotoActionPanelView:OnEvePhotoSeltChg()
	if PhotoMgr:IsCurSeltMajor() then
		PhotoActionVM:UpdateListVM()
		PhotoActionVM:UpdateCurIdx(true)
	else
		PhotoActionVM:ChangedSelecteActor()
	end
end

function PhotoActionPanelView:OnRegisterBinder()
	self:RegisterBinders(PhotoActionVM, 		self.BinderAction)
end

---
function PhotoActionPanelView:OnActionItemClicked(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end

	if Index == self.LastIdx then
		PhotoActionVM:ResetRoleActAni()
		return
	end

	local EntID = PhotoMgr.SeltEntID
	if PhotoActorUtil.IsActorMoving(EntID) then
		ShowTips(_G.LSTR(630060))
		return
	end

	if ItemData.Type == PhotoDefine.AnimType.Movement then
		local bIsRiding = ActorUtil.IsInRide(EntID)	--坐骑中
		if bIsRiding then
			ShowTips(_G.LSTR(630045))
			return
		end
	end

	self.LastIdx = Index
	PhotoVM:SetIsPauseSelect(false)
	--PhotoVM:SetIsPauseAll(false)
	PhotoActionVM:SetSelectedActionItem(Index, ItemData.ID)
end

function PhotoActionPanelView:OnAniPctChg(Pct)
	if Pct then
		self.Slider:SetValue(Pct)
		self.ProbarAct:SetPercent(Pct)
	end
end

function PhotoActionPanelView:OnValueChangedScale(_, Value)
	PhotoMgr:SetPlayingActionMontagePct(Value)
	self.ProbarAct:SetPercent(Value)
	_G.FLOG_INFO('[Photo][PhotoActionPanelView] AnimPct = ' .. tostring(Value))
	-- if (not _G.PhotoMgr:CurRoleInPlayingAni()) PhotoActionVM.IsPauseAnim then

	-- end
end

return PhotoActionPanelView