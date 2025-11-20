---
--- Author: xingcaicao
--- DateTime: 2024-12-13 18:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")

---@class ChatGifItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot CommonRedDotView
---@field ImgGif UFImage
---@field ImgGifNew UImage
---@field ImgLock UImage
---@field ImgLockLight UImage
---@field ImgMask UImage
---@field PanelLock UFCanvasPanel
---@field PanelUse UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatGifItemView = LuaClass(UIView, true)

function ChatGifItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot = nil
	--self.ImgGif = nil
	--self.ImgGifNew = nil
	--self.ImgLock = nil
	--self.ImgLockLight = nil
	--self.ImgMask = nil
	--self.PanelLock = nil
	--self.PanelUse = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatGifItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatGifItemView:OnPostInit()
	self.CommonRedDot:SetStyle(RedDotDefine.RedDotStyle.TextStyle)
	self.CommonRedDot:SetRedDotText("New")
end

function ChatGifItemView:OnShow()
	local Data = self:GetParamData()
	if Data == nil then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.ImgGif, Data.Icon)
	UIUtil.SetIsVisible(self.ImgGif, true)
	if self.ImgGifNew then
		UIUtil.SetIsVisible(self.ImgGifNew, false)
	end
	
	self:UpdateLockUI(Data)

	-- red dot
	if Data.RedDotID and Data.RedDotID ~= 0 then
		self.CommonRedDot:SetRedDotIDByID(Data.RedDotID)
		UIUtil.SetIsVisible(self.CommonRedDot, true)
	else
		UIUtil.SetIsVisible(self.CommonRedDot, false)
	end
end

function ChatGifItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.BagUseItemSucc, self.OnItemUsed)
end

function ChatGifItemView:OnItemUsed(Param)
	if not Param then
		return
	end

	local Data = self:GetParamData()
	if not Data then
		return
	end

	-- Handle the item usage logic here
	if Param.ResID ~= Data.UnlockItemID then
		return
	end

	if Data.IsLock then
		Data.IsLock = not _G.ChatVM:IsGiftUnlocked(Data.ID)
		Data.bNotUse = _G.BagMgr:GetItemByResID(Param.ResID ) ~= nil
		self:UpdateLockUI(Data)
	end
end

function ChatGifItemView:GetParamData()
	if self.Params then
		return self.Params.Data
	end
end

function ChatGifItemView:UpdateLockUI(Data)
	UIUtil.SetIsVisible(self.PanelLock, Data.IsLock)
	UIUtil.SetIsVisible(self.ImgLock, Data.IsLock and not Data.bNotUse)
	UIUtil.SetIsVisible(self.ImgLockLight, Data.IsLock and Data.bNotUse)
	UIUtil.SetIsVisible(self.PanelUse, Data.IsLock)
	UIUtil.SetIsVisible(self.ImgMask, Data.IsLock)
end

return ChatGifItemView