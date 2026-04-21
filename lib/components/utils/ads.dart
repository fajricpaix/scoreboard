import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

bool get _supportsMobileAds {
  if (kIsWeb) {
    return false;
  }

  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

class AppAds {
  static Future<void> initialize() async {
    if (!_supportsMobileAds) {
      return;
    }

    await MobileAds.instance.initialize();
  }

  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }

    return 'ca-app-pub-3940256099942544/2934735716';
  }

  static String get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/1033173712';
    }

    return 'ca-app-pub-3940256099942544/4411468910';
  }
}

class AppBannerAd extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final bool showSponsoredLabel;
  final Color backgroundColor;

  const AppBannerAd({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 24),
    this.showSponsoredLabel = true,
    this.backgroundColor = const Color(0xFF121212),
  });

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (!_supportsMobileAds) {
      return;
    }

    final bannerAd = BannerAd(
      adUnitId: AppAds.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsMobileAds) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: widget.backgroundColor,
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showSponsoredLabel)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Sponsored',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isLoaded && _bannerAd != null
                  ? SizedBox(
                      key: const ValueKey('banner-ad'),
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    )
                  : const SizedBox.shrink(key: ValueKey('banner-placeholder')),
            ),
          ),
        ],
      ),
    );
  }
}

class AppInterstitialAd {
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

  Future<void> load() async {
    if (!_supportsMobileAds || _isLoading || _interstitialAd != null) {
      return;
    }

    _isLoading = true;

    await InterstitialAd.load(
      adUnitId: AppAds.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
          _attachCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
        },
      ),
    );
  }

  void _attachCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        load();
      },
    );
  }

  Future<bool> show() async {
    if (_interstitialAd == null) {
      await load();
      return false;
    }

    final ad = _interstitialAd;
    _interstitialAd = null;

    if (ad == null) {
      return false;
    }

    ad.show();
    return true;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
