import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerWidget extends StatefulWidget {
  final bool isMedium;

  const AdBannerWidget({super.key, this.isMedium = false});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // テスト用ID。本番では AdMob コンソールで発行した実IDに差し替える
  static const String _adUnitId = 'ca-app-pub-5950809462500520/6510411527';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final size =
        widget.isMedium ? AdSize.mediumRectangle : AdSize.banner;
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
