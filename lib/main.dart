import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app.dart';

import 'features/auth/logic/auth_controller.dart';
import 'features/member/logic/beneficiary_controller.dart';

// Repository Interface Imports
import 'data/repositories/interfaces/auth_repository.dart';
import 'data/repositories/interfaces/member_repository.dart';
import 'data/repositories/interfaces/beneficiary_repository.dart';

// Repository Implementation Imports
import 'data/repositories/impl/auth_repository_firebase.dart';
import 'data/repositories/impl/member_repository_firestore.dart';
import 'data/repositories/impl/beneficiary_repository_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase Connected Successfully");
  } catch (e) {
    print("❌ Firebase Error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        // 1. Inject Auth Repository (Firebase)
        Provider<AuthRepository>(create: (_) => AuthRepositoryFirebase()),

        // 2. Inject Member Repository (Firestore)
        Provider<MemberRepository>(create: (_) => MemberRepositoryFirestore()),

        // 3. Inject Beneficiary Repository (Firestore)
        Provider<BeneficiaryRepository>(
          create: (_) => BeneficiaryRepositoryFirestore(),
        ),

        // 4. Inject Auth Controller (Depends on Auth & Member Repos)
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            authRepository: context.read<AuthRepository>(),
            memberRepository: context.read<MemberRepository>(),
          ),
        ),

        // 5. Inject Beneficiary Controller (Depends on Beneficiary & Auth Repos)
        ChangeNotifierProvider<BeneficiaryController>(
          create: (context) => BeneficiaryController(
            repo: context.read<BeneficiaryRepository>(),
            authRepo: context.read<AuthRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
