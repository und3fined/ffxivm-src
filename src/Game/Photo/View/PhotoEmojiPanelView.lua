---
--- Author: Administrator
--- DateTime: 2024-07-08 14:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PhotoDefine = require("Game/Photo/PhotoDefine")

local PhotoEmojiVM
local PhotoVM
local PhotoMgr

---@class PhotoEmojiPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommTabs CommTabsView
---@field FTextBlock_112 UFTextBlock
---@field ImgPlay UFImage
---@field PanelEmoji UFCanvasPanel
---@field PanelEmojiProbar UFCanvasPanel
---@field ProbarEmoji UFProgressBar
---@field Slider USlider
---@field TableView UTableView
---@field ToggleBtnStart UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoEmojiPanelView = LuaClass(UIView, true)

function PhotoEmojiPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommTabs = nil
	--self.FTextBlock_112 = nil
	--self.ImgPlay = nil
	--self.PanelEmoji = nil
	--self.PanelEmojiProbar = nil
	--self.ProbarEmoji = nil
	--self.Slider = nil
	--self.TableView = nil
	--self.ToggleBtnStart = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoEmojiPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoEmojiPanelView:OnInit()
	PhotoVM = _G.PhotoVM
	PhotoMgr = _G.PhotoMgr
	PhotoEmojiVM = _G.PhotoEmojiVM

	self.TableViewEmojiAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView)
	self.TableViewEmojiAdapter:SetOnClickedCallback(self.OnEmojiItemClicked)
	self.CommTabs:SetCallBack(self, self.OnTabs)
	self.FTextBlock_112:SetText(_G.LSTR(630084))

	self.BinderEmoji = {
		{ "EmojiItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewEmojiAdapter) },
		{ "EmojiProbarIsVisibility", UIBinderSetIsVisible.New(self, self.PanelEmojiProbar) },
		{ "IsPauseEmojiAnim", UIBinderSetIsChecked.New(self, self.ToggleBtnStart) },
		{ "CurAnimPct", UIBinderValueChangedCallback.New(self, nil, self.OnAniPctChg) },
	}
end

function PhotoEmojiPanelView:OnTabs(Idx)
	PhotoEmojiVM:SetEmojiType(Idx - 1)
end

function PhotoEmojiPanelView:OnDestroy()
	PhotoEmojiVM:ClearVMData()
end

--local ListData = { { Name = _G.LSTR(630052) }}--, { Name = _G.LSTR(630053) }}
local ListData = { { Name = _G.LSTR(630052) }, { Name = _G.LSTR(630053) }}
function PhotoEmojiPanelView:OnShow()
	self.CommTabs:SetTextColor("#d5d5d5")
	self.CommTabs:UpdateItems(ListData, 1)
end

function PhotoEmojiPanelView:OnHide()

end

function PhotoEmojiPanelView:OnRegisterUIEvent()
	UIUtil.AddOnValueChangedEvent(self, self.Slider, self.OnValueChangedScale)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnStart, self.OnTogPlay)
end

function PhotoEmojiPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.PhotoSeltEntChg, self.OnEvePhotoSeltChg)
end

function PhotoEmojiPanelView:OnRegisterBinder()
	self:RegisterBinders(PhotoEmojiVM, self.BinderEmoji)
end

function PhotoEmojiPanelView:OnRegisterTimer()
	self:RegisterTimer(self.OnUpdateTimer, 0, 0.01, 0)
end

function PhotoEmojiPanelView:OnEvePhotoSeltChg()
	PhotoEmojiVM:UpdateListVM()
	if PhotoMgr:IsCurSeltMajor() then
		PhotoEmojiVM:UpdateCurIdx()
	end
end

function PhotoEmojiPanelView:OnEmojiItemClicked(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end

	if ItemData.Type == PhotoDefine.AnimType.Face and ItemData.ID == PhotoMgr.EmojiID then
		PhotoEmojiVM:ResetRoleActAni(true)
		return
	elseif ItemData.Type == PhotoDefine.AnimType.Mouth and ItemData.ID == PhotoMgr.MouthID then
		PhotoEmojiVM:ResetRoleActAni(false)
		return
	end

	PhotoVM:SetIsPauseSelect(false)
	--PhotoVM:SetIsPauseAll(false)
	PhotoEmojiVM:SetSelectedEmojiItem(Index, ItemData.ID)
	PhotoEmojiVM.EmojiProbarIsVisibility = ItemData.Type == PhotoDefine.AnimType.Mouth

	if ItemData.Type == PhotoDefine.AnimType.Face then
		PhotoMgr:SetEmojiID(ItemData.ID)
	elseif ItemData.Type == PhotoDefine.AnimType.Mouth then
		PhotoEmojiVM:SetAmimIsPause(false)
		PhotoMgr:SetMouthID(ItemData.ID)
	end
end

function PhotoEmojiPanelView:IsRecover(ItemData)
	if ItemData.Type == PhotoDefine.AnimType.Face and ItemData.ID == PhotoMgr.EmojiID then
		return true
	elseif ItemData.Type == PhotoDefine.AnimType.Mouth and ItemData.ID == PhotoMgr.MouthID then
		return true
	end
	return false
end

function PhotoEmojiPanelView:OnAniPctChg(Pct)
	if Pct then
		self.Slider:SetValue(Pct)
		self.ProbarEmoji:SetPercent(Pct)
	end
end

function PhotoEmojiPanelView:OnValueChangedScale(_, Value)
	PhotoMgr:SetPlayingEmojiMontagePct(Value)
	self.ProbarEmoji:SetPercent(Value)
	--_G.FLOG_INFO(string.format('[Photo][PhotoEmojiPanelView] AnimPct = %f', Value))
end

function PhotoEmojiPanelView:OnTogPlay(Tog, Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	PhotoEmojiVM:SetAmimIsPause(IsChecked)
	-- -- 暂停取消同步个人暂停
	if not IsChecked then
		PhotoVM:SetIsPauseSelect(false)
	end
end

function PhotoEmojiPanelView:OnUpdateTimer()
	if PhotoEmojiVM.IsPauseEmojiAnim then
		return
	end

	local Pct = PhotoMgr:GetPlayingEmojiMontagePct() or 0
	PhotoEmojiVM.CurAnimPct = Pct
end

return PhotoEmojiPanelView