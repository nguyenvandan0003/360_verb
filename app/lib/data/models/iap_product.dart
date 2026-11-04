class IapProductModel {
  final String id;
  final String title;
  final String priceFormatted;
  final int priceVnd;
  final String subtitle;
  final String? badge;
  final bool isSubscription;
  final String period;

  const IapProductModel({
    required this.id,
    required this.title,
    required this.priceFormatted,
    required this.priceVnd,
    required this.subtitle,
    this.badge,
    this.isSubscription = false,
    this.period = '',
  });

  static const String idLifetime = 'verb360_lifetime_299k';
  static const String idYearly = 'verb360_sub_yearly_199k';
  static const String idMonthly = 'verb360_sub_monthly_19k';

  static const List<IapProductModel> defaultProducts = [
    IapProductModel(
      id: idYearly,
      title: 'Gói 1 Năm',
      priceFormatted: '199.000 đ',
      priceVnd: 199000,
      subtitle: 'Chỉ ~16.500 đ / tháng (Tiết kiệm 15%)',
      badge: 'PHỔ BIẾN NHẤT',
      isSubscription: true,
      period: 'năm',
    ),
    IapProductModel(
      id: idLifetime,
      title: 'Trọn Đời (Lifetime)',
      priceFormatted: '299.000 đ',
      priceVnd: 299000,
      subtitle: 'Thanh toán 1 lần duy nhất, sở hữu mãi mãi',
      badge: 'GIÁ TRỊ NHẤT',
      isSubscription: false,
      period: 'vĩnh viễn',
    ),
    IapProductModel(
      id: idMonthly,
      title: 'Gói 1 Tháng',
      priceFormatted: '19.000 đ',
      priceVnd: 19000,
      subtitle: 'Linh hoạt, tự động gia hạn từng tháng',
      badge: null,
      isSubscription: true,
      period: 'tháng',
    ),
  ];
}
