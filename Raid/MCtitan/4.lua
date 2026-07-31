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
local bossIndex = 4
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
    TJ.autoRaidTargetInfo[instanceID][12099] = TJ.autoRaidTargetIcon1

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

    -- 放逐小怪
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "WARLOCK" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            aura = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            18647
                        },
                    },
                },
            },
        }
        local text = L["安排术士。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_cripple", L["放逐小怪"],
            text, { "WARLOCK" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["放逐星星"] .. TJ.SetRaidTargetingIcons(nil, "xingxing"))
        TJ.CreateEdit(FB, bossIndex, L["放逐大饼"] .. TJ.SetRaidTargetingIcons(nil, "dabing"))
        TJ.CreateEdit(FB, bossIndex, L["放逐紫菱"] .. TJ.SetRaidTargetingIcons(nil, "ziling"))
        TJ.CreateEdit(FB, bossIndex, L["放逐三角"] .. TJ.SetRaidTargetingIcons(nil, "sanjiao"))
        TJ.CreateEdit(FB, bossIndex, L["放逐月亮"] .. TJ.SetRaidTargetingIcons(nil, "yueliang"))
        TJ.CreateEdit(FB, bossIndex, L["放逐方块"] .. TJ.SetRaidTargetingIcons(nil, "fangkuai"))
        TJ.CreateEdit(FB, bossIndex, L["放逐叉叉"] .. TJ.SetRaidTargetingIcons(nil, "chacha"))
        TJ.CreateEdit(FB, bossIndex, L["放逐骷髅"] .. TJ.SetRaidTargetingIcons(nil, "kulou"))
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
    -- 爆炸
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            19497,
                        },
                        colorNum = 1,
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_volcano", L["小怪爆炸"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
