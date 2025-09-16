---
--- Author: xingcaicao
--- DateTime: 2024-11-27 20:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local LSTR = _G.LSTR

---@class ChatMakeFriendsPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoTo CommBtnMView
---@field ImgManifesto UFImage
---@field TextDesc UFTextBlock
---@field TextDesc2 UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatMakeFriendsPageView = LuaClass(UIView, true)

function ChatMakeFriendsPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoTo = nil
	--self.ImgManifesto = nil
	--self.TextDesc = nil
	--self.TextDesc2 = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatMakeFriendsPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGoTo)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatMakeFriendsPageView:OnInit()
	self.IsInitConstInfo = false 
end

function ChatMakeFriendsPageView:OnDestroy()

end

function ChatMakeFriendsPageView:OnShow()
	self:InitConstInfo()
end

function ChatMakeFriendsPageView:OnHide()

end

function ChatMakeFriendsPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGoTo, self.OnClickButtonGoTo)
end

function ChatMakeFriendsPageView:OnRegisterGameEvent()

end

function ChatMakeFriendsPageView:OnRegisterBinder()

end

function ChatMakeFriendsPageView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	self.TextTitle:SetText(LSTR(50138)) -- "结识好友"
	self.TextDesc:SetText(LSTR(50139)) -- "寻找志同道合的冒险者"
	self.TextDesc2:SetText(LSTR(50140)) -- "快去邀请你的好友，一起来冒险吧!"

	self.BtnGoTo:SetButtonText(LSTR(50136)) -- "添加好友"

	-- 宣传图
	local Img = self.ImgManifesto
	if not UIUtil.IsVisible(Img) then
		local FriendManifestoImg = "Texture2D'/Game/UI/Texture/ChatNew/UI_Chat_Img_FriendBanner.UI_Chat_Img_FriendBanner'"
		if UIUtil.ImageSetBrushFromAssetPath(Img, FriendManifestoImg) then
			UIUtil.SetIsVisible(Img, true)
		end
	end
end

function ChatMakeFriendsPageView:OnClickButtonGoTo()
	UIViewMgr:HideView(UIViewID.ChatMainPanel)
	UIViewMgr:ShowView(UIViewID.SocialMainPanel)
end

return ChatMakeFriendsPageView