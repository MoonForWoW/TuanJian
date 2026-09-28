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
local FB = "SOO"
local bossIndex = 1
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
    local mainFrame = TJ.frame[FB][bossIndex]

    -- P2煞能迸发减伤链
    local bossSpellID = 143498
    local splitSpellID = 143020
    local shaEruptionName = L["煞能迸发"]
    local shaEruptionTexture = C_Spell.GetSpellTexture(bossSpellID)
    TJ.AddBoard(mainFrame, function()
        local arrange = 6
        local spellTbl = {
            {
                title = L["1/5"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["2/6"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["3/7"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
            {
                title = L["4/8"],
                class = nil,
                spell = TJ.Board_TJ1,
            },
        }
        local function AutoFuc()
            TJ.Board_AutoAssignMitigation(#spellTbl, arrange)
        end

        local tbl = {
            {
                name = L["%s减伤链"]:format(shaEruptionName),
                bossSpellID = bossSpellID,
                arrange = arrange,
                icon = shaEruptionTexture,
                id = 1,
                spell = spellTbl,
                event = "BOSS_SAY",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 0,
                maxIndex = nil,
                bossTime = { 20, 20, 20, 20, },
                autoHide = true,
            },
            AutoFuc = AutoFuc,
        }

        mainFrame.Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            mainFrame.BOSS_SAY("spell:" .. splitSpellID)
        end

        mainFrame.BOSS_SAY = function(msg)
            if not msg:find("spell:" .. splitSpellID, 1, true) then return end
            local info = TJ.Board_info[bossSpellID]
            if not info then return end
            info.index = info.index + info.step
            info.canUpdate = true
            info.updateFrame.t = 0
        end

        -- /run TJ.Board_ENCOUNTER_START("SOO",1,true) TJ.frame["SOO"][1].BOSS_SAY("spell:143020")
        TJ.CreateBoard(FB, bossIndex, tbl)
    end)

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 232, -121 } },
            { point = "TOPLEFT", xy = { 367, -121 } },
            { point = "TOPLEFT", xy = { 396, -183 } },
            { point = "TOPLEFT", xy = { 368, -242 } },
            { point = "TOPLEFT", xy = { 231, -246 } },
            { point = "TOPLEFT", xy = { 204, -183 } },
            { point = "TOPLEFT", xy = { 123, -136 } },
            { point = "TOPLEFT", xy = { 150, -92 } },
            { point = "TOPLEFT", xy = { 219, -55 } },
            { point = "TOPLEFT", xy = { 264, -36 } },
            { point = "TOPLEFT", xy = { 341, -39 } },
            { point = "TOPLEFT", xy = { 396, -53 } },
            { point = "TOPLEFT", xy = { 461, -90 } },
            { point = "TOPLEFT", xy = { 488, -144 } },
            { point = "TOPLEFT", xy = { 510, -224 } },
            { point = "TOPLEFT", xy = { 490, -285 } },
            { point = "TOPLEFT", xy = { 426, -350 } },
            { point = "TOPLEFT", xy = { 177, -353 } },
            { point = "TOPLEFT", xy = { 126, -283 } },
            { point = "TOPLEFT", xy = { 107, -219 } },
            { point = "TOPLEFT", xy = { 236, -381 } },
            { point = "TOPLEFT", xy = { 302, -392 } },
            { point = "TOPLEFT", xy = { 365, -378 } },

            --[[


]]

        }
        local xy = {
            { 204, -90 },  -- 星星
            { 403, -93 },  -- 大饼
            { 440, -179 }, -- 紫菱
            { 409, -277 }, -- 三角
            { 192, -272 },
            { 155, -177 },
            { 625, -64 },
            { 623, -17 },
        }
        for index = 1, 8 do
            local left = mod((index - 1) / 4, 1);
            local right = left + 0.25;
            local top = floor((index - 1) / 4) * 0.25;
            local bottom = top + 0.25;
            tbl[index + 90] = {
                xy = xy[index],
                isNPC = true,
                isNPC_help = true,
                isNPC_icon = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
                coord = { left, right, top, bottom },
                notMask = true,
            }
        end

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo(nil, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["1-6号位：治疗。"],
            L["剩余位置：DPS。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["新图"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1436 * 1095, nil, nil, nil, "v2.3.1", '-2')
    end

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 237, -119 } },
            { point = "TOPLEFT", xy = { 367, -121 } },
            { point = "TOPLEFT", xy = { 396, -183 } },
            { point = "TOPLEFT", xy = { 368, -242 } },
            { point = "TOPLEFT", xy = { 237, -242 } },
            { point = "TOPLEFT", xy = { 206, -178 } },
            { point = "TOPLEFT", xy = { 123, -136 } },
            { point = "TOPLEFT", xy = { 150, -92 } },
            { point = "TOPLEFT", xy = { 219, -55 } },
            { point = "TOPLEFT", xy = { 264, -36 } },
            { point = "TOPLEFT", xy = { 341, -39 } },
            { point = "TOPLEFT", xy = { 396, -53 } },
            { point = "TOPLEFT", xy = { 461, -90 } },
            { point = "TOPLEFT", xy = { 488, -144 } },
            { point = "TOPLEFT", xy = { 510, -224 } },
            { point = "TOPLEFT", xy = { 490, -285 } },
            { point = "TOPLEFT", xy = { 426, -350 } },
            { point = "TOPLEFT", xy = { 177, -353 } },
            { point = "TOPLEFT", xy = { 126, -283 } },
            { point = "TOPLEFT", xy = { 107, -219 } },
            { point = "TOPLEFT", xy = { 236, -381 } },
            { point = "TOPLEFT", xy = { 302, -392 } },
            { point = "TOPLEFT", xy = { 365, -378 } },

            --[[

]]

        }
        local xy = {
            { 204, -90 },  -- 星星
            { 403, -93 },  -- 大饼
            { 440, -179 }, -- 紫菱
            { 409, -277 }, -- 三角
            { 192, -272 },
            { 155, -177 },
            { 625, -64 },
            { 623, -17 },
        }
        for index = 1, 8 do
            local left = mod((index - 1) / 4, 1);
            local right = left + 0.25;
            local top = floor((index - 1) / 4) * 0.25;
            local bottom = top + 0.25;
            tbl[index + 90] = {
                xy = xy[index],
                isNPC = true,
                isNPC_help = true,
                isNPC_icon = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
                coord = { left, right, top, bottom },
                notMask = true,
            }
        end

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo(nil, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, nil, 2)
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, nil, 2)
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, nil, 2)
            end
        end
        local text = {
            L["1-6号位：治疗。"],
            L["剩余位置：DPS。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["旧图"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1390 * 1059, 2, nil, nil, "v2.2.5")
    end

    TJ.CreateMapTab(mainFrame, FB, bossIndex)

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 腐蚀冲击
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 143436 },
                        colorNum = 1,
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 236302, L["腐蚀冲击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 漩涡伤害
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = { 143412 },
                        colorNum = 1,
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            canSend = "count",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 651082, L["漩涡承伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- P2转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    71603, -- 煞之水滴
                },
            },
            showRaidMember = true,
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 252178, L["转火黑软"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- P2治疗小怪
    do
        local info = {
            hps = {
                type = "s",
                destNPCID = {
                    71604, -- 污染之水滴
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 136007, L["治疗白软"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

end
