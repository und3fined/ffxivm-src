--Author:Easy
--DateTime: 2023/1/10

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local ChocoboInfoAttrItemVM = require("Game/Chocobo/Life/VM/ChocoboInfoAttrItemVM")
local ChocoboMatchSectionCfg = require("TableCfg/ChocoboMatchSectionCfg")
local ChocoboUiIconCfg = require("TableCfg/ChocoboUiIconCfg")
local LSTR = nil

local ChocoboNewBornPanelVM = LuaClass(UIViewModel)
function ChocoboNewBornPanelVM:Ctor()
    LSTR = _G.LSTR
	self.ChildLevel = nil
	self.PanelParentInfoVisible = nil
	self.PanelChildVisible = nil
	self.PanelChildDetailVisible = nil
	self.PanelBottomVisible = nil
	self.BtnNextStepVisible = nil
	self.BtnNameVisible = nil

	self.FeatherRankText = nil
	self.FeatherIconPath = nil
	self.FeatherValue = nil

	self.FatherStarList = nil
	self.MotherStarList = nil
	self.ChildStarList = UIBindableList.New(ChocoboInfoAttrItemVM)
	self.ChildDetailList = UIBindableList.New(ChocoboInfoAttrItemVM)

	self.ChildData = nil
    
    self.FeatherIconPathCfg = {
        [1] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.FEATHER_STAGE_1),
        [2] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.FEATHER_STAGE_2),
        [3] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.FEATHER_STAGE_3),
        [4] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.FEATHER_STAGE_4),
        [5] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.FEATHER_STAGE_5),
        [6] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.FEATHER_STAGE_6),
        [7] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.FEATHER_STAGE_7),
        [8] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.FEATHER_STAGE_8),
        [9] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.FEATHER_STAGE_9),
    }

    self.AttrIconPathCfg = {
        [ProtoCommon.ChocoboAttrType.AttrTypeMaxSpeed] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.ATTR_MAX_SPEED),
        [ProtoCommon.ChocoboAttrType.AttrTypeSprintSpeed] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.ATTR_SPRINT_SPEED),
        [ProtoCommon.ChocoboAttrType.AttrTypeSkillStrenth] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.ATTR_SKILL_STRENGTH),
        [ProtoCommon.ChocoboAttrType.AttrTypeAcceleration] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.ATTR_ACCELERATION),
        [ProtoCommon.ChocoboAttrType.AttrTypeStamina] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.ATTR_STAMINA),
    }
end

function ChocoboNewBornPanelVM:OnInit()
end

function ChocoboNewBornPanelVM:OnBegin()
end

function ChocoboNewBornPanelVM:Clear()
end

function ChocoboNewBornPanelVM:OnEnd()
end

function ChocoboNewBornPanelVM:OnShutdown()

end

function ChocoboNewBornPanelVM:GetChildData()
	return self.ChildData
end

function ChocoboNewBornPanelVM:UpdateChild()
	self.PanelParentInfoVisible = false
	self.PanelChildDetailVisible = false
	self.PanelChildVisible = true
	self.PanelBottomVisible = true
	self.BtnNextStepVisible = true
	self.BtnNameVisible = false

	local Data = self.ChildData
	local AttrInfoList = {}
    local Count = #Data.Attr.Attr
    for i = 1, Count do
        local TempData = {}
        TempData.GeneRed = {}
        TempData.GeneBlue = {}
        if Data.Attr.Attr[i] ~= nil and Data.Attr.Max[i] ~= nil then
        	TempData.GeneRed = Data.Gene.GeneRed[i] == nil and 0 or Data.Gene.GeneRed[i]
            TempData.GeneBlue = Data.Gene.GeneBlue[i] == nil and 0 or Data.Gene.GeneBlue[i]
        end

		table.insert(AttrInfoList,TempData)
    end

    self.ChildStarList:UpdateByValues(AttrInfoList) 
end

function ChocoboNewBornPanelVM:UpdateChildDetail()
	self.PanelParentInfoVisible = false
	self.PanelChildDetailVisible = true
	self.PanelChildVisible = false
	self.PanelBottomVisible = true
	self.BtnNextStepVisible = false
	self.BtnNameVisible = true

	local Data = self.ChildData

	local AttrInfoList = {}
    local Count = #Data.Attr.Attr
    for i = 1, Count do  
    	local TempData = {}
        TempData.AttrName = ChocoboDefine.CHOCOBO_ATTR_TYPE_NAME[i]
    	TempData.AttrIconPath = self.AttrIconPathCfg[i]
		TempData.AttrValue = Data.Attr.Attr[i]
		TempData.MaxAttrValue = Data.Attr.Max[i]

	   	table.insert(AttrInfoList, TempData);
    end
    self.ChildDetailList:UpdateByValues(AttrInfoList) 

    -- 羽力值
    local FeatherValue = 0
    for __, MaxValue in ipairs(Data.Attr.Max) do
        FeatherValue = FeatherValue + MaxValue
    end

    --羽力值=五项属性上限的总和×(竞赛等级+10) / 500。计算结果向下取整
    local Feather =  math.floor((Data.Level + 10) * FeatherValue / 500)
    self.FeatherValue = LSTR(420005) .. " " .. Feather
    self.FeatherLevel = Data.Level
    
    local SectionCfgs = ChocoboMatchSectionCfg:FindAllCfg()
    for __, SectionCfg in pairs(SectionCfgs) do
        if Feather >= SectionCfg.LowerLimit and Feather <= SectionCfg.UpperLimit then
            self.FeatherLevel = SectionCfg.ID
        end
    end
    
    self.FeatherRankText = tostring(self.FeatherLevel)
    self.FeatherIconPath = self.FeatherIconPathCfg[self.FeatherLevel]
end

function ChocoboNewBornPanelVM:UpdateParent()
    self.PanelParentInfoVisible = true
    self.PanelBottomVisible = false
	self.PanelChildDetailVisible = false
	self.PanelChildVisible = false

    self:UpdateChild()
end

function ChocoboNewBornPanelVM:UpdatePanel(Child)
	if Child == nil then return end
	self.ChildData = Child

	self.ChildLevel = self.ChildData.Level
	if self.ChildData.Gender == 0 then
        self.GenderPath = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.GENDER_BOY)
    else
        self.GenderPath = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.GENDER_GIRL)
    end

	self:UpdateParent()
end

return ChocoboNewBornPanelVM
