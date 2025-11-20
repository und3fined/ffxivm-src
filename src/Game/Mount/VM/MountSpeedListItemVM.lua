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
    self.MaxSpeedLevel = 0
    self.Unlock =  {}
    self.MapSpeedLevel = 0
    self.SpeedLevelOne = 0
    self.SpeedLevelTwo = 0
    self.SpeedLevelThere = 0
    self.QuestInfoList = nil
    self.ImgFocusVisible = false
    self.SpeedLevelThereVisible = true
end

function MountSpeedListItemVM:IsEqualVM(Value)
    return self.MapID == Value.MapID
end

function MountSpeedListItemVM:UpdateVM(Value)
    self.MapID = Value.MapID
    self.MapName = Value.MapName
    self.MaxSpeedLevel = Value.MaxSpeedLevel
    self.QuestID = Value.QuestID
    self.Unlock = Value.Unlock
    if MountVM.MountSpeedLevelMap then
        self.MapSpeedLevel = MountVM.MountSpeedLevelMap[self.MapID] or 0
    end
    self:SetSpeedLevelIcon()
    self.SpeedLevelThereVisible = self.MaxSpeedLevel >= 3
    self:UpdateQuestInfo()
end

function MountSpeedListItemVM:SetSpeedLevelIcon()
    if self.MapSpeedLevel == 0 then
        self.SpeedLevelOne = 0
        self.SpeedLevelTwo = 0
        self.SpeedLevelThere = 0
    elseif self.MapSpeedLevel == 1 then
        self.SpeedLevelOne = 1
        self.SpeedLevelTwo = 0
        self.SpeedLevelThere = 0
    elseif self.MapSpeedLevel == 2 then
        self.SpeedLevelOne = 1
        self.SpeedLevelTwo = 1
        self.SpeedLevelThere = 0
    else
        self.SpeedLevelOne = 1
        self.SpeedLevelTwo = 1
        self.SpeedLevelThere = 1
    end
end

function MountSpeedListItemVM:SetSelectedState(Value)
    self.ImgFocusVisible = Value
end

function MountSpeedListItemVM:UpdateQuestInfo()
    local QuestInfo = {}
    local QuestInfoData = {}

    -- 条件一
    QuestInfoData.ID = 1
    QuestInfoData.Title = LSTR(200007)
    local IconPath = "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_Main_Missed_png.UI_Icon_Hud_Main_Missed_png'"
    local Text1 = self.Unlock[1].Content
    local IconRichText = RichTextUtil.GetTexture(IconPath,40, 40, -10)
    local QuestNameText = RichTextUtil.GetText(_G.QuestMgr:GetQuestLevel(self.QuestID) .. LSTR(200009),"D1BA8E")

    if self.MapSpeedLevel > 0 then
        local QuestName = _G.QuestMgr:GetQuestName(self.QuestID)
        QuestNameText = RichTextUtil.GetText(QuestName,"D1BA8E")
    end
    QuestInfoData.Info = string.format(Text1,IconRichText..QuestNameText);
    QuestInfoData.ItemID = self.Unlock[1].ItemID
    table.insert(QuestInfo, QuestInfoData)

    -- 条件二
    QuestInfoData = {}
    QuestInfoData.ID = 2
    QuestInfoData.Title = LSTR(200011)
    QuestInfoData.Info = self.Unlock[2].Content
    QuestInfoData.ItemID = self.Unlock[2].ItemID
    table.insert(QuestInfo, QuestInfoData)

    -- 条件三
    if self.MaxSpeedLevel >= 3 then
        QuestInfoData = {}
        QuestInfoData.ID = 3
        QuestInfoData.Title = LSTR(200014)
        QuestInfoData.Info = self.Unlock[3].Content
        QuestInfoData.ItemID = self.Unlock[3].ItemID
        table.insert(QuestInfo, QuestInfoData)
    end

    self.QuestInfoList = QuestInfo
end

return MountSpeedListItemVM
