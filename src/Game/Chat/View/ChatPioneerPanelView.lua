---
--- Author: xingcaicao
--- DateTime: 2025-03-18 20:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local ChatVM = require("Game/Chat/ChatVM")
local MajorUtil = require("Utils/MajorUtil")
local ChatUtil = require("Game/Chat/ChatUtil")
local ChatDefine = require("Game/Chat/ChatDefine")

local LSTR = _G.LSTR
local ChannelState = ChatDefine.ChannelState

---@class ChatPioneerPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnJoin CommBtnMView
---@field ImgManifesto UFImage
---@field PanelJoinTop UFCanvasPanel
---@field PioneerXC UFCanvasPanel
---@field ScrollBoxDeleteTips UScrollBox
---@field ScrollBoxJoin UScrollBox
---@field TextDeleteTips URichTextBox
---@field TextJoinDesc UFTextBlock
---@field TextJoinPioneer UFTextBlock
---@field TextOrganize URichTextBox
---@field TextSendMsgLevelTips URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatPioneerPanelView = LuaClass(UIView, true)

function ChatPioneerPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnJoin = nil
	--self.ImgManifesto = nil
	--self.PanelJoinTop = nil
	--self.PioneerXC = nil
	--self.ScrollBoxDeleteTips = nil
	--self.ScrollBoxJoin = nil
	--self.TextDeleteTips = nil
	--self.TextJoinDesc = nil
	--self.TextJoinPioneer = nil
	--self.TextOrganize = nil
	--self.TextSendMsgLevelTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatPioneerPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnJoin)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatPioneerPanelView:OnInit()
	self.IsInitConstInfo = false 
end

function ChatPioneerPanelView:OnDestroy()

end

function ChatPioneerPanelView:OnShow()
	self:RefreshUI()
end

function ChatPioneerPanelView:OnHide()

end

function ChatPioneerPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnJoin, self.OnClickButtonJoin)
end

function ChatPioneerPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ChatRefreshPioneerPanel, self.OnEventRefreshUI)
end

function ChatPioneerPanelView:OnRegisterBinder()

end

function ChatPioneerPanelView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	self.TextJoinPioneer:SetText(LSTR(50160)) -- "加入频道"
	self.TextJoinDesc:SetText(LSTR(50161)) -- "与世界各处冒险者一起冒险吧"
	self.TextOrganize:SetText(LSTR(50162)) -- "先锋频道可以与世界各处冒险者交流组队!\n请注意文明发言!"

	-- 加入
	self.BtnJoin:SetText(LSTR(50163)) -- "加入频道"

	-- 宣传图
	local Img = self.ImgManifesto
	if not UIUtil.IsVisible(Img) then
		local ManifestoImg = "Texture2D'/Game/UI/Texture/ChatNew/UI_Chat_Img_PioneerBanner.UI_Chat_Img_PioneerBanner'"
		if UIUtil.ImageSetBrushFromAssetPath(Img, ManifestoImg) then
			UIUtil.SetIsVisible(Img, true)
		end
	end
end

function ChatPioneerPanelView:RefreshUI()
	self.TextSendMsgLevelTips:SetText("")

	local State = ChatVM.PioneerChannelState
	if State == ChannelState.Joining then
		UIUtil.SetIsVisible(self.PioneerXC, false)

		local SendMsgLevel = ChatUtil.GetPioneerChannelSpeakLevel()
		if MajorUtil.GetMaxProfLevel() < SendMsgLevel then
			local Fmt = LSTR(50159)	 --"%s级后可发言"
			self.TextSendMsgLevelTips:SetText(string.format(Fmt, SendMsgLevel))
		end

		UIUtil.SetIsVisible(self.ScrollBoxDeleteTips, false)

	else
		UIUtil.SetIsVisible(self.PioneerXC, true)
		self:InitConstInfo()

		if State == ChannelState.Closed then
			local Fmt = LSTR(50169)	 --"先锋频道已关闭，将于%s删除。\n请于新人等频道继续互相帮助吧!"
			self.TextDeleteTips:SetText(string.format(Fmt, ChatVM.PioneerChannelDeleteTimeStr or ""))
			UIUtil.SetIsVisible(self.ScrollBoxDeleteTips, true)

		else
			UIUtil.SetIsVisible(self.ScrollBoxDeleteTips, false)
		end
	end

	local IsExited = State == ChannelState.Exited 
	UIUtil.SetIsVisible(self.PanelJoinTop, IsExited)
	UIUtil.SetIsVisible(self.BtnJoin, IsExited, true)
	UIUtil.SetIsVisible(self.ScrollBoxJoin, IsExited)
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function ChatPioneerPanelView:OnEventRefreshUI()
	if self:IsVisible() then
		self:RefreshUI()
	end
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatPioneerPanelView:OnClickButtonJoin()
	_G.ChatMgr:SendJoinPioneerChannel()
end

return ChatPioneerPanelView