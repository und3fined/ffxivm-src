---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class LinkShellListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelChecked UFCanvasPanel
---@field PanelCreate UFCanvasPanel
---@field PanelInfo UFCanvasPanel
---@field PanelUnchecked UFCanvasPanel
---@field RichTextTips URichTextBox
---@field TextCreate UFTextBlock
---@field TextMem UFTextBlock
---@field TextNameChecked UFTextBlock
---@field TextNameUnchecked UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellListItemView = LuaClass(UIView, true)

function LinkShellListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelChecked = nil
	--self.PanelCreate = nil
	--self.PanelInfo = nil
	--self.PanelUnchecked = nil
	--self.RichTextTips = nil
	--self.TextCreate = nil
	--self.TextMem = nil
	--self.TextNameChecked = nil
	--self.TextNameUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellListItemView:OnInit()
	self.Binders = {
		{ "Name", 		UIBinderSetText.New(self, self.TextNameChecked) },
		{ "Name", 		UIBinderSetText.New(self, self.TextNameUnchecked) },
		{ "MemDesc", 	UIBinderSetText.New(self, self.TextMem) },
		{ "StrTips", 	UIBinderSetText.New(self, self.RichTextTips) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.PanelCreate) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.PanelInfo, true) },
	}

	self.TextCreate:SetText(_G.LSTR(40004)) -- "创建通讯贝"
end

function LinkShellListItemView:OnDestroy()

end

function LinkShellListItemView:OnShow()

end

function LinkShellListItemView:OnHide()

end

function LinkShellListItemView:OnRegisterUIEvent()

end

function LinkShellListItemView:OnRegisterGameEvent()

end

function LinkShellListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local ViewModel = Params.Data
	self.ViewModel = ViewModel 
	self:RegisterBinders(ViewModel, self.Binders)
end

function LinkShellListItemView:OnSelectChanged( IsSelected )
	UIUtil.SetIsVisible(self.PanelChecked, IsSelected)
	UIUtil.SetIsVisible(self.PanelUnchecked, not IsSelected)
end

return LinkShellListItemView