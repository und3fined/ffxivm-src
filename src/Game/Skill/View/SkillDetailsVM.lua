local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillSystemSeriesCfg = require("TableCfg/SkillSystemSeriesCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")
local SkillUtil = require("Utils/SkillUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local SkillTipsUtil = require("Utils/SkillTipsUtil")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local PassiveSkillVM = require("Game/Skill/View/PassiveSkillVM")

local SkillSystemMgr = _G.SkillSystemMgr
local SkillTipsType <const> = SkillCommonDefine.SkillTipsType
local SeriesDetailNum    <const> = 6
local SeriesDetailMiddle <const> = 4

---@class SkillDetailsVM : UIViewModel
local SkillDetailsVM = LuaClass(UIViewModel)

function SkillDetailsVM:Ctor()
    self.SkillName = ""
    --self.SkillType = ""
    self.SkillIcon = ""
    self.SkillID = 0
    self.Index = -1
    self.Desc = ""
    self.LearnLevel = 0
    self.bShowLearnLevel = false
    self.bShowAdvancedProfPanel = false
    self.bIsAdvancedProf = false
    self.AdvancedProfText = ""
    self.bLearned = false
    self.AppendImage = ""
    self.bAppendImageVisible = false
    self.bPanelMoreVisible = false
    self.bPanelMoreExpanded = false
    self.ExpandText = ""
    self.bShowSeriesPanel = false
    self.RedDotNum = nil
    self.AttrList = {}
    self.bShowAttrList = false

    for i = 1, SeriesDetailNum do
        self[string.format("SeriesDetailVM%d", i)] = PassiveSkillVM.New()
        self[string.format("SeriesDetailShow%d", i)] = false
    end
end

function SkillDetailsVM:OnInit()

end

function SkillDetailsVM:OnBegin()
end

function SkillDetailsVM:OnEnd()
    -- self:UnRegisterAllRedDotWidgets()
end

function SkillDetailsVM:OnShutdown()
end

function SkillDetailsVM:UnRegisterAllRedDotWidgets()
    local SkillSystemMgr = _G.SkillSystemMgr
    local UnRegisterSkillRedDotWidget = SkillSystemMgr.UnRegisterSkillRedDotWidget
    UnRegisterSkillRedDotWidget(SkillSystemMgr, self.SkillID)
    for i = 1, SeriesDetailNum do
        local VM = self[string.format("SeriesDetailVM%d", i)]
        if VM then
            UnRegisterSkillRedDotWidget(SkillSystemMgr, VM.SkillID)
        end
    end
end

local LSTR = _G.LSTR
local LocalStrID = require("Game/Skill/SkillSystem/SkillSystemConfig").LocalStrID
local LSTR_Active <const> = LocalStrID.Active

function SkillDetailsVM:UpdateVM(Params)
    if Params and Params.SkillID ~= nil then
        self.bShowCrafterCost = Params.ProfFlags.bMakeProf and Params.CurrentLabel == LSTR_Active
        local ProfFlags = Params.ProfFlags

        local bShowAttrList = false
        if ProfFlags.bMakeProf and Params.CurrentLabel == LocalStrID.Active then
            bShowAttrList = true
            rawset(self, "AttrListType", SkillTipsType.Crafter)
        elseif not Params.bPassiveSkill and Params.ProfFlags.bCombatProf then
            bShowAttrList = true
            rawset(self, "AttrListType", SkillTipsType.Combat)
        end
        self.bShowAttrList = bShowAttrList

        local co = coroutine.create(self.SetSkillID)
        _G.UIAsyncTaskMgr:RegisterTask(co, self, Params.SkillID)
        self.Index = Params.Index
        self.EntityID = Params.EntityID
        local AppendImage = Params.AppendImage
        self.AppendImage = AppendImage
        self.bAppendImageVisible = AppendImage and AppendImage ~= ""
        self:SetSeriesList(Params)
        self.bPanelMoreVisible = Params.bPanelMoreVisible
        self.bPanelMoreExpanded = Params.bPanelMoreExpanded

        local bLimitSkill = Params.bLimitSkill
        if bLimitSkill then
            self.ExpandText = LSTR(170057)  -- 其他阶段
        else
            self.ExpandText = LSTR(170056)  -- 低级技能
        end
        self.bShowLearnLevel = not bLimitSkill and SkillSystemMgr:IsCurrentMapPVE()
    end
end

function SkillDetailsVM:SetAttrList(Cfg)
    if not self.bShowAttrList then
        return
    end
    self.AttrList = SkillTipsUtil.GetSkillAttrList(Cfg, rawget(self, "AttrListType"))
end

function SkillDetailsVM:SetSkillID(SkillID)
    self.SkillID = SkillID
    if SkillID ~= nil and SkillID > 0 then
        local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
        if Cfg then
            self.SkillName = Cfg.SkillName
            --self.SkillType = SkillTypeName[Cfg.Type]
            self.SkillIcon = Cfg.Icon
            self.Desc = Cfg.Desc

            self:SetAttrList(Cfg)
        end

        local ProfID = _G.SkillSystemMgr.ProfID
        local MajorLevel
        local bProfUnlocked = true
        if _G.DemoMajorType == 1 then
            bProfUnlocked = false
            MajorLevel = SkillUtil.GetGlobalConfigMaxLevel()
        else
            local MajorRoleDetail = ActorMgr:GetMajorRoleDetail()
	        if nil == MajorRoleDetail or nil == MajorRoleDetail.Prof.ProfList[ProfID] then
                bProfUnlocked = false
                MajorLevel = SkillUtil.GetGlobalConfigMaxLevel()
            else
                MajorLevel = MajorUtil.GetMajorLevelByProf(ProfID)
            end
        end
        local _, Level, bAdvancedProfUse = SkillUtil.GetSkillLearnValid(SkillID, ProfID, MajorLevel)
        self.bLearned = Level <= MajorLevel or (not bProfUnlocked)
        self.LearnLevel = Level

        local AdvancedProfID = ProfUtil.GetAdvancedProf(ProfID)
        self.bShowAdvancedProfPanel = bAdvancedProfUse and SkillSystemMgr:IsCurrentMapPVE()
        self.bIsAdvancedProf = AdvancedProfID == ProfID or (not bProfUnlocked)
        self.AdvancedProfText = ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, AdvancedProfID) or ""
    end
end

function SkillDetailsVM:SetSeriesList(Params)
    local co = coroutine.create(self.SetSeriesListAsync)
    _G.UIAsyncTaskMgr:RegisterTask(co, self, Params)
end

function SkillDetailsVM:SetSeriesListAsync(Params)
    local SkillID = Params.SkillID
    local Index = Params.Index
    local EntityID = Params.EntityID
    local bPassive = Params.bPassiveSkill
	local SeriesList = {}
	if SkillID > 0 and Index >= 0 and EntityID > 0 then
        if not bPassive then
            local LogicData = _G.SkillLogicMgr:GetSkillLogicData(EntityID)
            if LogicData then
                SeriesList = _G.SkillLogicMgr:GetPlayerSeriesList(EntityID, Index)
            end
        else
            local SeriesCfg = SkillSystemSeriesCfg:FindCfgByID(SkillID)
            if SeriesCfg then
                SeriesList = string.split(SeriesCfg.SkillQueue, ",")
            end
        end
	end
    coroutine.yield()
    local SkillSystemMgr = _G.SkillSystemMgr
    self:UnRegisterAllRedDotWidgets()
    local bAnySeriesDetailShow = false

    local SeriesSkillNum = #SeriesList
    local SelectedIndex = 0
    for i = 1, SeriesSkillNum do
        if SeriesList[i] == SkillID then
            SelectedIndex = i
            break
        end
    end
    local Offset = math.clamp(SelectedIndex - SeriesDetailMiddle, 0, SeriesSkillNum - SeriesDetailNum)

    for i = 1, SeriesDetailNum do
        local SeriesSkillID = SeriesList[i + Offset] or 0
        SkillSystemMgr:UnRegisterSkillRedDotWidget(SeriesSkillID)
        bAnySeriesDetailShow = bAnySeriesDetailShow or SeriesSkillID > 0

        if SeriesSkillID > 0 then
            self[string.format("SeriesDetailShow%d", i)] = true
            local SeriesDetailVM = self[string.format("SeriesDetailVM%d", i)]
            SeriesDetailVM:UpdateSeriesVM(SeriesSkillID, SeriesSkillID == SkillID)
            _G.SkillSystemMgr:RegisterSkillRedDotWidget(SeriesSkillID, function(bVisible)
                SeriesDetailVM.RedDotNum = bVisible and 1 or 0
            end)
        else
            self[string.format("SeriesDetailShow%d", i)] = false
        end
        coroutine.yield()
    end
    self.bShowSeriesPanel = bAnySeriesDetailShow
    SkillSystemMgr:RegisterSkillRedDotWidget(SkillID, function(bVisible)
        self.RedDotNum = bVisible and 1 or 0
    end)
end

function SkillDetailsVM:IsEqualVM(Value)
    return self.SkillID == Value
end

SkillDetailsVM.SeriesDetailNum = SeriesDetailNum

return SkillDetailsVM