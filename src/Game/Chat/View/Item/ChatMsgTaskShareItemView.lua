---
--- Author: xingcaicao
--- DateTime: 2023-11-02 19:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ChatMsgTaskShareItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgStarTagLeft UFImage
---@field ImgStarTagRight UFImage
---@field ImgTaskIcon UFImage
---@field ImgTaskPictures UFImage
---@field TextLevel UFTextBlock
---@field TextStatus UFTextBlock
---@field TextTaskName UFTextBlock
---@field TitleBgPanel UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatMsgTaskShareItemView = LuaClass(UIView, true)

function ChatMsgTaskShareItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgStarTagLeft = nil
	--self.ImgStarTagRight = nil
	--self.ImgTaskIcon = nil
	--self.ImgTaskPictures = nil
	--self.TextLevel = nil
	--self.TextStatus = nil
	--self.TextTaskName = nil
	--self.TitleBgPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatMsgTaskShareItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatMsgTaskShareItemView:OnInit()

end

function ChatMsgTaskShareItemView:OnDestroy()

end

function ChatMsgTaskShareItemView:OnShow()

end

function ChatMsgTaskShareItemView:OnHide()
	self.TaskID = nil
end

function ChatMsgTaskShareItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickButtonClick)
end

function ChatMsgTaskShareItemView:OnRegisterGameEvent()

end

function ChatMsgTaskShareItemView:OnRegisterBinder()

end

---@param Data cschatc.TaskHrefMessage @任务超链接数据信息
---@param IsMajor boolean @是否为主角发送的消息
function ChatMsgTaskShareItemView:RefreshUI(Data, IsMajor)
	if nil == Data then
		self.TaskID = nil 
		return
	end

	local TaskID = Data.TaskID
	self.TaskID = TaskID

	-- 方向图标
	UIUtil.SetIsVisible(self.ImgStarTagLeft, not IsMajor)
	UIUtil.SetIsVisible(self.ImgStarTagRight, IsMajor)

	-- 任务分享信息
	local Info = _G.QuestMgr:GetShareInfo(TaskID)
	if nil == Info then
		return
	end

	-- 状态描述
	self.TextStatus:SetText(Info.StatusTip or "")

	-- 配图
	UIUtil.ImageSetBrushFromAssetPath(self.ImgTaskPictures, Info.BgPath)

	-- 任务Icon
	UIUtil.ImageSetBrushFromAssetPath(self.ImgTaskIcon, Info.IconPath)

	-- 级别
	self.TextLevel:SetText(Info.LevelTip or "")

	-- 任务名称
	self.TextTaskName:SetText(Info.Name)

	-- 标题背景
	UIUtil.SetIsVisible(self.TitleBgPanel, Info.IsActive == true)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatMsgTaskShareItemView:OnClickButtonClick()
	local TaskID = self.TaskID
	if nil == TaskID then
		return	
	end

	_G.QuestMgr:OpenPanel(TaskID)
end

return ChatMsgTaskShareItemView