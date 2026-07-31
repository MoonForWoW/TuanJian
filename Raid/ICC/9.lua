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
local bossIndex = 9
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
            title = L["1/5"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["2/6"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["3/7"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["4/8"],
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
                TJ.SetBoardEditFormNum(v, 2, 1, s2)
                done[1] = true
                done[2] = true
            elseif not done[3] then
                TJ.SetBoardEditFormNum(v, 3, 1, s1)
                TJ.SetBoardEditFormNum(v, 4, 1, s2)
                done[3] = true
                done[4] = true
            end
        end
        if not done[3] then
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)
            for i, v in ipairs(tbl) do
                for i = 1, 4 do
                    if not done[i] then
                        if TuanJian.talentInfo[v.name] == 4 then
                            TJ.SetBoardEditFormNum(v, i, 1, s1)
                        else
                            TJ.SetBoardEditFormNum(v, i, 1, s2)
                        end
                        done[i] = true
                        break
                    end
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
            for i, v in ipairs(tbl) do
                for i = 1, 4 do
                    if not done[i] then
                        TJ.SetBoardEditFormNum(v, i, 1, s1)
                        done[i] = true
                        break
                    end
                end
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
    local cd = 30
    local tbl = {
        {
            name = L["连线减伤链"],
            bossSpellID = 71336,
            arrange = 2,
            icon = 136151,
            id = 1,
            spell = spellTbl,
            sound = L["即将连线"],
            event = "SPELL_CAST_SUCCESS",
            canUpdate = true,
            autoNextSpell = true,
            startIndex = 1,
            bossTime = { 15, cd, cd, cd, cd, cd, cd, cd, cd, cd, },
        },
        AutoFuc = AutoFuc,
    }
    TJ.CreateBoard(FB, bossIndex, tbl)
    TJ.frame[FB][bossIndex].Board_SPELL_CAST_SUCCESS = function(info, ...)
        local tbl = { ... }
        local spellID = tbl[12]
        local bossSpellID = 71336
        -- BOSS施放群控时，下次连线的CD改为25秒
        if spellID == 73070 and info[bossSpellID] then
            TJ.Board_HideBar(bossSpellID)
            local board = TJ.frame[FB][bossIndex].board
            for _, child in pairs(board.child) do
                if child.bossSpellID == bossSpellID then
                    child.bossTime[info[bossSpellID].index] = 25
                    break
                end
            end
            info[bossSpellID].canUpdate = true
            info[bossSpellID].updateFrame.t = 0
        end
    end

    -- 站位图
    local function Sort(team)
        local team = TJ.Copy(team)
        local new = {}
        for i = 1, #team do
            for i, v in ipairs(team) do
                if v.class == "WARLOCK" then
                    tinsert(new, v)
                    tremove(team, i)
                end
            end
        end
        for i, v in ipairs(team) do
            tinsert(new, v)
        end
        return new
    end
    -- P1
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 257, -193 } },
            { point = "TOPLEFT", xy = { 402, -197 } },
            { point = "TOPLEFT", xy = { 239, -263 } },
            { point = "TOPLEFT", xy = { 417, -260 } },
            { point = "TOPLEFT", xy = { 329, -363 } },

            { point = "TOPLEFT", xy = { 190, -130 } },
            { point = "TOPLEFT", xy = { 161, -203 } },
            { point = "TOPLEFT", xy = { 152, -282 } },
            { point = "TOPLEFT", xy = { 165, -356 } },
            { point = "TOPLEFT", xy = { 251, -337 } },

            { point = "TOPLEFT", xy = { 453, -129 } },
            { point = "TOPLEFT", xy = { 489, -200 } },
            { point = "TOPLEFT", xy = { 503, -275 } },
            { point = "TOPLEFT", xy = { 495, -355 } },
            { point = "TOPLEFT", xy = { 403, -337 } },

            { point = "TOPLEFT", xy = { 267, -402 } },
            { point = "TOPLEFT", xy = { 391, -403 } },
            [100] = { xy = { 331, -72 }, isNPC = "b" .. bossIndex },
        }

        local function AutoFuc()
            local mapIndex = ""
            local team = TJ.GetRaidPointByTeam(5)
            if team then
                for i, v in ipairs(Sort(team)) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 1, max = 5 }, mapIndex)
                    end
                end
            end
            local team = TJ.GetRaidPointByTeam(3)
            if team then
                for i, v in ipairs(Sort(team)) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 6, max = 10 }, mapIndex)
                    end
                end
            end
            local team = TJ.GetRaidPointByTeam(4)
            if team then
                for i, v in ipairs(team) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 11, max = 15 }, mapIndex)
                    end
                end
            end
            local team = TJ.GetRaidPointByTeam(2)
            if team then
                for i, v in ipairs(team) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 1, max = 17 }, mapIndex)
                    end
                end
            end
            local team = TJ.GetRaidPointByTeam(1)
            if team then
                for i, v in ipairs(team) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 1, max = 17 }, mapIndex)
                    end
                end
            end
        end
        local text = {
            L["1-5：5队。"],
            L["6-10：3队。"],
            L["11-15：4队。"],
            L["16-17：1队/2队剩余的远程DPS。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["P1站位"],
            text)
        local map = TJ.CreateMap(FB, bossIndex, tbl, 650, 540)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["P1站位"])
    end
    -- P2
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 274, -187 } },
            { point = "TOPLEFT", xy = { 386, -188 } },
            { point = "TOPLEFT", xy = { 208, -271 } },
            { point = "TOPLEFT", xy = { 446, -272 } },
            { point = "TOPLEFT", xy = { 336, -430 } },

            { point = "TOPLEFT", xy = { 67, -177 } },
            { point = "TOPLEFT", xy = { 80, -281 } },
            { point = "TOPLEFT", xy = { 121, -371 } },
            { point = "TOPLEFT", xy = { 174, -452 } },
            { point = "TOPLEFT", xy = { 251, -368 } },

            { point = "TOPLEFT", xy = { 595, -160 } },
            { point = "TOPLEFT", xy = { 581, -266 } },
            { point = "TOPLEFT", xy = { 559, -354 } },
            { point = "TOPLEFT", xy = { 513, -444 } },
            { point = "TOPLEFT", xy = { 416, -364 } },

            { point = "TOPLEFT", xy = { 268, -488 } },
            { point = "TOPLEFT", xy = { 409, -491 } },

            { point = "TOPLEFT", xy = { 330, -270 } },
            { point = "TOPLEFT", xy = { 273, -98 } },
            { point = "TOPLEFT", xy = { 397, -100 } },
            { point = "TOPLEFT", xy = { 131, -77 } },
            { point = "TOPLEFT", xy = { 531, -78 } },
            { point = "TOPLEFT", xy = { 214, -26 } },
            { point = "TOPLEFT", xy = { 444, -22 } },
            { point = "TOPLEFT", xy = { 330, -20 } },
            { point = "TOPLEFT", xy = { 178, -169 } },
            { point = "TOPLEFT", xy = { 493, -171 } },
        }
        local function AutoFuc()
            local mapIndex = 2
            local team = TJ.GetRaidPointByTeam(5)
            if team then
                for i, v in ipairs(Sort(team)) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 1, max = 5 }, mapIndex)
                    end
                end
            end
            local team = TJ.GetRaidPointByTeam(3)
            if team then
                for i, v in ipairs(Sort(team)) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 6, max = 10 }, mapIndex)
                    end
                end
            end
            local team = TJ.GetRaidPointByTeam(4)
            if team then
                for i, v in ipairs(team) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 11, max = 15 }, mapIndex)
                    end
                end
            end
            local team = TJ.GetRaidPointByTeam(2)
            if team then
                for i, v in ipairs(team) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 1, max = 17 }, mapIndex)
                    end
                end
            end
            local team = TJ.GetRaidPointByTeam(1)
            if team then
                for i, v in ipairs(team) do
                    if TJ.Isdps2(v) or TJ.Ishealer(v) then
                        TJ.SetMapIconPlayer(v, { min = 1, max = 17 }, mapIndex)
                    end
                end
            end
            -- 近战
            do
                local tbl = TJ.SortRaidRosterInfo(nil, "dps1", true)
                for i, v in ipairs(tbl) do
                    TJ.SetMapIconPlayer(v, { min = 18, max = 27 }, mapIndex)
                end
            end
            -- 坦克
            do
                local tbl = TJ.SortRaidRosterInfo(nil, "tank", true)
                for i, v in ipairs(tbl) do
                    TJ.SetMapIconPlayer(v, { min = 18, max = 27 }, mapIndex)
                end
            end
        end
        local text = {
            L["1-5：5队。"],
            L["6-10：3队。"],
            L["11-15：4队。"],
            L["16-17：1队/2队剩余的远程DPS。"],
            L["18-27：坦克和近战DPS。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["P2站位"],
            text)
        local map = TJ.CreateMap(FB, bossIndex, tbl, 650, 540, 2)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["P2站位"])
    end
    -- 灵魂石
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST", "DRUID", "SHAMAN" }, "healer", true)
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
        local text = L["优先绑奶骑，然后绑其他治疗。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_soulgem", L["灵魂石"],
            text, nil, updateFuc, info)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
    -- 连线
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                71340,
                            },
                            colorNum = 1,
                            frameLevel = 1,
                            tooltip = "health",
                        },
                    },
                }
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
        local f = TJ.CreateTitle(FB, bossIndex, nil, 136151, L["连线"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 吸血撕咬
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            70867, 70949, 70879, -- 鲜血女王的精华
                        },
                        colorNum = 1,
                        frameLevel = 1,
                    },
                    {
                        spellID = {
                            70923, -- 失心疯
                        },
                        colorNum = 5,
                        frameLevel = 2,
                    },
                },
            },
            castSuccess = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            71726, 70946, -- 吸血撕咬
                        },
                        colorNum = 4,
                        frameLevel = 5,
                    },
                }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 134298, L["吸血撕咬"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 蜂拥之影
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            71265,
                        },
                        colorNum = 1,
                        frameLevel = 1,
                        tooltip = "health",
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 236279, L["蜂拥之影"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 防恐结界
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            6346, -- 防护恐惧结界
                        },
                        colorNum = 1,
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_excorcism", L["防恐结界"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 血箭溅射误伤
    do
        local info = {
            damageFriend = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            71447,
                        },
                        colorNum = 1
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 237564, L["血箭溅射误伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.frame[FB][bossIndex].SPELL_CAST_SUCCESS = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 73070 then -- 群控
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime() + 12,
                name = "P1",
            })
        end
    end
end
