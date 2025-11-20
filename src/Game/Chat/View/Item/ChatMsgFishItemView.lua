---
--- Author: xingcaicao
--- DateTime: 2025-05-30 18:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoRes = require("Protocol/ProtoRes")
local FishCfg = require("TableCfg/FishCfg")

local LSTR = _G.LSTR

---@class ChatMsgFishItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgBanner UFImage
---@field ImgStarTagLeft UFImage
---@field ImgStarTagRight UFImage
---@field TextFishLocation UFTextBlock
---@field TextFishName UFTextBlock
---@field TextFishSize UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatMsgFishItemView = LuaClass(UIView, true)

function ChatMsgFishItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgBanner = nil
	--self.ImgStarTagLeft = nil
	--self.ImgStarTagRight = nil
	--self.TextFishLocation = nil
	--self.TextFishName = nil
	--self.TextFishSize = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatMsgFishItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatMsgFishItemView:OnInit()

end

function ChatMsgFishItemView:OnDestroy()

end

function ChatMsgFishItemView:OnShow()
	-- Banner图
	local Img = self.ImgBanner
	if not UIUtil.IsVisible(Img) then
		local ImgPath ="Texture2D'/Game/UI/Texture/ChatNew/UI_Chat_Img_BannerFish.UI_Chat_Img_BannerFish'"
		if UIUtil.ImageSetBrushFromAssetPath(Img, ImgPath) then
			UIUtil.SetIsVisible(Img, true)
		end
	end
end

function ChatMsgFishItemView:OnHide()

end

function ChatMsgFishItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickButtonClick)
end

function ChatMsgFishItemView:OnRegisterGameEvent()

end

function ChatMsgFishItemView:OnRegisterBinder()

end

---@param Data href.FishMessage @鱼类分享超链接数据信息
---@param IsMajor boolean @是否为主角发送的消息
function ChatMsgFishItemView:RefreshUI(Data, IsMajor)
	if nil == Data then
		return
	end

	-- 方向图标
	UIUtil.SetIsVisible(self.ImgStarTagLeft, not IsMajor)
	UIUtil.SetIsVisible(self.ImgStarTagRight, IsMajor)

	self.Data = Data

	-- 渔场类型
	local LocationType = ProtoEnumAlias.GetAlias(ProtoRes.FISH_LOCATION_TYPE, Data.LocationType) or ""
	self.TextFishLocation:SetText(LocationType)

	-- 鱼名
	local Cfg = FishCfg:FindCfgByKey(Data.ID)
	if Cfg then
		self.TextFishName:SetText(Cfg.Name)
	else
		self.TextFishName:SetText("")
	end

	-- 鱼大小
	local SizeUnit = self.FishSizeUnit or LSTR(180061)
	local StrSize = string.format("%s%s", Data.Size, SizeUnit)
	self.TextFishSize:SetText(StrSize)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatMsgFishItemView:OnClickButtonClick()
	_G.UIViewMgr:ShowView(_G.UIViewID.FishGuideChatTips, self.Data)
end

return ChatMsgFishItemView