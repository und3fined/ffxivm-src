---
--- Author: Leo
--- DateTime: 2023-9-21 10:
--- Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")

local LSTR = _G.LSTR
---@class JumboCactpotGetRewardItemVM : UIViewModel

local JumboCactpotGetRewardItemVM = LuaClass(UIViewModel)

function JumboCactpotGetRewardItemVM:Ctor()
    self.Level = ""
    self.Number = ""
    self.RichNumber = ""
    self.RewardNum = ""
    self.Rewards = ""
    self.bShowItemReward = false
    -- self.bPanel1Show = false
    -- self.bPanel2Show = false
    -- self.bPanel3Show = false
    -- self.bPanel4Show = false
    -- self.bPanel5Show = false
    self.bNumVisible = true
    self.ItemIcon = ""
    self.ItemCount = 0
    self.JDIcon = ""
    self.ImgBGPath = ""
    self.TextDescribe = ""
end

function JumboCactpotGetRewardItemVM:IsEqualVM()
    return true
end

function JumboCactpotGetRewardItemVM:UpdateVM(Value)
    local Level = Value.Level
    local PreContet, BgImgPath, Desc
    local GetWardItemBgPath = JumboCactpotDefine.GetWardItemBgPath
	if Level == 1 then
        BgImgPath = GetWardItemBgPath.First 
		PreContet = LSTR(240024) -- 一
        Desc = LSTR(240037) -- 针无虚发
	elseif Level == 2 then
        BgImgPath = GetWardItemBgPath.Second
		PreContet = LSTR(240028) -- 二
        Desc = LSTR(240038) -- 三针命中
	elseif Level == 3 then
        BgImgPath = GetWardItemBgPath.Third
		PreContet = LSTR(240027) -- 三
        Desc = LSTR(240039) -- 二针命中

	elseif Level == 4 then
        BgImgPath = GetWardItemBgPath.Four
		PreContet = LSTR(240026) -- 四
        Desc = LSTR(240040) -- 一针命中

	elseif Level == 5 then
        BgImgPath = GetWardItemBgPath.Fifth
		PreContet = LSTR(240025) -- 五
        Desc = LSTR(240041) -- 针针落空
	end
    self.TextDescribe = Desc

    self.Level = string.format(LSTR(240042), PreContet) -- %s等奖
    self.ImgBGPath = BgImgPath

    self.Number = Value.Number
    self.RichNumber = Value.RichNumber
    self.RewardNum =  Value.RewardNum
    self.Rewards = Value.Rewards
    -- self.bPanel1Show = Level == 1
    -- self.bPanel2Show = Level == 2
    -- self.bPanel3Show = Level == 3
    -- self.bPanel4Show = Level == 4
    -- self.bPanel5Show = Level == 5 50010940
    local JDCoinID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE
    local JDCfg = ItemCfg:FindCfgByKey(JDCoinID)
    local JDIconID = JDCfg.IconID
    self.JDIcon = ItemCfg.GetIconPath(JDIconID)
    self.bShowItemReward = #Value.Rewards ~= 0
    if self.bShowItemReward then
        self.ItemCount = Value.Rewards[1].Count

        local ResID = Value.Rewards[1].ResID
        self.ItemResID = ResID
        local Cfg = ItemCfg:FindCfgByKey(ResID)
        if Cfg ~= nil then
            local IconID = Cfg.IconID
		    self.ItemIcon = ItemCfg.GetIconPath(IconID)
        else
            FLOG_ERROR("ItemCfg = nil, ID = %s", ResID)
        end
    end
end

return JumboCactpotGetRewardItemVM