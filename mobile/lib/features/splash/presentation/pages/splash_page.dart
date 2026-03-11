import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/app_config.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/ml_service.dart';
import '../../../../core/services/offline_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _statusMessage = 'Initializing...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Initialize core services
      _updateStatus('Initializing core services...', 0.1);
      await AppConfig.init();
      
      // Step 2: Initialize storage
      _updateStatus('Setting up local storage...', 0.2);
      await StorageService.init();
      await StorageService.migrate();
      
      // Step 3: Initialize API service
      _updateStatus('Connecting to server...', 0.3);
      await ApiService.initialize();
      
      // Step 4: Initialize ML service
      _updateStatus('Loading AI models...', 0.5);
      await MLService.initialize();
      
      // Step 5: Initialize offline service
      _updateStatus('Setting up offline capabilities...', 0.7);
      await OfflineService.initialize();
      
      // Step 6: Initialize notifications
      _updateStatus('Setting up notifications...', 0.8);
      await NotificationService.requestPermissions();
      
      // Step 7: Check authentication
      _updateStatus('Checking authentication...', 0.9);
      await ref.read(authProvider.notifier).checkAuthStatus();
      
      // Step 8: Complete
      _updateStatus('Ready!', 1.0);
      
      // Wait a moment to show completion
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate based on auth status
      _navigateToNextScreen();
      
    } catch (e) {
      _updateStatus('Initialization failed', 1.0);
      _showErrorDialog(e.toString());
    }
  }

  void _updateStatus(String message, double progress) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
        _progress = progress;
      });
    }
  }

  void _navigateToNextScreen() {
    final authState = ref.read(authProvider);
    
      authState.when(
        data: (user) {
          if (user != null) {
            Navigator.of(context).pushReplacementNamed('/enhanced-dashboard');
          } else {
            Navigator.of(context).pushReplacementNamed('/auth');
          }
        },
        loading: () {
          // Stay on splash while loading
        },
        error: (error, stackTrace) {
          Navigator.of(context).pushReplacementNamed('/auth');
        },
      );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to initialize the app:\n$error',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp(); // Retry
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // App Logo and Animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          // App Icon/Logo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.agriculture,
                              size: 64,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // App Name
                          Text(
                            AppConfig.appName,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Tagline
                          Text(
                            'Smart Farming for East Africa',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const Spacer(flex: 3),
              
              // Loading Indicator and Status
              Column(
                children: [
                  // Progress Bar
                  Container(
                    width: double.infinity,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status Message
                  Text(
                    _statusMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Progress Percentage
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Version Info
              Text(
                'Version ${AppConfig.appVersion}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}