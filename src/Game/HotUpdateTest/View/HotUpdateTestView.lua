---
--- Author: loiafeng
--- DateTime: 2025-03-21 19:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class HotUpdateTestView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Common_CloseBtn_UIBP CommonCloseBtnView
---@field EnumTest UFTextBlock
---@field LevelLogicTest UFTextBlock
---@field StructTest UFTextBlock
---@field TableTest UFTextBlock
---@field DefaultStruct SHotUpdateTest
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HotUpdateTestView = LuaClass(UIView, true)

function HotUpdateTestView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Common_CloseBtn_UIBP = nil
	--self.EnumTest = nil
	--self.LevelLogicTest = nil
	--self.StructTest = nil
	--self.TableTest = nil
	--self.DefaultStruct = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HotUpdateTestView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_CloseBtn_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HotUpdateTestView:OnInit()

end

function HotUpdateTestView:OnDestroy()

end

function HotUpdateTestView:OnShow()
	-- 关卡逻辑测试
	local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
	if MapEditCfg and MapEditCfg.MapID == 5015 then  -- 伊芙利特
		for _, BirthPoint in ipairs(MapEditCfg.BirthPointList) do
			if BirthPoint.ID == 2100001 then
				self.LevelLogicTest:SetText("Level Logic: OK!!")
			end
		end
	end
end

function HotUpdateTestView:OnHide()

end

function HotUpdateTestView:OnRegisterUIEvent()

end

function HotUpdateTestView:OnRegisterGameEvent()

end

function HotUpdateTestView:OnRegisterBinder()

end

return HotUpdateTestView