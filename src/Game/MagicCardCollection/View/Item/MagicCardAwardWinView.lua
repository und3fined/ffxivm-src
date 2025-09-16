---
--- Author: Administrator
--- DateTime: 2023-12-18 16:00
--- Description:弃用
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MagicCardCollectionMgr = require("Game/MagicCardCollection/MagicCardCollectionMgr")

---@class MagicCardAwardWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field PanelWin UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field Probar UProgressBar
---@field TableViewItem UTableView
---@field TextCurrentquantity UFTextBlock
---@field TextMax UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicCardAwardWinView = LuaClass(UIView, true)

function MagicCardAwardWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.PanelWin = nil
	--self.PopUpBG = nil
	--self.Probar = nil
	--self.TableViewItem = nil
	--self.TextCurrentquantity = nil
	--self.TextMax = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicCardAwardWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicCardAwardWinView:OnInit()
	self.AwardAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewItem, self.OnCardAwardSelectChanged, true, false)
	self.Binders = {
		{"CardCollectAwardList", UIBinderUpdateBindableList.New(self, self.AwardAdapterTableView)},
		{"Percent", UIBinderSetPercent.New(self, self.Probar)},
		{"Progress", UIBinderSetText.New(self, self.TextCurrentquantity)},
		{"MaxCountText", UIBinderSetText.New(self, self.TextMax)},
	}
end

function MagicCardAwardWinView:OnDestroy()

end

function MagicCardAwardWinView:OnShow()

end

function MagicCardAwardWinView:OnHide()

end

function MagicCardAwardWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnCloseClicked)
end

function MagicCardAwardWinView:OnRegisterGameEvent()

end

function MagicCardAwardWinView:OnRegisterBinder()
	if MagicCardCollectionMgr and MagicCardCollectionMgr.CollectionAwardVM then
		self:RegisterBinders(MagicCardCollectionMgr.CollectionAwardVM, self.Binders)
	end
end

function MagicCardAwardWinView:OnCardAwardSelectChanged(Index, ItemData, ItemView)
	if self.Params == nil then
		return
	end

	if self.Params.CallBack then
		self.Params.CallBack(Index, ItemData, ItemView)
	end
	
	if ItemData.IsGetProgress then
		if MagicCardCollectionMgr and MagicCardCollectionMgr.CollectionAwardVM then
			MagicCardCollectionMgr.CollectionAwardVM:UpdateGetAwardState(Index)
		end
	end
end 

function MagicCardAwardWinView:OnCloseClicked()
	self:Hide()
end

return MagicCardAwardWinView