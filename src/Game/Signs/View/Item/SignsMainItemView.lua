---
--- Author: ds_tianjiateng
--- DateTime: 2024-03-12 19:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoRes = require("Protocol/ProtoRes")

local TargetMarkType = ProtoRes.TargetMarkType

---@class SignsMainItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelItem UFCanvasPanel
---@field PanelSort UFCanvasPanel
---@field TableViewSigns UTableView
---@field TextSort UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SignsMainItemView = LuaClass(UIView, true)

function SignsMainItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelItem = nil
	--self.PanelSort = nil
	--self.TableViewSigns = nil
	--self.TextSort = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SignsMainItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SignsMainItemView:OnInit()
	self.TableAdapterItemSigns = UIAdapterTableView.CreateAdapter(self, self.TableViewSigns, self.OnSelectedChanged, true)
	
	self.Binders = {
		{"SignsSlots", 			UIBinderUpdateBindableList.New(self, self.TableAdapterItemSigns)},
		{"TittleText", 			UIBinderSetText.New(self, self.TextSort)},
		{"TittleTextVisible", 	UIBinderSetIsVisible.New(self, self.PanelSort)},
		{"PanelItemVisible", 	UIBinderSetIsVisible.New(self, self.PanelItem)},
	}
end

function SignsMainItemView:OnDestroy()

end

function SignsMainItemView:OnSelectedChanged(Index, ItemData, ItemView)
	_G.EventMgr:SendEvent(_G.EventID.TeamSignsSelectedCancle)
	if ItemData.IsUsed then
		local IconID = ItemData.ID
		_G.SignsMgr:SendTargetMarkingReq(0, IconID)
		_G.EventMgr:SendEvent(_G.EventID.TeamSignsSelected, string.format("%s%d", ProtoEnumAlias.GetAlias(TargetMarkType, self.ViewModel.Index), Index))
	else
		if _G.SignsMgr.TargetID == 0 then
			MsgTipsUtil.ShowTips(LSTR("无可标记目标，请先选择目标再进行标记"))
		else
			--- 选中的Slot已使用并且是当前选中EntityID，上报0取消当前标记
			local IconID = ItemData.ID
			local TargetID = _G.SignsMgr.TargetID
			if ItemData.IsUsed and _G.SignsMgr:GetMarkingByEntityID(TargetID) == IconID then
				TargetID = 0
			end
			_G.SignsMgr:SendTargetMarkingReq(TargetID, IconID)
			ItemData.IsSelected = true
			local SelectedTextIndex = Index
			if self.ViewModel.Index == 1 then
				SelectedTextIndex = ItemData.ID
			end
			--- 事件通知主界面改变下方标记描述
			_G.EventMgr:SendEvent(_G.EventID.TeamSignsSelected, string.format("%s%d", ProtoEnumAlias.GetAlias(TargetMarkType, self.ViewModel.Index), SelectedTextIndex))
		end
	end
end

function SignsMainItemView:OnShow()

end

function SignsMainItemView:OnHide()

end

function SignsMainItemView:OnRegisterUIEvent()

end

function SignsMainItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TeamTargetMarkStateChanged, self.OnUsedStateChange)

end

function SignsMainItemView:OnUsedStateChange(Params)
    local EntityID = Params and Params.EntityID

	if self.ViewModel.IsUsed then
		self.ViewModel:SetIsUsed(false)
	end
	if _G.SignsMgr:GetMarkingByEntityID(EntityID) == self.ViewModel.ID and self.ViewModel.IsUsed ~= nil then
		self.ViewModel:SetIsUsed(true)
	end
end
function SignsMainItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return SignsMainItemView