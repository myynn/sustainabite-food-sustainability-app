import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:project_part2/firebase_options.dart';
import 'package:project_part2/screens/business_screen.dart';
import 'package:project_part2/screens/cart_screen.dart';
import 'package:project_part2/screens/change_password_screen.dart';
import 'package:project_part2/screens/login_screen.dart';
import 'package:project_part2/screens/profile_screen.dart';
import 'package:project_part2/screens/reset_password_screen.dart';
import 'package:project_part2/screens/settings_screen.dart';
import 'package:project_part2/screens/signup_screen.dart';
import 'package:project_part2/screens/start_screen.dart';
import 'package:project_part2/services/cart_store.dart';
import 'package:project_part2/services/firebase_service.dart';
import 'package:project_part2/services/nets_service.dart';
import 'package:project_part2/services/notification_service.dart';
import 'package:project_part2/services/theme_service.dart';
import 'package:project_part2/widgets/app_drawer.dart';
import 'package:project_part2/widgets/category_icon.dart';
import 'package:project_part2/widgets/food_card.dart';
import 'package:project_part2/widgets/search_bar.dart';
import 'package:project_part2/screens/item_details_screen.dart';
import 'package:project_part2/models/food_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //ensures flutter is properly initialised before doing any asnyc operations
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //initialises the firebase using platform specific configuration from firebase options dart
  GetIt.instance.registerLazySingleton(
    () => FirebaseService(),
  ); //registers the firebaseservice class using getit, registerlazy singleton ensures only one instance is created when first accessed
  GetIt.I.registerLazySingleton(() => CartStore());   // this is for my cart store in the service folder
  GetIt.I.registerLazySingleton(() => OrdersStore()); // this is for my cart store in the service folder
  GetIt.I.registerLazySingleton(() => NETSService()); //this is for the nets service for qr payment
  GetIt.I.registerLazySingleton<ThemeService>(() => ThemeService()); //this is for the theme service for chagning theme in settings screen
  await NotificationService.init();
  runApp(MyApp()); //starts the app by running the root widget myapp
}

// this is the main page of the app where users can search, view and filter the food items
class MyApp extends StatelessWidget {
  final fbService = GetIt.I<FirebaseService>(); //retrieves the registered instance of firebaseservice via getit
  final themeService = GetIt.I<ThemeService>();

  @override
  Widget build(BuildContext context) {
      return StreamBuilder<Color>(
        stream: themeService.getThemeStream(), //this is to listen to any theme changes from teh theme service
        initialData: Colors.green.shade100, 
        builder: (context, snap) {
          final seedColor = snap.data ?? Colors.green.shade100;
          return StreamBuilder<User?>(
            stream: fbService.getAuthUser(), //this listens to firebase auth user changes
            builder: (context, snapshot) {
              return MaterialApp(
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
                  useMaterial3: true,
                ),
                home: const SplashScreen(), //this is to show my splash screen before my start screen or home screen depending if the user is logged in or not
                routes: {
                  ProfileScreen.routeName: (_) => ProfileScreen(),
                  BusinessScreen.routeName: (_) => BusinessScreen(),
                  CartScreen.routeName: (_) => CartScreen(),
                  StartScreen.routeName: (_) => StartScreen(),
                  LoginScreen.routeName: (_) => LoginScreen(),
                  SignupScreen.routeName: (_) => SignupScreen(),
                  MainScreen.routeName: (_) => MainScreen(),
                  ResetPasswordScreen.routeName: (_) => ResetPasswordScreen(),
                  ChangePasswordScreen.routeName: (_) => ChangePasswordScreen(),
                  SettingsScreen.routeName: (_) => SettingsScreen(),
                },
              );
            },
          );
        },
      );
    }
  }

//this is the splash screen that is displayed when user first opens the app
  class SplashScreen extends StatefulWidget {
    const SplashScreen({super.key});

    @override
    State<SplashScreen> createState() => _SplashScreenState();
  }

class _SplashScreenState extends State<SplashScreen> {
  final fb = GetIt.I<FirebaseService>();

  @override
  void initState() {
    super.initState();
    // the splash screen will be on for 5 secs, then decide where to go based on auth state, whether the user is logged in or not
    Future.delayed(const Duration(seconds: 5), () async {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => isLoggedIn ? MainScreen() : StartScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAED3BE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, //to align all the text an image in centre on my splash screen
          children: [
            const Text(
              'SustainaBite', //my app name sustainabite
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.black87,
              ),
            ),
            // Logo
            Image.asset(
              'images/sustainabite3.png', //my app logo image
              height: 150,
            ),
            const SizedBox(height: 20),
            // Tagline
            const Text(
              'Fresh food, greener planet.', //my app slogan
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            // this is for the spinner shown on the splash screen
            const CircularProgressIndicator(
              color: Color(0xFF4E6E58), // and this is the spinner colour
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  static String routeName = '/main';

  @override
  _MainScreenState createState() => _MainScreenState();
}

//this is my home screen with search filters category icon buttons and food listings cards
class _MainScreenState extends State<MainScreen> {
  //this is the filter for the different types of cuisine displayed in the home screen
  int _selectedIndex = 0;
  // Search
  final TextEditingController _searchCtrl = TextEditingController();

  // Icon buttons for my advanced query select with multiple filter for same field and select with aggregation
  final Map<String, IconData> _catButtons = const {
    'Western': Icons.lunch_dining,
    'Japanese': Icons.ramen_dining,
    'Indian': Icons.restaurant,
    'Korean': Icons.rice_bowl,
  };
  final Set<String> _selectedCats = {};

  // this is the bottom sheet dialog filter buttons
  String? _selectedCategory; // this is the single category for select with multiple different fields advanced query
  String? _countLabel;
  Future<int>? _countFuture;
  double? _maxPrice; // this is my select with other filter criteria other than identifier
  bool _sortByPriceAsc = false; // this is my select with sort order
  

  // Firebase service
  final FirebaseService fb = GetIt.instance<FirebaseService>();

  void _onItemTapped(int index) {
    //this is for the navgiation between the different screens, the home screen is 0 the profile is 1 and business is 2
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.pushNamed(context, ProfileScreen.routeName);
    } else if (index == 2) {
      Navigator.pushNamed(context, BusinessScreen.routeName);
    }
  }

  // this is to decide which fetch method is used based on the filters selected by the users
  Future<List<FoodItem>> _fetchMainFeed() {
    final search = _searchCtrl.text.trim();
    if (search.isNotEmpty) {
      return fb.searchByNamePrefix(search); //this is for my search bar
    }

    if (_selectedCats.isNotEmpty) {
      return fb.filterByCategories(_selectedCats.toList()); //this is for my select with multiple criteria for same field
    }

    if ((_selectedCategory != null && _selectedCategory!.isNotEmpty) && //this is for my select with multiple criteria for different field
        _maxPrice != null) {
      return fb.filterCategoryAndPrice(_selectedCategory!, _maxPrice!); //for both category and maximum discounted price
    }

    if (_maxPrice != null) {
      return fb.filterByMaxPrice(_maxPrice!); //this is for my select with filter criteria other than identifier for less than or equals to the max discounted price selected by the user
    }

    if (_sortByPriceAsc) {
      return fb.listAllSortedByPrice(limit: 50); //this is for my select with sort order for ordering prices from low to high
    }

    // this is the default without any filters displaying items by newwest first
    return FirebaseFirestore.instance
        .collection('food_items')
        .orderBy('date', descending: true)
        .get()
        .then((qs) => qs.docs.map((d) => fb.mapDocToFoodItem(d)).toList());
  }

  // this is my bottom sheet dialog for the filter button
  void _openFilterSheet() {
    String? tmpCategory = _selectedCategory;
    double tmpMaxPrice = _maxPrice ?? 10.0;
    bool tmpSortAsc = _sortByPriceAsc;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFA1CEAF),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters', //this is the filters text at the top
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30, //this is to make the text slightly bigger than the rest
                    ),
                  ),
                  const SizedBox(height: 12),

                  // these are the categories
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children:
                        _catButtons.keys.map((c) {
                          final selected = tmpCategory == c;
                          return ChoiceChip(
                            label: Text(c),
                            selected: selected,
                            onSelected:
                                (_) => setState(() {
                                  tmpCategory = selected ? null : c;
                                }),
                            selectedColor: const Color(0xFFFFBF70),
                            backgroundColor: const Color(0xFFDDE7DA),
                            labelStyle: const TextStyle(color: Colors.black),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // this is the maximum discounted price slider
                  const Text(
                    'Max discounted price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider( //the slider to select the maximum price
                    value: tmpMaxPrice,
                    onChanged: (v) => setState(() => tmpMaxPrice = v),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    activeColor: Colors.green[800],
                    label: '\$${tmpMaxPrice.toStringAsFixed(2)}',
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '\$${tmpMaxPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sort
                  const Text(
                    'Sort',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<bool>(
                    value: true,
                    groupValue: tmpSortAsc,
                    title: const Text('Price: Low → High'), //this is to select whether they want to sort the items from low to high
                    onChanged: (v) => setState(() => tmpSortAsc = v ?? false),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<bool>(
                    value: false,
                    groupValue: tmpSortAsc,
                    title: const Text('None'), //or they can choose this for no filter
                    onChanged: (v) => setState(() => tmpSortAsc = v ?? false),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = null;
                            _maxPrice = null;
                            _sortByPriceAsc = false;
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset'), //the reset buttn to reset the filters
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = tmpCategory;
                            _maxPrice = tmpMaxPrice;
                            _sortByPriceAsc = tmpSortAsc;
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFBF70),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Apply'), //the apply for applying the filters
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // this is a helper to decode base64 for card image
  ImageProvider? _img(String b64) {
    if (b64.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(b64));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSearch = _searchCtrl.text.trim().isNotEmpty;
    final hasIconCats = _selectedCats.isNotEmpty;
    final hasSheetFilters =
        (_selectedCategory != null && _selectedCategory!.isNotEmpty) ||
        _maxPrice != null ||
        _sortByPriceAsc;

    return Scaffold(
      drawer:
          AppDrawer(), //to navigate to the app drawer widget file in the widget folder this is also the hamburger menu
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
            ), //the app bar has the cart icon on the top right that routes to the cart page
            onPressed: () {
              Navigator.pushNamed(context, CartScreen.routeName);
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        //this allows the user to select the page they want based on the index selected as explained above
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Color(0xFFA1CEAF),
        selectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.home, 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.person, 1),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.store, 2),
            label: 'Business',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            SearchBarWidget(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
            ), //this is the search bar widget under the widget folder
            const SizedBox(height: 16),

            //categories and filter button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                //this is the filter bottom sheet dialog button
                TextButton.icon(
                  onPressed: _openFilterSheet,
                  icon: const Icon(Icons.tune, color: Colors.black),
                  label: const Text(
                    'Filter',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFDDE7DA),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            const SizedBox(height: 12),

            //this is the category icons which are the icon buttons seen below the category title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  _catButtons.entries.map((e) {
                    final label = e.key;
                    final icon = e.value;
                    final selected = _selectedCats.contains(label);
                    return CategoryIcon(
                      icon: icon,
                      label: label,
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedCats.remove(label);
                          } else {
                            _selectedCats.add(label);
                          }
                          _countLabel = label;
                          _countFuture = GetIt.I<FirebaseService>().countByCategory(label); //this is for the advanced query select with aggregation to count the number of items are in teh categry selected
                        });
                      },
                    );
                  }).toList(),
            ),

            const SizedBox(height: 8),

            if (_countFuture != null && _countLabel != null)
              FutureBuilder<int>(
                future: _countFuture,
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Text('Counting…', style: TextStyle(color: Colors.black54)); //shows that it is counting so users can wait
                  }
                  if (snap.hasError) {
                    return const Text('Count failed', style: TextStyle(color: Colors.black54)); //shows that they failed to count the number of food items
                  }
                  final n = snap.data ?? 0;
                  return Text(
                    '$n items in $_countLabel', //this is to show the number of food items are in teh category selected
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  );
                },
              ),

            SizedBox(height: 16),

            //this is the first rescue a meal section
            _buildSectionTitle('Rescue a meal'),
            _buildHorizontalFeed(
              hasSearch,
              hasIconCats,
              hasSheetFilters,
            ), //this is for the food cards also found in the widget folder

            SizedBox(height: 20),

            //this is the second section tasty saves
            _buildSectionTitle('Tasty saves'),
            _buildHorizontalFeed(
              hasSearch,
              hasIconCats,
              hasSheetFilters,
            ), //this is for the food cards also
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    //this is the view all beside the section 1 and 2 title to allow users to view all the food items under each section
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text('View all', style: TextStyle(color: Colors.green)),
      ],
    );
  }

  Widget _buildHorizontalFeed(
    bool hasSearch,
    bool hasIconCats,
    bool hasSheetFilters,
  ) {
    if (hasSearch || hasIconCats || hasSheetFilters) {
      return FutureBuilder<List<FoodItem>>(
        future: _fetchMainFeed(),
        builder: (context, snap) => _buildFoodCardsFromSnapshot(snap),
      );
    }
    return StreamBuilder<List<FoodItem>>(
      stream: fb.getAllFoodItems(newestFirst: true), //tis is to get all teh food items and newest first
      builder: (context, snap) => _buildFoodCardsFromSnapshot(snap),
    );
  }

  Widget _buildFoodCardsFromSnapshot(AsyncSnapshot<List<FoodItem>> snap) {
    if (snap.connectionState == ConnectionState.waiting) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (snap.hasError) {
      return SizedBox(
        height: 200,
        child: Center(child: Text('Failed: ${snap.error}')), //to show that there is an error 
      );
    }
    final items = snap.data ?? [];
    if (items.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No items match your filters.')), //to show that there are no items that match the users selected items
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final it = items[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemDetailsScreen(docId: it.id),
                ),
              );
            },
            child: FoodCard(
              imageProvider: _img(it.image),
              title: it.foodName,
              originalPrice: it.originalPrice.toStringAsFixed(2),
              discountedPrice: it.discountedPrice.toStringAsFixed(2),
              co2Saved: it.estimateCO2SavedKg.toStringAsFixed(1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    //this is for the bottom nav when the user is on that screen then there will be a round box around the icon that is green
    return Container(
      decoration:
          _selectedIndex == index
              ? BoxDecoration(
                color: Color(0xFFDDE7DA),
                borderRadius: BorderRadius.circular(16),
              )
              : null,
      padding: EdgeInsets.all(8),
      child: Icon(icon),
    );
  }
}
