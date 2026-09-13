class OnboardingSlide {
  const OnboardingSlide({
    required this.fallbackAsset,
    required this.block1TitleFr,
    required this.block1TitleEn,
    required this.block1TextFr,
    required this.block1TextEn,
    required this.block2TitleFr,
    required this.block2TitleEn,
    required this.block2TextFr,
    required this.block2TextEn,
    required this.order,
    this.imageUrl,
    this.ctaTextFr,
    this.ctaTextEn,
  });

  final String fallbackAsset;
  final String? imageUrl;
  final String block1TitleFr;
  final String block1TitleEn;
  final String block1TextFr;
  final String block1TextEn;
  final String block2TitleFr;
  final String block2TitleEn;
  final String block2TextFr;
  final String block2TextEn;
  final String? ctaTextFr;
  final String? ctaTextEn;
  final int order;

  bool get hasRemoteImage =>
      imageUrl != null && imageUrl!.trim().startsWith('http');

  String title1(bool french) => french ? block1TitleFr : block1TitleEn;
  String text1(bool french) => french ? block1TextFr : block1TextEn;
  String title2(bool french) => french ? block2TitleFr : block2TitleEn;
  String text2(bool french) => french ? block2TextFr : block2TextEn;
  String? cta(bool french) {
    final value = french ? ctaTextFr : ctaTextEn;
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }

  factory OnboardingSlide.fromFirestore(
    Map<String, dynamic> json, {
    required String fallbackAsset,
  }) {
    return OnboardingSlide(
      fallbackAsset: fallbackAsset,
      imageUrl: (json['image_url'] ?? '').toString(),
      block1TitleFr: (json['block1_title_fr'] ?? '').toString(),
      block1TitleEn: (json['block1_title_en'] ?? '').toString(),
      block1TextFr: (json['block1_text_fr'] ?? '').toString(),
      block1TextEn: (json['block1_text_en'] ?? '').toString(),
      block2TitleFr: (json['block2_title_fr'] ?? '').toString(),
      block2TitleEn: (json['block2_title_en'] ?? '').toString(),
      block2TextFr: (json['block2_text_fr'] ?? '').toString(),
      block2TextEn: (json['block2_text_en'] ?? '').toString(),
      ctaTextFr: (json['cta_text_fr'] ?? '').toString(),
      ctaTextEn: (json['cta_text_en'] ?? '').toString(),
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 0,
    );
  }

  OnboardingSlide withBundledFallback(OnboardingSlide fallback) {
    String pick(String value, String bundled) =>
        value.trim().isEmpty ? bundled : value;
    return OnboardingSlide(
      fallbackAsset: fallbackAsset,
      imageUrl: imageUrl,
      block1TitleFr: pick(block1TitleFr, fallback.block1TitleFr),
      block1TitleEn: pick(block1TitleEn, fallback.block1TitleEn),
      block1TextFr: pick(block1TextFr, fallback.block1TextFr),
      block1TextEn: pick(block1TextEn, fallback.block1TextEn),
      block2TitleFr: pick(block2TitleFr, fallback.block2TitleFr),
      block2TitleEn: pick(block2TitleEn, fallback.block2TitleEn),
      block2TextFr: pick(block2TextFr, fallback.block2TextFr),
      block2TextEn: pick(block2TextEn, fallback.block2TextEn),
      ctaTextFr: pick(ctaTextFr ?? '', fallback.ctaTextFr ?? ''),
      ctaTextEn: pick(ctaTextEn ?? '', fallback.ctaTextEn ?? ''),
      order: order == 0 ? fallback.order : order,
    );
  }
}
