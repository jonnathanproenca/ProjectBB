class_name CharacterCreator
extends Control
## Criação de personagem em etapas, no estilo do Baldur's Gate 3: abas no topo, seletores com setas,
## retrato da espécie no centro e ficha à direita, com blocos de texto sobre painel escuro.
## Overlay sobre a seleção de perfil.
## Emite concluido(escolhas) ou cancelado e se remove sozinho.
## Imagens opcionais em assets/ui/criacao/ (sem arquivo, mostra cor sólida e texto):
##   fundo.png, especie_<id>_<masculino|feminino>.png (corpo inteiro, fundo transparente),
##   icone_<id>_<masculino|feminino>.png (busto com moldura redonda).
## Humanos usam o sprite da classe em assets/ui/classes/humano_<classe>_<sexo>.png; ao trocar a
## classe, a figura some de cima para baixo com uma borda de latão e vapor (ADR-064).
## Autômatos e mestiços seguem com o sprite da espécie até existirem as versões de classe.

signal concluido(escolhas: Dictionary)
signal cancelado

const PASTA_IMAGENS := "res://assets/ui/criacao/"
const PASTA_CLASSES := "res://assets/ui/classes/"
const IMAGEM_FUNDO := "res://assets/ui/criacao/fundo.png"
const DURACAO_TROCA: float = 0.7
const COR_LATAO := Color("c9a24a")
const COR_VAPOR := Color(0.92, 0.9, 0.85, 0.6)
const COR_FUNDO := Color("16181f")
const COR_SELECIONADO := Color("f2d28a")
const COR_NORMAL := Color.WHITE
const COR_APAGADO := Color(1, 1, 1, 0.45)
const COR_PAINEL := Color(0, 0, 0, 0.72)
const COR_BORDA_PAINEL := Color(0.95, 0.82, 0.54, 0.35)
const COR_TEXTO_CORRIDO := Color("f0e6d2")
const PASSOS: Array[String] = ["origem", "especie", "classe", "background", "habilidades", "pericias"]
const IDENTIDADES: Array[String] = ["masculino", "feminino"]
const LARGURA_PAINEL: float = 340.0
const MARGEM_PAINEL: float = 16.0
## Layout fixo (coordenadas de 1280x720): nada cresce nem encolhe ao trocar de classe.
## Altura: abas 60 + 22 + meio 492 + 22 + navegação 52 = 648 px, cabe em 720.
const ALTURA_CONTEUDO: float = 460.0
const LARGURA_ROLAGEM: float = 14.0
const TAMANHO_RETRATO := Vector2(260, 492)
const TAMANHO_ICONE := Vector2(84, 84)
const LARGURA_RESUMO: float = 260.0
const LARGURA_ABAS: float = 972.0
const TAMANHO_BOTAO_NAV := Vector2(200, 52)
## 7 abas: 7 x 132 + 6 x 8 = 972 px, cabe com folga na largura de 1280 (e em 1210 da captura).
const TAMANHO_ABA := Vector2(132, 44)
const ALTURA_LETRA_ABA: float = 22.0

## Escolhas iniciais: o personagem já é válido, como no BG3 (o jogador só troca o que quiser).
## "origem" guarda o Background (nome mantido para não quebrar o salvamento); "personagem" é só de exibição.
var _passo: int = 0
var _escolhas: Dictionary = {"especie": "humano", "identidade": "masculino", "classe": "guerreiro", "origem": "soldado", "personagem": "personalizado"}
var _nome: String = ""
var _raiz: VBoxContainer
## Retrato persistente: sobrevive às reconstruções de _montar() para a animação de troca não ser cortada.
var _quadro_retrato: Control
var _imagem_retrato: TextureRect
var _caminho_retrato: String = ""
var _sobreposicao_retrato: TextureRect
var _material_troca: ShaderMaterial
var _vapor_troca: CPUParticles2D
var _tween_retrato: Tween
var _shader_troca: Shader


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var cor := ColorRect.new()
	cor.color = COR_FUNDO
	cor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cor)

	var fundo := _textura(IMAGEM_FUNDO)
	if fundo != null:
		fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		fundo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		add_child(fundo)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)

	_raiz = VBoxContainer.new()
	_raiz.alignment = BoxContainer.ALIGNMENT_CENTER
	_raiz.add_theme_constant_override("separation", 22)
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centro.add_child(_raiz)
	_montar()


## Define o nome do perfil (já validado pela tela de seleção).
func configurar(nome: String) -> void:
	_nome = nome


func _montar() -> void:
	# Tira o retrato da árvore antes de liberar os filhos, para ele não ser apagado junto.
	if _quadro_retrato != null and _quadro_retrato.get_parent() != null:
		_quadro_retrato.get_parent().remove_child(_quadro_retrato)
	for filho in _raiz.get_children():
		_raiz.remove_child(filho)
		filho.queue_free()
	var painel_abas := _painel_escuro(_montar_abas(), 8.0)
	painel_abas.custom_minimum_size = Vector2(LARGURA_ABAS + 16.0, TAMANHO_ABA.y + 16.0)
	painel_abas.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	painel_abas.clip_contents = true
	_raiz.add_child(painel_abas)

	var meio := HBoxContainer.new()
	meio.alignment = BoxContainer.ALIGNMENT_CENTER
	meio.add_theme_constant_override("separation", 40)
	meio.add_child(_painel_fixo(_montar_painel(), LARGURA_PAINEL))
	meio.add_child(_obter_retrato())
	meio.add_child(_painel_fixo(_montar_resumo(), LARGURA_RESUMO))
	_raiz.add_child(meio)

	_raiz.add_child(_montar_navegacao())


## Abas no topo, como no BG3: a etapa atual fica dourada e as outras podem ser abertas direto.
func _montar_abas() -> Control:
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_theme_constant_override("separation", 8)
	for i in range(PASSOS.size()):
		var aba := UiKit.botao(UiText.t("passo_" + PASSOS[i]), ALTURA_LETRA_ABA, TAMANHO_ABA)
		aba.modulate = COR_SELECIONADO if i == _passo else COR_NORMAL
		aba.pressed.connect(_ir_para.bind(i))
		linha.add_child(aba)
	return linha


## Painel da esquerda: seletores e textos da etapa atual.
func _montar_painel() -> Control:
	var caixa := VBoxContainer.new()
	caixa.alignment = BoxContainer.ALIGNMENT_CENTER
	caixa.add_theme_constant_override("separation", 14)
	caixa.custom_minimum_size = Vector2(LARGURA_PAINEL - LARGURA_ROLAGEM, 0)
	caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var classe: String = str(_escolhas["classe"])
	var origem: String = str(_escolhas["origem"])
	var largura: float = LARGURA_PAINEL - LARGURA_ROLAGEM
	match PASSOS[_passo]:
		"origem":
			caixa.add_child(_seletor("personagem"))
			caixa.add_child(_paragrafo(UiText.t("personagem_desc_" + str(_escolhas["personagem"]))))
		"especie":
			caixa.add_child(_linha_icones())
			caixa.add_child(_seletor("especie"))
			caixa.add_child(_seletor("identidade"))
			caixa.add_child(UiKit.texto(_resumo_especie(), 18, UiKit.COR_TEXTO_DESTAQUE, largura))
		"classe":
			caixa.add_child(_seletor("classe"))
			caixa.add_child(UiKit.texto(_resumo_classe(), 18, UiKit.COR_TEXTO_DESTAQUE, largura))
			caixa.add_child(_paragrafo(UiText.t("classe_desc_" + classe)))
			caixa.add_child(UiKit.texto(UiText.t("pericias"), 19, UiKit.COR_TEXTO_DESTAQUE, largura))
			caixa.add_child(_paragrafo(_lista_pericias(classe, origem, false)))
		"background":
			caixa.add_child(_seletor("origem"))
			caixa.add_child(_paragrafo(UiText.t("background_desc_" + origem)))
		"habilidades":
			caixa.add_child(_paragrafo(UiText.t("habilidades_desc")))
			var finais := CharacterRules.atributos_finais(str(_escolhas["especie"]), classe)
			for atributo in CharacterRules.ATRIBUTOS:
				var valor: int = int(finais[atributo])
				caixa.add_child(UiKit.linha_atributo(UiText.t("attr_" + str(atributo)), valor, DndRules.ability_modifier(valor), 19))
		"pericias":
			caixa.add_child(_paragrafo(UiText.t("pericias_desc")))
			caixa.add_child(_paragrafo(_lista_pericias(classe, origem, true)))
	return caixa


## Retrato do centro (corpo inteiro, fundo transparente). Cria o quadro na primeira vez e depois só troca a imagem.
func _obter_retrato() -> Control:
	if _quadro_retrato == null:
		_criar_quadro_retrato()
	_trocar_retrato(_caminho_retrato_atual())
	return _quadro_retrato


func _criar_quadro_retrato() -> void:
	_quadro_retrato = Control.new()
	_quadro_retrato.custom_minimum_size = TAMANHO_RETRATO
	_quadro_retrato.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_quadro_retrato.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_quadro_retrato.clip_contents = true
	_quadro_retrato.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_imagem_retrato = _imagem_cheia()
	_quadro_retrato.add_child(_imagem_retrato)


func _imagem_cheia() -> TextureRect:
	var imagem := TextureRect.new()
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagem.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	imagem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	imagem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return imagem


## Caminho do sprite do retrato: humano com classe usa o sprite da classe; os demais, o da espécie.
func _caminho_retrato_atual() -> String:
	if str(_escolhas["especie"]) == "humano":
		var caminho_classe := "%shumano_%s_%s.png" % [PASTA_CLASSES, _escolhas["classe"], _escolhas["identidade"]]
		if ResourceLoader.exists(caminho_classe):
			return caminho_classe
	return _caminho_especie()


## Troca a imagem do retrato; se já havia uma, a antiga some de cima para baixo.
func _trocar_retrato(caminho: String) -> void:
	if caminho == _caminho_retrato or _imagem_retrato == null:
		return
	var anterior := _caminho_retrato
	_caminho_retrato = caminho
	var nova := _carregar(caminho)
	if nova == null:
		return
	_imagem_retrato.texture = nova
	var antiga: Texture2D = _carregar(anterior) if anterior != "" else null
	if antiga != null:
		_animar_troca(antiga)


func _animar_troca(antiga: Texture2D) -> void:
	if _tween_retrato != null and _tween_retrato.is_valid():
		_tween_retrato.kill()
	_limpar_efeitos_troca()
	if _shader_troca == null:
		_shader_troca = _criar_shader_troca()

	_sobreposicao_retrato = _imagem_cheia()
	_sobreposicao_retrato.texture = antiga
	_material_troca = ShaderMaterial.new()
	_material_troca.shader = _shader_troca
	_material_troca.set_shader_parameter("progress", 0.0)
	_sobreposicao_retrato.material = _material_troca
	_quadro_retrato.add_child(_sobreposicao_retrato)

	_vapor_troca = _criar_vapor()
	_quadro_retrato.add_child(_vapor_troca)

	_tween_retrato = create_tween()
	_tween_retrato.tween_method(_passo_troca, 0.0, 1.0, DURACAO_TROCA)
	_tween_retrato.finished.connect(_fim_troca)


func _passo_troca(progresso: float) -> void:
	if _material_troca == null or _vapor_troca == null:
		return
	_material_troca.set_shader_parameter("progress", progresso)
	var area := _area_imagem()
	_vapor_troca.position = Vector2(area.position.x + area.size.x * 0.5, area.position.y + area.size.y * progresso)


func _fim_troca() -> void:
	if _vapor_troca != null and is_instance_valid(_vapor_troca):
		_vapor_troca.emitting = false
		get_tree().create_timer(1.5).timeout.connect(_vapor_troca.queue_free)
		_vapor_troca = null
	if _sobreposicao_retrato != null and is_instance_valid(_sobreposicao_retrato):
		_sobreposicao_retrato.queue_free()
	_sobreposicao_retrato = null
	_material_troca = null


func _limpar_efeitos_troca() -> void:
	if _sobreposicao_retrato != null and is_instance_valid(_sobreposicao_retrato):
		_sobreposicao_retrato.queue_free()
	if _vapor_troca != null and is_instance_valid(_vapor_troca):
		_vapor_troca.queue_free()
	_sobreposicao_retrato = null
	_vapor_troca = null
	_material_troca = null


## Área do quadro onde a imagem aparece de fato (STRETCH_KEEP_ASPECT_CENTERED).
func _area_imagem() -> Rect2:
	var quadro := Rect2(Vector2.ZERO, TAMANHO_RETRATO)
	var tex: Texture2D = _imagem_retrato.texture if _imagem_retrato != null else null
	if tex == null:
		return quadro
	var escala := minf(quadro.size.x / tex.get_width(), quadro.size.y / tex.get_height())
	var tamanho := Vector2(tex.get_width(), tex.get_height()) * escala
	return Rect2((quadro.size - tamanho) * 0.5, tamanho)


func _criar_vapor() -> CPUParticles2D:
	var area := _area_imagem()
	var vapor := CPUParticles2D.new()
	vapor.emitting = true
	vapor.amount = 30
	vapor.lifetime = 0.9
	vapor.one_shot = false
	vapor.local_coords = false
	vapor.direction = Vector2(0, -1)
	vapor.spread = 40.0
	vapor.gravity = Vector2(0, -25)
	vapor.initial_velocity_min = 8.0
	vapor.initial_velocity_max = 36.0
	vapor.scale_amount_min = 3.0
	vapor.scale_amount_max = 9.0
	vapor.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	vapor.emission_rect_extents = Vector2(area.size.x * 0.5, 4.0)
	var degrade := Gradient.new()
	degrade.set_color(0, COR_VAPOR)
	degrade.set_color(1, Color(COR_VAPOR.r, COR_VAPOR.g, COR_VAPOR.b, 0.0))
	vapor.color_ramp = degrade
	return vapor


func _criar_shader_troca() -> Shader:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 brass_color : source_color = vec4(0.79, 0.64, 0.29, 1.0);
uniform float edge_width : hint_range(0.0, 0.2) = 0.04;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if (UV.y < progress) {
		discard;
	}
	float edge = (1.0 - smoothstep(0.0, edge_width, UV.y - progress)) * step(0.01, tex.a);
	COLOR = vec4(mix(tex.rgb, brass_color.rgb, edge * 0.9), tex.a);
}
"""
	return shader


## Ficha à direita, no estilo do BG3: nome, espécie, classe, background, atributos, PV e perícias.
## Reconstruída a cada escolha.
func _montar_resumo() -> Control:
	var caixa := VBoxContainer.new()
	caixa.alignment = BoxContainer.ALIGNMENT_CENTER
	caixa.add_theme_constant_override("separation", 4)
	caixa.custom_minimum_size = Vector2(LARGURA_RESUMO - LARGURA_ROLAGEM, 0)
	caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var largura: float = LARGURA_RESUMO - LARGURA_ROLAGEM
	var especie: String = str(_escolhas["especie"])
	var classe: String = str(_escolhas["classe"])
	var origem: String = str(_escolhas["origem"])
	var finais := CharacterRules.atributos_finais(especie, classe)

	# Título em letras pixel; detalhes em texto corrido (fonte padrão do Godot).
	if not _nome.is_empty():
		caixa.add_child(UiKit.titulo(_nome, 28, largura))
	caixa.add_child(UiKit.titulo(UiText.t("especie_" + especie), 22, largura))
	caixa.add_child(UiKit.titulo(UiText.t("classe_" + classe), 22, largura))
	caixa.add_child(UiKit.titulo(UiText.t("origem_" + origem), 22, largura))
	caixa.add_child(_espaco(6.0))
	for atributo in CharacterRules.ATRIBUTOS:
		var valor: int = int(finais[atributo])
		caixa.add_child(UiKit.linha_atributo(UiText.t("attr_" + str(atributo)), valor, DndRules.ability_modifier(valor), 17))
	caixa.add_child(_espaco(6.0))
	var pv := CharacterRules.pv_nivel_1(classe, int(finais["con"]))
	caixa.add_child(UiKit.texto("%s: %d" % [UiText.t("pv"), pv], 18, UiKit.COR_TEXTO, largura))
	caixa.add_child(_espaco(6.0))
	caixa.add_child(UiKit.texto(UiText.t("pericias"), 18, UiKit.COR_TEXTO_DESTAQUE, largura))
	for pericia in CharacterRules.pericias_finais(classe, origem):
		caixa.add_child(UiKit.texto(_nome_pericia(str(pericia)), 16, UiKit.COR_TEXTO, largura))
	return caixa


func _montar_navegacao() -> Control:
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_theme_constant_override("separation", 40)
	var voltar := UiKit.botao(UiText.t("cancelar") if _passo == 0 else UiText.t("voltar"), 26.0, TAMANHO_BOTAO_NAV)
	voltar.pressed.connect(_voltar)
	linha.add_child(voltar)
	var ultimo := _passo == PASSOS.size() - 1
	var avancar := UiKit.botao(UiText.t("concluir") if ultimo else UiText.t("avancar"), 26.0, TAMANHO_BOTAO_NAV)
	avancar.pressed.connect(_avancar)
	linha.add_child(avancar)
	return linha


## Seletor no estilo BG3: seta, nome da opção e seta. Dá a volta nas pontas.
func _seletor(chave: String) -> Control:
	var opcoes: Array = _opcoes(chave)
	var atual := maxi(opcoes.find(_escolhas[chave]), 0)
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_theme_constant_override("separation", 14)
	var esquerda := UiKit.seta(true, 34.0)
	esquerda.pressed.connect(_girar.bind(chave, -1))
	linha.add_child(esquerda)
	linha.add_child(UiKit.letras(_rotulo(chave, opcoes[atual]), 30.0, LARGURA_PAINEL - LARGURA_ROLAGEM - 110.0))
	var direita := UiKit.seta(false, 34.0)
	direita.pressed.connect(_girar.bind(chave, 1))
	linha.add_child(direita)
	return linha


## Linha de ícones das espécies (um por raça). Sem arquivo, mostra o nome curto.
func _linha_icones() -> Control:
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_theme_constant_override("separation", 18)
	for especie in _opcoes("especie"):
		var icone := Button.new()
		icone.flat = true
		icone.custom_minimum_size = TAMANHO_ICONE
		icone.tooltip_text = UiText.t("especie_" + str(especie))
		var textura := _carregar("%sicone_%s_%s.png" % [PASTA_IMAGENS, especie, _escolhas["identidade"]])
		if textura != null:
			icone.icon = textura
			icone.expand_icon = true
		else:
			icone.text = UiText.t("especie_" + str(especie)).substr(0, 3)
		icone.modulate = COR_SELECIONADO if especie == _escolhas["especie"] else COR_APAGADO
		icone.pressed.connect(_escolher.bind("especie", especie))
		linha.add_child(icone)
	return linha


func _girar(chave: String, passo: int) -> void:
	var opcoes: Array = _opcoes(chave)
	var atual := maxi(opcoes.find(_escolhas[chave]), 0)
	_escolhas[chave] = opcoes[posmod(atual + passo, opcoes.size())]
	_montar()


func _escolher(chave: String, valor: Variant) -> void:
	_escolhas[chave] = valor
	_montar()


func _ir_para(indice: int) -> void:
	_passo = indice
	_montar()


func _avancar() -> void:
	if _passo == PASSOS.size() - 1:
		var escolhas := _escolhas.duplicate()
		escolhas["nome"] = _nome
		concluido.emit(escolhas)
		queue_free()
		return
	_passo += 1
	_montar()


func _voltar() -> void:
	if _passo == 0:
		cancelado.emit()
		queue_free()
		return
	_passo -= 1
	_montar()


func _opcoes(chave: String) -> Array:
	match chave:
		"especie":
			return CharacterRules.ESPECIES.keys()
		"identidade":
			return IDENTIDADES.duplicate()
		"classe":
			return CharacterRules.CLASSES.keys()
		"origem":
			return CharacterRules.ORIGENS.keys()
		"personagem":
			return _chaves(CharacterRules.PERSONAGENS)
		_:
			return []


## Texto do seletor: "<prefixo>_<valor>" nos textos da interface.
func _rotulo(chave: String, valor: Variant) -> String:
	return UiText.t(chave + "_" + str(valor))


## Resumo de bônus da espécie escolhida (ex.: "CON +1  CAR +1").
func _resumo_especie() -> String:
	var especie: String = str(_escolhas["especie"])
	var bonus: Dictionary = (CharacterRules.ESPECIES[especie] as Dictionary)["bonus"]
	var partes := PackedStringArray()
	for atributo in CharacterRules.ATRIBUTOS:
		if bonus.has(atributo):
			partes.append("%s +%d" % [UiText.t("attr_" + atributo), int(bonus[atributo])])
	return "  ".join(partes)


## Dado de vida e PV no nível 1 da classe escolhida (muda ao trocar de classe).
func _resumo_classe() -> String:
	var classe: String = str(_escolhas["classe"])
	var dado: int = int((CharacterRules.CLASSES[classe] as Dictionary)["dado_vida"])
	var finais := CharacterRules.atributos_finais(str(_escolhas["especie"]), classe)
	var pv := CharacterRules.pv_nivel_1(classe, int(finais["con"]))
	return "%s: d%d   %s: %d" % [UiText.t("dado_vida"), dado, UiText.t("pv_nivel_1"), pv]


## Aceita Dictionary (usa as chaves) ou Array.
func _chaves(fonte: Variant) -> Array:
	if fonte is Dictionary:
		return (fonte as Dictionary).keys()
	return (fonte as Array).duplicate()


## Nome da perícia na interface; sem tradução, cai no id com a primeira letra maiúscula.
func _nome_pericia(id: String) -> String:
	var chave := "pericia_" + id
	var texto := UiText.t(chave)
	return id.capitalize() if texto == chave else texto


## Perícias finais, uma por linha. Com atributo, no formato "Atletismo (FOR)".
func _lista_pericias(classe: String, origem: String, com_atributo: bool) -> String:
	var linhas := PackedStringArray()
	for pericia in CharacterRules.pericias_finais(classe, origem):
		var linha := _nome_pericia(str(pericia))
		if com_atributo:
			var atributo: String = str((CharacterRules.PERICIAS[pericia] as Dictionary)["atributo"])
			linha += " (%s)" % UiText.t("attr_" + atributo)
		linhas.append(linha)
	return "\n".join(linhas)


## Painel escuro de tamanho fixo (largura x ALTURA_CONTEUDO) com rolagem vertical: se o texto passar da altura,
## rola dentro do painel e nunca empurra os outros elementos.
func _painel_fixo(conteudo: Control, largura: float) -> PanelContainer:
	conteudo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var rolagem := ScrollContainer.new()
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolagem.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	rolagem.custom_minimum_size = Vector2(largura, ALTURA_CONTEUDO)
	rolagem.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	rolagem.mouse_filter = Control.MOUSE_FILTER_PASS
	rolagem.add_child(conteudo)
	var painel := _painel_escuro(rolagem, MARGEM_PAINEL)
	painel.custom_minimum_size = Vector2(largura + 2.0 * MARGEM_PAINEL, ALTURA_CONTEUDO + 2.0 * MARGEM_PAINEL)
	painel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	painel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	painel.clip_contents = true
	return painel


## Painel escuro estilo BG3 (preto com alfa, cantos redondos e borda dourada discreta) atrás do conteúdo.
func _painel_escuro(conteudo: Control, margem: float) -> PanelContainer:
	var painel := PanelContainer.new()
	painel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = COR_PAINEL
	estilo.set_corner_radius_all(10)
	estilo.set_border_width_all(2)
	estilo.border_color = COR_BORDA_PAINEL
	estilo.set_content_margin_all(margem)
	painel.add_theme_stylebox_override("panel", estilo)
	painel.add_child(conteudo)
	return painel


## Texto corrido com quebra de linha (as letras recortadas não quebram), claro sobre o painel escuro.
func _paragrafo(texto: String) -> Label:
	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.custom_minimum_size = Vector2(LARGURA_PAINEL - LARGURA_ROLAGEM, 0)
	rotulo.add_theme_font_size_override("font_size", 18)
	rotulo.add_theme_color_override("font_color", COR_TEXTO_CORRIDO)
	rotulo.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	rotulo.add_theme_constant_override("outline_size", 2)
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rotulo


func _espaco(altura: float) -> Control:
	var vazio := Control.new()
	vazio.custom_minimum_size = Vector2(0, altura)
	return vazio


func _caminho_especie() -> String:
	return "%sespecie_%s_%s.png" % [PASTA_IMAGENS, _escolhas["especie"], _escolhas["identidade"]]


func _carregar(caminho: String) -> Texture2D:
	return load(caminho) as Texture2D if ResourceLoader.exists(caminho) else null


func _textura(caminho: String) -> TextureRect:
	var imagem := _carregar(caminho)
	if imagem == null:
		return null
	var tr := TextureRect.new()
	tr.texture = imagem
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr
