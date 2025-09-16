local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local PhotoDarkEdgeVM = LuaClass(UIViewModel)
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")

function PhotoDarkEdgeVM:Ctor()
    self.RedValue = nil
	self.GreenValue = nil
	self.BlueValue = nil
    self.VignettingA = nil
    self.VignettingG = nil
    self.VignettingB  = nil

    self.Aspect = 1
    self.Power = 0

    self.ResetOPFlag = false

    self.OffInfo = {
        Rad = 450,
        Asp = 1,
    }
end

function PhotoDarkEdgeVM:SetRedValue(Value)
    self.RedValue = Value
end

function PhotoDarkEdgeVM:SetGreenValue(Value)
    self.GreenValue = Value
end

function PhotoDarkEdgeVM:SetBlueValue(Value)
    self.BlueValue = Value
end

function PhotoDarkEdgeVM:ResetEdge()
    self.ResetOPFlag = true
    self:ResetDarkEdgeParam()
end

function PhotoDarkEdgeVM:SetDarkEdgeSize(OffsetX, OffsetY)
    --_G.FLOG_INFO('PhotoDarkEdgeVM:SetDarkEdgeSize OffsetX = ' .. tostring(OffsetX) .. " OffsetY = " .. tostring(OffsetY))
    local ScreenSize = UIUtil.GetScreenSize()
    self.VignettingA =  OffsetX * 10 
    self.VignettingG = (OffsetY * 10) * (ScreenSize.Y / ScreenSize.X)
    self.VignettingB = 0

   --_G.FLOG_INFO('PhotoDarkEdgeVM:SetDarkEdgeSize VignettingA = ' .. tostring(self.VignettingA) .. " VignettingG = " .. tostring(self.VignettingG).. " VignettingB = " .. tostring(self.VignettingB))
end

function PhotoDarkEdgeVM:ResetDarkEdgeParam()
    self.VignettingA = 0
    self.VignettingG = 0
    self.VignettingB = 0
    self.RedValue = 0
    self.GreenValue = 0
    self.BlueValue = 0

    self.Aspect = 1
    self.Power = 0

    self.OffInfo = {
        Rad = 450,
        Asp = 1,
    }
end

-------------------------------------------------------------------------------------------------------
---@region template setting

function PhotoDarkEdgeVM:TemplateSave(InTemplate)
    PhotoTemplateUtil.SetMask(
        InTemplate, 
        self.OffInfo.Rad,
        self.OffInfo.Asp,
        self.Aspect,
        self.Power,
        self.VignettingA,
        self.VignettingG,
        self.VignettingB,
        self.RedValue,
        self.GreenValue,
        self.BlueValue
    )
end

function PhotoDarkEdgeVM:TemplateApply(InTemplate)
    local Info = PhotoTemplateUtil.GetMask(InTemplate)
    -- _G.FLOG_INFO('[Photo][PhotoCamVM][TemplateApply] Info = ' .. table.tostring(Info))
    if Info then
        self.OffInfo = {
            Rad = InTemplate.Rad,
            Asp = InTemplate.Asp,
        }
        
        self.Aspect = Info.Aspect
        self.Power = Info.Power
        self.VignettingA = Info.VignettingA
        self.VignettingG = Info.VignettingG
        self.VignettingB = Info.VignettingB
        self.RedValue = Info.RedValue
        self.GreenValue = Info.GreenValue
        self.BlueValue = Info.BlueValue

        self.ResetOPFlag = false
	    _G.PhotoMgr:UpdateDarkEdgeEffect()
    end
end

return PhotoDarkEdgeVM