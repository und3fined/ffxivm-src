
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIInteractiveUtil = require("Game/PWorld/UIInteractive/UIInteractiveUtil")
local TeachingDefine = require("Game/Pworld/Teaching/TeachingDefine")

local LSTR = _G.LSTR
local TeachingMgr = _G.TeachingMgr

local PWorldTeachingCatalogItemViewVM = LuaClass(UIViewModel)

function PWorldTeachingCatalogItemViewVM:Ctor()
    self.Name = ""
    self.Require = ""
    self.TextTag = ""
    self.InteractiveID = 0
    self.ImgPath = ""
    
    self.ShowPassed = _G.UE.ESlateVisibility.Hidden
    self.ShowLocked = _G.UE.ESlateVisibility.Hidden

    self.IsLast = false
    self.PreCompleted = false
    self.LevelLimit = 0
    self.CanPreview = false
    self.CanEnter = false
    self.ShowSelected = _G.UE.ESlateVisibility.Hidden
end

function PWorldTeachingCatalogItemViewVM:UpdateVM(Value)
    self.Name = Value.Content
    self.InteractiveID = Value.InteractiveID
    -- 项目是否已经通过
    self.ShowPassed = UIInteractiveUtil.InteractiveIsCompleted(self.InteractiveID) and _G.UE.ESlateVisibility.Visible or _G.UE.ESlateVisibility.Hidden
    -- 项目是否可以解锁，完成前置挑战
    self.IsLast = TeachingMgr:IsLastTeachingProject(self.InteractiveID)
    if self.IsLast then
        self.PreCompleted = TeachingMgr:PreInteractiveCompleted(self.InteractiveID)
    else
        self.PreCompleted = true
    end
    -- 项目是否可以解锁，判断职业等级
    self.LevelLimit = TeachingMgr:GetLevelLimit(self.InteractiveID)
    self.CanPreview = Value.MaxLevel >= self.LevelLimit and true or false
    self.CanEnter = Value.ProfLevel >= self.LevelLimit and true or false
    -- 设置Lock状态
    local ShowEmptyImg = false
    if not self.CanPreview then
        ShowEmptyImg = true
        self.ShowLocked = _G.UE.ESlateVisibility.Visible
        self.Require = string.format(LSTR(890023), self.LevelLimit)
    elseif not self.CanEnter then
        self.ShowLocked = _G.UE.ESlateVisibility.Visible
        self.Require = string.format(LSTR(890023), self.LevelLimit)
    elseif not self.PreCompleted then
        self.ShowLocked = _G.UE.ESlateVisibility.Visible
        self.Require = LSTR(890024)
    else
        self.ShowLocked = _G.UE.ESlateVisibility.Hidden
    end
    -- 设置背景图
    if ShowEmptyImg then
        self.ImgPath = TeachingDefine.EmptyImagePath
    else
        self.ImgPath = Value.BackImg
    end
    -- 当前选中
    if TeachingMgr:IsSelected(self.InteractiveID) then
        self.ShowSelected =  _G.UE.ESlateVisibility.Visible
        self.TextTag = LSTR(890025)
    else
        self.ShowSelected = _G.UE.ESlateVisibility.Hidden
    end
end


return PWorldTeachingCatalogItemViewVM