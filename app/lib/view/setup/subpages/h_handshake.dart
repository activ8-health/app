import 'package:activ8/managers/api/api_auth.dart';
import 'package:activ8/managers/api/api_worker.dart';
import 'package:activ8/managers/api/v1/register.dart';
import 'package:activ8/managers/api/v1/sign_in.dart';
import 'package:activ8/utils/logger.dart';
import 'package:activ8/utils/snackbar.dart';
import 'package:activ8/view/home_page.dart';
import 'package:activ8/view/setup/setup_state.dart';
import 'package:activ8/view/setup/widgets/large_icon.dart';
import 'package:activ8/view/widgets/custom_navigation_bar.dart';
import 'package:activ8/view/widgets/custom_text_field.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:activ8/view/widgets/styles.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

// Facilitates for signing up or signing in, handshaking with the server
class SetupHandshakePage extends StatefulWidget {
  final bool accountExists; // differentiates a sign-in from a register
  final SetupState setupState; // only location field is used when signing in
  final PageController pageController;

  const SetupHandshakePage({
    super.key,
    required this.setupState,
    required this.accountExists,
    required this.pageController,
  });

  @override
  State<SetupHandshakePage> createState() => _SetupHandshakePageState();
}

class _SetupHandshakePageState extends State<SetupHandshakePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _RegisterData registerData = _RegisterData();
  bool enableSubmit = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    // Check to validate the form shortly after opening this page
    Future.delayed(const Duration(milliseconds: 300), () {
      enableSubmit = (formKey.currentState?.validate() ?? false);
      setState(() {});
    });
  }

  /// Submits the [widget.setupState] using [registerData]
  void submitAction() async {
    loading = true;
    setState(() {});

    if (!widget.accountExists && !(widget.setupState.isComplete)) {
      showSnackBar(context, "ERROR: Form incomplete");
    }

    // Set up API host
    ApiWorker.instance.address = registerData.address;

    Future<bool> Function() action = (widget.accountExists) ? signInAction : registerAction;
    bool success = await action();

    if (success && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const HomePage(),
        ),
      );
    }

    setState(() {});
  }

  Future<bool> registerAction() async {
    // Make registration request
    V1RegisterBody body = V1RegisterBody(
      userProfile: widget.setupState.userProfile,
      healthData: widget.setupState.healthData!,
      userPreferences: widget.setupState.userPreferences,
      location: widget.setupState.location,
    );

    Auth auth = Auth(email: registerData.email, password: registerData.password);

    V1RegisterResponse response = await v1register(body, auth);

    if (!context.mounted) return false;

    // In case a custom message was provided
    if (response.errorMessage != null && response.errorMessage!.isNotEmpty) {
      showSnackBar(context, "ERROR: ${response.errorMessage!}");
      return false;
    }

    switch (response.status) {
      case V1RegisterStatus.success:
        // TODO register profile
        return true;
      case V1RegisterStatus.emailInUse:
        showSnackBar(context, "ERROR: Email already exists");
        return false;
      case V1RegisterStatus.badRequest:
      case V1RegisterStatus.unknown:
        showSnackBar(context, "ERROR: Something went wrong");
        return false;
    }
  }

  Future<bool> signInAction() async {
    // Make registration request
    V1SignInBody body = V1SignInBody(
      location: widget.setupState.location,
    );

    Auth auth = Auth(email: registerData.email, password: registerData.password);

    V1SignInResponse response = await v1signIn(body, auth);

    if (!context.mounted) return false;

    // In case a custom message was provided
    if (response.errorMessage != null && response.errorMessage!.isNotEmpty) {
      showSnackBar(context, "ERROR: ${response.errorMessage!}");
      return false;
    }

    switch (response.status) {
      case V1SignInStatus.success:
        // TODO register profile
        return true;
      case V1SignInStatus.incorrectCredentials:
        showSnackBar(context, "ERROR: Incorrect credentials");
        return false;
      case V1SignInStatus.badRequest:
      case V1SignInStatus.unknown:
        showSnackBar(context, "ERROR: Something went wrong");
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? headingTheme = Theme.of(context).textTheme.headlineLarge;

    return GestureDetector(
      // Allow tapping outside to dismiss keyboard
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomNavigationBarWrapper(
            pageController: widget.pageController,
            showNext: false, // We are using our own submit button
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  padding(48),

                  // Icon
                  LargeIcon(icon: Icons.badge, color: Colors.purple.shade400),
                  padding(16),

                  // Title
                  Text(widget.accountExists ? "Sign In" : "Register", style: headingTheme),
                  padding(8),

                  // Description
                  const Text(
                    "Welcome to Activ8",
                    textAlign: TextAlign.center,
                  ),
                  padding(16),

                  // Content
                  _createContent(),

                  padding(16),

                  // Submit
                  _createSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createContent() {
    return SizedBox(
      width: 250,
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        onChanged: () {
          enableSubmit = (formKey.currentState?.validate() ?? false);
          setState(() {});
        },
        child: Column(
          children: [
            CustomTextField(
              label: "Email",
              initialValue: registerData.email,
              onChanged: (String value) {
                registerData.email = value.trim();
                logger.i("Email set to ${registerData.email}");
              },
              validator: (String value) => EmailValidator.validate(value.trim()),
              readOnly: loading,
            ),
            CustomTextField(
              label: "Password",
              obscureText: true,
              initialValue: registerData.password,
              onChanged: (String value) => registerData.password = value.trim(),
              validator: (String value) {
                late bool isGoodLength = value.trim().length >= 4 && value.trim().length <= 35;
                late bool hasWhitespaces = value.trim().contains(RegExp("\\s"));
                return isGoodLength && !hasWhitespaces;
              },
              readOnly: loading,
            ),
            CustomTextField(
              label: "Server Address (Debug)",
              initialValue: registerData.address,
              onChanged: (String value) => registerData.address = value,
              readOnly: loading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _createSubmitButton() {
    return ElevatedButton.icon(
      onPressed: (enableSubmit && !loading) ? submitAction : null,
      icon: const Icon(Icons.check),
      label: const Text("Submit"),
      style: filledElevatedButtonStyle(context),
    );
  }
}

class _RegisterData {
  String email = "";
  String password = "";
  String address = "127.0.0.1:8080";

  _RegisterData();
}
