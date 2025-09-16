--
-- Author: anypkvcai
-- Date: 2020-08-05 14:42:18
-- Description:
--

---LayerMutex配置了层级之间的互斥关系，如果有特殊需求，可添加新层
---@class UILayer
local UILayer = {
	Lowest = (1 << 0), -- 目前对话气泡类型的在使用
	--BelowLow = (1 << 1), -- 预留 暂未使用
	Low = (1 << 2), -- 主界面等低层级的界面
	AboveLow = (1 << 3), -- 比主界面层级高的
	BelowNormal = (1 << 4), -- 预留 暂未使用
	Normal = (1 << 5), -- 一般界面选择这层 显示时会隐藏 Lowest，Low和AboveLow层级的界面 (LayerMutex配置)
	AboveNormal = (1 << 6), -- 不隐藏Low和AboveLow层级的界面
	Story = (1 << 7), -- 剧情
	Exclusive = (1 << 8), -- 独占层 显示时会隐藏其他所有层的界面 (LayerMutex配置)
	BelowHigh = (1 << 9), -- 预留 暂未使用
	High = (1 << 10), -- MessageBox等弹框 显示时会隐藏 Lowest，Low和AboveLow层级的界面 (LayerMutex配置)
	AboveHigh = (1 << 11),
	Tips = (1 << 12), -- 提示
	Highest = (1 << 13), --侧边弹出框 最高层级
	Network = (1 << 14), -- 断线等网络异常提示
	Loading = (1 << 15), -- Loading

	All = (0xffff)
}

return UILayer