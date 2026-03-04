LinkLuaModifier("modifier_bounty_hunter_jinada_custom", "abilities/bounty_hunter_jinada_custom", LUA_MODIFIER_MOTION_NONE)

bounty_hunter_jinada_custom = class({})

function bounty_hunter_jinada_custom:GetIntrinsicModifierName()
    return "modifier_bounty_hunter_jinada_custom"
end

--------------------------------------------------------------------------------

modifier_bounty_hunter_jinada_custom = class({})

function modifier_bounty_hunter_jinada_custom:IsHidden() return true end
function modifier_bounty_hunter_jinada_custom:IsPurgable() return false end

function modifier_bounty_hunter_jinada_custom:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_bounty_hunter_jinada_custom:OnAttackLanded(params)
    if not IsServer() then return end
    
    local parent = self:GetParent()
    local target = params.target
    local ability = self:GetAbility()

    -- Verifica se o atacante é o Bounty e se a skill tá upada e fora de cooldown
    if params.attacker == parent and ability:GetLevel() > 0 and ability:IsCooldownReady() and not parent:PassivesDisabled() then
        
        local level = ability:GetLevel()

        -- TABELAS DE VALORES (FORÇADO NO LUA)
        local damage_table = {70, 105, 140, 175}
        local gold_table = {10, 20, 30, 40}
        local cooldown_table = {9, 7, 5, 3}

        local bonus_damage = damage_table[level]
        local gold_gain = gold_table[level]
        local cooldown_time = cooldown_table[level]

        -- Efeito visual e som
        target:EmitSound("Hero_BountyHunter.Jinada")
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinada_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:ReleaseParticleIndex(particle)

        -- Aplica o Dano Bônus Físico
        local damageTable = {
            victim = target,
            attacker = parent,
            damage = bonus_damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = ability,
        }
        ApplyDamage(damageTable)

        -- Dá o Gold (Independente do alvo ser creep ou herói)
        parent:ModifyGold(gold_gain, true, DOTA_ModifyGold_Unspecified)
        
        -- Mostra o numerozinho de gold subindo no Bounty
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, parent, gold_gain, nil)

        -- Inicia o cooldown forçado
        ability:StartCooldown(cooldown_time)
    end
end