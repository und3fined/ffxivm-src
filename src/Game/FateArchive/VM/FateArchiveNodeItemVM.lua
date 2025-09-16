local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EventID = require("Define/EventID")
local LSTR = _G.LSTR
local FateArchiveNodeItemVM = LuaClass(UIViewModel)

-- local UnknownTypeIcon = "PaperSprite'/Game/UI/Atlas/FateArchive/Frames/UI_FateArchive_Img_Unknown_png.UI_FateArchive_Img_Unknown_png'"
-- local FinishTypeIcon = "PaperSprite'/Game/UI/Atlas/FateArchive/Frames/UI_FateArchive_Image_Done_png.UI_FateArchive_Image_Done_png'"
-- local UnknownMonsterIcon = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_Unknown.UI_FateArchive_Img_Unknown'"
-- local DefaultMonsterIcon = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_Monster01.UI_FateArchive_Img_Monster01'"
function FateArchiveNodeItemVM:Ctor()
    self.Target = 0
    self.TextColor = "313131FF"
    self.NodeStatus = 0
    -- -- self.ConditionText = ""
    -- self.FateLevel = ""
    -- self.FateName = ""
    -- self.FateTypeIcon = ""
    -- self.FateMonsterIcon = ""
    -- self.bShowDoingText = false
    -- self.bShowUpperPart = true
end

function FateArchiveNodeItemVM:OnBegin()

end

function FateArchiveNodeItemVM:IsEqualVM(Value)
    return self.Target == Value.Target
end

function FateArchiveNodeItemVM:UpdateVM(Value)
    -- print(Value)
    self.Value = Value
    self.Target = Value.Target
    self.CurProgress = Value.CurProgress
    if self.CurProgress >= self.Target then
        self.NodeStatus = 1
        self.TextColor = "B56728FF"
    else
        self.NodeStatus = 0
        self.TextColor = "313131FF"
    end
end


return FateArchiveNodeItemVM