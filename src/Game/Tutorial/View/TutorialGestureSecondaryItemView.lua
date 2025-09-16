---
--- Author: Administrator
--- DateTime: 2023-05-19 10:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local TutorialCfg = require("TableCfg/TutorialCfg")
local TutorialUtil = require("Game/Tutorial/TutorialUtil")
local TutorialBaseView = require("Game/Tutorial/View/TutorialBaseView")

---@class TutorialGestureSecondaryItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GestureSelect TutorialGestureSelectItemView
---@field Secondary UFCanvasPanel
---@field TextTips TutorialGestureTips2ItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGestureSecondaryItemView = LuaClass(TutorialBaseView, true)

function TutorialGestureSecondaryItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GestureSelect = nil
	--self.Secondary = nil
	--self.TextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGestureSecondaryItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GestureSelect)
	self:AddSubView(self.TextTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGestureSecondaryItemView:OnInit()
end

function TutorialGestureSecondaryItemView:OnDestroy()
end

function TutorialGestureSecondaryItemView:OnShow()
	if self.Params == nil then
		return 
	end
	
	self.TutorialID = self.Params.TutorialID
end

function TutorialGestureSecondaryItemView:OnHide()
	self.TutorialID = nil
end

function TutorialGestureSecondaryItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.GestureSelect.Btn, 	self.OnItemClicked)
end

function TutorialGestureSecondaryItemView:OnRegisterGameEvent()
end

function TutorialGestureSecondaryItemView:OnRegisterBinder()
end

function TutorialGestureSecondaryItemView:SetContent(Content)
	self.TextTips:SetText(Content)
end

function TutorialGestureSecondaryItemView:NearBy(Dir)
	if Dir == nil then
		return
	end
	self.TextTips:NearBy(Dir)
end

function TutorialGestureSecondaryItemView:OnItemClicked()
	local TutorialID = self.TutorialID
	if TutorialID ~= nil then
		local UIBPName = TutorialCfg:GetTutorialBPName(TutorialID)
		local ViewID = UIViewMgr:GetViewIDByName(UIBPName)
		local View = UIViewMgr:FindVisibleView(ViewID)
		local WidgetPath = TutorialCfg:GetTutorialWidgetPath(TutorialID)
		local Widget = TutorialUtil:GetTutorialWidget(View, WidgetPath)
		TutorialUtil:HandleClickGuideWidget(TutorialID, Widget)
	end
end

function TutorialGestureSecondaryItemView:SetTutorialID(TutorialID)
	self.TutorialID = TutorialID
end


function TutorialGestureSecondaryItemView:StartCountDown(Time, View, Callback)
	if self.TextTips then
		self.TextTips:StartCountDown(Time, View, Callback)
	end
end


return TutorialGestureSecondaryItemView