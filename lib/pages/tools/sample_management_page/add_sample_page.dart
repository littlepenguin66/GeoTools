import 'package:flutter/material.dart';

class AddSamplePage extends StatefulWidget {
  final String routeName;
  final List<Map<String, dynamic>> samples;
  final ValueChanged<Map<String, dynamic>> onSampleAdded; // 回调函数

  const AddSamplePage(
      {super.key, required this.routeName, required this.samples, required this.onSampleAdded});

  @override
  _AddSamplePageState createState() => _AddSamplePageState();
}

class _AddSamplePageState extends State<AddSamplePage> {
  DateTime? _selectedDate;
  final TextEditingController _sampleNameController = TextEditingController();
  final TextEditingController _sampleDescriptionController =
      TextEditingController();

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveSample() {
    if (_selectedDate != null && _sampleNameController.text.isNotEmpty) {
      String sampleInfo =
          '路线名称: ${widget.routeName}, 样品名称: ${_sampleNameController.text}, 描述: ${_sampleDescriptionController.text.isNotEmpty ? _sampleDescriptionController.text : '无'}, 时间: ${_selectedDate!.toLocal().toString().substring(0, 16)}';
      final newSample = {
        'info': sampleInfo,
      };
      widget.onSampleAdded(newSample); // 调用回调函数
      _sampleNameController.clear();
      _sampleDescriptionController.clear();
      setState(() {
        _selectedDate = null;
      });
    } else {
      // 错误处理，例如提示用户填写所有信息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写样品名称和时间信息')),
      );
    }
  }

  void _deleteSample(int index) {
    setState(() {
      widget.samples.removeAt(index);
    });
  }

  void _editSample(int index) {
    final sample = widget.samples[index];
    _sampleNameController.text = sample['info'].split(', ')[1].split(': ')[1];
    _sampleDescriptionController.text = sample['info'].split(', ')[2].split(': ')[1];
    _selectedDate = DateTime.parse(sample['info'].split(', ')[3].split(': ')[1]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('修改样品信息'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _sampleNameController,
                  decoration: const InputDecoration(
                    labelText: '样品名称',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _sampleDescriptionController,
                  decoration: const InputDecoration(
                    labelText: '样品描述',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _selectDateTime(context),
                  child: Text(_selectedDate == null
                      ? '选择时间'
                      : '已选择时间: ${_selectedDate!.toLocal().toString().substring(0, 16)}'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.samples[index] = {
                    'info': '路线名称: ${widget.routeName}, 样品名称: ${_sampleNameController.text}, 描述: ${_sampleDescriptionController.text.isNotEmpty ? _sampleDescriptionController.text : '无'}, 时间: ${_selectedDate!.toLocal().toString().substring(0, 16)}',
                  };
                });
                Navigator.of(context).pop();
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routeName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.samples.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('样品详情'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.samples[index]['info']
                                      .split(', ')
                                      .join('\n'),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('关闭'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.samples[index]['info']
                                  .split(', ')
                                  .join('\n'),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Theme.of(context).iconTheme.color),
                                  onPressed: () {
                                    _editSample(index);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                        color: Theme.of(context).iconTheme.color),
                                  onPressed: () {
                                    _deleteSample(index);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('添加样品信息'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _sampleNameController,
                        decoration: const InputDecoration(
                          labelText: '样品名称',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _sampleDescriptionController,
                        decoration: const InputDecoration(
                          labelText: '样品描述',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _selectDateTime(context),
                        child: Text(_selectedDate == null
                            ? '选择时间'
                            : '已选择时间: ${_selectedDate!.toLocal().toString().substring(0, 16)}'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _saveSample();
                    },
                    child: const Text('保存'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}