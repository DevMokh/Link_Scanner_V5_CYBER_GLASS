import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/settings_store.dart';
import 'common.dart';

/// إعدادات الفحص المتقدم ومفاتيح الخدمات الخارجية الاختيارية.
class IntelSettingsPanel extends StatefulWidget {
  const IntelSettingsPanel({super.key});

  @override
  State<IntelSettingsPanel> createState() => _IntelSettingsPanelState();
}

class _IntelSettingsPanelState extends State<IntelSettingsPanel> {
  final TextEditingController _gsb = TextEditingController();
  final TextEditingController _vt = TextEditingController();
  bool _hide = true;

  @override
  void initState() {
    super.initState();
    _gsb.text = SettingsStore.instance.gsbKey;
    _vt.text = SettingsStore.instance.vtKey;
  }

  @override
  void dispose() {
    _gsb.dispose();
    _vt.dispose();
    super.dispose();
  }

  Future<void> _saveKeys() async {
    FocusScope.of(context).unfocus();
    final saved = await SettingsStore.instance.setKeys(
      gsb: _gsb.text,
      vt: _vt.text,
    );
    if (!mounted) return;
    toast(
      context,
      saved
          ? 'تم حفظ المفاتيح في التخزين الآمن للجهاز'
          : 'التخزين الآمن غير متاح: المفاتيح شغالة حتى تقفل التطبيق ولن تُحفظ',
    );
  }

  Widget _keyField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: _hide,
      autocorrect: false,
      enableSuggestions: false,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontFamily: 'monospace',
        color: C.text,
        fontSize: 13,
      ),
      decoration: fieldDecoration(hint: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsStore.instance,
      builder: (context, _) {
        return Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle('مصادر الفحص المتقدم'),
              const Row(
                children: [
                  Icon(Icons.shield_outlined, color: C.statusSafe, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: StatusBadge(label: 'NETGUARD / REDIRECT REQUEST GUARD', color: C.statusSafe, dot: false)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'NetGuard يتحقق من وجهات طلبات التحويلات قبل الاتصال، ويمنع العناوين المحلية والخاصة.',
                style: TextStyle(color: C.textSecondary, fontSize: 11.5, height: 1.45),
              ),
              const SizedBox(height: 8),
              const Text(
                'الفحص المتقدم اختياري ويجمع بين تتبّع التحويلات وعمر الدومين، ويمكنه الاستعلام من Google Safe Browsing وVirusTotal عند إضافة مفاتيح API.',
                style: TextStyle(color: C.muted, fontSize: 12.5, height: 1.5),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: SettingsStore.instance.intelConsent,
                onChanged: (value) =>
                    SettingsStore.instance.setIntelConsent(value),
                title: const Text(
                  'السماح بالفحص المتقدم عبر الإنترنت',
                  style: TextStyle(
                    color: C.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  'يتصل بالموقع لتتبّع التحويلات، ويرسل اسم الدومين إلى RDAP، والرابط الكامل إلى Google أو VirusTotal فقط عند إعداد مفاتيحهما. أوقفه لمنع هذه الاتصالات.',
                  style: TextStyle(color: C.muted, fontSize: 12, height: 1.45),
                ),
              ),
              const Divider(color: C.line, height: 28),
              const Text(
                'مفاتيح API (اختيارية)',
                style: TextStyle(
                  color: C.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              if (!SettingsStore.instance.keysSecure) ...[
                const SizedBox(height: 6),
                const Text(
                  'تنبيه: التخزين الآمن غير متاح على جهازك، فالمفاتيح هتفضل في الذاكرة حتى تقفل التطبيق وتحتاج تدخلها تاني.',
                  style: TextStyle(color: C.amber, fontSize: 12, height: 1.5),
                ),
              ],
              const SizedBox(height: 10),
              _keyField(_gsb, 'Google Safe Browsing API key'),
              const SizedBox(height: 8),
              _keyField(_vt, 'VirusTotal API key'),
              const SizedBox(height: 6),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => setState(() => _hide = !_hide),
                  icon: Icon(
                    _hide ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    size: 18,
                  ),
                  label: Text(_hide ? 'إظهار' : 'إخفاء'),
                  style: TextButton.styleFrom(foregroundColor: C.muted),
                ),
              ),
              FilledButton.icon(
                onPressed: _saveKeys,
                style: filledButtonStyle(),
                icon: const Icon(Icons.save_rounded),
                label: const Text('حفظ المفاتيح'),
              ),
              const SizedBox(height: 12),
              const Text(
                'الحصول على المفاتيح: Google Safe Browsing من Google Cloud Console (فعّل Safe Browsing API وأنشئ API key)، وVirusTotal من حسابك في موقعهم. المفاتيح بتتخزن مشفّرة في مخزن مفاتيح أندرويد على جهازك، ولا تُكتب في سجلات التطبيق. راجع شروط الاستخدام التجارية لكل خدمة قبل توزيع التطبيق.',
                style: TextStyle(color: C.muted, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }
}
