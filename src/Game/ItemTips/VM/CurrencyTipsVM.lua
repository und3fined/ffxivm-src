local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ItemUtil = require("Utils/ItemUtil")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local ProtoRes = require("Protocol/ProtoRes")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local LevelExpCfg = require("TableCfg/LevelExpCfg")
local MajorUtil = require("Utils/MajorUtil")

local CurrencyTipsVM = LuaClass(UIViewModel)

function CurrencyTipsVM:Ctor()
	self.TypeName = nil
	self.ItemName = nil
	self.IconID = nil

    self.IntroText = nil
    self.OwnRichText = nil
    self.ToGetVisible = nil
    self.ResID = nil
end

---UpdateVM
function CurrencyTipsVM:UpdateVM(ScoreID)
    local ItemResID = ScoreID
    self.ResID = ItemResID
    local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if nil == Cfg then
		return
	end

    local CfgItemType = Cfg.ItemType
	self.TypeName = ItemTypeCfg:GetTypeName(CfgItemType)
	self.IconID = Cfg.IconID
	self.ItemName = ItemCfg:GetItemName(ItemResID)
    self.IntroText = ItemCfg:GetItemDesc(ItemResID)


    if ItemResID == SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP then
        local LevelCfg = LevelExpCfg:FindCfgByKey(MajorUtil.GetMajorLevel())
        if LevelCfg == nil then
            self.OwnRichText = _G.LSTR(1020003)
        else
            self.OwnRichText = UIBinderSetTextFormatForMoney:GetText(ScoreMgr:GetScoreValueByID(ItemResID))
        end
    else
        self.OwnRichText = UIBinderSetTextFormatForMoney:GetText(ScoreMgr:GetScoreValueByID(ItemResID))
    end
    

    local CommGetWayItems = ItemUtil.GetItemGetWayList(ScoreID)

    if CommGetWayItems ~= nil and #CommGetWayItems > 0 then
        self.ToGetVisible = true
    else
        self.ToGetVisible = false
    end
end

return CurrencyTipsVM