---
--- Author: Administrator
--- DateTime: 2024-08-01 15:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local TutorialCfg = require("TableCfg/TutorialCfg")
local TutorialUtil = require("Game/Tutorial/TutorialUtil")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local LogMgr = require("Log/LogMgr")

---@class TutorialGuidanceItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GestureSelect TutorialGestureSelectItemView
---@field PanelTipsDown UFCanvasPanel
---@field PanelTipsLeft UFCanvasPanel
---@field PanelTipsRight UFCanvasPanel
---@field PanelTipsSuperior UFCanvasPanel
---@field TextTipsD TutorialGestureTips2ItemView
---@field TextTipsL TutorialGestureTips2ItemView
---@field TextTipsR TutorialGestureTips2ItemView
---@field TextTipsS TutorialGestureTips2ItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGuidanceItemView = LuaClass(UIView, true)

function TutorialGuidanceItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GestureSelect = nil
	--self.PanelTipsDown = nil
	--self.PanelTipsLeft = nil
	--self.PanelTipsRight = nil
	--self.PanelTipsSuperior = nil
	--self.TextTipsD = nil
	--self.TextTipsL = nil
	--self.TextTipsR = nil
	--self.TextTipsS = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGuidanceItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GestureSelect)
	self:AddSubView(self.TextTipsD)
	self:AddSubView(self.TextTipsL)
	self:AddSubView(self.TextTipsR)
	self:AddSubView(self.TextTipsS)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGuidanceItemView:OnInit()
end

function TutorialGuidanceItemView:OnDestroy()

end

function TutorialGuidanceItemView:OnShow()
end

function TutorialGuidanceItemView:OnHide()
end

function TutorialGuidanceItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.GestureSelect.Btn, self.OnBtnClicked)
end

function TutorialGuidanceItemView:OnRegisterGameEvent()

end

function TutorialGuidanceItemView:OnRegisterBinder()
end

function TutorialGuidanceItemView:SetCurTips(Dir,IsSystemUI)
	UIUtil.SetIsVisible(self.TextTipsSystemS, false)
	UIUtil.SetIsVisible(self.TextTipsS, false)
	UIUtil.SetIsVisible(self.TextTipsSystemD, false)
	UIUtil.SetIsVisible(self.TextTipsD, false)
	UIUtil.SetIsVisible(self.TextTipsSystemL, false)
	UIUtil.SetIsVisible(self.TextTipsL, false)
	UIUtil.SetIsVisible(self.TextTipsSystemR, false)
	UIUtil.SetIsVisible(self.TextTipsR, false)

	if Dir == TutorialDefine.TutorialArrowDir.Top then
		if IsSystemUI == 1 then
			self.CurTextTips = self.TextTipsS
		else
			self.CurTextTips = self.TextTipsSystemS
		end
	elseif Dir == TutorialDefine.TutorialArrowDir.Bottom then
		if IsSystemUI == 1 then
			self.CurTextTips = self.TextTipsD
		else
			self.CurTextTips = self.TextTipsSystemD
		end
	elseif Dir == TutorialDefine.TutorialArrowDir.Left then
		if IsSystemUI == 1 then
			self.CurTextTips = self.TextTipsL
		else
			self.CurTextTips = self.TextTipsSystemL
		end
	elseif Dir == TutorialDefine.TutorialArrowDir.Right then
		if IsSystemUI == 1 then
			self.CurTextTips = self.TextTipsR
		else
			self.CurTextTips = self.TextTipsSystemR
		end
	end
end

function TutorialGuidanceItemView:NearBy(Dir,Cfg)
	UIUtil.SetIsVisible(self.PanelTipsDown, TutorialDefine.TutorialArrowDir.Bottom == Dir)
	UIUtil.SetIsVisible(self.PanelTipsLeft, TutorialDefine.TutorialArrowDir.Left == Dir)
	UIUtil.SetIsVisible(self.PanelTipsRight, TutorialDefine.TutorialArrowDir.Right == Dir)
	UIUtil.SetIsVisible(self.PanelTipsSuperior, TutorialDefine.TutorialArrowDir.Top == Dir)

	if self.CurTextTips then
		UIUtil.SetIsVisible(self.CurTextTips, true, true)
		self.CurTextTips:NearBy(Dir,Cfg)
	end 
end

function TutorialGuidanceItemView:SetTutorialID(TutorialID)
	self.TutorialID = TutorialID
end

function TutorialGuidanceItemView:SetContent(Content)
	if self.CurTextTips then
		self.CurTextTips:SetText(Content)
	end
end

function TutorialGuidanceItemView:StartCountDown(Time, View, Callback)
	if self.CurTextTips then
		self.CurTextTips:StartCountDown(Time, View, Callback)
	end
end

function TutorialGuidanceItemView:RemoveTimer()
	if self.CurTextTips then
		self.CurTextTips:RemoveTimer()
	end
end

function TutorialGuidanceItemView:OnBtnClicked()
	local TutorialID = self.TutorialID

	if TutorialID ~= nil then
		local Cfg = _G.NewTutorialMgr:GetRunningCfg(TutorialID)

		if Cfg ~= nil then
			local UIBPName = Cfg.BPName
			local ViewID = UIViewMgr:GetViewIDByName(UIBPName)
			local View = UIViewMgr:FindVisibleView(ViewID)
			local WidgetPath = Cfg.WidgetPath
			local Widget = nil

			if string.find(WidgetPath,"Adapter") and Cfg.HandleType ~= TutorialDefine.TutorialHandleType.TableView then
				Widget = TutorialUtil:GetTutorialWidgetWithAdapter(View, WidgetPath,Cfg.StartParam)
			else
				Widget = TutorialUtil:GetTutorialWidget(View, WidgetPath)
			end

			if WidgetPath == "MainTeamPanel/MainQuestPanel/MainlineQuest/TableViewAdapter/IconSpanCoordinate" then
				WidgetPath = "MainTeamPanel/MainQuestPanel/MainlineQuest/TableViewAdapter/BtnMap"
				Widget = TutorialUtil:GetTutorialWidgetWithAdapter(View, WidgetPath,Cfg.StartParam)
			end

			if WidgetPath == "MountPanel/SkillSprintMountDownBtn/BtnRun" then
				Widget = TutorialUtil:GetTutorialWidget(View, "MountPanel")
			end

			TutorialUtil:HandleClickGuideWidget(Cfg, Widget)
		else
			LogMgr.Info(string.format("找不到对应的引导数据ID: %d", TutorialID))
		end
	end
end



return TutorialGuidanceItemView