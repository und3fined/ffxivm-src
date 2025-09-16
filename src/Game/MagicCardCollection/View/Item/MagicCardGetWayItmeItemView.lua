---
--- Author: Administrator
--- DateTime: 2023-12-18 16:00
--- Description:
---

local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MagicCardCollectionDefine = require("Game/MagicCardCollection/MagicCardCollectionDefine")

---@class MagicCardGetWayItmeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field ImgArrow UFImage
---@field ImgArrowDisable UFImage
---@field ImgItemIcon UFImage
---@field TextQuestName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicCardGetWayItmeItemView = LuaClass(UIView, true)

function MagicCardGetWayItmeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.ImgArrow = nil
	--self.ImgArrowDisable = nil
	--self.ImgItemIcon = nil
	--self.TextQuestName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicCardGetWayItmeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicCardGetWayItmeItemView:OnInit()
	self.DefaultFunIcon = "Texture2D'/Game/Assets/Icon/061000/UI_Icon_061804.UI_Icon_061804'"
end

function MagicCardGetWayItmeItemView:OnDestroy()

end

function MagicCardGetWayItmeItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Item = Params.Data
	if nil == Item then
		return
	end

	local FunIcon = Item.FunIcon
	if string.isnilorempty(FunIcon) then
		FunIcon = self.DefaultFunIcon
	end
	UIUtil.ImageSetBrushFromAssetPath(self.ImgItemIcon, FunIcon)
	self.TextQuestName:SetText(Item.FunDesc)
	if Item.IsUnLock then
		-- UIUtil.SetIsVisible(self.BtnGo, true, true)
		UIUtil.SetColorAndOpacity(self.TextQuestName, 0.03, 0.03, 0.03, 1)
		--UIUtil.SetColorAndOpacity(self.ImgArrow, 1, 1, 1, 1)
		UIUtil.SetColorAndOpacity(self.ImgItemIcon, 1, 1, 1, 1)
	else
		-- UIUtil.SetIsVisible(self.BtnGo, true, false)
		UIUtil.SetColorAndOpacity(self.TextQuestName, 0.03, 0.03, 0.03, 0.4)
		--UIUtil.SetColorAndOpacity(self.ImgArrow, 0.6, 0.6, 0.6, 0.4)
		UIUtil.SetColorAndOpacity(self.ImgItemIcon, 0.6, 0.6, 0.6, 0.4)
		self.TextQuestName:SetText(MagicCardCollectionDefine.LockGetWayName)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgItemIcon, MagicCardCollectionDefine.LockGetWayIconPath)
	end

	local IsRedirect = Item.IsRedirect and Item.IsRedirect > 0 or false --是否跳转
	local IsUnLock = Item.IsUnLock
	UIUtil.SetIsVisible(self.ImgArrow, IsRedirect and IsUnLock)
	UIUtil.SetIsVisible(self.ImgArrowDisable, IsRedirect and not IsUnLock)
end

function MagicCardGetWayItmeItemView:OnHide()

end

function MagicCardGetWayItmeItemView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnGoClicked)
end

function MagicCardGetWayItmeItemView:OnRegisterGameEvent()

end

function MagicCardGetWayItmeItemView:OnRegisterBinder()

end

function MagicCardGetWayItmeItemView:OnGoClicked()
end

return MagicCardGetWayItmeItemView