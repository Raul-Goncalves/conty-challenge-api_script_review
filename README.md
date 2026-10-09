# Revisão de Roteiro - API & Domínio

Solução desenvolvida para modelar o fluxo de revisão de roteiros de campanhas com controle explícito de versões, transição de estados e validação precisa de prazos no fuso horário da marca (`America/Sao_Paulo`).

---

## 🎯 O que olhar primeiro

1. **Modelagem de Domínio (`lib/src/domain/entities/script.dart`):**
   * Agregado que encapsula as regras de transição de estado (`emAnalise`, `alteracaoSolicitada`, `aprovado`).
   * Imutabilidade após aprovação: encerra o ciclo e impede novos pedidos ou novas versões.
   * Preservação do histórico completo de versões e pedidos de alteração.

2. **Precisão de Fuso Horário (`lib/core/time/timezone_utils.dart`):**
   * O prazo da marca vence estritamente no último instante (`23:59:59.999999`) do fuso `America/Sao_Paulo` (UTC-3), normalizado em UTC para comparações temporais seguras.
   * Evita a virada precoce de prazo quando o relógio UTC muda de dia mas São Paulo ainda permanece no mesmo dia.

3. **Suíte de Testes com Relógio Controlado (`test/domain/script_test.dart`):**
   * Teste no último instante do dia permitido (operação válida).
   * Teste no primeiro instante (`00:00:00.000`) do dia seguinte (operação rejeitada).
   * Testes cobrindo a imutabilidade do status aprovado e a obrigatoriedade de motivo e prazo válido.

---

## 🚀 Como Executar

### Pré-requisitos
* Dart SDK `^3.0.0` (ou Flutter SDK instalado).

### Instalação de Dependências
```bash
dart pub get
