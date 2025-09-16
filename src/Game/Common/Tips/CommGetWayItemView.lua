---
--- Author: chaooren
--- DateTime: 2021-12-02 14:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SystemEntranceMgr = require("Game/Common/Tips/SystemEntranceMgr")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local LSTR = _G.LSTR
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

---@class CommGetWayItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@fi---@field IconLock UFImage
---@field ImgArrow UFImage
---@field ImgBG UFImage
---@field ImgFocus UFImage
---@field ImgItemIcon UFImage
---@field TextQuestName UFTextBlock
---@field IsClipped bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommGetWayItemView = LuaClass(UIView, true)

function CommGetWayItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.IconLock = nil
	--self.ImgArrow = nil
	--self.ImgBG = nil
	--self.ImgFocus = nil
	--self.ImgItemIcon = nil
	--self.TextQuestName = nil
	--self.IsClipped = nil
	--self.TextQuestName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommGetWayItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommGetWayItemView:OnInit()

end

function CommGetWayItemView:OnDestroy()

end

function CommGetWayItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Item = Params.Data
	if nil == Item then
		return
	end
	
	self:SetGetWayContentShow(Item)
end

function CommGetWayItemView:OnHide()

end

function CommGetWayItemView:SetGetWayContentShow(Item)
	if Item.IsUnLock then
		--UIUtil.SetColorAndOpacity(self.TextQuestName, 1, 1, 1, 1)
		--UIUtil.SetColorAndOpacity(self.ImgArrow, 1, 1, 1, 1)
		--UIUtil.SetColorAndOpacity(self.ImgItemIcon, 1, 1, 1, 1)
		self.IsUnLock = true
		
	else
		--UIUtil.SetColorAndOpacity(self.TextQuestName, 0.4, 0.4, 0.4, 0.4)
		--UIUtil.SetColorAndOpacity(self.ImgArrow, 0.4, 0.4, 0.4, 0.4)
		--UIUtil.SetColorAndOpacity(self.ImgItemIcon, 0.4, 0.4, 0.4, 0.4)
		--UIUtil.SetColorAndOpacity(self.IconLock, 0.4, 0.4, 0.4, 0.4)
		self.IsUnLock = false
	end

	UIUtil.SetIsVisible(self.ImgArrow, Item.IsUnLock and Item.IsRedirect and Item.IsRedirect > 0)
	UIUtil.SetIsVisible(self.IconLock, not Item.IsUnLock)
	
	---- 已解锁 且 不满足剧透条件 隐藏箭头 显示不可剧透文字
	if not Item.CanRevealPlot then
		self.TextQuestName:SetText(Item.SpoilerTipsDesc or "")
		UIUtil.SetIsVisible(self.ImgArrow, false)
	else
		UIUtil.ImageSetBrushFromAssetPath(self.ImgItemIcon, Item.FunIcon)
		self.TextQuestName:SetText(Item.FunDesc)
	end
end

function CommGetWayItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickedGoBtn)
end

function CommGetWayItemView:OnRegisterGameEvent()
	--self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)
end

function CommGetWayItemView:OnRegisterBinder()

end

function CommGetWayItemView:OnPreprocessedMouseButtonUp(MouseEvent)
	local MousePosition = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.BtnGo, MousePosition) == true then
		self:OnClickedGoBtn()
	end
end

function CommGetWayItemView:ClosePanelOnJump()
	UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
	UIViewMgr:HideView(UIViewID.CommonMsgBox)
end

function CommGetWayItemView:OnClickedGoBtn()
	if not self.Params or not self.Params.Data then
		self:ClosePanelOnJump()
	else
		self:OnJumpWay()
	end
end

function CommGetWayItemView:OnJumpWay()
	local Params = self.Params
	local Item = Params.Data
	if Item.Source then
		DataReportUtil.ReportItemAccessGetWayData(Item.ItemID, Item.Source)
	end
	
	local AdapterParams = Params.Adapter.Params
	if AdapterParams and AdapterParams.ViewModel and AdapterParams.ViewModel.Item then
		Item.TransferData = AdapterParams.ViewModel.Item
	end

	if not Item.IsUnLock or not Item.CanRevealPlot then
		if Item.UnLockTipsID and Item.UnLockTipsID > 0 then
			MsgTipsUtil.ShowTipsByID(Item.UnLockTipsID)
		else
			MsgTipsUtil.ShowTips(LSTR(1020074))
		end

		self:ClosePanelOnJump()
		return
	end

	if Item.IsRedirect == 0 then --跳转状态为0不跳转
		local Alignment = Item.Alignment
		if self.IsClipped then
			local TipsUtil = require("Utils/TipsUtil")
			TipsUtil.ShowInfoTips(Item.FunDescItem, self.BtnGo, _G.UE.FVector2D(0, 0), Alignment)
		else
			self:ClosePanelOnJump()
		end
		
		return
	end

	local AdapterParams1 = Params.Adapter.Params
	if AdapterParams1 and  AdapterParams1.ViewModel and  AdapterParams1.ViewModel.ParentViewID then
		UIViewMgr:HideView(AdapterParams1.ViewModel.ParentViewID)
	end
	
	self:ClosePanelOnJump()
	local ItemUtil = require("Utils/ItemUtil")
	ItemUtil.JumpGetWayByItemData(Item)
end

return CommGetWayItemView