--
-- Author: anypkvcai
-- Date: 2020-08-06 09:59:42
-- Description:
--

---@class UIShowType
local UIShowType = {
	Normal = 1, --显示在当前层其他界面上方
	HideOthers = 2, --隐藏当前层层级比自己低的其他所有界面
	Popup = 3, --界面显示时，隐藏当前层上一个Popup类型界面，关闭时显示上一个Popup类型界面
}

return UIShowType