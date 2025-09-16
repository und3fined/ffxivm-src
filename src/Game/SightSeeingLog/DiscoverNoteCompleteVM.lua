---
--- Author: Alex
--- DateTime: 2024-03-11 11:09:30
--- Description: 探索笔记完成界面VM
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local DiscoverNoteDefine = require("Game/SightSeeingLog/DiscoverNoteDefine")
local TextureColoredColorParam = DiscoverNoteDefine.TextureColoredColorParam
local TextureGreyColorParam = DiscoverNoteDefine.TextureGreyColorParam
local TextureColoredOpacityParam = DiscoverNoteDefine.TextureColoredOpacityParam
local TextureGreyOpacityParam = DiscoverNoteDefine.TextureGreyOpacityParam
local NoteUnlockType = DiscoverNoteDefine.NoteUnlockType

---@class DiscoverNoteCompleteVM : UIViewModel
local DiscoverNoteCompleteVM = LuaClass(UIViewModel)

---Ctor
function DiscoverNoteCompleteVM:Ctor()
    -- Main Part
    self.ItemID = 0
    self.NoteName = ""
    self.ImgPath = ""
    self.NoteContent = ""
    self.RegionName = ""
    self.MapName = ""

    -- 二期内容
    self.CompleteState = NoteUnlockType.Locked

    -- Texture参数
    self.Color = nil
    self.Opacity = nil
    self.Int = nil
    self.Tint = nil
end

function DiscoverNoteCompleteVM:UpdateVM(Value)
    self.ItemID = Value.NoteItemID
    self.NoteName = Value.NoteName
    self.ImgPath = Value.ImgPath
    self.NoteContent = Value.NoteContent
    self.RegionName = Value.RegionName
    self.MapName = Value.MapName

    local UnlockType = Value.CompleteState
    self.CompleteState = UnlockType

    self:SetLeftPhotoTextureParams(UnlockType == NoteUnlockType.PerfectUnlock)
end

function DiscoverNoteCompleteVM:SetLeftPhotoTextureParams(bPerfectComplete)
    if bPerfectComplete then
        self.Color = TextureColoredColorParam.Color
        self.Opacity = TextureColoredOpacityParam.Opacity
        self.Int = TextureColoredColorParam.Int
        self.Tint = TextureColoredColorParam.Tint
    else
        self.Color = TextureGreyColorParam.Color
        self.Opacity = TextureGreyOpacityParam.Opacity
        self.Int = TextureGreyColorParam.Int
        self.Tint = TextureGreyColorParam.Tint
    end
end

return DiscoverNoteCompleteVM
