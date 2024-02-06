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
  final SetupState setupState;
  final PageController pageController;

  const SetupHandshakePage({
    super.key,
    required this.setupState, // not used when logging in
    required this.pageController,
    required this.accountExists,
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

    print(widget.setupState.isComplete);

    // TODO make register/login request to the server
    await Future.delayed(const Duration(seconds: 2));

    // TODO set the profile state

    loading = false;
    setState(() {});
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
                  Text(widget.accountExists ? "Log In" : "Register", style: headingTheme),
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
              onChanged: (String value) => registerData.email = value,
              validator: (String value) => EmailValidator.validate(value),
              readOnly: loading,
            ),
            CustomTextField(
              label: "Password",
              obscureText: true,
              initialValue: registerData.password,
              onChanged: (String value) => registerData.password = value,
              validator: (String value) => value.length >= 4 && value.length <= 35,
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