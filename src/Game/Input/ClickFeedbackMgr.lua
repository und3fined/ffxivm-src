--- 点击反馈 管理器
--- Author: xingcaicao
--- DateTime: 2022-11-25 12:48
--- Description:

local MgrBase = require("Common/MgrBase")
local LuaClass = require("Core/LuaClass")

local ClickFeedbackMgr = LuaClass(MgrBase)

function ClickFeedbackMgr:OnInit()
end

function ClickFeedbackMgr:OnBegin()
    _G.UE.ClickFeedbackInteraction.Get():RegisterInputPreProcessorForLua()
end

function ClickFeedbackMgr:OnEnd()
    _G.UE.ClickFeedbackInteraction.Get():UnRegisterInputPreProcessorForLua()
end

function ClickFeedbackMgr:OnShutdown()
end

function ClickFeedbackMgr:OnRegisterGameEvent()
end

---------------------------------------------------------------------------------------------
--- c++ 回调函数

function ClickFeedbackMgr.OnPreprocessedMouseButtonDown(MouseEvent)
	_G.EventMgr:SendEvent(_G.EventID.PreprocessedMouseButtonDown, MouseEvent)
end

function ClickFeedbackMgr.OnPreprocessedMouseButtonUp(MouseEvent)
    _G.EventMgr:SendEvent(_G.EventID.PreprocessedMouseButtonUp, MouseEvent)
end

function ClickFeedbackMgr.OnPreprocessedMouseMove(MouseEvent)
    _G.EventMgr:SendEvent(_G.EventID.PreprocessedMouseMove, MouseEvent)
end

return ClickFeedbackMgr