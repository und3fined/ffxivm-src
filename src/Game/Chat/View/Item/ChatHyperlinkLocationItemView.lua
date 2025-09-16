---
--- Author: xingcaicao
--- DateTime: 2023-09-11 19:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChatMgr = require("Game/Chat/ChatMgr")
local ChatDefine = require("Game/Chat/ChatDefine")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local WorldMapMgr = _G.WorldMapMgr
local HyperlinkLocationType = ChatDefine.HyperlinkLocationType

---@class ChatHyperlinkLocationItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnLoction UFButton
---@field ImgLoctionNormal UFImage
---@field TextMapDescNormal UFTextBlock
---@field TextPositionNormal UFTextBlock
---@field TextTipsNormal UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatHyperlinkLocationItemView = LuaClass(UIView, true)

function ChatHyperlinkLocationItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnLoction = nil
	--self.ImgLoctionNormal = nil
	--self.TextMapDescNormal = nil
	--self.TextPositionNormal = nil
	--self.TextTipsNormal = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatHyperlinkLocationItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatHyperlinkLocationItemView:OnInit()
	self.Binders = {
		{ "Tips", 			UIBinderSetText.New(self, self.TextTipsNormal) },
		{ "MapDesc", 		UIBinderSetText.New(self, self.TextMapDescNormal) },
		{ "NormalIcon", 	UIBinderSetBrushFromAssetPath.New(self, self.ImgLoctionNormal) },
		{ "PositionDesc", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedPosDesc) },
	}
end

function ChatHyperlinkLocationItemView:OnDestroy()

end

function ChatHyperlinkLocationItemView:OnShow()

end

function ChatHyperlinkLocationItemView:OnHide()

end

function ChatHyperlinkLocationItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnLoction, self.OnClickButtonLoction)
end

function ChatHyperlinkLocationItemView:OnRegisterGameEvent()

end

function ChatHyperlinkLocationItemView:OnRegisterBinder()
	if nil == self.Params then
		return
	end

	local ViewModel = self.Params.Data 
	self.ViewModel = ViewModel 
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function ChatHyperlinkLocationItemView:OnValueChangedPosDesc( Desc )
	Desc = Desc or ""

	self.TextPositionNormal:SetText(Desc)
	UIUtil.SetIsVisible(self.TextPositionNormal, not string.isnilorempty(Desc))
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatHyperlinkLocationItemView:OnClickButtonLoction()
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	local Type = ViewModel.Type
	if Type == HyperlinkLocationType.MyLocation then
		ChatMgr:AddLocationHref(ViewModel.MapID, ViewModel.Position)

	elseif Type == HyperlinkLocationType.OpenMap then
		WorldMapMgr:ShowSendLoctionView() 
	end
end

return ChatHyperlinkLocationItemView