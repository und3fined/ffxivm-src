---
--- Author: sammrli
--- DateTime: 2023-05-12 21:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class AdventureCompletionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNodeDark UFImage
---@field RichTextMark URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureCompletionItemView = LuaClass(UIView, true)

function AdventureCompletionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNodeDark = nil
	--self.RichTextMark = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureCompletionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureCompletionItemView:OnInit()

end

function AdventureCompletionItemView:OnDestroy()

end

function AdventureCompletionItemView:OnShow()

end

function AdventureCompletionItemView:OnHide()

end

function AdventureCompletionItemView:OnRegisterUIEvent()

end

function AdventureCompletionItemView:OnRegisterGameEvent()

end

function AdventureCompletionItemView:OnRegisterBinder()

end

---设置灰色
---@param IsGray boolean
function AdventureCompletionItemView:SetGray(IsGray)
	UIUtil.SetIsVisible(self.ImgNodeDark, IsGray)
	local AdventureMgr = require("Game/Adventure/AdventureMgr")
	if not IsGray and not AdventureMgr:IsRewardCollected(self.Count) then
		self:PlayAnimation(self.AnimAvailableShow)
	else
		self:PlayAnimation(self.AnimAvailableHide)
	end
end

---设置文本
---@param Text string
function AdventureCompletionItemView:SetText(Text)
	self.RichTextMark:SetText(Text)
end

function AdventureCompletionItemView:SetCount(Count)
	self.Count = Count
end

return AdventureCompletionItemView