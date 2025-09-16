local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PhotoFilterVM = LuaClass(UIViewModel)

-- local ItemVM = require("Game/Item/ItemVM")

local LSTR = _G.LSTR

local PhotoMgr

local UIBindableList = require("UI/UIBindableList")
local PhotoFilterItemVM = require("Game/Photo/ItemVM/PhotoFilterItemVM")
local PhotoFilterCfg = require("TableCfg/PhotoFilterCfg")
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")


function PhotoFilterVM:Ctor()
    self.FilterIdx = -1
    self.FilterAlpha = 1
    self.FilterAlphaText = 100
    self.FilterAlphaMap = {}
    self.IsShowAngPanel = false
    self.CurID = nil
end

function PhotoFilterVM:OnInit()
end

function PhotoFilterVM:OnBegin()
    PhotoMgr = _G.PhotoMgr
    self.FilterList = UIBindableList.New(PhotoFilterItemVM)
end

function PhotoFilterVM:OnEnd()
end

function PhotoFilterVM:OnShutdown()
end

function PhotoFilterVM:UpdateVM()
    self.FilterAlphaMap = {}
    self:UpdFilterList()
    self:SetFilterIdx(nil)
end

function PhotoFilterVM:UpdFilterList()
    self.ListData = {}
    local AllCfg = PhotoFilterCfg:FindAllCfg()
    for _, Cfg in pairs(AllCfg or {}) do
        -- if not Cfg.Hide then
            table.insert(self.ListData, {ID = Cfg.ID, DefaultAlpha = Cfg.DefaultAlpha / 100})
        -- end
    end

    self.FilterList:UpdateByValues(self.ListData)
end

function PhotoFilterVM:OnTimer()
end

function PhotoFilterVM:SetFilterIdx(V)
    self.CurFilterIdx = V
    if not V then
        PhotoMgr:CheckAndHdlCloseFilter()
        self.IsShowAngPanel = false
        self.CurID = nil
        return
    end

    self.IsShowAngPanel = true

    local Item = self.FilterList:Get(V)

    if Item then
        PhotoMgr:HdlFilter(Item.ID, true)
        self.CurID = Item.ID
    end

    local Alpha = self.FilterAlphaMap[self.CurFilterIdx] or (self.ListData[self.CurFilterIdx] or {}).DefaultAlpha or 1

    self:SetFilterAlpha(Alpha)
end

--- Filter Alpha

function PhotoFilterVM:SetFilterAlpha(V)
    self.FilterAlpha = V
    self.FilterAlphaText = math.ceil((tonumber(V) or 0)*100)

    if self.CurFilterIdx then
        self.FilterAlphaMap[self.CurFilterIdx] = V
    end
    PhotoMgr:SetFilterAlpha(V)
end

-------------------------------------------------------------------------------------------------------
---@region template setting

function PhotoFilterVM:TemplateSave(InTemplate)
    PhotoTemplateUtil.SetFilter(InTemplate, self.CurFilterIdx)
end

function PhotoFilterVM:TemplateApply(InTemplate)
    local Info = PhotoTemplateUtil.GetFilter(InTemplate)
    if Info then
        local FilterIdx = Info.ID

        if FilterIdx and FilterIdx ~= 0 then
            self:SetFilterIdx(FilterIdx)
        end
    end
end

return PhotoFilterVM