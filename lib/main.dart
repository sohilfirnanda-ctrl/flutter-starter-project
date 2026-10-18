import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String api = 'http://localhost:8000/api';
const Color biru = Color(0xFF174A8B);

void main() {
  runApp(const BengkelApp());
}

class BengkelApp extends StatelessWidget {
  const BengkelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bengkel Motor',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: biru),
        scaffoldBackgroundColor: const Color(0xFFF3F6FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: biru,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const HalamanUtama(),
    );
  }
}

Future<List<dynamic>> ambil(String endpoint) async {
  final r = await http.get(Uri.parse('$api$endpoint'));
  if (r.statusCode != 200) {
    throw Exception('Gagal mengambil data: ${r.body}');
  }
  final hasil = jsonDecode(r.body);
  return List<dynamic>.from(hasil['data'] ?? []);
}

Future<Map<String, dynamic>> kirim(
  String endpoint,
  String metode,
  Map<String, dynamic> data,
) async {
  final uri = Uri.parse('$api$endpoint');
  final headers = {'Content-Type': 'application/json'};
  late http.Response r;

  if (metode == 'POST') {
    r = await http.post(uri, headers: headers, body: jsonEncode(data));
  } else if (metode == 'PUT') {
    r = await http.put(uri, headers: headers, body: jsonEncode(data));
  } else {
    r = await http.delete(uri, headers: headers);
  }

  final body = jsonDecode(r.body);
  if (r.statusCode < 200 || r.statusCode >= 300) {
    final errors = body['errors'];
    if (errors is Map) {
      throw Exception(errors.values.expand((e) => e as List).join('\n'));
    }
    throw Exception(body['message'] ?? body['pesan'] ?? 'Permintaan gagal');
  }
  return Map<String, dynamic>.from(body);
}

String rupiah(dynamic nilai) {
  final angka = double.tryParse('$nilai') ?? 0;
  return 'Rp ${angka.toStringAsFixed(0)}';
}

void info(BuildContext context, String pesan) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(pesan)),
  );
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int halaman = 0;

  final judul = [
    'Dashboard Bengkel',
    'Data Pelanggan',
    'Data Kendaraan',
    'Riwayat Servis',
  ];

  @override
  Widget build(BuildContext context) {
    final halamanWidget = [
      const Dashboard(),
      const PelangganPage(),
      const KendaraanPage(),
      const ServisPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.two_wheeler, size: 28),
            const SizedBox(width: 10),
            Text(judul[halaman]),
          ],
        ),
      ),
      body: SafeArea(child: halamanWidget[halaman]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: halaman,
        onDestinationSelected: (i) => setState(() => halaman = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Pelanggan',
          ),
          NavigationDestination(
            icon: Icon(Icons.motorcycle_outlined),
            selectedIcon: Icon(Icons.motorcycle),
            label: 'Motor',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.build),
            label: 'Servis',
          ),
        ],
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<List<dynamic>> pelanggan;
  late Future<List<dynamic>> motor;
  late Future<List<dynamic>> servis;

  void muat() {
    pelanggan = ambil('/pelanggan');
    motor = ambil('/kendaraan');
    servis = ambil('/riwayat-servis');
  }

  @override
  void initState() {
    super.initState();
    muat();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(muat),
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [biru, Color(0xFF2877BC)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.two_wheeler, color: Colors.white, size: 42),
                SizedBox(height: 14),
                Text(
                  'Selamat Datang!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Kelola pelanggan, kendaraan, dan riwayat servis '
                  'bengkel dalam satu aplikasi.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ringkasan Bengkel',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<dynamic>>(
            future: pelanggan,
            builder: (context, s) => KartuRingkasan(
              judul: 'Total Pelanggan',
              jumlah: s.hasData ? '${s.data!.length}' : '—',
              ikon: Icons.people,
              warna: const Color(0xFF174A8B),
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: motor,
            builder: (context, s) => KartuRingkasan(
              judul: 'Total Kendaraan',
              jumlah: s.hasData ? '${s.data!.length}' : '—',
              ikon: Icons.motorcycle,
              warna: const Color(0xFF16836B),
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: servis,
            builder: (context, s) => KartuRingkasan(
              judul: 'Total Catatan Servis',
              jumlah: s.hasData ? '${s.data!.length}' : '—',
              ikon: Icons.build_circle_outlined,
              warna: const Color(0xFFB76B16),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cara Menggunakan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '1. Tambahkan pelanggan terlebih dahulu.\n'
                '2. Daftarkan motor dan nomor polisinya.\n'
                '3. Catat setiap servis yang dikerjakan.\n'
                '4. Cari riwayat lama melalui menu Servis.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KartuRingkasan extends StatelessWidget {
  final String judul;
  final String jumlah;
  final IconData ikon;
  final Color warna;

  const KartuRingkasan({
    super.key,
    required this.judul,
    required this.jumlah,
    required this.ikon,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: warna.withValues(alpha: 0.12),
          foregroundColor: warna,
          child: Icon(ikon),
        ),
        title: Text(judul),
        trailing: Text(
          jumlah,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: warna,
          ),
        ),
      ),
    );
  }
}

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  late Future<List<dynamic>> data;

  void muat() => data = ambil('/pelanggan');

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<void> tambah() async {
    final nama = TextEditingController();
    final hp = TextEditingController();

    final hasil = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Pelanggan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nama,
              decoration: const InputDecoration(
                labelText: 'Nama pelanggan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hp,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor HP',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (hasil != true) {
      nama.dispose();
      hp.dispose();
      return;
    }

    try {
      await kirim('/pelanggan', 'POST', {
        'nama': nama.text.trim(),
        'no_hp': hp.text.trim().isEmpty ? null : hp.text.trim(),
      });
      if (!mounted) return;
      info(context, 'Pelanggan berhasil ditambahkan.');
      setState(muat);
    } catch (e) {
      if (mounted) info(context, 'Gagal: $e');
    } finally {
      nama.dispose();
      hp.dispose();
    }
  }

  Future<void> hapus(dynamic item) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus pelanggan?'),
        content: Text('Hapus data ${item['nama']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    try {
      await kirim('/pelanggan/${item['id']}', 'DELETE', {});
      if (mounted) {
        info(context, 'Pelanggan dihapus.');
        setState(muat);
      }
    } catch (e) {
      if (mounted) info(context, 'Gagal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: tambah,
              icon: const Icon(Icons.person_add),
              label: const Text('Tambah Pelanggan'),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: data,
            builder: (context, s) {
              if (s.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (s.hasError) {
                return PesanError(
                  pesan: '${s.error}',
                  ulang: () => setState(muat),
                );
              }
              final daftar = s.data ?? [];
              if (daftar.isEmpty) {
                return const Kosong(pesan: 'Belum ada pelanggan.');
              }
              return RefreshIndicator(
                onRefresh: () async => setState(muat),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: daftar.length,
                  itemBuilder: (context, i) {
                    final p = daftar[i];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text('${p['nama']}'),
                        subtitle: Text('HP: ${p['no_hp'] ?? '-'}'),
                        trailing: IconButton(
                          tooltip: 'Hapus',
                          onPressed: () => hapus(p),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class KendaraanPage extends StatefulWidget {
  const KendaraanPage({super.key});

  @override
  State<KendaraanPage> createState() => _KendaraanPageState();
}

class _KendaraanPageState extends State<KendaraanPage> {
  late Future<List<dynamic>> data;

  void muat() => data = ambil('/kendaraan');

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<void> tambah() async {
    List<dynamic> pelanggan;
    try {
      pelanggan = await ambil('/pelanggan');
    } catch (e) {
      if (mounted) info(context, 'Gagal mengambil pelanggan: $e');
      return;
    }

    if (!mounted) return;
    if (pelanggan.isEmpty) {
      info(context, 'Tambahkan pelanggan terlebih dahulu.');
      return;
    }

    final polisi = TextEditingController();
    final merek = TextEditingController();
    final tipe = TextEditingController();
    dynamic pelangganId = pelanggan.first['id'];

    final hasil = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ubah) => AlertDialog(
          title: const Text('Daftarkan Motor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<dynamic>(
                  value: pelangganId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Pemilik motor',
                    border: OutlineInputBorder(),
                  ),
                  items: pelanggan.map((p) {
                    return DropdownMenuItem<dynamic>(
                      value: p['id'],
                      child: Text('${p['nama']}'),
                    );
                  }).toList(),
                  onChanged: (v) => ubah(() => pelangganId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: polisi,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Nomor polisi',
                    hintText: 'BL 1234 XX',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: merek,
                  decoration: const InputDecoration(
                    labelText: 'Merek motor',
                    hintText: 'Honda, Yamaha, Suzuki',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tipe,
                  decoration: const InputDecoration(
                    labelText: 'Tipe motor',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (hasil != true) {
      polisi.dispose();
      merek.dispose();
      tipe.dispose();
      return;
    }

    try {
      await kirim('/kendaraan', 'POST', {
        'pelanggan_id': pelangganId,
        'nomor_polisi': polisi.text.trim().toUpperCase(),
        'merek': merek.text.trim(),
        'tipe': tipe.text.trim().isEmpty ? null : tipe.text.trim(),
      });
      if (mounted) {
        info(context, 'Kendaraan berhasil didaftarkan.');
        setState(muat);
      }
    } catch (e) {
      if (mounted) info(context, 'Gagal: $e');
    } finally {
      polisi.dispose();
      merek.dispose();
      tipe.dispose();
    }
  }

  Future<void> hapus(dynamic item) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus kendaraan?'),
        content: Text('Hapus motor ${item['nomor_polisi']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    try {
      await kirim('/kendaraan/${item['id']}', 'DELETE', {});
      if (mounted) {
        info(context, 'Kendaraan dihapus.');
        setState(muat);
      }
    } catch (e) {
      if (mounted) info(context, 'Gagal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: tambah,
              icon: const Icon(Icons.add),
              label: const Text('Daftarkan Motor'),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: data,
            builder: (context, s) {
              if (s.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (s.hasError) {
                return PesanError(
                  pesan: '${s.error}',
                  ulang: () => setState(muat),
                );
              }
              final daftar = s.data ?? [];
              if (daftar.isEmpty) {
                return const Kosong(pesan: 'Belum ada kendaraan.');
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: daftar.length,
                itemBuilder: (context, i) {
                  final m = daftar[i];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.motorcycle),
                      ),
                      title: Text('${m['nomor_polisi']}'),
                      subtitle: Text(
                        '${m['merek']} ${m['tipe'] ?? ''}\n'
                        'Pemilik: ${m['nama_pelanggan'] ?? '-'}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: 'Hapus',
                        onPressed: () => hapus(m),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ServisPage extends StatefulWidget {
  const ServisPage({super.key});

  @override
  State<ServisPage> createState() => _ServisPageState();
}

class _ServisPageState extends State<ServisPage> {
  late Future<List<dynamic>> data;
  final cari = TextEditingController();
  List<dynamic>? hasilCari;
  bool mencari = false;

  void muat() => data = ambil('/riwayat-servis');

  @override
  void initState() {
    super.initState();
    muat();
  }

  @override
  void dispose() {
    cari.dispose();
    super.dispose();
  }

  Future<void> cariRiwayat() async {
    final polisi = cari.text.trim().toUpperCase();
    if (polisi.isEmpty) {
      info(context, 'Masukkan nomor polisi.');
      return;
    }
    setState(() {
      mencari = true;
      hasilCari = null;
    });
    try {
      final daftar = await ambil(
        '/riwayat-servis/cari/${Uri.encodeComponent(polisi)}',
      );
      if (mounted) setState(() => hasilCari = daftar);
    } catch (e) {
      if (mounted) info(context, 'Pencarian gagal: $e');
    } finally {
      if (mounted) setState(() => mencari = false);
    }
  }

  Future<void> tambah() async {
    List<dynamic> motor;
    try {
      motor = await ambil('/kendaraan');
    } catch (e) {
      if (mounted) info(context, 'Gagal mengambil kendaraan: $e');
      return;
    }

    if (!mounted) return;
    if (motor.isEmpty) {
      info(context, 'Daftarkan kendaraan terlebih dahulu.');
      return;
    }

    dynamic kendaraanId = motor.first['id'];
    final tanggal = TextEditingController(
      text: DateTime.now().toIso8601String().substring(0, 10),
    );
    final keluhan = TextEditingController();
    final tindakan = TextEditingController();
    final kilometer = TextEditingController();
    final biaya = TextEditingController(text: '0');
    String status = 'Menunggu';

    final hasil = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ubah) => AlertDialog(
          title: const Text('Catat Servis'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<dynamic>(
                    value: kendaraanId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Nomor polisi / motor',
                      border: OutlineInputBorder(),
                    ),
                    items: motor.map((m) {
                      return DropdownMenuItem<dynamic>(
                        value: m['id'],
                        child: Text(
                          '${m['nomor_polisi']} - ${m['merek']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => ubah(() => kendaraanId = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tanggal,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal (YYYY-MM-DD)',
                      hintText: '2026-10-18',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: keluhan,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Keluhan pelanggan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tindakan,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Tindakan / perbaikan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: kilometer,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Kilometer motor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: biaya,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Biaya servis (Rp)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(
                      labelText: 'Status servis',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Menunggu',
                        child: Text('Menunggu'),
                      ),
                      DropdownMenuItem(
                        value: 'Dikerjakan',
                        child: Text('Dikerjakan'),
                      ),
                      DropdownMenuItem(
                        value: 'Selesai',
                        child: Text('Selesai'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) ubah(() => status = v);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Simpan Servis'),
            ),
          ],
        ),
      ),
    );

    if (hasil != true) {
      tanggal.dispose();
      keluhan.dispose();
      tindakan.dispose();
      kilometer.dispose();
      biaya.dispose();
      return;
    }

    try {
      await kirim('/riwayat-servis', 'POST', {
        'kendaraan_id': kendaraanId,
        'tanggal_servis': tanggal.text.trim(),
        'keluhan': keluhan.text.trim(),
        'tindakan': tindakan.text.trim().isEmpty
            ? null
            : tindakan.text.trim(),
        'kilometer': kilometer.text.trim().isEmpty
            ? null
            : int.tryParse(kilometer.text.trim()),
        'biaya': double.tryParse(biaya.text.trim()) ?? 0,
        'status': status,
      });
      if (mounted) {
        info(context, 'Riwayat servis berhasil disimpan.');
        setState(() {
          hasilCari = null;
          muat();
        });
      }
    } catch (e) {
      if (mounted) info(context, 'Gagal: $e');
    } finally {
      tanggal.dispose();
      keluhan.dispose();
      tindakan.dispose();
      kilometer.dispose();
      biaya.dispose();
    }
  }

  Widget kartuServis(dynamic s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.motorcycle, color: biru),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${s['nomor_polisi'] ?? 'Motor ID ${s['kendaraan_id']}'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(label: Text('${s['status']}')),
              ],
            ),
            Text('Pemilik: ${s['nama_pelanggan'] ?? '-'}'),
            Text('Motor: ${s['merek'] ?? '-'} ${s['tipe'] ?? ''}'),
            const Divider(),
            Text('Tanggal: ${s['tanggal_servis']}'),
            Text('Keluhan: ${s['keluhan']}'),
            Text('Tindakan: ${s['tindakan'] ?? '-'}'),
            Text('Kilometer: ${s['kilometer'] ?? '-'} km'),
            Text(
              'Biaya: ${rupiah(s['biaya'])}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: biru,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: cari,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Cari nomor polisi',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => cariRiwayat(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Cari riwayat',
                onPressed: mencari ? null : cariRiwayat,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: tambah,
              icon: const Icon(Icons.add),
              label: const Text('Catat Servis Baru'),
            ),
          ),
        ),
        Expanded(
          child: mencari
              ? const Center(child: CircularProgressIndicator())
              : hasilCari != null
                  ? Column(
                      children: [
                        ListTile(
                          title: Text('Hasil pencarian: ${hasilCari!.length}'),
                          trailing: TextButton(
                            onPressed: () => setState(() {
                              hasilCari = null;
                              cari.clear();
                            }),
                            child: const Text('Lihat semua'),
                          ),
                        ),
                        Expanded(
                          child: hasilCari!.isEmpty
                              ? const Kosong(
                                  pesan: 'Riwayat servis tidak ditemukan.',
                                )
                              : ListView(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  children: hasilCari!.map(kartuServis).toList(),
                                ),
                        ),
                      ],
                    )
                  : FutureBuilder<List<dynamic>>(
                      future: data,
                      builder: (context, s) {
                        if (s.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (s.hasError) {
                          return PesanError(
                            pesan: '${s.error}',
                            ulang: () => setState(muat),
                          );
                        }
                        final daftar = s.data ?? [];
                        if (daftar.isEmpty) {
                          return const Kosong(
                            pesan: 'Belum ada catatan servis.',
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async => setState(muat),
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            children: daftar.map(kartuServis).toList(),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class Kosong extends StatelessWidget {
  final String pesan;

  const Kosong({super.key, required this.pesan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 54,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 12),
            Text(pesan, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class PesanError extends StatelessWidget {
  final String pesan;
  final VoidCallback ulang;

  const PesanError({
    super.key,
    required this.pesan,
    required this.ulang,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 46, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat data',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(pesan, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: ulang,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}