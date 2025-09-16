local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MountVM = require("Game/Mount/VM/MountVM")
local RichTextUtil = require("Utils/RichTextUtil")


local LSTR = _G.LSTR

local MountSpeedListItemVM = LuaClass(UIViewModel)

function MountSpeedListItemVM:Ctor()
    self.MapID = 0
    self.MapName = ""
    self.QuestID = 0
    self.ItemID = 0
    self.QuestContent = ""
    self.MapSpeedLevel = 0
    self.SpeedLevelOne = 0
    self.SpeedLevelTwo = 0
    self.QuestInfoList = nil
    self.ImgFocusVisible = false
end

function MountSpeedListItemVM:UpdateVM(Value)
    self.MapID = Value.MapID
    self.MapName = Value.MapName
    self.QuestID = Value.QuestID
    self.ItemID = Value.ItemID
    self.QuestContent = Value.Content
    if MountVM.MountSpeedLevelMap then
        self.MapSpeedLevel = MountVM.MountSpeedLevelMap[self.MapID] or 0
    end
    self:SetSpeedLevelIcon()
    self:UpdateQuestInfo()
end

function MountSpeedListItemVM:SetSpeedLevelIcon()
    if self.MapSpeedLevel == 0 then
        self.SpeedLevelOne = 0
        self.SpeedLevelTwo = 0
    elseif self.MapSpeedLevel == 1 then
        self.SpeedLevelOne = 1
        self.SpeedLevelTwo = 0
    else
        self.SpeedLevelOne = 1
        self.SpeedLevelTwo = 1
    end
end

function MountSpeedListItemVM:SetSelectedState(Value)
    self.ImgFocusVisible = Value
end

function MountSpeedListItemVM:UpdateQuestInfo()
    local QuestInfo = {}
    local QuestInfoData = {}

    -- 条件一
    QuestInfoData.Title = LSTR(200007)
    local IconPath = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Main_Missed_png.UI_Icon_Hud_Main_Missed_png'"
    local Text1 = RichTextUtil.GetText(LSTR(200008),"D5D5D5")
    local IconRichText = RichTextUtil.GetTexture(IconPath,40, 40, -10)
    local QuestNameText = RichTextUtil.GetText(LSTR(200009),"D1BA8E")
    if self.MapSpeedLevel > 0 then
        local QuestName = _G.QuestMgr:GetQuestName(self.QuestID)
        QuestNameText = RichTextUtil.GetText(QuestName,"D1BA8E")
    end
    local Text2 = RichTextUtil.GetText(LSTR(200010),"D5D5D5")
    QuestInfoData.Info = string.format("%s%s%s%s", Text1, IconRichText, QuestNameText, Text2);
    QuestInfoData.ItemID = 0
    table.insert(QuestInfo, QuestInfoData)

    -- 条件二
    QuestInfoData = {}
    QuestInfoData.Title = LSTR(200011)
    QuestInfoData.Info = self.QuestContent
    QuestInfoData.ItemID = self.ItemID
    table.insert(QuestInfo, QuestInfoData)

    self.QuestInfoList = QuestInfo
end

return MountSpeedListItemVM
