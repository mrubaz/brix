import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Gives [child] its view model: created when the screen opens, closed
/// when it goes away. Screens read it with `GetView` / `Get.find`.
class ViewModelScope<T extends GetxController> extends StatefulWidget {
  const ViewModelScope({
    super.key,
    required this.create,
    required this.child,
    this.onCreated,
  });

  final T Function() create;
  final Widget child;

  /// Runs once after the view model is made (e.g. to fill a field).
  final void Function(T viewModel)? onCreated;

  @override
  State<ViewModelScope<T>> createState() => _ViewModelScopeState<T>();
}

class _ViewModelScopeState<T extends GetxController>
    extends State<ViewModelScope<T>> {
  @override
  void initState() {
    super.initState();
    final viewModel = Get.put<T>(widget.create());
    widget.onCreated?.call(viewModel);
  }

  @override
  void dispose() {
    Get.delete<T>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
