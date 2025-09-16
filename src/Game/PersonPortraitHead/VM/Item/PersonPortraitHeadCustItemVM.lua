---
--- Author: xingcaicao
--- DateTime: 2023-04-17 15:42
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local PersonPortraitHeadDefine = require("Game/PersonPortraitHead/PersonPortraitHeadDefine")

local LSTR = _G.LSTR

---@class PersonPortraitHeadCustItemVM : UIViewModel
local PersonPortraitHeadCustItemVM = LuaClass(UIViewModel)

---Ctor
function PersonPortraitHeadCustItemVM:Ctor( )
	self.HeadCustID = nil 
    self.HeadIcon   = nil 
    self.IsInUse      = false
    self.IsEmpty    = false
    self.HeadIconUrl = ""
    self.IsSelt = false
    self.HeadType = PersonPortraitHeadDefine.HeadType.Custom
    self.Idx = nil

    -- 统一默认/自定义头像的操作Key
    self.OptKey = nil
end

function PersonPortraitHeadCustItemVM:IsEqualVM( Value )
    return Value ~= nil and self.HeadCustID ~= nil and self.HeadCustID == Value.HeadCustID
end

function PersonPortraitHeadCustItemVM:UpdateVM( Value )
    self.Idx = Value.Idx
    self.HeadIconUrl = Value.HeadUrl

    if Value.IsHistory then
        self.IsInUse = false
        return
    end

    if Value.HeadCustID then
        self.IsEmpty = false
        self.HeadCustID = Value.HeadCustID
        self.HeadIcon   = nil 
        self.IsInUse = _G.PersonPortraitHeadMgr:IsInUseHead(self.HeadCustID, self.HeadType)
        self.OptKey = self.HeadCustID
    else
        self.IsEmpty = true
        self.IsInUse = false
        self.HeadIconUrl = ''
        self.IsSelt = false
        self.OptKey = nil
        self.HeadCustID = -1
    end
end

return PersonPortraitHeadCustItemVM