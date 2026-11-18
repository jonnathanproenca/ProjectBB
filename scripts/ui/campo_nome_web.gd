class_name CampoNomeWeb
extends Node
## Campo de texto HTML real, transparente, sobreposto ao campo do Godot no navegador do celular.
## Motivo: o iOS Safari só abre o teclado quando o próprio toque do usuário cai num <input> do DOM
## (ou quando .focus() roda de forma síncrona no evento). O Godot processa o toque no loop de quadros,
## tarde demais, então o toque precisa chegar direto no <input>, sem passar pelo Godot.

signal texto_mudou(texto: String)
signal foco_mudou(com_foco: bool)
signal confirmado(texto: String)

const JS_CRIAR := """
(function (id, valor, max, dica) {
	var antigo = document.getElementById(id);
	if (antigo) { antigo.remove(); }
	var el = document.createElement('input');
	el.id = id;
	el.type = 'text';
	el.value = valor;
	el.maxLength = max;
	el.setAttribute('autocomplete', 'off');
	el.setAttribute('autocorrect', 'off');
	el.setAttribute('autocapitalize', 'words');
	el.setAttribute('spellcheck', 'false');
	el.setAttribute('enterkeyhint', 'done');
	el.setAttribute('aria-label', dica);
	// font-size 16px evita o zoom automático do iOS ao focar. Opacidade baixa (não zero) mantém o campo tocável.
	el.style.cssText = 'position:fixed;left:0;top:0;width:10px;height:10px;margin:0;padding:0;border:0;'
		+ 'outline:none;background:transparent;color:transparent;caret-color:transparent;'
		+ 'font-size:16px;opacity:0.02;z-index:30;touch-action:manipulation;-webkit-appearance:none;border-radius:0;';
	el.addEventListener('input', function () { window[id + '_input'](el.value); });
	el.addEventListener('focus', function () { window[id + '_foco'](true); });
	el.addEventListener('blur', function () { window[id + '_foco'](false); });
	el.addEventListener('keydown', function (e) {
		if (e.key === 'Enter') { e.preventDefault(); window[id + '_enter'](el.value); el.blur(); }
	});
	document.body.appendChild(el);
})
"""

var _id: String = ""
var _cb_input: JavaScriptObject
var _cb_foco: JavaScriptObject
var _cb_enter: JavaScriptObject
var _alvo: Control
var _max_len: int = 20


## Cria o <input> sobre o controle alvo. Só funciona no navegador; fora dele não faz nada.
func iniciar(alvo: Control, valor: String, max_len: int, dica: String) -> void:
	if not OS.has_feature("web"):
		return
	_alvo = alvo
	_max_len = max_len
	_id = "bb_nome_%d" % get_instance_id()
	var janela := JavaScriptBridge.get_interface("window")
	# Os callbacks precisam ficar guardados em variáveis, senão o Godot os libera.
	_cb_input = JavaScriptBridge.create_callback(_ao_digitar)
	_cb_foco = JavaScriptBridge.create_callback(_ao_focar)
	_cb_enter = JavaScriptBridge.create_callback(_ao_confirmar)
	janela[_id + "_input"] = _cb_input
	janela[_id + "_foco"] = _cb_foco
	janela[_id + "_enter"] = _cb_enter
	JavaScriptBridge.eval("(%s)(%s, %s, %d, %s)" % [
		JS_CRIAR, JSON.stringify(_id), JSON.stringify(valor), max_len, JSON.stringify(dica)], true)
	get_window().size_changed.connect(posicionar)
	alvo.resized.connect(posicionar)
	posicionar()
	# Layout dos containers só se resolve no quadro seguinte; reposiciona de novo.
	posicionar.call_deferred()
	get_tree().process_frame.connect(posicionar, CONNECT_ONE_SHOT)


## Alinha o <input> exatamente sobre o campo do Godot (pixels CSS da página).
func posicionar() -> void:
	if _id.is_empty() or not is_instance_valid(_alvo) or not _alvo.is_inside_tree():
		return
	var rect_viewport := _alvo.get_global_rect()
	var rect_canvas: Rect2 = get_window().get_final_transform() * rect_viewport
	var tela: Variant = JavaScriptBridge.eval(
		"(function(){var c=document.getElementById('canvas');if(!c){return null;}"
		+ "var r=c.getBoundingClientRect();return [c.width,c.height,r.left,r.top,r.width,r.height];})()", true)
	if tela == null:
		return
	var dados: Array = _para_array(tela)
	if dados.size() < 6:
		return
	var rect_css := CampoWebRules.rect_css(
		rect_canvas,
		Vector2(float(dados[0]), float(dados[1])),
		Rect2(float(dados[2]), float(dados[3]), float(dados[4]), float(dados[5])))
	var modelo := ("(function(){var e=document.getElementById(%s);if(!e){return;}"
		+ "e.style.left='%spx';e.style.top='%spx';e.style.width='%spx';e.style.height='%spx';})()")
	JavaScriptBridge.eval(modelo % [
		JSON.stringify(_id), rect_css.position.x, rect_css.position.y, rect_css.size.x, rect_css.size.y], true)


## Tira o foco do <input> (fecha o teclado), por exemplo ao tocar em Criar.
func fechar_teclado() -> void:
	if _id.is_empty():
		return
	JavaScriptBridge.eval("(function(){var e=document.getElementById(%s);if(e){e.blur();}})()" % JSON.stringify(_id), true)


## Troca o texto do <input> (usado pelo botão Aleatório, que não passa pelo teclado).
func definir_texto(texto: String) -> void:
	if _id.is_empty():
		return
	JavaScriptBridge.eval("(function(){var e=document.getElementById(%s);if(e){e.value=%s;}})()" % [JSON.stringify(_id), JSON.stringify(texto)], true)


func _exit_tree() -> void:
	if _id.is_empty():
		return
	JavaScriptBridge.eval("(function(){var e=document.getElementById(%s);if(e){e.remove();}})()" % JSON.stringify(_id), true)
	var janela := JavaScriptBridge.get_interface("window")
	janela[_id + "_input"] = null
	janela[_id + "_foco"] = null
	janela[_id + "_enter"] = null
	_id = ""


func _ao_digitar(args: Array) -> void:
	texto_mudou.emit(CampoWebRules.limpar_texto(str(args[0]), _max_len))


func _ao_focar(args: Array) -> void:
	foco_mudou.emit(bool(args[0]))


func _ao_confirmar(args: Array) -> void:
	confirmado.emit(CampoWebRules.limpar_texto(str(args[0]), _max_len))


## O eval devolve um JavaScriptObject para arrays; lê os elementos pelo índice.
func _para_array(valor: Variant) -> Array:
	if valor is Array:
		return valor
	var saida: Array = []
	if valor is JavaScriptObject:
		var obj: JavaScriptObject = valor
		for i in range(6):
			saida.append(obj[str(i)])
	return saida
