# CNH Simulated

Aplicativo desktop para simular e revisar questões do exame teórico da CNH, com banco local e geração de novas perguntas por IA.

## O que inclui

- Simulação offline com perguntas armazenadas localmente
- Geração de questões com Google Gemini
- Salvar questões geradas no banco local
- Interface em PySide6 para estudo e revisão

## Estrutura

```text
CNH-Simulated/
├── core/         # configurações, estilos e carregamento de dados
├── json/         # banco local de questões
├── logic/        # fluxo de geração com Gemini
├── ui/           # telas e widgets da interface
├── main.py       # ponto de entrada da aplicação
├── pyproject.toml
├── build.sh      # empacotamento para Linux
├── LICENSE
└── README.md
```

## Requisitos

- Python 3.12+
- uv

## Como executar

```bash
git clone https://github.com/guilherme23x/CNH-Simulated.git
cd CNH-Simulated
uv sync
uv run main.py
```

## Configuração da IA

Para usar a geração de questões com IA:

1. Crie uma chave no Google AI Studio
2. Abra o app
3. Vá em Configurações
4. Insira a API key e escolha o modelo

A aplicação usa o modelo Gemini configurado para criar novas perguntas e pode salvar essas questões localmente para uso posterior.

## Build

Para empacotar a aplicação no Linux:

```bash
./build.sh
```
