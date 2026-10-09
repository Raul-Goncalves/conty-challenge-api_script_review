import 'package:test/test.dart';
import 'package:conty_challenge/core/errors/domain_exception.dart';
import 'package:conty_challenge/core/time/clock.dart';
import 'package:conty_challenge/src/domain/entities/script.dart';
import 'package:conty_challenge/src/domain/entities/script_status.dart';

void main() {
  group('Roteiro - Fluxo Temporal e Estados', () {
    final deadlineDay = DateTime.utc(2026, 10, 15);

    test('Deve aceitar nova versão no último instante do dia em São Paulo', () {
      final ultimoInstanteUtc = DateTime.utc(2026, 10, 16, 2, 59, 59, 999, 999);
      final clockNoFimDoDia = FixedClock(ultimoInstanteUtc);

      final script = Script(id: '1');
      script.addVersion('Versão 1', FixedClock(DateTime.utc(2026, 10, 15, 12)));
      script.requestChange(
        reason: 'Ajustar introdução',
        deadlineDate: deadlineDay,
        clock: FixedClock(DateTime.utc(2026, 10, 15, 13)),
      );

      expect(() => script.addVersion('Versão 2', clockNoFimDoDia), returnsNormally);
      expect(script.versions.length, equals(2));
      expect(script.status, equals(ScriptStatus.emAnalise));
    });

    test('Deve rejeitar nova versão no primeiro instante do dia seguinte em São Paulo', () {
      final primeiroInstanteSeguinteUtc = DateTime.utc(2026, 10, 16, 3, 0, 0, 0, 0);
      final clockExpirado = FixedClock(primeiroInstanteSeguinteUtc);

      final script = Script(id: '1');
      script.addVersion('Versão 1', FixedClock(DateTime.utc(2026, 10, 15, 12)));
      script.requestChange(
        reason: 'Ajustar CTA',
        deadlineDate: deadlineDay,
        clock: FixedClock(DateTime.utc(2026, 10, 15, 13)),
      );

      expect(
            () => script.addVersion('Versão 2', clockExpirado),
        throwsA(isA<DomainException>().having(
              (e) => e.message,
          'mensagem',
          contains('expirou'),
        )),
      );
    });

    test('Não deve expirar quando o dia virar em UTC mas ainda for o mesmo dia em São Paulo', () {
      final instanteViradaUtc = DateTime.utc(2026, 10, 16, 1, 0, 0);
      final clockViradaUtc = FixedClock(instanteViradaUtc);

      final script = Script(id: '1');
      script.addVersion('Versão 1', FixedClock(DateTime.utc(2026, 10, 15, 10)));
      script.requestChange(
        reason: 'Refazer gancho',
        deadlineDate: deadlineDay,
        clock: FixedClock(DateTime.utc(2026, 10, 15, 12)),
      );

      expect(() => script.addVersion('Versão 2', clockViradaUtc), returnsNormally);
    });

    test('Roteiro aprovado não deve aceitar novas versões nem pedidos de alteração', () {
      final script = Script(id: '1');
      final clock = SystemClock();

      script.addVersion('Versão final', clock);
      script.approve();

      expect(
            () => script.requestChange(
          reason: 'Mudança tardia',
          deadlineDate: DateTime.now().add(const Duration(days: 1)),
          clock: clock,
        ),
        throwsA(isA<DomainException>()),
      );

      expect(
            () => script.addVersion('Versão extra', clock),
        throwsA(isA<DomainException>()),
      );
    });
  });
}