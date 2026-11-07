import 'package:flutter/material.dart';
import 'premium_ui.dart';

/// Shared visual components for the Surat and LPJ flows.
/// No API calls or permission changes are performed here.
class CikokoFlowSteps extends StatelessWidget {
  final List<String> labels;
  final int current;
  const CikokoFlowSteps({
    super.key,
    required this.labels,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (labels.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i != 0) Expanded(child: Container(
            height: 2,
            margin: const EdgeInsets.only(left: 2, right: 5, bottom: 20),
            color: i <= current ? scheme.primary : scheme.outlineVariant,
          )),
          Flexible(flex: 2, child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 29,
              height: 29,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= current ? scheme.primary
                  : scheme.surfaceContainerHighest,
              ),
              child: i < current
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 17)
                : Text('${i + 1}', style: TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: i == current ? Colors.white : scheme.onSurfaceVariant)),
            ),
            const SizedBox(height: 5),
            Text(labels[i], textAlign: TextAlign.center, maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: i == current ? scheme.primary : scheme.onSurfaceVariant)),
          ])),
        ],
      ]),
    );
  }
}

class CikokoFlowSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;
  const CikokoFlowSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            width: 37, height: 37,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: scheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(
                color: scheme.onSurface, fontSize: 14,
                fontWeight: FontWeight.w800)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10.5)),
              ],
            ],
          )),
        ]),
        const SizedBox(height: 13),
        child,
      ]),
    );
  }
}

class CikokoRecordCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final String statusLabel;
  final VoidCallback? onTap;
  final Widget? footer;
  const CikokoRecordCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusLabel,
    this.onTap,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 43, height: 43,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.description_outlined,
                  color: scheme.primary, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurface,
                      fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11)),
                  const SizedBox(height: 9),
                  Row(children: [
                    Flexible(child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: CikokoStatusBadge.accentFor(status)
                          .withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(statusLabel, maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: CikokoStatusBadge.accentFor(status))),
                    )),
                  ]),
                ],
              )),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded,
                  size: 20, color: scheme.onSurfaceVariant),
            ]),
          ),
        ),
        if (footer != null) ...[
          Divider(height: 1, color: scheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 4, 9, 7),
            child: footer!,
          ),
        ],
      ]),
    );
  }
}
