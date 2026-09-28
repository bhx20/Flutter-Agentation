import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Comprehensive showcase of Flutter text fields, search bars, switches, and sliders.
class InputsSection extends StatefulWidget {
  const InputsSection({super.key});

  @override
  State<InputsSection> createState() => _InputsSectionState();
}

class _InputsSectionState extends State<InputsSection> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController(text: 'Visual Inspection Engine');
  final _searchController = SearchController();

  bool _switchVal1 = true;
  bool _switchVal2 = false;
  bool? _checkboxVal1 = true;
  bool? _checkboxVal2 = false;
  bool? _checkboxValTristate;
  int _selectedRadio = 1;
  double _sliderValue = 65.0;
  RangeValues _rangeValues = const RangeValues(20.0, 80.0);

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.inputs,
          itemCount: 8,
        ),

        // 1. SearchBar (Material 3)
        WidgetCard(
          title: 'SearchBar',
          subtitle: 'Material 3 SearchBar widget with leading and trailing actions',
          child: SearchBar(
            controller: _searchController,
            hintText: 'Search inspectable components...',
            leading: const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.search, color: Color(0xFF6366F1)),
            ),
            trailing: [
              IconButton(
                icon: const Icon(Icons.mic_none_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // 2. TextField & TextFormField
        WidgetCard(
          title: 'TextField & TextFormField',
          subtitle: 'Text entry with prefix icons, helper text, and validation',
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: 'Annotation Title',
                    hintText: 'Enter component summary...',
                    helperText: 'Will be exported in markdown / MCP report',
                    prefixIcon: const Icon(Icons.edit_note_outlined, color: Color(0xFF6366F1)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, size: 18.0),
                      onPressed: () => _textController.clear(),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextFormField(
                  initialValue: 'sankeerth@flutter.dev',
                  decoration: InputDecoration(
                    labelText: 'Reviewer Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),

        // 3. Selection Controls: Switches, Checkboxes, Radios
        WidgetCard(
          title: 'Switch, Checkbox & Radio Controls',
          subtitle: 'Toggle, multi-select, and exclusive radio option selectors',
          child: Column(
            children: [
              // Switches row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: _switchVal1,
                        activeThumbColor: const Color(0xFF6366F1),
                        onChanged: (val) => setState(() => _switchVal1 = val),
                      ),
                      const SizedBox(width: 6.0),
                      const Text('Auto-Freeze'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch.adaptive(
                        value: _switchVal2,
                        activeThumbColor: const Color(0xFF10B981),
                        onChanged: (val) => setState(() => _switchVal2 = val),
                      ),
                      const SizedBox(width: 6.0),
                      const Text('MCP Sync'),
                    ],
                  ),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(value: false, onChanged: null), // Disabled
                      SizedBox(width: 6.0),
                      Text('Locked', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24.0),

              // Checkboxes row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _checkboxVal1,
                        activeColor: const Color(0xFF6366F1),
                        onChanged: (val) => setState(() => _checkboxVal1 = val),
                      ),
                      const Text('Checked'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _checkboxVal2,
                        onChanged: (val) => setState(() => _checkboxVal2 = val),
                      ),
                      const Text('Unchecked'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _checkboxValTristate,
                        tristate: true,
                        activeColor: const Color(0xFFF59E0B),
                        onChanged: (val) => setState(() => _checkboxValTristate = val),
                      ),
                      const Text('Tristate'),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24.0),

              // Radios row with RadioGroup
              RadioGroup<int>(
                groupValue: _selectedRadio,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRadio = val);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<int>(
                          value: 1,
                          activeColor: Color(0xFF6366F1),
                        ),
                        Text('Option A'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<int>(
                          value: 2,
                          activeColor: Color(0xFF6366F1),
                        ),
                        Text('Option B'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<int>(
                          value: 3,
                          activeColor: Color(0xFF6366F1),
                        ),
                        Text('Option C'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 4. Sliders & RangeSliders
        WidgetCard(
          title: 'Slider & RangeSlider',
          subtitle: 'Continuous value selection with real-time value badges',
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.opacity, size: 20.0, color: Color(0xFF6366F1)),
                  const SizedBox(width: 8.0),
                  Text('Opacity (${_sliderValue.toInt()}%)'),
                  Expanded(
                    child: Slider(
                      value: _sliderValue,
                      min: 0.0,
                      max: 100.0,
                      divisions: 20,
                      label: '${_sliderValue.toInt()}%',
                      activeColor: const Color(0xFF6366F1),
                      onChanged: (val) => setState(() => _sliderValue = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.straighten, size: 20.0, color: Color(0xFF10B981)),
                  const SizedBox(width: 8.0),
                  Text('Bounds [${_rangeValues.start.toInt()} - ${_rangeValues.end.toInt()}]'),
                  Expanded(
                    child: RangeSlider(
                      values: _rangeValues,
                      min: 0.0,
                      max: 100.0,
                      divisions: 10,
                      labels: RangeLabels(
                        '${_rangeValues.start.toInt()}',
                        '${_rangeValues.end.toInt()}',
                      ),
                      activeColor: const Color(0xFF10B981),
                      onChanged: (vals) => setState(() => _rangeValues = vals),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
