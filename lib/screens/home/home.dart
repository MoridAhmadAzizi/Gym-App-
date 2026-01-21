import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/product_data.dart';
import '../../model/product.dart';
import '../../screens/detail/detail.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _initializeProducts();
  }

  void _initializeProducts() {
    try {
      _allProducts = products;
      _filteredProducts = List<Product>.from(_allProducts);
      print('Products loaded: ${_allProducts.length} items');

      if (_allProducts.isNotEmpty) {
        print('First product imageURL: ${_allProducts[0].imageURL}');
        print(
            'First product imageURL type: ${_allProducts[0].imageURL.runtimeType}');
      }
    } catch (e) {
      print('Error loading products: $e');
      _allProducts = [];
      _filteredProducts = [];
    }
  }

  void _searchProducts(String query) {
    setState(() {
      _searchText = query;

      if (query.isEmpty) {
        _filteredProducts = List<Product>.from(_allProducts);
      } else {
        _filteredProducts = _allProducts.where((product) {
          final title = product.title.toLowerCase();
          final group = product.group.toLowerCase();
          final searchQuery = query.toLowerCase();

          return title.contains(searchQuery) || group.contains(searchQuery);
        }).toList();
      }
    });
  }

  List<Product> _getProductsByTab(int tabIndex) {
    if (_searchText.isNotEmpty) {
      return _filteredProducts.where((product) {
        if (tabIndex == 0) return product.group == 'Group A';
        if (tabIndex == 1) return product.group == 'Group B';
        return true;
      }).toList();
    } else {
      if (tabIndex == 0) {
        return _allProducts.where((p) => p.group == 'Group A').toList();
      } else if (tabIndex == 1) {
        return _allProducts.where((p) => p.group == 'Group B').toList();
      } else {
        return List<Product>.from(_allProducts);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black87,
          title: const Text('Application Home',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        drawer: const NavigationDrawer(),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
                border: BoxBorder.all(
                  color: Colors.grey[800]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300]!,
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: Text(
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy,",
                    style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.none,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CupertinoSearchTextField(
                onChanged: _searchProducts,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2.0,
                  ),
                ),
                placeholder: 'Search...',
                placeholderStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 18.0,
                ),
                prefixIcon: const Icon(
                  CupertinoIcons.search,
                  color: Colors.grey,
                  size: 30.0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 14.0,
                ),
                autofocus: false,
                autocorrect: true,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/add');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Add New',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTabContent(0),
                  _buildTabContent(1),
                  _buildTabContent(2),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(2),
              height: kToolbarHeight - 8.0,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.0)),
              child: TabBar(
                tabs: const [
                  Tab(
                    text: 'Group A',
                  ),
                  Tab(text: 'Group B'),
                  Tab(text: 'All'),
                ],
                labelColor: Colors.white,
                indicatorColor: Colors.grey,
                labelStyle: TextStyle(fontSize: 16),
                unselectedLabelColor: Colors.grey,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.black87),
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(int tabIndex) {
    final products = _getProductsByTab(tabIndex);

    if (_searchText.isNotEmpty && products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 15),
            Text(
              '"$_searchText" not found',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Try different keywords',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: products.map((product) {
          String imagePath;
          if (product.imageURL.isNotEmpty && product.imageURL[0].isNotEmpty) {
            imagePath = product.imageURL[0];
          } else {
            imagePath = 'assets/images/bg1.png';
          }

          return _ImageCard(
            imagePath: imagePath,
            title: product.title,
            description: product.group,
            product: product,
          );
        }).toList(),
      ),
    );
  }

  Widget _ImageCard({
    required String imagePath,
    required String title,
    required String description,
    required Product product,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/detail', extra: product);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: Colors.grey[100]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.asset(
                      imagePath,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_outlined, size: 25),
          ],
        ),
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildHeaderItems(context, user),
            buildMenuItems(context),
          ],
        ),
      ),
    );
  }
}

Widget buildHeaderItems(BuildContext context, User? user) => SafeArea(
      child: Container(
        color: Colors.grey,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 52,
              backgroundImage: AssetImage('assets/images/bg1.png'),
            ),
            const SizedBox(height: 6),
            const Text(
              'Morid Ahmad Azizi',
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            Text(
              '${user?.email!}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );

Widget buildMenuItems(BuildContext context) => Padding(
      padding: const EdgeInsets.all(12.0),
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {},
          ),
          const ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            onTap: signUserout,
          ),
        ],
      ),
    );
void signUserout() {
  FirebaseAuth.instance.signOut();
}
