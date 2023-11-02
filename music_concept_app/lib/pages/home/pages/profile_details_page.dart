import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class ProfileDetailsPage extends StatelessWidget {
  final FdSnapshot? guest;
  const ProfileDetailsPage({super.key, this.guest});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Get.find<ProfileCtrl>().getAccountStream(
          guest?.reference.path,
        ),
        initialData: guest,
        builder: (context, snapshot) {
          var name = snapshot.data?.data()?['name'] ?? "***********";
          List<String> academicStudies =
              snapshot.data?.data()?['academicStudies']?.cast<String>() ?? [];
          String? status = snapshot.data?.data()?['maritalStatus'];
          return Scaffold(
            appBar: AppBar(
              title: Text("Perfil de $name"),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderTitle(
                    title: "Estudios realizados",
                  ),
                  if (academicStudies.isNotEmpty)
                    ...academicStudies.map(
                      (e) =>
                          _academicStudyItem(initialValue: e, canDelete: true),
                    ),
                  if (academicStudies.isEmpty) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      "No hay estudios realizados",
                      style: TextStyle(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                  ],
                  if (guest == null) _academicStudyItem(),
                  _buildHeaderTitle(
                    title: "Estado Civil",
                  ),
                  const SizedBox(height: 8.0),
                  if (status != null) _buildMaritalStatus(status),
                  if (status == null)
                    Text(
                      "No hay estado civil",
                      style: TextStyle(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          );
        });
  }

  DropdownButtonFormField<String> _buildMaritalStatus(String status) {
    return DropdownButtonFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Get.theme.colorScheme.onBackground,
          prefixIcon: Icon(
            Icons.male,
            color: Get.theme.colorScheme.primary,
          ),
          labelStyle: TextStyle(
            color: Colors.grey[500],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none,
          ),
        ),
        value: status,
        items: [
          'Casado',
          'Soltero',
          'Viudo',
          'Divorciado',
          'Conviviente',
          'Unión Libre',
        ]
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            Get.find<ProfileCtrl>().changeMaritalStatus(
              value: value.toString(),
              accountRef: guest?.reference.path,
            );
          }
        });
  }

  SizedBox _academicStudyItem({
    String? initialValue,
    bool canDelete = false,
  }) {
    String currentValue = initialValue ?? "";
    TextEditingController? controller;
    return SizedBox(
      height: 80.0,
      child: Row(
        children: [
          Expanded(
            child: LoginRoundedTextField(
              label: "Nuevo ",
              initialValue: currentValue,
              icon: Icons.school,
              onControllingText: (ctrl) {
                controller = ctrl;
              },
              onChanged: guest != null || canDelete
                  ? null
                  : (value) {
                      currentValue = value;
                    },
            ),
          ),
          if (guest == null) ...[
            const SizedBox(width: 8.0),
            _buildButtonAction(
              onTap: () {
                if (currentValue.isEmpty) return;
                if (canDelete) {
                  Get.find<ProfileCtrl>().removeAcademicStudy(currentValue);
                } else {
                  controller?.clear();
                  Get.find<ProfileCtrl>().addAcademicStudy(currentValue);
                }
              },
              icon: !canDelete ? Icons.add : Icons.delete,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButtonAction({
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55.0,
        height: 55.0,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.onBackground,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.grey[800]!,
            width: 1.0,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.grey[500]!,
        ),
      ),
    );
  }

  Text _buildHeaderTitle({
    required String title,
  }) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
      ),
    );
  }
}
