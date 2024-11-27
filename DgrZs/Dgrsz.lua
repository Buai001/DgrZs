-- 创建主窗口
local frame = CreateFrame("Frame", "MyAddonFrame", UIParent)
frame:SetSize(220, 440)  -- 设置窗口大小
frame:SetPoint("CENTER")  -- 设置窗口位置
frame:Hide()  -- 默认隐藏窗口

-- 添加背景
local background = frame:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints(frame)
background:SetColorTexture(0, 0, 0, 0.8)  -- 设置背景颜色为黑色，透明度为0.8

-- 添加标题
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("DGR一键助手")

-- 创建关闭按钮
local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
closeButton:SetSize(80, 22)
closeButton:SetPoint("BOTTOM", 0, 5)
closeButton:SetText("关闭")
closeButton:SetScript("OnClick", function() frame:Hide() end)

-- 创建命令来显示窗口
SLASH_MYADDON1 = "/DGR"
SlashCmdList["MYADDON"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- 创建一个函数来处理重新加载插件的命令
local function ReloadUICommand()
    ReloadUI()
end

-- 注册命令 /rl
SLASH_RELOADUI1 = "/rl"
SlashCmdList["RELOADUI"] = ReloadUICommand

-- 创建职业下拉菜单
local classDropdown = CreateFrame("Frame", "MyAddonClassDropdown", frame, "UIDropDownMenuTemplate")
classDropdown:SetPoint("TOPLEFT", 10, -40)

local classes = {"奶骑", "牧师","德鲁伊"}
local skillsByClass = {
    ["奶骑"] = {
        {"圣光术", "Interface\\Icons\\Spell_Holy_HolyBolt"},
        {"圣光闪现", "Interface\\Icons\\Spell_Holy_FlashHeal"},
        {"神圣震击", "Interface\\Icons\\Spell_Holy_SearingLight"},
        {"圣疗术", "Interface\\Icons\\Spell_Holy_LayOnHands"},
        {"保护祝福", "Interface\\Icons\\Spell_Holy_SealOfProtection"},
        {"力量祝福", "Interface\\Icons\\spell_holy_fistofjustice"},
        {"智慧祝福", "Interface\\Icons\\Spell_Holy_SealOfWisdom"},
        {"王者祝福", "Interface\\Icons\\spell_magic_magearmor"},
        {"清洁术", "Interface\\Icons\\spell_holy_renew"},
        {"纯净术", "Interface\\Icons\\spell_holy_purify"},
    },
    ["牧师"] = {
        {"次级治疗术", "Interface\\Icons\\Spell_Holy_LesserHeal"},
        {"治疗术", "Interface\\Icons\\Spell_Holy_Heal"},
        {"强效治疗术", "Interface\\Icons\\Spell_Holy_GreaterHeal"},
        {"快速治疗", "Interface\\Icons\\Spell_Holy_FlashHeal"},
        {"治疗祷言", "Interface\\Icons\\spell_holy_prayerofhealing02"},
        {"恢复", "Interface\\Icons\\Spell_Holy_Renew"},
        {"心灵之火", "Interface\\Icons\\spell_holy_innerfire"},
        {"真言术.韧", "Interface\\Icons\\spell_holy_wordfortitude"},
        {"真言术.盾", "Interface\\Icons\\Spell_Holy_PowerWordShield"},
        {"神圣之灵", "Interface\\Icons\\spell_holy_divinespirit"},
        {"祛病术", "Interface\\Icons\\spell_holy_nullifydisease"},
    },
    ["德鲁伊"] = {
        {"治疗之触", "Interface\\Icons\\spell_nature_healingtouch"},
        {"回春术", "Interface\\Icons\\spell_nature_rejuvenation"},
        {"愈合", "Interface\\Icons\\spell_nature_resistnature"},
        {"宁静", "Interface\\Icons\\spell_nature_tranquility"},
        {"激活", "Interface\\Icons\\spell_nature_lightning"},
        {"荆棘术", "Interface\\Icons\\spell_nature_thorns"},
        {"野性印记", "Interface\\Icons\\spell_nature_regeneration"},
        {"消毒术", "Interface\\Icons\\spell_nature_nullifypoison"},
        {"解除诅咒", "Interface\\Icons\\spell_holy_removecurse"},
    },
}

local checkboxes = {}

-- 初始化保存变量
DGRSV = DGRSV or {}
tempSkills = tempSkills or {}  -- 确保 tempSkills 是全局变量

-- 更新技能复选框
local function UpdateSkills(class, isReload)
    local classKey = class  -- 根据职业生成键
    local skills = skillsByClass[class]
    if not skills then
        return
    end

    -- 清空之前的复选框
    for _, checkbox in ipairs(checkboxes) do
        checkbox:Hide()
    end
    wipe(checkboxes)  -- 清空复选框列表

    -- 清空临时技能状态
    wipe(tempSkills)  -- 清空临时变量，确保没有旧的技能状态

    for i, skill in ipairs(skills) do
        local skillName = skill[1]
        local skillIcon = skill[2]

        -- 创建复选框
        local checkbox = CreateFrame("CheckButton", "MyAddonCheckbox" .. i, frame, "UICheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", 20, -80 - (i - 1) * 30)  -- 设置复选框位置
        checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 33, 0)
        checkbox.text:SetText(skillName)

        -- 设置复选框的图标
        checkbox.icon = checkbox:CreateTexture(nil, "ARTWORK")
        checkbox.icon:SetSize(24, 24)
        checkbox.icon:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
        checkbox.icon:SetTexture(skillIcon)

        -- 读取当前技能的状态
        local isChecked
        if isReload then
            -- 如果是框架重载，从SavedVariables读取
            isChecked = DGRSV[classKey] and DGRSV[classKey][skillName]
        else
            -- 如果是切换下拉菜单，从临时变量读取
            isChecked = tempSkills[skillName]
        end

        checkbox:SetChecked(isChecked or false)  -- 确保默认值为false
        tempSkills[skillName] = isChecked or false  -- 将当前状态存储到临时变量

        -- 复选框点击事件
        checkbox:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            tempSkills[skillName] = checked  -- 更新临时变量
            SaveConfig(class, skillName, checked)  -- 保存配置
        end)

        checkbox:Show()  -- 显示复选框
        table.insert(checkboxes, checkbox)  -- 将复选框添加到列表中
    end
end

-- 保存配置到SavedVariables
local function SaveConfig(class, skillName, isChecked)
    local classKey = class  -- 使用职业名称作为键
    if not DGRSV[classKey] then
        DGRSV[classKey] = {}
    end
    DGRSV[classKey][skillName] = isChecked
end

-- 职业下拉菜单点击事件
local function OnClick(self)
    UIDropDownMenu_SetSelectedID(classDropdown, self:GetID())
    local selectedClass = self.value
    DGRSV.selectedClass = selectedClass
    UpdateSkills(selectedClass, false)  -- 从临时变量读取
end

-- 创建下拉菜单选项
local function InitializeDropdown(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for _, class in ipairs(classes) do
        info.text = class
        info.value = class
        info.func = OnClick
        info.checked = (class == DGRSV.selectedClass)  -- 仅选中当前保存的职业
        UIDropDownMenu_AddButton(info, level)
    end
end

UIDropDownMenu_Initialize(classDropdown, InitializeDropdown)
UIDropDownMenu_SetWidth(classDropdown, 150)
UIDropDownMenu_SetButtonWidth(classDropdown, 150)

-- 在下拉菜单初始化后设置选中项
if DGRSV.selectedClass then
    UIDropDownMenu_SetSelectedName(classDropdown, DGRSV.selectedClass)
else
    DGRSV.selectedClass = classes[1]  -- 设置默认职业
    UIDropDownMenu_SetSelectedID(classDropdown, 1)  -- 选择第一个职业
end

UIDropDownMenu_JustifyText(classDropdown, "LEFT")

-- 事件处理框架
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        -- 初始化 SavedVariables
        if not DGRSV then
            DGRSV = {}
        end
        
        -- 插件加载时读取配置
        if DGRSV.selectedClass then
            UIDropDownMenu_SetSelectedName(classDropdown, DGRSV.selectedClass)
            UpdateSkills(DGRSV.selectedClass, true)  -- 从SavedVariables读取技能状态
        else
            DGRSV.selectedClass = classes[1]  -- 设置默认职业
            UIDropDownMenu_SetSelectedID(classDropdown, 1)
            UpdateSkills(classes[1], true)  -- 从SavedVariables读取技能状态
        end
    elseif event == "PLAYER_LOGOUT" then
        -- 插件关闭时保存配置
        for skillName, isChecked in pairs(tempSkills) do
            SaveConfig(DGRSV.selectedClass, skillName, isChecked)
        end
    end
end)

-- 初始化时更新技能复选框
UpdateSkills(classes[1])

local function CreateTargetMacros()--设置职业宏和快捷键
    -- 角色职业
    local _, playerProfession = UnitClass("player") -- 使用 UnitClass 获取职业
    -- 创建技能宏
    local skills
    if playerProfession == "PRIEST" then -- 注意职业名称是英文
        skills = {
            {name = "跟随", command = "/follow party1"},
            {name = "取消跟随", command = "/follow player"},
            {name = "协助", command = "/assist party1"},
            {name = "焦点目标", command = "/目标 party1"},
            {name = "次级治疗术", command = "/cast 次级治疗术"},
            {name = "治疗术", command = "/cast 治疗术"},
            {name = "强效治疗术", command = "/cast 强效治疗术"},
            {name = "快速治疗", command = "/cast 快速治疗"},
            {name = "治疗祷言", command = "/cast 治疗祷言"},
            {name = "恢复", command = "/cast 恢复"},
            {name = "心灵之火", command = "/cast [@player]心灵之火"},
            {name = "真言术：韧", command = "/cast 真言术：韧"},
            {name = "真言术：盾", command = "/cast 真言术：盾"},
            {name = "神圣之灵", command = "/cast 神圣之灵"},
            {name = "祛病术", command = "/cast 祛病术"},
        }
	elseif playerProfession == "PALADIN" then--圣骑士
	    -- 在这里添加圣骑士的技能
		skills = {
            {name = "跟随", command = "/follow party1"},
            {name = "取消跟随", command = "/follow player"},
            {name = "协助", command = "/assist party1"},
            {name = "焦点目标", command = "/目标 party1"},
            {name = "圣光术", command = "/cast 圣光术"},
            {name = "圣光闪现", command = "/cast 圣光闪现"},
            {name = "神圣震击", command = "/cast 神圣震击"},
            {name = "圣疗术", command = "/cast 圣疗术"},
            {name = "保护祝福", command = "/cast 保护祝福"},
            {name = "力量祝福", command = "/cast 力量祝福"},
			{name = "智慧祝福", command = "/cast 智慧祝福"},
			{name = "王者祝福", command = "/cast 王者祝福"},
            {name = "清洁术", command = "/cast 清洁术"},
            {name = "纯净术", command = "/cast 纯净术"},
        }
    elseif playerProfession == "DRUID" then--德鲁伊
        --这里添加德鲁伊技能
        skills = {
            {name = "跟随", command = "/follow party1"},
            {name = "取消跟随", command = "/follow player"},
            {name = "协助", command = "/assist party1"},
            {name = "焦点目标", command = "/目标 party1"},
            {name = "治疗之触", command = "/cast 治疗之触"},
            {name = "回春术", command = "/cast 回春术"},
            {name = "愈合", command = "/cast 愈合"},
            {name = "宁静", command = "/cast [@player]宁静"},
            {name = "激活", command = "/cast [@player]激活"},
            {name = "荆棘术", command = "/cast 荆棘术"},
            {name = "野性印记", command = "/cast 野性印记"},
            {name = "消毒术", command = "/cast 消毒术"},
            {name = "解除诅咒", command = "/cast 解除诅咒"},
        }
    end
	
    if skills then
        for i, skill in ipairs(skills) do
            local macroName = skill.name -- 宏名称
            local macroCommand = skill.command -- 宏命令
            -- 创建宏
            local macroIndex = GetMacroIndexByName(macroName)
            if macroIndex > 0 then
                -- 如果宏已经存在，更新宏
                EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", macroCommand)
            else
                -- 创建新宏
                CreateMacro(macroName, "INV_MISC_QUESTIONMARK", macroCommand)
            end

            -- 创建按钮并绑定快捷键
            local button = CreateFrame("Button", "MySkillMacroButton" .. i, UIParent, "SecureActionButtonTemplate")
            button:SetAttribute("type", "macro")
            button:SetAttribute("macro", macroName)

            local keyBinding
            if i <= 9 then
                -- 绑定快捷键到 Ctrl + 小键盘1-9
                keyBinding = "CTRL-NUMPAD" .. i
            elseif i <= 18 then
                -- 绑定快捷键到 ALT + 小键盘1-9
                keyBinding = "ALT-NUMPAD" .. (i - 9)
            elseif i <= 27 then
                  -- 绑定快捷键到 小键盘1-9
                keyBinding = "NUMPAD" .. (i - 18)
            end
            
            -- 设置快捷键绑定
            if keyBinding then
                SetBinding(keyBinding, "CLICK MySkillMacroButton" .. i .. ":LeftButton")
            end
        end
    end
end

-- 注册事件
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        -- 使用延迟调用来避免卡顿
        C_Timer.After(1, CreateTargetMacros) -- 延迟1秒后创建宏
    end
end)