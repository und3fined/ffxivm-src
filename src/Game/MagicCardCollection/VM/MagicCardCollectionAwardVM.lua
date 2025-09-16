---
---@author Carl
---DateTime: 2023-09-12 19:17:13
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")

local MagicCardAwardItemVM = require("Game/MagicCardCollection/VM/ItemVM/MagicCardAwardItemVM")
--local MagicCardCollectionMgr = require("Game/MagicCardCollection/MagicCardCollectionMgr")
local MagicCardCollectionDefine = require("Game/MagicCardCollection/MagicCardCollectionDefine")


---@class MagicCardCollectionAwardVM : UIViewModel
---@field CardGetWayList table @获取方式列表
---
---@field MagicCardName string @幻卡名字
---@field MagicCardID string @幻卡编号
---@field MagicCardIntroduction string @幻卡介绍
---@field MagicCardQuantity number @幻卡累计数量
---@field MagicCardBigIcon string @幻卡图片路径

local MagicCardCollectionAwardVM = LuaClass(UIViewModel)

function MagicCardCollectionAwardVM:Ctor()
    self.CardCollectAwardList = UIBindableList.New(MagicCardAwardItemVM)
    self.Progress = 0
    self.MaxCount = 0
    self.Percent = 0
end

function MagicCardCollectionAwardVM:OnInit()

end

function MagicCardCollectionAwardVM:OnShutdown()
    self.CardGetWayList:Clear()
end

---@type 刷新幻卡收集信息
function MagicCardCollectionAwardVM:UpdateCollectionInfo(Progress, MaxCount, AwardList)
    if Progress == nil or MaxCount == nil or AwardList == nil then
        return
    end

    self.Progress = Progress
    self.MaxCount = MaxCount
    self.MaxCountText = "/"..self.MaxCount
    if self.MaxCount > 0 then
        self.Percent = self.Progress / self.MaxCount
    end
    
    local AwardList = AwardList
    self.AwardInfoList = {}
    if AwardList then
        for _, Award in ipairs(AwardList) do
            local AwardInfo = {
                CollectTargetNum = Award.CollectNum,
                AwardID = Award.AwardID,
                AwardNum = Award.AwardNum,
                IsGetProgress = self.Progress >= Award.CollectNum and not Award.IsCollectedAward , -- 是否已达到奖励进度
                IsCollectedAward = Award.IsCollectedAward, -- 是否已领奖
            }
            table.insert(self.AwardInfoList, AwardInfo)
        end
    end
    
    self.CardCollectAwardList:UpdateByValues(self.AwardInfoList, nil)
end

---@type 更新领取状态
function MagicCardCollectionAwardVM:UpdateGetAwardState(AwardIndex)
    if self.AwardInfoList == nil or next(self.AwardInfoList) == nil then
        return
    end

    local SelectAward = self.AwardInfoList[AwardIndex]
    if SelectAward then
        SelectAward.IsCollectedAward = true
        SelectAward.IsGetProgress = false
    end

    local Item = self.CardCollectAwardList.Items[AwardIndex]
    if Item then
        Item:UpdateVM(SelectAward)
    end
end

return MagicCardCollectionAwardVM
