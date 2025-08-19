import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'mixture_page/litro_info.dart';
import 'mixture_page/valor_info.dart';

class MixturePage extends StatefulWidget {
  const MixturePage({super.key});

  @override
  _MixturePageState createState() => _MixturePageState();
}

class _MixturePageState extends State<MixturePage> {
  bool isLitro = true;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: BannerAd.testAdUnitId, // 👉 Troque pelo seu ID real do AdMob
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0, right: 18, left: 18),
        child: Column(
          children: [
            AnimatedToggleSwitch<bool>.dual(
              current: isLitro,
              first: true,
              second: false,
              onChanged: (value) {
                setState(() {
                  isLitro = value;
                });
              },
              style: const ToggleStyle(
                indicatorColor: Colors.blue,
                borderColor: Colors.blue,
              ),
              iconBuilder: (value) => value
                  ? const Icon(Icons.local_gas_station, color: Colors.white)
                  : const Icon(Icons.attach_money, color: Colors.white),
              textBuilder: (value) => value
                  ? const Center(
                  child:
                  Text('Litro', style: TextStyle(color: Colors.black)))
                  : const Center(
                  child:
                  Text('Valor', style: TextStyle(color: Colors.black))),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLitro ? const LitroInfo() : const ValorInfo(),
            ),
            if (_isBannerLoaded && _bannerAd != null)
              SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
