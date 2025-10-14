import 'package:flutter/material.dart';

void main() => runApp(const PizzeriaApp());

/// ======================== APP ROOT ========================
class PizzeriaApp extends StatelessWidget {
  const PizzeriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderProvider(
      child: MaterialApp(
        title: 'Pizzeria Order System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.light,
        ),
        home: const HomeScreen(),
        onGenerateRoute: (settings) {
          if (settings.name == TableSelectScreen.route) {
            return MaterialPageRoute(builder: (_) => const TableSelectScreen());
          }
          if (settings.name == CategoryScreen.route) {
            final args = settings.arguments as OrderArgs;
            return MaterialPageRoute(builder: (_) => CategoryScreen(args: args));
          }
          if (settings.name == ItemListScreen.route) {
            final args = settings.arguments as ItemListArgs;
            return MaterialPageRoute(builder: (_) => ItemListScreen(args: args));
          }
          if (settings.name == OrderScreen.route) {
            final args = settings.arguments as OrderArgs;
            return MaterialPageRoute(builder: (_) => OrderScreen(args: args));
          }
          return null;
        },
      ),
    );
  }
}

/// ======================== HOME ========================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = [
      _HomeEntry('Table', Icons.restaurant, Colors.teal, TableSelectScreen.route, OrderKind.table),
      _HomeEntry('Takeaway', Icons.shopping_bag, Colors.orange, TableSelectScreen.route, OrderKind.takeaway),
      _HomeEntry('Delivery', Icons.delivery_dining, Colors.indigo, TableSelectScreen.route, OrderKind.delivery),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Order Console'), centerTitle: true),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        padding: const EdgeInsets.all(24),
        children: entries.map((e) => _HomeBox(entry: e)).toList(),
      ),
    );
  }
}

class _HomeEntry {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  final OrderKind kind;
  _HomeEntry(this.label, this.icon, this.color, this.route, this.kind);
}

class _HomeBox extends StatelessWidget {
  final _HomeEntry entry;
  const _HomeBox({required this.entry});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, entry.route, arguments: entry.kind),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: entry.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: entry.color.withOpacity(0.35)),
        ),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(entry.icon, size: 48, color: entry.color),
            const SizedBox(height: 10),
            Text(entry.label, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: entry.color.darken())),
          ]),
        ),
      ),
    );
  }
}

/// ======================== TABLE / TAKEAWAY / DELIVERY ========================
enum OrderKind { table, takeaway, delivery }

class TableSelectScreen extends StatefulWidget {
  static const route = '/select';
  const TableSelectScreen({super.key});

  @override
  State<TableSelectScreen> createState() => _TableSelectScreenState();
}

class _TableSelectScreenState extends State<TableSelectScreen> {
  int tableCount = 20;
  OrderKind kind = OrderKind.table;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments as OrderKind?;
    if (arg != null) kind = arg;
  }

  @override
  Widget build(BuildContext context) {
    final store = OrderProvider.of(context);
    final color = Theme.of(context).colorScheme.primary;

    final count = kind == OrderKind.table ? tableCount : 30;
    final prefix = switch (kind) {
      OrderKind.table => 'T',
      OrderKind.takeaway => 'AP',
      OrderKind.delivery => 'D',
    };

    return Scaffold(
      appBar: AppBar(title: Text('Select ${prefix == "T" ? "Table" : prefix == "AP" ? "Takeaway" : "Delivery"}')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: count,
        itemBuilder: (_, i) {
          final label = '$prefix${i + 1}';
          final total = store.totalFor(label);
          return InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              CategoryScreen.route,
              arguments: OrderArgs(kind: kind, label: label),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(label,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color.darken())),
                  ),
                  if (total > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
                        child: Text('${total.toStringAsFixed(2)} €',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ======================== CATEGORIES ========================
class OrderArgs {
  final OrderKind kind;
  final String label;
  const OrderArgs({required this.kind, required this.label});
}

enum CategoryKey { drinks, starters, pizzas, pastas, veganPizzas, veganPastas, desserts }

class CategoryScreen extends StatelessWidget {
  static const route = '/categories';
  final OrderArgs args;
  const CategoryScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final cats = [
      _Category('Drinks', Icons.local_drink, Colors.cyan, CategoryKey.drinks),
      _Category('Starters', Icons.ramen_dining, Colors.green, CategoryKey.starters),
      _Category('Pizzas', Icons.local_pizza, Colors.redAccent, CategoryKey.pizzas),
      _Category('Pastas', Icons.set_meal, Colors.orange, CategoryKey.pastas),
      _Category('Vegan Pizzas', Icons.eco, Colors.lightGreen, CategoryKey.veganPizzas),
      _Category('Vegan Pastas', Icons.spa, Colors.teal, CategoryKey.veganPastas),
      _Category('Desserts', Icons.icecream, Colors.purple, CategoryKey.desserts),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${args.label} – Choose Category'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.pushNamed(context, OrderScreen.route, arguments: args),
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: cats
            .map((c) => InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    ItemListScreen.route,
                    arguments: ItemListArgs(order: args, category: c.key),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: c.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.color.withOpacity(0.3)),
                    ),
                    child: Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(c.icon, size: 48, color: c.color),
                      const SizedBox(height: 8),
                      Text(c.title,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.color.darken())),
                    ])),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _Category {
  final String title;
  final IconData icon;
  final Color color;
  final CategoryKey key;
  _Category(this.title, this.icon, this.color, this.key);
}

/// ======================== CATALOG (ONE SOURCE OF TRUTH) ========================
/// Edit here only. Categories below just reference codes from this map.
class MenuItem {
  final String code; // e.g. "#20"
  final String name; // e.g. "Pizza Margherita"
  final double price;
  const MenuItem({required this.code, required this.name, required this.price});
}

final Map<String, MenuItem> catalog = {
  // Drinks
  'D01': MenuItem(code: '—', name: 'Apfelschorle 0,33 l', price: 3.00),
  'D02': MenuItem(code: '—', name: 'Kölsch 0,3 l', price: 3.00),
  'D03': MenuItem(code: '—', name: 'Cola 0,33 l', price: 3.00),
  'D04': MenuItem(code: '—', name: 'Fanta 0,33 l', price: 3.00),
  'D05': MenuItem(code: '—', name: 'Coca-Cola Zero 0,33 l', price: 3.00),
  'D06': MenuItem(code: '—', name: 'Mezzo Mix 0,33 l', price: 3.00),
  'D07': MenuItem(code: '—', name: 'San Pellegrino 1,0 l', price: 6.50),
  'D08': MenuItem(code: '—', name: 'Jever Fun 0,33 l', price: 3.50),

  // Starters (bread pricing rule applied as two SKUs)
  'S01': MenuItem(code: '—', name: 'Bruschetta Classic', price: 7.00),
  'S02': MenuItem(code: '—', name: 'Focaccia', price: 5.50),
  'S03': MenuItem(code: '—', name: 'Caprese', price: 10.50),
  'S04': MenuItem(code: '—', name: 'Carpaccio di Manzo', price: 13.00),
  'S05': MenuItem(code: '—', name: 'Carpaccio di Pesce', price: 14.50),
  // Bread + dip rule: normal 4.50, vegan 5.50
  'S10': MenuItem(code: '—', name: 'Brot + Dip (normal)', price: 4.50),
  'S11': MenuItem(code: '—', name: 'Brot + Dip (vegan)', price: 5.50),

  // Pizzas
  'P20': MenuItem(code: '#20', name: 'Pizza Margherita', price: 8.50),
  'P21': MenuItem(code: '#21', name: 'Pizza Bufalina', price: 10.00),
  'P25': MenuItem(code: '#25', name: 'Pizza Funghi', price: 10.00),
  'P30': MenuItem(code: '#30', name: 'Pizza Tonno', price: 11.00),
  'P32': MenuItem(code: '#32', name: 'Pizza Verdura', price: 12.50),
  'P34': MenuItem(code: '#34', name: 'Pizza Quattro Formaggi', price: 12.50),
  'P40': MenuItem(code: '#40', name: 'Pizza Melanzane', price: 12.50),
  'P42': MenuItem(code: '#42', name: 'Pizza Salmone', price: 14.50),

  // Pastas
  'PA61': MenuItem(code: '#61', name: 'Spaghetti Napoli', price: 9.50),
  'PA62': MenuItem(code: '#62', name: 'Spaghetti Bolognese', price: 12.00),
  'PA66': MenuItem(code: '#66', name: 'Penne Arrabiata', price: 10.50),
  'PA69': MenuItem(code: '#69', name: 'Rigatoni Norcina', price: 13.50),

  // Vegan Pizzas (adjust to your real list if different)
  'VP201': MenuItem(code: 'V#201', name: 'Vegan Margherita', price: 9.00),
  'VP232': MenuItem(code: 'V#232', name: 'Vegan Verdura', price: 13.00),
  'VP230': MenuItem(code: 'V#230', name: 'Vegan Tonno (plant-based)', price: 12.00),

  // Vegan Pastas
  'VPA661': MenuItem(code: 'V#661', name: 'Penne Arrabiata (vegan)', price: 10.50),
  'VPA610': MenuItem(code: 'V#610', name: 'Spaghetti Napoli (vegan)', price: 9.50),

  // Desserts
  'DE140': MenuItem(code: '#140', name: 'Tiramisu', price: 7.00),
  'DE141': MenuItem(code: '#141', name: 'Tartufo Eis', price: 6.00),
  'DE143': MenuItem(code: '#143', name: 'Schoko Soufflé', price: 6.00),
};

/// Category → item codes (keys of `catalog`)
final Map<CategoryKey, List<String>> categoryItems = {
  CategoryKey.drinks: ['D01', 'D02', 'D03', 'D04', 'D05', 'D06', 'D07', 'D08'],
  CategoryKey.starters: ['S01', 'S02', 'S03', 'S04', 'S05', 'S10', 'S11'],
  CategoryKey.pizzas: ['P20', 'P21', 'P25', 'P30', 'P32', 'P34', 'P40', 'P42'],
  CategoryKey.pastas: ['PA61', 'PA62', 'PA66', 'PA69'],
  CategoryKey.veganPizzas: ['VP201', 'VP232', 'VP230'],
  CategoryKey.veganPastas: ['VPA661', 'VPA610'],
  CategoryKey.desserts: ['DE140', 'DE141', 'DE143'],
};

/// ======================== ITEMS (TAP TO ADD) ========================
class ItemListArgs {
  final OrderArgs order;
  final CategoryKey category;
  ItemListArgs({required this.order, required this.category});
}

class ItemListScreen extends StatelessWidget {
  static const route = '/items';
  final ItemListArgs args;
  const ItemListScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final store = OrderProvider.of(context);
    final codes = categoryItems[args.category] ?? const <String>[];
    final items = codes.map((c) => catalog[c]!).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('${args.order.label} – ${args.category.name.toUpperCase()}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.pushNamed(context, OrderScreen.route, arguments: args.order),
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final it = items[i];
          return ListTile(
            title: Text('${it.name} ${it.code != "—" ? '(${it.code})' : ''}'),
            trailing: Text('${it.price.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () async {
              final qty = await pickQuantity(context);
              if (qty != null) {
                store.addLine(args.order.label, OrderLine(qty: qty, name: it.name, price: it.price));
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Added: $qty× ${it.name}')));
              }
            },
          );
        },
      ),
    );
  }
}

/// Quantity picker dialog
Future<int?> pickQuantity(BuildContext context, {int initial = 1, int min = 1, int max = 20}) async {
  int qty = initial;
  return showDialog<int>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Quantity'),
      content: StatefulBuilder(
        builder: (ctx, setState) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => setState(() => qty = (qty - 1).clamp(min, max)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('$qty', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => setState(() => qty = (qty + 1).clamp(min, max)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, qty), child: const Text('Add')),
      ],
    ),
  );
}

/// ======================== ORDER SCREEN ========================
class OrderScreen extends StatelessWidget {
  static const route = '/order';
  final OrderArgs args;
  const OrderScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final store = OrderProvider.of(context);
    final order = store.orderFor(args.label);
    final total = store.totalFor(args.label).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: Text('${args.label} – Order (€$total)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('${args.label} – Bill'),
                  content: Text('Total: €$total'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () {
                        store.clear(args.label);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Bill & Clear'),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: order.lines.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final l = order.lines[i];
          return Dismissible(
            key: ValueKey('$i-${l.name}-${l.qty}-${l.price}'),
            background: Container(
              color: Colors.red.withOpacity(0.8),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red.withOpacity(0.8),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              store.removeLineAt(args.label, i);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item removed')));
            },
            child: ListTile(
              leading: Text('${l.qty}×', style: const TextStyle(fontWeight: FontWeight.bold)),
              title: Text(l.name),
              trailing: Text('${(l.qty * l.price).toStringAsFixed(2)} €',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              onTap: () async {
                final newQty = await pickQuantity(context, initial: l.qty);
                if (newQty != null && newQty != l.qty) {
                  store.updateQty(args.label, i, newQty);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

/// ======================== DATA STORE ========================
class OrderProvider extends InheritedNotifier<OrderStore> {
  const OrderProvider({super.key, required Widget child}) : super(notifier: OrderStore(), child: child);
  static OrderStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OrderProvider>()!.notifier!;
}

class OrderStore extends ChangeNotifier {
  final Map<String, OrderData> _orders = {};

  OrderData orderFor(String label) => _orders.putIfAbsent(label, () => OrderData(label: label));

  void addLine(String label, OrderLine line) {
    orderFor(label).lines.add(line);
    notifyListeners();
  }

  void updateQty(String label, int index, int qty) {
    final o = orderFor(label);
    if (index >= 0 && index < o.lines.length) {
      o.lines[index] = o.lines[index].copyWith(qty: qty);
      notifyListeners();
    }
  }

  void removeLineAt(String label, int index) {
    final o = orderFor(label);
    if (index >= 0 && index < o.lines.length) {
      o.lines.removeAt(index);
      notifyListeners();
    }
  }

  double totalFor(String label) {
    final o = _orders[label];
    return o == null ? 0.0 : o.lines.fold(0.0, (s, l) => s + l.qty * l.price);
  }

  void clear(String label) {
    _orders.remove(label);
    notifyListeners();
  }
}

class OrderData {
  final String label;
  final List<OrderLine> lines = [];
  OrderData({required this.label});
}

class OrderLine {
  final int qty;
  final String name;
  final double price;
  OrderLine({required this.qty, required this.name, required this.price});

  OrderLine copyWith({int? qty, String? name, double? price}) =>
      OrderLine(qty: qty ?? this.qty, name: name ?? this.name, price: price ?? this.price);
}

/// ======================== COLOR EXT ========================
extension on Color {
  Color darken([double amount = .2]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
