import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tema/tema_aplikasi.dart';

/// Komponen widget yang dapat digunakan ulang di seluruh aplikasi
/// Memastikan konsistensi tampilan

// ==================== HEADER GRADASI ====================
class GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final double height;

  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00695C),
            Color(0xFF00897B),
            Color(0xFF26A69A),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: TemaAplikasi.primaryDark.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      style: TemaAplikasi.bodyWhiteLight,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    title,
                    style: TemaAplikasi.headingWhite,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// ==================== KARTU INFO ====================
class KartuInfo extends StatelessWidget {
  final String judul;
  final List<Widget> children;
  final IconData? icon;
  final List<Color>? gradientColors;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const KartuInfo({
    super.key,
    required this.judul,
    required this.children,
    this.icon,
    this.gradientColors,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: gradientColors != null
          ? TemaAplikasi.gradientCardDecoration(colors: gradientColors)
          : TemaAplikasi.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gradientColors != null
                        ? Colors.white.withOpacity(0.2)
                        : TemaAplikasi.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: gradientColors != null
                        ? Colors.white
                        : TemaAplikasi.primary,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  judul,
                  style: gradientColors != null
                      ? TemaAplikasi.titleWhite
                      : TemaAplikasi.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// ==================== KARTU MENU ====================
class KartuMenu extends StatelessWidget {
  final String judul;
  final String subjudul;
  final IconData icon;
  final Color warna;
  final VoidCallback? onTap;

  const KartuMenu({
    super.key,
    required this.judul,
    required this.subjudul,
    required this.icon,
    required this.warna,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TemaAplikasi.cardBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: warna.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      warna.withOpacity(0.8),
                      warna,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: warna.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Text(
                judul,
                style: TemaAplikasi.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subjudul,
                style: TemaAplikasi.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== KARTU STATISTIK ====================
class KartuStatistik extends StatelessWidget {
  final String label;
  final String nilai;
  final IconData icon;
  final Color warna;

  const KartuStatistik({
    super.key,
    required this.label,
    required this.nilai,
    required this.icon,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warna.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: warna.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: warna.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: warna, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            nilai,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: warna,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TemaAplikasi.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ==================== BARIS INFO ====================
class BarisInfo extends StatelessWidget {
  final String label;
  final String nilai;
  final bool isWhite;

  const BarisInfo({
    super.key,
    required this.label,
    required this.nilai,
    this.isWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isWhite
                    ? Colors.white.withOpacity(0.7)
                    : TemaAplikasi.textSecondary,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              color: isWhite
                  ? Colors.white.withOpacity(0.7)
                  : TemaAplikasi.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              nilai,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isWhite ? Colors.white : TemaAplikasi.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== KARTU TIPS ====================
class KartuTips extends StatelessWidget {
  final String judul;
  final String deskripsi;
  final IconData icon;
  final Color? warna;

  const KartuTips({
    super.key,
    required this.judul,
    required this.deskripsi,
    this.icon = Icons.lightbulb_outline,
    this.warna,
  });

  @override
  Widget build(BuildContext context) {
    final color = warna ?? TemaAplikasi.warning;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: TemaAplikasi.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deskripsi,
                  style: TemaAplikasi.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== KARTU LIST ITEM ====================
class KartuListItem extends StatelessWidget {
  final String judul;
  final String? subjudul;
  final String? info;
  final IconData icon;
  final Color warna;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const KartuListItem({
    super.key,
    required this.judul,
    this.subjudul,
    this.info,
    required this.icon,
    required this.warna,
    this.trailing,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: TemaAplikasi.cardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        warna.withOpacity(0.7),
                        warna,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: warna.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judul,
                        style: TemaAplikasi.titleLarge,
                      ),
                      if (subjudul != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subjudul!,
                          style: TemaAplikasi.bodyMedium,
                        ),
                      ],
                      if (info != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          info!,
                          style: TemaAplikasi.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (onEdit != null || onDelete != null)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: TemaAplikasi.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 20, color: TemaAplikasi.primary),
                              const SizedBox(width: 12),
                              const Text('Edit'),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'hapus',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 20, color: TemaAplikasi.error),
                              const SizedBox(width: 12),
                              Text('Hapus',
                                  style: TextStyle(color: TemaAplikasi.error)),
                            ],
                          ),
                        ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'hapus') onDelete?.call();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== TAMPILAN KOSONG ====================
class TampilanKosong extends StatelessWidget {
  final IconData icon;
  final String judul;
  final String deskripsi;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const TampilanKosong({
    super.key,
    required this.icon,
    required this.judul,
    required this.deskripsi,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TemaAplikasi.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: TemaAplikasi.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              judul,
              style: TemaAplikasi.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              deskripsi,
              style: TemaAplikasi.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.add),
                label: Text(buttonText!),
                style: TemaAplikasi.primaryButton,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== LOADING INDICATOR ====================
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const LoadingIndicator({
    super.key,
    this.message,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(TemaAplikasi.primary),
          strokeWidth: 3,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TemaAplikasi.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isFullScreen) {
      return Container(
        color: TemaAplikasi.background,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

// ==================== BADGE STATUS ====================
class BadgeStatus extends StatelessWidget {
  final String text;
  final Color color;

  const BadgeStatus({
    super.key,
    required this.text,
    required this.color,
  });

  factory BadgeStatus.success(String text) => BadgeStatus(
        text: text,
        color: TemaAplikasi.success,
      );

  factory BadgeStatus.warning(String text) => BadgeStatus(
        text: text,
        color: TemaAplikasi.warning,
      );

  factory BadgeStatus.error(String text) => BadgeStatus(
        text: text,
        color: TemaAplikasi.error,
      );

  factory BadgeStatus.info(String text) => BadgeStatus(
        text: text,
        color: TemaAplikasi.info,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

// ==================== RINGKASAN KARTU ====================
class KartuRingkasan extends StatelessWidget {
  final String judul;
  final String nilai;
  final IconData icon;
  final List<Widget>? children;

  const KartuRingkasan({
    super.key,
    required this.judul,
    required this.nilai,
    required this.icon,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: TemaAplikasi.gradientCardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  judul,
                  style: TemaAplikasi.bodyWhiteLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            nilai,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (children != null) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 12),
            ...children!,
          ],
        ],
      ),
    );
  }
}
