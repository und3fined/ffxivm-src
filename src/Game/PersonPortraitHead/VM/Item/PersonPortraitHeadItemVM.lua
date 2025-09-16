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

---@class PersonPortraitHeadItemVM : UIViewModel
local PersonPortraitHeadItemVM = LuaClass(UIViewModel)

---Ctor
function PersonPortraitHeadItemVM:Ctor( )
	self.HeadResID = nil 
    self.HeadIcon = ""
    self.IsSelt = false
    self.IsInUse = false
    self.HeadType = PersonPortraitHeadDefine.HeadType.Default
    self.Idx = nil
    self.HeadName = ""
    -- 统一默认/自定义头像的操作Key
    self.OptKey = nil
end

function PersonPortraitHeadItemVM:IsEqualVM( Value )
    return Value ~= nil and self.HeadResID ~= nil and self.HeadResID == Value.HeadResID
end

function PersonPortraitHeadItemVM:UpdateVM( Value )
    self.Idx = Value.HeadIdx
    self.OptKey = self.Idx
	self.HeadResID = Value.HeadResID
    self.HeadIcon = Value.HeadIcon
    self.HeadName = Value.HeadName
    self.IsInUse = _G.PersonPortraitHeadMgr:IsInUseHead(self.Idx, self.HeadType)
end

return PersonPortraitHeadItemVM