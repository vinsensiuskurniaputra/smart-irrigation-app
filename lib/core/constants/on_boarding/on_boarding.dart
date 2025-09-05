import 'package:smart_irrigation_app/core/config/assets/app_images.dart';

class OnBoardingData {
  final String image, title, description;

  OnBoardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<OnBoardingData> onBoardingData = [
  OnBoardingData(
    image: AppImages.onboarding1,
    title: 'AI Plant Detection',
    description:
        'Aplikasi mendeteksi jenis tanaman secara otomatis menggunakan AI untuk mendukung penyiraman yang lebih tepat.',
  ),
  OnBoardingData(
    image: AppImages.onboarding2,
    title: 'Smart Irrigation',
    description:
        'Atur penyiraman tanaman secara otomatis dan efisien berdasarkan kebutuhan spesifik tiap tanaman.',
  ),
  OnBoardingData(
    image: AppImages.onboarding3,
    title: 'Monitoring & Reports',
    description:
        'Pantau kondisi tanaman dan riwayat penyiraman, serta unduh laporan kapan saja sesuai kebutuhan Anda.',
  ),
];
