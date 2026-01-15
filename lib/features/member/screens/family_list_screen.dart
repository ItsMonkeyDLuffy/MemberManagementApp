import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/beneficiary_controller.dart';

class FamilyListScreen extends StatefulWidget {
  const FamilyListScreen({super.key});

  @override
  State<FamilyListScreen> createState() => _FamilyListScreenState();
}

class _FamilyListScreenState extends State<FamilyListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BeneficiaryController>().loadBeneficiaries();
    });
  }

  // Simple Dialog to Add Member
  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final relationController = TextEditingController();
    final aadhaarController = TextEditingController();
    final mobileController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Family Member"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: relationController,
              decoration: const InputDecoration(
                labelText: "Relation (e.g. Wife)",
              ),
            ),
            TextField(
              controller: aadhaarController,
              decoration: const InputDecoration(labelText: "Aadhaar No"),
            ),
            TextField(
              controller: mobileController,
              decoration: const InputDecoration(labelText: "Mobile No"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BeneficiaryController>().addFamilyMember(
                nameController.text,
                relationController.text,
                aadhaarController.text,
                mobileController.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<BeneficiaryController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Family Members")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.beneficiaries.isEmpty
          ? const Center(child: Text("No family members added yet."))
          : ListView.builder(
              itemCount: controller.beneficiaries.length,
              itemBuilder: (ctx, index) {
                final member = controller.beneficiaries[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(member.relation[0])),
                    title: Text(member.name),
                    subtitle: Text("${member.relation} | ${member.mobileNo}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.deleteMember(member.id!),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
