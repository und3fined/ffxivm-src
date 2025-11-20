---
--- Author: Administrator
--- DateTime: 2025-09-18 10:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")
local UIBindableList = require("UI/UIBindableList")
local AchievementDetailJobItemVM = require("Game/Achievement/VM/Item/AchievementDetailJobItemVM")
local AchievementDiyGruopCfg = require("TableCfg/AchievementDiyGruopCfg")

local AchievementMgr = _G.AchievementMgr
local LSTR = _G.LSTR

---@class AchievementProgressViewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field FImage_70 UFImage
---@field ImgStateIcon UFImage
---@field PanelDone UFCanvasPanel
---@field RichTextProcess URichTextBox
---@field TableView_58 UTableView
---@field TextContent UFTextBlock
---@field TextDate2 UFTextBlock
---@field TextName UFTextBlock
---@field TextReach UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimTracked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AchievementProgressViewItemView = LuaClass(UIView, true)

function AchievementProgressViewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.FImage_70 = nil
	--self.ImgStateIcon = nil
	--self.PanelDone = nil
	--self.RichTextProcess = nil
	--self.TableView_58 = nil
	--self.TextContent = nil
	--self.TextDate2 = nil
	--self.TextName = nil
	--self.TextReach = nil
	--self.AnimIn = nil
	--self.AnimTracked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AchievementProgressViewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AchievementProgressViewItemView:OnInit()
	self.JobList = UIBindableList.New( AchievementDetailJobItemVM )
	self.JobTableView = UIAdapterTableView.CreateAdapter(self, self.TableView_58)
	self.Binders = {
		{ "Title", UIBinderSetText.New(self, self.TextName) },
		{ "Icon", UIBinderValueChangedCallback.New(self, nil, self.OnIconChanged)},
		{ "TitleIcon", UIBinderValueChangedCallback.New(self, nil, self.OnTitleIconChanged)},
		{ "ID", UIBinderValueChangedCallback.New(self, nil, self.OnIDChanged) },
	}
end

function AchievementProgressViewItemView:OnIconChanged(NewValue)
	if (NewValue or "") == "" then
		UIUtil.SetIsVisible(self.ImgStateIcon, false)
	else
		UIUtil.ImageSetBrushFromAssetPath(self.ImgStateIcon, NewValue)
		UIUtil.SetIsVisible(self.ImgStateIcon, true)
	end
end

function AchievementProgressViewItemView:OnTitleIconChanged(NewValue)
	if (NewValue or "") == "" then
		UIUtil.SetIsVisible(self.FImage_70, false)
	else
		UIUtil.ImageSetBrushFromAssetPath(self.FImage_70, NewValue)
		UIUtil.SetIsVisible(self.FImage_70, true)
	end
end

function AchievementProgressViewItemView:OnIDChanged(NewValue)
	local DiyGroupCfg = AchievementDiyGruopCfg:FindCfgByKey(NewValue)
	if DiyGroupCfg == nil then
		return
	end
	local DiyGroupCfgParams = DiyGroupCfg.Params or {}
	local FinishJobNum = tonumber(DiyGroupCfgParams[3] or 0)
	local SceneId = tonumber(DiyGroupCfgParams[1] or 0)
	local ModeId = tonumber(DiyGroupCfgParams[2] or 0)
	UIUtil.SetIsVisible(self.PanelDone, false)
	UIUtil.SetIsVisible(self.RichTextProcess, false)
	local ViewModel = self.ViewModel or {}
	local ContentText = ViewModel.Content or ""
	local FinishTime, FinishProfs = AchievementMgr:GetSceneFinishState(SceneId, ModeId, FinishJobNum)
	if #FinishProfs <= 0 then
		UIUtil.SetIsVisible(self.TableView_58, false)
		UIUtil.SetIsVisible(self.RichTextProcess, true)
		ContentText = ContentText .. LSTR(720030)    --"无"
	else
		local JobList = {}
		for i = 1, #FinishProfs do
			table.insert(JobList, FinishProfs[i].ProfId )
		end
		self.JobList:UpdateByValues(JobList)
		self.JobTableView:UpdateAll(self.JobList)
		UIUtil.SetIsVisible(self.PanelDone, FinishTime ~= 0)
		UIUtil.SetIsVisible(self.TableView_58, true)
		UIUtil.SetIsVisible(self.RichTextProcess, FinishTime == 0 )
	end
	self.TextContent:SetText(ContentText)
end

function AchievementProgressViewItemView:OnDestroy()

end

function AchievementProgressViewItemView:OnShow()
	self.RichTextProcess:SetText(LSTR(720016))      	-- "进行中"
	self.TextReach:SetText(LSTR(720021))      			-- "已达成"
end

function AchievementProgressViewItemView:OnHide()

end

function AchievementProgressViewItemView:OnRegisterUIEvent()

end

function AchievementProgressViewItemView:OnRegisterGameEvent()

end

function AchievementProgressViewItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return AchievementProgressViewItemView