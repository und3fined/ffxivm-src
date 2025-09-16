
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local UIUtil = require("Utils/UIUtil")

local LSTR = _G.LSTR
local ProtoCS = require("Protocol/ProtoCS")
local RecipeCfg = require("TableCfg/RecipeCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local CatalystCfg = require("TableCfg/CatalystCfg")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local LifeskillEffectCfg = require("TableCfg/LifeskillEffectCfg")
local RandomEventCfg = require("TableCfg/RandomEventCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local CollectInfoCfg = require("TableCfg/CollectInfoCfg")
local ItemUtil = require("Utils/ItemUtil")
local TimeUtil = require("Utils/TimeUtil")
---@class CrafterSidebarPanelVM : UIViewModel
local CrafterSidebarPanelVM = LuaClass(UIViewModel)

local FVector2D = _G.UE.FVector2D

function CrafterSidebarPanelVM:Ctor()
    self.EventSkillRsp = {}

    self.ProfName = ""
    self.RecipeName = ""
    self.ItemIconPath = ""
    self.TextValue = ""
    self.TextValueNumber = ""

    self.bShowImgCollect = false
    self.bHorizontalValue = false
    self.bQualityPanel = false

    self.OpCountText = 0
    self.ProductionNumText = 0
    self.bProductionNumVisible = true
    self.RichTextDurableText = ""
    self.ProgressText = ""
    self.QualityText = ""
    self.QualityTitle = ""
    
    self.DurableBarSize = _G.UE.FVector2D(296, 36)
    self.DurableBar = 0
    self.ProgressBar = 0
    self.QualityBar = 0
    self.SetDurableFillColorType = 1
    self.SetImgQualityPos = nil
    self.CollectTextBlue = ""
    self.CollectTextYellow = ""
    self.CollectTextGreen = ""
    self.CollectAnimType = 0

    self.ImgQualityGreenPercent = 0.95
end

function CrafterSidebarPanelVM:OnInit()
    self.AnimInfoMap = {}
    self.AnimInfoMap[ProtoCS.FeatureType.FEATURE_TYPE_PROGRESS] = 
        {Last = 0, To = 1, Prop = "ProgressBar", LifeTime = 200, CurTime = 0}
    self.AnimInfoMap[ProtoCS.FeatureType.FEATURE_TYPE_QUALITY] = 
        {Last = 0, To = 1, Prop = "QualityBar", LifeTime = 200, CurTime = 0}
end

function CrafterSidebarPanelVM:OnBegin()
end

function CrafterSidebarPanelVM:OnEnd()
end

function CrafterSidebarPanelVM:OnShutdown()
end

function CrafterSidebarPanelVM:Reset()
end

--StartMake的回包，处理界面刷新
function CrafterSidebarPanelVM:UpdateStartMakeRsp(StartMakeRsp)  
    if not StartMakeRsp then
        FLOG_ERROR("Crafter StartMakeRsp is nil")
        return 
    end

    local RecipleID = StartMakeRsp.RecipeID
    self.RecipeConfig = RecipeCfg:FindCfgByKey(RecipleID)
    if not self.RecipeConfig then
        FLOG_ERROR("Crafter Reciper %d not config", RecipleID)
        return 
    end

    -- 是不是收藏品
    local IsCollection = self.RecipeConfig.IsCollection == 1
    self.RecipeName = ItemUtil.GetItemName(self.RecipeConfig.ProductID)
    local NowMakeCount = _G.CraftingLogMgr.NowMakeCount
    if NowMakeCount == 1 then
        self.ProductionNumText = self.RecipeConfig.ProductNum
    else
        self.ProductionNumText = string.format("%s x %s",self.RecipeConfig.ProductNum, NowMakeCount)
    end
    local Cfg = ItemCfg:FindCfgByKey(self.RecipeConfig.ProductID)
    if Cfg then
        self.ItemIconPath = UIUtil.GetIconPath(Cfg.IconID)
    end

    self.QualityMax = self.RecipeConfig.QualityMax

    local MajorProfID = MajorUtil.GetMajorProfID()
    local ProfName = RoleInitCfg:FindRoleInitProfName(MajorProfID) or ""
    self.ProfName = ProfName

    self.bShowImgCollect = IsCollection
    local bShowQualityPanel = false
    
    self.CollectValues = nil
    if IsCollection then
        bShowQualityPanel = true
        self.TextValue = LSTR(150066)  -- 收藏价值
        self.QualityTitle = LSTR(150066)  -- 收藏价值
        local Quality = StartMakeRsp.Features[ProtoCS.FeatureType.FEATURE_TYPE_QUALITY] or 0
        self.CollectAnimType = 0

        if Quality == 0 then
            Quality = 1
        end
        self.TextValueNumber = Quality

        local CollectionCfg = CollectInfoCfg:FindCfgByKey(self.RecipeConfig.ProductID)
        if CollectionCfg then
            self.CollectValues = CollectionCfg.CollectValue
            self.QualityMax = self.CollectValues[3] / self.ImgQualityGreenPercent
            --刷新位置
            self.SetImgQualityPos = self.CollectValues

            self.CollectTextBlue = string.format("%d~", self.CollectValues[1])
            self.CollectTextYellow = string.format("%d~", self.CollectValues[2])
            self.CollectTextGreen = string.format("%d~", self.CollectValues[3])
        end
    else
        self.TextValue = LSTR(150067)  -- 优质率
        self.QualityTitle = LSTR(150068)  -- 品质
        local Value = StartMakeRsp.Features[ProtoCS.FeatureType.FEATURE_TYPE_HQRATE] or 0
        self.TextValueNumber = math.floor(Value / 100) .. "%"
    end

    if self.RecipeConfig.CanHQ == 0 or IsCollection then
        self.bHorizontalValue = false
    else
        self.bHorizontalValue = true
        bShowQualityPanel = true
    end
    self.bQualityPanel = bShowQualityPanel
    
    self:UpdateFeatures(StartMakeRsp.Features)
end

function CrafterSidebarPanelVM:StartAnimTimer()
    self.LastUpdateTime = TimeUtil.GetLocalTimeMS()
    if not self.AnimTimerID then
        self.AnimTimerID = _G.TimerMgr:AddTimer(self, self.ProgressAnimUpdate, 0, 0, 0)
    end
end

function CrafterSidebarPanelVM:CloseAnimTimer()
    if self.AnimTimerID then
        _G.TimerMgr:CancelTimer(self.AnimTimerID)
        self.AnimTimerID = nil
    end
end

function CrafterSidebarPanelVM:ProgressAnimUpdate()
    local CurLocalTime = TimeUtil.GetLocalTimeMS()
    local ElapsedTime = CurLocalTime - self.LastUpdateTime
    local AnimOver = true
	-- print("-------- crafter ProgressAnimUpdate Elapsed:", ElapsedTime)

    for FeatureID, AnimInfo in pairs(self.AnimInfoMap) do
        AnimInfo.CurTime = AnimInfo.CurTime + ElapsedTime
        local X = AnimInfo.CurTime / AnimInfo.LifeTime
        if X > 1 then
            X = 1
            AnimInfo.Last = AnimInfo.To
            AnimInfo.CurTime = 0
        else
            AnimOver = false
        end

        X = 1 - X

        local CurStep = (1 - X * X * X) * (AnimInfo.To - AnimInfo.Last)
        local To = AnimInfo.Last + CurStep
        -- print("crafter, To: ", To, " Last: ", AnimInfo.Last, " CurStep: ", CurStep
        --     , " CurTime: ", AnimInfo.CurTime, " X: ", X)
        
        self[AnimInfo.Prop] = To
    end

    if AnimOver then
        self:CloseAnimTimer()
    end
    
    self.LastUpdateTime = CurLocalTime
end

function CrafterSidebarPanelVM:UpdateFeatures(Features)
	if not Features or not self.RecipeConfig then
		return 
	end
    
    --耐久
    local Value = Features[ProtoCS.FeatureType.FEATURE_TYPE_DURABILITY] or 0
    local MaxDuration = self.RecipeConfig.Durability    --math.random(1, 8) * 10
    local Width = MaxDuration * 2.5
    Width = math.floor(Width)
    -- FLOG_ERROR("Test: Crafter Width:%d, Max:%d", Width, MaxDuration)
    self.DurableBarSize = _G.UE.FVector2D(Width, 36)
    self.DurableBar = Value / MaxDuration
    if self.DurableBar >= 0.5 then
        self.RichTextDurableText = string.format("<span color=\"#6fb1e9FF\">%d</><span color=\"#AAAAAAFF\">/%d</>"
            , Value, self.RecipeConfig.Durability)
        self.SetDurableFillColorType = 1
    elseif self.DurableBar >= 0.25 then
        self.RichTextDurableText = string.format("<span color=\"#d1ba8eFF\">%d</><span color=\"#AAAAAAFF\">/%d</>"
            , Value, self.RecipeConfig.Durability)
        self.SetDurableFillColorType = 2
    else
        self.RichTextDurableText = string.format("<span color=\"#dc5868FF\">%d</><span color=\"#AAAAAAFF\">/%d</>"
            , Value, self.RecipeConfig.Durability)
        self.SetDurableFillColorType = 3
    end 
    
    --进度
    Value = Features[ProtoCS.FeatureType.FEATURE_TYPE_PROGRESS] or 0
    self.ProgressText = Value .. "/" .. self.RecipeConfig.ProgressMax
    local TargetPercent = Value / self.RecipeConfig.ProgressMax
    -- print("++++ Crafter PROGRESS TargetPercent: ", TargetPercent)
    local AnimInfo = self.AnimInfoMap[ProtoCS.FeatureType.FEATURE_TYPE_PROGRESS]
    if TargetPercent > AnimInfo.Last then
        AnimInfo.To = TargetPercent
        AnimInfo.CurTime = 0
        AnimInfo.LifeTime = 200
        AnimInfo.Last = self[AnimInfo.Prop]
        self:StartAnimTimer()
    else
        self.ProgressBar = TargetPercent
        AnimInfo.To = TargetPercent
        AnimInfo.Last = TargetPercent
    end

    --品质
    Value = Features[ProtoCS.FeatureType.FEATURE_TYPE_QUALITY] or 0
    -- Value = Value * 6
    if self.bShowImgCollect then
        if Value == 0 then
            Value = 1
        end

        local CollectValues = self.CollectValues
        if CollectValues then
            self.QualityText = Value .. "/" .. CollectValues[3]
            for i = #CollectValues, 1, -1 do
                if Value >= CollectValues[i] then
                    self.CollectAnimType = i
                    break
                end
            end
        end
        self.TextValueNumber = Value
    else
        self.QualityText = Value .. "/" .. self.RecipeConfig.QualityMax
    end

    TargetPercent = Value / self.QualityMax
    if TargetPercent > 1 then
        TargetPercent = 1
    end
    
    -- print("++++ Crafter QUALITY TargetPercent: ", TargetPercent)
    AnimInfo = self.AnimInfoMap[ProtoCS.FeatureType.FEATURE_TYPE_QUALITY]
    if AnimInfo then
        if TargetPercent > AnimInfo.Last then
            AnimInfo.To = TargetPercent
            AnimInfo.CurTime = 0
            AnimInfo.LifeTime = 200
            AnimInfo.Last = self[AnimInfo.Prop]
            self:StartAnimTimer()
        else
            self.QualityBar = TargetPercent
            AnimInfo.To = TargetPercent
            AnimInfo.Last = TargetPercent
        end
    else
        FLOG_ERROR("++++ Crafter AnimInfo is nil")
    end

    --工次
    Value = Features[ProtoCS.FeatureType.FEATURE_TYPE_STEPS] or 0
    self.OpCountText = Value
    
    --反应强度
    -- Value = Features[ProtoCS.FeatureType.FEATURE_TYPE_STEPS] or 0
    -- self.StrengthText:SetText(Value)

    --优质率
    if self.RecipeConfig.CanHQ == 1 and not self.bShowImgCollect then
        Value = Features[ProtoCS.FeatureType.FEATURE_TYPE_HQRATE] or 0
        self.TextValueNumber = math.floor(Value / 100) .. "%"
    end
end

--技能的回包，处理界面刷新，随机事件
function CrafterSidebarPanelVM:UpdateSkillRsp(MsgBody)
    -- self.EventSkillRsp = MsgBody.CrafterSkill
end

return CrafterSidebarPanelVM