import 'package:uuid/uuid.dart';
import '../../../core/errors/domain_exception.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/timezone_utils.dart';
import 'change_request.dart';
import 'script_status.dart';
import 'script_version.dart';

class Script {
  final String id;
  ScriptStatus _status;
  final List<ScriptVersion> _versions = [];
  final List<ChangeRequest> _changeRequests = [];

  Script({
    required this.id,
    ScriptStatus initialStatus = ScriptStatus.emAnalise,
  }) : _status = initialStatus;

  ScriptStatus get status => _status;
  List<ScriptVersion> get versions => List.unmodifiable(_versions);
  List<ChangeRequest> get changeRequests => List.unmodifiable(_changeRequests);

  void addVersion(String content, Clock clock) {
    if (_status == ScriptStatus.aprovado) {
      throw const DomainException('Roteiro aprovado não aceita nova versão.');
    }

    if (_versions.isNotEmpty) {
      if (_status != ScriptStatus.alteracaoSolicitada) {
        throw const DomainException('A versão atual ainda está sob análise.');
      }

      final lastRequest = _changeRequests.last;
      if (clock.now().isAfter(lastRequest.deadlineUtc)) {
        throw const DomainException('O prazo para envio de uma nova versão expirou.');
      }
    }

    final newVersion = ScriptVersion(
      id: const Uuid().v4(),
      number: _versions.length + 1,
      content: content,
      createdAt: clock.now(),
    );

    _versions.add(newVersion);
    _status = ScriptStatus.emAnalise;
  }

  void requestChange({
    required String reason,
    required DateTime deadlineDate,
    required Clock clock,
  }) {
    if (_status == ScriptStatus.aprovado) {
      throw const DomainException('Roteiro aprovado não aceita novo pedido de alteração.');
    }
    if (_versions.isEmpty) {
      throw const DomainException('Não é possível solicitar alteração sem existir uma versão.');
    }
    if (reason.trim().isEmpty) {
      throw const DomainException('Pedido de alteração sem motivo não passa.');
    }

    final deadlineUtc = TimezoneUtils.endOfDayInSaoPaulo(deadlineDate);
    final currentInstant = clock.now();

    if (deadlineUtc.isBefore(currentInstant)) {
      throw const DomainException('Pedido de alteração com prazo que já passou não vale.');
    }

    _status = ScriptStatus.alteracaoSolicitada;
    _changeRequests.add(
      ChangeRequest(
        id: const Uuid().v4(),
        reason: reason,
        deadlineUtc: deadlineUtc,
        createdAt: currentInstant,
      ),
    );
  }

  void approve() {
    if (_status == ScriptStatus.aprovado) {
      throw const DomainException('O roteiro já está aprovado.');
    }
    if (_versions.isEmpty) {
      throw const DomainException('Não é possível aprovar um roteiro sem versões.');
    }
    _status = ScriptStatus.aprovado;
  }
}