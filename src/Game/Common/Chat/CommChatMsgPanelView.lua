---
--- Author: xingcaicao
--- DateTime: 2024-06-13 10:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChatVM = require("Game/Chat/ChatVM")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatUtil = require("Game/Chat/ChatUtil")

local FVector2D = _G.UE.FVector2D
local MsgItemSortFunc = ChatDefine.MsgItemSortFunc

---@class CommChatMsgPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonMsg UFButton
---@field RichTextMsg URichTextBox
---@field ArrayChannel ChatChannelType
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommChatMsgPanelView = LuaClass(UIView, true)

function CommChatMsgPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonMsg = nil
	--self.RichTextMsg = nil
	--self.ArrayChannel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommChatMsgPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommChatMsgPanelView:OnInit()
	self.TextRawSize = UIUtil.CanvasSlotGetSize(self.RichTextMsg)
	self.TextRawSizeY = self.TextRawSize.Y
end

function CommChatMsgPanelView:OnDestroy()

end

function CommChatMsgPanelView:OnShow()
	self.RichTextMsg:SetText("")
	self.IsEmpty = self.ArrayChannel:Num() <= 0
end

function CommChatMsgPanelView:OnHide()
	self.Source = nil 
	self.CurMsgItemVM = nil
	self.RichTextMsg:SetText("")
end

function CommChatMsgPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonMsg, 	self.OnClickButtonMsg)
end

function CommChatMsgPanelView:OnRegisterGameEvent()

end

function CommChatMsgPanelView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function CommChatMsgPanelView:OnTimer( )
	self:UpdateMsg()
end

function CommChatMsgPanelView:OnRegisterBinder()

end

function CommChatMsgPanelView:UpdateMsg()
	if self.IsEmpty then
		self.CurMsgItemVM = nil
		return
	end

	local MsgList = {}
	local ChannelVMList = ChatVM.ChannelVMList

	for _, Channel in pairs(self.ArrayChannel) do
		for _, ChannelVM in ipairs(ChannelVMList)  do
			if Channel == ChannelVM:GetChannel() then
				local LatestMsgItemVM = ChannelVM:GetLatestMsg()
				table.insert(MsgList, LatestMsgItemVM)
			end
		end
	end

	local Num = #MsgList
	if Num <= 0 then 
		return
	end

	table.sort(MsgList, MsgItemSortFunc)

	local MsgItemVM = MsgList[Num] 
	local CurMsgItemVM = self.CurMsgItemVM
	if CurMsgItemVM ~= nil and CurMsgItemVM:IsEqualVM(MsgItemVM) then
		return
	end

	self.CurMsgItemVM = MsgItemVM 

	-- 调整文本高度
	local Height = -1
	local CurHeight = self.CurTextHeight or self.TextRawSizeY

	local Text = ChatUtil.GetChatSimpleDesc(MsgItemVM) or ""
	local IsHaveImg = string.find(Text, '<img tex="') 
	if IsHaveImg then
		for value in string.gmatch(Text, '<img[^>]*size="%d+;(%d+)"[^>]*>') do
			Height = math.max(Height, tonumber(value))
		end

		if Height > 0 and CurHeight ~= Height then
			self.CurTextHeight = Height  
			UIUtil.CanvasSlotSetSize(self.RichTextMsg, FVector2D(self.TextRawSize.X, Height))
		end
	else
		if CurHeight ~= self.TextRawSizeY then
			self.CurTextHeight = self.TextRawSizeY  
			UIUtil.CanvasSlotSetSize(self.RichTextMsg, self.TextRawSize)
		end
	end

	self.RichTextMsg:SetText(Text)
end


-------------------------------------------------------------------------------------------------------
---Component CallBack

function CommChatMsgPanelView:OnClickButtonMsg()
	local Channel = nil 
	local ChannelID = nil
	local MsgItemVM = self.CurMsgItemVM 
	if MsgItemVM then
		Channel = MsgItemVM:GetChannel()
		ChannelID = MsgItemVM:GetChannelID()
	end

	if nil == Channel and self.ArrayChannel:Num() > 0 then
		Channel = self.ArrayChannel[1]
		ChannelID = nil
	end

	_G.ChatMgr:ShowChatView(Channel, ChannelID, self.Source, self.CurViewID )
end

-------------------------------------------------------------------------------------------------------
---Public Interface 

---设置来源
---@param Source ChatDefine.OpenSource @来源，没特殊需求可不传
function CommChatMsgPanelView:SetSource(Source)
	self.Source = Source
end

---设置来源界面ViewID，用于隐藏
---@param CurViewID  @设置当前界面ID，用于聊天跳转时隐藏,除主界面外基本都需要设置
function CommChatMsgPanelView:SetCurViewID(CurViewID)
	self.CurViewID = CurViewID
end

function CommChatMsgPanelView:GetCurViewID()
	return self.CurViewID
end

return CommChatMsgPanelView