--[[
Date: 2021-12-07 11:16:20
LastEditors: moody
LastEditTime: 2023-12-07 11:16:20
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local UIBindableList = require("UI/UIBindableList")
local EmoActVM = require("Game/EmoAct/VM/EmoActVM")
-- local CommSideFrameTabsVM = require("Game/Common/Tab/CommSideFrameTabsVM")


---@class EmoActPanelVM : UIViewModel
local EmoActPanelVM = LuaClass(UIViewModel)

---Ctor
function EmoActPanelVM:Ctor()
end

function EmoActPanelVM:OnInit()
	self.DetailTipsVisible = false  --UI提示的可视性
	-- self.CommSideFrameTabsVM = CommSideFrameTabsVM.New()
	self.CurEmotionList = UIBindableList.New(EmoActVM)       --存放所有常用动作
	self.CurEmotionFilter = 1+1       --将“情感动作类型”设置为：收藏0、一般1、持续2、表情3
	self.ListRecentFavorite = nil   --最近使用+收藏
	self.ListFavorite = nil   		--收藏列表(更新收藏页面ItemView)
	self.SavedFavoriteID = {}   	--已保存的收藏ID
	self.bIsFavorite = false        --是否已收藏
	self.EnableID = nil				--当前选中的动作ID
	self.SelectList = {}			--提供快速点击的缓存列表（元素总数 < 3）
	self.QuestList = {}				--任务动作
	self.EmotionShowQuestID = {}	--任务动作ID
	self.ShowTemporaryTagID = nil	--临时跳转标签
	self.CanUseList = {}			--可用状态列表
	self.RecentSize = nil			--收藏外图层尺寸
end

function EmoActPanelVM:OnBegin()
end

function EmoActPanelVM:OnEnd()
end

function EmoActPanelVM:OnShutdown()
end

function EmoActPanelVM:SetDetailTipsVisible(Visible)
	self.DetailTipsVisible = Visible
end

function EmoActPanelVM:GetDetailTipsVisible()
	return self.DetailTipsVisible
end

function EmoActPanelVM:SetEmotionFilter(NewEmotionFilter)
	self.CurEmotionFilter = NewEmotionFilter
end

function EmoActPanelVM:GetEmotionFilter()
	return self.CurEmotionFilter
end

return EmoActPanelVM