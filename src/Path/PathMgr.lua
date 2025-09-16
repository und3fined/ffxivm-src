--
-- Author: anypkvcai
-- Date: 2020-09-21 20:37:20
-- Description:
--

local UPathMgr = _G.UE.UPathMgr

---@class PathMgr
local PathMgr = {}

---PersistentDir
---绝对路径 持久存储目录 可读可写 用于存放热更新或其它类型资源 路径为/storage/emulated/0/Android/data/com.tencent.tmgp.xxxx/files/（UE4默认）
function PathMgr.PersistentDir()
	return UPathMgr.PersistentDir(true)
end

---ContentDir
---绝对路径 资源Content根目录 只读
function PathMgr.ContentDir()
	return UPathMgr.ContentDir(true)
end

---SavedDir
---绝对路径 临时资源目录 可读可写 /storage/emulated/0/UE4Game/FGame/FGame/Saved/（UE4默认）
---修改为包内路径：PersistentDir + Saved/
function PathMgr.SavedDir()
	return UPathMgr.SavedDir(true)
end

---LogDir
---绝对路径 日志目录 可读可写 路径为SavedDir() + Logs/（UE4默认）
---修改为包内路径：PersistentDir + Logs/
---win： H:/sourework/Client/PersistentDownloadDir/Logs/ 
---Android： /storage/emulated/0/Android/data/com.tencent.tmgp.fmgame/files/Logs/
---也就是说LogDir并不是FGame.Log的绝对路径，需要使用PathMgr的PathToAbsolutePaths获取（参考接口使用说明）
function PathMgr.LogDir()
	return UPathMgr.LogDir(true)
end

---PakDir
---绝对路径 Pak存放目录 PersistentDir + Paks/
function PathMgr.PakDir()
	return UPathMgr.PakDir(true)
end

---PersistentDirRelative
---相对路径 持久存储目录 可读可写 用于存放热更新或其它类型资源
function PathMgr.PersistentDirRelative()
	return UPathMgr.PersistentDir(false)
end

---ContentDirRelative
---相对路径 资源Content根目录 只读 相对路径为../../../FGame/Content/（UE4默认）
function PathMgr.ContentDirRelative()
	return UPathMgr.ContentDir(false)
end

---SavedDirRelative
---相对路径 临时资源目录 可读可写 相对路径为../../../FGame/Saved/
---修改为包内路径：PersistentDir + Saved/
function PathMgr.SavedDirRelative()
	return UPathMgr.SavedDir(false)
end

---LogDirRelative
---相对路径 日志目录 可读可写 路径为SavedDir() + Logs/（UE4默认）
---修改为包内路径：PersistentDir + Logs/
---Win：../../../../Client/PersistentDownloadDir/Logs/
---Ios：../../../FGame/Saved/Logs/FGame.log
function PathMgr.LogDirRelative()
	return UPathMgr.LogDir(false)
end

---PakDirRelative
---相对路径 Pak存放目录 PersistentDir + Paks/
function PathMgr.PakDirRelative()
	return UPathMgr.PakDir(false)
end

-- 区分平台
-- 安卓传入示例：FPaths::Combine(FPaths::ProjectLogDir(), TEXT("FGame.log"))
-- IOS传入示例："/FGame/Saved/Logs/FGame.log"
-- windows传入示例：FPaths::Combine(FPaths::ProjectLogDir(), TEXT("FGame.log"))
function PathMgr.PathToAbsolutePath(FilePath,UseGFilePathBase)
	return UPathMgr.PathToAbsolutePath(FilePath,UseGFilePathBase)
end

---ExistFile
---@param FilePath string
function PathMgr.ExistFile(FilePath)
	return UPathMgr.ExistFile(FilePath)
end

---FileSize
---@param FilePath string
function PathMgr.FileSize(FilePath)
	return UPathMgr.FileSize(FilePath)
end

---DeleteFile
---@param FilePath string
function PathMgr.DeleteFile(FilePath)
	return UPathMgr.DeleteFile(FilePath)
end

---CopyFile
---@param FromFile string
---@param ToFile string
---@param Replace string
function PathMgr.CopyFile(FromFile, ToFile, Replace)
	return UPathMgr.CopyFile(FromFile, ToFile, Replace)
end

---CopyFile
---@param Dest string
---@param Src string
function PathMgr.CopyFileForce(Dest, Src)
	return UPathMgr.CopyFileForce(Dest, Src)
end

---ExistDir
---@param DirPath string
function PathMgr.ExistDir(DirPath)
	return UPathMgr.ExistDir(DirPath)
end

---CreateDir
---@param DirPath string
---@param Replace string
function PathMgr.CreateDir(DirPath, Replace)
	return UPathMgr.CreateDir(DirPath, Replace)
end

---DeleteDir
---@param DirPath string
function PathMgr.DeleteDir(DirPath)
	return UPathMgr.DeleteDir(DirPath)
end

---CopyDir
---@param FromDir string
---@param ToDir string
---@param Recursive boolean
---@param Replace boolean
function PathMgr.CopyDir(FromDir, ToDir, Recursive, Replace)
	return UPathMgr.CopyDir(FromDir, ToDir, Recursive, Replace)
end

---GetCleanFilename
---Returns the filename (with extension), minus any path information
---@param Path string
function PathMgr.GetCleanFilename(Path)
	return UPathMgr.GetCleanFilename(Path)
end

---GetBaseFilename
---Returns the same thing as GetCleanFilename, but without the extension
---@param Path string
---@param bRemovePath boolean
function PathMgr.GetBaseFilename(Path, bRemovePath)
	return UPathMgr.GetBaseFilename(Path, bRemovePath)
end

---GetPath
---Returns the path in front of the filename
---@param Path string
function PathMgr.GetPath(Path)
	return UPathMgr.GetPath(Path)
end

---GetPathLeaf
---Returns the leaf in the path
---@param Path string
function PathMgr.GetPathLeaf(Path)
	return UPathMgr.GetPathLeaf(Path)
end

---GetFileList
---Returns the file list in the path
---@param Path string
---@param FileType string  .sav .lua等 .*代表全部类型
---@param Recursive string 是否包含子目录 返回文件全路径
function PathMgr.GetFileList(Path, FileType, Recursive)
	return UPathMgr.GetFileList(Path, FileType, Recursive)
end


---GetFileCreationTime
---Returns the CreationTime of the file
---@param Path string
function PathMgr.GetFileCreationTime(Path)
	return UPathMgr.GetFileCreationTime(Path)
end

---GetFileLastModificationTime
---Returns the LastModificationTime of the file
---@param Path string
function PathMgr.GetFileLastModificationTime(Path)
	return UPathMgr.GetFileLastModificationTime(Path)
end

---FindFilesRecursively
---Found files recursively
---@param FoundFiles string
---@param DirPath string
---@param Filename string
---@param bFiles boolean
---@param bDirectories boolean
---@param bClearFileNames boolean
function PathMgr.FindFilesRecursively(FoundFiles, DirPath, Filename, bFiles, bDirectories, bClearFileNames)
	return UPathMgr.FindFilesRecursively(FoundFiles, DirPath, Filename, bFiles, bDirectories, bClearFileNames)
end

return PathMgr