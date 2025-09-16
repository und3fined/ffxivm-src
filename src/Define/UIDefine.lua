--
-- Author: anypkvcai
-- Date: 2023-06-25 10:30
-- Description:
--


---@class CommBtnColorType
local CommBtnColorType = {
	Normal = 0, -- 普通 灰色
	Recommend = 1, -- 推荐 绿色
	Disable = 2, -- 禁用状态
	Done = 3, -- 完成
}

---@class SearchBtnColorType
local SearchBtnColorType = {
	Light = 0, -- 浅色
	Dark = 1, -- 深色

}

---@class CommUIStyleType
local CommUIStyleType = {
	Dark = 0, -- 深色系
	Light = 1, -- 浅色系
}

--界面关闭时是否强制GC 测试内存释放用
local bForceGC = false

local UIDefine = {
	CommBtnColorType = CommBtnColorType,
	SearchBtnColorType = SearchBtnColorType,
	CommUIStyleType = CommUIStyleType,
	bForceGC = bForceGC,
}

return UIDefine