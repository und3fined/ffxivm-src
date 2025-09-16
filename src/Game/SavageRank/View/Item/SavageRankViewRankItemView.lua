---
--- Author: Administrator
--- DateTime: 2024-12-25 15:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")



---@class SavageRankViewRankItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF_BG1 UFCanvasPanel
---@field EFF_BG2 UFCanvasPanel
---@field EFF_BG3 UFCanvasPanel
---@field ImgBG UFImage
---@field ImgBadge UFImage
---@field ImgNormal UFImage
---@field TableViewPlayer UTableView
---@field TextClass UFTextBlock
---@field TextNumber UFTextBlock
---@field TextTime UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SavageRankViewRankItemView = LuaClass(UIView, true)

function SavageRankViewRankItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF_BG1 = nil
	--self.EFF_BG2 = nil
	--self.EFF_BG3 = nil
	--self.ImgBG = nil
	--self.ImgBadge = nil
	--self.ImgNormal = nil
	--self.TableViewPlayer = nil
	--self.TextClass = nil
	--self.TextNumber = nil
	--self.TextTime = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SavageRankViewRankItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SavageRankViewRankItemView:OnInit()
	self.HeadTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPlayer, self.OnHeadSelectChanged, true)
	self.Binders = {
		{ "RankNumber", UIBinderSetText.New(self, self.TextNumber) },
		{ "TopThreeNumber", UIBinderSetText.New(self, self.TextNumber02) },
		{ "RankNumberVisible", UIBinderSetIsVisible.New(self, self.TextNumber) },
		{ "TopThreeNumberVisible", UIBinderSetIsVisible.New(self, self.TextNumber02) },
		{ "EquipLvText", UIBinderSetText.New(self, self.TextClass) },
		{ "TimeText", UIBinderSetText.New(self, self.TextTime) },	
		{ "RankIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBadge) },	
		{ "CurHeadList", UIBinderUpdateBindableList.New(self, self.HeadTableViewAdapter) },
		{ "ImgBadgeVisible", UIBinderSetIsVisible.New(self, self.ImgBadge) },
		{ "ImgNormalVisible", UIBinderSetIsVisible.New(self, self.ImgNormal) },	
		{ "BgImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgBG) },	
	}
	
end

function SavageRankViewRankItemView:OnDestroy()

end

function SavageRankViewRankItemView:OnShow()

end

function SavageRankViewRankItemView:OnHide()

end

function SavageRankViewRankItemView:OnRegisterUIEvent()

end

function SavageRankViewRankItemView:OnRegisterGameEvent()

end

function SavageRankViewRankItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function SavageRankViewRankItemView:OnHeadSelectChanged(Index, ItemData, ItemView)
	_G.PersonInfoMgr:ShowPersonalSimpleInfoView(ItemData.RoleID)
end

return SavageRankViewRankItemView