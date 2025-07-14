import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Add Category', icon: Icon(Icons.category)),
            Tab(text: 'Users', icon: Icon(Icons.person)),
            Tab(text: 'Workers', icon: Icon(Icons.engineering)),
            Tab(text: 'Orders', icon: Icon(Icons.assignment)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAddCategoryTab(),
          _buildUsersTab(),
          _buildWorkersTab(),
          _buildOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildAddCategoryTab() {
    return _AddCategoryTab();
  }

  Widget _buildUsersTab() {
    return _ManageUsersTab();
  }

  Widget _buildWorkersTab() {
    return _ManageWorkersTab();
  }

  Widget _buildOrdersTab() {
    return _ManageOrdersTab();
  }
}

class _AddCategoryTab extends StatefulWidget {
  @override
  State<_AddCategoryTab> createState() => _AddCategoryTabState();
}

class _AddCategoryTabState extends State<_AddCategoryTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ApiService();
      final cats = await api.getAdminCategories();
      setState(() {
        _categories = cats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });
    try {
      final api = ApiService();
      await api.createAdminCategory({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'icon': _iconController.text.trim(),
        'color': _colorController.text.trim(),
      });
      setState(() {
        _success = 'Category added successfully!';
        _nameController.clear();
        _descController.clear();
        _iconController.clear();
        _colorController.clear();
      });
      await _fetchCategories();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Category',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'Enter category name'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _iconController,
                        decoration: const InputDecoration(
                          labelText: 'Icon (e.g. category, home, etc.)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(
                          labelText: 'Color (hex, e.g. #1565C0)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label:
                              _isLoading
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text('Add Category'),
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      if (_success != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _success!,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Existing Categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _categories.isEmpty
                ? const Text('No categories found.')
                : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _parseColor(cat['color']),
                        child: Icon(
                          _getIconData(cat['icon']),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(cat['name'] ?? ''),
                      subtitle: Text(cat['description'] ?? ''),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blueGrey;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  IconData _getIconData(String? iconName) {
    if (iconName == null || iconName.isEmpty) return Icons.category;
    final iconData = _iconMap[iconName];
    return iconData ?? Icons.category;
  }

  // Add more icons as needed
  static const Map<String, IconData> _iconMap = {
    'category': Icons.category,
    'home': Icons.home,
    'build': Icons.build,
    'cleaning_services': Icons.cleaning_services,
    'plumbing': Icons.plumbing,
    'electrical_services': Icons.electrical_services,
    'carpenter': Icons.handyman,
    'paint': Icons.format_paint,
    'ac_unit': Icons.ac_unit,
    'garden': Icons.park,
    // Add more as needed
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    super.dispose();
  }
}

class _ManageUsersTab extends StatefulWidget {
  @override
  State<_ManageUsersTab> createState() => _ManageUsersTabState();
}

class _ManageUsersTabState extends State<_ManageUsersTab> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ApiService();
      final users = await api.getAdminUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleActive(Map<String, dynamic> user) async {
    final bool newActive = !(user['is_active'] ?? false);
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(newActive ? 'Activate User' : 'Deactivate User'),
            content: Text(
              'Are you sure you want to ${newActive ? 'activate' : 'deactivate'} this user?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final api = ApiService();
      await api.setUserActive(user['id'], newActive);
      await _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User ${newActive ? 'activated' : 'deactivated'} successfully',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : _users.isEmpty
              ? const Center(child: Text('No users found.'))
              : ListView.separated(
                itemCount: _users.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final user = _users[i];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            user['is_admin'] == true
                                ? Colors.orange
                                : Colors.blue,
                        child: Icon(
                          user['is_admin'] == true
                              ? Icons.admin_panel_settings
                              : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(user['full_name'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['email'] ?? ''),
                          if (user['is_admin'] == true)
                            const Text(
                              'Admin',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (user['is_active'] == false)
                            const Text(
                              'Inactive',
                              style: TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          user['is_active'] == true
                              ? Icons.toggle_on
                              : Icons.toggle_off,
                          color:
                              user['is_active'] == true
                                  ? Colors.green
                                  : Colors.grey,
                          size: 32,
                        ),
                        tooltip:
                            user['is_active'] == true
                                ? 'Deactivate'
                                : 'Activate',
                        onPressed:
                            user['is_admin'] == true
                                ? null
                                : () => _toggleActive(user),
                      ),
                      onTap: () => _showUserDetails(user),
                    ),
                  );
                },
              ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(user['full_name'] ?? 'User Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${user['email'] ?? ''}'),
                Text('Phone: ${user['phone_number'] ?? ''}'),
                Text('Address: ${user['address'] ?? ''}'),
                Text('Created: ${user['created_at'] ?? ''}'),
                Text('Verified: ${user['is_verified'] == true ? 'Yes' : 'No'}'),
                Text('Active: ${user['is_active'] == true ? 'Yes' : 'No'}'),
                if (user['is_admin'] == true)
                  const Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class _ManageWorkersTab extends StatefulWidget {
  @override
  State<_ManageWorkersTab> createState() => _ManageWorkersTabState();
}

class _ManageWorkersTabState extends State<_ManageWorkersTab> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _workers = [];

  @override
  void initState() {
    super.initState();
    _fetchWorkers();
  }

  Future<void> _fetchWorkers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ApiService();
      final workers = await api.getAdminWorkers();
      setState(() {
        _workers = workers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleActive(Map<String, dynamic> worker) async {
    final bool newActive = !(worker['is_active'] ?? false);
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(newActive ? 'Activate Worker' : 'Deactivate Worker'),
            content: Text(
              'Are you sure you want to ${newActive ? 'activate' : 'deactivate'} this worker?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final api = ApiService();
      await api.setWorkerActive(worker['id'], newActive);
      await _fetchWorkers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Worker ${newActive ? 'activated' : 'deactivated'} successfully',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : _workers.isEmpty
              ? const Center(child: Text('No workers found.'))
              : ListView.separated(
                itemCount: _workers.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final worker = _workers[i];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            worker['is_active'] == true
                                ? Colors.green
                                : Colors.grey,
                        child: const Icon(
                          Icons.engineering,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(worker['full_name'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(worker['email'] ?? ''),
                          if (worker['is_active'] == false)
                            const Text(
                              'Inactive',
                              style: TextStyle(color: Colors.red),
                            ),
                          if (worker['is_verified'] == true)
                            const Text(
                              'Verified',
                              style: TextStyle(color: Colors.green),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          worker['is_active'] == true
                              ? Icons.toggle_on
                              : Icons.toggle_off,
                          color:
                              worker['is_active'] == true
                                  ? Colors.green
                                  : Colors.grey,
                          size: 32,
                        ),
                        tooltip:
                            worker['is_active'] == true
                                ? 'Deactivate'
                                : 'Activate',
                        onPressed: () => _toggleActive(worker),
                      ),
                      onTap: () => _showWorkerDetails(worker),
                    ),
                  );
                },
              ),
    );
  }

  void _showWorkerDetails(Map<String, dynamic> worker) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(worker['full_name'] ?? 'Worker Details'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${worker['email'] ?? ''}'),
                  Text('Phone: ${worker['phone_number'] ?? ''}'),
                  Text('Address: ${worker['address'] ?? ''}'),
                  Text('Created: ${worker['created_at'] ?? ''}'),
                  Text(
                    'Verified: ${worker['is_verified'] == true ? 'Yes' : 'No'}',
                  ),
                  Text('Active: ${worker['is_active'] == true ? 'Yes' : 'No'}'),
                  Text('Skills: ${worker['skills'] ?? ''}'),
                  Text('Hourly Rate: ${worker['hourly_rate'] ?? ''}'),
                  Text('Experience: ${worker['experience_years'] ?? ''} years'),
                  Text('Rating: ${worker['rating'] ?? 'N/A'}'),
                  Text('Total Reviews: ${worker['total_reviews'] ?? 'N/A'}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class _ManageOrdersTab extends StatefulWidget {
  @override
  State<_ManageOrdersTab> createState() => _ManageOrdersTabState();
}

class _ManageOrdersTabState extends State<_ManageOrdersTab> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ApiService();
      final orders = await api.getAdminOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _changeStatus(Map<String, dynamic> order) async {
    final String? newStatus = await showDialog<String>(
      context: context,
      builder:
          (ctx) => SimpleDialog(
            title: const Text('Change Order Status'),
            children: [
              ...['pending', 'completed', 'cancelled']
                  .where((s) => s != order['status'])
                  .map(
                    (status) => SimpleDialogOption(
                      child: Text(
                        'Set as ${status[0].toUpperCase()}${status.substring(1)}',
                      ),
                      onPressed: () => Navigator.pop(ctx, status),
                    ),
                  ),
              SimpleDialogOption(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(ctx, null),
              ),
            ],
          ),
    );
    if (newStatus == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final api = ApiService();
      await api.setOrderStatus(order['id'], newStatus);
      await _fetchOrders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : _orders.isEmpty
              ? const Center(child: Text('No orders found.'))
              : ListView.separated(
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final order = _orders[i];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _statusColor(order['status']),
                        child: Icon(Icons.assignment, color: Colors.white),
                      ),
                      title: Text('Order #${order['id']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User: ${order['user']?['full_name'] ?? ''}'),
                          Text(
                            'Worker: ${order['worker']?['full_name'] ?? ''}',
                          ),
                          Text('Status: ${order['status'] ?? ''}'),
                          Text('Amount: ${order['total_amount'] ?? ''}'),
                          Text('Created: ${order['created_at'] ?? ''}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Change Status',
                        onPressed: () => _changeStatus(order),
                      ),
                      onTap: () => _showOrderDetails(order),
                    ),
                  );
                },
              ),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Order #${order['id']}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User:'),
                  if (order['user'] != null) ...[
                    Text('  Name: ${order['user']['full_name'] ?? ''}'),
                    Text('  Email: ${order['user']['email'] ?? ''}'),
                  ],
                  const SizedBox(height: 8),
                  Text('Worker:'),
                  if (order['worker'] != null) ...[
                    Text('  Name: ${order['worker']['full_name'] ?? ''}'),
                    Text('  Email: ${order['worker']['email'] ?? ''}'),
                  ],
                  const SizedBox(height: 8),
                  Text('Service:'),
                  if (order['service'] != null) ...[
                    Text('  Title: ${order['service']['title'] ?? ''}'),
                    Text(
                      '  Description: ${order['service']['description'] ?? ''}',
                    ),
                    Text(
                      '  Hourly Rate: ${order['service']['hourly_rate'] ?? ''}',
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text('Status: ${order['status'] ?? ''}'),
                  Text('Amount: ${order['total_amount'] ?? ''}'),
                  Text('Payment: ${order['payment_method'] ?? ''}'),
                  Text('Scheduled: ${order['scheduled_date'] ?? ''}'),
                  Text('Created: ${order['created_at'] ?? ''}'),
                  Text('Description: ${order['description'] ?? ''}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
