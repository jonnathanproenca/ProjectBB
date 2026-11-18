class_name ArenaCatalogo
extends RefCounted
## Lê o manifesto de assets das arenas (gerado por tools/gerar_manifesto_arenas.py).

const CAMINHO_PADRAO: String = "res://assets/arenas/manifesto.json"


static func carregar(caminho: String = CAMINHO_PADRAO) -> Dictionary:
	if not FileAccess.file_exists(caminho):
		return {}
	var dados = JSON.parse_string(FileAccess.get_file_as_string(caminho))
	if typeof(dados) != TYPE_DICTIONARY:
		return {}
	return dados
