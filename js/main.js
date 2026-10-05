// Funções compartilhadas por todas as páginas do site.

// Marca no menu a página que está aberta.
(function marcarMenu() {
  var pagina = location.pathname.split("/").pop() || "index.html";
  document.querySelectorAll("nav.menu a").forEach(function (link) {
    if (link.getAttribute("href") === pagina) link.classList.add("ativo");
  });
})();

// Ano no rodapé.
document.querySelectorAll("[data-ano]").forEach(function (el) {
  el.textContent = new Date().getFullYear();
});

// Diz se o site foi aberto pela VM (localhost) ou pela URL pública do ngrok.
function tipoDeAcesso() {
  var host = location.hostname;
  if (!host || host === "localhost" || host === "127.0.0.1" || host === "::1") return "local";
  if (/ngrok/.test(host)) return "ngrok";
  return "rede";
}

// Página "Acesso": preenche a tabela e o selo de status.
(function painelDeAcesso() {
  var tabela = document.getElementById("info-acesso");
  if (!tabela) return;

  var tipo = tipoDeAcesso();
  var selo = document.getElementById("selo-acesso");
  var textos = {
    local: ["Acesso local (dentro da VM)", "local"],
    ngrok: ["Acesso externo pelo ngrok", "ok"],
    rede: ["Acesso pela rede", "ok"]
  };
  selo.textContent = textos[tipo][0];
  selo.classList.add(textos[tipo][1]);

  var linhas = [
    ["Endereço completo", location.href],
    ["Servidor (host)", location.host],
    ["Protocolo", location.protocol.replace(":", "").toUpperCase()],
    ["Porta", location.port || (location.protocol === "https:" ? "443 (padrão HTTPS)" : "80 (padrão HTTP)")],
    ["Navegador", navigator.userAgent],
    ["Tela", screen.width + " x " + screen.height],
    ["Data e hora do acesso", new Date().toLocaleString("pt-BR")]
  ];
  tabela.innerHTML = linhas
    .map(function (l) { return "<tr><th>" + l[0] + "</th><td>" + l[1] + "</td></tr>"; })
    .join("");
})();

// Página "QR Code": gera o QR da URL pública.
(function geradorDeQr() {
  var alvo = document.getElementById("qrcode");
  if (!alvo || typeof QRCode === "undefined") return;

  var campo = document.getElementById("url-qr");
  var aviso = document.getElementById("aviso-qr");
  var raiz = location.href.replace(/[^/]*$/, ""); // pasta do projeto, ex.: https://xxxx.ngrok-free.app/projeto/

  // Se já estiver pelo ngrok, a própria URL vira o QR. Na VM, o aluno cola a URL do ngrok.
  campo.value = tipoDeAcesso() === "local" ? "" : raiz;

  var qr = new QRCode(alvo, { width: 240, height: 240, correctLevel: QRCode.CorrectLevel.M });

  function gerar() {
    var url = campo.value.trim();
    if (!url) {
      alvo.style.visibility = "hidden";
      aviso.textContent = "Cole aqui a URL HTTPS que o ngrok mostrou no terminal (ex.: https://xxxx.ngrok-free.app/projeto/).";
      return;
    }
    alvo.style.visibility = "visible";
    qr.makeCode(url);
    aviso.textContent = "QR Code gerado para: " + url;
  }

  document.getElementById("btn-gerar").addEventListener("click", gerar);
  campo.addEventListener("keydown", function (e) { if (e.key === "Enter") gerar(); });
  gerar();
})();

// Página "Checklist": guarda o progresso no navegador.
(function checklist() {
  var lista = document.getElementById("checklist");
  if (!lista) return;

  var chave = "ac2-checklist";
  var salvo = {};
  try { salvo = JSON.parse(localStorage.getItem(chave)) || {}; } catch (e) {}

  var caixas = lista.querySelectorAll("input[type=checkbox]");
  var barra = document.querySelector(".progresso div");
  var contador = document.getElementById("contador");

  function atualizar() {
    var feitos = 0;
    caixas.forEach(function (c) { if (c.checked) feitos++; salvo[c.id] = c.checked; });
    barra.style.width = (feitos / caixas.length) * 100 + "%";
    contador.textContent = feitos + " de " + caixas.length + " itens concluídos";
    try { localStorage.setItem(chave, JSON.stringify(salvo)); } catch (e) {}
  }

  caixas.forEach(function (c) {
    c.checked = !!salvo[c.id];
    c.addEventListener("change", atualizar);
  });
  atualizar();
})();
