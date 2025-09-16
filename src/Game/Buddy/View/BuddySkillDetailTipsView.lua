---
--- Author: Administrator
--- DateTime: 2023-11-30 14:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local BuddySkillDetailTipsVM = require("Game/Buddy/VM/BuddySkillDetailTipsVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local UE = _G.UE
local UKismetInputLibrary = UE.UKismetInputLibrary
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

---@class BuddySkillDetailTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelDetail UFCanvasPanel
---@field RichTextDiscribe URichTextBox
---@field SkillType SkillTypeTagItemView
---@field ImgSkillIcon UFImage
---@field TableViewSkillType UTableView
---@field TextSkillName UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddySkillDetailTipsView = LuaClass(UIView, true)

function BuddySkillDetailTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelDetail = nil
	--self.RichTextDiscribe = nil
	--self.SkillType = nil
	--self.TableViewAttri = nil
	--self.TextSkillName = nil
	--self.AnimIn = nil
	--self.TableViewSkillType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddySkillDetailTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	-- self:AddSubView(self.SkillType)
	-- self:AddSubView(self.TableViewAttriAdapter)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddySkillDetailTipsView:OnInit()
	self.ViewModel = BuddySkillDetailTipsVM.New()
	self.TableViewAttriAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewAttri)
	self.TableViewSkillTypeAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSkillType)
	self.Binders = {
		{ "NameText", UIBinderSetText.New(self, self.TextSkillName) },
		{ "DescText", UIBinderSetText.New(self, self.RichTextDiscribe) },
		{ "AttriVMList", UIBinderUpdateBindableList.New(self, self.TableViewAttriAdapter) },
		{ "SkillTypeVMList", UIBinderUpdateBindableList.New(self, self.TableViewSkillTypeAdapter) },
	}
end

function BuddySkillDetailTipsView:OnDestroy()
	self.ViewModel = nil
end

function BuddySkillDetailTipsView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local SkillID = Params.SkillID
	self.ViewModel:UpdateVM(SkillID)


	self.HideCallback = Params.HideCallback

	local ItemView = Params.SlotView
	if nil ~= ItemView then
		ItemTipsUtil.AdjustTipsPosition(self.PanelDetail, ItemView, Params.Offset)
	end

end

function BuddySkillDetailTipsView:OnHide()

end

function BuddySkillDetailTipsView:OnRegisterUIEvent()

end

function BuddySkillDetailTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function BuddySkillDetailTipsView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.SkillType:SetParams({Data = self.ViewModel})
end

function BuddySkillDetailTipsView:OnPreprocessedMouseButtonDown(MouseEvent)
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end

	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelDetail, MousePosition) == false then
		UIViewMgr:HideView(UIViewID.BuddySkillDetailTips)
	end
end

return BuddySkillDetailTipsView