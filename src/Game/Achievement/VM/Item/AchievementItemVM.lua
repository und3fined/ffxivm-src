---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local AchieveCommRewardsSlotVM = require("Game/Achievement/VM/Item/AchieveCommRewardsSlotVM")
local UIBindableList = require("UI/UIBindableList")
local ProtoRes = require("Protocol/ProtoRes")
local RichTextUtil = require("Utils/RichTextUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")

local LSTR = _G.LSTR
local EToggleButtonState = _G.UE.EToggleButtonState
local AchievementHideType = ProtoRes.AchievementHideType

---@class AchievementItemVM : UIViewModel
local AchievementItemVM = LuaClass(UIViewModel)

---Ctor
function AchievementItemVM:Ctor()
	self.ID = 0
	self.GroupID = 0
	self.ViewScale = _G.UE.FVector2D(1.0, 1.0)                      
	self.TrackedVisible = false
	self.TextName = ""
	self.ToggleBtnFavorState = EToggleButtonState.Unchecked
	self.BtnRequestDetailVisible = false
	self.AchievePoint = 0
	self.ImgLevelPath = ""

	self.TableViewRewardsVisible = false
	self.PanelGetVisible = false
	self.RichTextProcessVisible = true
	self.PanelDoneVisible = false
	self.RichTextProcessText = "----/----"
	self.TextDate = "----.--.--"

	self.TableViewRewardsList = UIBindableList.New( AchieveCommRewardsSlotVM )
	
	self.OriginalTextContent = ""
end

function AchievementItemVM:OnInit()

end

function AchievementItemVM:OnBegin()

end

function AchievementItemVM:IsEqualVM(Value)
	return true
end

function AchievementItemVM:OnEnd()

end

function AchievementItemVM:OnShutdown()

end

function AchievementItemVM:SetTrackedVisible(TrackedVisible)
	self.TrackedVisible = TrackedVisible
end

function AchievementItemVM:SetSelfVisible(Visible)
	self.SelfVisible = Visible
end

function AchievementItemVM:SetToggleBtnFavorState(State)
	self.ToggleBtnFavorState = State
end

--[[
function AchievementItemVM:SetSelected(IsSelected)
	if IsSelected then
		self.ViewScale = _G.UE.FVector2D(1.02, 1.02)
	else
		self.ViewScale = _G.UE.FVector2D(1.0, 1.0)
	end
end
]]--

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function AchievementItemVM:UpdateVM(Value, Params)
	self:SetTrackedVisible(false)
	self.ID = Value.ID
	local TextContent = nil
	local TextName = nil
	if Value.HideType == AchievementHideType.ACHIEVEMENT_HIDE_TYPE_HIDE_CONDITION and Value.IsFinish == false then
		TextContent = "????"
	end
	if Value.HideType == AchievementHideType.ACHIEVEMENT_HIDE_TYPE_HIDE_ALL and Value.IsFinish == false then
		TextContent = "????"
		TextName = "? ? ?"
	end

	self.TextName = TextName or Value.TextName
	self.TextContent = TextContent or Value.TextContent

	self.ToggleBtnFavorState = _G.AchievementMgr:IsCollectAchievement(Value.ID) and EToggleButtonState.Checked or EToggleButtonState.Unchecked
	self.BtnRequestDetailVisible = (Value.GroupID or 0) ~= 0
	self.GroupID = Value.GroupID
	self.AchievePoint = Value.AchievePoint
	self.ImgLevelPath = Value.AchievePointIcon
	local RewardList = Value.RewardList or {}
	for i = 1, #RewardList do
		RewardList[i].Received = Value.IsFinish and not Value.HaveReward
	end
	
	if #RewardList > 0 then
		self.TableViewRewardsVisible = true
		self.TableViewRewardsList:UpdateByValues(Value.RewardList or {} )
	else
		self.TableViewRewardsVisible = false
		self.TableViewRewardsList:Clear()
	end
	
	if Value.IsFinish == false then
		self.RichTextProcessVisible = true
		self.PanelGetVisible = false 
		self.PanelDoneVisible = false
		self:ProcessTextDisplays(Value)
	else
		self.RichTextProcessVisible = false
		local TimeStr = TimeUtil.GetTimeFormat("%Y.%m.%d", Value.FinishTime)
        self.TextDate = LocalizationUtil.GetTimeForFixedFormat(TimeStr)

		if Value.HaveReward then 
			self.PanelGetVisible = true 
			self.PanelDoneVisible = false 
		else
			self.PanelGetVisible = false 
			self.PanelDoneVisible = true
		end 
	end
end

function AchievementItemVM:ReceiveAwardSucceed()
	self.PanelGetVisible = false 
	self.PanelDoneVisible = true
	local Items = self.TableViewRewardsList:GetItems() or {}
	for i = 1, #Items do
		Items[i]:ReceiveAward(true)
	end
end

function AchievementItemVM:ProcessTextDisplays(Value)
	if Value.ProgressType == 1 then 
		self.RichTextProcessText = RichTextUtil.GetText(tostring(Value.Progress) .. '/' .. tostring(Value.TotalProgress), "b56728")
	else
		self.RichTextProcessText = RichTextUtil.GetText(LSTR(720016), "b56728")
	end
end

return AchievementItemVM