---
--- Author: xingcaicao
--- DateTime: 2024-11-27 20:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class ChatHyperlinkTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ComRedDot CommonRedDotView
---@field TextTitle UFTextBlock
---@field AnimChecked UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatHyperlinkTabItemView = LuaClass(UIView, true)

function ChatHyperlinkTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ComRedDot = nil
	--self.TextTitle = nil
	--self.AnimChecked = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatHyperlinkTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ComRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatHyperlinkTabItemView:OnInit()

end

function ChatHyperlinkTabItemView:OnDestroy()

end

function ChatHyperlinkTabItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Data = Params.Data
	self.TextTitle:SetText(Data.Name or "")

	--小红点
	local RedDotID = Data.RedDotID
	if RedDotID and RedDotID > 0 then
		self.ComRedDot:SetRedDotIDByID(RedDotID)
	end
end

function ChatHyperlinkTabItemView:OnHide()

end

function ChatHyperlinkTabItemView:OnRegisterUIEvent()

end

function ChatHyperlinkTabItemView:OnRegisterGameEvent()

end

function ChatHyperlinkTabItemView:OnRegisterBinder()

end

function ChatHyperlinkTabItemView:StopCurAnim()
	local Anim = self.CurAnim
	if Anim then
		self:StopAnimation(Anim)
	end
end

function ChatHyperlinkTabItemView:OnSelectChanged(IsSelected)
	-- 动效
	self:StopCurAnim()

	local Anim = IsSelected and self.AnimChecked or self.AnimUnchecked
	self.CurAnim = Anim 
	self:PlayAnimation(Anim)
end

return ChatHyperlinkTabItemView