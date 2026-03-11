import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class FarmsPage extends StatelessWidget {
  const FarmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Farms'),
      ),
      body: Center(
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.agriculture, 
                size: ResponsiveUtils.getResponsiveIconSize(context, small: 48, medium: 64, large: 80), 
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
              Text(
                'Farm Management',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, small: 6, medium: 8, large: 12)),
              Text(
                'Farm management features coming soon!',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}