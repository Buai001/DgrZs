-- 创建主框架
local DgrzsFrame = CreateFrame("Frame", "DgrzsFrame", UIParent)
DgrzsFrame:SetSize(26, 14)  -- 设置框架大小
DgrzsFrame:SetPoint("TOPLEFT", 0, 0)  -- 设置框架位置为左上角

-- 添加背景
local background = DgrzsFrame:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints(DgrzsFrame)
background:SetColorTexture(0, 0, 0, 0.5)  -- 设置背景颜色为黑色，透明度为0.5

-- 定义8个颜色 队友1-5
local colors = {
    {1, 0, 0, 1},    -- 红色
    {1, 0.5, 0, 1},  -- 橙色
    {1, 1, 0, 1},    -- 黄色
    {0, 1, 0, 1},    -- 绿色
    {0, 1, 1, 1},    -- 青色
    {0, 0, 1, 1},    -- 蓝色--队长
    {0.5, 0, 1, 1},  -- 紫色--需要跟随
	{0, 0, 0, 0}, -- 透明
}

-- 定义18个颜色 技能1-18
local colors1 = {
    {1, 0, 0, 1},    -- 红色
    {1, 0.5, 0, 1},  -- 橙色
    {1, 1, 0, 1},    -- 黄色
    {0, 1, 0, 1},    -- 绿色
    {0, 1, 1, 1},    -- 青色
    {0, 0, 1, 1},    -- 蓝色
    {0.5, 0, 1, 1},  -- 紫色
    {1, 0,0.75, 1},    -- 品红
    {1, 0.5, 0.5, 1},-- 浅红色
    {1, 1, 0.5, 1},  -- 浅黄色
    {0.5, 1, 0.5, 1},-- 浅绿色
    {0.5, 1, 1, 1},  -- 浅青色
    {0.5, 0.5, 1, 1},-- 浅蓝色
    {0.75, 0.5, 1, 1}, -- 浅紫色
    {1, 0.75, 1, 1}, -- 浅品红
    {1, 0.25, 0.25, 1}, -- 深红色
    {1, 1, 0.25, 1}, -- 深黄色
    {0.25, 1, 0.25, 1}, -- 深绿色
	{0, 0, 0, 0}, -- 透明
}

-- 创建10x10的纹理
local squareTexture = DgrzsFrame:CreateTexture(nil, "OVERLAY")
squareTexture:SetSize(10, 10)  -- 设置纹理大小为10x10
squareTexture:SetPoint("TOPLEFT", DgrzsFrame, "TOPLEFT", 2, -2)  -- 将纹理放置在框架中心

-- 创建第二个10x10的纹理
local squareTexture1 = DgrzsFrame:CreateTexture(nil, "OVERLAY")
squareTexture1:SetSize(10, 10)  -- 设置纹理大小为10x10
squareTexture1:SetPoint("TOPLEFT", DgrzsFrame, "TOPLEFT", 14, -2)  -- 将纹理放置在框架中心

-- 切换颜色的函数
local function SetSquareColor(index)
    -- 获取颜色
    local r, g, b, a = unpack(colors[index])

    -- 设置纹理颜色为指定颜色
    squareTexture:SetColorTexture(r, g, b, a)  -- 设置当前颜色为不透明
end

-- 切换颜色的函数
local function SetSquareColor1(index)
    -- 获取颜色
    local r, g, b, a = unpack(colors1[index])

    -- 设置纹理颜色为指定颜色
    squareTexture1:SetColorTexture(r, g, b, a)  -- 设置当前颜色为不透明
end

-- 创建命令来显示框架
SLASH_DGRZS1 = "/dgrzs"
SlashCmdList["DGRZS"] = function(msg)
    if DgrzsFrame:IsShown() then
        DgrzsFrame:Hide()
    else
        DgrzsFrame:Show()
    end
end

local function JL(unit) -- 检测与对象的距离
    if UnitExists(unit) then -- 检查目标是否存在
        local distanceSquared = UnitDistanceSquared(unit)
        if distanceSquared then
            -- 计算正常的距离
            local distance = math.sqrt(distanceSquared)
            return distance
        end
    end
    return 0 -- 如果目标不存在或距离平方无效，返回 0
end
local function isPlayerCasting(unit)--检测自身是否施法状态
    local casting = UnitCastingInfo(unit)
    local channeling = UnitChannelInfo(unit)

    if casting or channeling then
        return true
    else
        return false
    end
end
local function debuff(unit)--读取对象身上的有害buff
	local bufflist = {}
	for i = 1, 20 do
		local name = UnitAura(unit, i, "HARMFUL")
		if name then
			bufflist[i] = name
		else
			break
		end
	end
	return bufflist
end
local function buff(unit)--读取对象身上的增益buff
	local bufflist = {}
	for i = 1, 20 do
		local name = UnitAura(unit, i, "HELPFUL")
		if name then
			bufflist[i] = name
		else
			break
		end
	end
	return bufflist
end
local function hasBuff(bufflist, buffName)  --检查是否存在指定buff
    for _, name in ipairs(bufflist) do 
        if name == buffName or name == buffName1 then  
            return true  
        end  
    end  
    return false  
end
local function JCdydebuff(unit, playerProfession)   -- 检查队友身上的debuff 中毒 疾病 魔法 诅咒
    for n = 1, 5 do
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitDebuff(unit, n)
        if name then
            if debuffType == "Poison" then
                return 1
            elseif debuffType == "Disease" then
                return 2
            elseif debuffType == "Magic" then
                return 3
            elseif debuffType == "Curse" then
                return 4
            end
        end
    end
    return 0  -- 如果没有找到任何debuff，返回0
end
local function isSpellLearned(spellName)--检查技能是否已学习
    local spellName = GetSpellInfo(spellName)
    if not spellName then
        return false
    end

    local i = 1
    while true do
        local bookSpellName, bookSpellRank = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not bookSpellName then break end
        if bookSpellName == spellName then
            return true
        end
        i = i + 1
    end
    return false
end
local function CD(spellName)--检查技能是否CD
    if not isSpellLearned(spellName) then
        return false
    end

    local start, duration, enabled = GetSpellCooldown(spellName)
    if start > 0 and duration > 0 then
        return false
    else
        return true
    end
end
local function Isparty1InCombat()--判断是否战斗状态
    if UnitExists("party1") then
        if UnitAffectingCombat("party1") then
            return true
        else
            return false
        end
    else
        return false
    end
end
local function Gensui() -- 判断是否跟随
    if UnitExists("party1") then
        local distance = JL("party1")
        if distance >= 10 and distance <= 30 then
            return true
        elseif distance > 30 or distance < 10 then
            return false
        end
    else
        return false
    end
end
local function JCch() -- 检查是否需要吃喝
    local player = "Player"
    local jshp = UnitHealth(player) / UnitHealthMax(player) * 100 -- 血量百分比
    local jsmp = UnitPower(player) / UnitPowerMax(player) * 100 -- 蓝量百分比
    local bufflist = buff(player)
    if jshp <= 30 and jsmp <= 30 and not hasBuff(bufflist, "饮水") and not hasBuff(bufflist, "喝水") and not hasBuff(bufflist, "进食") then
        SetSquareColor(1)
        SetSquareColor1(18) -- 同时需要吃喝
        return
    elseif jsmp <= 30 and (not hasBuff(bufflist, "饮水") and not hasBuff(bufflist, "喝水")) then
        SetSquareColor(1)
        SetSquareColor1(17) -- 只需要喝
        return
    elseif jshp <= 30 and not hasBuff(bufflist, "进食") then
        SetSquareColor(1)
        SetSquareColor1(16) -- 只需要吃
        return
    end
end
local function SendWhisperToparty1(message)--给队长目标发送悄悄话
    -- 检查是否有队长目标
    local party1Unit = "party1"
    if UnitExists(party1Unit) then
        -- 获取队长目标的名字
        local party1Name = GetUnitName(party1Unit, true) -- true表示获取完整名字（包括服务器名）
        if party1Name then
            -- 发送悄悄话
            SendChatMessage(message, "WHISPER", nil, party1Name)
        end
    end
end
local function NQ()--奶骑
    SetSquareColor(8) -- 当前对象
    SetSquareColor1(19)
    local zdhp = 100 -- 假设最大血量为100
    local dqdx = 1 -- 默认值
    if Isparty1InCombat() and IsInGroup() then --判断是否战斗中
            --队伍内 --对全队进行治疗
        local numMembers = GetNumGroupMembers()--队员数量
        for n = 1, numMembers do
            local unit = (n == 1) and "player" or "party" .. (n - 1)
            local debuff = JCdydebuff(unit, "圣骑士")
            local jn1 = CD("清洁术") -- 冷却完毕
            local jn2 = CD("纯净术") -- 冷却完毕
            local dxjl = JL(unit)

           if (debuff == 1 or debuff == 2) and jn1 and dxjl <= 30 and tempSkills["清洁术"] then
                SetSquareColor(n)
                SetSquareColor1(9) -- 清洁术
                return -- 找到需要驱散的目标后直接返回
            elseif (debuff == 1 or debuff == 2) and jn2 and dxjl <= 30 and tempSkills["纯净术"] then
                SetSquareColor(n)
                SetSquareColor1(10) -- 纯净术
                return -- 找到需要驱散的目标后直接返回
            end
        end

        -- 检查治疗
        for n = 1, numMembers do
            local unit = (n == 1) and "player" or "party" .. (n - 1)
            local jshp = UnitHealth(unit) / UnitHealthMax(unit) * 100 -- 直接计算百分比
            if jshp < zdhp then
                zdhp = jshp
                dqdx = n -- 最低血量玩家
            end
        end
        local unit = (dqdx == 1) and "player" or "party" .. (dqdx - 1)
        local sf = isPlayerCasting("player") -- 是否在施法
        local dxjl = JL(unit) -- 目标在30码以内

        if dxjl <= 30 and not sf then
            -- 读取所有技能CD是否完毕
            local jn1 = CD("圣疗术")
            local jn2 = CD("圣光术")
            local jn3 = CD("圣光闪现")
            local jn4 = CD("神圣震击")
            local jn5 = CD("保护祝福")
            
            -- 直接计算百分比
            local jshp = UnitHealth(unit) / UnitHealthMax(unit) * 100
            
            if tempSkills["圣疗术"] and jshp <= 20 and jshp > 0 and jn1 then
                SetSquareColor(dqdx) -- 当前对象
                SetSquareColor1(4) -- 圣疗术
                return
            elseif tempSkills["保护祝福"] and jshp <= 10 and jshp > 0 and jn5 then
                SetSquareColor(dqdx) -- 当前对象
                SetSquareColor1(5) -- 保护祝福
                return
            elseif tempSkills["圣光术"] and jshp <= 60 and jshp > 0 and jn2 then
                SetSquareColor(dqdx) -- 当前对象
                SetSquareColor1(1) -- 圣光术
                return
            elseif tempSkills["神圣震击"] and jshp <= 80 and jshp > 0 and jn4 then
                SetSquareColor(dqdx) -- 当前对象
                SetSquareColor1(3) -- 神圣震击
                return    
            elseif tempSkills["圣光闪现"] and jshp <= 80 and jshp > 0 and jn3 then
                SetSquareColor(dqdx) -- 当前对象
                SetSquareColor1(2) -- 圣光闪现
                return
            end
        end
    else
        JCch()--检查是否需要吃喝
        --脱战
        if IsInGroup() then--判断是否在队伍
            --队伍内 --对全队检查buff
            local numMembers = GetNumGroupMembers()--队员数量
            for n = 1, numMembers do
                local unit = (n == 1) and "player" or "party" .. (n - 1)
                local jshp = UnitHealth(unit) / UnitHealthMax(unit) * 100 -- 直接计算百分比
                -- 读取所有技能CD是否完毕
                local jn1 = CD("力量祝福")
                local jn2 = CD("智慧祝福")
                local jn3 = CD("王者祝福")
                local dxjl = JL(unit) -- 目标在30码以内

                local bufflist = buff(unit)
                local hasStrengthBuff = tempSkills["力量祝福"] and jshp > 0 and jn1 and dxjl <= 30 and not hasBuff(bufflist, "力量祝福")
                local hasWisdomBuff = tempSkills["智慧祝福"] and jshp > 0 and jn2 and dxjl <= 30 and not hasBuff(bufflist, "智慧祝福")
                local hasKingsBuff = tempSkills["王者祝福"] and jshp > 0 and jn3 and dxjl <= 30 and not hasBuff(bufflist, "王者祝福")

                if hasStrengthBuff then
                    SetSquareColor(n) -- 当前对象
                    SetSquareColor1(6) -- 力量祝福
                    return
                elseif hasWisdomBuff then
                    SetSquareColor(n) -- 当前对象
                    SetSquareColor1(7) -- 智慧祝福
                    return
                elseif hasKingsBuff then
                    SetSquareColor(n) -- 当前对象
                    SetSquareColor1(8) -- 王者祝福
                    return
                end
            end
        end
    end
end
local function MS()--牧师
    SetSquareColor(8) -- 当前对象
    SetSquareColor1(19)
    local zdhp = 100 -- 假设最大血量为100
    local dqdx = 1 -- 默认值
    if Isparty1InCombat() then --判断是否战斗中
        --战斗中
        if IsInGroup() then--判断是否在队伍
            --队伍内 --对全队进行治疗
            local numMembers = GetNumGroupMembers()--队员数量
            for n = 1, numMembers do
                local unit = (n == 1) and "player" or "party" .. (n - 1)
                local debuff = JCdydebuff(unit, "牧师")
                local jn1 = CD("祛病术") -- 冷却完毕
                local dxjl = JL(unit)
    
                if debuff == 2 and jn1 and dxjl <= 30 then
                    SetSquareColor(n)
                    SetSquareColor1(11) -- 祛病术
                    return -- 找到需要驱散的目标后直接返回
                end
            end

            -- 检查治疗
            local cxjs = 0
            for n = 1, numMembers do
                local unit = (n == 1) and "player" or "party" .. (n - 1)
                local jshp = UnitHealth(unit) / UnitHealthMax(unit) * 100 -- 直接计算百分比
                if jshp <= 50 then
                    cxjs = cxjs + 1
                end 
                if jshp < zdhp then
                    zdhp = jshp
                    dqdx = n -- 最低血量玩家
                end
            end
            
            local unit = (dqdx == 1) and "player" or "party" .. (dqdx - 1)
            local sf = isPlayerCasting("player") -- 是否在施法
            local dxjl = JL(unit) -- 目标在30码以内
    
            if dxjl <= 30 and not sf then
                -- 读取所有技能CD是否完毕
                local jn3 = CD("强效治疗术")
                local jn2 = CD("治疗术")
                local jn1 = CD("次级治疗术")
                local jn4 = CD("快速治疗")
                local jn6 = CD("恢复")
                local jn9 = CD("真言术：盾")
                local jn5 = CD("治疗祷言")
                local bufflist = buff(unit)
                -- 直接计算百分比
                local jshp = UnitHealth(unit) / UnitHealthMax(unit) * 100
                
                if tempSkills["真言术：盾"] and jshp <= 20 and jshp > 0 and jn9 then
                    SetSquareColor(dqdx) -- 当前对象
                    SetSquareColor1(9) -- 真言术盾
                    local macroName = "真言术：盾"
                    local macroIndex = GetMacroIndexByName(macroName)
                    if macroIndex > 0 then  -- 确保宏存在
                        local Level = UnitLevel(unit)
                        if Level <= 6 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：盾(等级 1)")
                        elseif Level <= 12 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：盾(等级 2)")
                        elseif Level <= 18 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：盾(等级 3)")
                        elseif Level <= 24 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：盾(等级 4)")
                        elseif Level <= 30 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：盾(等级 5)")
                        elseif Level <= 36 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：盾(等级 6)")
                        elseif Level <= 42 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：盾(等级 7)")
                        elseif Level <= 48 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：盾(等级 8)")
                        elseif Level <= 54 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：盾(等级 9)")
                        elseif Level <= 60 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：盾(等级 10)")
                        end
                    end
                    return
                elseif tempSkills["恢复"] and jshp <= 90 and jshp > 0 and jn6 and hasBuff(bufflist,"恢复")==false then
                    SetSquareColor(dqdx) -- 当前对象
                    SetSquareColor1(6) --恢复
                    local macroName = "恢复"
                    local macroIndex = GetMacroIndexByName(macroName)
                    if macroIndex > 0 then  -- 确保宏存在
                        local Level = UnitLevel(unit)
                        if Level <= 10 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 恢复(等级 1)")
                        elseif Level <= 20 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 恢复(等级 2)")
                        elseif Level <= 30 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 恢复(等级 3)")
                        elseif Level <= 40 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 恢复(等级 4)")
                        elseif Level <= 50 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 恢复(等级 5)")
                        elseif Level <= 60 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 恢复(等级 6)")
                        end
                    end
                    return
                elseif tempSkills["治疗祷言"] and jshp <= 60 and jshp > 0 and jn5 and cxjs>=3 then
                    SetSquareColor(dqdx) -- 当前对象
                    SetSquareColor1(5) -- 治疗祷言
                    return
                elseif tempSkills["强效治疗术"] and jshp <= 60 and jshp > 0 and jn3 then
                    SetSquareColor(dqdx) -- 当前对象
                    SetSquareColor1(3) -- 强效治疗术
                    return
                elseif tempSkills["治疗术"] and jshp <= 60 and jshp > 0 and jn2 then
                    SetSquareColor(dqdx) -- 当前对象
                    SetSquareColor1(2) -- 治疗术
                    return
                elseif tempSkills["快速治疗"] and jshp <= 80 and jshp > 0 and jn4 then
                    SetSquareColor(dqdx) -- 当前对象
                    SetSquareColor1(4) -- 快速治疗
                    return
                elseif tempSkills["次级治疗术"] and jshp <= 80 and jshp > 0 and jn1 then
                    SetSquareColor(dqdx) -- 当前对象
                    SetSquareColor1(1) -- 次级治疗术
                    return
                end
            end
        end
    else
        JCch()--检查是否需要吃喝
        --脱战
        if IsInGroup() then--判断是否在队伍
            --队伍内 --对全队检查buff
            local numMembers = GetNumGroupMembers()--队员数量
            for n = 1, numMembers do
                local unit = (n == 1) and "player" or "party" .. (n - 1)
                local jshp = UnitHealth(unit) / UnitHealthMax(unit) * 100 -- 直接计算百分比
                -- 读取所有技能CD是否完毕
                local jn1 = CD("真言术：韧")
                local jn2 = CD("神圣之灵")
                local dxjl = JL(unit) -- 目标在30码以内

                local bufflist = buff(unit)
                local hasStrengthBuff = tempSkills["真言术.韧"] and jshp > 0 and jn1 and dxjl <= 30 and not hasBuff(bufflist, "真言术：韧")
                local hasWisdomBuff = tempSkills["神圣之灵"] and jshp > 0 and jn2 and dxjl <= 30 and not hasBuff(bufflist, "神圣之灵")

                if hasStrengthBuff then
                    SetSquareColor(n) -- 当前对象
                    SetSquareColor1(8) -- 真言术韧
                    local macroName = "真言术：韧"
                    local macroIndex = GetMacroIndexByName(macroName)
                    if macroIndex > 0 then  -- 确保宏存在
                        local Level = UnitLevel(unit)
                        if Level <= 10 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：韧(等级 1)")
                        elseif Level <= 20 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：韧(等级 2)")
                        elseif Level <= 30 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：韧(等级 3)")
                        elseif Level <= 40 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：韧(等级 4)")
                        elseif Level <= 50 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：韧(等级 5)")
                        elseif Level <= 60 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：韧(等级 6)")
                        end
                    end
                    return
                elseif hasWisdomBuff then
                    SetSquareColor(n) -- 当前对象
                    SetSquareColor1(10) -- 神圣之灵
                    local macroName = "神圣之灵"
                    local macroIndex = GetMacroIndexByName(macroName)
                    if macroIndex > 0 then  -- 确保宏存在
                        local Level = UnitLevel(unit)
                        if Level <= 20 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 神圣之灵(等级 1)")
                        elseif Level <= 30 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 神圣之灵(等级 2)")
                        elseif Level <= 40 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 神圣之灵(等级 3)")
                        elseif Level <= 50 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 神圣之灵(等级 4)")
                        elseif Level <= 60 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 神圣之灵(等级 5)")
                        end
                    end
                    return
                end
            end
            local bufflist = buff("player")
            local jn = CD("心灵之火")
            local jshp = UnitHealth("player") / UnitHealthMax("player") * 100 -- 直接计算百分比
            local zishenBuff = tempSkills["心灵之火"] and jshp and jn and not hasBuff(bufflist, "心灵之火")
            if zishenBuff then
                SetSquareColor(1) -- 当前对象
                SetSquareColor1(7) -- 神圣之灵
            end
        end
    end
end
local function ND()--小德
    SetSquareColor(8) -- 当前对象
    SetSquareColor1(19)
    local zdhp = 100 -- 假设最大血量为100
    local dqdx = 1 -- 默认值
    if Isparty1InCombat() then --判断是否战斗中
        --战斗中
        if IsInGroup() then--判断是否在队伍
            --队伍内 --对全队进行治疗
            local numMembers = GetNumGroupMembers()--队员数量
            for n = 1, numMembers do
                local unit = (n == 1) and "player" or "party" .. (n - 1)
                local debuff = JCdydebuff(unit, "德鲁伊")
                local jn1 = CD("消毒术") -- 冷却完毕
                local jn2 = CD("解除诅咒") -- 冷却完毕
                local dxjl = JL(unit)
    
                if debuff == 1 and jn1 and dxjl <= 30 then
                    SetSquareColor(n)
                    SetSquareColor1(8) -- 消毒术
                    return -- 找到需要驱散的目标后直接返回
                elseif debuff == 4 and jn2 and dxjl <= 30 then
                    SetSquareColor(n)
                    SetSquareColor1(9) -- 解除诅咒
                    return -- 找到需要驱散的目标后直接返回
                end
            end

            -- 检查治疗
            local cxjs = 0
            for n = 1, numMembers do
                local unit = (n == 1) and "player" or "party" .. (n - 1)
                local jshp = UnitHealth(unit) / UnitHealthMax(unit) * 100 -- 直接计算百分比
                if jshp <= 50 then
                    cxjs = cxjs + 1
                end 
                if jshp < zdhp then
                    zdhp = jshp
                    dqdx = n -- 最低血量玩家
                end
            end
            
            local unit = (dqdx == 1) and "player" or "party" .. (dqdx - 1)
            local sf = isPlayerCasting("player") -- 是否在施法
            local dxjl = JL(unit) -- 目标在30码以内
    
            if dxjl <= 30 and not sf then
                -- 读取所有技能CD是否完毕
                local jn1 = CD("治疗之触")
                local jn2 = CD("回春术")
                local jn3 = CD("愈合")
                local jn4 = CD("宁静")
                local jn5 = CD("激活")

                local bufflist = buff(unit)
                -- 直接计算百分比
                local jshp = UnitHealth(unit) / UnitHealthMax(unit) * 100 --当前对象血量
                local zsmp = UnitPower("player") / UnitPowerMax("player") * 100 -- 自身蓝量百分比
                local zshp = UnitHealth("player") / UnitHealthMax("player") * 100 -- 自身血量百分比
                if tempSkills["激活"] and jsmp <= 10 and zshp > 0 and jshp > 0 and jn4 then
                    SetSquareColor(dqdx) -- 当前对象
                    SetSquareColor1(4) -- 宁静
                    return
                elseif tempSkills["回春术"] and jshp <= 90 and jshp > 0 and jn2 and cxjs>=3 then
                    SetSquareColor(dqdx) -- 当前对象
                    SetSquareColor1(2) -- 回春术
                    return
                elseif tempSkills["治疗之触"] and jshp <= 60 and jshp > 0 and jn1 and cxjs>=3 then
                    SetSquareColor(dqdx) -- 当前对象
                    SetSquareColor1(1) -- 治疗之触
                    return
                elseif tempSkills["愈合"] and jshp <= 60 and jshp > 0 and jn3 and cxjs>=3 then
                    SetSquareColor(dqdx) -- 当前对象
                    SetSquareColor1(1) -- 愈合
                    return
                end
            end
        end
    else
        JCch()--检查是否需要吃喝
        --脱战
        if IsInGroup() then--判断是否在队伍
            --队伍内 --对全队检查buff
            local numMembers = GetNumGroupMembers()--队员数量
            for n = 1, numMembers do
                local unit = (n == 1) and "player" or "party" .. (n - 1)
                local jshp = UnitHealth(unit) / UnitHealthMax(unit) * 100 -- 直接计算百分比
                -- 读取所有技能CD是否完毕
                local jn1 = CD("真言术：韧")
                local jn2 = CD("神圣之灵")
                local dxjl = JL(unit) -- 目标在30码以内

                local bufflist = buff(unit)
                local hasStrengthBuff = tempSkills["真言术.韧"] and jshp > 0 and jn1 and dxjl <= 30 and not hasBuff(bufflist, "真言术：韧")
                local hasWisdomBuff = tempSkills["神圣之灵"] and jshp > 0 and jn2 and dxjl <= 30 and not hasBuff(bufflist, "神圣之灵")

                if hasStrengthBuff then
                    SetSquareColor(n) -- 当前对象
                    SetSquareColor1(8) -- 真言术韧
                    local macroName = "真言术：韧"
                    local macroIndex = GetMacroIndexByName(macroName)
                    if macroIndex > 0 then  -- 确保宏存在
                        local Level = UnitLevel(unit)
                        if Level <= 10 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：韧(等级 1)")
                        elseif Level <= 20 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：韧(等级 2)")
                        elseif Level <= 30 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：韧(等级 3)")
                        elseif Level <= 40 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：韧(等级 4)")
                        elseif Level <= 50 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：韧(等级 5)")
                        elseif Level <= 60 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 真言术：韧(等级 6)")
                        end
                    end
                    return
                elseif hasWisdomBuff then
                    SetSquareColor(n) -- 当前对象
                    SetSquareColor1(10) -- 神圣之灵
                    local macroName = "神圣之灵"
                    local macroIndex = GetMacroIndexByName(macroName)
                    if macroIndex > 0 then  -- 确保宏存在
                        local Level = UnitLevel(unit)
                        if Level <= 20 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 神圣之灵(等级 1)")
                        elseif Level <= 30 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 神圣之灵(等级 2)")
                        elseif Level <= 40 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 神圣之灵(等级 3)")
                        elseif Level <= 50 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 神圣之灵(等级 4)")
                        elseif Level <= 60 then
                            EditMacro(macroIndex, macroName, "INV_MISC_QUESTIONMARK", "/cast 神圣之灵(等级 5)")
                        end
                    end
                    return
                end
            end
            local bufflist = buff("player")
            local jn = CD("心灵之火")
            local jshp = UnitHealth("player") / UnitHealthMax("player") * 100 -- 直接计算百分比
            local zishenBuff = tempSkills["心灵之火"] and jshp and jn and not hasBuff(bufflist, "心灵之火")
            if zishenBuff then
                SetSquareColor(1) -- 当前对象
                SetSquareColor1(7) -- 神圣之灵
            end
        end
    end
end
DgrzsFrame:SetScript("OnUpdate", function ()
	--角色职业
	local playerProfession=GetPlayerInfoByGUID(UnitGUID("player"))
    if Gensui() then--检测是否需要跟随
        SetSquareColor(7)
        SetSquareColor1(19)
        return
    elseif UnitIsAFK("player") then--检测是否暂离
        SetSquareColor(1)
        SetSquareColor1(15)
        return
    else
        if playerProfession=="圣骑士" then
            NQ ()
        elseif playerProfession=="牧师" then
            MS ()
        end
    end
end)