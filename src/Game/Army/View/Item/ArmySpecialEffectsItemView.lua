---
--- Author: Administrator
--- DateTime: 2024-05-06 19:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TipsUtil = require("Utils/TipsUtil")
local TimeUtil = require("Utils/TimeUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local UIViewMgr = require("UI/UIViewMgr")
local ArmyMgr

---@class ArmySpecialEffectsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInfo UFButton
---@field ImgIcon UFImage
---@field PanelContent UFCanvasPanel
---@field PanelNoopen UFCanvasPanel
---@field TextContent UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySpecialEffectsItemView = LuaClass(UIView, true)

function ArmySpecialEffectsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInfo = nil
	--self.ImgIcon = nil
	--self.PanelContent = nil
	--self.PanelNoopen = nil
	--self.TextContent = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsItemView:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	self.Binders = {
        {"IsEmpty", UIBinderValueChangedCallback.New(self, nil ,self.SetEmpty)},
		{"Icon", UIBinderValueChangedCallback.New(self, nil, self.ImgIconChanged)}, 
		{"Name", UIBinderValueChangedCallback.New(self, nil, self.TextNameChanged)}, 
		--{"SimpleDesc", UIBinderValueChangedCallback.New(self, nil, self.TextContentChanged)}, 
		{"TimeStr", UIBinderValueChangedCallback.New(self, nil, self.TextContentChanged)}, 
		{"Time", UIBinderValueChangedCallback.New(self, nil, self.OnEndTimeChanged)},
	}
end

function ArmySpecialEffectsItemView:SetEmpty(InIsEmpty)
	if InIsEmpty then
		if self.ContentView then
			self:RemoveSubPanel(self.ContentView)
			self.ContentView = nil
		end
		if self.EmptyView == nil then
			self.EmptyView = UIViewMgr:CreateViewByName("Army/Item/ArmySpecialEffectsEmptyItem_UIBP", nil, self, true)
			if self.EmptyView then
				self.PanelContent:AddChildToCanvas(self.EmptyView)
				local Anchor = _G.UE.FAnchors()
				Anchor.Minimum = _G.UE.FVector2D(0, 0)
				Anchor.Maximum = _G.UE.FVector2D(1, 1)
				UIUtil.CanvasSlotSetAnchors(self.EmptyView, Anchor)
				UIUtil.CanvasSlotSetSize(self.EmptyView, _G.UE.FVector2D(0, 0))
			end
		end
	else
		if self.EmptyView then
			self:RemoveSubPanel(self.EmptyView)
			self.EmptyView = nil
		end
		if self.ContentView == nil then
			self.ContentView = UIViewMgr:CreateViewByName("Army/Item/ArmySpecialEffectsSubItem_UIBP", nil, self, true)
			if self.ContentView then
				self.PanelContent:AddChildToCanvas(self.ContentView)
				UIUtil.CanvasSlotSetSize(self.ContentView, _G.UE.FVector2D(0, 0))
				self.ContentView:SetCallback(self, self.OnClickedInfo)
				---设置一下数据，防止绑定数据变化时，子view还没有添加
				if self.Params and self.Params.Data then
					self.SEItemVM = self.Params.Data
					if self.SEItemVM.Name then
						self.ContentView.TextName:SetText(self.SEItemVM.Name)
					end
					if self.SEItemVM.Icon then
						UIUtil.ImageSetBrushFromAssetPath(self.ContentView.ImgIcon, self.SEItemVM.Icon)
					end
					if self.SEItemVM.TimeStr then
						UIUtil.SetIsVisible(self.ContentView.TextContent, true)
						self.ContentView.TextContent:SetText(self.SEItemVM.TimeStr)
					end
				end
			end
		end
	end
end

function ArmySpecialEffectsItemView:RemoveSubPanel(View)
    if View then
        self.PanelContent:RemoveChild(View)
        UIViewMgr:RecycleView(View)
    end
end

function ArmySpecialEffectsItemView:ImgIconChanged(InIcon)
	if self.ContentView and self.ContentView.ImgIcon then 
		UIUtil.ImageSetBrushFromAssetPath(self.ContentView.ImgIcon, InIcon)
	else
        _G.FLOG_INFO("ArmySpecialEffectsItemView.ContentView.ImgIcon is nil")
	end
end

function ArmySpecialEffectsItemView:TextNameChanged(InName)
	if self.ContentView and self.ContentView.TextName then 
		self.ContentView.TextName:SetText(InName)
	else
        _G.FLOG_INFO("ArmySpecialEffectsItemView.ContentView.TextName is nil")
	end
end

function ArmySpecialEffectsItemView:TextContentChanged(InContent)
	if self.ContentView and self.ContentView.TextContent then 
		UIUtil.SetIsVisible(self.ContentView.TextContent, true)
		self.ContentView.TextContent:SetText(InContent)
	else
        _G.FLOG_INFO("ArmySpecialEffectsItemView.ContentView.TextContent is nil")
	end
end

function ArmySpecialEffectsItemView:OnDestroy()

end

function ArmySpecialEffectsItemView:OnShow()

end

function ArmySpecialEffectsItemView:OnHide()

end

function ArmySpecialEffectsItemView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.BtnInfo, self.OnClickedInfo)
end

function ArmySpecialEffectsItemView:OnRegisterGameEvent()

end

function ArmySpecialEffectsItemView:OnRegisterBinder()
	if self.Params and self.Params.Data then
		self.SEItemVM = self.Params.Data
		self:RegisterBinders(self.SEItemVM, self.Binders)
	end
end

function ArmySpecialEffectsItemView:OnClickedInfo()
	if self.SEItemVM then
		local Params = {}
		Params.Title = self.SEItemVM.Name
		-- LSTR string:效果:
		Params.Content = string.format("%s %s \n%s %s",LSTR(910146), self.SEItemVM.Desc, LSTR(910075), self.SEItemVM.TimeStr)
		if self.ContentView and self.ContentView.ImgIcon then 
			TipsUtil.ShowSimpleTipsView(Params, self.ContentView.ImgIcon, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0), false)
		end
	end
end

function ArmySpecialEffectsItemView:OnEndTimeChanged(Time)
	if Time and Time < 60 then
		self.EndTimer = self:RegisterTimer(self.TimeDataUpdate, 0, 1, -1)
	end
end

function ArmySpecialEffectsItemView:TimeDataUpdate(Params)
	local CurTime = TimeUtil.GetServerTime()
	local Time = self.SEItemVM.EndTime - CurTime
	if Time > 0 then
		local TimeStr = LocalizationUtil.GetCountdownTimeForSimpleTime(Time, "s")
		self.SEItemVM:SetTimeStr(TimeStr)
	else
		if self.EndTimer then
			self:UnRegisterTimer(self.EndTimer)
			self.EndTimer = nil
		end
		ArmyMgr:QueryGroupBonusState()
	end
end

return ArmySpecialEffectsItemView