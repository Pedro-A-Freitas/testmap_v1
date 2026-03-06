item_mkb_custom_2 = class({})
LinkLuaModifier("modifier_item_mkb_custom_2", "items/item_mkb_custom_2", LUA_MODIFIER_MOTION_NONE)

function item_mkb_custom_2:GetIntrinsicModifierName()
    return "modifier_item_mkb_custom_2"
end

--------------------------------------------------------------------------------

modifier_item_mkb_custom_2 = class({})

function modifier_item_mkb_custom_2:IsHidden() return true end
function modifier_item_mkb_custom_2:IsPurgable() return false end
function modifier_item_mkb_custom_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- =========================================================================
-- O SEGREDO ESTÁ AQUI: ESTADOS ABSOLUTOS
-- =========================================================================
function modifier_item_mkb_custom_2:CheckState()
    return {
        -- Esta linha desliga completamente o conceito de "Miss" para este herói.
        [MODIFIER_STATE_CANNOT_MISS] = true,
    }
end

function modifier_item_mkb_custom_2:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

-- BÔNUS DE DANO BASE (80)
function modifier_item_mkb_custom_2:GetModifierPreAttack_BonusDamage()
    return 80
end

-- BÔNUS DE ATTACK SPEED (90)
function modifier_item_mkb_custom_2:GetModifierAttackSpeedBonus_Constant()
    return 90
end

function modifier_item_mkb_custom_2:OnAttackLanded(params)
    if not IsServer() then return end
    
    if params.attacker ~= self:GetParent() then return end
    if params.target:IsBuilding() or params.target:IsOther() then return end

    local damage_extra = 140

    -- Aplica o dano mágico real que tira o HP
    ApplyDamage({
        victim = params.target,
        attacker = self:GetParent(),
        damage = damage_extra,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility()
    })

    -- =========================================================================
    -- A MÁGICA VISUAL: Faz o número 140 subir na tela do alvo
    -- =========================================================================
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, params.target, damage_extra, nil)

    -- Sons e Partículas
    params.target:EmitSound("DOTA_Item.MonkeyKingBar.Target")
    local pfx = ParticleManager:CreateParticle("particles/items_fx/monkey_king_bar_proc.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
    ParticleManager:ReleaseParticleIndex(pfx)
end