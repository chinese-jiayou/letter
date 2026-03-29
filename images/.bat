@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: 设置目标文件夹路径（修改这里指定文件夹，比如：set "target_dir=D:\音乐"）
set "target_dir=%~dp0"

:: 切换到目标文件夹
cd /d "%target_dir%" || (
    echo 错误：无法访问文件夹 "%target_dir%"
    pause
    exit /b 1
)

echo 正在处理文件夹：%target_dir%
echo ==============================

:: 遍历所有文件（排除脚本自身）
for /f "delims=" %%a in ('dir /b /a-d ^| findstr /v /i "%~nx0"') do (
    set "old_name=%%a"
    set "new_name=!old_name!"
    
    :: 第一步：删除所有括号（小/中/大）
    set "new_name=!new_name:(=!"
    set "new_name=!new_name:)=!"
    set "new_name=!new_name:[=!"
    set "new_name=!new_name:]=!"
    set "new_name=!new_name:{=!"
    set "new_name=!new_name:}=!"
    
    :: 第二步：删除括号删除后可能残留的多余空格（关键修正）
    set "new_name=!new_name:  = !"  :: 先把连续两个空格换成一个
    :trim_space
    if "!new_name:  = !" neq "!new_name!" (
        set "new_name=!new_name:  = !"
        goto trim_space
    )
    :: 去除首尾空格（如果有）
    for /f "tokens=* delims= " %%b in ("!new_name!") do set "new_name=%%b"
    
    :: 仅当文件名变化且新文件名不存在时重命名
    if not "!old_name!"=="!new_name!" (
        if not exist "!new_name!" (
            ren "!old_name!" "!new_name!"
            echo 已处理：!old_name! → !new_name!
        ) else (
            echo 跳过：!new_name! 已存在，未重命名 "!old_name!"
        )
    )
)

echo ==============================
echo 处理完成！按任意键退出...
pause > nul
endlocal