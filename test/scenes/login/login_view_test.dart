import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:carteira_digital/scenes/login/login_factory.dart';
import 'package:carteira_digital/scenes/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) => MaterialApp(theme: AppTheme.light(), home: home);

Widget _login({required void Function() onLoginSuccess}) => _app(
  LoginFactory.make(
    authRepository: InMemoryAuthRepository(),
    onLoginSuccess: onLoginSuccess,
  ),
);

void main() {
  testWidgets('LoginFactory.make builds the login scene', (tester) async {
    await tester.pumpWidget(_login(onLoginSuccess: () {}));

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('renders e-mail, password and primary button', (tester) async {
    await tester.pumpWidget(_login(onLoginSuccess: () {}));

    expect(find.byType(AppTextField), findsNWidgets(2));
    expect(find.byType(PasswordField), findsOneWidget);

    final button = tester.widget<AppButton>(
      find.byKey(const Key('login_submit')),
    );
    expect(button.variant, AppButtonVariant.primary);
  });

  testWidgets('empty fields show a message and do not sign in', (tester) async {
    var signedIn = false;
    await tester.pumpWidget(_login(onLoginSuccess: () => signedIn = true));

    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_error')), findsOneWidget);
    expect(signedIn, isFalse);
  });

  testWidgets('wrong password shows an error and does not sign in', (
    tester,
  ) async {
    var signedIn = false;
    await tester.pumpWidget(_login(onLoginSuccess: () => signedIn = true));

    await tester.enterText(
      find.byKey(const Key('login_email')),
      SampleData.user.email,
    );
    await tester.enterText(find.byKey(const Key('login_password')), 'errada');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_error')), findsOneWidget);
    expect(signedIn, isFalse);
  });

  testWidgets('right credentials sign in', (tester) async {
    var signedIn = false;
    await tester.pumpWidget(_login(onLoginSuccess: () => signedIn = true));

    await tester.enterText(
      find.byKey(const Key('login_email')),
      SampleData.user.email,
    );
    await tester.enterText(
      find.byKey(const Key('login_password')),
      SampleData.password,
    );
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(signedIn, isTrue);
  });
}
