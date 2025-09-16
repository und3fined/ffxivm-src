---
--- Author: Administrator
--- DateTime: 2024-07-08 14:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local PhotoDefine = require("Game/Photo/PhotoDefine")
local PhotoMgr
local FVector2D = _G.UE.FVector2D
local PhotoVM
local PhotoCamVM
local PhotoFilterVM
local PhotoDarkEdgeVM
local PhotoRoleSettingVM
local PhotoSceneVM
local PhotoTemplateVM
local PhotoActionVM
local PhotoEmojiVM
local PhotoRoleStatVM

local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetRenderTransformAngle = require("Binder/UIBinderSetRenderTransformAngle")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

local PhotoActionItemVM = require("Game/Photo/VM/Item/PhotoActionItemVM")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local PhotoEmojiVM

---@class PhotoEmojiPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommTabs CommTabsView
---@field ImgBuySelect_2 UFImage
---@field ImgGiftSelect_2 UFImage
---@field PanelEmoji UFCanvasPanel
---@field TableView UTableView
---@field TextSwitchBuy_2 UFTextBlock
---@field TextSwitchGift_2 UFTextBlock
---@field ToggleBtnBuy_2 UToggleButton
---@field ToggleBtnGift_2 UToggleButton
---@field ToggleGroupSwitch_2 UToggleGroup
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoEmojiPanelView = LuaClass(UIView, true)

function PhotoEmojiPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommTabs = nil
	--self.ImgBuySelect_2 = nil
	--self.ImgGiftSelect_2 = nil
	--self.PanelEmoji = nil
	--self.TableView = nil
	--self.TextSwitchBuy_2 = nil
	--self.TextSwitchGift_2 = nil
	--self.ToggleBtnBuy_2 = nil
	--self.ToggleBtnGift_2 = nil
	--self.ToggleGroupSwitch_2 = nil
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
	PhotoEmojiVM 			= _G.PhotoEmojiVM
	PhotoVM = _G.PhotoVM

	self.TableViewEmojiAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView)
	self.TableViewEmojiAdapter:SetOnClickedCallback(self.OnEmojiItemClicked)

	self.BinderEmoji = 
	{
		{ "EmojiItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewEmojiAdapter) },
	}

	self.CommTabs:SetCallBack(self, self.OnTabs)
end

function PhotoEmojiPanelView:OnTabs(Idx)
	PhotoEmojiVM:SetEmojiType(Idx - 1)
end

function PhotoEmojiPanelView:OnDestroy()

end

local ListData = { { Name = _G.LSTR(630052) }}--, { Name = _G.LSTR(630053) }}
function PhotoEmojiPanelView:OnShow()
	self.CommTabs:UpdateItems(ListData, 1)
end

function PhotoEmojiPanelView:OnHide()

end

function PhotoEmojiPanelView:OnRegisterUIEvent()
end

function PhotoEmojiPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.PhotoSeltEntChg,                   self.OnEvePhotoSeltChg)
end

function PhotoEmojiPanelView:OnEvePhotoSeltChg()
	PhotoEmojiVM:UpdateVM()
end

function PhotoEmojiPanelView:OnRegisterBinder()
	self:RegisterBinders(PhotoEmojiVM, 			self.BinderEmoji)
end

function PhotoEmojiPanelView:OnEmojiItemClicked(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end
	
	PhotoEmojiVM:SetSelectedEmojiItem(Index, ItemData.ID)
	PhotoVM:SetIsPauseSelect(false)
	PhotoVM:SetIsPauseAll(false)

	if ItemData.Type == PhotoActionItemVM.ItemType.Face then
		_G.PhotoMgr:SetEmojiID(ItemData.ID)
	elseif ItemData.Type == PhotoActionItemVM.ItemType.Mouth then	
		_G.PhotoMgr:SetMouthID(ItemData.ID)
	end

end

return PhotoEmojiPanelView