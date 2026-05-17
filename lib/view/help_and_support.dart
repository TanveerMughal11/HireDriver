import 'package:flutter/material.dart';
import 'package:hire_driver/customwidgets/bottombar.dart';
import 'package:hire_driver/utils/app_colors.dart';
import 'package:hire_driver/view/livechat.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String selectedCategory = 'All';

  final List<Map<String, String>> faqs = [
    {
      "category": "Rides",
      "q": "How does Hire a Driver work?",
      "a":
          "You provide your own car. Our verified driver comes to your location and drives your vehicle to the destination you specify. You sit back and relax in your own car.",
    },
    {
      "category": "Pricing",
      "q": "How is the fare calculated?",
      "a":
          "For hire services, fares are calculated per hour. For rides, you set your own price and drivers can accept or counter-offer. There are no hidden charges.",
    },
    {
      "category": "Safety",
      "q": "Is my car safe with a HireDrive driver?",
      "a":
          "Yes. All drivers undergo strict background checks, CNIC verification, and driving history analysis. Trips are GPS-monitored and you can trigger SOS at any time.",
    },
    {
      "category": "Earnings",
      "q": "How do I earn by renting my car?",
      "a":
          "List your car in 3 steps — car info, photos, pricing. Approve rental requests from verified renters and earn every day your car is rented. We handle payments.",
    },
    {
      "category": "Payments",
      "q": "What payment methods are accepted?",
      "a":
          "We accept JazzCash, EasyPaisa, Bank Transfer, and cash. Your HD Wallet makes repeat bookings faster and more secure.",
    },
  ];

  List<String> get categories => [
        'All',
        'Rides',
        'Pricing',
        'Safety',
        'Earnings',
        'Payments',
      ];

  List<Map<String, String>> get filteredFaqs {
    final query = _searchController.text.trim().toLowerCase();

    return faqs.where((faq) {
      final matchesCategory =
          selectedCategory == 'All' || faq['category'] == selectedCategory;

      final matchesSearch = query.isEmpty ||
          faq['q']!.toLowerCase().contains(query) ||
          faq['a']!.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _submitTicket() {
    if (_subjectController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill subject and message'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ticket submitted successfully'),
      ),
    );

    _subjectController.clear();
    _messageController.clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faqList = filteredFaqs;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const AppBottomNavBar(
        currentIndex: 3,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help & Support',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text1(context),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _SupportCard(
                      title: 'Live Chat',
                      subtitle: 'Avg 2 min reply',
                      icon: Icons.chat_bubble_rounded,
                      gradient: const [AppColors.primary, AppColors.darkPrimary],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LiveChatScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  _SupportCard(
                    title: 'Call Us',
                    subtitle: '9AM – 11PM daily',
                    icon: Icons.call_rounded,
                    gradient: const [Color(0xFFFF7B3A), Color(0xFFFF9158)],
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Call support: +92 300 111 2222'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.45),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(
                    color: AppColors.text1(context),
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    icon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                    ),
                    hintText: 'Search FAQ',
                    hintStyle: TextStyle(
                      color: AppColors.text2(context),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final active = selectedCategory == category;

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.card(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: active
                                ? AppColors.primary
                                : AppColors.secondary,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: active
                                ? AppColors.white
                                : AppColors.text2(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text1(context),
                ),
              ),
              const SizedBox(height: 14),
              if (faqList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.45),
                    ),
                  ),
                  child: Text(
                    'No FAQ found for this search.',
                    style: TextStyle(
                      color: AppColors.text2(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                ...faqList.map(
                  (faq) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FaqTile(
                      question: faq["q"]!,
                      answer: faq["a"]!,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.45),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Raise a Ticket',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TicketInputField(
                      controller: _subjectController,
                      hintText: 'Subject',
                    ),
                    const SizedBox(height: 12),
                    _TicketInputField(
                      controller: _messageController,
                      hintText: 'Describe your issue',
                      maxLines: 5,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Submit Ticket',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback? onTap;

  const _SupportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: AppColors.white),
            const SizedBox(height: 12),
            const SizedBox(height: 0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        setState(() {
          isOpen = !isOpen;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.45),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1(context),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (isOpen) ...[
              Container(
                height: 1,
                color: AppColors.secondary.withOpacity(0.35),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  widget.answer,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.text2(context),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TicketInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const _TicketInputField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.6),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          color: AppColors.text1(context),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.text2(context),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}