class_name ArenaTesteV2
extends ArenaTeste
## Tela de teste da V2 das arenas: mesmo gerador e mesmos controles, com tiles e props feitos no Blender.
## Manifesto: assets/arenas/manifesto_v2.json (tools/gerar_manifesto_arenas_v2.py).

const MANIFESTO_V2: String = "res://assets/arenas/manifesto_v2.json"


func _caminho_manifesto() -> String:
	return MANIFESTO_V2
