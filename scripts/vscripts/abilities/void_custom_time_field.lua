void_custom_time_field = class({})
LinkLuaModifier("modifier_void_custom_time_field_thinker", "abilities/void_custom_time_field.lua", LUA_MODIFIER_MOTION_NONE)

function void_custom_time_field:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    
    -- VALORES HARDCODED
    local duration_table = {1.0, 2.0, 3.0, 4.0}
    local duration = duration_table[self:GetLevel()] or 1.0
    local radius = 375 -- Raio padrão do Time Dilation

    -- Cria a unidade invisível que "pensa" a skill no chão
    CreateModifierThinker(
        caster,
        self,
        "modifier_void_custom_time_field_thinker",
        { duration = duration },
        point,
        caster:GetTeamNumber(),
        false
    )

    -- Som de ativação
    caster:EmitSound("Hero_FacelessVoid.TimeDilation.Cast")
end

--------------------------------------------------------------------------------
-- Modificador que fica no chão
modifier_void_custom_time_field_thinker = class({})

-- Define o alcance da conjuração (o círculo maior de onde o Void alcança)
function void_custom_time_field:GetCastRange(location, target)
    return 700 
end

-- Define o círculo de área no cursor (o círculo do efeito da skill)
function void_custom_time_field:GetAOERadius()
    return 375
end

function modifier_void_custom_time_field_thinker:OnCreated()
    if not IsServer() then return end
    
    self.radius = 375
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    
    -- Efeito Visual do Time Dilation PARADO no chão
    local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_dilation.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(pfx, 1, Vector(self.radius, 1, 1))
    self:AddParticle(pfx, false, false, -1, false, false)

    -- Começa a bater a cada 1 segundo
    self:StartIntervalThink(1.0)
    self:OnIntervalThink() -- Já trigga a primeira vez ao soltar
end

function modifier_void_custom_time_field_thinker:OnIntervalThink()
    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    -- Pega a skill de BASH (Time Lock) para usar os valores dela
    local ability_bash = self.caster:FindAbilityByName("faceless_void_time_lock")
    
    local bash_damage = 0
    local bash_duration = 0

    if ability_bash and ability_bash:GetLevel() > 0 then
        -- Puxa os valores direto da skill 3 (Hardcoded caso o KV falhe)
        local bash_lvl = ability_bash:GetLevel() - 1
        bash_damage = ability_bash:GetLevelSpecialValueFor("bonus_damage", bash_lvl)
        bash_duration = ability_bash:GetLevelSpecialValueFor("duration_creep", bash_lvl)
    end

    for _, enemy in pairs(enemies) do
        -- Efeito sonoro de Bash em cada um
        enemy:EmitSound("Hero_FacelessVoid.TimeLockImpact")
        
        -- Aplica o Stun (Duração do Bash)
        enemy:AddNewModifier(self.caster, ability_bash, "modifier_bashed", { duration = bash_duration })

        -- Aplica o Dano do Bash
        ApplyDamage({
            victim = enemy,
            attacker = self.caster,
            damage = bash_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability_bash
        })

        -- Efeito visual do Bash (As "mãozinhas" do Void)
        local pfx_bash = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
        ParticleManager:ReleaseParticleIndex(pfx_bash)
    end
end