---
--- Author: user
--- DateTime: 2023-03-03 10:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")

---@class JumboCactpotRecordListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_SelfBar UFImage
---@field Text_WinnerName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotRecordListItemView = LuaClass(UIView, true)

function JumboCactpotRecordListItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.FImg_SelfBar = nil
    --self.Text_WinnerName = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotRecordListItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotRecordListItemView:OnInit()
    self.MajorID = MajorUtil.GetMajorRoleID()
end

function JumboCactpotRecordListItemView:OnDestroy()
end

function JumboCactpotRecordListItemView:OnShow()
    local Data = self.Params.Data
    if nil == Data then
        return
    end
    self.Text_WinnerName:SetText(Data.Nickname)
    UIUtil.SetIsVisible(self.FImg_SelfBar, Data.RoleId == self.MajorID and true or false)
end

function JumboCactpotRecordListItemView:OnHide()
end

function JumboCactpotRecordListItemView:OnRegisterUIEvent()
end

function JumboCactpotRecordListItemView:OnRegisterGameEvent()
end

function JumboCactpotRecordListItemView:OnRegisterBinder()
end

return JumboCactpotRecordListItemView
