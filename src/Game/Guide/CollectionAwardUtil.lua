--
-- Author: carl
-- Date: 2024-4-24 15:49:02
-- Description:
--

local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")

local FLOG_ERROR = _G.FLOG_ERROR
local LSTR = _G.LSTR

---@class CollectionAwardUtil
local CollectionAwardUtil = {

}

---@type 显示收集进度奖励界面
---@param ViewID number UIViewID 图鉴ViewID,用于展示不同的动效
---@param CollectedNum number 已收集数量
---@param MaxCollectNum number 最大收集数
---@param AwardList number 奖励列表{@CollectNum --达成此奖励所需数量，AwardID --奖励ID，AwardNum -- 奖励数量，IsCollectedAward -- 是否已领奖 } 
---@param OnGetAwardCallBack table 点击领取奖励事件回调
---@param AreaName string 区域名字，没有就不填
function CollectionAwardUtil.ShowCollectionAwardView(ViewID, CollectedNum, MaxCollectNum, AwardList, OnGetAwardCallBack, AreaName)
	local Params = {
		ModuleID = ViewID,
		CollectedNum = CollectedNum,
		MaxCollectNum = MaxCollectNum,
		AreaName = AreaName,
		OnGetAwardCallBack = OnGetAwardCallBack,
	}

	local AwardInfoList = {}
	if AwardList and #AwardList > 0 then
		for _, Award in ipairs(AwardList) do
            local AwardInfo = {
                CollectTargetNum = Award.CollectNum,
                AwardID = Award.AwardID,
                AwardNum = Award.AwardNum,
                IsGetProgress = CollectedNum >= Award.CollectNum and not Award.IsCollectedAward , -- 是否已达到奖励进度
                IsCollectedAward = Award.IsCollectedAward, -- 是否已领奖
            }
            table.insert(AwardInfoList, AwardInfo)
        end
	end
	Params.AwardList = AwardInfoList

    UIViewMgr:ShowView(UIViewID.CollectionAwardPanel, Params)
end


return CollectionAwardUtil