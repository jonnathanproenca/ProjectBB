class_name DialogoPrologo
extends RefCounted
## Árvore de diálogo de exemplo do prólogo: NPC com a quest "entregar_carta".
## Estado da quest nas flags: "quest_entregar_carta" (ver QuestRules).


static func arvore_inicial() -> Dictionary:
	return {
		"inicio": "n1",
		"nos": {
			"n1": {
				"texto": "Viajante! Preciso levar esta carta ao capitão da guarda, mas minhas pernas não aguentam mais.",
				"opcoes": [
					{
						"texto": "Eu levo a carta.",
						"proximo": "n_ajudou",
						"efeito": {"flag": "quest_entregar_carta", "valor": "ativa"},
					},
					{
						"texto": "Não tenho tempo para isso.",
						"proximo": "n_recusou",
						"efeito": {"flag": "recusou_carta", "valor": true},
					},
					{
						"texto": "Entreguei a carta ao capitão.",
						"proximo": "n_entregue",
						"condicao": {"flag": "quest_entregar_carta", "valor": "ativa"},
						"efeito": {"flag": "quest_entregar_carta", "valor": "concluida"},
					},
				],
			},
			"n_ajudou": {
				"texto": "Que os deuses o guiem! O capitão está no portão leste.",
				"opcoes": [],
			},
			"n_recusou": {
				"texto": "Entendo... Talvez outro viajante me ajude.",
				"opcoes": [],
			},
			"n_entregue": {
				"texto": "Você é um bom amigo. Aqui, fique com a minha gratidão.",
				"opcoes": [],
			},
		},
	}
