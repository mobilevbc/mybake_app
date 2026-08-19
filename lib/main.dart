import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const MyBakeApp());
}

class MyBakeApp extends StatelessWidget {
  const MyBakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Bake Order Request',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        useMaterial3: true,
      ),
      home: const OrderHomePage(),
    );
  }
}

class OrderHomePage extends StatefulWidget {
  const OrderHomePage({super.key});

  @override
  State<OrderHomePage> createState() => _OrderHomePageState();
}

class _OrderHomePageState extends State<OrderHomePage> {
  final Map<String, List<int>> productsData = {
    "mango": [75, 100],
    "caramel": [75, 100],
    "cappuccino": [75, 100],
    "lotus": [75, 100],
    "half fruits chocolate": [75, 100],
    "chocolate": [75, 100],
    "strawberry": [75, 100],
    "snickers": [75, 100],
    "b.minicake3": [55],
    "b.minicake2": [55],
    "bassboossa mix": [35, 65],
    "kistha": [35],
    "Thamar": [35],
    "cutting": [35],
    "kamfaroosh": [35, 65],
    "donuts": [25],
    "d.caramel": [35],
    "cake joss": [35],
    "cake joss mix": [35, 65],
    "mango s": [45],
    "nice cake": [35],
    "snickers s": [45],
    "brownies": [45],
    "mini mix": [45],
    "galaxy": [45],
    "kaliya": [20, 30, 40, 50],
    "fathayer mini": [35, 50],
    "sandwiches": [35, 50],
    "pizza mini round": [35],
    "pizza soudi": [35],
    "zater": [25],
    "mix": [100],
    "annan mix": [100],
    "paper sandwich": [35, 50],
    "organab": [35],
    "chees roll": [35],
    "morning fathayer": [30, 40],
  };

  String? selectedProduct;
  Map<int, TextEditingController> qtyControllers = {};
  Map<String, Map<int, int>> orderSummary = {};
  late String nextDayDate;

  @override
  void initState() {
    super.initState();
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    nextDayDate = "${tomorrow.day.toString().padLeft(2, '0')}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.year}";
  }

  void _onProductSelected(String? product) {
    if (product == null) return;
    setState(() {
      selectedProduct = product;
      qtyControllers.clear();
      for (var price in productsData[product]!) {
        qtyControllers[price] = TextEditingController();
      }
    });
  }

  void _addToOrder() {
    if (selectedProduct == null) return;

    Map<int, int> currentQtyMap = {};
    qtyControllers.forEach((price, controller) {
      int qty = int.tryParse(controller.text) ?? 0;
      if (qty > 0) {
        currentQtyMap[price] = qty;
      }
    });

    if (currentQtyMap.isNotEmpty) {
      setState(() {
        orderSummary[selectedProduct!] = currentQtyMap;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$selectedProduct ഓർഡറിലേക്ക് ചേർത്തു!"), duration: const Duration(seconds: 1)),
      );
    }
  }

  // കോളം വിഡ്ത്ത് ഐറ്റത്തിന് തൊട്ടടുത്ത് വരുന്ന രീതിയിൽ മാറ്റിയ A5 PDF ഫംഗ്ഷൻ
  Future<void> _printA5Document() async {
    final pdf = pw.Document();

    final List<List<String>> tableData = [];
    int slNo = 1;

    orderSummary.forEach((item, priceQtyMap) {
      String priceQtyString = priceQtyMap.entries
          .map((e) => "${e.key}*${e.value}")
          .join(", ");

      tableData.add([
        slNo.toString(),
        item,
        priceQtyString,
      ]);
      slNo++;
    });

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('MY BAKE ORDER REQUEST', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text('Date: $nextDayDate', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800)),
              ),
              pw.SizedBox(height: 10),
              
              // ടേബിൾ പരമാവധി ഇടത്തേക്ക് അടുത്തുനിൽക്കുന്ന സ്ട്രക്ചർ
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                headers: ['S.No', 'Item Name', 'Price * Qty'],
                data: tableData,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                headerAlignment: pw.Alignment.centerLeft,
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),  // Sl No (ചെറിയ വിഡ്ത്ത്)
                  1: const pw.FlexColumnWidth(1.8),  // Item Name (പരമാവധി ആവശ്യമുള്ള വിഡ്ത്ത് മാത്രം)
                  2: const pw.FlexColumnWidth(2.2),  // Price * Qty (ഐറ്റത്തിന് തൊട്ടടുത്ത് വരും)
                },
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'MyBake_Order_$nextDayDate.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/icon.png', width: 35, height: 35, errorBuilder: (c, o, s) => const Icon(Icons.shopping_bag)),
              const SizedBox(width: 8),
              const Text("My Bake Order", style: TextStyle(fontSize: 18)),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(
                child: Text("Date: $nextDayDate", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add_shopping_cart), text: "Select Item"),
              Tab(icon: Icon(Icons.receipt_long), text: "Order List"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Product", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedProduct,
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), hintText: "Choose Product"),
                    items: productsData.keys.map((String key) {
                      return DropdownMenuItem<String>(value: key, child: Text(key));
                    }).toList(),
                    onChanged: _onProductSelected,
                  ),
                  const SizedBox(height: 15),
                  if (selectedProduct != null) ...[
                    Text("Enter Quantity for $selectedProduct:", style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        children: productsData[selectedProduct]!.map((price) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Price: ₹$price", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  SizedBox(
                                    width: 90,
                                    child: TextField(
                                      controller: qtyControllers[price],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, hintText: "Qty"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addToOrder,
                      icon: const Icon(Icons.add),
                      label: const Text("Add To Order List"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700], foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
                    )
                  ] else
                    const Expanded(child: Center(child: Text("പ്രോഡക്റ്റ് സെലക്ട് ചെയ്യുക"))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Items: ${orderSummary.length}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep, color: Colors.red),
                        onPressed: () => setState(() => orderSummary.clear()),
                        tooltip: "Clear All",
                      )
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: orderSummary.isEmpty
                        ? const Center(child: Text("ഓർഡർ ലിസ്റ്റ് ശൂന്യമാണ്"))
                        : ListView.builder(
                            itemCount: orderSummary.length,
                            itemBuilder: (context, index) {
                              String key = orderSummary.keys.elementAt(index);
                              Map<int, int> prices = orderSummary[key]!;
                              String formattedDetails = prices.entries.map((e) => "${e.key}*${e.value}").join(", ");

                              return Card(
                                child: ListTile(
                                  title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(formattedDetails, style: const TextStyle(fontSize: 14, color: Colors.indigo, fontWeight: FontWeight.bold)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                    onPressed: () => setState(() => orderSummary.remove(key)),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: orderSummary.isEmpty ? null : _printA5Document,
                    icon: const Icon(Icons.print),
                    label: const Text("Print / Save as A5 PDF"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
