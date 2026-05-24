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
  double _dosePerTimeMl = 0.2;

  final _searchCtrl = TextEditingController();
  final _weightCtrl = TextEditingController(text: '100');
  final _strengthCtrl = TextEditingController(text: '5');

  DoseResult? _result;
  bool _loaded = false;

  String get _strengthLabel =>
    _selectedDrug != null && _selectedDrug!.unit.contains('IU')
      ? '每片药含量 (万IU)' : '每片药含量 (mg)';

  String get _strengthHint =>
    _selectedDrug != null && _selectedDrug!.unit.contains('IU') ? '例: 10' : '例: 5';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final drugs = await DrugRepository.load();
    setState(() { _filteredDrugs = drugs; _loaded = true; });
  }

  void _onSearch(String q) => setState(() { _filteredDrugs = DrugRepository.search(q); });

  void _selectDrug(Drug drug) {
    setState(() { _selectedDrug = drug; _doseSlider = drug.doseMid; _result = null; });
    Navigator.pop(context);
  }

  void _selectBird(Bird bird) {
    setState(() { _selectedBird = bird; _result = null; _dosePerTimeMl = bird.maxOralMl <= 0.2 ? 0.2 : 1.0; });
    Navigator.pop(context);
  }

  void _calculate() {
    if (_selectedDrug == null || _selectedBird == null) return;
    final weight = double.tryParse(_weightCtrl.text) ?? 100;
    final strength = double.tryParse(_strengthCtrl.text) ?? 5;
    if (weight <= 0 || strength <= 0) return;
    final isIu = _selectedDrug!.unit.contains('IU');
    setState(() {
      _result = DoseCalculator.calculate(
        drug: _selectedDrug!, selectedDose: _doseSlider, birdWeightG: weight,
        drugStrength: strength, strengthUnit: isIu ? '万IU' : 'mg',
        dosePerTimeMl: _dosePerTimeMl, maxOralMl: _selectedBird!.maxOralMl,
      );
    });
  }

  Drug? _expandedDrug;

  void _showDrugPicker() {
    _expandedDrug = null;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.85, expand: false,
          builder: (_, scrollCtrl) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(hintText: '搜索药品名称...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                onChanged: (q) => setSheetState(() => _onSearch(q)),
              ),
              const SizedBox(height: 8),
              Expanded(child: ListView.builder(controller: scrollCtrl, itemCount: _filteredDrugs.length, itemBuilder: (_, i) {
                final d = _filteredDrugs[i];
                final isExpanded = _expandedDrug == d;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${d.doseMin}-${d.doseMax} ${d.unit}  |  ${d.route}  |  ${d.birds}', style: const TextStyle(fontSize: 12)),
                          if (d.note.isNotEmpty) Row(children: [
                            Icon(Icons.info_outline, size: 12, color: Colors.orange.shade600),
                            const SizedBox(width: 3),
                            Flexible(child: Text(d.note, style: TextStyle(fontSize: 11, color: Colors.orange.shade600))),
                          ]),
                        ]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (d.mechanism.isNotEmpty || d.sideEffects.isNotEmpty)
                              IconButton(
                                icon: Icon(isExpanded ? Icons.expand_less : Icons.info_outline,
                                    size: 20, color: Colors.teal),
                                onPressed: () {
                                  setSheetState(() {
                                    _expandedDrug = isExpanded ? null : d;
                                  });
                                  // 展开后仅在内容超出可见区域时才滚动
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    final idx = _filteredDrugs.indexOf(d);
                                    if (idx < 0 || !scrollCtrl.hasClients) return;
                                    const itemH = 86.0;   // 卡片折叠时高度
                                    const extraH = 190.0; // 展开额外高度
                                    final top = idx * itemH;
                                    final bottom = top + itemH + extraH;
                                    final viewTop = scrollCtrl.offset;
                                    final viewBottom = viewTop + scrollCtrl.position.viewportDimension;
                                    if (bottom > viewBottom) {
                                      final target = bottom - viewBottom + viewTop + 10;
                                      scrollCtrl.animateTo(
                                        target.clamp(0, scrollCtrl.position.maxScrollExtent),
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  });
                                },
                              ),
                            ChoiceChip(label: Text('✓ 选择', style: const TextStyle(fontSize: 11)),
                              selected: false, onSelected: (_) => _selectDrug(d)),
                          ],
                        ),
                      ),
                      if (isExpanded)
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (d.mechanism.isNotEmpty) ...[                                const Divider(height: 8),
                                Text('作用机理', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.teal.shade700)),
                                const SizedBox(height: 4),
                                Text(d.mechanism, style: const TextStyle(fontSize: 12)),
                              ],
                              if (d.sideEffects.isNotEmpty) ...[                                const SizedBox(height: 8),
                                Text('副作用', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.orange.shade700)),
                                const SizedBox(height: 4),
                                Text(d.sideEffects, style: const TextStyle(fontSize: 12)),
                              ],                            ],                          ),
                        ),                    ],                  ),
                );
              })),
            ]),
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
              leading: CircleAvatar(backgroundColor: b.maxOralMl > 0.5 ? Colors.blue.shade100 : Colors.orange.shade100,
                child: Text(b.category[0], style: TextStyle(color: b.maxOralMl > 0.5 ? Colors.blue : Colors.orange))),
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
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isSmall = _selectedBird != null && _selectedBird!.maxOralMl <= 0.2;

    return Scaffold(
      appBar: AppBar(title: const Text('🦜 药物计算器'), backgroundColor: Theme.of(context).colorScheme.primaryContainer),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _section('① 选择药品'),
        const SizedBox(height: 4), _buildDrugSelector(), const SizedBox(height: 20),
        _section('② 选择鹦鹉'),
        const SizedBox(height: 4), _buildBirdSelector(), const SizedBox(height: 20),
        if (_selectedDrug != null) ...[
          _section('③ 调整剂量强度'), _buildDoseSlider(), const SizedBox(height: 20),
        ],
        _section('④ 输入参数'),
        const SizedBox(height: 4), _buildParamInputs(), const SizedBox(height: 20),
        if (_selectedBird != null) ...[
          _section('⑤ 选择每次喂服量'),
          const SizedBox(height: 4), _buildDoseVolume(isSmall), const SizedBox(height: 24),
        ],
        FilledButton.icon(
          onPressed: (_selectedDrug != null && _selectedBird != null) ? _calculate : null,
          icon: const Icon(Icons.calculate),
          label: const Text('计算配药方案', style: TextStyle(fontSize: 16)),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        ),
        if (_result != null) ...[const SizedBox(height: 24), _buildResult()],
      ])),
    );
  }

  Widget _section(String t) => Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15));

  Widget _buildDrugSelector() => Card(child: InkWell(onTap: _showDrugPicker, borderRadius: BorderRadius.circular(12),
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(children: [
      const Icon(Icons.medication, color: Colors.teal), const SizedBox(width: 12),
      Expanded(child: _selectedDrug == null
        ? const Text('点击选择药品...', style: TextStyle(color: Colors.grey, fontSize: 15))
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_selectedDrug!.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text('${_selectedDrug!.doseMin}-${_selectedDrug!.doseMax} ${_selectedDrug!.unit}, ${_selectedDrug!.route}, ${_selectedDrug!.freq}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (_selectedDrug!.note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2), child: Row(children: [
              Icon(Icons.info_outline, size: 13, color: Colors.orange.shade700),
              const SizedBox(width: 4),
              Flexible(child: Text(_selectedDrug!.note, style: TextStyle(fontSize: 11, color: Colors.orange.shade700))),
            ])),
          ])),
      const Icon(Icons.arrow_drop_down),
    ]))));

  Widget _buildBirdSelector() => Card(child: InkWell(onTap: _showBirdPicker, borderRadius: BorderRadius.circular(12),
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(children: [
      const Icon(Icons.pets, color: Colors.orange), const SizedBox(width: 12),
      Expanded(child: _selectedBird == null
        ? const Text('点击选择鹦鹉...', style: TextStyle(color: Colors.grey, fontSize: 15))
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_selectedBird!.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text('${_selectedBird!.weightMinG}-${_selectedBird!.weightMaxG}g  |  口服上限 ${_selectedBird!.maxOralMl}mL', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ])),
      const Icon(Icons.arrow_drop_down),
    ]))));

  Widget _buildDoseSlider() {
    final d = _selectedDrug!;
    return Card(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('保守 ${d.doseMin}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text('${_doseSlider.toStringAsFixed(1)} ${d.unit}', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text('${d.doseMax} 加强', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
      Slider(value: _doseSlider, min: d.doseMin, max: d.doseMax, divisions: ((d.doseMax - d.doseMin) * 2).round(),
        label: '${_doseSlider.toStringAsFixed(1)} ${d.unit}', onChanged: (v) => setState(() => _doseSlider = v)),
    ])));
  }

  Widget _buildParamInputs() => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    _inputRow('鹦鹉体重 (g)', _weightCtrl, '例: 100'),
    const SizedBox(height: 12),
    _inputRow(_strengthLabel, _strengthCtrl, _strengthHint),
  ])));

  Widget _inputRow(String label, TextEditingController ctrl, String hint) => Row(children: [
    SizedBox(width: 150, child: Text(label, style: const TextStyle(fontSize: 14))),
    Expanded(child: TextField(controller: ctrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(hintText: hint, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), border: const OutlineInputBorder()))),
  ]);

  Widget _buildDoseVolume(bool isSmall) {
    final options = isSmall ? [0.1, 0.2] : [0.5, 1.0, 2.0];
    return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(isSmall ? '中小型鹦鹉推荐 0.1 或 0.2mL' : '大型鹦鹉推荐 0.5 或 1.0mL', style: const TextStyle(fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 8),
      Row(children: options.map((v) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ChoiceChip(
        label: Text('${v}mL', style: const TextStyle(fontSize: 14)), selected: _dosePerTimeMl == v,
        onSelected: (_) => setState(() { _dosePerTimeMl = v; _result = null; }),
      )))).toList()),
    ])));
  }

  Widget _buildResult() {
    final r = _result!;
    final unit = r.strengthUnit;
    final doseLabel = r.doseLabel;

    return Card(elevation: 4, color: Theme.of(context).colorScheme.primaryContainer, child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.description, size: 20), const SizedBox(width: 8),
        Text('📋 配药方案', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))]),
      const Divider(height: 20),
      _row('药品', r.drug.name),
      _row('剂量', '${r.selectedDose.toStringAsFixed(r.isIu ? 0 : 1)} ${r.isIu ? "IU/kg" : r.doseUnit}'),
      _row('需药量', '${r.requiredAmount.toStringAsFixed(1)} $doseLabel'),
      _row('药片规格', '${r.drugStrength.toStringAsFixed(1)} $unit/片'),
      const Divider(height: 16),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('① 取 ${r.tabletsNeeded} 片（${r.actualAmount.toStringAsFixed(1)}$unit），研碎', style: const TextStyle(fontSize: 15)),
        const SizedBox(height: 6),
        Text('② 加水 ${r.waterVolumeMl.toStringAsFixed(2)} mL，搅拌溶解', style: const TextStyle(fontSize: 15)),
        Text('   （用秤称 ${r.waterVolumeMl.toStringAsFixed(2)}g 水即可）', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Text('③ 药液浓度: ${r.concentration.toStringAsFixed(1)} $unit/mL', style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
          color: r.isOverLimit ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Icon(r.isOverLimit ? Icons.warning_amber : Icons.check_circle, color: r.isOverLimit ? Colors.red : Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(
              '④ 每次用 1mL 针管抽 ${r.dosePerTimeMl.toStringAsFixed(1)} mL 喂服\n'
              '   （含 ${r.actualDoseAmount.toStringAsFixed(1)}$doseLabel）',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: r.isOverLimit ? Colors.red.shade800 : Colors.green.shade800))),
          ]),
        ),
      ])),
      const Divider(height: 16),
      _row('给药频次', r.drug.freq),
      _row('给药途径', r.drug.route),
      if (r.drug.note.isNotEmpty) _row('备注', r.drug.note),
      if (!r.isAccurate && !r.isOverLimit) Padding(padding: const EdgeInsets.only(top: 8), child: Text(r.note, style: TextStyle(color: Colors.orange.shade800, fontSize: 13))),
    ])));
  }

  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.grey))),
    Expanded(child: Text(value)),
  ]));

  @override
  void dispose() { _searchCtrl.dispose(); _weightCtrl.dispose(); _strengthCtrl.dispose(); super.dispose(); }
}
