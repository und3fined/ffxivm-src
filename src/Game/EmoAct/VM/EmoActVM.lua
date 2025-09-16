local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local UIBindableList = require("UI/UIBindableList")
local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")


---@class EmoActVM : UIViewModel
local EmoActVM = LuaClass(UIViewModel)

---Ctor
function EmoActVM:Ctor()
	self:Reset()
end

function EmoActVM:OnInit()
end

function EmoActVM:OnBegin()
end

function EmoActVM:OnEnd()
end

function EmoActVM:OnShutdown()
end

function EmoActVM:Reset()
	self.ID = 0
	self.EmotionName = ""
	self.IconPath = ""
	self.MotionType = 0
	self.CanUse = nil
	self.IsBattleEmotion = false
	self.HasAnimPath = false
end

function EmoActVM:IsEqualVM(Value)
	if Value == nil then
		return false
	end

	return self.ID and self.ID > 0 and self.ID == Value.ID
end

function EmoActVM:UpdateVM(Value, Param)
	if Value then
		self.ID = Value.ID
		self.EmotionName = Value.EmotionName
		self.IconPath = Value.IconPath
		self.MotionType = Value.MotionType
		self.CanUse = Value.CanUse
		self.IsBattleEmotion = Value.IsBattleEmotion
		self.HasAnimPath = EmotionAnimUtils.IsEmotionHasAnim(Value)
	else
		self:Reset()
	end
end

return EmoActVM