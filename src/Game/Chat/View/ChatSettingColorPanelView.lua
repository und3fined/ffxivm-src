---
--- Author: xingcaicao
--- DateTime: 2024-12-19 20:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatSetting = require("Game/Chat/ChatSetting")
local RichTextUtil = require("Utils/RichTextUtil")

local LSTR = _G.LSTR

---@class ChatSettingColorPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnReset UFButton
---@field FTextChannel URichTextBox
---@field FTextColor UFTextBlock
---@field ImageChannel UFImage
---@field TableViewColor UTableView
---@field TextChannelName URichTextBox
---@field TextPlayerName URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatSettingColorPanelView = LuaClass(UIView, true)

function ChatSettingColorPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnReset = nil
	--self.FTextChannel = nil
	--self.FTextColor = nil
	--self.ImageChannel = nil
	--self.TableViewColor = nil
	--self.TextChannelName = nil
	--self.TextPlayerName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatSettingColorPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatSettingColorPanelView:OnInit()
	self.IsInitConstInfo = false 

	self.TableAdapterColor = UIAdapterTableView.CreateAdapter(self, self.TableViewColor, self.OnSelectChangedColor)
end

function ChatSettingColorPanelView:OnDestroy()
end

function ChatSettingColorPanelView:OnShow()
	_G.ObjectMgr:CollectGarbage(false)


	self.MenuInfo = nil
	self.ColorIndex = nil
	self.SrcColorIdx = nil 

	self:InitConstInfo()
	self.TableAdapterColor:UpdateAll(ChatDefine.ChatChannelColor)
end

function ChatSettingColorPanelView:OnHide()
	self:SaveColorSetting()
	self.TableAdapterColor:ReleaseAllItem(true)
end

function ChatSettingColorPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnReset, self.OnClickedBtnReset)
end

function ChatSettingColorPanelView:OnRegisterGameEvent()

end

function ChatSettingColorPanelView:OnRegisterBinder()

end

function ChatSettingColorPanelView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	self.FTextColor:SetText(LSTR(50121)) -- "选择颜色"
	self.TextPlayerName:SetText(LSTR(50122)) -- "玩家名字"
end

function ChatSettingColorPanelView:SetMenuInfo(Info)
	local MenuInfo = self.MenuInfo
	if MenuInfo then
		-- 保存上一个页签的数据
		self:SaveColorSetting()
	end

	self.MenuInfo = Info
	local Channel, ChannelID = Info.Channel, Info.ChannelID 
	local ColorIdx = ChatSetting.GetChannelColorIndex(Channel, ChannelID)

	self.ColorIndex = ColorIdx 
	self.SrcColorIdx = ColorIdx

	self.TableAdapterColor:SetSelectedIndex(ColorIdx)

	self:UpdateInfo()
end

function ChatSettingColorPanelView:SaveColorSetting()
	local MenuInfo = self.MenuInfo
	if nil == MenuInfo then
		return
	end

	local ColorIdx = self.ColorIndex 
	if nil == ColorIdx or ColorIdx == self.SrcColorIdx then
		return
	end

	local Channel, ChannelID = MenuInfo.Channel, MenuInfo.ChannelID 
	if Channel then
		ChatSetting.SetChannelColorIndex(Channel, ColorIdx, ChannelID)

		_G.EventMgr:SendEvent(_G.EventID.ChatUpdateColor)
	end
end

function ChatSettingColorPanelView:UpdateInfo()
	local Name = (self.MenuInfo or {}).Name or ""
	self.FTextChannel:SetText(Name)

	local ColorIndex = self.ColorIndex
	local Color = ChatDefine.ChatChannelColor[ColorIndex]
	local ChannelRT = RichTextUtil .GetText(string.format("[%s]", Name), Color)
	self.TextChannelName:SetText(ChannelRT .. LSTR(50122))

	-- 标签色
	UIUtil.ImageSetColorAndOpacityHex(self.ImageChannel, Color)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatSettingColorPanelView:OnSelectChangedColor(Index, ItemData, ItemView)
	self.ColorIndex = Index
	self:UpdateInfo()
end

function ChatSettingColorPanelView:OnClickedBtnReset()
	local Channel = (self.MenuInfo or {}).Channel 
	local ColorIdx = ChatSetting.GetDefaultChannelColorIndex(Channel)
	if nil == ColorIdx then
		return
	end

	self.ColorIndex = ColorIdx 

	self.TableAdapterColor:SetSelectedIndex(ColorIdx)
end

return ChatSettingColorPanelView