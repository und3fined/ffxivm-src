local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BuddyColorCfg = require("TableCfg/BuddyColorCfg")
local RichTextUtil = require("Utils/RichTextUtil")

local BuddyMgr
---@class BuddySurfaceStainVM : UIViewModel
local BuddySurfaceStainVM = LuaClass(UIViewModel)

---Ctor
function BuddySurfaceStainVM:Ctor()
	BuddyMgr = _G.BuddyMgr
	self.ColorNameText = nil
end

function BuddySurfaceStainVM:UpdateVM(TargetColorID)
	local BuddyColor = BuddyMgr:GetSurfaceColor()
	if BuddyColor then
		local ColorCfg = BuddyColorCfg:FindCfgByKey(BuddyColor.RGB)
		local TargetColorCfg = BuddyColorCfg:FindCfgByKey(TargetColorID)
		if ColorCfg and TargetColorCfg then
			local CurRichText = RichTextUtil.GetText(string.format("%s", ColorCfg.Name), "d1ba81", 0, nil)
			local TargetRichText = RichTextUtil.GetText(string.format("%s", TargetColorCfg.Name), "d1ba81", 0, nil)
    		self.ColorNameText =  StringTools.Format(_G.LSTR(1000026), CurRichText, TargetRichText)
		end
	end

end

--要返回当前类
return BuddySurfaceStainVM