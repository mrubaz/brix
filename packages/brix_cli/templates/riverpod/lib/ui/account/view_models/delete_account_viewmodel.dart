import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';

/// Deletes the account of [identifier] after a code.
class DeleteAccountViewModel extends BrixDeleteAccountNotifier {
  DeleteAccountViewModel(this.identifier);

  final String identifier;

  @override
  DeleteAccountFlow createFlow() => DeleteAccountFlow(
    account: Dependencies.account,
    store: Dependencies.session,
    navigator: Dependencies.navigator,
    feedback: Dependencies.feedback,
    identifier: identifier,
  );
}

/// One per email.
final deleteAccountProvider = NotifierProvider.autoDispose
    .family<DeleteAccountViewModel, CodeEntryState, String>(
      DeleteAccountViewModel.new,
    );
