---
--- Author: zimuyi
--- DateTime: 2024-09-02
--- Description: UI关卡管理
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local UE = _G.UE
local FLOG_INFO = _G.FLOG_INFO

---@class UILevelMgr : MgrBase
local UILevelMgr = LuaClass(MgrBase)

function UILevelMgr:OnInit()
	self.HoldLevelStreamingCount = 0
end

-- 开关关卡流送，计数值更新前/后为0时才会关闭/开启流送，务必成对调用
function UILevelMgr:SwitchLevelStreaming(bOn)
	if nil == self.HoldLevelStreamingCount then
		self.HoldLevelStreamingCount = 0
	end
	if bOn then
		self.HoldLevelStreamingCount = math.max(self.HoldLevelStreamingCount - 1, 0)
		if self.HoldLevelStreamingCount == 0 then
			UE.UWorldMgr.Get():SwitchLevelStreaming(bOn)
		end
	else
		if self.HoldLevelStreamingCount == 0 then
			UE.UWorldMgr.Get():SwitchLevelStreaming(bOn)
		end
		self.HoldLevelStreamingCount = self.HoldLevelStreamingCount + 1
	end
	FLOG_INFO(string.format("UILevelMgr: Switch %s level streaming. Current hold count is %d",
		bOn and "on" or "off", self.HoldLevelStreamingCount))
end

return UILevelMgr