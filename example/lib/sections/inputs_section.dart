// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Showcases:
/// Input (16): TextField, TextFormField, Checkbox, CheckboxListTile, Radio, RadioListTile,
/// Switch, SwitchListTile, Slider, RangeSlider, DropdownButton, DropdownButtonFormField,
/// DropdownMenu, Autocomplete, SearchBar, SearchAnchor
/// Stepper (1): Stepper
class InputsSection extends StatefulWidget {
  const InputsSection({super.key});

  @override
  State<InputsSection> createState() => _InputsSectionState();
}

class _InputsSectionState extends State<InputsSection> {
  late final TextEditingController _textController;
  late final SearchController _searchController;
  final ValueNotifier<bool> _checkboxNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _checkboxTileNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> _radioNotifier = ValueNotifier<int>(1);
  final ValueNotifier<bool> _switchNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _switchTileNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> _sliderNotifier = ValueNotifier<double>(65.0);
  final ValueNotifier<RangeValues> _rangeSliderNotifier =
      ValueNotifier<RangeValues>(const RangeValues(25.0, 75.0));
  final ValueNotifier<String> _dropdownNotifier = ValueNotifier<String>('Standard');
  final ValueNotifier<int> _stepperStepNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: 'Inspection Input');
    _searchController = SearchController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    _checkboxNotifier.dispose();
    _checkboxTileNotifier.dispose();
    _radioNotifier.dispose();
    _switchNotifier.dispose();
    _switchTileNotifier.dispose();
    _sliderNotifier.dispose();
    _rangeSliderNotifier.dispose();
    _dropdownNotifier.dispose();
    _stepperStepNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.inputs,
          itemCount: 17,
        ),

        // 1. SearchBar & SearchAnchor
        WidgetCard(
          title: 'Search Inputs: SearchBar & SearchAnchor',
          subtitle: 'SearchBar, SearchAnchor',
          badgeColor: const Color(0xFF6366F1),
          child: Column(
            children: [
              SearchBar(
                controller: _searchController,
                hintText: 'SearchBar hint text...',
                leading: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.search, size: 20, color: Color(0xFF6366F1)),
                ),
              ),
              const SizedBox(height: 8.0),
              SearchAnchor(
                builder: (context, controller) {
                  return OutlinedButton.icon(
                    icon: const Icon(Icons.saved_search_rounded, size: 16),
                    label: const Text('SearchAnchor bar', style: TextStyle(fontSize: 11)),
                    onPressed: () => controller.openView(),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  return [
                    const ListTile(title: Text('Component Result 1')),
                    const ListTile(title: Text('Component Result 2')),
                  ];
                },
              ),
            ],
          ),
        ),

        // 2. TextField, TextFormField, Autocomplete
        WidgetCard(
          title: 'Text Forms & Autocomplete',
          subtitle: 'TextField, TextFormField, Autocomplete',
          badgeColor: const Color(0xFF10B981),
          child: Column(
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'TextField',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                initialValue: 'TextFormField prefilled value',
                decoration: InputDecoration(
                  labelText: 'TextFormField',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
              const SizedBox(height: 8.0),
              Autocomplete<String>(
                optionsBuilder: (textEditingValue) {
                  const options = ['Container', 'Column', 'Row', 'Stack', 'Card'];
                  return options.where((opt) => opt.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Autocomplete Widget Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // 3. Checkbox, CheckboxListTile, Radio, RadioListTile
        WidgetCard(
          title: 'Toggles: Checkbox & Radio',
          subtitle: 'Checkbox, CheckboxListTile, Radio, RadioListTile',
          badgeColor: const Color(0xFFF59E0B),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _checkboxNotifier,
                        builder: (context, val, _) => Checkbox(
                          value: val,
                          onChanged: (newVal) => _checkboxNotifier.value = newVal ?? false,
                        ),
                      ),
                      const Text('Checkbox', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                  Row(
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: _radioNotifier,
                        builder: (context, val, _) => Radio<int>(
                          value: 1,
                          groupValue: val,
                          onChanged: (newVal) => _radioNotifier.value = newVal ?? 1,
                        ),
                      ),
                      const Text('Radio 1', style: TextStyle(fontSize: 11)),
                      ValueListenableBuilder<int>(
                        valueListenable: _radioNotifier,
                        builder: (context, val, _) => Radio<int>(
                          value: 2,
                          groupValue: val,
                          onChanged: (newVal) => _radioNotifier.value = newVal ?? 2,
                        ),
                      ),
                      const Text('Radio 2', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _checkboxTileNotifier,
                builder: (context, val, _) => CheckboxListTile(
                  dense: true,
                  title: const Text('CheckboxListTile', style: TextStyle(fontSize: 12)),
                  value: val,
                  onChanged: (newVal) => _checkboxTileNotifier.value = newVal ?? false,
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: _radioNotifier,
                builder: (context, val, _) => RadioListTile<int>(
                  dense: true,
                  title: const Text('RadioListTile (Option 1)', style: TextStyle(fontSize: 12)),
                  value: 1,
                  groupValue: val,
                  onChanged: (newVal) => _radioNotifier.value = newVal ?? 1,
                ),
              ),
            ],
          ),
        ),

        // 4. Switch, SwitchListTile, Slider, RangeSlider
        WidgetCard(
          title: 'Switches & Sliders',
          subtitle: 'Switch, SwitchListTile, Slider, RangeSlider',
          badgeColor: const Color(0xFF8B5CF6),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _switchNotifier,
                        builder: (context, val, _) => Switch(
                          value: val,
                          onChanged: (newVal) => _switchNotifier.value = newVal,
                        ),
                      ),
                      const Text('Switch', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                  Expanded(
                    child: ValueListenableBuilder<double>(
                      valueListenable: _sliderNotifier,
                      builder: (context, val, _) => Slider(
                        value: val,
                        min: 0,
                        max: 100,
                        onChanged: (newVal) => _sliderNotifier.value = newVal,
                      ),
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _switchTileNotifier,
                builder: (context, val, _) => SwitchListTile(
                  dense: true,
                  title: const Text('SwitchListTile', style: TextStyle(fontSize: 12)),
                  value: val,
                  onChanged: (newVal) => _switchTileNotifier.value = newVal,
                ),
              ),
              ValueListenableBuilder<RangeValues>(
                valueListenable: _rangeSliderNotifier,
                builder: (context, range, _) => RangeSlider(
                  values: range,
                  min: 0,
                  max: 100,
                  onChanged: (newRange) => _rangeSliderNotifier.value = newRange,
                ),
              ),
            ],
          ),
        ),

        // 5. DropdownButton, DropdownButtonFormField, DropdownMenu
        WidgetCard(
          title: 'Dropdown Selectors',
          subtitle: 'DropdownButton, DropdownButtonFormField, DropdownMenu',
          badgeColor: const Color(0xFFEC4899),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: _dropdownNotifier,
                      builder: (context, val, _) => DropdownButton<String>(
                        isExpanded: true,
                        value: val,
                        items: const [
                          DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                          DropdownMenuItem(value: 'Detailed', child: Text('Detailed')),
                          DropdownMenuItem(value: 'Forensic', child: Text('Forensic')),
                        ],
                        onChanged: (newVal) {
                          if (newVal != null) _dropdownNotifier.value = newVal;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const Expanded(
                    child: DropdownMenu<String>(
                      initialSelection: 'Menu 1',
                      dropdownMenuEntries: [
                        DropdownMenuEntry(value: 'Menu 1', label: 'Menu 1'),
                        DropdownMenuEntry(value: 'Menu 2', label: 'Menu 2'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              ValueListenableBuilder<String>(
                valueListenable: _dropdownNotifier,
                builder: (context, val, _) => DropdownButtonFormField<String>(
                  initialValue: val,
                  decoration: const InputDecoration(labelText: 'DropdownButtonFormField'),
                  items: const [
                    DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                    DropdownMenuItem(value: 'Detailed', child: Text('Detailed')),
                    DropdownMenuItem(value: 'Forensic', child: Text('Forensic')),
                  ],
                  onChanged: (newVal) {
                    if (newVal != null) _dropdownNotifier.value = newVal;
                  },
                ),
              ),
            ],
          ),
        ),

        // 6. Stepper
        WidgetCard(
          title: 'Stepper',
          subtitle: 'Multi-step process indicator',
          badgeColor: const Color(0xFF06B6D4),
          child: ValueListenableBuilder<int>(
            valueListenable: _stepperStepNotifier,
            builder: (context, step, _) {
              return Stepper(
                physics: const NeverScrollableScrollPhysics(),
                currentStep: step,
                onStepContinue: () {
                  if (step < 2) _stepperStepNotifier.value = step + 1;
                },
                onStepCancel: () {
                  if (step > 0) _stepperStepNotifier.value = step - 1;
                },
                steps: const [
                  Step(title: Text('Inspect Element'), content: Text('Select widget via pointer or marquee')),
                  Step(title: Text('Annotate Feedback'), content: Text('Add bug report or suggestion')),
                  Step(title: Text('Export & Sync'), content: Text('Push report via MCP / webhook')),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
