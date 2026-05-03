import 'package:flutter/material.dart';
import 'package:hire_driver/customwidgets/bottombar.dart';
import 'package:hire_driver/utils/app_colors.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String selectedFilter = 'All';

  final List<_TransactionItemData> allTransactions = const [
    _TransactionItemData(
      type: 'credit',
      title: 'Referral Bonus',
      subtitle: 'Friend signed up',
      time: 'Yesterday',
      amount: '+PKR 200',
      amountColor: Color(0xFF10B981),
      icon: Icons.card_giftcard_rounded,
      iconBg: Color(0xFFCFEFD9),
      iconColor: Color(0xFFE18B1D),
    ),
    _TransactionItemData(
      type: 'credit',
      title: 'Wallet Top-up',
      subtitle: 'Via JazzCash',
      time: '3 days ago',
      amount: '+PKR 2,000',
      amountColor: Color(0xFF10B981),
      icon: Icons.add_rounded,
      iconBg: Color(0xFFCFEFD9),
      iconColor: AppColors.primary,
    ),
    _TransactionItemData(
      type: 'debit',
      title: 'Hire Driver — One Way',
      subtitle: 'Ali Hassan · 12.4 km',
      time: 'Today, 2:00 PM',
      amount: '-PKR 405',
      amountColor: Color(0xFFF05353),
      icon: Icons.local_taxi_rounded,
      iconBg: Color(0xFFF7D9DA),
      iconColor: AppColors.primary,
    ),
    _TransactionItemData(
      type: 'debit',
      title: 'Book a Ride',
      subtitle: 'Zain UI · 8.2 km',
      time: 'Yesterday, 6:30 PM',
      amount: '-PKR 350',
      amountColor: Color(0xFFF05353),
      icon: Icons.directions_car_filled_rounded,
      iconBg: Color(0xFFF7D9DA),
      iconColor: AppColors.primary,
    ),
  ];

  List<_TransactionItemData> get filteredTransactions {
    if (selectedFilter == 'Credit') {
      return allTransactions.where((e) => e.type == 'credit').toList();
    }
    if (selectedFilter == 'Debit') {
      return allTransactions.where((e) => e.type == 'debit').toList();
    }
    return allTransactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const AppBottomNavBar(
        currentIndex: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _WalletBalanceCard(),
              const SizedBox(height: 18),
              const _SectionTitle(title: 'Payment Methods'),
              const SizedBox(height: 12),
              const _PaymentMethodCard(
                title: 'JazzCash',
                subtitle: '0300–XXXXXXX',
                amountText: 'PKR 1,500 available',
                iconColors: [Color(0xFFF18A5B), Color(0xFFFF6B57)],
                badgeText: '✓ Linked',
                badgeBackground: Color(0xFFC9EFD9),
                badgeTextColor: Color(0xFF16935C),
              ),
              const SizedBox(height: 12),
              const _PaymentMethodCard(
                title: 'EasyPaisa',
                subtitle: '0312–XXXXXXX',
                amountText: 'PKR 850 available',
                iconColors: [Color(0xFF8CE39D), Color(0xFF46C785)],
                badgeText: '✓ Linked',
                badgeBackground: Color(0xFFC9EFD9),
                badgeTextColor: Color(0xFF16935C),
              ),
              const SizedBox(height: 12),
              const _PaymentMethodCard(
                title: 'Visa Card',
                subtitle: '**** **** **** 4582',
                amountText: 'Primary card',
                iconColors: [AppColors.secondary, AppColors.primary],
                badgeText: '✓ Linked',
                badgeBackground: Color(0xFFC9EFD9),
                badgeTextColor: Color(0xFF16935C),
              ),
              const SizedBox(height: 20),
              _TransactionHeader(
                selectedFilter: selectedFilter,
                onSelected: (value) {
                  setState(() {
                    selectedFilter = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              ...filteredTransactions.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TransactionCard(item: item),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.darkPrimary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -18,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 54,
            bottom: -46,
            child: Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 30,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.24),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 4, 4, 4),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'HIREDRIVE WALLET',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.72),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'PKR 3,250',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Expanded(
                    child: _WalletActionButton(
                      text: 'Add Money',
                      icon: Icons.add,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _WalletActionButton(
                      text: 'Withdraw ',
                      icon: Icons.payments_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletActionButton extends StatelessWidget {
  final String text;
  final IconData icon;

  const _WalletActionButton({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.white.withOpacity(0.16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.white, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.text1(context),
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amountText;
  final List<Color> iconColors;
  final String badgeText;
  final Color badgeBackground;
  final Color badgeTextColor;

  const _PaymentMethodCard({
    required this.title,
    required this.subtitle,
    required this.amountText,
    required this.iconColors,
    required this.badgeText,
    required this.badgeBackground,
    required this.badgeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: iconColors),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text1(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.text2(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (amountText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  const Text(
                    '',
                    style: TextStyle(fontSize: 0),
                  ),
                  Text(
                    amountText,
                    style: const TextStyle(
                      color: Color(0xFF16935C),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: badgeBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionHeader extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const _TransactionHeader({
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Transaction History',
            style: TextStyle(
              color: AppColors.text1(context),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _TransactionFilterChip(
          text: 'All',
          active: selectedFilter == 'All',
          onTap: () => onSelected('All'),
        ),
        const SizedBox(width: 8),
        _TransactionFilterChip(
          text: 'Credit',
          active: selectedFilter == 'Credit',
          onTap: () => onSelected('Credit'),
        ),
        const SizedBox(width: 8),
        _TransactionFilterChip(
          text: 'Debit',
          active: selectedFilter == 'Debit',
          onTap: () => onSelected('Debit'),
        ),
      ],
    );
  }
}

class _TransactionFilterChip extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _TransactionFilterChip({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? AppColors.primary
                : AppColors.secondary.withOpacity(0.6),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? AppColors.white : AppColors.text2(context),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final _TransactionItemData item;

  const _TransactionCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.secondary.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              item.icon,
              color: item.iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: AppColors.text1(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: AppColors.text2(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.time,
                  style: TextStyle(
                    color: AppColors.text2(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.amount,
            style: TextStyle(
              color: item.amountColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItemData {
  final String type;
  final String title;
  final String subtitle;
  final String time;
  final String amount;
  final Color amountColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _TransactionItemData({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.amount,
    required this.amountColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}