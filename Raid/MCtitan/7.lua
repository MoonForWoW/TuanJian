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
local FB = "MCtitan"
local bossIndex = 7
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
    -- 自动标记
    local instanceID = TJ.FBinfo[FB].ID
    TJ.autoRaidTargetInfo[instanceID][11662] = TJ.autoRaidTargetIcon2

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    TJ.SetEditTextFormNum(v, title, 1)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "PALADIN" then
                    TJ.SetEditTextFormNum(v, title, 2)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "PALADIN" then
                    TJ.SetEditTextFormNum(v, title, 3)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["BOSS优先安排DKT，小怪优先安排防骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["BOSS坦"])
        TJ.CreateEdit(FB, bossIndex, L["小怪1坦"])
        TJ.CreateEdit(FB, bossIndex, L["小怪2坦"])
    end

    -- 打断小怪
    do
        local function AutoFuc(title)
            local tbl = CopyTable(TJ.SortRaidRosterInfo({ "DEATHKNIGHT", "ROGUE", "WARRIOR", "SHAMAN" }, "dps1", true))
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    tbl[i].index = 1
                elseif v.class == "ROGUE" then
                    tbl[i].index = 2
                elseif v.class == "WARRIOR" then
                    tbl[i].index = 3
                elseif v.class == "SHAMAN" then
                    tbl[i].index = 4
                end
            end
            local tbl2 = CopyTable(TJ.SortRaidRosterInfo({ "SHAMAN", "MAGE" }, "dps2", true))
            for i, v in ipairs(tbl2) do
                if v.class == "SHAMAN" then
                    tbl2[i].index = 5
                elseif v.class == "MAGE" then
                    tbl2[i].index = 6
                end
            end
            for _, v in pairs(tbl2) do
                tinsert(tbl, v)
            end

            sort(tbl, function(a, b)
                if a.index and b.index then
                    return a.index < b.index
                end
                return false
            end)
            local done = {}
            for _, v in ipairs(tbl) do
                for _, i in ipairs({ 1, 3, 5, 7, 2, 4, 6, 8 }) do
                    if not done[i] then
                        TJ.SetEditTextFormNum(v, title, i)
                        done[i] = true
                        break
                    end
                end
            end
        end
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 19775 },
                        },
                    },
                },
                title = { name = L["漏打断"], color = { 1, 0, 0 } },
                canSend = "count",
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                19775
                            },
                        },
                    },
                },
                title = { name = L["成功打断"] }
            },
        }
        local text = L["优先安排DK/盗贼/战士/增强萨，其次元素萨/法师。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_chilltouch", L["打断小怪加血"],
            text, nil, nil, info, nil,
            true, 2)
        TJ.CreateEdit(FB, bossIndex, TJ.SetRaidTargetingIcons(nil, "kulou") .. L["骷髅1断"])
        TJ.CreateEdit(FB, bossIndex, TJ.SetRaidTargetingIcons(nil, "kulou") .. L["骷髅2断"])
        TJ.CreateEdit(FB, bossIndex, TJ.SetRaidTargetingIcons(nil, "chacha") .. L["叉叉1断"])
        TJ.CreateEdit(FB, bossIndex, TJ.SetRaidTargetingIcons(nil, "chacha") .. L["叉叉2断"])
        TJ.CreateEdit(FB, bossIndex, TJ.SetRaidTargetingIcons(nil, "fangkuai") .. L["方块1断"])
        TJ.CreateEdit(FB, bossIndex, TJ.SetRaidTargetingIcons(nil, "fangkuai") .. L["方块2断"])
        TJ.CreateEdit(FB, bossIndex, TJ.SetRaidTargetingIcons(nil, "yueliang") .. L["月亮1断"])
        TJ.CreateEdit(FB, bossIndex, TJ.SetRaidTargetingIcons(nil, "yueliang") .. L["月亮2断"])
    end

    -- 驱散DEBUFF
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            dispel = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            20294, 19776,
                        },
                        colorNum = 1,
                        frameLevel = 1,
                    },
                },
                sourceNpcType = { "Player" },
            }
        }
        local text = L["只安排奶牧（驱散痛和献祭）。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_dispelmagic", L["驱散痛和献祭"],
            text, { "PRIEST", "PALADIN" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])

        TJ.AddDispelInfo(20294, 1, FB, bossIndex)
        TJ.AddDispelInfo(19776, 1, FB, bossIndex)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
end
