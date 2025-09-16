---
--- Author: Administrator
--- DateTime: 2024-07-09 11:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local JumboCactpotVM = require("Game/JumboCactpot/JumboCactpotVM")
local JumboCactpotMgr = require("Game/JumboCactpot/JumboCactpotMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local AudioUtil = require("Utils/AudioUtil")
local LSTR = _G.LSTR
---@class JumboCactpotGetRewardNewWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGet UFButton
---@field ImgIcon UFImage
---@field PopUpBG CommonPopUpBGView
---@field TableViewList UTableView
---@field Text01 UFTextBlock
---@field TextFirstPrize UFTextBlock
---@field TextGet UFTextBlock
---@field TextNumber UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotGetRewardNewWinView = LuaClass(UIView, true)

function JumboCactpotGetRewardNewWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGet = nil
	--self.ImgIcon = nil
	--self.PopUpBG = nil
	--self.TableViewList = nil
	--self.Text01 = nil
	--self.TextFirstPrize = nil
	--self.TextGet = nil
	--self.TextNumber = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotGetRewardNewWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotGetRewardNewWinView:OnInit()
	self.GetRewardList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, true)

	self.Binders = {
		{ "GetRewardList", UIBinderUpdateBindableList.New(self, self.GetRewardList)},
	}
end

function JumboCactpotGetRewardNewWinView:OnDestroy()

end

function JumboCactpotGetRewardNewWinView:OnShow()
	self.Text01:SetText(LSTR(240096))
	self.TextGet:SetText(LSTR(240097))


	-- JumboCactpotMgr.bInOpenLotteryPro = false
	self.PopUpBG:SetHideOnClick(false)
	self.BtnGet:SetIsEnabled(true)

	local LevelResult = self.Params
	local AllRewardJDNum = 0
	local BestReward = 5
	JumboCactpotVM:UpdateList(JumboCactpotVM.GetRewardList, LevelResult)

	for _, v in pairs(LevelResult) do
		local Elem = v
		AllRewardJDNum = Elem.RewardNum + AllRewardJDNum
		if Elem.Level < BestReward then
			BestReward = Elem.Level
		end
	end

	AllRewardJDNum = UIBinderSetTextFormatForMoney:GetText(AllRewardJDNum)
	self.TextNumber:SetText(AllRewardJDNum)
	self:SetTitle(BestReward)
	self.TextFirstPrize:SetText(string.format(LSTR(240057), JumboCactpotMgr.WinNumber)) -- 一等奖号码:%s
	AudioUtil.LoadAndPlayUISound(JumboCactpotDefine.JumboUIAudioPath.GetReward)
end

function JumboCactpotGetRewardNewWinView:OnHide()

end

function JumboCactpotGetRewardNewWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGet, self.OnBtnGetClick)
end

function JumboCactpotGetRewardNewWinView:OnRegisterGameEvent()

end

function JumboCactpotGetRewardNewWinView:OnRegisterBinder()
	self:RegisterBinders(JumboCactpotVM, self.Binders)
end

--- @type 点击全部领取按钮
function JumboCactpotGetRewardNewWinView:OnBtnGetClick()
	-- TODO奖励兑换
	-- _G.NetworkStateMgr:TestReconnect()

	local MsgBody = {
        Cmd = ProtoCS.FairyColorGameCmd.ExchangeReward,
    }
    JumboCactpotMgr:OnSendNetMsg(MsgBody)
	self.BtnGet:SetIsEnabled(false)

	self:Hide()
	-- _G.UIViewMgr:HideView(_G.UIViewID.JumboCactpotPlate)
end


--- @type 设置标题
function JumboCactpotGetRewardNewWinView:SetTitle(BestReward)
	local NeedText = ""
	UIUtil.SetIsVisible(self.TextTitle, true)
	if BestReward == 1 then	-- 一等奖
		NeedText = (LSTR(240058)) -- 仙人结彩
	elseif BestReward == 2 then	-- 二等奖
		NeedText = LSTR(240038) -- "三针命中"
	elseif BestReward == 3 then	-- 三等奖
		NeedText = LSTR(240039) -- 两针命中
	elseif BestReward == 4 then	-- 四等奖
		NeedText = LSTR(240040) -- 一针命中
	elseif BestReward == 5 then	-- 五等奖
		NeedText = LSTR(240041)	-- 针针落空
		-- UIUtil.SetIsVisible(self.TextTitle, false)
	end
	self.TextTitle:SetText(NeedText)

end

return JumboCactpotGetRewardNewWinView