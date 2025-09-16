
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TreasureChestVM = require("Game/TreasureChest/VM/TreasureChestVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class BagTreasureChestWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnNormal CommBtnLView
---@field BtnRecommend CommBtnLView
---@field CommFrame Comm2FrameLView
---@field TableViewList UTableView
---@field TextHint UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BagTreasureChestWinView = LuaClass(UIView, true)

function BagTreasureChestWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnNormal = nil
	--self.BtnRecommend = nil
	--self.CommFrame = nil
	--self.TableViewList = nil
	--self.TextHint = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BagTreasureChestWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnNormal)
	self:AddSubView(self.BtnRecommend)
	self:AddSubView(self.CommFrame)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BagTreasureChestWinView:OnInit()
	self.AdapterTableViewList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnListSclectedChanged, true)
	self.Binders = {
		{ "OptionList", 	UIBinderUpdateBindableList.New(self, self.AdapterTableViewList) },
		-- { "CurrentNum", 	UIBinderValueChangedCallback.New(self, nil, self.OnVMCurrentNumChanged) },
		{ "TextHintText", 	UIBinderSetText.New(self, self.TextHint) },
	}
	self.LimitTipsStr = LSTR(1230008)							--- "已达选择上限"
	self.DisabledTips = LSTR(1230009)							--- "请先选择奖励"
end

function BagTreasureChestWinView:OnDestroy()

end

function BagTreasureChestWinView:OnShow()
	self.CommFrame:SetTitleText(LSTR(1230001))			--- "奖励自选"
	self.BtnNormal:SetBtnName(LSTR(1230002))			--- "取消"
	TreasureChestVM:UpdateViewData()
	self.BtnRecommend:SetButtonText(LSTR(1230003))			--- "兑  换"
end

function BagTreasureChestWinView:OnListSclectedChanged(Index, ItemData, ItemView)
	if not ItemData.IsSelected then
	-- 	ItemData:OnSetIsSelected(not ItemData.IsSelected)
	-- 	if ItemView ~= nil and ItemView.SetCurValue ~= nil then
	-- 		ItemView:SetCurValue(ItemData.SelectedNum)
	-- 	end
	-- else
		if TreasureChestVM:OnCheckNumIsValid() then
			ItemData:OnSetIsSelected(not ItemData.IsSelected)
			if ItemView ~= nil and ItemView.SetCurValue ~= nil then
				ItemView:SetCurValue(ItemData.SelectedNum)
			end
		else
			MsgTipsUtil.ShowTips(self.LimitTipsStr, nil, 1)
		end
	end
	
end

function BagTreasureChestWinView:OnHide()
end

function BagTreasureChestWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnNormal.Button, self.OnClickedBtnNormal)
	UIUtil.AddOnClickedEvent(self, self.BtnRecommend.Button, self.OnClickedBtnRecommend)
end

function BagTreasureChestWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.BagTreasureChestNumChanged, self.OnVMCurrentNumChanged)
end

function BagTreasureChestWinView:OnVMCurrentNumChanged()
	local IsEnable = TreasureChestVM.CurrentNum > 0
	if IsEnable then
		self.BtnRecommend:SetIsRecommendState(true)
	else
		self.BtnRecommend:SetIsDisabledState(true, true)
	end
end

function BagTreasureChestWinView:OnRegisterBinder()
	self:RegisterBinders(TreasureChestVM, self.Binders)
end

function BagTreasureChestWinView:OnClickedBtnRecommend()
	if TreasureChestVM.CurrentNum <= 0 then
		_G.MsgTipsUtil.ShowTips(self.DisabledTips)
		return
	end
	TreasureChestVM:OnClickRecommend()
end

function BagTreasureChestWinView:OnClickedBtnNormal()
	self:Hide()
	TreasureChestVM:OnInit()
end


return BagTreasureChestWinView