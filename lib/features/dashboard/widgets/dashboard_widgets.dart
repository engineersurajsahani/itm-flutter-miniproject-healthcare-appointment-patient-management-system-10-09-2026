import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/appointment.dart';
import '../../../models/user_role.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({required this.compact, required this.role, super.key});
  final bool compact;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final stats = role == UserRole.patient
        ? [
            (
              'Upcoming visits',
              '03',
              '+1 this month',
              Icons.event_available_outlined,
              const Color(0xFFE8EDFF),
            ),
            (
              'Care team',
              '04',
              'Active providers',
              Icons.medical_services_outlined,
              const Color(0xFFFFE9DE),
            ),
            (
              'Prescriptions',
              '06',
              '2 refills due',
              Icons.medication_outlined,
              const Color(0xFFE9F7F1),
            ),
          ]
        : role == UserRole.admin
        ? [
            (
              'Total patients',
              '1,248',
              '+12.5%',
              Icons.people_alt_outlined,
              const Color(0xFFE8EDFF),
            ),
            (
              'Active doctors',
              '86',
              '+8.2%',
              Icons.medical_services_outlined,
              const Color(0xFFFFE9DE),
            ),
            (
              'Pending requests',
              '07',
              '-3.1%',
              Icons.schedule_outlined,
              const Color(0xFFE9F7F1),
            ),
          ]
        : [
            (
              'Total patients',
              '1,248',
              '+12.5%',
              Icons.people_alt_outlined,
              const Color(0xFFE8EDFF),
            ),
            (
              'Appointments today',
              '24',
              '+8.2%',
              Icons.calendar_today_outlined,
              const Color(0xFFFFE9DE),
            ),
            (
              'Pending requests',
              '07',
              '-3.1%',
              Icons.schedule_outlined,
              const Color(0xFFE9F7F1),
            ),
          ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: compact ? 1 : 3,
        mainAxisExtent: 116,
        crossAxisSpacing: 18,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (_, index) {
        final stat = stats[index];
        return DashboardPanel(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: stat.$5,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(stat.$4, color: AppColors.blue),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stat.$1,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        stat.$2,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        stat.$3,
                        style: TextStyle(
                          color: stat.$3.startsWith('-')
                              ? Colors.redAccent
                              : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    required this.role,
    required this.selected,
    required this.onSelect,
    super.key,
  });
  final UserRole role;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: Container(
      width: 238,
      padding: const EdgeInsets.fromLTRB(24, 28, 18, 24),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 23),
              ),
              const SizedBox(width: 10),
              const Text(
                'careflow',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          const Text(
            'MAIN MENU',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          ..._menuItems.asMap().entries.map(
            (entry) => _NavItem(
              label: entry.value,
              icon: [
                Icons.grid_view_rounded,
                Icons.calendar_today_outlined,
                Icons.people_outline,
                Icons.medical_services_outlined,
              ][entry.key],
              selected: selected == entry.key,
              onTap: () => onSelect(entry.key),
            ),
          ),
          const Spacer(),
          const Divider(color: AppColors.line),
          const SizedBox(height: 12),
          const _NavItem(label: 'Settings', icon: Icons.settings_outlined),
          const _NavItem(label: 'Help center', icon: Icons.help_outline),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lavender,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFD6DDFD),
                  child: Icon(
                    role == UserRole.patient
                        ? Icons.person
                        : role == UserRole.doctor
                            ? Icons.medical_services
                            : Icons.admin_panel_settings,
                    color: AppColors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role == UserRole.patient
                            ? 'Olivia Bennett'
                            : role == UserRole.doctor
                                ? 'Dr. Sarah Wilson'
                                : 'Sarah (Admin)',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        role.label,
                        style: const TextStyle(color: AppColors.muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  List<String> get _menuItems {
    switch (role) {
      case UserRole.patient:
        return ['Overview', 'My appointments', 'Care team', 'Health records'];
      case UserRole.doctor:
        return ['Overview', 'Appointments', 'Patients', 'Staff'];
      case UserRole.admin:
        return ['Overview', 'Patients', 'Doctors', 'Reports'];
    }
  }
}

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    required this.compact,
    required this.role,
    required this.onBook,
    required this.onSignOut,
    super.key,
  });
  final bool compact;
  final VoidCallback onBook;
  final UserRole role;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (compact)
        IconButton(
          icon: const Icon(Icons.menu, color: AppColors.ink),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      const Spacer(),
      IconButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications up to date')),
          );
        },
        icon: const Icon(Icons.notifications_none, color: AppColors.muted),
      ),
      const SizedBox(width: 8),
      if (role == UserRole.patient)
        FilledButton.icon(
          onPressed: onBook,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Book appointment'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      const SizedBox(width: 8),
      IconButton(
        onPressed: onSignOut,
        tooltip: 'Sign out',
        icon: const Icon(Icons.logout, color: AppColors.muted),
      ),
    ],
  );
}

class DashboardPanel extends StatelessWidget {
  const DashboardPanel({
    required this.child,
    this.title,
    this.action,
    this.padding,
    super.key,
  });
  final Widget child;
  final String? title;
  final String? action;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.line),
    ),
    child: title == null
        ? child
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title!,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (action != null)
                    Text(
                      action!,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              child,
            ],
          ),
  );
}

class AppointmentTile extends StatelessWidget {
  const AppointmentTile({required this.appointment, super.key});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: appointment.color.withAlpha(45),
          child: Icon(Icons.person, color: appointment.color, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.patient,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${appointment.doctor}  ·  ${appointment.specialty}',
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              appointment.time,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              appointment.status,
              style: TextStyle(
                color: appointment.status == 'Pending'
                    ? Colors.orange
                    : Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    this.selected = false,
    this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: selected ? AppColors.lavender : null,
        leading: Icon(
          icon,
          size: 19,
          color: selected ? AppColors.blue : AppColors.muted,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.blue : AppColors.muted,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
