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


---@class EmoActRecentItemVM : UIViewModel
local EmoActRecentItemVM = LuaClass(UIViewModel)

---Ctor
function EmoActRecentItemVM:Ctor()
	self.RecentEmotionList = UIBindableList.New(EmoActVM)       --存放所有常用动作
end

function EmoActRecentItemVM:OnInit()
end

function EmoActRecentItemVM:OnBegin()
end

function EmoActRecentItemVM:OnEnd()
end

function EmoActRecentItemVM:OnShutdown()
end

return EmoActRecentItemVM