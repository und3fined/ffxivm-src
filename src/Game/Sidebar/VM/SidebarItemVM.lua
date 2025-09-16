---
--- Author: xingcaicao
--- DateTime: 2023-06-30 15:08:05
--- Description: 侧边栏Item ViewModel
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SidebarCfg = require("TableCfg/SidebarCfg")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")

---@class SidebarItemVM : UIViewModel
local Class = LuaClass(UIViewModel)

local DefaultPriority = 999
local DefaultShowTime = 15

---Ctor
function Class:Ctor()
    self.Type       = nil
    self.TypeName   = ""
    self.Priority   = DefaultPriority 
    self.StartTime  = 0 
    self.CountDown  = 0 
    self.Tips       = ""
    self.Text2      = ""
    self.Icon       = nil
    self.ItemBg     = SidebarDefine.DefaultItemBg

    self.TransData = nil --透传数据

    self.LoopAnimName = nil
end

function Class:IsEqualVM( Value )
	return nil ~= Value and Value.Type == self.Type
end

function Class:UpdateVM( Value )
    local Type = Value.Type

    self.Type               = Type
    self.StartTime          = Value.StartTime or 0
    self.Tips               = Value.Tips or ""
    self.LoopAnimName       = Value.LoopAnimName 

    local ShowTime = Value.CountDown or 0
	local Cfg = SidebarCfg:FindCfgByKey(Type)
    if Cfg then
        self.TypeName   = Cfg.TypeName or ""
        self.Priority   = Cfg.Priority or DefaultPriority
        self.Icon       = Cfg.Icon
        self.ItemBg     = Cfg.BG or SidebarDefine.DefaultItemBg

        ShowTime = ShowTime > 0 and ShowTime or (Cfg.ShowTime or 0)
    end

    self.TransData = Value.TransData 
    self.CountDown = ShowTime 
end

function Class:SetTips( Tips )
    self.Tips = Tips
end

function Class:SetLoopAnimName( Name )
    self.LoopAnimName = Name
end

return Class