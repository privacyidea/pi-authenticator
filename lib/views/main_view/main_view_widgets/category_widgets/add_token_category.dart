import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../utils/riverpod_providers.dart';

class AddTokenCategory extends ConsumerStatefulWidget {
  const AddTokenCategory({Key? key}) : super(key: key);

  @override
  ConsumerState<AddTokenCategory> createState() => _AddTokenCategoryWidgetState();
}

class _AddTokenCategoryWidgetState extends ConsumerState<AddTokenCategory> {
  bool addingCategory = false;
  final TextEditingController _folderNameController = TextEditingController();

  void onSubmitted(String value) {
    ref.read(tokenCategoryProvider.notifier).addCategory(value);
    setState(() {
      addingCategory = false;
    });
  }

  void onCanceled() {
    setState(() {
      addingCategory = false;
    });
  }

  void startAddingCategory() {
    setState(() {
      addingCategory = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return addingCategory
        ? ListTile(
            leading: IconButton(
              onPressed: () {
                onSubmitted(_folderNameController.text);
              },
              icon: const Icon(Icons.check),
            ),
            title: TextField(
                autofocus: true,
                controller: _folderNameController,
                decoration: const InputDecoration(
                  hintText: 'New folder name',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: onSubmitted),
            trailing: IconButton(
              onPressed: () {
                onSubmitted(_folderNameController.text);
              },
              icon: const Icon(Icons.close),
            ),
          )
        : Center(
            child: GestureDetector(
              onTap: startAddingCategory,
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: 50,
                child: const Icon(Icons.create_new_folder),
              ),
            ),
          );
  }
}
