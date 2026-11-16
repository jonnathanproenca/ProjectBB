class_name UiText
extends RefCounted
## Textos fixos da interface por idioma. Chave ausente cai no português.

const STRINGS = {
	"pt": {
		"entrar": "Entrar", "opcoes": "Opções", "mapa": "Mapa", "voltar": "Voltar", "cancelar": "Cancelar",
		"idioma": "Idioma", "brilho": "Brilho", "opcoes_titulo": "Opções",
		"perfis_titulo": "Selecione um perfil", "novo_perfil": "Novo perfil", "criar": "Criar",
		"raca": "Raça", "classe": "Classe", "nivel": "Nível", "xp": "XP",
		"tempo_jogo": "Tempo de jogo", "nao_definido": "Não definido", "jogar": "Jogar",
		"em_breve": "Em breve", "slot_vazio": "Vazio", "nome_perfil": "Nome do perfil",
		"erro_nome_vazio": "Informe um nome.", "erro_nome_longo": "Use até 20 caracteres.",
		"excluir": "Excluir", "apagar": "Apagar", "confirmar_exclusao": "Apagar este perfil?",
		"h": "h", "min": "min",
	},
	"en": {
		"entrar": "Enter", "opcoes": "Options", "mapa": "Map", "voltar": "Back", "cancelar": "Cancel",
		"idioma": "Language", "brilho": "Brightness", "opcoes_titulo": "Options",
		"perfis_titulo": "Select a profile", "novo_perfil": "New profile", "criar": "Create",
		"raca": "Race", "classe": "Class", "nivel": "Level", "xp": "XP",
		"tempo_jogo": "Play time", "nao_definido": "Not set", "jogar": "Play",
		"em_breve": "Coming soon", "slot_vazio": "Empty", "nome_perfil": "Profile name",
		"erro_nome_vazio": "Enter a name.", "erro_nome_longo": "Use up to 20 characters.",
		"excluir": "Delete", "apagar": "Delete", "confirmar_exclusao": "Delete this profile?",
		"h": "h", "min": "min",
	},
	"es": {
		"entrar": "Entrar", "opcoes": "Opciones", "mapa": "Mapa", "voltar": "Volver", "cancelar": "Cancelar",
		"idioma": "Idioma", "brilho": "Brillo", "opcoes_titulo": "Opciones",
		"perfis_titulo": "Selecciona un perfil", "novo_perfil": "Nuevo perfil", "criar": "Crear",
		"raca": "Raza", "classe": "Clase", "nivel": "Nivel", "xp": "XP",
		"tempo_jogo": "Tiempo de juego", "nao_definido": "Sin definir", "jogar": "Jugar",
		"em_breve": "Próximamente", "slot_vazio": "Vacío", "nome_perfil": "Nombre del perfil",
		"erro_nome_vazio": "Escribe un nombre.", "erro_nome_longo": "Usa hasta 20 caracteres.",
		"excluir": "Eliminar", "apagar": "Eliminar", "confirmar_exclusao": "¿Eliminar este perfil?",
		"h": "h", "min": "min",
	},
}


static func t(key: String) -> String:
	var lang := TranslationServer.get_locale().substr(0, 2)
	var table: Dictionary = STRINGS.get(lang, STRINGS["pt"])
	return str(table.get(key, STRINGS["pt"].get(key, key)))
