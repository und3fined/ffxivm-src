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
local JumboCactpotMgr = require("Game/JumboCactpot/JumboCactpotMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local LSTR = _G.LSTR
---@class JumboCactpotGetRewardWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGet UFButton
---@field ImgIcon UFImage
---@field No1 JumboCactpotGetItemView
---@field PopUpBG CommonPopUpBGView
---@field TableViewList UTableView
---@field TextGet UFTextBlock
---@field TextNumber UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotGetRewardWinView = LuaClass(UIView, true)

function JumboCactpotGetRewardWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGet = nil
	--self.ImgIcon = nil
	--self.No1 = nil
	--self.PopUpBG = nil
	--self.TableViewList = nil
	--self.TextGet = nil
	--self.TextNumber = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotGetRewardWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.No1)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotGetRewardWinView:OnInit()
	self.GetRewardList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, true)

	self.Binders = {
		{ "GetRewardList", UIBinderUpdateBindableList.New(self, self.GetRewardList)},
	}

end

function JumboCactpotGetRewardWinView:OnDestroy()

end

function JumboCactpotGetRewardWinView:OnShow()
	-- JumboCactpotMgr.bInOpenLotteryPro = false
	self.PopUpBG:SetHideOnClick(false)
	local LevelResult = self.Params
	local AllRewardJDNum = 0
	local BestReward = 5
	if #LevelResult > 1 then
		UIUtil.SetIsVisible(self.No1, false)
		UIUtil.SetIsVisible(self.TableViewList, true)

		JumboCactpotVM:UpdateList(JumboCactpotVM.GetRewardList, LevelResult)

		for _, v in pairs(LevelResult) do
			local Elem = v
			AllRewardJDNum = Elem.RewardNum + AllRewardJDNum
			if Elem.Level < BestReward then
				BestReward = Elem.Level
			end
		end

	elseif #LevelResult == 1 then
		self:UpdateSingleReward()
		AllRewardJDNum = LevelResult[1].RewardNum
		UIUtil.SetIsVisible(self.TableViewList, false)
		BestReward =  LevelResult[1].Level
	end

	self.TextNumber:SetText(AllRewardJDNum)

	self:SetTitle(BestReward)

	self.TextGet:SetText(LSTR(240076)) -- 领  取
	self.Text01:SetText(LSTR(240077)) -- 共计：
end

function JumboCactpotGetRewardWinView:OnHide()

end

function JumboCactpotGetRewardWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGet, self.OnBtnGetClick)
end

function JumboCactpotGetRewardWinView:OnRegisterGameEvent()

end

function JumboCactpotGetRewardWinView:OnRegisterBinder()
	self:RegisterBinders(JumboCactpotVM, self.Binders)
end

--- @type 只买了一发彩票单独加载单个奖励卡片
function JumboCactpotGetRewardWinView:UpdateSingleReward()
	local No1 = self.No1
	local LevelResult = self.Params
	local Level = LevelResult[1].Level
	local Rewards = LevelResult[1].Rewards
	UIUtil.SetIsVisible(No1, true)
	local PreContet
	if Level == 1 then
		PreContet = LSTR(240024) -- 一
	elseif Level == 2 then
		PreContet = LSTR(240028) -- 二
	elseif Level == 3 then
		PreContet = LSTR(240027) -- 三
	elseif Level == 4 then
		PreContet = LSTR(240026) -- 四
	elseif Level == 5 then
		PreContet = LSTR(240025) -- 五
	end
	local LevelContent = string.format(LSTR(240050), PreContet) -- "%s等奖"
	No1.TextTitle:SetText(LevelContent)
	No1.RichTextBoxNumber:SetText(LevelResult[1].RichNumber)
	UIUtil.SetIsVisible(No1.PanelReward01, #Rewards ~= 0)
	UIUtil.SetIsVisible(No1.Panel01, Level == 1)
	UIUtil.SetIsVisible(No1.Panel02, Level == 2)
	UIUtil.SetIsVisible(No1.Panel03, Level == 3)
	UIUtil.SetIsVisible(No1.Panel04, Level == 4)
	UIUtil.SetIsVisible(No1.Panel05, Level == 5)
	local Reward02 = No1.Reward02
	Reward02.RichTextNum:SetText(LevelResult[1].RewardNum)
	UIUtil.SetIsVisible(Reward02.RichTextNum, true)

	local JDCoinID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE
    local JDCfg = ItemCfg:FindCfgByKey(JDCoinID)
    local JDIconID = JDCfg.IconID
	local JDIcon = ItemCfg.GetIconPath(JDIconID)
	UIUtil.ImageSetBrushFromAssetPath(No1.Reward02.FImg_Icon, JDIcon)

	if UIUtil.IsVisible(No1.PanelReward01) then
		local Count = Rewards[1].Count
		No1.Reward01.RichTextNum:SetText(Count)
		UIUtil.SetIsVisible(No1.Reward01.RichTextNum, true)

		local ResID = Rewards[1].ResID
		local Cfg = ItemCfg:FindCfgByKey(ResID)
		local IconID = Cfg.IconID
		local IconPath = ItemCfg.GetIconPath(IconID)
		UIUtil.ImageSetBrushFromAssetPath(No1.Reward01.FImg_Icon, IconPath)
	end
end

--- @type 点击全部领取按钮
function JumboCactpotGetRewardWinView:OnBtnGetClick()
	-- TODO奖励兑换
	-- _G.NetworkStateMgr:TestReconnect()

	local MsgBody = {
        Cmd = ProtoCS.FairyColorGameCmd.ExchangeReward,
    }
    JumboCactpotMgr:OnSendNetMsg(MsgBody)
	self:Hide()
	-- _G.UIViewMgr:HideView(_G.UIViewID.JumboCactpotPlate)
end

--- @type 设置标题
function JumboCactpotGetRewardWinView:SetTitle(BestReward)
	local NeedText = ""
	UIUtil.SetIsVisible(self.TextTitle, true)
	if BestReward == 1 then	-- 一等奖
		NeedText = (LSTR(240058)) --- 仙人结彩
	elseif BestReward == 2 then	-- 二等奖
		NeedText = LSTR(240038) -- 三针命中
	elseif BestReward == 3 then	-- 三等奖
		NeedText = LSTR(240039) -- 两针命中
	elseif BestReward == 4 then	-- 四等奖
		NeedText = LSTR(240040) -- 一针命中
	elseif BestReward == 5 then	-- 五等奖
		NeedText = LSTR(240041) -- 针针落空
		-- UIUtil.SetIsVisible(self.TextTitle, false)
	end
	self.TextTitle:SetText(NeedText)

end

return JumboCactpotGetRewardWinView