---
---@Author: ZhengJanChuan
---@Date: 2023-05-31 10:22:18
---@Description: 
---
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GuideCfg = require("TableCfg/GuideCfg")
local UIBindableList = require("UI/UIBindableList")
local TutorialGuideShowDropWinItemVM = require("Game/Tutorial/VM/TutorialGuideShowDropWinItemVM")
local LogMgr


local TutorialGuideShowPanelVM = LuaClass(UIViewModel)

---Ctor
function TutorialGuideShowPanelVM:Ctor()
    self.IsLeft = nil
    self.IsRight = nil
    self.DropListSelectIndex = nil
    self.SpecShowPicShow = false

    self.RichTextContent = nil
    self.TextTitle = nil
    self.GuideShowPic = nil
    self.SpecShowPic = nil
    self.TipsText = nil
    self.DropList = UIBindableList.New(TutorialGuideShowDropWinItemVM) --二级分类的列表
end

function TutorialGuideShowPanelVM:OnInit()
end

function TutorialGuideShowPanelVM:OnBegin()
    LogMgr = _G.LogMgr
    
    self.IsLeft = false
    self.IsRight = false
    self.DropListSelectIndex = 1

end

function TutorialGuideShowPanelVM:OnEnd()
end

function TutorialGuideShowPanelVM:OnShutdown()
end

--- 通过id 获取新手指南表的数据
function TutorialGuideShowPanelVM:UpdateData(ID, Index)  
    local Cfg = GuideCfg:FindCfgByGuideID(ID)

    if not Cfg then
        return 
    end

    self.TitleText = Cfg.Title
    self:UpdateContent(ID, Index)
    self:UpdateDotTable(Cfg)
    self.DropListSelectIndex = 1

end

function TutorialGuideShowPanelVM:UpdateDotTable(Cfg)
    if Cfg == nil then
        return
    end

    self.DropList:Clear()
    local List = {}
    for index, v in ipairs(Cfg.WindowContent) do
        local Data = TutorialGuideShowDropWinItemVM.New()
        if index == 1 then
            Data.IsSelected = true
        else
            Data.IsSelected = false
        end

        table.insert(List, Data)
    end

    self.DropList:Update(List)
end

function TutorialGuideShowPanelVM:UpdateContent(ID, Index)
    local Cfg = GuideCfg:FindCfgByGuideID(ID)
    if not Cfg then
        return 
    end

    local Pic = Cfg.Picture
    local Content = Cfg.WindowContent
    local ContentLength = (Cfg.WindowContent and not table.is_nil_empty(Cfg.WindowContent)) and table.length(Cfg.WindowContent) or 0 
    local SpecPic = Cfg.SpecPicture

    self.TextTitle = Cfg.Title

    if ContentLength < Index or Content == nil then
        return
    end

    self.GuideShowPic = Pic[Index]
    self.RichTextContent = Content[Index]

    if SpecPic[Index] and SpecPic[Index] ~= "" then
        self.SpecShowPic = SpecPic[Index]
        self.SpecShowPicShow = true
    else
        self.SpecShowPicShow = false
    end

    self.DropListSelectIndex = Index

    self.IsLeft = not (Index == 1)
    self.IsRight = not (Index >= ContentLength)

    self:UpdateTips(Cfg, Index)
end

function TutorialGuideShowPanelVM:UpdateTips(Cfg, Index)
    if Cfg == nil then
        return
    end

    if not(Cfg.IsRead ~= nil and Cfg.IsRead == 1) then
        self.TipsText = _G.LSTR(890004)
        return
    end

    local ContentLength = table.length(Cfg.Content)
    if Index >= ContentLength then
        self.TipsText = _G.LSTR(890004)
    else
        self.TipsText = _G.LSTR(890005)
    end
end

return TutorialGuideShowPanelVM