# brix_getx

GetX controllers for [brix](https://pub.dev/packages/brix): the text fields, form key, loading state and dispose code of every auth and account screen – so a screen is only its layout.

| Controller | Screen |
|---|---|
| `BrixLoginController` | login, remember me, email pre-fill |
| `BrixSignupController` | signup (you add your own fields and build the request) |
| `BrixOtpController` | code after signup: boxes, paste / autofill, auto submit, resend countdown |
| `BrixForgotPasswordController` | forgot password |
| `BrixResetPasswordController` | reset password: code boxes + new password + checklist |
| `BrixChangePasswordController` | change password |
| `BrixProfileController` | profile load / save / avatar (you add your fields) |
| `BrixDeleteAccountController` | delete account with a code |
| `BrixSessionController` | splash (`start`) and logout |

Helpers: `OtpCodeBoxes` (one box per digit), `PasswordRulesTracker` (live password checklist).

All logic lives in [brix](https://pub.dev/packages/brix) – read its README first for the four classes you write (backend, storage, navigator, alerts).

### How a screen works

```
 View (layout only)          Controller (brix_getx)             Flow (brix)
 ──────────────────          ──────────────────────             ───────────
 TextFormField ◀──────────── identifierController
 FilledButton ──tap────────▶ login() ── validates form ───────▶ LoginFlow.submit
 spinner ◀── Obx ─────────── isSubmitting ◀──── changes ──────── state
 route closed ─────────────▶ onClose: text fields + flow disposed
```

## Install

```
flutter pub add brix_getx
```

One import gives you the controllers and all of brix:

```dart
import 'package:brix_getx/brix_getx.dart';
```

## Bindings

Each route gets its controller, and the controller gets its brix flow:

```dart
GetPage(
  name: '/login',
  page: () => const LoginScreen(),
  binding: BindingsBuilder(() {
    Get.put(BrixLoginController<User>(LoginFlow(
      provider: MyAuthProvider(api),
      store: MySessionStore(),
      navigator: MyNavigator(),
      feedback: MyFeedback(),
    )));
  }),
),
```

The controller disposes its flow and text fields when the route closes.

## Login

```dart
class LoginScreen extends GetView<BrixLoginController<User>> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(children: [
        TextFormField(controller: controller.identifierController),
        Obx(() => TextFormField(
          controller: controller.passwordController,
          obscureText: controller.obscurePassword.value,
        )),
        Obx(() => Checkbox(
          value: controller.rememberMe.value,
          onChanged: (_) => controller.toggleRememberMe(),
        )),
        Obx(() => FilledButton(
          onPressed: controller.isSubmitting.value ? null : controller.login,
          child: const Text('Log in'),
        )),
      ]),
    );
  }
}
```

"Remember me" fills the form on open. After a reset or a verified signup, call `controller.prefillIdentifier(email)` to fill the email.

## Signup

Add your own fields and say how the request is built:

```dart
class SignupController extends BrixSignupController<SignupBody, User> {
  SignupController(super.flow);

  final nameController = TextEditingController();
  final acceptedTerms = false.obs;

  @override
  SignupBody buildRequest({required String identifier, required String password}) =>
      SignupBody(name: nameController.text.trim(), email: identifier, password: password);

  /// Your own checks before the call.
  @override
  Future<bool> beforeSubmit() async {
    if (acceptedTerms.value) return true;
    Get.snackbar('Terms', 'Please accept the terms.');
    return false;
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
```

In the view: `identifierController`, `passwordController`, `confirmPasswordController`, `signup()`, `isSubmitting`, and the checklist from `passwordRules`:

```dart
Obx(() => Column(children: [
  for (final rule in controller.passwordRules.rules)
    Row(children: [
      Icon(controller.passwordRules.unmet.contains(rule)
          ? Icons.radio_button_unchecked
          : Icons.check_circle),
      Text(rule.labelFor(controller.passwordRules.policy)),
    ]),
]))
```

## Code screen (after signup)

```dart
class OtpScreen extends GetView<BrixOtpController<User>> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final boxes = controller.boxes;
    return Column(children: [
      Obx(() => Text('Code sent to ${controller.maskedIdentifier.value}')),
      Row(children: [
        for (var i = 0; i < boxes.length; i++)
          Expanded(child: TextField(
            controller: boxes.controllers[i],
            focusNode: boxes.focusNodes[i],
            keyboardType: TextInputType.number,
            autofillHints: i == 0 ? const [AutofillHints.oneTimeCode] : null,
            onChanged: (value) => boxes.onDigitChanged(i, value),
          )),
      ]),
      Obx(() => TextButton(
        onPressed: controller.resendSeconds.value > 0 ? null : controller.resend,
        child: Text(controller.resendSeconds.value > 0
            ? 'Resend in ${controller.resendSeconds.value}s'
            : 'Resend code'),
      )),
      TextButton(onPressed: controller.changeIdentifier, child: const Text('Change email')),
    ]);
  }
}
```

Typing or pasting the last digit verifies at once; a wrong code clears the boxes.

## Forgot and reset password

```dart
// Forgot: identifierController, submit(), isSubmitting.
Get.put(BrixForgotPasswordController(ForgotPasswordFlow(
  provider: provider, navigator: navigator, feedback: feedback,
)));

// Reset: the email comes from the route.
Get.put(BrixResetPasswordController(ResetPasswordFlow(
  provider: provider,
  navigator: navigator,
  feedback: feedback,
  identifier: Get.arguments as String,
  store: store,
)));
```

The reset screen uses the same `boxes`, `resendSeconds`, `resend()` and `changeIdentifier()` as the code screen, plus `formKey`, `newPasswordController`, `newPasswordFocus` (focused when the code is complete), `obscureNewPassword`, `passwordRules` and `submit()`.

## Splash and logout

```dart
Get.put(BrixSessionController<User>(SessionFlow(
  auth: provider, store: store, navigator: navigator, feedback: feedback,
)));

// Splash, after the first frame:
Get.find<BrixSessionController<User>>().start();

// Logout button:
Obx(() => TextButton(
  onPressed: controller.isLoggingOut.value ? null : controller.logout,
  child: const Text('Log out'),
))
```

## Account screens

```dart
// Change password: currentPasswordController, newPasswordController,
// confirmPasswordController, passwordRules, submit(), isSubmitting.
Get.put(BrixChangePasswordController(ChangePasswordFlow(
  account: account, store: store, navigator: navigator, feedback: feedback,
)));

// Delete account: requestDeletion() sends the code, then isCodeSent shows
// the boxes; confirm() deletes. isRequesting / isSubmitting for loaders.
Get.put(BrixDeleteAccountController(DeleteAccountFlow(
  account: account, store: store, navigator: navigator, feedback: feedback,
  identifier: currentUser.email,
)));
```

Profile – add your fields:

```dart
class ProfileController extends BrixProfileController<User, ProfileBody> {
  ProfileController(super.flow);

  final nameController = TextEditingController();

  @override
  void onUserLoaded(User user, {required bool fillForm}) {
    if (fillForm) nameController.text = user.name;
  }

  @override
  ProfileBody buildUpdate() => ProfileBody(name: nameController.text.trim());

  @override
  bool canSave() => nameController.text.trim() != user.value?.name;

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
```

The view uses `formKey`, `isLoading`, `loadFailed` (with `load()` as retry), `isSaving`, `save()`, and `uploadAvatar(AvatarUpload(...))` / `isUploadingAvatar`.

## Example app

[example/](https://github.com/mrubaz/brix/tree/main/packages/brix_getx/example) – login, signup with a code, forgot / reset password and logout on an in-memory demo backend. No server needed:

```
cd example
flutter run
```

Demo account `demo@brix.dev` / `Demo@1234`, every code `123456`.

## License

MIT
