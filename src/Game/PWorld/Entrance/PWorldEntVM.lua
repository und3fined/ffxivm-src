local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PWorldEntTypeVM = require("Game/PWorld/Entrance/ItemVM/PWorldEntTypeVM")
local PWorldEntPVPVM = require("Game/PWorld/Entrance/ItemVM/PWorldEntPVPVM")
local PworldEntGoldSaucerVM = require("Game/PWorld/Entrance/ItemVM/PworldEntGoldSaucerVM")
local PworldEntMagicCardVM = require("Game/PWorld/Entrance/ItemVM/PworldEntMagicCardVM")
local PWorldSelectionItemVM = require("Game/PWorld/Entrance/ItemVM/PWorldSelectionItemVM")
local UIBindableList = require("UI/UIBindableList")
local ProtoCommon = require("Protocol/ProtoCommon")

local PolUtil = require("Game/PWorld/Entrance/Policy/PWorldEntPolUtil")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local PworldCfg = require("TableCfg/PworldCfg")
local ModuleOpenCfg = require("TableCfg/ModuleOpenCfg")
local MakeLSTRAttrKey = require("Common/StringTools").MakeLSTRAttrKey
local MakeLSTRDict = require("Common/StringTools").MakeLSTRDict

---@class PWorldEntVM: UIViewModel
local PWorldEntVM = LuaClass(UIViewModel)

local PWorldTypeDict = {
	[1] = {ID = 1},
	[2] = {ID = 2},
	[3] = {ID = 3},
	[4] = {ID = 4},
}

local PWorldGoldSaucerDict = 
{
	[1] = {ID = ProtoCommon.ScenePoolType.ScenePoolChocobo}, --陆行鸟
}

local PWorldPVPDict = {
    [1] = {ID = ProtoCommon.ScenePoolType.ScenePoolPVPCrystal}, -- 水晶冲突
}

local PWorldMenuType = {
	[1] = MakeLSTRDict({ID = 1, [MakeLSTRAttrKey("Name")] = 1320075, Data = PWorldTypeDict}, true),
	[2] = MakeLSTRDict({ID = 2, [MakeLSTRAttrKey("Name")] = 1320076, Data = PWorldGoldSaucerDict}, true),
    [3] = MakeLSTRDict({ID = 3, [MakeLSTRAttrKey("Name")] = 1320077, Data = PWorldPVPDict}, true),
}

function PWorldEntVM:Ctor()
    self.CurMenuIndex = 1
    self.PWorldTypes = UIBindableList.New(PWorldEntTypeVM)
    self.PVPTypes = UIBindableList.New(PWorldEntPVPVM)
    self.PworldEntChocoboTypeVM = PworldEntGoldSaucerVM.New()
    self.PworldEntMagicCardTypeVM = PworldEntMagicCardVM.New()
    self.MatchSelectionVisibility = _G.UE.ESlateVisibility.Visible
    self.MatchSelectionTypes = UIBindableList.New(PWorldSelectionItemVM)
    self.bUnlockTeach = false
    self.TextTeach = ""

    self.ChineseTabVisibility = true
    self.OtherTabVisibility = false
end

function PWorldEntVM:IsShowNomalTab()
    local CommonUtil = require("Utils/CommonUtil")
	local CurCultureName = CommonUtil.GetCurrentCultureName()
	if CurCultureName and CurCultureName == "zh" then
        return true
    else
        return false
    end
end

function PWorldEntVM:InitSelectTabView()
    self.ChineseTabVisibility = self:IsShowNomalTab()
    self.OtherTabVisibility = not self.ChineseTabVisibility
end

function PWorldEntVM:UpdMatch()
    local Items = self.PWorldTypes:GetItems()
    for _, Item in pairs(Items) do
        Item:UpdMatch()
    end

    Items = self.PVPTypes:GetItems()
    for _, Item in pairs(Items) do
        Item:UpdMatch()
    end
    
    self.PworldEntChocoboTypeVM:UpdMatch()
end

function PWorldEntVM:UpdPWorldTypes()
    self.CurMenuIndex = 1
    self.PWorldTypes:UpdateByValues(PWorldTypeDict)
    self.PVPTypes:UpdateByValues(PWorldPVPDict)
    self.PworldEntChocoboTypeVM:UpdateVM(PWorldGoldSaucerDict[1])
    self.PworldEntMagicCardTypeVM:UpdateVM()
    self.MatchSelectionTypes:UpdateByValues(PWorldMenuType)
    self:UpdateTeach()
end

function PWorldEntVM:GetPWorldMenuType()
    return PWorldMenuType
end

function PWorldEntVM:GetPworldEntChocoboTypeVM()
    return self.PworldEntChocoboTypeVM
end

function PWorldEntVM:GetPworldEntMagicCardTypeVM()
    return self.PworldEntMagicCardTypeVM
end

function PWorldEntVM:ChangePWorldEntranceMenu(Index)
    if Index == self.CurMenuIndex then
        return
    end

    self.CurMenuIndex = Index
end

function PWorldEntVM:FindItem(ID)
    return self.PWorldTypes:Find(function(Item)
        return Item.TypeID == ID
    end)
end

function PWorldEntVM:UpdateTeach()
    local Cfg = ModuleOpenCfg:FindCfg(string.format("ModuleID=%d", ProtoCommon.ModuleID.ModuleIDSpecialTrain))
    local bShowTeach = Cfg and #(Cfg.PreTask or {}) > 0
    for _, v in ipairs((Cfg or {}).PreTask or {}) do
        bShowTeach = bShowTeach and PolUtil.HasPreQuestFinish(v)
        if not bShowTeach then
           break 
        end
    end
    self.bUnlockTeach = bShowTeach

    local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
    self.TextTeach = ProtoEnumAlias.GetAlias(ProtoCommon.ModuleID, ProtoCommon.ModuleID.ModuleIDSpecialTrain)
end

return PWorldEntVM
