local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local AddTexture = ns.AddTexture

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")


local T = {}
local FB = "ICC"
local bossIndex = 5
--[[
"DEATHKNIGHT"
"PALADIN"
"WARRIOR"
"SHAMAN"
"HUNTER"
"DRUID"
"ROGUE"
"MAGE"
"WARLOCK"
"PRIEST"
 ]]

TJ.Load[FB .. bossIndex] = function()
    -- 战术板
    local s1, s2, s3, s4, s5, s6, s7, s8
    local spellTbl = {
        {
            title = L["第1"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第2"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第3"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第4"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第5"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第6"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
    }
    local spellTbl2 = {
        {
            title = L["第1"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["第2"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
    }
    local function AutoFuc()
        local done = {}
        local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
        for i, v in ipairs(tbl) do
            if not done[1] then
                TJ.SetBoardEditFormNum(v, 1, 1, s1)
                TJ.SetBoardEditFormNum(v, 1, 2, s2)
                TJ.SetBoardEditFormNum(v, 4, 1, s1)
                TJ.SetBoardEditFormNum(v, 4, 2, s2)
                done[1] = true
                done[2] = true
                done[4] = true
                done[5] = true
            elseif not done[7] then
                TJ.SetBoardEditFormNum(v, 1, 1, s1, 2)
                TJ.SetBoardEditFormNum(v, 1, 2, s2, 2)
                TJ.SetBoardEditFormNum(v, 2, 1, s1, 2)
                TJ.SetBoardEditFormNum(v, 2, 2, s2, 2)
                done[7] = true
            end
        end
        local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
        for i, v in ipairs(tbl) do
            if not done[3] then
                TJ.SetBoardEditFormNum(v, 2, 1, s1)
                done[3] = true
                break
            end
        end
        local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)
        for i, v in ipairs(tbl) do
            if not done[6] then
                if TuanJian.talentInfo[v.name] == 4 then
                    TJ.SetBoardEditFormNum(v, 5, 1, s1)
                else
                    TJ.SetBoardEditFormNum(v, 5, 1, s2)
                end
                done[6] = true
                break
            end
        end
    end
    TJ.OnUpdateTime(function(self, t)
        if ns.isLoaded then
            self:SetScript("OnUpdate", nil)
            self:Hide()
            s1, s2, s3, s4, s5, s6, s7, s8 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7, ns.s8
        end
    end)
    local cd = 12
    local tbl = {
        {
            name = L["孢子减伤链"],
            bossSpellID = 69278,
            arrange = 2,
            icon = 237514,
            id = 1,
            spell = spellTbl,
            sound = L["准备孢子减伤"],
            event = "SPELL_AURA_APPLIED",
            canUpdate = false,
            autoNextSpell = nil,
            startIndex = 1,
            bossTime = { cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, },
        },
        {
            name = L["刺鼻毒气减伤链"],
            bossSpellID = 69195,
            arrange = 2,
            icon = 136118,
            id = 2,
            spell = spellTbl2,
            sound = L["即将刺鼻毒气"],
            event = "SPELL_CAST_SUCCESS",
            canUpdate = false,
            autoNextSpell = nil,
            startIndex = 1,
            bossTime = { 30.5, 30.5, 30.5, },
        },
        AutoFuc = AutoFuc,
    }
    TJ.CreateBoard(FB, bossIndex, tbl)
    local new = true
    local hxCount = 0
    TJ.frame[FB][bossIndex].Board_ENCOUNTER_START = function(info)
        new = true
        hxCount = 0
    end
    TJ.frame[FB][bossIndex].Board_SPELL_AURA_APPLIED = function(info, ...)
        if not new then return end
        local tbl = { ... }
        local spellID = tbl[12]
        local bossSpellID = 69278 -- 毒气孢子
        if spellID == bossSpellID and info[bossSpellID] then
            new = nil
            After(2, function() new = true end)
            info[bossSpellID].canUpdate = true
            info[bossSpellID].updateFrame.t = 0
            After(12.5, function()
                if info[bossSpellID] then
                    TJ.Board_HideBar(bossSpellID)
                    info[bossSpellID].index = info[bossSpellID].index + info[bossSpellID].step
                    info[bossSpellID].canUpdate = false
                    info[bossSpellID].updateFrame.t = 0
                end
            end)
        end
    end
    TJ.frame[FB][bossIndex].Board_SPELL_CAST_SUCCESS = function(info, ...)
        if not new then return end
        local tbl = { ... }
        local spellID = tbl[12]
        local bossSpellID = 69195 -- 凋零呼吸
        -- 凋零呼吸3层后开始刺鼻毒气的计时
        if spellID == 69165 and info[bossSpellID] then
            hxCount = hxCount + 1
            if hxCount >= 3 then
                hxCount = 0
                info[bossSpellID].canUpdate = true
                info[bossSpellID].updateFrame.t = 0
            end
        elseif spellID == bossSpellID and info[bossSpellID] then
            TJ.Board_HideBar(bossSpellID)
            info[bossSpellID].index = info[bossSpellID].index + info[bossSpellID].step
            info[bossSpellID].canUpdate = false
            info[bossSpellID].updateFrame.t = 0
        end
    end
    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 285, -419 } },
            { point = "TOPLEFT", xy = { 198, -356 } },
            { point = "TOPLEFT", xy = { 399, -410 } },
            { point = "TOPLEFT", xy = { 180, -282 } },
            { point = "TOPLEFT", xy = { 457, -347 } },
            { point = "TOPLEFT", xy = { 219, -475 } },
            { point = "TOPLEFT", xy = { 316, -503 } },
            { point = "TOPLEFT", xy = { 155, -418 } },
            { point = "TOPLEFT", xy = { 406, -488 } },
            { point = "TOPLEFT", xy = { 116, -347 } },
            { point = "TOPLEFT", xy = { 481, -443 } },
            { point = "TOPLEFT", xy = { 104, -265 } },
            { point = "TOPLEFT", xy = { 538, -377 } },
            { point = "TOPLEFT", xy = { 150, -199 } },
            { point = "TOPLEFT", xy = { 524, -300 } },
            [100] = { xy = { 329, -285 }, isNPC = "b" .. bossIndex },
        }
        local function AutoFuc()
            -- N
            do
                local tbl = TJ.SortRaidRosterInfo(TJ.healerClass, "healer", true)
                for i, v in ipairs(tbl) do
                    if v.class == "PALADIN" then
                        TJ.SetMapIconPlayerFormNum(2, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class ~= "PALADIN" then
                        TJ.SetMapIconPlayerFormNum(3, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class ~= "PALADIN" then
                        TJ.SetMapIconPlayerFormNum(1, v)
                        tremove(tbl, i)
                        break
                    end
                end
            end
            -- DPS
            do
                local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
                for i, v in ipairs(tbl) do
                    if v.class == "MAGE" or v.class == "PRIEST" then
                        TJ.SetMapIconPlayerFormNum(12, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "MAGE" or v.class == "PRIEST" then
                        TJ.SetMapIconPlayerFormNum(13, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "MAGE" or v.class == "PRIEST" then
                        TJ.SetMapIconPlayerFormNum(15, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "MAGE" or v.class == "PRIEST" then
                        TJ.SetMapIconPlayerFormNum(14, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    TJ.SetMapIconPlayer(v)
                end
            end
        end
        local text = {
            L["2奶骑，1/3其他治疗（剩余治疗近战位）。"],
            L["12-15优先安排FS/AM，剩余位置安排远程DPS。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        TJ.CreateMap(FB, bossIndex, tbl, 650, 625)
    end

    -- 灵魂石
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local function updateFuc(index)
            local count = 0
            for i, v in ipairs(TJ.raidRosterInfo) do
                if count >= 3 then break end
                if v.role ~= "MAINASSIST" and v.class == "WARLOCK" then
                    count = count + 1
                    local name = "|c" .. select(4, GetClassColor(v.class)) .. TJ.GetIconAndName(v) .. "|r"
                    TJ.CreateEdit(FB, bossIndex, name, index)
                end
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = ns.sp["灵魂石"],
                    },
                },
            }
        }
        local text = L["绑定坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_soulgem", L["灵魂石"],
            text, nil, updateFuc, info)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
    -- 孢子
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                69290, -- 孢子
                            },
                            colorNum = 1
                        },
                    },
                },
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                69195,
                            },
                            colorNum = 2,
                            frameLevel = 1,
                        },
                    },
                },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                31821, -- 光掌
                            },
                            colorNum = 4
                        },
                        {
                            spellID = {
                                70940, -- 大牺牲
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                    onlyShowMe = { 70940, 31821, 64843, 48447, 48446, 26983, },
                },
                title = { name = L["神圣牺牲/光环掌握"], icon = 64205 },
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 237514, L["孢子"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 疫苗
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            69291, -- 疫苗
                        },
                        colorNum = 1
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 136127, L["疫苗"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 邪恶毒气误伤
    do
        local info = {
            damageFriend = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            69244,
                        },
                        colorNum = 1
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 132093, L["邪恶毒气误伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 延展
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72297,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_herb_evergreenmoss", L["延展"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
