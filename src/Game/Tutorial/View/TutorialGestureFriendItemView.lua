---
--- Author: Administrator
--- DateTime: 2023-05-19 10:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local TutorialCfg = require("TableCfg/TutorialCfg")
local TutorialUtil = require("Game/Tutorial/TutorialUtil")

---@class TutorialGestureFriendItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GestureSelect TutorialGestureSelectItemView
---@field Map UFCanvasPanel
---@field TextTips TutorialGestureTips2ItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGestureFriendItemView = LuaClass(UIView, true)

function TutorialGestureFriendItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GestureSelect = nil
	--self.Map = nil
	--self.TextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGestureFriendItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GestureSelect)
	self:AddSubView(self.TextTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGestureFriendItemView:OnInit()
end

function TutorialGestureFriendItemView:OnDestroy()
end

function TutorialGestureFriendItemView:OnShow()
end

function TutorialGestureFriendItemView:OnHide()

end

function TutorialGestureFriendItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.GestureSelect.Btn, self.OnItemClicked)
end

function TutorialGestureFriendItemView:OnRegisterGameEvent()

end

function TutorialGestureFriendItemView:OnRegisterBinder()
end

function TutorialGestureFriendItemView:SetContent(Content)
	self.TextTips:SetText(Content)
end

function TutorialGestureFriendItemView:NearBy(Dir)
	self.TextTips:NearBy(Dir)
end

function TutorialGestureFriendItemView:SetTutorialID(TutorialID)
	self.TutorialID = TutorialID
end

function TutorialGestureFriendItemView:StartCountDown(Time, View, Callback)
	if self.TextTips then
		self.TextTips:StartCountDown(Time, View, Callback)
	end
end

function TutorialGestureFriendItemView:OnItemClicked()
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


return TutorialGestureFriendItemView