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
local bossIndex = 13
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
"MONK"
 ]]

TJ.Load[FB .. bossIndex] = function()
    local mainFrame = TJ.frame[FB][bossIndex]

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 281, -136 } },
            { point = "TOPLEFT", xy = { 421, -131 } },
            { point = "TOPLEFT", xy = { 279, -288 } },
            { point = "TOPLEFT", xy = { 418, -287 } },
            { point = "TOPLEFT", xy = { 189, -202 } },
            { point = "TOPLEFT", xy = { 513, -205 } },
            { point = "TOPLEFT", xy = { 202, -127 } },
            { point = "TOPLEFT", xy = { 501, -134 } },
            { point = "TOPLEFT", xy = { 200, -281 } },
            { point = "TOPLEFT", xy = { 502, -277 } },
            { point = "TOPLEFT", xy = { 266, -68 } },
            { point = "TOPLEFT", xy = { 445, -69 } },
            { point = "TOPLEFT", xy = { 257, -354 } },
            { point = "TOPLEFT", xy = { 449, -358 } },
            { point = "TOPLEFT", xy = { 351, -57 } },
            { point = "TOPLEFT", xy = { 352, -363 } },
            [100] = { xy = { 348, -211 }, isNPC = "b" .. bossIndex },
        }

        --[[

]]
        local xy = {
            { 122, -203 }, -- 星星
            { 583, -207 }, -- 大饼
            { 724, -266 }, -- 紫菱
            { 725, -215 }, -- 三角
            { 725, -164 },
            { 724, -115 },
            { 724, -71 },
            { 725, -21 },
        }
        for index = 1, 8 do
            local left = mod((index - 1) / 4, 1);
            local right = left + 0.25;
            local top = floor((index - 1) / 4) * 0.25;
            local bottom = top + 0.25;
            tbl[index + 80] = {
                xy = xy[index],
                isNPC = true,
                isNPC_help = true,
                isNPC_icon = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
                coord = { left, right, top, bottom },
                notMask = true,
            }
        end

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "DRUID", "PRIEST", }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "PRIEST" }, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo({ "HUNTER", "DRUID", "MAGE", "WARLOCK", }, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["1-4号位：治疗。"],
            L["5-6号位：优先元素萨/暗牧。"],
            L["剩余位置：远程DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 700
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1823 * 1070, nil, nil, nil, "v2.2.5")
    end

    -- -- 本周击杀顺序
    -- do
    --     local text = {
    --         L["英杰的登场顺序每周变化。根据开战前的“准备战斗”标记填写本周击杀顺序。"],
    --         L["一只英杰死亡后，其余存活英杰会恢复满血，因此不要对非击杀目标进行无意义的顺劈和多目标输出。"],
    --         L["优先处理考尔文、伊约库克等会严重限制团队的组合，并根据下一只登场英杰及时调整。"],
    --     }
    --     TJ.CreateTitle(FB, bossIndex, nil, "ability_creature_poison_03", L["本周击杀顺序"], text)
    --     for i = 1, 9 do
    --         TJ.CreateEdit(FB, bossIndex, L["第%s击杀"]:format(i))
    --     end
    -- end

    --[=[     -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for _, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = {
            L["两名坦克分别承受场上的可坦克英杰。斯基尔和里卡尔同时在场时不能由同一坦克承受。"],
            L["夏柯希尔和基尔鲁克同时在场时也必须分开承受。里卡尔、夏柯希尔坦克持续使用主动减伤，避免注射或腐蚀之血叠层。"],
            L["考尔文盾击当前坦克后，另一名坦克立即嘲讽，避免恶毒突袭连续命中被击晕的坦克。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass)
        TJ.CreateEdit(FB, bossIndex, L["坦克1"])
        TJ.CreateEdit(FB, bossIndex, L["坦克2"])
    end

    -- 瞄准分摊
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for _, v in ipairs(TJ.SortRaidRosterInfo(nil, "healer", true)) do
                tinsert(tbl, v)
            end
            local num = GetNumGroupMembers() > 15 and 8 or 4
            for i = 1, num do
                if tbl[i] then
                    TJ.SetEditTextFormNum(tbl[i], title, i)
                end
            end
        end
        local text = {
            L["瞄准目标站到希塞克远处，分摊人员在BOSS与目标之间排成直线。"],
            L["所有分摊人员彼此保持5码，避免射击后生成的音波共鸣互相误伤。未被安排的玩家离开射击直线。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_hisek_aim", L["瞄准分摊"], text)
        for i = 1, 8 do
            TJ.CreateEdit(FB, bossIndex, L["分摊%s"]:format(i))
        end
    end

    -- 关键转火
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for _, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = {
            L["放血出现后所有DPS立即击杀血球，控制手负责减速、定身或击退，不能让血球接触英杰回血。"],
            L["有人被催眠时立即转火其行进方向上的饥饿的昆虫，打掉其30%生命值即可救人。"],
            L["出现琥珀寄生虫时优先击杀；被变成琥珀蝎的玩家使用捕食直接消灭寄生虫。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_warrior_cleave", L["关键转火"], text)
        TJ.CreateEdit(FB, bossIndex, L["血球控制1"])
        TJ.CreateEdit(FB, bossIndex, L["血球控制2"])
        TJ.CreateEdit(FB, bossIndex, L["吞噬者主攻1"])
        TJ.CreateEdit(FB, bossIndex, L["吞噬者主攻2"])
    end

    -- 英杰之力
    do
        local function AutoFuc(title)
            local used = {}
            for _, v in ipairs(title.edits) do
                if v.edit.player then
                    used[v.edit.player] = true
                end
            end
            local function SetPlayer(tbl, num)
                for _, v in ipairs(tbl) do
                    if not used[v.name] and TJ.SetEditTextFormNum(v, title, num) then
                        used[v.name] = true
                        return
                    end
                end
            end

            local melee = TJ.SortRaidRosterInfo(nil, "dps1", true)
            local ranged = TJ.SortRaidRosterInfo(nil, "dps2", true)
            local dps = {}
            for _, v in ipairs(melee) do
                tinsert(dps, v)
            end
            for _, v in ipairs(ranged) do
                tinsert(dps, v)
            end
            local tanks = TJ.SortRaidRosterInfo(TJ.tankClass, "tank", true)
            local healers = TJ.SortRaidRosterInfo(nil, "healer", true)
            local all = TJ.SortRaidRosterInfo(nil, nil, true)

            SetPlayer(melee, 1)   -- 嗜血
            SetPlayer(ranged, 3)  -- 复眼
            SetPlayer(dps, 4)     -- 强壮的腿
            SetPlayer(tanks, 5)   -- 琥珀大师
            SetPlayer(healers, 6) -- 聪慧
            SetPlayer(healers, 7) -- 药剂师知识
            SetPlayer(dps, 9)     -- 收割
            SetPlayer(all, 2)     -- 疯狂科学家
            SetPlayer(all, 8)     -- 操纵者大师
        end
        local text = {
            L["每只英杰死亡后只能由一名玩家领取其力量，每名玩家整场只能领取一次。"],
            L["嗜血优先近战，复眼优先远程；强壮的腿可保留用于摧毁考尔文的琥珀。考尔文和夏柯希尔的力量分别由坦克、治疗领取。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "inv_misc_volatilelife_green", L["英杰之力"], text)
        TJ.CreateEdit(FB, bossIndex, L["斯基尔：嗜血（DPS）"])
        TJ.CreateEdit(FB, bossIndex, L["里卡尔：疯狂科学家（任意）"])
        TJ.CreateEdit(FB, bossIndex, L["希塞克：复眼（DPS）"])
        TJ.CreateEdit(FB, bossIndex, L["卡罗兹：强壮的腿（DPS）"])
        TJ.CreateEdit(FB, bossIndex, L["考尔文：琥珀大师（坦克）"])
        TJ.CreateEdit(FB, bossIndex, L["伊约库克：聪慧（治疗）"])
        TJ.CreateEdit(FB, bossIndex, L["夏柯希尔：药剂师知识（治疗）"])
        TJ.CreateEdit(FB, bossIndex, L["卡兹提克：操纵者大师（任意）"])
        TJ.CreateEdit(FB, bossIndex, L["基尔鲁克：收割（DPS）"])
    end
 ]=]
    -- -- 团队减伤
    -- do
    --     local function AutoFuc(title)
    --         local tbl = TJ.SortRaidRosterInfo(nil, "healer", true)
    --         for _, v in ipairs(tbl) do
    --             TJ.SetEditText(v, title)
    --         end
    --     end
    --     local text = {
    --         L["本场技能组合随每周登场顺序变化，团队减伤主要留给火焰之刃、催化反应，以及英雄模式的快速射击或收割与其他技能重叠时。"],
    --         L["瞄准应依靠正确分摊，不能用团队减伤代替站位。"],
    --     }
    --     TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_powerwordbarrier", L["团队减伤"], text)
    --     for i = 1, 4 do
    --         TJ.CreateEdit(FB, bossIndex, L["团队减伤%s"]:format(i))
    --     end
    -- end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
    --[=[
    -- 瞄准
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 142948 },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                notShowDead = true,
                title = { name = L["瞄准点名"] },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 142950 },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["瞄准分摊承伤"] },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 144094 },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                canSend = "count",
                title = { name = L["音波共鸣误伤"] },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_hisek_aim", L["瞄准"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 暴食
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 143701 },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                canSend = "count",
                title = { name = L["被闪击冲锋命中"] },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 143735 },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                notShowDead = true,
                canSend = "count",
                title = { name = L["踩腐蚀琥珀"],icon=143735 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_druid_galewinds", L["暴食"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 火焰之刃
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = { 142808 },
                        colorNum = 2,
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            title = { name = L["火焰之刃承伤"] },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_iyyokuk_sword", L["火焰之刃"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 催眠
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 142671 },
                            colorNum = 5,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["催眠点名"] },
            },
            {
                dps = {
                    type = "s",
                    destNPCID = { 71420, 71425 },
                },
                showRaidMember = true,
                canSend = "dps",
                title = { name = L["饥饿/成熟的昆虫伤害"] },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_sleep", L["催眠救人"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 坦克机制
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 143339 },
                            colorNum = 2,
                            combatRole = { "Istank" },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["注射层数"] },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 143939 },
                            colorNum = 1,
                            combatRole = { "Istank" },
                        },
                        {
                            spellID = { 143974 },
                            colorNum = 2,
                            combatRole = { "Istank" },
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["凿击/盾击点名"] },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 143941 },
                            colorNum = 1,
                            combatRole = { "Istank" },
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["毁伤承伤"] },
            },
        }
        for _, v in ipairs(TJ.combatInfoTank) do
            tinsert(info, v)
        end
        local f = TJ.CreateTitle(FB, bossIndex, nil, "Spell_Deathknight_BloodPresence", L["坦克机制"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 需要躲避的技能
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 142232 },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                canSend = "count",
                title = { name = L["天降死神承伤"] },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 143768 },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                canSend = "count",
                title = { name = L["音波投射承伤"] },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_rogue_fanofknives", L["躲避技能"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 关键目标伤害
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = { 71542 },
                },
                showRaidMember = true,
                canSend = "dps",
                title = { name = L["血球"] },
            },
            {
                dps = {
                    type = "s",
                    destNPCID = { 71578 },
                },
                showRaidMember = true,
                canSend = "dps",
                title = { name = L["琥珀寄生虫"] },
            },
            {
                dps = {
                    type = "s",
                    destNPCID = { 71420, 71425 },
                },
                showRaidMember = true,
                canSend = "dps",
                title = { name = L["饥饿/成熟的昆虫"] },
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_cleave", L["关键目标伤害"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local paragonNames = {
        [71152] = L["觅血"],
        [71158] = L["切割"],
        [71155] = L["至尊"],
        [71153] = L["虫群"],
        [71157] = L["毒心"],
        [71160] = L["明澈"],
        [71156] = L["操纵"],
        [71161] = L["掠风"],
        [71154] = L["暴食"],
    }

    mainFrame.UNIT_DIED = function(...)
        local tbl = { ... }
        local name = paragonNames[TJ.GetNPCID(tbl[8])]
        if name then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = L["击杀%s"]:format(name),
            })
        end
    end ]=]
end
