import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/campaign_card.dart';
import '../campaign/campaign_detail_screen.dart';
import '../topup/topup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
      campaignProvider.loadCampaigns();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
    campaignProvider.setSearchQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await Future.wait([
              campaignProvider.loadCampaigns(),
              authProvider.refreshUser(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selamat datang,',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    authProvider.user?.name ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Balance Card - ✅ DIGANTI dengan BalanceCardSimple
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return BalanceCardSimple(
                      balance: authProvider.user?.balance ?? 0,
                      onTopupTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TopupScreen()),
                        );
                      },
                    );
                  },
                ),

                // Search
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        hintText: 'Cari kampanye...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Categories
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 300),
                  child: SizedBox(
                    height: 50,
                    child: Consumer<CampaignProvider>(
                      builder: (context, campaignProvider, child) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: campaignProvider.categories.length,
                          itemBuilder: (context, index) {
                            final category = campaignProvider.categories[index];
                            final isSelected = campaignProvider.selectedCategory == category;
                            
                            return GestureDetector(
                              onTap: () => campaignProvider.setCategory(category),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: isSelected ? AppTheme.primaryGradient : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Campaigns Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeInLeft(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                    child: const Text(
                      'Kampanye Donasi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Campaigns List
                Consumer<CampaignProvider>(
                  builder: (context, campaignProvider, child) {
                    if (campaignProvider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (campaignProvider.error != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                campaignProvider.error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => campaignProvider.loadCampaigns(),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (campaignProvider.campaigns.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada kampanye',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: campaignProvider.campaigns.asMap().entries.map((entry) {
                          final index = entry.key;
                          final campaign = entry.value;
                          
                          return CampaignCard(
                            campaign: campaign,
                            index: index,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CampaignDetailScreen(campaignId: campaign.id),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}