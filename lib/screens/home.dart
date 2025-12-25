import 'package:flutter/material.dart';
import 'menu_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late TabController _tabController;

  // 🔎 Data menu Sutta sesuai fragment Android
  final suttaKitabs = [
    {
      "acronym": "DN",
      "name": "Dīghanikāya",
      "desc": "Kumpulan Panjang",
      "range": "DN 1–34",
    },
    {
      "acronym": "MN",
      "name": "Majjhimanikāya",
      "desc": "Kumpulan Sedang",
      "range": "MN 1–152",
    },
    {
      "acronym": "SN",
      "name": "Saṁyuttanikāya",
      "desc": "Kumpulan Bertaut",
      "range": "SN 1–56",
    },
    {
      "acronym": "AN",
      "name": "Aṅguttaranikāya",
      "desc": "Kumpulan Berangka",
      "range": "AN 1–11",
    },
    {
      "acronym": "Kp",
      "name": "Khuddakapāṭha",
      "desc": "Kumpulan Kecil – Petikan Pendek",
      "range": "Kp 1–9",
    },
    {
      "acronym": "Dhp",
      "name": "Dhammapada",
      "desc": "Kumpulan Kecil – Bait Kebenaran",
      "range": "Dhp 1–423",
    },
    {
      "acronym": "Ud",
      "name": "Udāna",
      "desc": "Kumpulan Kecil – Seruan Luhur",
      "range": "Ud 1–8",
    },
    {
      "acronym": "Iti",
      "name": "Itivuttaka",
      "desc": "Kumpulan Kecil – Sedemikian Dikatakan",
      "range": "Iti 1–112",
    },
    {
      "acronym": "Snp",
      "name": "Suttanipāta",
      "desc": "Kumpulan Kecil – Koleksi Diskursus",
      "range": "Snp 1–5",
    },
    {
      "acronym": "Vv",
      "name": "Vimānavatthu",
      "desc": "Kumpulan Kecil – Cerita Wisma",
      "range": "Vv 1–85",
    },
    {
      "acronym": "Pv",
      "name": "Petavatthu",
      "desc": "Kumpulan Kecil – Cerita Hantu",
      "range": "Pv 1–51",
    },
    {
      "acronym": "Thag",
      "name": "Theragāthā",
      "desc": "Kumpulan Kecil – Syair Thera",
      "range": "Thag 1–21",
    },
    {
      "acronym": "Thig",
      "name": "Therīgāthā",
      "desc": "Kumpulan Kecil – Syair Therī",
      "range": "Thig 1–16",
    },
    {
      "acronym": "ThaAp",
      "name": "Therāpadāna",
      "desc": "Kumpulan Kecil – Legenda Thera",
      "range": "Tha Ap 1–563",
    },
    {
      "acronym": "ThiAp",
      "name": "Therīapadāna",
      "desc": "Kumpulan Kecil – Legenda Therī",
      "range": "Thi Ap 1–40",
    },
    {
      "acronym": "Bv",
      "name": "Buddhavaṁsa",
      "desc": "Kumpulan Kecil – Wangsa Buddha",
      "range": "Bv 1–29",
    },
    {
      "acronym": "Cp",
      "name": "Cariyāpiṭaka",
      "desc": "Kumpulan Kecil – Keranjang Perilaku",
      "range": "Cp 1–35",
    },
    {
      "acronym": "Ja",
      "name": "Jātaka",
      "desc": "Kumpulan Kecil – Kisah Kelahiran",
      "range": "Ja 1–547",
    },
    {
      "acronym": "Mnd",
      "name": "Mahāniddesa",
      "desc": "Kumpulan Kecil – Eksposisi Besar",
      "range": "Mnd 1–16",
    },
    {
      "acronym": "Cnd",
      "name": "Cūḷaniddesa",
      "desc": "Kumpulan Kecil – Eksposisi Kecil",
      "range": "Cnd 1–23",
    },
    {
      "acronym": "Ps",
      "name": "Paṭisambhidāmagga",
      "desc": "Kumpulan Kecil – Jalan Analitis",
      "range": "Ps 1–3",
    },
    {
      "acronym": "Ne",
      "name": "Netti",
      "desc": "Kumpulan Kecil – Panduan",
      "range": "Ne 1–37",
    },
    {
      "acronym": "Pe",
      "name": "Peṭakopadesa",
      "desc": "Kumpulan Kecil – Wilayah Keranjang",
      "range": "Pe 1–9",
    },
    {
      "acronym": "Mil",
      "name": "Milindapañha",
      "desc": "Kumpulan Kecil – Pertanyaan Milinda",
      "range": "Mil 1–8",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget buildKitabIcon(String acronym) {
    return CircleAvatar(
      backgroundColor: Colors.deepPurple,
      child: Text(
        acronym,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildKitabList(List<Map<String, String>> kitabs) {
    return ListView.builder(
      itemCount: kitabs.length,
      itemBuilder: (context, index) {
        final kitab = kitabs[index];
        final uid = kitab["acronym"]!.toLowerCase();

        return ListTile(
          leading: buildKitabIcon(kitab["acronym"]!),
          title: Text(kitab["name"]!),
          subtitle: Text("${kitab["desc"]}\n${kitab["range"]}"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MenuPage(uid: uid)),
            );
          },
        );
      },
    );
  }

  Widget buildSliderGreeting() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.orange.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Sotthi Hotu, Namo Ratanattayā",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text("2025 M / 2568–2569 TB", style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tripitaka Indonesia")),
      body: Column(
        children: [
          buildSliderGreeting(),
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            tabs: const [
              Tab(text: "Sutta"),
              Tab(text: "Abhidhamma"),
              Tab(text: "Vinaya"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildKitabList(suttaKitabs),
                const Center(child: Text("Abhidhamma belum diisi")),
                const Center(child: Text("Vinaya belum diisi")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
