---
--- Author: sammrli
--- DateTime: 2023-05-16 18:54
--- Description:每周挑战完成奖励
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local math = require('math')
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local AdventureItemVM = require("Game/Adventure/ItemVM/AdventureItemVM")
local AdventureMgr = require("Game/Adventure/AdventureMgr")
local RichTextUtil = require("Utils/RichTextUtil")
local ChallengeLogRewardCfg = require("TableCfg/ChallengeLogRewardCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local AdventureDefine = require("Game/Adventure/AdventureDefine")

local TimerMgr = _G.TimerMgr
local LSTR = _G.LSTR

---@class AdventureCompletionWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field Node01 AdventureCompletionItemView
---@field Node02 AdventureCompletionItemView
---@field Node03 AdventureCompletionItemView
---@field Node04 AdventureCompletionItemView
---@field Node05 AdventureCompletionItemView
---@field ProBar UProgressBar
---@field RichTextCycle URichTextBox
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureCompletionWinView = LuaClass(UIView, true)

function AdventureCompletionWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.Node01 = nil
	--self.Node02 = nil
	--self.Node03 = nil
	--self.Node04 = nil
	--self.Node05 = nil
	--self.ProBar = nil
	--self.RichTextCycle = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.UpdateTimerID = nil
	self.SurplusTime = 0
end

function AdventureCompletionWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.Node01)
	self:AddSubView(self.Node02)
	self:AddSubView(self.Node03)
	self:AddSubView(self.Node04)
	self:AddSubView(self.Node05)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureCompletionWinView:OnInit()
	self.BG.HideOnClick = false
	self.AdapterItemList = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
end

function AdventureCompletionWinView:OnDestroy()

end

function AdventureCompletionWinView:OnShow()
	AdventureMgr:SendChallengelogReward()
	self:UpdateItems()
	self:InitSurplusTime()
	self.UpdateTimerID = TimerMgr:AddTimer(self, self.OnUpdateTime, 0, 1, 0)
	self.BG:SetTitleText(LSTR(520064))
end

function AdventureCompletionWinView:OnHide()
	if self.UpdateTimerID then
		TimerMgr:CancelTimer(self.UpdateTimerID)
		self.UpdateTimerID = nil
	end
end

function AdventureCompletionWinView:OnRegisterUIEvent()

end

function AdventureCompletionWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.GetChallengeLogRewardCollect, self.OnUpdateView)
	self:RegisterGameEvent(EventID.GetChallengeRewardCollect, self.OnUpdateView)
end

function AdventureCompletionWinView:OnRegisterBinder()

end

function AdventureCompletionWinView:UpdateItems()
	local ItemVMList = {}
	local FinishCount = AdventureMgr:GetFinishCount()
	local Cfgs = ChallengeLogRewardCfg:FindAllCfg()
	local Percent = 0
	local LastCount = 0
	if Cfgs then
		for K, V in ipairs(Cfgs) do
			local ItemVM = AdventureItemVM.New()
			local Count = (V.Count and V.Count or 0)
			local IsFinish = FinishCount >= Count
			local Collected = AdventureMgr:IsRewardCollected(V.Count)

			local ItemParam = {
				ID = K,
				OnClickGet = self.OnClickGetHandle,
				IsBtnGetVisible = IsFinish and not Collected,
				IsUnFinishVisible = not IsFinish or Collected,
				IsNewRedVisible = false,
				IsDescriptionVisible = true,
				DescriptionText = LSTR(520021),
				ContentText = V.Desc,
				BtnGetText = LSTR(520055),
				MainIconPath = V.Icon,
			}
			if not Collected then
				ItemParam.DescriptionText = string.format(LSTR(520025), string.format("%d/%d", math.min(FinishCount, Count), V.Count))
			end

			if Collected then
                ItemParam.UnFinishText = LSTR(520022)
            elseif not IsFinish then
                ItemParam.UnFinishText = LSTR(520036)
            end
			
			if IsFinish then
				Percent = Percent + 0.2
			else
				Percent = Percent + math.max(0, FinishCount - LastCount) / (Count - LastCount) * 0.2
			end

			LastCount = Count
			ItemVM:UpdateVM(ItemParam)
			local RewardData = {}
			local RewardItemList = AdventureMgr:GetLootItems(V.LootID)
			for i = 1, #RewardItemList do
				local Params = {}
                local Produce = RewardItemList and RewardItemList[i] or nil
                if Produce then
                    local Cfg = ItemCfg:FindCfgByKey(Produce.ResID)
                    if Cfg then
                        Params.IconPath = UIUtil.GetIconPath(Cfg.IconID)
                    end
					Params.ResID = Produce.ResID
                    Params.IsVisible = true
                    Params.NumText = _G.ScoreMgr.FormatScore(Produce.Num)
					Params.IsMaskVisible = Collected
                else
                    Params.IsVisible = false
                    Params.NumText = ""
					Params.IsMaskVisible = false
                end

				table.insert(RewardData, Params)
            end

			ItemVM:SetRewardData(RewardData)
			table.insert(ItemVMList, ItemVM)
			---@type AdventureCompletionItemView
			local NodeView = self[string.format("Node0%d", K)]
			if NodeView then
				NodeView:SetCount(V.Count)
				NodeView:SetGray(not IsFinish)
				NodeView:SetText(IsFinish and RichTextUtil.GetText(tostring(V.Count), "c3a572") or  RichTextUtil.GetText(tostring(V.Count), "828282FF"))
			end
		end
	end

	table.sort(ItemVMList, self.SortRewardLogPredicate)
	self.AdapterItemList:UpdateAll(ItemVMList)

	self.ProBar:SetPercent(Percent)
end

function AdventureCompletionWinView:InitSurplusTime()
	self.SurplusTime = AdventureMgr:GetWeeklyRefreshSurplusTime()
end

---排序 可领取>不可领取>已领取
function AdventureCompletionWinView.SortRewardLogPredicate(Left, Right)
    local LeftScore = Left.ID
    if Left.IsFinish then
        LeftScore = LeftScore + (Left.Collected and 10000 or -10000)
	else
		if Left.Collected then
            LeftScore = LeftScore + 10000
        end
    end
    local RightScore = Right.ID
    if Right.IsFinish then
        RightScore = RightScore + (Right.Collected and 10000 or -10000)
	else
		if Right.Collected then
            RightScore = RightScore + 10000
        end
    end
    return LeftScore < RightScore
end

function AdventureCompletionWinView:OnUpdateTime()
	self.SurplusTime = self.SurplusTime - 1
	if self.SurplusTime < 0 then
		self:InitSurplusTime()
	end

	local LocalizationUtil = require("Utils/LocalizationUtil")
	local Text = string.format(LSTR(520050), LocalizationUtil.GetCountdownTimeForLongTime(self.SurplusTime))
    self.RichTextCycle:SetText(Text)
end

function AdventureCompletionWinView:OnClickGetHandle(ID)
	local Cfgs = ChallengeLogRewardCfg:FindAllCfg()
	if Cfgs then
		local Cfg = Cfgs[ID]
		if Cfg then
			AdventureMgr:SendChallengeLogRewardCollect(Cfg.Count)
		end
	end
end

function AdventureCompletionWinView:OnUpdateView()
	self:UpdateItems()
end

return AdventureCompletionWinView