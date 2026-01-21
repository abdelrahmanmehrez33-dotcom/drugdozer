import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../di/service_locator.dart';
import '../../domain/entities/drug.dart';
import '../../domain/entities/drug_type.dart';
import '../../domain/repositories/drug_repository.dart';
import 'details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DrugRepository _drugRepository = getIt<DrugRepository>();
  final TextEditingController _searchController = TextEditingController();
  List<Drug> _searchResults = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadAllDrugs();
  }

  Future<void> _loadAllDrugs() async {
    final drugs = await _drugRepository.getAllDrugs();
    setState(() {
      _searchResults = drugs;
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        List<Drug> results;
        
        if (query.isEmpty) {
          results = await _drugRepository.getAllDrugs();
        } else {
          results = await _drugRepository.searchDrugs(query);
        }
        
        setState(() {
          _searchResults = results;
        });
      } catch (e) {
        print("Error searching drugs: $e");
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث عن دواء'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ابحث عن دواء بالاسم العربي أو الإنجليزي...',
                hintStyle: GoogleFonts.cairo(),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00695C)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final drug = _searchResults[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(_getDrugIcon(drug.type)),
                    title: Text(drug.arabicName),
                    subtitle: Text('${drug.englishName} - ${drug.category}'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(drug: drug),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDrugIcon(DrugType type) {
    switch (type) {
      case DrugType.syrup: return Icons.water_drop;
      case DrugType.tablet: return Icons.medication;
      case DrugType.cream: return Icons.healing;
      case DrugType.spray: return Icons.air;
      case DrugType.drops: return Icons.water_drop_outlined;
      case DrugType.injection: return Icons.medication_liquid;
    }
  }
}