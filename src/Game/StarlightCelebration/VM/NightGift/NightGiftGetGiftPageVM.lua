local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local UIBindableList = require("UI/UIBindableList")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local NightGetGiftSlotVM = require("Game/StarlightCelebration/VM/NightGift/NightGetGiftSlotVM")
local OpsStarlightDefine = require("Game/StarlightCelebration/OpsStarlightDefine")
local ItemUtil = require("Utils/ItemUtil")
local LSTR = _G.LSTR
---@class NightGiftGetGiftPageVM : UIViewModel
local NightGiftGetGiftPageVM = LuaClass(UIViewModel)

---Ctor
function NightGiftGetGiftPageVM:Ctor()
	self.BlessingText = nil
	self.NightGiftItemVMList = UIBindableList.New(NightGetGiftSlotVM)
end

function NightGiftGetGiftPageVM:UpdateGetPageInfo()
    local Activity = _G.OpsSeasonActivityMgr:GetSeasonActivity()
    if Activity then
        local GetGiftNodeList = _G.OpsActivityMgr:GetNodesByNodeType(Activity.ActivityID, ActivityNodeType.ActivityNodeTypeStarDayGetGift)
        if GetGiftNodeList and #GetGiftNodeList > 0 then
            self.GetGiftNode = GetGiftNodeList[1]
            local StarGift = self.GetGiftNode.Extra.StarGift or {}
            local GetGiftNum = StarGift.Gifts and #StarGift.Gifts or 0
            if GetGiftNum > 0 then
                self.BlessingText = OpsStarlightDefine.GiftBlessingText[StarGift.Gifts[GetGiftNum].Message]
                local ItemList = {}
                for _, Value in ipairs(StarGift.Gifts[GetGiftNum].Items) do
                    local GiftItem = ItemUtil.CreateItem(Value.ResID, Value.Num)
                    table.insert(ItemList, {Item = GiftItem})
                end

                for _, Value in ipairs(StarGift.Gifts[GetGiftNum].SystemItems) do
                    local GiftItem = ItemUtil.CreateItem(Value.ResID, Value.Num)
                    table.insert(ItemList, {SystemItem = GiftItem})
                end
                self.NightGiftItemVMList:UpdateByValues(ItemList)

            end
        end
    end
end


--要返回当前类
return NightGiftGetGiftPageVM