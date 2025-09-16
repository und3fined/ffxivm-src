local CommonUtil = require("Utils/CommonUtil")

local MapResCfg = require("TableCfg/MapresCfg")
local NPCBaseCfg = require("TableCfg/NpcbaseCfg")

local FAutoPSOUtil = _G.UE.FAutoPSOUtil
local FAssetFilter = _G.UE.FAssetFilter
local FAutoPSOAssetData = _G.UE.FAutoPSOAssetData
local NewObject = _G.NewObject

-----------------------------------------------------------------------------
--[[ Sample

local function PipelineSetupSample(Pipeline)
    -----------------------------------------------------------------------------
	-- Pipeline初始化
	-----------------------------------------------------------------------------

    Pipeline:Initialize("PipelineSample")  -- Pipeline标识，用于保存进度

    -----------------------------------------------------------------------------
	-- 添加PSOCollector
	-----------------------------------------------------------------------------

    local SamplePSOCollector = NewObject(_G.UE.USamplePSOCollector.StaticClass(), Pipeline)
    SamplePSOCollector.UsageMask = 1

    local AssetFilter = FAssetFilter()
    -- 指定需要处理的资源目录
    AssetFilter.SpecifiedDirectories:Add("/Game/Assets/Character/Demihuman/d1006/Equipment/e0005/Texture")
    AssetFilter.SpecifiedDirectories:Add("/Game/Assets/Character/Demihuman/d1006/Equipment/e0005/Material")
    -- 指定黑名单目录
    AssetFilter.BlacklistDirectories:Add("/Game/Assets/Character/Demihuman/d1006/Equipment/e0005/Material/v0001")
    SamplePSOCollector:FindAssetsFromAssetRegistry(AssetFilter)

    -- 直接指定资产
    local AssetData = FAutoPSOAssetData()
    AssetData.AssetClass = "Unknown"
    AssetData.Path = "/Game/Assets/Character/Demihuman/d1006/Equipment/e0005/DA_ImageChangeData.DA_ImageChangeData"
    SamplePSOCollector:AddAssetData(AssetData)
    AssetData.Path = "/Game/Assets/Character/Demihuman/d1006/Equipment/e0005/Material/v0001/MI_d1006e0005_glv_b.MI_d1006e0005_glv_b"
    SamplePSOCollector:AddAssetData(AssetData)

    Pipeline:AddCollector(SamplePSOCollector)
end

--]]
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Internal

local function SetupPostProcessing(Pipeline, UsageMask)
    local Collector = NewObject(_G.UE.UAutoPostProcessingPSO.StaticClass(), Pipeline)
    Collector.UsageMask = UsageMask
    Pipeline:AddCollector(Collector)
end

local function SetupParticle(Pipeline, UsageMask, MaterialQualityLevels)
    for _, Level in ipairs(MaterialQualityLevels) do
        local Collector = NewObject(_G.UE.UAutoParticlePSO.StaticClass(), Pipeline)
        Collector.UsageMask = UsageMask
        Collector.MaterialQualityLevel = Level
        --Collector.ProcessWaitFrame = 100
        Pipeline:AddCollector(Collector)
    end
end

local function CheckMap(Cfg)
    local Path = Cfg.PersistentLevelPath
    return not string.isnilorempty(Path) and
        -- not string.isnilorempty(Cfg.PackageName) and
        -- Cfg.VersionName == "2.0.0" and  -- TODO(loiafeng): 临时版本判断
        not string.endsWith(Path, "z1c1") and -- 屏蔽登录地图
        not string.endsWith(Path, "z1c2") and  -- 屏蔽登录地图
        not string.endsWith(Path, "z1c3") and  -- 屏蔽登录地图
        not string.endsWith(Path, "z1c4") and  -- 屏蔽登录地图
        not string.endsWith(Path, "z1c5") and  -- 屏蔽登录地图
        _G.ObjectMgr:IsResExist(Path)
end

local function SetupMap(Pipeline, UsageMask, MaterialQualityLevels)
    local AllCfg = MapResCfg:FindAllCfg()
    for _, Cfg in ipairs(AllCfg) do
        if CheckMap(Cfg) then
            local Path = Cfg.PersistentLevelPath
            for _, Level in ipairs(MaterialQualityLevels) do
                local Collector = NewObject(_G.UE.UAutoMapPSO.StaticClass(), Pipeline)
                Collector.UsageMask = UsageMask
                Collector.MaterialQualityLevel = Level
                Collector.bKillAppWhenTimeout = false
                Collector.PersistentLevelPaths:Add(Path)
                Pipeline:AddCollector(Collector)
            end
        end
    end
end

---@return number
local function HashNPCBaseCfg(Cfg)
    local function Hash(Seed, Value) 
        return Seed ~ (Value + 0x9e3779b9 + (Seed << 6) + (Seed >> 2))
    end

    local function ModelString2Number(ModelString)
        return tonumber((string.gsub(ModelString, "[ %;]", ""))) or 0
    end

    local HashCode = 0
    HashCode = Hash(HashCode, Cfg.Customize00)
    HashCode = Hash(HashCode, Cfg.Customize01)
    HashCode = Hash(HashCode, Cfg.Customize02)
    HashCode = Hash(HashCode, Cfg.Customize03)
    HashCode = Hash(HashCode, Cfg.Customize04)

    HashCode = Hash(HashCode, ModelString2Number(Cfg.Weapon))
    HashCode = Hash(HashCode, ModelString2Number(Cfg.SubWeapon))
    HashCode = Hash(HashCode, ModelString2Number(Cfg.Equip00))
    HashCode = Hash(HashCode, ModelString2Number(Cfg.Equip01))
    HashCode = Hash(HashCode, ModelString2Number(Cfg.Equip02))
    HashCode = Hash(HashCode, ModelString2Number(Cfg.Equip03))
    HashCode = Hash(HashCode, ModelString2Number(Cfg.Equip04))
    HashCode = Hash(HashCode, ModelString2Number(Cfg.Equip05))
    HashCode = Hash(HashCode, ModelString2Number(Cfg.Equip06))
    HashCode = Hash(HashCode, ModelString2Number(Cfg.Equip07))
    HashCode = Hash(HashCode, ModelString2Number(Cfg.Equip08))
    HashCode = Hash(HashCode, ModelString2Number(Cfg.Equip09))

    HashCode = Hash(HashCode, Cfg.WeaponStain)
    HashCode = Hash(HashCode, Cfg.SubWeaponStain)
    HashCode = Hash(HashCode, Cfg.Stain00)
    HashCode = Hash(HashCode, Cfg.Stain01)
    HashCode = Hash(HashCode, Cfg.Stain02)
    HashCode = Hash(HashCode, Cfg.Stain03)
    HashCode = Hash(HashCode, Cfg.Stain04)
    HashCode = Hash(HashCode, Cfg.Stain05)
    HashCode = Hash(HashCode, Cfg.Stain06)
    HashCode = Hash(HashCode, Cfg.Stain07)
    HashCode = Hash(HashCode, Cfg.Stain08)
    HashCode = Hash(HashCode, Cfg.Stain09)

    return HashCode
end

local function SetupCharacter(Pipeline, UsageMask, MaterialQualityLevels)
    local AllCfg = NPCBaseCfg:FindAllCfg()

    local CfgHashSet = {}
    local IdsToCollect = {}

    -- 筛选出需要处理的Avatar
    for _, Cfg in ipairs(AllCfg) do
        local HashCode = HashNPCBaseCfg(Cfg)
        if nil == CfgHashSet[HashCode] then
            CfgHashSet[HashCode] = true
            table.insert(IdsToCollect, Cfg.Key)
        end
    end

    for _, Level in ipairs(MaterialQualityLevels) do
        local Collector = NewObject(_G.UE.UAutoCharacterPSO.StaticClass(), Pipeline)
        Collector.UsageMask = UsageMask
        Collector.MaterialQualityLevel = Level

        for _, Id in ipairs(IdsToCollect) do Collector.NPCBaseIDs:Add(Id) end
        Pipeline:AddCollector(Collector)
    end
end

local function SetupMaterial(Pipeline, UsageMask, MaterialQualityLevels)
    for _, Level in ipairs(MaterialQualityLevels) do
        local Collector = NewObject(_G.UE.UAutoMaterialPSO.StaticClass(), Pipeline)
        Collector.UsageMask = UsageMask
        Collector.MaterialQualityLevel = Level
        -- Collector.CollectMapPath = "/Game/Assets/bg/ffxiv/wil_w1/evt/w1eb/level/w1eb"  -- "/Game/Assets/bg/ffxiv/fst_f1/twn/f1t1/level/f1t1"
        Collector.CollectMapPath = "/Game/Assets/bg/ffxiv/fst_f1/twn/f1t1/level/f1t1"

        -- Collector.SkeletonMeshPath1 = "/Game/Assets/Character/Human/Skeleton/c1101/Face/f0101/Model/SK_c1101f0101.SK_c1101f0101"
        Collector.SkeletonMeshPath2 = "/Game/Assets/Character/Human/Skeleton/c0201/Body/b0001/Model/SK_c0201b0001.SK_c0201b0001"
        Collector.SwitchLightFrame = 1

        Pipeline:AddCollector(Collector)
    end
end

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Pipeline Setup

local function PipelineSetupAll(Pipeline, QualityLevels)
    Pipeline:Initialize("PipelineAll") -- Pipeline标识，用于保存进度

    local UsageMask = -1

    SetupPostProcessing(Pipeline, UsageMask)

    SetupParticle(Pipeline, UsageMask, QualityLevels)

    SetupMap(Pipeline, UsageMask, QualityLevels)

    -- SetupCharacter(Pipeline, UsageMask, QualityLevels)

    SetupMaterial(Pipeline, UsageMask, QualityLevels)
end

local function PipelineSetupParticle(Pipeline, QualityLevels)
    Pipeline:Initialize("PipelineParticle") -- Pipeline标识，用于保存进度

    local UsageMask = -1
    SetupParticle(Pipeline, UsageMask, QualityLevels)
end

local function PipelineSetupMap(Pipeline, QualityLevels)
    Pipeline:Initialize("PipelineMap") -- Pipeline标识，用于保存进度

    local UsageMask = -1
    SetupMap(Pipeline, UsageMask, QualityLevels)
end

local function PipelineSetupCharacter(Pipeline, QualityLevels)
    Pipeline:Initialize("PipelineCharacter") -- Pipeline标识，用于保存进度

    local UsageMask = -1
    SetupCharacter(Pipeline, UsageMask, QualityLevels)
end

local function PipelineSetupMaterial(Pipeline, QualityLevels)
    Pipeline:Initialize("PipelineMaterial") -- Pipeline标识，用于保存进度

    local UsageMask = -1
    SetupMaterial(Pipeline, UsageMask, QualityLevels)
end

local PipelineSetupFunctionMap = {
    ["All"] = PipelineSetupAll,
    ["Particle"] = PipelineSetupParticle,
    ["Map"] = PipelineSetupMap,
    ["Character"] = PipelineSetupCharacter,
    ["Material"] = PipelineSetupMaterial,
}

local PSOUtil = {}

function PSOUtil.CollectPSO(Pipeline, Arg1, Arg2)
    local Scenario = Arg1.Value
    local QualityLevels = {}
    if not string.isnilorempty(Arg2.Value) then
        for _, QualityLevel in ipairs(string.split(Arg2.Value, ",")) do
            table.insert(QualityLevels, tonumber(QualityLevel))
        end
    else
        QualityLevels = {1,2,3}
    end

    _G.FLOG_INFO("PSOUtil.CollectPSO(): Collecting %s, Quality Levels: %s", Scenario, table.tostring(QualityLevels))

    local SetupFunction = PipelineSetupFunctionMap[Scenario]
    if SetupFunction then
        SetupFunction(Pipeline, QualityLevels)
    else
        local AvailableArgs = {}
        for Key, _ in pairs(PipelineSetupFunctionMap) do
            table.insert(AvailableArgs, Key)
        end

        local Message = string.format("Unknown command arg: \"%s\". Available args are: %s", Scenario, table.concat(AvailableArgs, ", "))
        FAutoPSOUtil.ShowTips("Unknown Arg!", Message)
    end
    Pipeline:Start()
end

return PSOUtil
