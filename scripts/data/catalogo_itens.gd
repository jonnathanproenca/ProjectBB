class_name CatalogoItens
extends RefCounted
## Itens de exemplo do jogo, tirados de docs/ITENS.md (nome em português e descrição curta).
## Cada item: { "nome": String, "descricao": String }. A chave é o id do item.


static func itens() -> Dictionary:
	return {
		"adaga": {"nome": "Adaga", "descricao": "Arma leve. 1d4 perfurante, acuidade e arremesso (6/18 m)."},
		"espada_longa": {"nome": "Espada longa", "descricao": "Arma marcial. 1d8 cortante, versátil (1d10)."},
		"granada_de_vapor": {"nome": "Granada de vapor", "descricao": "Consumível de arremesso. 2d6 de dano de vapor em raio de 3 m."},
		"capacete_de_trincheira": {"nome": "Capacete de trincheira", "descricao": "Elmo simples. CA +1."},
		"botas_de_couro": {"nome": "Botas de couro", "descricao": "Sapatos leves. +1 em Furtividade em ruínas."},
		"anel_de_protecao": {"nome": "Anel de proteção", "descricao": "Anel com sintonia. CA +1."},
	}


## Dados do item, ou um Dictionary vazio se o id não existir.
static func obter(item_id: String) -> Dictionary:
	return itens().get(item_id, {})
