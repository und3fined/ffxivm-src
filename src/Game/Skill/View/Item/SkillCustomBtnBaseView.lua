local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local SkillCustomBtnBaseVM = require("Game/Skill/View/Item/SkillCustomBtnBaseVM")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local SkillCustomDefine = require("Game/Skill/SkillCustomDefine")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillCustomMgr = require("Game/Skill/SkillCustomMgr")
local EventID = require("Define/EventID")

local EventMgr         <const> = _G.EventMgr
local EButtonState     <const> = SkillCustomDefine.EButtonState
local TipsIDMap        <const> = SkillCustomDefine.TipsIDMap
local TipsID_SameIndex <const> = 106042  -- 相同栏位不可设置
local OneVector2D      <const> = UE.FVector2D(1, 1)



---@class SkillCustomBtnBaseView : UIView
local SkillCustomBtnBaseView = LuaClass(UIView, true)

function SkillCustomBtnBaseView:OnInit()
	self.VM = SkillCustomBtnBaseVM.New()
end

function SkillCustomBtnBaseView:OnShow()

end

function SkillCustomBtnBaseView:OnHide()

end

function SkillCustomBtnBaseView:OnRegisterUIEvent()

end

function SkillCustomBtnBaseView:OnRegisterGameEvent()

end

function SkillCustomBtnBaseView:OnScaleChanged(Scale)
	self:SetRenderScale(OneVector2D * Scale)
end

function SkillCustomBtnBaseView:SetSkillID(SkillID)
    local IconPath = SkillMainCfg:FindValue(SkillID, "Icon")
    if IconPath then
        self.VM.SkillIcon = IconPath
        self.BtnSkillID = SkillID
        return true
    end
    return false
end

function SkillCustomBtnBaseView:OnSkillReplace(LogicData, MapType)
    local bEditable = SkillCustomMgr:IsIndexEditable(self.ButtonIndex, MapType)
    self.VM.ButtonState = bEditable and EButtonState.Available or EButtonState.Unavailable
    self.bEditable = bEditable

    local SkillID = LogicData:GetBtnSkillID(self.ButtonIndex)
    return self:SetSkillID(SkillID)
end

function SkillCustomBtnBaseView:CheckEditable(bShowTips)
    if self.bEditable then
        return true
    end

    if bShowTips then
        local TipsID = TipsIDMap[self.ButtonIndex or -1]
        if TipsID then
            MsgTipsUtil.ShowTipsByID(TipsID)
        end
    end
    return false
end

function SkillCustomBtnBaseView:Select()
    self.bSelected = true
    self.VM.ButtonState = EButtonState.Selected
    SkillCustomMgr.CurrentSelectedIndex = self.ButtonIndex
    EventMgr:SendEvent(EventID.PlayerPrepareCastSkill, {
        Index = self.ButtonIndex,
        SkillID = self.BtnSkillID,
        bShowMultiSkill = true,
        })
end

function SkillCustomBtnBaseView:Unselect()
    self.bSelected = false
    self.VM.ButtonState = EButtonState.Available
    if SkillCustomMgr.CurrentSelectedIndex == self.ButtonIndex then
        SkillCustomMgr.CurrentSelectedIndex = nil
    end
end

function SkillCustomBtnBaseView:DragBegin(MouseEvent)
    self.bDragged = true
    self.VM.ButtonState = EButtonState.Dragged
    SkillCustomMgr.CurrentDraggedIndex = self.ButtonIndex

    local ParentView = self.ParentView
    -- 先调用一次Move, 防止偶现的位置更新1帧延迟
    ParentView:DragMove(MouseEvent)
    ParentView:DragBegin(self.ButtonIndex, self.BtnSkillID)
end

function SkillCustomBtnBaseView:DragEnd()
    self.bDragged = false
    self.VM.ButtonState = EButtonState.Available
    if SkillCustomMgr.CurrentDraggedIndex == self.ButtonIndex then
        SkillCustomMgr.CurrentDraggedIndex = nil
        self.ParentView:DragEnd()
    else
        FLOG_ERROR("[SkillCustomBtnBaseView:DragEnd] Unexpected ButtonIndex")
    end
end

function SkillCustomBtnBaseView:Hover()
    self.bHover = true
    self.VM.ButtonState = EButtonState.ReadyToChange
    SkillCustomMgr.CurrentHoveringIndex = self.ButtonIndex
end

function SkillCustomBtnBaseView:Unhover()
    self.bHover = false
    self.VM.ButtonState = EButtonState.Available
    if SkillCustomMgr.CurrentHoveringIndex == self.ButtonIndex then
        SkillCustomMgr.CurrentHoveringIndex = nil
    end
end

function SkillCustomBtnBaseView:PressBegin()
    SkillCustomMgr.CurrentPressedIndex = self.ButtonIndex
    self.bPressed = true
end

function SkillCustomBtnBaseView:PressEnd()
    self.bPressed = false
    if SkillCustomMgr.CurrentPressedIndex == self.ButtonIndex then
        SkillCustomMgr.CurrentPressedIndex = nil
        return true
    end
    return false
end

--region 鼠标事件

local NewObject          <const> = _G.NewObject
local FKey               <const> = UE.FKey
local WBL                <const> = UE.UWidgetBlueprintLibrary
local Unhandled          <const> = WBL.Unhandled()



function SkillCustomBtnBaseView:OnMouseCaptureLost()
    if not self.bDragged then
        self:OnMouseButtonUp()
    end
end

function SkillCustomBtnBaseView:OnDragEnter(MyGeometry, MouseEvent)
    local CurrentDraggedIndex = SkillCustomMgr.CurrentDraggedIndex
    if self.bEditable and CurrentDraggedIndex and CurrentDraggedIndex ~= self.ButtonIndex then
        self:Hover()
    end
end

function SkillCustomBtnBaseView:OnDragLeave(MouseEvent)
    if self.bHover then
        self:Unhover()
    end
end

function SkillCustomBtnBaseView:OnDrop(MyGeometry, PointerEvent, Operation)
    local DraggedView = Operation.DraggedView
    if not DraggedView then
        return false
    end
    if not self:CheckEditable(true) then
        return false
    end

    -- 尝试和悬停处的按钮交换
    local DraggedButtonIndex = DraggedView.ButtonIndex
    local CurrentHoveringIndex = self.ButtonIndex
    if CurrentHoveringIndex and CurrentHoveringIndex ~= DraggedButtonIndex then
        if not DraggedView:PressEnd() then
            return false
        end
        DraggedView:DragEnd()
        SkillCustomMgr:SwapEditingIndex(DraggedButtonIndex, CurrentHoveringIndex)
        return true
    end
    return false
end

function SkillCustomBtnBaseView:OnDragCancelled()
    self:PressEnd()
    -- 悬停处无有效按钮, 重新回到选中态
    self:DragEnd()
    self:Select()
end

function SkillCustomBtnBaseView:OnDragDetected(MyGeometry, MouseEvent, Operation)
    self:DragBegin(MouseEvent)
    local Class = SkillCustomMgr.DragOpClass
    if not Class then
        FLOG_ERROR("[SkillCustom] Cannot get drag drop op class.")
        return nil
    end
    Operation = NewObject(Class, self)
    Operation.DraggedView = self
    return Operation
end

function SkillCustomBtnBaseView:OnMouseButtonDown(MyGeometry, MouseEvent)
    if SkillCustomMgr.CurrentPressedIndex then
        return Unhandled
    end

    local Handled = WBL.Handled()
    self.VM.Scale = SkillCommonDefine.SkillBtnClickFeedback
    self:PressBegin()

    if not self.bDragged and self:CheckEditable() then
        Handled = WBL.DetectDragIfPressed(MouseEvent, self, FKey("LeftMouseButton"))
	end
    return WBL.CaptureMouse(Handled, self)
end

function SkillCustomBtnBaseView:OnMouseButtonUp(MyGeometry, MouseEvent)
    local Handled = WBL.Handled()
    local ButtonIndex = self.ButtonIndex
    self.VM.Scale = 1

    if not self.bPressed then
        return WBL.ReleaseMouseCapture(Handled)
    end
    self:PressEnd()

    if self:CheckEditable(true) then
        if self.bDragged then
            return WBL.ReleaseMouseCapture(Handled)
        end
        local CurrentSelectedIndex = SkillCustomMgr.CurrentSelectedIndex
        if CurrentSelectedIndex == nil then
            -- 进入选中态
            self:Select()
        else
            -- 和选中按钮交换
            if CurrentSelectedIndex == ButtonIndex then
                MsgTipsUtil.ShowTipsByID(TipsID_SameIndex)
            else
                SkillCustomMgr:SwapEditingIndex(ButtonIndex, CurrentSelectedIndex)
            end
        end
    end

    return WBL.ReleaseMouseCapture(Handled)
end

--endregion


return SkillCustomBtnBaseView