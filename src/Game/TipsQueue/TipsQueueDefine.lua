---
--- Author: bowxiong
--- DateTime: 2024-11-08 15:01
--- Description:
---

local TipsQueueDefine = {}

-- 消息提示结束的原因
TipsQueueDefine.STOP_REASON = {
	COMPLETE=1, --时间到了正常结束
	NEWTIPS=2, --有新的消息加入
	PLAYSEQUENCE=3, --播放过场动画
	PWORLDCHANGE=4, -- 切换场景
}

return TipsQueueDefine