@echo off
mode con cp select=936 >nul
setlocal enabledelayedexpansion

:: ====================== 导出项目的 tags + branches ======================
:EXPORT_MENU

:: 获取当前文件夹名
for %%I in ("%~dp0.") do set "FolderName=%%~nxI"

:: 检查 Git 仓库
git rev-parse --git-dir >nul 2>nul
if errorlevel 1 (
    echo 不是 Git 仓库，无法导出。
    pause
    exit /b 1
)

:: ---------- 收集 tags ----------
set tag_idx=0
for /f "delims=" %%t in ('git tag --sort=creatordate') do (
    set /a tag_idx+=1
    set "tag!tag_idx!=%%t"
)

:: ---------- 收集 branches（本地分支，按最近提交排序） ----------
set branch_idx=0
for /f "delims=" %%b in ('git for-each-ref --sort=-committerdate --format="%%(refname:short)" refs/heads') do (
    set /a branch_idx+=1
    set "branch!branch_idx!=%%b"
)

:: 总数为 0 时退出
set /a total_idx=tag_idx+branch_idx
if %total_idx% equ 0 (
    echo 该项目没有任何标签或分支。
    pause
    exit /b 0
)

echo.
echo ===== 项目 %FolderName% 的标签与分支列表 =====

if %tag_idx% gtr 0 (
    echo [标签]
    for /l %%i in (1,1,%tag_idx%) do (
        echo %%i. !tag%%i!
    )
) else (
    echo [标签] 无
)
echo.
if %branch_idx% gtr 0 (
    echo [分支]
    for /l %%i in (1,1,%branch_idx%) do (
        set /a real_idx=tag_idx+%%i
        echo !real_idx!. !branch%%i!
    )
) else (
    echo [分支] 无
)
echo 0. 导出全部标签和分支
echo.

set "choice="
set /p "choice=请输入编号 (1-%total_idx%) 或输入 0 导出全部："
echo.

if not defined choice goto EXPORT_MENU
if "!choice!"=="0" goto EXPORT_ALL

:: 校验是否为纯数字
echo(!choice!|findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 goto EXPORT_MENU
if !choice! lss 1 goto EXPORT_MENU
if !choice! gtr %total_idx% goto EXPORT_MENU

:: ---------- 判断选择的是 tag 还是 branch ----------
if !choice! leq %tag_idx% (
    :: 导出 tag
    set "selected_tag=!tag%choice%!"
    echo 导出标签: !selected_tag!

    set "safe_name=!selected_tag:/=_!"
    set "safe_name=!safe_name:\=_!"
    set "safe_name=!safe_name::=_!"

    set "output_zip=.\!FolderName!_!safe_name!.zip"
    git archive --format=zip --output="!output_zip!" "!selected_tag!"

    if errorlevel 1 (
        echo 导出失败
    ) else (
        echo 成功导出: !output_zip!
    )
) else (
    :: 导出 branch
    set /a bi=!choice!-tag_idx
    for %%k in (!bi!) do set "selected_branch=!branch%%k!"
    echo 导出分支: !selected_branch!

    set "safe_name=!selected_branch:/=_!"
    set "safe_name=!safe_name:\=_!"
    set "safe_name=!safe_name::=_!"

    set "output_zip=.\!FolderName!_!safe_name!.zip"
    git archive --format=zip --output="!output_zip!" "!selected_branch!"

    if errorlevel 1 (
        echo 导出失败
    ) else (
        echo 成功导出: !output_zip!
    )
)

echo.
timeout /t 3 /nobreak >nul
exit /b 0


:: ====================== 导出全部 ======================
:EXPORT_ALL
echo.
echo 正在导出项目 !FolderName! 的所有标签和分支...

:: 导出所有 tags
if %tag_idx% gtr 0 (
    for /l %%i in (1,1,%tag_idx%) do (
        set "name=!tag%%i!"
        echo 导出标签: !name!

        set "safe_name=!name:/=_!"
        set "safe_name=!safe_name:\=_!"
        set "safe_name=!safe_name::=_!"

        set "output_zip=.\!FolderName!_!safe_name!.zip"
        git archive --format=zip --output="!output_zip!" "!name!"

        if errorlevel 1 (
            echo 警告：导出标签 !name! 失败
        ) else (
            echo 成功导出: !output_zip!
        )
    )
)

:: 导出所有 branches
if %branch_idx% gtr 0 (
    for /l %%i in (1,1,%branch_idx%) do (
        set "name=!branch%%i!"
        echo 导出分支: !name!

        set "safe_name=!name:/=_!"
        set "safe_name=!safe_name:\=_!"
        set "safe_name=!safe_name::=_!"

        set "output_zip=.\!FolderName!_!safe_name!.zip"
        git archive --format=zip --output="!output_zip!" "!name!"

        if errorlevel 1 (
            echo 警告：导出分支 !name! 失败
        ) else (
            echo 成功导出: !output_zip!
        )
    )
)

echo.
echo √ 项目 !FolderName! 的所有标签和分支已导出到当前目录。
echo    文件名格式：项目名_标签名或分支名.zip
timeout /t 3 /nobreak >nul
exit /b 0