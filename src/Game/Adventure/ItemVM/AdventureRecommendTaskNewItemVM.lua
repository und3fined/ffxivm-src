---
---@Author: ZhengJanChuan
---@Date: 2024-06-04 21:28:23
---@Description: 推荐任务子Item
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local AdventureItemItemVM = require("Game/Adventure/ItemVM/AdventureItemItemVM")
local UIBindableList = require("UI/UIBindableList")

local LSTR

---@class AdventureRecommendTaskNewItemVM : UIViewModel
local AdventureRecommendTaskNewItemVM = LuaClass(UIViewModel)

---Ctor
function AdventureRecommendTaskNewItemVM:Ctor()
	self.ID = nil
	self.ChapterID = nil
	self.TextTitle = ""
	self.TextDescribe = ""
	self.TextBtnGo = ""
	self.ImgTaskIcon = ""
	self.IsNew = true
	self.GoBtnStyle = nil
	self.RewardList = UIBindableList.New(AdventureItemItemVM)
	self.GoText = ""
	self.StartVisible = true
	self.PanelOngoingVisible = false
	self.Top = false
	self.MinLevel = ""
	self.Priority = nil
    self.Status = nil
	self.ImgTask = nil
	self.GoBtnStyle = nil
	self.UnlockIconPath = ""
end

function AdventureRecommendTaskNewItemVM:OnInit()
end

function AdventureRecommendTaskNewItemVM:OnBegin()
	LSTR = _G.LSTR
end

function AdventureRecommendTaskNewItemVM:OnEnd()
end

function AdventureRecommendTaskNewItemVM:OnShutdown()
end

function AdventureRecommendTaskNewItemVM:UpdateVM(Params)
    self.ID = Params.ID
    self.ChapterID = Params.ChapterID
    self.MinLevel = Params.MinLevel
    self.Top = Params.Top
    self.Priority = Params.Priority
    self.Status = Params.Status
    self.TextTitle = Params.TextTitle
    self.TextDescribe = Params.TextDescribe
    self.ImgTaskIcon = Params.ImgTaskIcon 
    self.ImgTask = Params.ImgTask
    self.StartVisible = Params.StartVisible
    self.GoText = Params.GoText
    self.GoBtnStyle = Params.GoBtnStyle
    self.UnlockIconPath = Params.UnlockIconPath
    if Params.RewardList then
        self:SetRewardData(Params.RewardList)
    end
end

function AdventureRecommendTaskNewItemVM:SetRewardData(RewardList)
	self.RewardList:UpdateByValues(RewardList)
end

function AdventureRecommendTaskNewItemVM:SetItemNewState(State)
	self.IsNew = State
end

return AdventureRecommendTaskNewItemVM