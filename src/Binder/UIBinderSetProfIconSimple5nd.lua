local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local ProtoCommon = require("Protocol/ProtoCommon")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

local RoleClassIconCfg = {
	[ProtoCommon.class_type.CLASS_TYPE_NULL] = "UI_Icon_Job_Img_White"; -- 其他
	[ProtoCommon.class_type.CLASS_TYPE_TANK] = "UI_Icon_Job_Img_Blue"; -- 坦克
	[ProtoCommon.class_type.CLASS_TYPE_NEAR] = "UI_Icon_Job_Img_Red"; -- 近战
	[ProtoCommon.class_type.CLASS_TYPE_FAR] = "UI_Icon_Job_Img_Red"; -- 远程
	[ProtoCommon.class_type.CLASS_TYPE_MAGIC] = "UI_Icon_Job_Img_Red"; -- 魔法
	[ProtoCommon.class_type.CLASS_TYPE_HEALTH] = "UI_Icon_Job_Img_Green"; -- 治疗
	[ProtoCommon.class_type.CLASS_TYPE_CARPENTER] = "UI_Icon_Job_Img_White"; -- 能工巧匠
	[ProtoCommon.class_type.CLASS_TYPE_EARTHMESSENGER] = "UI_Icon_Job_Img_White"; -- 大地使者
}

---@class UIBinderSetProfIconSimple5nd : UIBinder
local UIBinderSetProfIconSimple5nd = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param NormalWidget UImage
function UIBinderSetProfIconSimple5nd:Ctor(View, NormalWidget, BGWidget)
	self.NormalWidget = NormalWidget
	self.BGWidget = BGWidget
end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetProfIconSimple5nd:OnValueChanged(NewValue, OldValue)
	local ProfID = NewValue
	if nil == ProfID then
		return
	end
	
	local ProfIcon = RoleInitCfg:FindRoleInitProfIconSimple5nd(ProfID)
	if (ProfIcon == nil) then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.NormalWidget, ProfIcon)

	if self.BGWidget then
		local ClassIcon = RoleClassIconCfg[RoleInitCfg:FindProfClass(ProfID)]
		local ClassPath = string.format("Texture2D'/Game/UI/Texture/Role/%s.%s'", ClassIcon, ClassIcon)
		UIUtil.ImageSetBrushFromAssetPath(self.BGWidget, ClassPath)
	end
end

return UIBinderSetProfIconSimple5nd