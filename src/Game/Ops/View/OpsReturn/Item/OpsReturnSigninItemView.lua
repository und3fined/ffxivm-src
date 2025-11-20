---
--- Author: Administrator
--- DateTime: 2025-07-22 19:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ProtoCS = require("Protocol/ProtoCS")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class OpsReturnSigninItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableView_34 UTableView
---@field TextDay UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsReturnSigninItemView = LuaClass(UIView, true)

function OpsReturnSigninItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableView_34 = nil
	--self.TextDay = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsReturnSigninItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsReturnSigninItemView:OnInit()
	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_34, self.OnClickedRewardItem, true)

	self.Binders = {
		{"Day", UIBinderSetText.New(self, self.TextDay)},
		{"RewardList", UIBinderUpdateBindableList.New(self, self.RewardListAdapter)},
	}
end

function OpsReturnSigninItemView:OnDestroy()

end

function OpsReturnSigninItemView:OnShow()

end

function OpsReturnSigninItemView:OnHide()

end

function OpsReturnSigninItemView:OnRegisterUIEvent()

end

function OpsReturnSigninItemView:OnRegisterGameEvent()

end

function OpsReturnSigninItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function OpsReturnSigninItemView:OnClickedRewardItem(Index, ItemData, ItemView)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	if ViewModel.RewardsStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		--发送查询领取
		_G.OpsReturnMgr:SetCurSignNodeID(ViewModel.NodeID)
		_G.OpsReturnMgr:SendGetTaskRewardReq(ViewModel.NodeID)
	else
		if ItemData and ItemData.ResID then
			ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
		end
	end
end

return OpsReturnSigninItemView