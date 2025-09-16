---
--- Author: Administrator
--- DateTime: 2024-06-27 14:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CommHelpInfoVM =  require("Game/Common/Tips/VM/CommHelpInfoVM")
local FVector2D = _G.UE.FVector2D

local InfoTipMargin = {
    Left = -35,
    Top = -26,
    Right = -35,
    Bottom = -31,
}

local InfoTipGap = 10

---@class CommHelpInfoTips1View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg2 UFImage
---@field PanelTips UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field SizeBox2 USizeBox
---@field TableViewContent UTableView
---@field AnimShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommHelpInfoTips1View = LuaClass(UIView, true)

function CommHelpInfoTips1View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg2 = nil
	--self.PanelTips = nil
	--self.PopUpBG = nil
	--self.SizeBox2 = nil
	--self.TableViewContent = nil
	--self.AnimShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommHelpInfoTips1View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommHelpInfoTips1View:OnInit()
	self.VM = CommHelpInfoVM.New()
	self.TableViewContentAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewContent)
	self.Binders = {}
	self.AnimIn = nil
end

function CommHelpInfoTips1View:OnDestroy()

end

function CommHelpInfoTips1View:OnShow()
	if self.Params == nil then
		return
	end

	local Params = self.Params

	if Params.Data then
		self.VM:UpdateVM(Params.Data)
	end

	local HidePopUpBG = Params.HidePopUpBG

	if HidePopUpBG then
		UIUtil.SetIsVisible(self.PopUpBG, false, false)
	end

	if not Params.HidePopUpBG and Params.View and self.Params.HidePopUpBGCallback  then
		UIUtil.SetIsVisible(self.PopUpBG, true, true)
		self.PopUpBG:SetCallback(self.Params.View, self.Params.HidePopUpBGCallback)
	end

	local Offset = Params.Offset
	local Alignment = Params.Alignment

	if Alignment.X == 0.0 and Alignment.Y  == 0.0 then
		Offset.X = Offset.X - InfoTipMargin.Left - InfoTipGap
		Offset.Y = Offset.Y - InfoTipMargin.Top
	elseif Alignment.X == 1.0 and Alignment.Y == 1.0 then
		Offset.X = Offset.X + InfoTipMargin.Right - InfoTipGap
		Offset.Y = Offset.Y + InfoTipMargin.Bottom
	elseif Alignment.X == 1.0 and Alignment.Y == 0.0 then
		Offset.X = Offset.X + InfoTipMargin.Right - InfoTipGap
		Offset.Y = Offset.Y - InfoTipMargin.Top
	elseif Alignment.X == 0.0 and Alignment.Y == 1.0 then
		Offset.X = Offset.X - InfoTipMargin.Left - InfoTipGap
		Offset.Y = Offset.Y + InfoTipMargin.Bottom
	end

	UIUtil.CanvasSlotSetPosition(self.PanelTips, FVector2D(0, 0))
	UIUtil.CanvasSlotSetAlignment(self.PanelTips, FVector2D(0, 0))
	UIUtil.SetRenderOpacity(self.PanelTips, 0)
	
	-- 0.3 秒PanelTips的大小才正确
	self:RegisterTimer(function ()
		if Params.InTargetWidget then
			TipsUtil.AdjustTipsPosition(self.PanelTips, Params.InTargetWidget, Offset, Alignment)
		else
			TipsUtil.AdjustTipsPositionByPos(self.PanelTips, Offset, Alignment)
		end
		UIUtil.SetRenderOpacity(self.PanelTips, 1)
		self:PlayAnimation(self.AnimShow)
	end, 0.3)

end

function CommHelpInfoTips1View:OnHide()

end

function CommHelpInfoTips1View:OnRegisterUIEvent()

end

function CommHelpInfoTips1View:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function CommHelpInfoTips1View:OnRegisterBinder()
	local Binders = {
		{"TableViewContentList", UIBinderUpdateBindableList.New(self, self.TableViewContentAdapter)},
	}

	self:RegisterBinders(self.VM, Binders)
end

function CommHelpInfoTips1View:UpdateData(Data)
	if self.VM then
		self.VM:UpdateVM(Data)
	end
end

function CommHelpInfoTips1View:OnPreprocessedMouseButtonDown(MouseEvent)
	local Params = self.Params

	local MousePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelTips, MousePosition) == false then
		if Params.HidePopUpBGCallback ~= nil then
			self.PopUpBG:OnClickButtonMask()
		else
			_G.UIViewMgr:HideView(_G.UIViewID.CommHelpInfoTipsView)
		end
	end
end

return CommHelpInfoTips1View