import 'package:flutter/material.dart';

void main() => runApp(const PizzeriaApp());

/// ======================== APP ROOT ========================
class PizzeriaApp extends StatelessWidget {
  const PizzeriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OrderProvider(
      child: MaterialApp(
        title: 'Order Console',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.light,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
        onGenerateRoute: (settings) {
          if (settings.name == TableSelectScreen.route) {
            final kind = settings.arguments as OrderKind? ?? OrderKind.table;
            return MaterialPageRoute(builder: (_) => TableSelectScreen(kind: kind));
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
    final items = <_Entry>[
      _Entry(label: 'Table', icon: Icons.restaurant, route: TableSelectScreen.route, color: Colors.teal, arg: OrderKind.table),
      _Entry(label: 'Takeaway', icon: Icons.shopping_bag, route: TableSelectScreen.route, color: Colors.orange, arg: OrderKind.takeaway),
      _Entry(label: 'Delivery', icon: Icons.delivery_dining, route: TableSelectScreen.route, color: Colors.indigo, arg: OrderKind.delivery),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Order Console'), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 650;
          final padding = EdgeInsets.symmetric(horizontal: isWide ? 32 : 16, vertical: isWide ? 24 : 16);
          final child = isWide
              ? GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  padding: padding,
                  children: items.map((e) => _HomeBox(entry: e)).toList(),
                )
              : ListView.separated(
                  padding: padding,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => _HomeBox(entry: items[i], tall: true),
                );
          return child;
        },
      ),
    );
  }
}

class _Entry {
  final String label;
  final IconData icon;
  final String route;
  final Color color;
  final Object? arg;
  const _Entry({required this.label, required this.icon, required this.route, required this.color, this.arg});
}

class _HomeBox extends StatelessWidget {
  final _Entry entry;
  final bool tall;
  const _HomeBox({required this.entry, this.tall = false});

  @override
  Widget build(BuildContext context) {
    final boxHeight = tall ? 120.0 : 160.0;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.pushNamed(context, entry.route, arguments: entry.arg),
      child: Ink(
        height: boxHeight,
        decoration: BoxDecoration(
          color: entry.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: entry.color.withOpacity(0.35), width: 1),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(entry.icon, size: 44, color: entry.color),
                  const SizedBox(width: 14),
                  Text(
                    entry.label,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: entry.color.darken(),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ======================== SELECT GRID ========================
enum OrderKind { table, takeaway, delivery }

class TableSelectScreen extends StatelessWidget {
  static const route = '/select';
  final OrderKind kind;
  const TableSelectScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final store = OrderProvider.of(context);

    final count = kind == OrderKind.table ? 16 : 50; // T1..T16 as requested
    final title = kind == OrderKind.table
        ? 'Select Table'
        : kind == OrderKind.takeaway
            ? 'Select Takeaway'
            : 'Select Delivery';

    final labels = List<String>.generate(count, (i) {
      final n = i + 1;
      return kind == OrderKind.table ? 'T$n' : kind == OrderKind.takeaway ? 'AP$n' : 'D$n';
    });

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 600;
          final cross = isWide ? 5 : 3;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemCount: labels.length,
            itemBuilder: (_, i) {
              final label = labels[i];
              final total = store.totalFor(label);
              return _TableButton(
                label: label,
                color: color,
                total: total > 0 ? total : null,
                onTap: () => Navigator.pushNamed(
                  context,
                  CategoryScreen.route,
                  arguments: OrderArgs(kind: kind, label: label),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TableButton extends StatelessWidget {
  final String label;
  final Color color;
  final double? total; // show badge only when not null
  final VoidCallback onTap;
  const _TableButton({super.key, required this.label, required this.color, required this.onTap, this.total});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                label,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color.darken()),
              ),
            ),
            if (total != null)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${total!.toStringAsFixed(2)} €',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ======================== CATEGORY SCREEN ========================
class OrderArgs {
  final OrderKind kind;
  final String label; // T1 / AP1 / D1
  const OrderArgs({required this.kind, required this.label});
}

class CategoryScreen extends StatelessWidget {
  static const route = '/categories';
  final OrderArgs args;
  const CategoryScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final categories = <_Category>[
      _Category('Drinks', Icons.local_drink, CategoryKey.drinks, Colors.cyan),
      _Category('Starters', Icons.ramen_dining, CategoryKey.starters, Colors.green),
      _Category('Salads', Icons.set_meal, CategoryKey.salads, Colors.lightGreen),
      _Category('Pizzas', Icons.local_pizza, CategoryKey.pizzas, Colors.redAccent),
      _Category('Spezial-Pizza', Icons.local_pizza_outlined, CategoryKey.spezialPizza, Colors.deepOrange),
      _Category('Pastas', Icons.dinner_dining, CategoryKey.pastas, Colors.orange),
      _Category('Al Forno', Icons.local_fire_department, CategoryKey.alForno, Colors.brown),
      _Category('Snacks', Icons.fastfood, CategoryKey.snacks, Colors.amber),
      _Category('Schnitzel', Icons.set_meal_outlined, CategoryKey.schnitzel, Colors.blueGrey),
      _Category('Fish', Icons.set_meal_rounded, CategoryKey.fish, Colors.indigo),
      _Category('Desserts', Icons.icecream, CategoryKey.desserts, Colors.purple),
      _Category('Vegan Pizzas', Icons.eco, CategoryKey.veganPizzas, Colors.teal),
      _Category('Vegan Pastas', Icons.eco_outlined, CategoryKey.veganPastas, Colors.tealAccent),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${args.label} – Choose Category'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, OrderScreen.route, arguments: args),
            icon: const Icon(Icons.receipt_long),
            label: const Text('Order'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 800;
          final cross = isWide ? 3 : 2;
          return GridView.count(
            crossAxisCount: cross,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            padding: const EdgeInsets.all(16),
            children: categories
                .map((cat) => _CategoryCard(
                      cat: cat,
                      onTap: () => Navigator.pushNamed(
                        context,
                        ItemListScreen.route,
                        arguments: ItemListArgs(order: args, category: cat.key),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class _Category {
  final String title;
  final IconData icon;
  final CategoryKey key;
  final Color color;
  _Category(this.title, this.icon, this.key, this.color);
}

class _CategoryCard extends StatelessWidget {
  final _Category cat;
  final VoidCallback onTap;
  const _CategoryCard({super.key, required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: cat.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cat.color.withOpacity(0.35)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(cat.icon, size: 48, color: cat.color),
              const SizedBox(height: 10),
              Text(cat.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cat.color.darken())),
            ],
          ),
        ),
      ),
    );
  }
}

enum CategoryKey {
  drinks,
  starters,
  salads,
  pizzas,
  spezialPizza,
  pastas,
  alForno,
  snacks,
  schnitzel,
  fish,
  desserts,
  veganPizzas,
  veganPastas,
}

/// ======================== ITEM LIST (TAP → QTY PICKER) ========================
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
    final items = _itemsForCategory(args.category);

    return Scaffold(
      appBar: AppBar(
        title: Text('${args.order.label} – ${_title(args.category)}'),
        actions: [
          IconButton(
            tooltip: 'View Order',
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
            leading: CircleAvatar(child: Text(it.short)),
            title: Text(it.name),
            subtitle: it.subtitle == null ? null : Text(it.subtitle!),
            trailing: Text('${it.price.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.w700)),
            onTap: () async {
              final qty = await pickQuantity(context, initial: 1);
              if (qty == null) return;
              store.addLine(args.order.label, OrderLine(qty: qty, name: it.displayName, price: it.price));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added: ${qty}× ${it.displayName}')));
            },
          );
        },
      ),
    );
  }

  String _title(CategoryKey k) {
    switch (k) {
      case CategoryKey.drinks: return 'Drinks';
      case CategoryKey.starters: return 'Starters';
      case CategoryKey.salads: return 'Salads';
      case CategoryKey.pizzas: return 'Pizzas';
      case CategoryKey.spezialPizza: return 'Spezial-Pizza';
      case CategoryKey.pastas: return 'Pastas';
      case CategoryKey.alForno: return 'Al Forno';
      case CategoryKey.snacks: return 'Snacks';
      case CategoryKey.schnitzel: return 'Schnitzel';
      case CategoryKey.fish: return 'Fish';
      case CategoryKey.desserts: return 'Desserts';
      case CategoryKey.veganPizzas: return 'Vegan Pizzas';
      case CategoryKey.veganPastas: return 'Vegan Pastas';
    }
  }

  List<_Item> _itemsForCategory(CategoryKey k) {
    switch (k) {
      case CategoryKey.drinks:
        return const [
          _Item('#', 'Apfelschorle 0,33 l', 'ap', 3.00),
          _Item('#', 'Kölsch 0,3 l', 'kolsch', 3.00),
          _Item('#', 'Cola 0,33 l', 'cola', 3.00),
          _Item('#', 'Fanta 0,33 l', 'fanta', 3.00),
          _Item('#', 'Coca-Cola Zero 0,33 l', 'zero', 3.00),
          _Item('#', 'Mezzo Mix 0,33 l', 'mezomix', 3.00),
          _Item('#', 'San Pellegrino 1,0 l', 'wasser', 6.50),
          _Item('#', 'Jever Fun 0,33 l (alkfrei)', 'jever', 3.50),
        ];
      case CategoryKey.starters:
        return const [
          _Item('#1', 'Bruschetta Classic', '1', 7.00),
          _Item('#1a', 'Focaccia', '1a', 5.50),
          _Item('#2', 'Caprese', '2', 10.50),
          _Item('#3', 'Carpaccio di Manzo', '3', 13.00),
          _Item('#4', 'Carpaccio di Pesce', '4', 14.50),
          _Item('#5', 'Antipasto Italiano (2P)', '5', 20.50),
          _Item('#6', 'Antipasto Vegetale', '6', 9.50),
          _Item('#7', 'Ziegenkäse überbacken', '7', 14.50),
        ];
      case CategoryKey.salads:
        return const [
          _Item('#10', 'Insalata Mista', '10', 8.00),
          _Item('#11', 'Insalata Pomodoro', '11', 6.50),
          _Item('#12', 'Insalata Rucola', '12', 9.50),
          _Item('#13', 'Insalata Contadina', '13', 11.50),
          _Item('#14', 'Insalata Pollo', '14', 11.50),
          _Item('#15', 'Insalata Salmone', '15', 13.50),
          _Item('#16', 'Insalata Capricciosa', '16', 12.50),
        ];
      case CategoryKey.pizzas:
        return const [
          _Item('#20', 'Margherita', '20', 8.50),
          _Item('#21', 'Bufalina', '21', 10.00),
          _Item('#22', 'Primavera (ohne Käse)', '22', 10.00),
          _Item('#23', 'Salami', '23', 10.00),
          _Item('#24', 'Prosciutto', '24', 10.00),
          _Item('#25', 'Funghi', '25', 10.00),
          _Item('#26', 'Pugliese', '26', 11.50),
          _Item('#27', 'Inferno', '27', 10.50),
          _Item('#28', 'Spinaci', '28', 10.50),
          _Item('#29', 'Prosciutto e Funghi', '29', 11.00),
          _Item('#30', 'Tonno', '30', 11.00),
          _Item('#31', 'Hawaii', '31', 11.50),
          _Item('#32', 'Verdura', '32', 12.50),
          _Item('#33', 'Quattro Stagioni', '33', 12.50),
          _Item('#34', 'Quattro Formaggi', '34', 12.50),
          _Item('#35', 'Carciofi', '35', 12.50),
          _Item('#36', 'Calzone', '36', 13.00),
          _Item('#37', 'Rustica', '37', 12.50),
          _Item('#38', 'Frutti di Mare', '38', 12.50),
          _Item('#39', 'Capri', '39', 11.50),
          _Item('#40', 'Melanzane', '40', 12.50),
          _Item('#41', 'Chef', '41', 13.00),
          _Item('#42', 'Salmone', '42', 14.50),
          _Item('#43', 'Parma', '43', 14.50),
          _Item('#44', 'Salvatore', '44', 14.50),
          _Item('#45', 'Pollo (o.Tom., Holl.)', '45', 14.50),
          _Item('#46', 'Amsterdam', '46', 15.50),
          _Item('#47', 'Chiara', '47', 16.50),
        ];
      case CategoryKey.spezialPizza:
        return const [
          _Item('#51', 'Asparagi', '51', 15.00),
          _Item('#52', 'Gorgonzola (ohne Tom.)', '52', 14.50),
          _Item('#53', 'Salsiccia', '53', 15.00),
          _Item('#54', 'Di Capra', '54', 15.50),
        ];
      case CategoryKey.pastas:
        return const [
          _Item('#61', 'Spaghetti Napoli', '61', 9.50),
          _Item('#62', 'Spaghetti Bolognese', '62', 12.00),
          _Item('#63', 'Spaghetti Aglio Olio e Peper.', '63', 9.50),
          _Item('#64', 'Spaghetti Carbonara', '64', 13.50),
          _Item('#65', 'Tortellini Panna e Prosciutto', '65', 12.00),
          _Item('#66', 'Penne Arrabiata', '66', 10.50),
          _Item('#67', 'Penne Amatriciana', '67', 13.00),
          _Item('#68', 'Rigatoni Gorgonzola', '68', 12.50),
          _Item('#69', 'Rigatoni Norcina', '69', 13.50),
          _Item('#70', 'Rigatoni Quattro Formaggi', '70', 12.50),
          _Item('#71', 'Tagliatelle Salmone', '71', 18.50),
          _Item('#72', 'Tagliatelle Scampi', '72', 18.50),
          _Item('#73', 'Tagliatelle di Manzo', '73', 19.50),
        ];
      case CategoryKey.alForno:
        return const [
          _Item('#100', 'Lasagne', '100', 13.00),
          _Item('#101', 'Tortellini al Forno', '101', 13.00),
          _Item('#102', 'Rigatoni al Forno', '102', 13.00),
          _Item('#103', 'Cannelloni', '103', 13.00),
          _Item('#104', 'Auflauf Spezial', '104', 13.50),
        ];
      case CategoryKey.snacks:
        return const [
          _Item('#110', 'Pommes Frites', '110', 5.00),
          _Item('#111', 'Chicken Nuggets (9)', '111', 7.50),
          _Item('#112', 'Chicken Nuggets (20)', '112', 14.00),
        ];
      case CategoryKey.schnitzel:
        return const [
          _Item('#113', 'Schnitzel Wiener Art', '113', 12.50),
          _Item('#114', 'Paprikaschnitzel', '114', 14.50),
          _Item('#115', 'Jägerschnitzel', '115', 14.50),
          _Item('#116', 'Schnitzel Funghi', '116', 14.50),
          _Item('#117', 'Schnitzel Hollandaise', '117', 14.50),
          _Item('#118', 'Zwiebelschnitzel', '118', 14.50),
        ];
      case CategoryKey.fish:
        return const [
          _Item('#120', 'Salmone Griglia', '120', 20.50),
          _Item('#121', 'Salmone Basilico', '121', 21.50),
        ];
      case CategoryKey.desserts:
        return const [
          _Item('#140', 'Tiramisu (hausgemacht)', '140', 7.00),
          _Item('#141', 'Tartufo Eis', '141', 6.00),
          _Item('#142', 'Cassata', '142', 6.00),
          _Item('#143', 'Schoko Soufflé', '143', 6.00),
        ];
      case CategoryKey.veganPizzas:
        return const [
          // Add mirrored vegan pizzas later
        ];
      case CategoryKey.veganPastas:
        return const [
          // Add mirrored vegan pastas later
        ];
    }
  }
}

class _Item {
  final String short;       // leading chip
  final String name;        // UI name
  final String code;        // code used in catalog/parser
  final double price;
  final String? subtitle;

  const _Item(this.short, this.name, this.code, this.price, [this.subtitle]);

  String get displayName => name;
}

/// ======================== ORDER SCREEN ========================
class OrderScreen extends StatefulWidget {
  static const route = '/order';
  final OrderArgs args;
  const OrderScreen({super.key, required this.args});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final TextEditingController _input = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final store = OrderProvider.of(context);
    final order = store.orderFor(widget.args.label);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.args.label} – Order'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, CategoryScreen.route, arguments: widget.args),
            icon: const Icon(Icons.grid_view),
            label: const Text('Categories'),
          ),
          const SizedBox(width: 6),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${store.totalFor(widget.args.label).toStringAsFixed(2)} €',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick-input parser (optional)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _input,
              decoration: InputDecoration(
                hintText: 'Type: 2x31 + ap + wasser',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addLine(store),
                  tooltip: 'Add line',
                ),
              ),
              onSubmitted: (_) => _addLine(store),
            ),
          ),
          Expanded(
            child: order.lines.isEmpty
                ? const Center(child: Text('No items yet.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: order.lines.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final l = order.lines[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${l.qty}x')),
                        title: Text(l.name),
                        trailing: Text((l.qty * l.price).toStringAsFixed(2) + ' €'),
                        subtitle: l.note == null ? null : Text(l.note!),
                        onLongPress: () => store.removeLine(widget.args.label, i),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Total'),
                      onPressed: () => _showTotal(store),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Bill'),
                      onPressed: () => _billAndClear(store), // shows items + total; option to clear
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addLine(OrderStore store) {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final parsed = parseInputToLines(text);
    if (parsed.isEmpty) {
      _snack('Could not parse. Add more items to catalog or change input.');
      return;
    }
    for (final l in parsed) {
      store.addLine(widget.args.label, l);
    }
    _input.clear();
  }

  void _showTotal(OrderStore store) {
    final total = store.totalFor(widget.args.label).toStringAsFixed(2);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Current total'),
        content: Text('$total €'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  /// UPDATED BILL: shows all items and total; Clear & Close optionally clears the table
  void _billAndClear(OrderStore store) {
    final order = store.orderFor(widget.args.label);
    final total = store.totalFor(widget.args.label);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('${widget.args.label} – Bill'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.lines.isEmpty)
                  const Text('No items on this table.')
                else
                  ...order.lines.map((l) {
                    final lineTotal = (l.qty * l.price).toStringAsFixed(2);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('${l.qty}× ${l.name}  —  €$lineTotal'),
                    );
                  }),
                const Divider(height: 20),
                Text(
                  'Total: ${total.toStringAsFixed(2)} €',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                store.clear(widget.args.label); // clear after billing
                Navigator.pop(context); // back to categories
              },
              child: const Text('Clear & Close'),
            ),
          ],
        );
      },
    );
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

/// ======================== STATE (ORDERS) ========================
class OrderProvider extends InheritedNotifier<OrderStore> {
  OrderProvider({super.key, required Widget child}) : super(notifier: OrderStore(), child: child);
  static OrderStore of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<OrderProvider>()!.notifier!;
}

class OrderStore extends ChangeNotifier {
  final Map<String, OrderData> _orders = {}; // T1, AP1, D1...

  OrderData orderFor(String label) => _orders.putIfAbsent(label, () => OrderData(label: label));

  void addLine(String label, OrderLine line) {
    orderFor(label).lines.add(line);
    notifyListeners();
  }

  void removeLine(String label, int index) {
    final o = orderFor(label);
    if (index >= 0 && index < o.lines.length) {
      o.lines.removeAt(index);
      notifyListeners();
    }
  }

  double totalFor(String label) {
    final o = _orders[label];
    if (o == null) return 0.0;
    return o.lines.fold(0.0, (sum, l) => sum + l.qty * l.price);
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
  final String? note;
  OrderLine({required this.qty, required this.name, required this.price, this.note});
}

/// ======================== QUANTITY PICKER ========================
Future<int?> pickQuantity(BuildContext context, {int initial = 1, int min = 1, int max = 20}) async {
  int qty = initial.clamp(min, max);
  return showDialog<int>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Quantity'),
      content: StatefulBuilder(
        builder: (ctx, setState) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => setState(() => qty = (qty - 1).clamp(min, max)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$qty', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => qty = (qty + 1).clamp(min, max)),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, qty), child: const Text('Add')),
      ],
    ),
  );
}

/// ======================== PARSER + CATALOG ========================
/// Final locked PRICES (numbers → €)
final Map<String, double> catalog = {
  // Drinks
  'ap': 3.00, 'kolsch': 3.00, 'cola': 3.00, 'fanta': 3.00, 'zero': 3.00,
  'mezomix': 3.00, 'wasser': 6.50, 'jever': 3.50,

  // Starters #1–7
  '1': 7.00, '1a': 5.50, '2': 10.50, '3': 13.00, '4': 14.50, '5': 20.50, '6': 9.50, '7': 14.50,

  // Salads #10–16
  '10': 8.00, '11': 6.50, '12': 9.50, '13': 11.50, '14': 11.50, '15': 13.50, '16': 12.50,

  // Pizzas #20–47
  '20': 8.50, '21': 10.00, '22': 10.00, '23': 10.00, '24': 10.00, '25': 10.00,
  '26': 11.50, '27': 10.50, '28': 10.50, '29': 11.00, '30': 11.00, '31': 11.50,
  '32': 12.50, '33': 12.50, '34': 12.50, '35': 12.50, '36': 13.00, '37': 12.50,
  '38': 12.50, '39': 11.50, '40': 12.50, '41': 13.00, '42': 14.50, '43': 14.50,
  '44': 14.50, '45': 14.50, '46': 15.50, '47': 16.50,

  // Spezial-Pizza #51–54
  '51': 15.00, '52': 14.50, '53': 15.00, '54': 15.50,

  // Pastas #61–73
  '61': 9.50, '62': 12.00, '63': 9.50, '64': 13.50, '65': 12.00, '66': 10.50,
  '67': 13.00, '68': 12.50, '69': 13.50, '70': 12.50, '71': 18.50, '72': 18.50, '73': 19.50,

  // Al Forno #100–#104
  '100': 13.00, '101': 13.00, '102': 13.00, '103': 13.00, '104': 13.50,

  // Snacks #110–#112
  '110': 5.00, '111': 7.50, '112': 14.00,

  // Schnitzel #113–#118
  '113': 12.50, '114': 14.50, '115': 14.50, '116': 14.50, '117': 14.50, '118': 14.50,

  // Fish #120–#121
  '120': 20.50, '121': 21.50,

  // Desserts #140–#143
  '140': 7.00, '141': 6.00, '142': 6.00, '143': 6.00,
};

/// Display names / aliases (used for parser + UI prettiness)
final Map<String, String> nameMap = {
  // Drinks aliases
  'ap': 'Apfelschorle 0,33 l',
  'kolsch': 'Kölsch 0,3 l',
  'cola': 'Cola 0,33 l',
  'fanta': 'Fanta 0,33 l',
  'zero': 'Coca-Cola Zero 0,33 l',
  'mezomix': 'Mezzo Mix 0,33 l',
  'wasser': 'San Pellegrino 1,0 l',
  'jever': 'Jever Fun 0,33 l',

  // Starters
  '1': 'Bruschetta Classic (#1)', '1a': 'Focaccia (#1a)', '2': 'Caprese (#2)',
  '3': 'Carpaccio di Manzo (#3)', '4': 'Carpaccio di Pesce (#4)',
  '5': 'Antipasto Italiano (#5)', '6': 'Antipasto Vegetale (#6)', '7': 'Ziegenkäse überbacken (#7)',

  // Salads
  '10': 'Insalata Mista (#10)', '11': 'Insalata Pomodoro (#11)', '12': 'Insalata Rucola (#12)',
  '13': 'Insalata Contadina (#13)', '14': 'Insalata Pollo (#14)', '15': 'Insalata Salmone (#15)', '16': 'Insalata Capricciosa (#16)',

  // Pizzas
  '20': 'Pizza Margherita (#20)', '21': 'Pizza Bufalina (#21)', '22': 'Pizza Primavera (#22)',
  '23': 'Pizza Salami (#23)', '24': 'Pizza Prosciutto (#24)', '25': 'Pizza Funghi (#25)',
  '26': 'Pizza Pugliese (#26)', '27': 'Pizza Inferno (#27)', '28': 'Pizza Spinaci (#28)',
  '29': 'Pizza Prosciutto e Funghi (#29)', '30': 'Pizza Tonno (#30)', '31': 'Pizza Hawaii (#31)',
  '32': 'Pizza Verdura (#32)', '33': 'Pizza Quattro Stagioni (#33)', '34': 'Pizza Quattro Formaggi (#34)',
  '35': 'Pizza Carciofi (#35)', '36': 'Pizza Calzone (#36)', '37': 'Pizza Rustica (#37)',
  '38': 'Pizza Frutti di Mare (#38)', '39': 'Pizza Capri (#39)', '40': 'Pizza Melanzane (#40)',
  '41': 'Pizza Chef (#41)', '42': 'Pizza Salmone (#42)', '43': 'Pizza Parma (#43)',
  '44': 'Pizza Salvatore (#44)', '45': 'Pizza Pollo (#45)', '46': 'Pizza Amsterdam (#46)', '47': 'Pizza Chiara (#47)',

  // Spezial-Pizza
  '51': 'Pizza Asparagi (#51)', '52': 'Pizza Gorgonzola (#52)', '53': 'Pizza Salsiccia (#53)', '54': 'Pizza Di Capra (#54)',

  // Pastas
  '61': 'Spaghetti Napoli (#61)', '62': 'Spaghetti Bolognese (#62)', '63': 'Spaghetti Aglio Olio e Peperoncino (#63)',
  '64': 'Spaghetti Carbonara (#64)', '65': 'Tortellini Panna e Prosciutto (#65)', '66': 'Penne Arrabiata (#66)',
  '67': 'Penne Amatriciana (#67)', '68': 'Rigatoni Gorgonzola (#68)', '69': 'Rigatoni Norcina (#69)',
  '70': 'Rigatoni Quattro Formaggi (#70)', '71': 'Tagliatelle Salmone (#71)', '72': 'Tagliatelle Scampi (#72)', '73': 'Tagliatelle di Manzo (#73)',

  // Al Forno
  '100': 'Lasagne (#100)', '101': 'Tortellini al Forno (#101)', '102': 'Rigatoni al Forno (#102)',
  '103': 'Cannelloni (#103)', '104': 'Auflauf Spezial (#104)',

  // Snacks
  '110': 'Pommes Frites (#110)', '111': 'Chicken Nuggets (9) (#111)', '112': 'Chicken Nuggets (20) (#112)',

  // Schnitzel
  '113': 'Schnitzel Wiener Art (#113)', '114': 'Paprikaschnitzel (#114)', '115': 'Jägerschnitzel (#115)',
  '116': 'Schnitzel Funghi (#116)', '117': 'Schnitzel Hollandaise (#117)', '118': 'Zwiebelschnitzel (#118)',

  // Fish
  '120': 'Salmone Griglia (#120)', '121': 'Salmone Basilico (#121)',

  // Desserts
  '140': 'Tiramisu (#140)', '141': 'Tartufo Eis (#141)', '142': 'Cassata (#142)', '143': 'Schoko Soufflé (#143)',
};

/// Quick aliases & special rules parser for the input box
List<OrderLine> parseInputToLines(String input) {
  var s = input.toLowerCase().replaceAll(',', ' ').replaceAll('+', ' ');
  s = s.replaceAll('x ', 'x'); // normalize "2x 34" -> "2x34"
  final parts = s.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();

  final List<OrderLine> lines = [];
  for (final token in parts) {
    // e.g., "2x34" or "3xap"
    final m = RegExp(r'^(\d+)x([a-z0-9]+)$').firstMatch(token);
    if (m != null) {
      final qty = int.parse(m.group(1)!);
      final code = _normalizeCode(m.group(2)!);
      final line = _codeToLine(code, qty);
      if (line != null) lines.add(line);
      continue;
    }

    // Special: "salami+paprika" or "23+paprika" ⇒ Salami base +1.00 = 11.00
    if (token.contains('+paprika')) {
      if (token.startsWith('23') || token.startsWith('salami')) {
        lines.add(OrderLine(qty: 1, name: 'Pizza Salami + Paprika (#23 + extra)', price: 11.00));
      }
      continue;
    }

    // Single token like "34" or "ap"
    final code = _normalizeCode(token);
    final line = _codeToLine(code, 1);
    if (line != null) lines.add(line);
  }
  return lines;
}

String _normalizeCode(String raw) {
  final alias = {
    'apfelschorle': 'ap',
    'jeverfun': 'jever',
    'qf': '34', // Quattro Formaggi
    'qs': '33', // Quattro Stagioni
  };
  return alias[raw] ?? raw;
}

OrderLine? _codeToLine(String code, int qty) {
  final price = catalog[code];
  if (price == null) return null;
  final name = nameMap[code] ?? code;
  return OrderLine(qty: qty, name: name, price: price);
}

/// ----------------------- COLOR HELPER -----------------------
extension on Color {
  Color darken([double amount = .22]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
