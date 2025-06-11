import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeLayout extends StatefulWidget {
  final Widget child;
  const HomeLayout({super.key, required this.child});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    '/home',
    '/home/map',
    '/home/users',
    '/home/profile',
  ];

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
    context.go(_tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: LucideIcons.home,
                label: 'Inicio',
                isSelected: _selectedIndex == 0,
                onTap: () => _onTap(0),
              ),
              _NavItem(
                icon: LucideIcons.map,
                label: 'Mapa',
                isSelected: _selectedIndex == 1,
                onTap: () => _onTap(1),
              ),
              _NavItem(
                icon: LucideIcons.bell,
                label: 'Usuarios',
                isSelected: _selectedIndex == 2,
                onTap: () => _onTap(2),
              ),
              _NavItem(
                icon: LucideIcons.user,
                label: 'Perfil',
                isSelected: _selectedIndex == 3,
                onTap: () => _onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.blueAccent : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }
}
