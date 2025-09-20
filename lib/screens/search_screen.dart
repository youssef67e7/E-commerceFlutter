import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/products_provider.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/widgets/product_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  bool _showFilters = false;
  String _selectedCategory = 'All';
  double _minPrice = 0;
  double _maxPrice = 2000;
  double _minRating = 0;
  String _sortBy = 'relevance';

  List<Product> _filteredProducts = [];
  bool _isSearching = false;

  final List<String> _categories = [
    'All',
    'Electronics',
    'Fashion',
    'Home & Garden',
    'Sports',
    'Books',
    'Health & Beauty',
    'Automotive',
  ];

  final List<String> _sortOptions = [
    'relevance',
    'price_low_high',
    'price_high_low',
    'rating_high_low',
    'newest',
  ];

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );

    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredProducts = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _performSearch();
  }

  void _performSearch() {
    final productsProvider = Provider.of<ProductsProvider>(
      context,
      listen: false,
    );
    final allProducts = productsProvider.products;

    final query = _searchController.text.toLowerCase();

    List<Product> results =
        allProducts.where((product) {
          // Text search
          final matchesText =
              product.title.toLowerCase().contains(query) ||
              product.description.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query);

          // Category filter
          final matchesCategory =
              _selectedCategory == 'All' ||
              product.category.toLowerCase().contains(
                _selectedCategory.toLowerCase(),
              );

          // Price filter
          final matchesPrice =
              product.price >= _minPrice && product.price <= _maxPrice;

          // Rating filter
          final matchesRating = product.rating >= _minRating;

          return matchesText &&
              matchesCategory &&
              matchesPrice &&
              matchesRating;
        }).toList();

    // Apply sorting
    switch (_sortBy) {
      case 'price_low_high':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high_low':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating_high_low':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
        // For demo purposes, sort by ID (newest first)
        results.sort((a, b) => b.id.compareTo(a.id));
        break;
      default:
        // Relevance - keep original order
        break;
    }

    setState(() {
      _filteredProducts = results;
      _isSearching = false;
    });
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _minPrice = 0;
      _maxPrice = 2000;
      _minRating = 0;
      _sortBy = 'relevance';
    });
    _performSearch();
  }

  String _getSortDisplayName(String sortKey) {
    switch (sortKey) {
      case 'price_low_high':
        return 'Price: Low to High';
      case 'price_high_low':
        return 'Price: High to Low';
      case 'rating_high_low':
        return 'Highest Rated';
      case 'newest':
        return 'Newest First';
      default:
        return 'Relevance';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon:
                                  _searchController.text.isNotEmpty
                                      ? IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                        icon: const Icon(Icons.clear),
                                      )
                                      : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleFilters,
                        icon: AnimatedRotation(
                          turns: _showFilters ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.tune,
                            color:
                                _showFilters
                                    ? Theme.of(context).primaryColor
                                    : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Filters Section
                  SizeTransition(
                    sizeFactor: _filterAnimation,
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Filters',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: _clearFilters,
                                child: const Text('Clear All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Category Filter
                          const Text(
                            'Category',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children:
                                _categories.map((category) {
                                  final isSelected =
                                      _selectedCategory == category;
                                  return FilterChip(
                                    label: Text(category),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedCategory = category;
                                      });
                                      _performSearch();
                                    },
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // Price Range
                          const Text(
                            'Price Range',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          RangeSlider(
                            values: RangeValues(_minPrice, _maxPrice),
                            min: 0,
                            max: 2000,
                            divisions: 40,
                            labels: RangeLabels(
                              '\$${_minPrice.round()}',
                              '\$${_maxPrice.round()}',
                            ),
                            onChanged: (values) {
                              setState(() {
                                _minPrice = values.start;
                                _maxPrice = values.end;
                              });
                            },
                            onChangeEnd: (values) {
                              _performSearch();
                            },
                          ),
                          const SizedBox(height: 16),

                          // Rating Filter
                          Row(
                            children: [
                              const Text(
                                'Minimum Rating',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Text('${_minRating.toStringAsFixed(1)} ⭐'),
                            ],
                          ),
                          Slider(
                            value: _minRating,
                            min: 0,
                            max: 5,
                            divisions: 10,
                            onChanged: (value) {
                              setState(() {
                                _minRating = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _performSearch();
                            },
                          ),
                          const SizedBox(height: 16),

                          // Sort By
                          const Text(
                            'Sort By',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _sortBy,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items:
                                _sortOptions.map((option) {
                                  return DropdownMenuItem(
                                    value: option,
                                    child: Text(_getSortDisplayName(option)),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _sortBy = value;
                                });
                                _performSearch();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Results
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredProducts.isEmpty) {
      return _buildNoResults();
    }

    return Column(
      children: [
        // Results Count
        Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
          child: Text(
            '${_filteredProducts.length} results found',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),

        // Products Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              return ProductItem(product: _filteredProducts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Search for products',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Find exactly what you\'re looking for',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _clearFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}
