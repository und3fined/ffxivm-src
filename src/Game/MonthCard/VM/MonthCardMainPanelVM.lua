--
-- Author: ZhengJanChuan
-- Date: 2023-11-16 16:09
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ItemVM = require("Game/Item/ItemVM")
local MonthCardItemSlotVM = require("Game/MonthCard/VM/MonthCardItemSlotVM")
local MonthcardGlobalCfg = require("TableCfg/MonthcardGlobalCfg")
local LocalizationUtil = require("Utils/LocalizationUtil")
local UIBindableList = require("UI/UIBindableList")

local MonthCardMgr

local LSTR
local TimeUtil
local FLOG_INFO
local Global_ID = ProtoRes.global_cfg_id

local AlterNum = 3

---@class MonthCardMainPanelVM : UIViewModel
local MonthCardMainPanelVM = LuaClass(UIViewModel)

---Ctor
function MonthCardMainPanelVM:Ctor()
	self.MonthCardAwardNum = ""
	self.MonthCardMaxAddupTxt = ""
	self.PlayerAddedupNum = ""
	self.MonthCardRemainDays = ""
	self.TotalTips = ""
	self.PlayerAddedupVisible = false
	self.MonthCardVaildVisible = false
	self.BtnDailyGiftVisible = false
	self.GainItemVM = ItemVM.New()
	self.DailyRewardList = UIBindableList.New(ItemVM, {IsShowSelectStatus = false})

	self.PaytTax = ""
	self.Exp = ""
	self.StallNum = ""
	self.MountSpeed = ""
	self.MaxTips = ""

	self.TotalValue = ""

	MonthCardMgr = _G.MonthCardMgr
	LSTR = _G.LSTR
	TimeUtil = _G.TimeUtil
	FLOG_INFO = _G.FLOG_INFO
end

function MonthCardMainPanelVM:OnInit()
end

function MonthCardMainPanelVM:OnBegin()
end

function MonthCardMainPanelVM:OnEnd()
end

function MonthCardMainPanelVM:OnShutdown()
end

function MonthCardMainPanelVM:UpdateBaseData()
	local CfgDailyReward = MonthcardGlobalCfg:FindCfgByKey(ProtoRes.MonthCardGlobalParamType.MonthCardGlobalDailyReward)
	local CfgMaxDay =  MonthcardGlobalCfg:FindCfgByKey(ProtoRes.MonthCardGlobalParamType.MonthCardGlobalDailyRewardMaxNum)
	local CfgReward = MonthcardGlobalCfg:FindCfgByKey(ProtoRes.MonthCardGlobalParamType.MonthCardGlobalExtendReward)
	local CfgVaildTime = MonthcardGlobalCfg:FindCfgByKey(ProtoRes.MonthCardGlobalParamType.MonthCardGlobalValidTime)
	
	local VaildDay = CfgVaildTime.Value[1] or 30
	local AccumulateMaxDay = CfgMaxDay.Value[1]
	local GainCrystalNum = CfgReward.Value[2]
	local CrystalID =  CfgReward.Value[1]
	local DailyReward1Num = CfgDailyReward.Value[2] or 0

	local DailyRewardList = {}
	for i = 1, #CfgDailyReward.Value, 2 do
		if CfgDailyReward.Value[i+1] then
			local itemId = CfgDailyReward.Value[i] or 0
			local itemCount = CfgDailyReward.Value[i+1] or 0
			
			table.insert(DailyRewardList, {
				ID = itemId,
				Num = itemCount
			})
		end
	end

	local CfgPayTax = MonthcardGlobalCfg:FindCfgByKey(ProtoRes.MonthCardGlobalParamType.MonthCardGlobalTradeTaxShow)
	local CfgExp = MonthcardGlobalCfg:FindCfgByKey(ProtoRes.MonthCardGlobalParamType.MonthCardGlobalBonusStatusExpAdd)
	local CfgStallNum = MonthcardGlobalCfg:FindCfgByKey(ProtoRes.MonthCardGlobalParamType.MonthCardGlobalAddTradeStallShow)
	local CfgMountSpeed = MonthcardGlobalCfg:FindCfgByKey(ProtoRes.MonthCardGlobalParamType.MonthCardGlobalBonusStatusMountSpeedAdd)

	local PaytTax = CfgPayTax and CfgPayTax.Value[1] or 0
	local Exp = CfgExp and CfgExp.Value[1] or 0
	local StallNum = CfgStallNum and CfgStallNum.Value[1] or 0
	local MountSpeed = CfgMountSpeed and CfgMountSpeed.Value[1] or 0

	self.PaytTax = string.format("-%d%s", PaytTax, "%")
	self.Exp = string.format("+%d%s", Exp, "%")
	self.StallNum =  string.format("+%d", StallNum)
	self.MountSpeed =  string.format("+%d%s", MountSpeed, "%")

	local TotalNum = GainCrystalNum + VaildDay * DailyReward1Num
	self.TotalValue = string.format("x%s", string.formatint(TotalNum))

	local TempStr = ""
	for index, v in ipairs(DailyRewardList) do
		if index == 1 then
			TempStr = string.format("%s×%s +", RichTextUtil.GetTexture(UIUtil.GetIconPath(ItemUtil.GetItemIcon(v.ID)), 40, 40, -10),string.formatint(TotalNum))
		else
			local Num = v.Num or 0
			TempStr = string.format("%s%s×%s +", TempStr, RichTextUtil.GetTexture(UIUtil.GetIconPath(ItemUtil.GetItemIcon(v.ID)), 40, 40, -10), string.formatint(Num * VaildDay))
		end
	end
	self.TotalTips = string.format(LSTR(840005), TempStr, tostring(VaildDay))
	
	--  购买立得
	self.MonthCardAwardNum = string.format("x%s", string.formatint(GainCrystalNum))
	-- -- 最大累计天数提示
	self.MaxTips = string.format(LSTR(840006), AccumulateMaxDay)

	local GainItem = ItemUtil.CreateItem(CrystalID, 0)

	self.DailyRewardList:Clear()

	local TempList = {}
	for _, v in ipairs(DailyRewardList) do
		local Item = ItemUtil.CreateItem(v.ID, v.Num)
		Item.ItemNumVisible = false
		table.insert(TempList, Item)
	end

	self.DailyRewardList:UpdateByValues(TempList)

	self.GainItemVM:UpdateVM(GainItem , {IsShowNum = false})

end

function MonthCardMainPanelVM:UpdateSeverData()
	local DailyRewardNum = MonthCardMgr:GetDailyRewardNum()
	local MonthCardStatus = MonthCardMgr:GetMonthCardStatus()

	self.PlayerAddedupNum = string.format(LSTR(840007), DailyRewardNum)
	self.PlayerAddedupVisible = MonthCardStatus and DailyRewardNum > 1
	self.MonthCardVaildVisible = MonthCardStatus
	self.BtnDailyGiftVisible = MonthCardStatus

	if MonthCardStatus then
		local LocalTimeStamp = TimeUtil.GetServerLogicTime()
		local VaildTimeStamp = MonthCardMgr:GetMonthCardValidTime()
		local RemainTimeStamp = VaildTimeStamp - LocalTimeStamp
		local RemainDay = math.floor(RemainTimeStamp/86400) + 1
		local curNumRichText = ""
		local VaildText = RichTextUtil.GetText(string.format(LSTR(840008)), "#ffe8a9FF")
		local SecondsTime = RemainTimeStamp + 1
		local RemainTxt = LocalizationUtil.GetCountdownTimeForSimpleTime(SecondsTime, self:GetTimeFormat(SecondsTime))
		if RemainDay <= AlterNum then
			curNumRichText = RichTextUtil.GetText(string.format("%s", RemainTxt), "#DC5868FF")
			self.MonthCardRemainDays = string.format(LSTR(840009), VaildText, curNumRichText)
		else
			self.MonthCardRemainDays = string.format(LSTR(840009), VaildText, RemainTxt)
		end
	end

end

function MonthCardMainPanelVM:Refresh()
	self:UpdateBaseData()
	self:UpdateSeverData()
end

function MonthCardMainPanelVM:GetTimeFormat(SecondsTime)
	local days = SecondsTime / (24 * 3600)
    if days >= 1 then
        return "d"
    end
    
    local hours = SecondsTime / 3600
    if hours >= 1 then
        return "h"
    end
    
    local minutes = SecondsTime / 60
    if minutes >= 1 then
        return "m"
    end

    return "s"
end

--要返回当前类
return MonthCardMainPanelVM