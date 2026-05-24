import 'package:flutter/material.dart';
import '../models/drug.dart';
import '../models/bird.dart';
import '../utils/drug_repository.dart';
import '../utils/dose_calc.dart';

class CalcScreen extends StatefulWidget {
  const CalcScreen({super.key});

  @override
  State<CalcScreen> createState() => _CalcScreenState();
}

class _CalcScreenState extends State<CalcScreen> {
  List<Drug> _filteredDrugs = [];

  Drug? _selectedDrug;
  Bird? _selectedBird;
  double _doseSlider = 0;
  double _waterVolume = 0.2;

  final _searchCtrl = TextEditingController();
  final _weightCtrl = TextEditingController(text: '100');
  final _strengthCtrl = TextEditingController(text: '5');
  final _waterCtrl = TextEditingController(text: '0.2');

  DoseResult? _result;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final drugs = await DrugRepository.load();
    setState(() {
      _filteredDrugs = drugs;
      _loaded = true;
    });
  }

  void _onSearch(String q) {
    setState(() {
      _filteredDrugs = DrugRepository.search(q);
    });
  }

  void _selectDrug(Drug drug) {
    setState(() {
      _selectedDrug = drug;
      _doseSlider = drug.doseMid;
      _result = null;
    });
    Navigator.pop(context);
  }

  void _selectBird(Bird bird) {
    setState(() {
      _selectedBird = bird;
      _waterVolume = bird.maxOralMl * 0.6; // default to 60% of max
      _waterCtrl.text = _waterVolume.toStringAsFixed(2);
      _result = null;
    });
    Navigator.pop(context);
  }

  void _calculate() {
    if (_selectedDrug == null || _selectedBird == null) return;

    final weight = double.tryParse(_weightCtrl.text) ?? 100;
    final strength = double.tryParse(_strengthCtrl.text) ?? 5;
    final water = double.tryParse(_waterCtrl.text) ?? 0.2;

    if (weight <= 0 || strength <= 0 || water <= 0) return;

    setState(() {
      _waterVolume = water;
      _result = DoseCalculator.calculate(
        drug: _selectedDrug!,
        selectedDose: _doseSlider,
        birdWeightG: weight,
        drugStrength: strength,
        waterVolumeMl: water,
        maxOralMl: _selectedBird!.maxOralMl,
      );
    });
  }

  void _showDrugPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: '搜索药品名称...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _onSearch,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: _filteredDrugs.length,
                  itemBuilder: (_, i) {
                    final d = _filteredDrugs[i];
                    return ListTile(
                      title: Text(d.name),
                      subtitle: Text(
                        '${d.doseMin}-${d.doseMax} mg/kg  |  ${d.route}  |  ${d.birds}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Chip(label: Text(d.category, style: const TextStyle(fontSize: 11))),
                      onTap: () => _selectDrug(d),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBirdPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SizedBox(
        height: 400,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: birdSpecies.length,
          itemBuilder: (_, i) {
            final b = birdSpecies[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: b.maxOralMl > 0.5
                    ? Colors.blue.shade100
                    : Colors.orange.shade100,
                child: Text(b.category[0], style: TextStyle(
                  color: b.maxOralMl > 0.5 ? Colors.blue : Colors.orange,
                )),
              ),
              title: Text(b.name),
              subtitle: Text('${b.weightMinG}-${b.weightMaxG}g  |  口服上限 ${b.maxOralMl}mL'),
              onTap: () => _selectBird(b),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🦜 药物计算器'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 选药
            _buildSectionTitle('① 选择药品'),
            const SizedBox(height: 4),
            _buildDrugSelector(),
            const SizedBox(height: 20),

            // 选鸟
            _buildSectionTitle('② 选择鹦鹉'),
            const SizedBox(height: 4),
            _buildBirdSelector(),
            const SizedBox(height: 20),

            // 剂量滑块
            if (_selectedDrug != null) ...[
              _buildSectionTitle('③ 调整剂量强度'),
              _buildDoseSlider(),
              const SizedBox(height: 20),
            ],

            // 参数输入
            _buildSectionTitle('④ 输入参数'),
            const SizedBox(height: 4),
            _buildParamInputs(),
            const SizedBox(height: 24),

            // 计算按钮
            FilledButton.icon(
              onPressed: (_selectedDrug != null && _selectedBird != null) ? _calculate : null,
              icon: const Icon(Icons.calculate),
              label: const Text('计算配药方案', style: TextStyle(fontSize: 16)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            // 结果
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResult(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15));
  }

  Widget _buildDrugSelector() {
    return Card(
      child: InkWell(
        onTap: _showDrugPicker,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.medication, color: Colors.teal),
              const SizedBox(width: 12),
              Expanded(
                child: _selectedDrug == null
                    ? const Text('点击选择药品...', style: TextStyle(color: Colors.grey, fontSize: 15))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_selectedDrug!.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          Text('${_selectedDrug!.doseMin}-${_selectedDrug!.doseMax} mg/kg, ${_selectedDrug!.route}, ${_selectedDrug!.freq}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirdSelector() {
    return Card(
      child: InkWell(
        onTap: _showBirdPicker,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.pets, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: _selectedBird == null
                    ? const Text('点击选择鹦鹉...', style: TextStyle(color: Colors.grey, fontSize: 15))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_selectedBird!.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          Text('${_selectedBird!.weightMinG}-${_selectedBird!.weightMaxG}g  |  口服上限 ${_selectedBird!.maxOralMl}mL',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoseSlider() {
    final d = _selectedDrug!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('保守 ${d.doseMin}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text('${_doseSlider.toStringAsFixed(1)} mg/kg', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${d.doseMax} 加强', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            Slider(
              value: _doseSlider,
              min: d.doseMin,
              max: d.doseMax,
              divisions: ((d.doseMax - d.doseMin) * 2).round(),
              label: '${_doseSlider.toStringAsFixed(1)} mg/kg',
              onChanged: (v) => setState(() => _doseSlider = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParamInputs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputRow('鹦鹉体重 (g)', _weightCtrl, '例: 100'),
            const SizedBox(height: 12),
            _buildInputRow('每片药含量 (mg)', _strengthCtrl, '例: 5'),
            const SizedBox(height: 12),
            _buildInputRow(
              '加水体积 (mL)',
              _waterCtrl,
              _selectedBird != null ? '参考上限 ${_selectedBird!.maxOralMl}mL' : '例: 0.2',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController ctrl, String hint) {
    return Row(
      children: [
        SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 14))),
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final r = _result!;
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, size: 20),
                const SizedBox(width: 8),
                Text('📋 配药方案', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),

            _resultRow('药品', r.drug.name),
            _resultRow('剂量', '${r.selectedDose.toStringAsFixed(1)} mg/kg'),
            _resultRow('需药量', '${r.requiredMg.toStringAsFixed(2)} mg'),
            _resultRow('药片规格', '${r.drugStrength.toStringAsFixed(1)} mg/片'),

            const Divider(height: 16),
            Text(
              '取 ${r.tabletsNeeded} 片 (${r.actualMg.toStringAsFixed(1)}mg)，研碎',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            Text('加 ${r.waterVolumeMl.toStringAsFixed(2)} mL 水溶解'),
            const SizedBox(height: 8),
            Text(
              '药液浓度: ${r.concentration.toStringAsFixed(1)} mg/mL',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: r.isOverLimit ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(r.isOverLimit ? Icons.warning_amber : Icons.check_circle,
                       color: r.isOverLimit ? Colors.red : Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      r.isOverLimit
                        ? '⚠️ 每次喂 ${r.dosePerTimeMl.toStringAsFixed(2)}mL，超过安全上限 ${r.maxOralMl}mL！请增加水量重新计算'
                        : '✅ 每次喂服 ${r.dosePerTimeMl.toStringAsFixed(2)} mL（用 1mL 针管），未超过安全上限 ${r.maxOralMl}mL',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: r.isOverLimit ? Colors.red.shade800 : Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 16),
            _resultRow('给药频次', r.drug.freq),
            _resultRow('给药途径', r.drug.route),
            if (r.drug.note.isNotEmpty) _resultRow('备注', r.drug.note),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _weightCtrl.dispose();
    _strengthCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }
}
