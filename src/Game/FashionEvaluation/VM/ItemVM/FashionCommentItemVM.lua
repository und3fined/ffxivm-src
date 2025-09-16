--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:NPC评论ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")

---@class FashionCommentItemVMlua : UIViewModel
local FashionCommentItemVMlua = LuaClass(UIViewModel)

function FashionCommentItemVMlua:Ctor()
    self.NPCResID = 0
    self.NPCIcon = ""
    self.NPCName = ""
    self.NPCComment = ""
end


function FashionCommentItemVMlua:IsEqualVM(Value)
    return Value ~= nil and Value.NPCResID == self.NPCResID
end

function FashionCommentItemVMlua:GetKey()
    return self.NPCResID
end

function FashionCommentItemVMlua:UpdateVM(Value)
    self.NPCResID = Value.NPCResID
    self.NPCComment = Value.Comment
    self.NPCIcon = FashionEvaluationVMUtils.GetNPCHeadIcon(self.NPCResID)
    self.NPCName = Value.NPCName
end

return FashionCommentItemVMlua