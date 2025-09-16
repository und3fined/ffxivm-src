---
---@Author: ZhengJanChuan
---@Date: 2023-05-31 15:26:39
---@Description: 
 ---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GuideCfg = require("TableCfg/GuideCfg")
local TutorialGuideMgr = require("Game/Tutorial/TutorialGuideMgr")
local TutorialGuideListItemVM = require("Game/Tutorial/VM/TutorialGuideListItemVM")
local TutorialGuideListSearchItemVM = require("Game/Tutorial/VM/TutorialGuideListSearchItemVM")
local TutorialGuideShowDropWinItemVM = require("Game/Tutorial/VM/TutorialGuideShowDropWinItemVM")
local UIBindableList = require("UI/UIBindableList")

local EToggleButtonState = _G.UE.EToggleButtonState
local LSTR = _G.LSTR

local TutorialGuidePanelVM = LuaClass(UIViewModel)


---Ctor
function TutorialGuidePanelVM:Ctor()
    self.RichTextContent = nil
    self.TextTitle = nil
    self.GuideOpacity = nil
    self.NotSearchedVisible = false
    self.NotTutorialGuideVisble = false
    self.ContentVisible = true
    self.DropList = UIBindableList.New(TutorialGuideShowDropWinItemVM)   --- 内容的小点点
    self.GroupTableList = UIBindableList.New(TutorialGuideListItemVM) --二级分类的列表
    self.GroupTableListVisible = false
    self.GroupTableDataList = {}
    self.TreeViewSearchDataList = nil -- 搜索的数据列表
    self.TreeViewSearchList = UIBindableList.New(TutorialGuideListSearchItemVM)-- 搜索显示列表
    self.SearchListVisible = false
    self.DropListSelectIndex = nil
    self.SearchSelectIndex = nil
    self.TabSelectIndex = nil
    self.IsSearching = false
    self.SearchGuideID  = nil
    self.GuidePic = nil
    self.SpecShowPicShow = false
    self.SpecShowPic = nil

end

function TutorialGuidePanelVM:OnInit()
    self.GuideOpacity = 1
    self.GroupTableList:Clear()
    self.GroupTableDataList = {}
    self.TreeViewSearchDataList = {}
end

function TutorialGuidePanelVM:OnBegin()
end

function TutorialGuidePanelVM:OnEnd()
end 

function TutorialGuidePanelVM:OnShutdown()
end


function TutorialGuidePanelVM:UpdateGroupVisible()
    self.NotTutorialGuideVisble =  (not self.IsSearching) and not (table.length(self.GroupTableList.Items) > 0)
    self.ContentVisible = (table.length(self.GroupTableList.Items) > 0)
end

function TutorialGuidePanelVM:UpdateCurContent(ID, ContentIndex)
    local Cfg = GuideCfg:FindCfgByKey(ID)

    if Cfg == nil then
        return
    end

    self.ContentVisible = true
    
    local Content = Cfg.Content or {}
    if Cfg.Content == nil then
        _G.FLOG_ERROR(string.format("TutorialGuidePanelVM:Guide %s UpdateCurContent Content is Nil", tostring(ID)))
        return 
    end

    if ContentIndex == nil then
        ContentIndex = 1
    end

    self.TextTitle = Cfg.Title
    self.RichTextContent = Content[ContentIndex]
    self.GuidePic = Cfg.Picture[ContentIndex]
    local SpecPic = Cfg.SpecPicture

    if SpecPic[ContentIndex] and SpecPic[ContentIndex] ~= "" then
        self.SpecShowPic = SpecPic[ContentIndex]
        self.SpecShowPicShow = true
    else
        self.SpecShowPicShow = false
    end

    self.DropList:Clear()
    local DataList = {}
    for index, value in ipairs(Content) do
        local Data = TutorialGuideShowDropWinItemVM.New()
        table.insert(DataList, Data)
    end
    self.DropList:Update(DataList)
    self.DropListSelectIndex = 0
    self.DropListSelectIndex = ContentIndex

end

function TutorialGuidePanelVM:UpdateTabGroup(GroupID)
    local GuideCfgs = GuideCfg:FindAllGroupID(GroupID)

    if GroupID == 0 then
        GuideCfgs = GuideCfg:FindAllCfg()
    end

    local TempDataList = {}
    if self.GroupTableList ~= nil then
        self.GroupTableList:Clear()
    end

    local FinsihedIDList = TutorialGuideMgr:GetGuideTutorial()
    --判断是否已经在说明型引导里。
    
    if not table.is_nil_empty(FinsihedIDList) then
        for _, v in pairs(FinsihedIDList) do
            for Index, Cfg in ipairs(GuideCfgs) do
                if math.abs(v) == Cfg.GuideID then
                    Cfg.IsNew = v < 0
                    table.insert(TempDataList, Cfg)
                end
            end
        end
    end

    -- 全部
    if GroupID == 0 then
        local GroupTableDataList = {}
        for _, v in ipairs(TempDataList) do
            local Cfg =GuideCfg:FindCfgByKey(v.GuideID)
            if Cfg ~= nil then
                table.insert(GroupTableDataList, Cfg)
            end
        end

        table.sort(GroupTableDataList, self.SortListPredicate)

        for index, value in ipairs(GroupTableDataList) do
            local TempData1 = {}
            TempData1.Index = index
            TempData1.RealIndex = index
            TempData1.GuideID = value.GuideID
            TempData1.WidgetIndex = 1
            TempData1.Children = {}
            TempData1.Title = value.Title

            if not _G.TutorialGuideMgr:CheckIsRead(value.GuideID) then
                TempData1.TextNewVisible = true
                _G.TutorialGuideMgr:AddRedDot(value.GuideID)
            else
                TempData1.TextNewVisible = false
                _G.TutorialGuideMgr:DelRedDot(value.GuideID)
            end

            local TitleItemVM = TutorialGuideListItemVM.New()
            TitleItemVM:InitVM(TempData1)
            self.GroupTableList:Add(TitleItemVM)
        end
    else
        local GroupTableDataList = {}
        for _, v in ipairs(TempDataList) do
            local Cfg = GuideCfg:FindCfgByKey(v.GuideID)
            if Cfg ~= nil and not string.isnilorempty(Cfg.SubTitle) then
                local SubTitle = Cfg.SubTitle
                if table.is_nil_empty(GroupTableDataList[SubTitle]) then
                    GroupTableDataList[SubTitle] = {}
                end
                table.insert(GroupTableDataList[SubTitle], Cfg)
            end
        end
    
        -- 内部排序
        for _, value in pairs(GroupTableDataList) do
            table.sort(value, self.SortListPredicate)
        end

        local Index = 1
        local RealIndex = 1
        for subTitle, v in pairs(GroupTableDataList) do
            local TempData1 = {}
            TempData1.Index = 0
            TempData1.WidgetIndex = 0
            TempData1.Items = {}
            TempData1.Title = subTitle
            TempData1.RealIndex = RealIndex
            local ChildrenLen = 0
            for index, value in ipairs(v) do
                local TempItem = {}
                TempItem.Index = Index
                TempItem.RealIndex = TempData1.RealIndex + index
                TempItem.WidgetIndex = 1
                TempItem.Title = value.Title
                TempItem.GuideID = value.GuideID
                if not _G.TutorialGuideMgr:CheckIsRead(value.GuideID) then
                    TempItem.TextNewVisible = true
                    _G.TutorialGuideMgr:AddRedDot(value.GuideID)
                else
                    TempItem.TextNewVisible = false
                    _G.TutorialGuideMgr:DelRedDot(value.GuideID)
                end
                table.insert(TempData1.Items, TempItem)
                Index = Index + 1
                ChildrenLen = ChildrenLen + 1
            end

            RealIndex = RealIndex + ChildrenLen + 1
            local TitleItemVM = TutorialGuideListItemVM.New()
            TitleItemVM:InitVM(TempData1)
            self.GroupTableList:Add(TitleItemVM)
        end
    end
end

function TutorialGuidePanelVM:GetGroupTabListChildrenNum()
    local ChildrenNum = 0
    for _, v in ipairs(self.GroupTableList.Items) do
        for _, value in ipairs(v.ChildrenVM) do
            if value.Index ~= 0 then
                 ChildrenNum = ChildrenNum + 1
            end
        end
    end

    return ChildrenNum
end

function TutorialGuidePanelVM:Search(SearchText, Length)
    if Length <= 0 then
        self.TreeViewSearchList:Clear()
        self.NotSearchedVisible = false
        self.TabSelectIndex =  1
        return 
    end

    self.NotSearchedVisible = false
   
    self.TreeViewSearchDataList = {}
    self.TreeViewSearchList:Clear()

    local TitleResult = TutorialGuideMgr:SearchGuideTutorialTitle(SearchText)
    local ContentNewResult = TutorialGuideMgr:SearchGuideTutorialContent(SearchText)

   --- 创建一个以GuideID为键的表来避免重复
    local mergedResults = {}

    for _, item in ipairs(TitleResult) do
        if item ~= nil then
        item.Priority = 1
        mergedResults[item.GuideID] = item
        end
    end

    for _, item in ipairs(ContentNewResult) do
        if item ~= nil then
            if not mergedResults[item.GuideID] then
                item.Priority = 2
                mergedResults[item.GuideID] = item
            end
        end
    end

    --- 转换回列表
    local List = {}
    for _, item in pairs(mergedResults) do
        table.insert(List, item)
    end

    table.sort(List, function(a, b)
        if a.Priority ~= b.Priority then
            return a.Priority < b.Priority
        end
        return a.GuideID > b.GuideID 
    end)

    if table.length(List) <= 0 then
        self.NotTutorialGuideVisble = false
        self.NotSearchedVisible = true
        self.ContentVisible = false
        return 
    end

    self.NotSearchedVisible = false

    local CurID 
    for Index, Data in ipairs(List) do
        Data.Index = Index
        local GroupItemVM = TutorialGuideListSearchItemVM.New()
        if Index == 1 then
            CurID = Data.GuideID
           -- GroupItemVM.IsSelected = true
        else
            --GroupItemVM.IsSelected = false
        end
        GroupItemVM:UpdateItemInfo(Data)
        self.TreeViewSearchList:Add(GroupItemVM)
    end

    if CurID ~= nil then
        self.SearchGuideID = CurID
        self:UpdateCurContent(CurID)
        _G.EventMgr:SendEvent(_G.EventID.TutorialGuideIdChanged, { GuideIndex = self:GetGuideIndex(CurID), ContentIndex = 1}) 
    end

end

function TutorialGuidePanelVM:GetGuideID(GuideIndex)
    for _, v in ipairs(self.GroupTableList.Items) do
        if v.Index == GuideIndex then
            return v.GuideID
        end

        for _, value in ipairs(v.ChildrenVM) do
            if value.Index == GuideIndex then
                return value.GuideID
            end
        end
    end

    return nil
end

function TutorialGuidePanelVM:GetSearchingGuideID(GuideIndex)
    for _, v in ipairs(self.TreeViewSearchList.Items) do
        if v.Index == GuideIndex then
            return v.GuideID
        end
    end
end


function TutorialGuidePanelVM:GetGuideIndex(GuideID)
    for _, v in ipairs(self.GroupTableList.Items) do
        if v.GuideID == GuideID then
            return v.Index
        end

        for _, value in ipairs(v.ChildrenVM) do
            if value.GuideID == GuideID then
                return value.Index
            end
        end
    end

    return nil
end

function TutorialGuidePanelVM:GetItemRealIndex(GuideID)
    for _, v in ipairs(self.GroupTableList.Items) do
        if v.GuideID == GuideID then
            return v.RealIndex
        end

        for _, value in ipairs(v.ChildrenVM) do
            if value.GuideID == GuideID then
                return value.RealIndex
            end
        end
    end
end

function TutorialGuidePanelVM.SortListPredicate(Left, Right)
    if Left.IsNew ~= Right.IsNew then
        return Left.IsNew
    else
        return Left.GuideID < Right.GuideID
    end
end


return TutorialGuidePanelVM
