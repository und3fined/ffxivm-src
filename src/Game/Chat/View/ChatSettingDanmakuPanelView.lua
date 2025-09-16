---
--- Author: xingcaicao
--- DateTime: 2025-04-16 15:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatSetting = require("Game/Chat/ChatSetting")

local DefaultOpenSetting = ChatDefine.DefaultOpenSetting

local LSTR = _G.LSTR

---@class ChatSettingDanmakuPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBox_Private_Dungeon_Danmaku CommSingleBoxView
---@field CheckBox_Private_Dungeon_RedDotTips CommSingleBoxView
---@field CheckBox_Private_Dungeon_Sidebar CommSingleBoxView
---@field CheckBox_Private_Other_Danmaku CommSingleBoxView
---@field CheckBox_Private_Other_RedDotTips CommSingleBoxView
---@field CheckBox_Private_Other_Sidebar CommSingleBoxView
---@field CheckBox_Team_Dungeon_Danmaku CommSingleBoxView
---@field CheckBox_Team_Other_Danmaku CommSingleBoxView
---@field CommInforBtnDanmaku CommInforBtnView
---@field CommInforBtnRedDotTips CommInforBtnView
---@field CommInforBtnSidebar CommInforBtnView
---@field CommInforBtnTitle CommInforBtnView
---@field FTextPrivateChannel_1 UFTextBlock
---@field FTextPrivateChannel_2 UFTextBlock
---@field FTextPrivateChannel_3 UFTextBlock
---@field FTextTeamChannel_3 UFTextBlock
---@field FTextTitle UFTextBlock
---@field FTextTitle_Danmaku UFTextBlock
---@field FTextTitle_RedDotTips UFTextBlock
---@field FTextTitle_Sidebar UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatSettingDanmakuPanelView = LuaClass(UIView, true)

function ChatSettingDanmakuPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBox_Private_Dungeon_Danmaku = nil
	--self.CheckBox_Private_Dungeon_RedDotTips = nil
	--self.CheckBox_Private_Dungeon_Sidebar = nil
	--self.CheckBox_Private_Other_Danmaku = nil
	--self.CheckBox_Private_Other_RedDotTips = nil
	--self.CheckBox_Private_Other_Sidebar = nil
	--self.CheckBox_Team_Dungeon_Danmaku = nil
	--self.CheckBox_Team_Other_Danmaku = nil
	--self.CommInforBtnDanmaku = nil
	--self.CommInforBtnRedDotTips = nil
	--self.CommInforBtnSidebar = nil
	--self.CommInforBtnTitle = nil
	--self.FTextPrivateChannel_1 = nil
	--self.FTextPrivateChannel_2 = nil
	--self.FTextPrivateChannel_3 = nil
	--self.FTextTeamChannel_3 = nil
	--self.FTextTitle = nil
	--self.FTextTitle_Danmaku = nil
	--self.FTextTitle_RedDotTips = nil
	--self.FTextTitle_Sidebar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatSettingDanmakuPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBox_Private_Dungeon_Danmaku)
	self:AddSubView(self.CheckBox_Private_Dungeon_RedDotTips)
	self:AddSubView(self.CheckBox_Private_Dungeon_Sidebar)
	self:AddSubView(self.CheckBox_Private_Other_Danmaku)
	self:AddSubView(self.CheckBox_Private_Other_RedDotTips)
	self:AddSubView(self.CheckBox_Private_Other_Sidebar)
	self:AddSubView(self.CheckBox_Team_Dungeon_Danmaku)
	self:AddSubView(self.CheckBox_Team_Other_Danmaku)
	self:AddSubView(self.CommInforBtnDanmaku)
	self:AddSubView(self.CommInforBtnRedDotTips)
	self:AddSubView(self.CommInforBtnSidebar)
	self:AddSubView(self.CommInforBtnTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatSettingDanmakuPanelView:OnInit()

end

function ChatSettingDanmakuPanelView:OnDestroy()

end

function ChatSettingDanmakuPanelView:OnShow()
	self:InitConstInfo()

	-- 私聊小红点提示 
	local Settings = ChatSetting.OpenPrivateRedDotTip or DefaultOpenSetting.PrivateRedDotTip 
	self.CheckBox_Private_Dungeon_RedDotTips:SetChecked(Settings[1])
	self.CheckBox_Private_Other_RedDotTips:SetChecked(Settings[2])

	-- 私聊侧边栏
	Settings = ChatSetting.OpenPrivateSidebar or DefaultOpenSetting.PrivateSidebar
	self.CheckBox_Private_Dungeon_Sidebar:SetChecked(Settings[1])
	self.CheckBox_Private_Other_Sidebar:SetChecked(Settings[2])

	-- 私聊弹幕
	Settings = ChatSetting.OpenPrivateDanmaku or DefaultOpenSetting.PrivateDanmaku
	self.CheckBox_Private_Dungeon_Danmaku:SetChecked(Settings[1])
	self.CheckBox_Private_Other_Danmaku:SetChecked(Settings[2])	

	-- 队伍弹幕
	Settings = ChatSetting.OpenTeamDanmaku or DefaultOpenSetting.TeamDanmaku
	self.CheckBox_Team_Dungeon_Danmaku:SetChecked(Settings[1])
	self.CheckBox_Team_Other_Danmaku:SetChecked(Settings[2])
end

function ChatSettingDanmakuPanelView:OnHide()
	local b1 = self.CheckBox_Private_Dungeon_RedDotTips:GetChecked()
	local b2 = self.CheckBox_Private_Other_RedDotTips:GetChecked()
	ChatSetting.SetIsOpenPrivateRedDotTip(b1, b2)

	b1 = self.CheckBox_Private_Dungeon_Sidebar:GetChecked()
	b2 = self.CheckBox_Private_Other_Sidebar:GetChecked()
	ChatSetting.SetIsOpenPrivateSidebar(b1, b2)

	b1 = self.CheckBox_Private_Dungeon_Danmaku:GetChecked()
	b2 = self.CheckBox_Private_Other_Danmaku:GetChecked()
	ChatSetting.SetIsOpenPrivateDanmaku(b1, b2)

	b1 = self.CheckBox_Team_Dungeon_Danmaku:GetChecked()
	b2 = self.CheckBox_Team_Other_Danmaku:GetChecked()
	ChatSetting.SetIsOpenTeamDanmaku(b1, b2)
end

function ChatSettingDanmakuPanelView:OnRegisterUIEvent()

end

function ChatSettingDanmakuPanelView:OnRegisterGameEvent()

end

function ChatSettingDanmakuPanelView:OnRegisterBinder()

end

function ChatSettingDanmakuPanelView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	self.FTextTitle:SetText(LSTR(50112)) -- "提示信息显示"
	self.FTextTitle_RedDotTips:SetText(LSTR(50179)) -- "聊天红点提醒"
	self.FTextTitle_Sidebar:SetText(LSTR(50180)) -- "聊天侧栏"
	self.FTextTitle_Danmaku:SetText(LSTR(50181)) -- "聊天弹幕"

	local Str = LSTR(50186) -- "私聊"
	self.FTextPrivateChannel_1:SetText(Str)
	self.FTextPrivateChannel_2:SetText(Str)
	self.FTextPrivateChannel_3:SetText(Str)

	Str = LSTR(50187) -- "队伍"
	self.FTextTeamChannel_3:SetText(Str)

	Str = LSTR(50182) -- "迷宫内"
	self.CheckBox_Private_Dungeon_RedDotTips:SetText(Str)
	self.CheckBox_Private_Dungeon_Sidebar:SetText(Str)
	self.CheckBox_Private_Dungeon_Danmaku:SetText(Str)
	self.CheckBox_Team_Dungeon_Danmaku:SetText(Str)

	Str = LSTR(50183) -- "迷宫外"
	self.CheckBox_Private_Other_RedDotTips:SetText(Str)
	self.CheckBox_Private_Other_Sidebar:SetText(Str)
	self.CheckBox_Private_Other_Danmaku:SetText(Str)
	self.CheckBox_Team_Other_Danmaku:SetText(Str)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack


return ChatSettingDanmakuPanelView