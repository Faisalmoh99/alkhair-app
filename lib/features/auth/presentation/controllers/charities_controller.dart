import 'package:alkhair_app/core/errors/failures.dart';
import 'package:alkhair_app/core/providers/firebase_providers.dart';
import 'package:alkhair_app/features/auth/domain/entities/charity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'charities_controller.g.dart';

/// Thrown when the `Charities` reference list can't be loaded; carries the
/// underlying [Failure] so the UI can surface an Arabic message.
class CharitiesLoadException implements Exception {
  const CharitiesLoadException(this.failure);
  final Failure failure;
}

/// Loads the `Charities` list for the volunteer registration dropdown.
@riverpod
Future<List<Charity>> charities(CharitiesRef ref) async {
  final result = await ref.watch(authRepositoryProvider).fetchCharities();
  return result.fold(
    (failure) => throw CharitiesLoadException(failure),
    (list) => list,
  );
}
