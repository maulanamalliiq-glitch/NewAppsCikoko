import 'package:flutter/material.dart';
import 'premium_ui.dart';

bool cikokoNotificationIsRead(Map<String, dynamic> event) {
  return event['is_read'] == true || (event['is_read'] ?? '').toString() == '1';
}

/// Only well-known request categories use the "Permohonan" grouping.
bool cikokoNotificationIsRequest(Map<String, dynamic> event) {
  final category = (event['category'] ?? '').toString().toLowerCase();
  return const {
    'rt_rw_surat', 'rt_rw_status', 'surat', 'progres_surat',
    'laporan_masuk', 'waris', 'lpj', 'surat_waris',
  }.contains(category);
}

class CikokoNotificationsPage extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  final ValueChanged<Map<String, dynamic>> onOpen;
  const CikokoNotificationsPage({
    super.key,
    required this.events,
    required this.onOpen,
  });

  @override
  State<CikokoNotificationsPage> createState() =>
      _CikokoNotificationsPageState();
}

class _CikokoNotificationsPageState extends State<CikokoNotificationsPage> {
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unread = widget.events.where((e) => !cikokoNotificationIsRead(e)).length;
    final visible = widget.events.where((e) {
      switch (filter) {
        case 'request':
          return cikokoNotificationIsRequest(e);
        case 'other':
          return !cikokoNotificationIsRequest(e);
        default:
          return true;
      }
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 26),
      children: [
        CikokoPremiumHeader(
          title: 'Notifikasi',
          subtitle: unread == 0
            ? 'Tidak ada notifikasi baru saat ini.'
            : '$unread notifikasi belum dibaca.',
          icon: Icons.notifications_active_outlined,
          start: const Color(0xFF07346E),
          end: const Color(0xFF267FDF),
        ),
        const SizedBox(height: 13),
        Wrap(spacing: 8, runSpacing: 7, children: [
          ChoiceChip(
            key: const Key('notification_all'),
            label: const Text('Semua'),
            selected: filter == 'all',
            onSelected: (_) => setState(() => filter = 'all'),
          ),
          ChoiceChip(
            key: const Key('notification_request'),
            label: const Text('Permohonan'),
            selected: filter == 'request',
            onSelected: (_) => setState(() => filter = 'request'),
          ),
          ChoiceChip(
            key: const Key('notification_other'),
            label: const Text('Lainnya'),
            selected: filter == 'other',
            onSelected: (_) => setState(() => filter = 'other'),
          ),
        ]),
        const SizedBox(height: 13),
        if (visible.isEmpty)
          Card(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
            child: Column(children: [
              Icon(Icons.notifications_off_outlined, size: 37,
                color: scheme.primary),
              const SizedBox(height: 10),
              Text(widget.events.isEmpty
                ? 'Belum ada notifikasi untuk akun ini.'
                : 'Belum ada notifikasi pada kategori ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant)),
            ]),
          )),
        for (final event in visible)
          _NotificationCard(
            key: ValueKey('notification_${event['id'] ?? event.hashCode}'),
            event: event,
            onTap: () => widget.onOpen(event),
          ),
        const SizedBox(height: 12),
        const CikokoPageSignature(),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;
  const _NotificationCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final read = cikokoNotificationIsRead(event);
    final request = cikokoNotificationIsRequest(event);
    final title = (event['title'] ?? 'Notifikasi Cikoko').toString().trim();
    final message = (event['message'] ?? '').toString().trim();
    final date = (event['created_at'] ?? '').toString().trim();
    final accent = request ? const Color(0xFF176AD4) : const Color(0xFF0D9B7F);

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: accent.withValues(alpha: .13),
              child: Icon(request
                ? Icons.description_outlined
                : Icons.notifications_none_rounded,
                color: accent, size: 23),
            ),
            const SizedBox(width: 11),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(
                    title.isEmpty ? 'Notifikasi Cikoko' : title,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurface, fontSize: 12.5,
                      fontWeight: read ? FontWeight.w600 : FontWeight.w800),
                  )),
                  if (!read) ...[
                    const SizedBox(width: 6),
                    const CircleAvatar(
                      radius: 4, backgroundColor: Color(0xFFE74343)),
                  ],
                ]),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(message, maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurfaceVariant,
                      fontSize: 11.2, height: 1.35)),
                ],
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(date, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurfaceVariant,
                      fontSize: 10)),
                ],
              ],
            )),
            const SizedBox(width: 3),
            Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Icon(Icons.chevron_right_rounded,
                size: 19, color: scheme.onSurfaceVariant),
            ),
          ]),
        ),
      ),
    );
  }
}
