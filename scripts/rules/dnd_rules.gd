class_name DndRules
extends RefCounted
## Regras puras (sem nós de cena) baseadas no SRD 5.2.
## Funções estáticas para facilitar teste headless.

## Limiares de XP por nível (tabela de progressão do D&D 5e, mesma do SRD).
## Índice = nível alvo. Nível 1 = 0 XP.
const XP_THRESHOLDS: Array[int] = [
	0, 0, 300, 900, 2700, 6500, 14000, 23000, 34000, 48000, 64000,
	85000, 100000, 120000, 140000, 165000, 195000, 225000, 265000, 305000, 355000,
]

## Bônus de proficiência por nível (1-20).
static func proficiency_bonus(level: int) -> int:
	return 2 + int((clampi(level, 1, 20) - 1) / 4.0)


## Modificador de atributo: floor((valor - 10) / 2).
static func ability_modifier(score: int) -> int:
	return int(floor((score - 10) / 2.0))


## Nível correspondente a um total de XP, limitado ao nível máximo informado.
static func level_for_xp(xp: int, max_level: int) -> int:
	var level := 1
	for lv in range(2, mini(max_level, 20) + 1):
		if xp >= XP_THRESHOLDS[lv]:
			level = lv
	return level


## Dano com redução por defesa em razão: dano * K / (K + defesa).
## K é a defesa que reduz o dano pela metade. Evita imunidade por acúmulo.
## Arredonda somente no fim.
static func mitigated_damage(raw: float, defense: float, k: float = 20.0) -> int:
	if raw <= 0.0:
		return 0
	var dealt := raw * k / (k + maxf(defense, 0.0))
	return maxi(0, int(round(dealt)))


## Limite de resistência percentual (75% por padrão, convenção comum de RPG).
static func clamp_resistance(percent: float, cap: float = 75.0) -> float:
	return clampf(percent, -100.0, cap)


## Acerto de ataque (d20 + modificador contra CA). Crítico (20) sempre acerta; 1 sempre erra.
static func attack_hits(d20: int, mod: int, ac: int) -> bool:
	if d20 == 20:
		return true
	if d20 == 1:
		return false
	return d20 + mod >= ac
