---
--- Author: zerodeng
--- DateTime: 2025-05-29 10:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local LocalizationUtil = require("Utils/LocalizationUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local AdventureMgr = require("Game/Adventure/AdventureMgr")
local AdventureDailyWeeklyVM = require("Game/Adventure/AdventureDailyWeeklyVM")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
--local BaseView = require("Game/Adventure/View/AdventureChildPageBaseView")

local challenge_log_type = ProtoRes.challenge_log_type

---@class WorldExploraAdventureWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field RichTextCycle URichTextBox
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraAdventureWinView = LuaClass(UIView, true)

function WorldExploraAdventureWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.RichTextCycle = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraAdventureWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end


local CreatCount = 10
local FilterChallengeTypes = {	--过滤挑战日志类型
	challenge_log_type.CHALLENGE_LOG_TYPE_FATE_HIGHEST_RATE,	--危命任务最高评价	
	challenge_log_type.CHALLENGE_LOG_TYPE_GATHER,				--采集活动
	challenge_log_type.CHALLENGE_LOG_TYPE_GATHER_HQ,			--优质采集
	challenge_log_type.CHALLENGE_LOG_TYPE_FISH,					--钓鱼
	challenge_log_type.CHALLENGE_LOG_TYPE_FISH_HQ,				--优质钓鱼
	challenge_log_type.CHALLENGE_LOG_TYPE_SPEARFISH, 			--刺鱼
	challenge_log_type.CHALLENGE_LOG_TYPE_SPEARFISH_HQ, 		--优质刺鱼
	challenge_log_type.CHALLENGE_LOG_TYPE_TIMEWORN_MAPS, 		--藏宝图采集
	challenge_log_type.CHALLENGE_LOG_TYPE_TREASURE_COFFER, 		--打开宝箱
	challenge_log_type.CHALLENGE_LOG_TYPE_TREASURY, 			--打开宝物库宝箱
	challenge_log_type.CHALLENGE_LOG_TYPE_FATE_GET_REWARD, 		--危命任务获得奖励
	challenge_log_type.CHALLENGE_LOG_TYPE_FISH_LARGE_SIZE, 		--大尺寸钓鱼
}


function WorldExploraAdventureWinView:OnInit()
	self.AdapterNoteList = UIAdapterTableView.CreateAdapter(self, self.TableViewList)

	--创建VM
	self.VM = AdventureDailyWeeklyVM.New()

	self.BG:SetTitleText(LSTR(1610030))

	self.CreatSucess = false
end


function WorldExploraAdventureWinView:OnShow()
	--请求所有挑战笔记数据
	AdventureMgr:SendChallengeLog(0)
	self:SetTheSurplusEndTime()
	self:SetSurplusTimeText()	
end


function WorldExploraAdventureWinView:SetTheSurplusEndTime()
	self.SurplusTime = AdventureMgr:GetWeeklyRefreshSurplusTime()
end

function WorldExploraAdventureWinView:SetSurplusTimeText()
	local TimeString = LocalizationUtil.GetCountdownTimeForLongTime(self.SurplusTime)
	local Text = string.format(LSTR(350022), TimeString)
	self.RichTextCycle:SetText(Text)
end


function WorldExploraAdventureWinView:OnHide()
	self.CreatSucess = false
    self:UnRegisterAllTimer()
	if self.VM then
		self.VM:ClearItemList()
	end
end


function WorldExploraAdventureWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.GetChallengeLogInfo, self.OnUpdateChallengeLogs)
	self:RegisterGameEvent(EventID.GetChallengeLogCollect, self.OnUpdateCollectLogs)
end

function WorldExploraAdventureWinView:OnRegisterBinder()
	local Binders = {
		{"ItemList", UIBinderUpdateBindableList.New(self, self.AdapterNoteList)},
	}
	self:RegisterBinders(self.VM, Binders)
end

function WorldExploraAdventureWinView:OnUpdateChallengeLogs()
	--收到挑战笔记数据回包
	local ItemListData = self.VM:GetWeeklyListData()

	local FilterItemListData = {}

	--筛选野外类型
	for _, Value in ipairs(ItemListData) do
		local ChallengeType = Value.ChallengeType
		if (table.contain(FilterChallengeTypes, ChallengeType)) then
			table.insert(FilterItemListData, Value)
		end
	end


	if self.CreatSucess then
		self.VM:SetItemListData(FilterItemListData)
	else
		self:CreatItemList(FilterItemListData)
	end	

	--开始更新时间--放这里注册，CreatItemList中会调用UnRegisterAllTimer()
	self:RegisterTimer(self.OnUpdateTime, 0, 10, 0)
end

function WorldExploraAdventureWinView:OnUpdateCollectLogs(LogID)	
	self.VM:UpdateNoteItemCollected(LogID)
end

function WorldExploraAdventureWinView:OnUpdateTime()	
	self.SurplusTime = self.SurplusTime - 1
	
	if self.SurplusTime < 0 then
		self:SetTheSurplusEndTime()
		AdventureMgr:SendChallengeLog(0)		
	end	

	self:SetSurplusTimeText()
end

function WorldExploraAdventureWinView:CreatItemList(ItemListData)
	self.CreatSucess = false
	self:UnRegisterAllTimer()
    if not self.VM then
        FLOG_ERROR("AdventureChildPageBaseView ChildView Need Init VM")
        return
    end

    self.VM:ClearItemList()
    if #ItemListData > CreatCount then
		local Time = 1
		self:RegisterTimer(function()
			local Start = (Time - 1) * 5 > 0 and (Time - 1) * 5 + 1 or 1
			for i = Start, Time * CreatCount, 1 do
				if ItemListData[i] then
					self.VM:SetOneItemListData(ItemListData[i])
				else
					break
				end
			end

			Time = Time + 1
			if Time >= math.ceil(#ItemListData / CreatCount)then
				self.CreatSucess = true
			end
		end, 0, 0.1, math.ceil(#ItemListData / CreatCount))
	else
		self.VM:SetItemListData(ItemListData)
		self.CreatSucess = true
	end
end


return WorldExploraAdventureWinView