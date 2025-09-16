---
--- Author: janezli
--- DateTime: 2024-10-11 14:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class MountSpeedUnlockInfoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichText URichTextBox
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountSpeedUnlockInfoItemView = LuaClass(UIView, true)

function MountSpeedUnlockInfoItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichText = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountSpeedUnlockInfoItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountSpeedUnlockInfoItemView:OnInit()
	self.Binders = {
		{ "QuestTitle", UIBinderSetText.New(self, self.TextTitle)},
		{ "QuestRichText", UIBinderSetText.New(self, self.RichText) },
	}
end

function MountSpeedUnlockInfoItemView:OnDestroy()

end

function MountSpeedUnlockInfoItemView:OnShow()

end

function MountSpeedUnlockInfoItemView:OnHide()

end

function MountSpeedUnlockInfoItemView:OnRegisterUIEvent()
	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichText, self.OnHyperlinkClicked)
end

function MountSpeedUnlockInfoItemView:OnRegisterGameEvent()

end

function MountSpeedUnlockInfoItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MountSpeedUnlockInfoItemView:OnHyperlinkClicked(_, LinkID)
	local ItemID = tonumber(LinkID)
	if ItemID and ItemID > 0 then
		ItemTipsUtil.ShowTipsByResID(ItemID, self.RichText)
	end
end

return MountSpeedUnlockInfoItemView