---
--- Author: Administrator
--- DateTime: 2023-09-18 09:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local JumboCactpotVM = require("Game/JumboCactpot/JumboCactpotVM")

local LSTR = _G.LSTR
---@class JumboCactpotHistorylotteryView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PlayStyleCommFrameL_UIBP PlayStyleCommFrameLView
---@field RichTextTime URichTextBox
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotHistorylotteryView = LuaClass(UIView, true)

function JumboCactpotHistorylotteryView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PlayStyleCommFrameL_UIBP = nil
	--self.RichTextTime = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotHistorylotteryView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayStyleCommFrameL_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotHistorylotteryView:OnInit()
	self.LottoryNameList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, true)

	self.Binders = {
		{ "LottoryNameList", UIBinderUpdateBindableList.New(self, self.LottoryNameList)},
		-- { "OwnJDNum", UIBinderSetTextFormatForMoney.New(self, self.PlayStyleCommFrameL_UIBP.CommCurrency01.TextAmount)},
	}
end

function JumboCactpotHistorylotteryView:OnDestroy()

end

function JumboCactpotHistorylotteryView:OnShow()
	local Params = self.Params
	local Title = string.format(LSTR(240059), Params.Term) -- %s·一等奖中奖名单
	self.PlayStyleCommFrameL_UIBP.FText_Title:SetText(Title)

	local OpenTime = Params.OpenTime
	self.RichTextTime:SetText(tostring(OpenTime))

	-- UIUtil.SetIsVisible(self.PlayStyleCommFrameL_UIBP.CommCurrency02, false)
	self.PlayStyleCommFrameL_UIBP:MoneySlot1UpdateView(19000501, false, nil, true)
	self.PlayStyleCommFrameL_UIBP:MoneySlot2UpdateView(19000004, false, nil, true)

end

function JumboCactpotHistorylotteryView:OnHide()

end

function JumboCactpotHistorylotteryView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.PlayStyleCommFrameL_UIBP.ButtonClose, self.OnButtonCloseClick)
end

function JumboCactpotHistorylotteryView:OnRegisterGameEvent()

end

function JumboCactpotHistorylotteryView:OnRegisterBinder()
    self:RegisterBinders(JumboCactpotVM, self.Binders)
end


function JumboCactpotHistorylotteryView:OnButtonCloseClick()
	self:Hide()
end

return JumboCactpotHistorylotteryView