---
--- Author: sammrli
--- DateTime: 2025-01-13 18:37
--- Description:
---

local LuaClass = require("Core/LuaClass")
local CommMsgBoxNewView = require("Game/Common/Tips/CommMsgBoxNewView")

---@class CommMsgBoxMustClickView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnItem UFButton
---@field CheckBoxNoReminder CommSingleBoxView
---@field Comm58Slot CommBackpack58SlotView
---@field CommonTips CommonTipsView
---@field Icon UFImage
---@field ImgSpent UFImage
---@field LeftBtnOp CommBtnLView
---@field LeftBtnThreeOp CommBtnMView
---@field MiddleBtnThreeOp CommBtnMView
---@field Panel2Btns UFHorizontalBox
---@field Panel3Btns UCanvasPanel
---@field PanelConsume UFHorizontalBox
---@field PanelSpent UFHorizontalBox
---@field PopUpBG CommonPopUpBGView
---@field RichTextBoxDesc URichTextBox
---@field RichTextBoxTitle URichTextBox
---@field RichTextExtraHint URichTextBox
---@field RightBtnOp CommBtnLView
---@field RightBtnThreeOp CommBtnMView
---@field SpacerMid USpacer
---@field TextQuantity URichTextBox
---@field TextSpentTotal UFTextBlock
---@field Textconsume UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommMsgBoxMustClickView = LuaClass(CommMsgBoxNewView, true)

return CommMsgBoxMustClickView