
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ChocoboInfoAttrItemStarVM = require("Game/Chocobo/Life/VM/ChocoboInfoAttrItemStarVM")
local ChocoboMgr = nil

---@class ChocoboBreedInfoItemVM : UIViewModel
local ChocoboBreedInfoItemVM = LuaClass(UIViewModel)

---Ctor
function ChocoboBreedInfoItemVM:Ctor()
    ChocoboMgr = _G.ChocoboMgr  
    self.AttrIconPath = nil  
    self.ShowStar = true
    self.BlueStarTableView = UIBindableList.New(ChocoboInfoAttrItemStarVM)
    self.RedStarTableView = UIBindableList.New(ChocoboInfoAttrItemStarVM)
end

function ChocoboBreedInfoItemVM:OnInit()
end

function ChocoboBreedInfoItemVM:Clear()
    self:CloseTimer()
end

function ChocoboBreedInfoItemVM:UpdateVM(Data)
    if Data == nil then return end

    self.AttrIconPath = Data.AttrIconPath
    
    self.DataInfo = Data
    self.ShowStar = false
    self:CreateTimer()
end

function ChocoboBreedInfoItemVM:CreateTimer()
    self:CloseTimer()
    self.StarTimer = _G.TimerMgr:AddTimer(self, self.UpdateStar, 0, 0.5, -1)
end

-- 关闭定时器
function ChocoboBreedInfoItemVM:CloseTimer()
    if self.StarTimer ~= nil then
        _G.TimerMgr:CancelTimer(self.StarTimer)
        self.StarTimer = nil
    end
end

function ChocoboBreedInfoItemVM:IsEqualVM(Value)
    return Value ~= nil and Value.ID == self.ID
end

function ChocoboBreedInfoItemVM:UpdateStar()
    self.ShowStar = not self.ShowStar
    local RedData = {}
    for i = 1,self.DataInfo.GeneRed.Min do 
        local TempData = {}
        if self.DataInfo.GeneRed.Min > ChocoboMgr.GeneMaxStarNum then
            TempData.IsShwoImgStarM = true
        else
            TempData.IsShwoImgStarM = false 
        end
        TempData.IsShwoImgStarS = true
        table.insert(RedData, TempData)
    end

    for i = self.DataInfo.GeneRed.Min+1,self.DataInfo.GeneRed.Max do 
        local TempData = {}
        TempData.IsShwoImgStarM = false
        TempData.IsShwoImgStarS = self.ShowStar
        table.insert(RedData, TempData)
    end

    for i = self.DataInfo.GeneRed.Max+1,ChocoboMgr.GeneMaxStarNum do 
        local TempData = {}
        TempData.IsShwoImgStarM = false
        TempData.IsShwoImgStarS = false
        table.insert(RedData, TempData)
    end
    self.RedStarTableView:UpdateByValues(RedData)

    local BlueData = {}
    for i = 1,self.DataInfo.GeneBlue.Min do 
        local TempData = {}
        if self.DataInfo.GeneBlue.Min > ChocoboMgr.GeneMaxStarNum then
            TempData.IsShwoImgStarM = true
        else
            TempData.IsShwoImgStarM = false 
        end
        TempData.IsShwoImgStarS = true
        table.insert(BlueData, TempData)
    end

    for i = self.DataInfo.GeneBlue.Min+1,self.DataInfo.GeneBlue.Max do 
        local TempData = {}
        TempData.IsShwoImgStarM = false
        TempData.IsShwoImgStarS = self.ShowStar
        table.insert(BlueData, TempData)
    end

    for i = self.DataInfo.GeneBlue.Max+1,ChocoboMgr.GeneMaxStarNum do 
        local TempData = {}
        TempData.IsShwoImgStarM = false
        TempData.IsShwoImgStarS = false
        table.insert(BlueData, TempData)
    end
    self.BlueStarTableView:UpdateByValues(BlueData)
end

return ChocoboBreedInfoItemVM