extends Node
## Autoload "GameConfig". Fonte única de parâmetros de regra e de escopo.
## Limites do MVP ficam aqui, não espalhados pelo código.

## Tamanho máximo do grupo (party). Ajustar aqui; o código não assume 4 fixo.
const PARTY_MAX_SIZE: int = 4

## Número de slots de perfil na seleção após Entrar.
const PROFILE_SLOTS_MAX: int = 3

## Nível máximo do MVP. A regra do D&D vai até 20; aumentar aqui quando for liberado.
const MAX_LEVEL: int = 5

## Multiclasse liberada (regra de pré-requisito de atributo e de espaço de nível
## segue o SRD 5.2 / PHB).
const MULTICLASS_ENABLED: bool = true

## Arenas: quantos hexes de campo vizinhos recebem o mesmo tile (1 = sem agrupar).
## Agrupar deixa blocos contínuos, como um trecho de terra amarela, e reduz a sensação de bagunça.
const ARENA_AGRUPAMENTO_PADRAO: int = 3
const ARENA_AGRUPAMENTO_MAX: int = 6

## Versão da regra de referência.
const RULESET: String = "SRD 5.2"

## Modo de execução: "single" no MVP, "coop" depois.
var play_mode: String = "single"


func _ready() -> void:
	assert(PARTY_MAX_SIZE >= 1, "PARTY_MAX_SIZE deve ser >= 1")
	assert(MAX_LEVEL >= 1 and MAX_LEVEL <= 20, "MAX_LEVEL fora da faixa 1-20 do D&D")
