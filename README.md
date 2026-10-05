# AC2 · Hospedagem de site em máquina virtual (Windows Server 2022 + IIS + ngrok)

Atividade prática da disciplina **Server and Data Center Administration** (FECAF, Prof. Nilvan Garcia de Almeida).

Site estático (HTML, CSS e JavaScript, sem back-end, API ou banco) para publicar no IIS de uma VM com Windows Server 2022 e expor na internet com o ngrok e um QR Code.

## Páginas do site

| Página | Para que serve |
|---|---|
| `index.html` | Apresentação da atividade e das tecnologias |
| `arquitetura.html` | Explica o papel da VM, do IIS e do ngrok (use na apresentação) |
| `acesso.html` | Mostra de onde o site foi aberto: `localhost` na VM ou domínio do ngrok no celular |
| `qrcode.html` | Gera o QR Code da URL pública (funciona offline, a biblioteca está em `js/`) |
| `checklist.html` | Checklist da apresentação, com progresso salvo no navegador |

## Passo a passo na VM

### Etapa 1: máquina virtual
1. Criar a VM no Hyper-V ou VirtualBox: **4 GB de RAM, 2 processadores, 40 GB de disco**.
2. Instalar o **Windows Server 2022** (Desktop Experience).
3. Conectar a VM à internet (placa de rede em NAT ou Default Switch) e instalar as atualizações.

### Etapa 2: preparar o Windows Server
1. Idioma Português (Brasil) e teclado ABNT2.
2. Instalar um navegador (Edge já vem no Server 2022).

### Etapas 2 e 3 de uma vez: script automático
Abra o **PowerShell como Administrador** dentro da VM e rode:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
Invoke-WebRequest https://raw.githubusercontent.com/gabrielcomercial401-ux/ac2-site-iis-ngrok/main/scripts/setup-vm.ps1 -OutFile setup-vm.ps1 -UseBasicParsing
.\setup-vm.ps1
```

O script:
- instala a função **Web Server (IIS)** com o console de gerenciamento;
- baixa este repositório e copia o site para `C:\inetpub\wwwroot\projeto` (com o `index.html` na raiz);
- testa `http://localhost/projeto/`;
- baixa o ngrok para `C:\ngrok`.

### Fazendo à mão (se preferir mostrar ao professor)
1. **Gerenciador do Servidor → Adicionar funções e recursos → Web Server (IIS)**.
2. Abrir `http://localhost` no navegador: a página padrão do IIS deve aparecer.
3. Baixar o ZIP deste repositório (**Code → Download ZIP**), extrair e copiar o conteúdo para `C:\inetpub\wwwroot\projeto`.
4. Abrir `http://localhost/projeto/`.

### Etapa 4: ngrok
1. Criar conta grátis em https://ngrok.com e copiar o **authtoken** em *Your Authtoken*.
2. Cadastrar o token (só uma vez, **não compartilhe o token**):
   ```powershell
   C:\ngrok\ngrok.exe config add-authtoken SEU_TOKEN
   ```
3. Abrir o túnel na mesma porta do IIS:
   ```powershell
   C:\ngrok\ngrok.exe http 80
   ```
   ou `.\scripts\iniciar-ngrok.ps1`, que testa o site local antes de ligar o túnel.
4. Copiar a URL HTTPS da linha **Forwarding** e acrescentar `/projeto/` no final, por exemplo `https://xxxx.ngrok-free.app/projeto/`.
5. Manter o terminal aberto durante todo o teste.

| IIS | Teste local | ngrok |
|---|---|---|
| Porta 80 (padrão) | `http://localhost/projeto/` | `ngrok http 80` |
| Porta 8080 | `http://localhost:8080/projeto/` | `ngrok http 8080` |

Erro 404 = endereço, pasta ou porta errada. Teste o site localmente antes de ligar o ngrok.

### Etapa 5: QR Code e validação
1. Abrir `http://localhost/projeto/qrcode.html` na VM, colar a URL do ngrok e clicar em **Gerar QR Code**.
2. Ler o QR com o celular **usando dados móveis** (fora do Wi-Fi da faculdade).
3. No plano grátis, o ngrok mostra uma tela de aviso antes do site: toque em **Visit Site**.
4. No celular, abrir a página **Acesso**: ela deve mostrar o domínio do ngrok e o selo "Acesso externo pelo ngrok".
5. Se o ngrok for reiniciado, a URL muda: gere outro QR Code.

## Roteiro curto para a apresentação

1. **VM**: "A VM é um computador virtual dentro do meu PC, com Windows Server 2022, 4 GB de RAM, 2 vCPUs e 40 GB. Ela é o servidor do projeto."
2. **IIS**: "O IIS é o servidor web do Windows. Ele escuta na porta 80 e entrega os arquivos que estão em `C:\inetpub\wwwroot\projeto`." Mostrar `http://localhost/projeto/`.
3. **ngrok**: "A VM não tem IP público. O ngrok abre um túnel de saída até a nuvem dele e me dá uma URL HTTPS pública que encaminha para a porta 80 do IIS." Mostrar o terminal com o Forwarding.
4. **QR Code**: ler o QR no celular, abrir a página **Acesso** e mostrar o domínio do ngrok.
5. Encerrar o ngrok com **Ctrl+C** depois da avaliação.

## Checklist

- [ ] A VM inicia
- [ ] O Windows está configurado
- [ ] O IIS está ativo
- [ ] O site abre localmente
- [ ] A porta está correta
- [ ] A URL abre no celular
- [ ] O QR Code abre o site
- [ ] A arquitetura foi explicada

## Estrutura

```
index.html  arquitetura.html  acesso.html  qrcode.html  checklist.html
css/style.css
js/main.js  js/qrcode.min.js   (qrcodejs 1.0.0, licença MIT)
scripts/setup-vm.ps1           instala IIS, publica o site e baixa o ngrok
scripts/iniciar-ngrok.ps1      testa o site local e abre o túnel
```
