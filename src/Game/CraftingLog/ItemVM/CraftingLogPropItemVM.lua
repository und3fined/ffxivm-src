local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local CraftingLogMgr = require("Game/CraftingLog/CraftingLogMgr")
local CraftingLogDefine = require("Game/CraftingLog/CraftingLogDefine")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemUtil = require("Utils/ItemUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local UIUtil = require("Utils/UIUtil")
local LSTR = _G.LSTR


---@class CraftingLogPropItemVM : UIViewModel
local CraftingLogPropItemVM = LuaClass(UIViewModel)
---Ctor
---@field Icon string @头部组件
---@field bImgDoneShow boolean @是否制作过
---@field PropName string @装备名称
---@field PropLevel string @装备等级
---@field bCraftStar1Show boolean @星星1
---@field bCraftStar2Show boolean @星星2
---@field bCraftStar3Show boolean @星星3
---@field bCraftStar4Show boolean @星星4
---@field bCraftStar5Show boolean @星星5
---@field bIsAFStarTrue boolean @是否收藏
---@field bImgCollectShow boolean @收藏显示
---@field bImgDifficultyShow boolean @高难度配方
function CraftingLogPropItemVM:Ctor()
    self:Reset()
end

function CraftingLogPropItemVM:Reset()
    self.bSelect = false
    self.ID = 0
    self.Icon = ""
    self.bImgDoneShow = false
    self.PropName = ""
    self.PropLevel = ""
    self.RecipeLevel = 0
    self.Craftjob = 0
    self.bCraftStar1Show = false
    self.bCraftStar2Show = false
    self.bCraftStar3Show = false
    self.bCraftStar4Show = false
    self.bCraftStar5Show = false
    self.bIsAFStarTrue = false
    self.bImgAFFalse = false
    self.bImgCollectShow = false
    self.bImgDifficultyShow = false
    self.ItemQualityImg = nil
    self.bLockGray = false
    self.CategoryNum = 0
    self.bLeveQuestMarked = false
end

function CraftingLogPropItemVM:OnShutdown()
    self:Reset()
end

function CraftingLogPropItemVM:UpdateVM(Params)
    if nil == Params then
        return
    end

    self.CategoryNum = Params.CategoryNum
    self.bLockGray = Params.bLockGray ~= nil and Params.bLockGray or self:SetLockState(Params)
    self.bSelect = Params.bSelect
    self.bLeveQuestMarked = Params.bLeveQuestMarked
    self.ID = Params.ID

    local IsFast = false
    if Params.FastCraft ~= nil and Params.FastCraft == 1 and CraftingLogMgr:GetIsDone(Params) then
        local AttrWorkPrecision = _G.UE.UActorUtil.GetActorAttrValue(MajorUtil.GetMajorEntityID(),
            ProtoCommon.attr_type.attr_work_precision)
        local AttrProducePrecision = _G.UE.UActorUtil.GetActorAttrValue(MajorUtil.GetMajorEntityID(),
            ProtoCommon.attr_type.attr_produce_precision)
        if AttrWorkPrecision >= Params.HQFastCraftmanShipNeed and AttrProducePrecision >= Params.HQFastCraftControlNeed then
            IsFast = true
        end
    end
    local ProductID = IsFast and Params.HQProductID or Params.ProductID
    self.PropName = ItemCfg:GetItemName(ProductID)
    self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(ProductID))
    self.ItemQualityImg = ItemUtil.GetSlotColorIcon(ProductID, ItemDefine.ItemSlotType.Item96Slot)

    local PropStarShow = CraftingLogDefine.PropStarShow
    self.Craftjob = Params.Craftjob
    self.RecipeLevel = Params.RecipeLevel
    self.PropLevel = string.format("%s%s", Params.RecipeLevel, LSTR(70022))
    local PropRecipeStar = Params.RecipeStar
    local PropRecipeType = Params.RecipeType
    if PropRecipeStar then
        self.bCraftStar1Show = PropStarShow.Star1 <= PropRecipeStar
        self.bCraftStar2Show = PropStarShow.Star2 <= PropRecipeStar
        self.bCraftStar3Show = PropStarShow.Star3 <= PropRecipeStar
        self.bCraftStar4Show = PropStarShow.Star4 <= PropRecipeStar
        self.bCraftStar5Show = PropStarShow.Star5 <= PropRecipeStar
    end
    local PropItemID = Params.ID
    local CollectData = CraftingLogMgr.CollectListData[Params.Craftjob]
    self.bIsAFStarTrue = CollectData and CollectData[PropItemID] or false
    self.ItemData = Params
    self.bImgDifficultyShow = Params.RecipeDifficulty == CraftingLogDefine.ExplainType.Grandmini

    local CollectIndex = ProtoRes.RecipeType.RecipeTypeCollection
    self.bImgCollectShow = CollectIndex == PropRecipeType

    self:SetImgDoneShow()
end

function CraftingLogPropItemVM:SetLockState(Value)
    local ProfbLock = CraftingLogMgr:GetProfIsLock(Value.Craftjob)
    local MajorLevel = MajorUtil.GetMajorLevelByProf(Value.Craftjob)
    return ProfbLock or (MajorLevel + 10) <= Value.RecipeLevel
end

--- 设置返回的索引：0
function CraftingLogPropItemVM:AdapterOnGetWidgetIndex()
    return 1
end

function CraftingLogPropItemVM:IsEqualVM(Value)
    return true
end

function CraftingLogPropItemVM:SetImgDoneShow()
    local RecipeData = self.ItemData
    local ProfHistoryList = CraftingLogMgr.HistoryList[RecipeData.Craftjob]
    if not ProfHistoryList then
        self.bImgDoneShow = false
        return
    end
    self.bImgDoneShow = ProfHistoryList[RecipeData.ID] and true or false
end

function CraftingLogPropItemVM:SetCollectShow()
    local RecipeData = self.ItemData
    if RecipeData ~= nil then
        local ProfCollectList = CraftingLogMgr.CollectListData[RecipeData.Craftjob]
        self.bIsAFStarTrue = ProfCollectList and ProfCollectList[RecipeData.ID] or false
    end
end

function CraftingLogPropItemVM:AdapterGetCategory()
	if self.ItemData == nil then
		return nil
	end
	local ChildTypeFilter = nil
	if CraftingLogMgr.CraftingState == CraftingLogDefine.CraftingLogState.Searching then
		local Craftjob = self.ItemData.Craftjob
        local ProfInfo = RoleInitCfg:FindCfgByKey(Craftjob)
        ChildTypeFilter = ProfInfo.ProfName
	elseif  CraftingLogMgr.LastHorTabIndex == CraftingLogDefine.FilterALLType.Career then
        local RecipeLable = self.ItemData.RecipeLable
        if RecipeLable and RecipeLable[3] then
            ChildTypeFilter = RecipeLable[3]
        end
	end
	return ChildTypeFilter
end

return CraftingLogPropItemVM
