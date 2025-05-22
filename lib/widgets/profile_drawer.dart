import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final employee = authProvider.currentEmployee;

    if (employee == null) {
      return const SizedBox.shrink();
    }

    return Drawer(
      child: Container(
        color: colorScheme.surface,
        child: Column(
          children: [
            _buildProfileHeader(context, employee, colorScheme),
            const Divider(height: 1),
            _buildThemeToggle(context, themeProvider, colorScheme),
            _buildDrawerItem(
              context,
              icon: Icons.history,
              title: 'Attendance History',
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Navigate to attendance history if implemented
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.insert_invitation,
              title: 'Leave Requests',
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Navigate to leave requests if needed
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                authProvider.logout();
              },
              color: colorScheme.error,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, Employee employee, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.onPrimary.withOpacity(0.2),
              backgroundImage: NetworkImage(employee.imageUrl),
            ),
            const SizedBox(height: 16),
            Text(
              employee.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${employee.position} • ${employee.department}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.9),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${employee.id}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider,
      ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Text(
                'Dark Mode',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = color ?? colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style:
            Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      visualDensity: VisualDensity.compact,
    );
  }
}
