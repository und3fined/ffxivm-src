local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local CrafterCulinarianElementItemVM = require("Game/Crafter/View/Culinarian/CrafterCulinarianElementItemVM")
local ProtoRes = require("Protocol/ProtoRes")
local culinary_element_type = ProtoRes.culinary_element_type

local CrafterConfig = require("Define/CrafterConfig")
local ProtoCommon = require("Protocol/ProtoCommon")
local CulinarianConfig = CrafterConfig.ProfConfig[ProtoCommon.prof_type.PROF_TYPE_CULINARIAN]
local MenphinaBuffID = CulinarianConfig.MenphinaBuffID

---@class CrafterCulinarianVM : UIViewModel
local CrafterCulinarianVM = LuaClass(UIViewModel)

local InitServerPoolElementCountList = {
    -- [culinary_element_type.CULINARY_ELEMENT_TYPE_EMPTY] = nil,
    [culinary_element_type.CULINARY_ELEMENT_TYPE_COLOR] = 0,
    [culinary_element_type.CULINARY_ELEMENT_TYPE_SWEET] = 0,
    [culinary_element_type.CULINARY_ELEMENT_TYPE_TASTE] = 0,
    [culinary_element_type.CULINARY_ELEMENT_TYPE_TEXTURE] = 0,
    [culinary_element_type.CULINARY_ELEMENT_TYPE_SMELL] = 0,
    -- [culinary_element_type.CULINARY_ELEMENT_TYPE_PHANTOM] = nil,
}

function CrafterCulinarianVM:RawSetBindableProperty(PropertyName, Value)
    local BindableProperty = self:FindBindableProperty(PropertyName)
    if BindableProperty then
        BindableProperty.Value = Value
    end
end

function CrafterCulinarianVM:ResetParams()
    -- 堆叠元素的数量
    self.PoolElementCountList = table.deepcopy(InitServerPoolElementCountList)

    -- 这里不能触发Changed函数, 否则会短暂闪现上回合的元素
    local ServerPoolElementCountList = table.deepcopy(InitServerPoolElementCountList)
    if self.ServerPoolElementCountList then
        self:RawSetBindableProperty("ServerPoolElementCountList", ServerPoolElementCountList)
    else
        self.ServerPoolElementCountList = ServerPoolElementCountList
    end
    

    self:SetNoCheckValueChange("bHasAfflatus", true)

    self.bIsAfflatusTriple = false
    self.bHasAfflatusFirstly = false
    self.bHasAfflatus = false
    self.bIsPanelSourceVisible = false
    self.bPanelInspireStormVisible = false
    self.AfflatusLockIndex = -1
end

function CrafterCulinarianVM:Ctor()
    self.ColorElementList = UIBindableList.New(CrafterCulinarianElementItemVM)
    self.AromaElementList = UIBindableList.New(CrafterCulinarianElementItemVM)
    self.TasteElementList = UIBindableList.New(CrafterCulinarianElementItemVM)
    self.QualityElementList = UIBindableList.New(CrafterCulinarianElementItemVM)
    self.FlavorElementList = UIBindableList.New(CrafterCulinarianElementItemVM)
    self.StormElementList = UIBindableList.New(CrafterCulinarianElementItemVM)

    self:ResetParams()
end

function CrafterCulinarianVM:OnBuffChanged(BuffID, bHasBuff)
    if BuffID == MenphinaBuffID then
        self.bIsMenphinaState = bHasBuff
    end
end

return CrafterCulinarianVM