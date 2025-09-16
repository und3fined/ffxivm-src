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
local TutorialDefine = require("Game/Tutorial/TutorialDefine")

---@class TutorialGestureMapItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GestureSelect TutorialGestureSelectItemView
---@field Map UFCanvasPanel
---@field TextTips TutorialGestureTips2ItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGestureMapItemView = LuaClass(UIView, true)

function TutorialGestureMapItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GestureSelect = nil
	--self.Map = nil
	--self.TextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGestureMapItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GestureSelect)
	self:AddSubView(self.TextTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGestureMapItemView:OnInit()

end

function TutorialGestureMapItemView:OnDestroy()
end

function TutorialGestureMapItemView:OnShow()
	if self.Params == nil then
		return
	end

	self.TutorialID = self.Params.TutorialID
	local ContentDir  = TutorialUtil:GetContentDir(TutorialCfg:GetTutorialDir(self.TutorialID))
	local Content = TutorialCfg:GetTutorialContent(self.TutorialID)

	-- self:SetContent(Content)
	self:NearBy(ContentDir)

end

function TutorialGestureMapItemView:OnHide()

end

function TutorialGestureMapItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.GestureSelect.Btn, self.OnClickMapItem)
end

function TutorialGestureMapItemView:OnRegisterGameEvent()

end

function TutorialGestureMapItemView:OnRegisterBinder()
end

function TutorialGestureMapItemView:SetContent(Content)
	self.TextTips:SetText(Content)
end

function TutorialGestureMapItemView:NearBy(Dir)
	self.TextTips:NearBy(Dir)
	
	local Pos = TutorialDefine.TutorialContentPos.Top
	
	if TutorialDefine.TutorialArrowDir.Top == Dir then
		Pos = TutorialDefine.TutorialContentPos.Top
	elseif TutorialDefine.TutorialArrowDir.Left == Dir then
		Pos = TutorialDefine.TutorialContentPos.Left
	elseif TutorialDefine.TutorialArrowDir.Right == Dir then
		Pos = TutorialDefine.TutorialContentPos.Right
	elseif TutorialDefine.TutorialArrowDir.Bottom == Dir then
		Pos = TutorialDefine.TutorialContentPos.Bottom
	end

	UIUtil.CanvasSlotSetPosition(self.TextTips, _G.UE.FVector2D(Pos.X, Pos.Y))
	
end

function TutorialGestureMapItemView:SetTutorialID(TutorialID)
	self.TutorialID = TutorialID
end

function TutorialGestureMapItemView:OnClickMapItem()
	local TutorialID = self.TutorialID

	local UIBPName = TutorialCfg:GetTutorialBPName(TutorialID)
	local ViewID = UIViewMgr:GetViewIDByName(UIBPName)
	local View = UIViewMgr:FindVisibleView(ViewID)
	local WidgetPath = TutorialCfg:GetTutorialWidgetPath(TutorialID)
	local MapMarkers = TutorialUtil:GetTutorialWidget(View, WidgetPath)

	TutorialUtil:HandleClickGuideWidget(TutorialID, MapMarkers)

end

function TutorialGestureMapItemView:StartCountDown(Time, View, Callback)
	if self.TextTips then
		self.TextTips:StartCountDown(Time, View, Callback)
	end
end

return TutorialGestureMapItemView