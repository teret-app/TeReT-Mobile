import 'package:flutter/material.dart';

class CarrierSetupScreen extends StatefulWidget {
  const CarrierSetupScreen({super.key});

  @override
  State<CarrierSetupScreen> createState() => _CarrierSetupScreenState();
}

class _CarrierSetupScreenState extends State<CarrierSetupScreen> {
  // Dummy loads (kasnije ide iz backenda)
  final List<_Load> _loads = const [
    _Load(
      id: 'L1',
      pickup: 'Osijek',
      dropoff: 'Zagreb',
      weightKg: 850,
      description: 'Palete, suha roba',
    ),
    _Load(
      id: 'L2',
      pickup: 'Split',
      dropoff: 'Rijeka',
      weightKg: 320,
      description: 'Bijela tehnika (pažljivo)',
    ),
    _Load(
      id: 'L3',
      pickup: 'Požega',
      dropoff: 'Pula',
      weightKg: 1200,
      description: 'Građevinski materijal',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prijevoznik')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _loads.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final l = _loads[i];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final result = await Navigator.push<double>(
                context,
                MaterialPageRoute(
                  builder: (_) => _LoadDetailBidScreen(load: l),
                ),
              );

              if (!mounted || result == null) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ponuda poslana: €${result.toStringAsFixed(2)}')),
              );
            },
            child: Ink(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l.pickup} → ${l.dropoff}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text('${l.weightKg} kg • ${l.description}',
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('Otvori i daj ponudu'),
                      Spacer(),
                      Icon(Icons.chevron_right),
                    ],
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

class _LoadDetailBidScreen extends StatefulWidget {
  final _Load load;
  const _LoadDetailBidScreen({required this.load});

  @override
  State<_LoadDetailBidScreen> createState() => _LoadDetailBidScreenState();
}

class _LoadDetailBidScreenState extends State<_LoadDetailBidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sending = true);
    try {
      // TODO: ovdje ide backend poziv: POST /loads/{id}/bids
      final price = double.parse(_priceController.text.replaceAll(',', '.'));

      if (!mounted) return;
      Navigator.pop<double>(context, price);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.load;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalji tereta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              '${l.pickup} → ${l.dropoff}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('${l.weightKg} kg', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Text(l.description),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            const Text(
              'Unesi svoju ponudu (€)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Form(
              key: _formKey,
              child: TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Ponuda (€)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final s = (v ?? '').trim().replaceAll(',', '.');
                  final p = double.tryParse(s);
                  if (p == null || p <= 0) return 'Unesi ispravnu cijenu';
                  return null;
                },
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _sending ? null : _submitBid,
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Pošalji ponudu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Load {
  final String id;
  final String pickup;
  final String dropoff;
  final int weightKg;
  final String description;

  const _Load({
    required this.id,
    required this.pickup,
    required this.dropoff,
    required this.weightKg,
    required this.description,
  });
}