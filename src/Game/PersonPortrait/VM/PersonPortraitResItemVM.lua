---
--- Author: xingcaicao
--- DateTime: 2025-03-20 16:16
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local PersonPortraitUtil = require("Game/PersonPortrait/PersonPortraitUtil")
local PortraitDesignCfg = require("TableCfg/PortraitDesignCfg")
local EmotionCfg = require("TableCfg/EmotionCfg")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")

local DesignerType = ProtoCommon.DesignerType

---@class PersonPortraitResItemVM : UIViewModel
local PersonPortraitResItemVM = LuaClass(UIViewModel)

---Ctor
function PersonPortraitResItemVM:Ctor( )
    self:Reset()
end

function PersonPortraitResItemVM:IsEqualVM(Value)
    return Value ~= nil and self.ID ~= nil and self.ID == Value.ID
end

function PersonPortraitResItemVM:Reset()
    self.ID = nil
    self.EmotionID = nil

    self.Name = nil 
    self.Type = DesignerType.DesignerType_None 
    self.UnlockType = nil
    self.UnlockValue = nil
    self.UnlockDesc = nil 


    self.UnknownUnlockValue = nil
    self.UnknownDesc = nil 

    self.BgID = nil
    self.DecorationID = nil
    self.FrameID = nil

    self.BgIcon = nil 
    self.DecorationIcon = nil
    self.FrameIcon = nil
    self.EmotionIcon = nil

    self.RedDotID = nil 

    self.IsOwned = false -- 是否已获取
    self.IsUnknown = false  -- 是否处于防剧透状态
    self.ImgUnlockVisible = false
    self.ImgSecretVisible = false
end

function PersonPortraitResItemVM:UpdateVM(Value)
    self:Reset()

    if nil == Value.TypeID then
        self:UpdateVMByPredesign(Value)
    else
        self:UpdateVMByDesign(Value)
    end
end

---更新数据（肖像预设配置）
function PersonPortraitResItemVM:UpdateVMByPredesign(Value)
    self.Type   = DesignerType.DesignerType_Predict
    self.IsOwned = Value.IsOwned 

    local CfgData = Value.CfgData

    self.ID = CfgData.ID

    -- 背景
    local BgID = CfgData.BgID
    local Icon = PortraitDesignCfg:GetIcon(BgID)
    if not string.isnilorempty(Icon) then
        self.BgID = BgID 
        self.BgIcon = PersonPortraitUtil.GetDesignIconPath(Icon)
    end

    -- 装饰
    local DecorationID = CfgData.DecorationID 
    Icon = PortraitDesignCfg:GetIcon(DecorationID)
    if not string.isnilorempty(Icon) then
        self.DecorationID = DecorationID 
        self.DecorationIcon = PersonPortraitUtil.GetDesignIconPath(Icon)
    end

    -- 装饰框
    local FrameID = CfgData.FrameID 
    Icon = PortraitDesignCfg:GetIcon(FrameID)
    if not string.isnilorempty(Icon) then
        self.FrameID = FrameID 
        self.FrameIcon = PersonPortraitUtil.GetDesignIconPath(Icon)
    end

    self.Name = self.ImgSecretVisible and "？？？？" or CfgData.Name
    self.RedDotID = nil 
end

---更新数据（肖像装饰设计配置）
function PersonPortraitResItemVM:UpdateVMByDesign(Value)
    local CfgData = Value.CfgData
    local ID = CfgData.ID

    self.ID             = ID
    self.UnlockType     = CfgData.UnlockType
    self.UnlockValue    = CfgData.UnlockValue 
    self.UnlockDesc     = CfgData.UnlockDesc 

    self.UnknownUnlockValue = CfgData.UnknownUnlockValue
    self.UnknownDesc = CfgData.UnknownDesc

    local IsOwned = Value.IsOwned
    self.IsOwned = IsOwned 

    local IsUnknown = Value.IsUnknown
    self.IsUnknown = IsUnknown

    self.ImgUnlockVisible = not IsOwned and not IsUnknown 
    self.ImgSecretVisible = not IsOwned and IsUnknown

    local Icon = PersonPortraitUtil.GetDesignIconPath(CfgData.Icon)
    local Type = Value.TypeID or DesignerType.DesignerType_None
    self.Type = Type 

    if Type == DesignerType.DesignerType_BackGround then -- 背景
        self.BgID = ID 
        self.BgIcon = Icon

    elseif Type == DesignerType.DesignerType_Decoration then -- 装饰
        self.DecorationID = ID 
        self.DecorationIcon = Icon

    elseif Type == DesignerType.DesignerType_Decoration_Frame then -- 装饰框
        self.FrameID = ID 
        self.FrameIcon = Icon

    elseif Type == DesignerType.DesignerType_Action or Type == DesignerType.DesignerType_Emotion then -- 动作、表情
        local EmotionID = CfgData.EmotionID
        self.EmotionID = EmotionID

        local Cfg = EmotionCfg:FindCfgByKey(EmotionID) or {}
        local IconName = Cfg.IconPath
        self.EmotionIcon = string.isnilorempty(IconName) and "" or EmotionUtils.GetEmoActIconPath(IconName)
    end

    self.Name = self.ImgSecretVisible and "？？？？" or CfgData.Name
    self.RedDotID = CfgData.RedDotID 
end

return PersonPortraitResItemVM