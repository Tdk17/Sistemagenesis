import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_genesis/Src/Config/appColors.dart';
import 'package:sistema_genesis/Src/Config/appConfig.dart';
import 'package:sistema_genesis/Src/Dependencies/dependencies.dart';
import 'package:sistema_genesis/Src/Routes/appRoutes.dart';
import 'package:sistema_genesis/Src/Services/authController.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: AppConfig.isBack4AppConfigured ? '' : AppConfig.localAdminEmail,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await getIt<AuthController>().logIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (success && mounted) context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 900;
          return Row(
            children: [
              if (desktop) const Expanded(flex: 11, child: _LoginShowcase()),
              Expanded(
                flex: desktop ? 9 : 1,
                child: Container(
                  color: Colors.white,
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: desktop ? 64 : 24,
                          vertical: 32,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: _LoginForm(
                            formKey: _formKey,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            onTogglePassword: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            onSubmit: _submit,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthController>();
    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _MobileBrand(),
              const SizedBox(height: 44),
              const Text(
                'Bem-vindo de volta',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Acesse sua central de projetos, clientes e resultados.',
                style: TextStyle(color: AppColors.muted, height: 1.5),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe seu e-mail.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe sua senha.'
                    : null,
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withOpacity(.2)),
                  ),
                  child: Text(
                    auth.error!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: auth.isLoading ? null : onSubmit,
                child: auth.isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Entrar no Genesis'),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 19),
                        ],
                      ),
              ),
              const SizedBox(height: 18),
              const _AccessNotice(),
            ],
          ),
        );
      },
    );
  }
}

class _AccessNotice extends StatelessWidget {
  const _AccessNotice();

  @override
  Widget build(BuildContext context) {
    final local = !AppConfig.isBack4AppConfigured;
    final color = local ? AppColors.warning : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            local ? Icons.shield_outlined : Icons.verified_user_outlined,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              local
                  ? 'Modo local temporário. Senha inicial: Genesis@2026. Ao conectar o Back4App, este acesso é desativado.'
                  : 'Acesso protegido pela conta exclusiva configurada no Back4App.',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileBrand extends StatelessWidget {
  const _MobileBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.blueBright, AppColors.blue],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.hub_rounded, color: AppColors.goldSoft),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GENESIS',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.7,
                color: AppColors.black,
              ),
            ),
            Text(
              'BUSINESS OS',
              style: TextStyle(
                color: AppColors.blue,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoginShowcase extends StatelessWidget {
  const _LoginShowcase();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(64),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.black, Color(0xFF0B1B34), Color(0xFF07101E)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.blue.withOpacity(.28), Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.hub_rounded, color: AppColors.goldSoft, size: 30),
                  SizedBox(width: 13),
                  Text(
                    'GENESIS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.4,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withOpacity(.25)),
                ),
                child: const Text(
                  'COMANDO CENTRAL DA EMPRESA',
                  style: TextStyle(
                    color: AppColors.goldSoft,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Projetos sob controle.\nDecisões com clareza.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.4,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                width: 520,
                child: Text(
                  'Uma operação única para acompanhar clientes, pipeline, compromissos e desempenho financeiro — em qualquer dispositivo.',
                  style: TextStyle(
                    color: Color(0xFFB4C0D0),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 38),
              const Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _FeaturePill(Icons.view_kanban_outlined, 'Pipeline visual'),
                  _FeaturePill(Icons.cloud_done_outlined, 'Pronto para nuvem'),
                  _FeaturePill(Icons.phone_iphone_rounded, 'PWA instalável'),
                ],
              ),
              const Spacer(),
              const Text(
                'GENESIS BUSINESS OS  •  OPERAÇÃO PRIVADA',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(.09)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.blueBright, size: 18),
          const SizedBox(width: 9),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
