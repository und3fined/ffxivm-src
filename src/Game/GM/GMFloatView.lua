---
--- Author: Administrator
--- DateTime: 2023-11-13 19:56
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

---@class GMFloatView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonCard UFButton
---@field ButtonGM UFButton
---@field AudioEventViewer UMG_WWiseEventViewer_C
---@field DragOffset Vector2D
---@field DragedWidget UserWidget
---@field IsCanDrag bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMFloatView = LuaClass(UIView, true)

function GMFloatView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.ButtonCard = nil
    -- self.ButtonGM = nil
    -- self.AudioEventViewer = nil
    -- self.DragOffset = nil
    -- self.DragedWidget = nil
    -- self.IsCanDrag = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMFloatView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMFloatView:OnInit()

end

function GMFloatView:OnDestroy()

end

function GMFloatView:OnShow()

end

function GMFloatView:OnHide()

end

function GMFloatView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.ButtonGM, self.OnButtonGM)
end

function GMFloatView:OnButtonGM()
    -- 临时功能 打开GM界面
    if UIViewMgr:IsViewVisible(UIViewID.GMMain) then
        UIViewMgr:HideView(UIViewID.GMMain)
    else
        UIViewMgr:ShowView(UIViewID.GMMain)
    end
end

function GMFloatView:OnRegisterGameEvent()

end

function GMFloatView:OnRegisterBinder()

end

return GMFloatView
