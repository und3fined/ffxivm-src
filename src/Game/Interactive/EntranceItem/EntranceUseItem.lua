local LuaClass = require("Core/LuaClass")
local EntranceBase = require("Game/Interactive/EntranceItem/EntranceBase")
local ActorUtil = require("Utils/ActorUtil")
local BagMgr = require("Game/Bag/BagMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local UIUtil = require("Utils/UIUtil")
local QuestHelper = require("Game/Quest/QuestHelper")

local LSTR = _G.LSTR

local EntranceUseItem = LuaClass(EntranceBase)

function EntranceUseItem:Ctor()
    self.TargetType = _G.LuaEntranceType.UseItem
end

function EntranceUseItem:OnInit()
end

function EntranceUseItem:UpdateEntrance(Params)
    --self.DefaultTurn = false

    if (not Params) or (not Params.ViewParams) then return end
    self.ViewParams = Params.ViewParams
	self.CurrItemData = Params.ViewParams.CurrItemData
    if not self.CurrItemData then return end

    self:Init(Params)

    if self.EntityID == nil then return end
    local Actor = ActorUtil.GetActorByEntityID(self.EntityID)
    if Actor == nil then return end
    local AttrComp = Actor:GetAttributeComponent()
    if AttrComp == nil then return end
	local Cfg = ItemCfg:FindCfgByKey(self.CurrItemData.ResID)
    if Cfg == nil then return end

	if not string.isnilorempty(Cfg.CustomText) and Cfg.CustomText ~= 0 and Cfg.CustomText ~= "0" then
		self.DisplayName = Cfg.CustomText
    else
        self.DisplayName = string.format(LSTR(90015), ActorUtil.GetActorName(self.EntityID), ItemCfg:GetItemName(self.CurrItemData.ResID))
	end

    self.IconPath = UIUtil.GetIconPath(Cfg.IconID)

    if not self.Distance or self.Distance <= 0 then
        self.Distance = Actor:GetDistanceToMajor()
    end

    self.FunctionItemsList = {}
end

function EntranceUseItem:OnUpdateDistance()
    if self.EntityID > 0 then
        local Actor = ActorUtil.GetActorByEntityID(self.EntityID)

        if Actor then
            self.Distance = Actor:GetDistanceToMajor()
        else
            self.EntityID = 0
        end
    end
end

function EntranceUseItem:CheckBeforeClick()
    if not self.CurrItemData then
        return true
    end
    local ItemID = self.CurrItemData.ResID
    local QuestParamsList = _G.QuestMgr:GetEObjQuestParamsList(self.ResID)
    if #QuestParamsList == 0 then
        return true
    end
    for _, QuestParam in ipairs(QuestParamsList) do
        if QuestHelper.CheckIsUseItemTarget(QuestParam.QuestID, QuestParam.TargetID, ItemID) then
            if not QuestHelper.CheckLootItems(QuestParam.QuestID, QuestParam.TargetID) then
                QuestHelper.PlayRestrictedDialog(QuestParam.QuestID, QuestParam.TargetID)
                return false
            end
        end
    end
    return true
end

function EntranceUseItem:OnClick()
	local Params = self.ViewParams
	if Params == nil then return end
	local CurrItemData = Params.CurrItemData
	if CurrItemData == nil then return end

    if not self:CheckBeforeClick() then
        return
    end

	local ItemParams = {
		TargetEntityID = Params.TargetEntityID,
		LimitValue = Params.LimitValue,
		SkillParams = nil,
	}

	BagMgr:UseItem(CurrItemData.GID, ItemParams)
end

function EntranceUseItem:OnGenFunctionList()
    return {}
end

function EntranceUseItem:CheckInterative(EnableCheckLog)
    return true
end

function EntranceUseItem:IsNeedShowArmyExchangeEntrance()
    return false
end

function EntranceUseItem:GenInteractiveQuestEntranceItems(_)
    return {}
end

function EntranceUseItem:HasFunctionItems()
    return false
end

return EntranceUseItem
