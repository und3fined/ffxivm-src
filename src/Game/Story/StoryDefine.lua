
local StoryDefine = {}

StoryDefine.UIType = {
	NpcDialog = 1,
	SequenceDialog = 2
}

StoryDefine.DialogType = {
    Dialog = 1,
    HistoryQuestList = 2,
}

StoryDefine.ContentType = {
	NpcContent = 1,
	Choice = 2,
	OnlyContent = 3
}

StoryDefine.DialogHistoryClass = {
    New = function(ContentType, DialogType, Name, Content, VoiceName)
        if (VoiceName == "") then VoiceName = nil end
        local Object = {
            -- 创建时传参
            ContentType = ContentType,
            DialogType = DialogType,
            Name = Name,
            Content = Content,
            VoiceName = VoiceName,
            -- 无需传参
            bNew = false,
            Index = 0, -- 创建时记录自身顺序（假设顺序不会改变）
        }
        return Object
    end
}

-- 仅作保护用，实际读取客户端全局配置
StoryDefine.TouchWaitTimeMS = 100
StoryDefine.AutoWaitTime = 0.3

StoryDefine.SpeedLevelData = {
	[1] = 1,
	[2] = 0.2,
	[3] = 0.1,
	[4] = 0.05,
	[5] = 0.01
}

-- 来源：https://doc.weixin.qq.com/sheet/e3_AT8AVQYhALQwE0E0yb4SZqU07UhyW?scode=AJEAIQdfAAopRbyXtpAT8AVQYhALQ&tab=BB08J2
StoryDefine.LcutWithNcutList = { "21405902", "21405904", "21603301", "21603401", "21603501", "21720503" }

return StoryDefine