import 'dart:developer';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/screens/profile/terms_of_use_screen.dart';
import 'package:foxxhealth/features/presentation/screens/profile/privacy_policy_screen.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumOverlay extends StatefulWidget {
  const PremiumOverlay({Key? key}) : super(key: key);

  @override
  State<PremiumOverlay> createState() => _PremiumOverlayState();
}

class _PremiumOverlayState extends State<PremiumOverlay> {
  bool isYearlySelected = true;
  bool _isLoading = false;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs - replace with your actual product IDs from App Store/Google Play
  static const String yearlyProductId = 'foxx_health_yearly_premium';
  static const String monthlyProductId = 'foxx_health_monthly_premium';

  @override
  void initState() {
    super.initState();
    _initializeStore();
    _listenToPurchaseUpdated();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initializeStore() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      setState(() {
        _isAvailable = false;
      });
      return;
    }

    setState(() {
      _isAvailable = true;
    });

    // Load products
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final Set<String> productIds = {yearlyProductId, monthlyProductId};
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        log('Products not found: ${response.notFoundIDs}');
        log('This is normal during development or if app is under review');
      }

      if (response.productDetails.isEmpty) {
        log('No products loaded. This usually means:');
        log('1. App is still under review');
        log('2. Products are not configured in App Store Connect/Google Play Console');
        log('3. Testing on simulator (use real device for testing)');
      }

      setState(() {
        _products = response.productDetails;
      });
    } catch (e) {
      log('Error loading products: $e');
    }
  }

  Future<void> initializePayment() async {
    if (!_isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('In-app purchases are not available on this device')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String productId = isYearlySelected ? yearlyProductId : monthlyProductId;
      
      if (_products.isEmpty) {
        throw 'No products available. Please wait for app review to complete or check your product configuration.';
      }
      
      final ProductDetails product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw 'Product not found: $productId. This usually means the app is still under review.',
      );

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      if (product.id == yearlyProductId) {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }

    } catch (e) {
      log('Error during purchase: $e');
      String errorMessage = e.toString();
      if (errorMessage.contains('Product not found')) {
        errorMessage = 'Products are not available yet. This is normal while your app is under review.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getProductPrice(String productId) {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      return product.currencySymbol + product.rawPrice.toString();
    } catch (e) {
      // Fallback prices if products are not loaded
      return productId == yearlyProductId ? '\$22' : '\$2';
    }
  }

  String _getProductTitle(String productId) {
    return productId == yearlyProductId ? 'Yearly Subscription' : 'Monthly Subscription';
  }

  String _getProductDescription(String productId) {
    return productId == yearlyProductId 
        ? 'Auto renewal 1 year on expiry.' 
        : 'Auto renewal 1 month on expiry.';
  }

  void _listenToPurchaseUpdated() {
    _subscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        log('Error in purchase stream: $error');
      },
    );
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show loading UI
        log('Purchase pending');
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Verify purchase
        await _verifyPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle error
        log('Purchase error: ${purchaseDetails.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: ${purchaseDetails.error?.message ?? "Unknown error"}')),
        );
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        // Handle cancellation
        log('Purchase canceled');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase was canceled')),
        );
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    });
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      log('Starting purchase verification for: ${purchaseDetails.productID}');
      
      String? verificationData;
      String platform = Platform.isIOS ? 'ios' : 'android';
      
      if (Platform.isIOS) {
        // iOS: Get receipt data
        if (purchaseDetails.verificationData.serverVerificationData.isNotEmpty) {
          verificationData = purchaseDetails.verificationData.serverVerificationData;
        } else if (purchaseDetails.verificationData.localVerificationData.isNotEmpty) {
          verificationData = purchaseDetails.verificationData.localVerificationData;
        }
        
        if (verificationData == null || verificationData.isEmpty) {
          throw Exception('No receipt data available for verification');
        }
      } else {
        // Android: Get purchase token
        verificationData = purchaseDetails.purchaseID;
        if (verificationData == null || verificationData.isEmpty) {
          throw Exception('No purchase token available for verification');
        }
      }
      
      // Send verification data to backend
      final verificationSuccess = await _verifyPurchaseWithBackend(
        verificationData: verificationData,
        productId: purchaseDetails.productID,
        platform: platform,
        transactionId: purchaseDetails.purchaseID ?? '',
      );
      
      if (verificationSuccess) {
        log('Purchase verification successful: ${purchaseDetails.productID}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase successful! Welcome to Premium!')),
        );
        
        // Close the premium overlay
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        throw Exception('Purchase verification failed');
      }
      
    } catch (e) {
      log('Purchase verification error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase verification failed: $e')),
      );
    }
  }
  
  Future<bool> _verifyPurchaseWithBackend({
    required String verificationData,
    required String productId,
    required String platform,
    required String transactionId,
  }) async {
    try {
      // TODO: Replace with your actual API client
      // final response = await _apiClient.post(
      //   '/api/v1/subscriptions/verify-purchase',
      //   data: {
      //     if (platform == 'ios') 
      //       'receipt_data': verificationData
      //     else 
      //       'purchase_token': verificationData,
      //     'platform': platform,
      //     'product_id': productId,
      //     'transaction_id': transactionId,
      //     if (platform == 'android') 'package_name': 'com.foxxhealth',
      //   },
      // );
      
      // For now, simulate successful verification
      // In production, replace this with actual API call
      log('Simulating ${platform} purchase verification...');
      await Future.delayed(const Duration(seconds: 1));
      
      // return response.statusCode == 200;
      return true; // Temporary - replace with actual API response check
      
    } catch (e) {
      log('Backend verification error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
      color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.amethystViolet),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text('Premium Plan', style: AppTextStyles.heading3),
                      const SizedBox(width: 50),
                    ],
                  ),
                ),
                _buildPremiumBenefits(),
                  Container(
                    color: Colors.transparent,
                child: Column(
                  children: [
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isYearlySelected = true;
                    });
                  },
                  child: _buildSubscriptionOption(
                    title: _getProductTitle(yearlyProductId),
                    price: _getProductPrice(yearlyProductId),
                    description: _getProductDescription(yearlyProductId),
                    isSelected: isYearlySelected,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isYearlySelected = false;
                    });
                  },
                  child: _buildSubscriptionOption(
                    title: _getProductTitle(monthlyProductId),
                    price: _getProductPrice(monthlyProductId),
                    description: _getProductDescription(monthlyProductId),
                    isSelected: !isYearlySelected,
                  ),
                ),
            
                     const SizedBox(height: 48),
                _buildTestimonial(),
                const SizedBox(height: 16),
                _buildTermsOfService(),
                const SizedBox(height:10),
                
                
                  ],
                ),
              ),
             
                _buildTrialButton(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBenefits() {
    return Container(
      color: AppColors.lightViolet,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Premium Benefits',
                style: AppTextStyles.heading2
                    .copyWith(color: AppColors.amethystViolet)),
            const SizedBox(height: 3),
            _buildBenefitItem('Unlock the Personal Health Guide'),
            _buildBenefitItem('In-appointment support'),
            _buildBenefitItem('First access to exclusive events'),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4,right: 10,left: 10),
      child: Row(
        children: [
          Text('• ', style: AppTextStyles.bodyOpenSans),
          Expanded(
            child: Text(text, style: AppTextStyles.bodyOpenSans.copyWith(fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOption({
    required String title,
    required String price,
    required String description,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(
          width: isSelected ? 3 : 1,
            color: isSelected ? AppColors.amethystViolet : Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(color: isSelected ? AppColors.amethystViolet : Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.captionOpenSans.copyWith()
                ),
                Text(
                  'Cancel Anytime',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: AppTextStyles.bodyOpenSans.copyWith(fontSize: 22,
            color: isSelected ? AppColors.amethystViolet : Colors.black,
              fontWeight: FontWeight.w600)
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonial() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Text(
        "Every woman deserves a tool like the FoXx Health app",
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w400),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTermsOfService() {
    return Center(
      child: Column(
        children: [
          Text(
            'By subscribing, you agree to our ',
            style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigate to Terms of Use
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TermsOfUseScreen(),
                    ),
                  );
                },
                child: Text(
                  'Terms of Use',
                  style: TextStyle(
                    color: AppColors.amethystViolet,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                ' and ',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to Privacy Policy
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.amethystViolet,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrialButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 16),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(

        onPressed: _isLoading ? null : initializePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amethystViolet,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Start Free 3-day Trial',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

