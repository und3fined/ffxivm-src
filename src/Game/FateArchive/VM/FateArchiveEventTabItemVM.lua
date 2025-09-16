local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EventID = require("Define/EventID")
local FateIconCfgTable = require("TableCfg/FateIconCfg")
local ProtoCS = require("Protocol/ProtoCS")
local LSTR = _G.LSTR
local FateArchiveEventTabItemVM = LuaClass(UIViewModel)
local UnknownTypeIcon = "PaperSprite'/Game/UI/Atlas/FateArchive/Frames/UI_FateArchive_Icon_Unknown_png.UI_FateArchive_Icon_Unknown_png'"
local FinishTypeIcon = "PaperSprite'/Game/UI/Atlas/FateArchive/Frames/UI_FateArchive_Image_Done_png.UI_FateArchive_Image_Done_png'"
-- local UnknownMonsterIcon = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_Unknown.UI_FateArchive_Img_Unknown'"
-- local DefaultMonsterIcon = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_Monster01.UI_FateArchive_Img_Monster01'"
function FateArchiveEventTabItemVM:Ctor()
    self.ID = 0
    self.PanelStatus = 0
    -- self.ConditionText = ""
    self.FateLevel = ""
    self.FateName = ""
    self.FateTypeIcon = ""
    self.FateMonsterIcon = ""
    self.bShowDoingText = false
    self.bShowUpperPart = true
    self.bShowUnkonwImg = false
    self.bIsNew = false
    self.bFinish = false
    self.bSelected = false
end

function FateArchiveEventTabItemVM:OnBegin()
end

function FateArchiveEventTabItemVM:IsEqualVM(Value)
    return self.ID == Value.ID
end

function FateArchiveEventTabItemVM:UpdateVM(Value)
    -- print(Value)
    self.Value = Value
    self.ID = Value.ID

    local FateArchiveMainVM = require("Game/FateArchive/VM/FateArchiveMainVM")
    local FateInfo = _G.FateMgr:GetFateInfo(Value.ID)
    -- 这里考虑未发现和已完成的Fate,使用不同的图标
    if FateInfo == nil and (not FateArchiveMainVM.bForceShowAll) then
        self.FateTypeIcon = UnknownTypeIcon
        self.bShowDoingText = false
        self.bShowUnkonwImg = true
        self.bShowUpperPart = true
        self.FateLevel = string.format(LSTR(10031), Value.Level)
        self.FateName = LSTR(190115)
        self.bFinish = false
    else
        self.bShowUnkonwImg = false
        self.bShowUpperPart = true
        self.FateLevel = string.format(LSTR(10031), Value.Level)
        self.FateName = Value.Name
        if _G.FateMgr:IsFateAchievementFinish(Value.ID) then
            self.FateTypeIcon = FinishTypeIcon
        else
            local IconCfg = FateIconCfgTable:FindCfg(string.format("Type = %d", Value.Type))
            self.FateTypeIcon = IconCfg.IconPath
        end

        local Achievement = nil
        if (FateInfo ~= nil) then
            Achievement = FateInfo.Achievement
        end

        local RevealCount = 0
        local TotalCount = 0
        if (Achievement ~= nil) then
            for Idx, Event in ipairs(Achievement) do
                TotalCount = TotalCount + 1
                Event.idx = Idx
                if Event.Target ~= nil and Event.Progress ~= nil and Event.Target > 0 and Event.Target == Event.Progress then
                    RevealCount = RevealCount + 1
                end
            end
        end
        self.bFinish = TotalCount > 0 and RevealCount >= TotalCount
        local ActiveFate = _G.FateMgr:GetActiveFate(Value.ID)
        self.bShowDoingText = ActiveFate ~= nil and ActiveFate.State ~= ProtoCS.FateState.FateState_Finished
    end

    self:RefreshNewState()
end

function FateArchiveEventTabItemVM:RefreshNewState()
    self.bIsNew = _G.FateMgr:IsFateNewTrigger(self.ID)
end

function FateArchiveEventTabItemVM:IsHide()
    return self.PanelStatus == 0
end

return FateArchiveEventTabItemVM
