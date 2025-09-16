---
--- Author: xingcaicao
--- DateTime: 2023-04-13 19:40
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local HeadFrameCfg = require("TableCfg/HeadFrameCfg")


---@class PersonInfoPortraitFrameVM : UIViewModel
local PersonInfoPortraitFrameVM = LuaClass(UIViewModel)

---Ctor
function PersonInfoPortraitFrameVM:Ctor( )
    self.FrameResID = nil
    self.CanUnlock = false
    self.IsSelt = false
    self.IsUnlock = true
    self.FrameIcon = ""
    self.FrameName = ""
    self.FrameDesc = ""
    self.PropID = nil
    self.UnlockType = nil
    self.IsInUse = false
    self.IsShowLockIcon = false
end

function PersonInfoPortraitFrameVM:IsEqualVM( Value )
    return Value ~= nil and self.FrameResID ~= nil and self.FrameResID == Value.FrameResID
end

function PersonInfoPortraitFrameVM:UpdateVM( Value )
	self.FrameResID     = Value.FrameResID
    self.IsUnlock       = Value.IsUnlock
    self.IsShowLockIcon = not self.IsUnlock 

    self.IsInUse        = _G.PersonPortraitHeadMgr:IsHeadFrameInUse(self.FrameResID)
    local Cfg = Value.CfgData

    local BagMgr = _G.BagMgr

    if Cfg then
        self.FrameIcon = Cfg.FrameIcon
        self.FrameName = Cfg.FrameName
        self.FrameDesc = Cfg.Description
        self.UnlockType = Cfg.UnlockType
        self.FrameType = Cfg.FrameType
        self.Access     = Cfg.Access or ""
        self.Remian     = 0
        if (not self.IsUnlock) and Cfg.ItemID then
            local GID = BagMgr:GetItemGIDByResID(Cfg.ItemID)
            if GID then
                self.PropID = GID
                self.CanUnlock = true
                self.IsShowLockIcon = false
                return
            end
        end
        self.PropID    = nil
        self.CanUnlock = false
    end
end

function PersonInfoPortraitFrameVM:UpdInUse()
    self.IsInUse        = _G.PersonPortraitHeadMgr:IsHeadFrameInUse(self.FrameResID)
end

return PersonInfoPortraitFrameVM