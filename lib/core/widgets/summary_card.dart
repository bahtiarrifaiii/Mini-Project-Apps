import 'package:flutter/material.dart';

class SummaryCard extends StatefulWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final bool obscureValue;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.obscureValue = false,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  bool _isObscured = false;

  String get _displayValue {
    if (!_isObscured) return widget.value;
    return widget.value.startsWith('Rp') ? 'Rp ******' : '******';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFF404040),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 23),
                  ),
                  if (widget.obscureValue)
                    IconButton(
                      onPressed: () {
                        setState(() => _isObscured = !_isObscured);
                      },
                      icon: Icon(
                        _isObscured
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 21,
                        color: widget.color,
                      ),
                      tooltip: _isObscured
                          ? 'Tampilkan saldo'
                          : 'Sembunyikan saldo',
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _displayValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: -0.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
