import 'package:flutter/material.dart';
import 'package:pf_care_front/model/enums/super_admin_functions_enum.dart';
import 'package:pf_care_front/model/globals/section_title.dart';
import 'package:pf_care_front/model/objects/volunteer_person_object.dart';
import '../../model/globals/chart/pie_chart_most_demanded_activities.dart';
import '../../model/globals/chart/pie_chart_patient_volunteers.dart';
import '../../model/globals/constants.dart'
    show  uriPatientWithoutValidateAndNotDeleted,
          uriVolunteerPersonWithoutValidateAndNotDeleted;
import '../../model/globals/logout.dart';
import '../../model/globals/requests/fetch_data_object.dart';
import '../../model/globals/selectable_super_admin_patient_list_tile.dart';
import '../../model/globals/selectable_super_admin_volunteer_person_list_tile.dart';
import '../../model/globals/tools/floating_message.dart';
import '../../model/objects/patient_object.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {

  SuperAdminFunctionsEnum? superAdminFunctionsEnum;
  final List<PatientObject> _patientsList = [];
  List<SelectableSuperAdminPatientListTile> _selectablePatientsList = [];
  //final List<SuperAdminReferenceCareObject> _referenceCareList = [];
  //List<SelectableSuperAdminReferenceCareListTile> _selectableReferenceCareList = [];
  final List<VolunteerPersonObject> _volunteerPersonList = [];
  List<SelectableSuperAdminVolunteerPersonListTile> _selectableVolunteerPersonList = [];

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(themeData.colorScheme),
        backgroundColor: Colors.black12,
        actions: [logout(context)],
      ),

      body: Column(
        children: [
          Expanded(child: _functionsSuperAdmin()),
        ],
      ),
    );
  }

  Widget _functionsSuperAdmin() {

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 20.0,),
          _buttonValidatePatient(),
          //const SizedBox(height: 10.0,),
          //_buttonValidateReferenceCare(),
          const SizedBox(height: 10.0,),
          _buttonValidateVolunteerPerson(),
          //const SizedBox(height: 10.0,),
          //_buttonValidateFormalCare(),
          const SizedBox(height: 10.0,),
          _buttonDashboard(),
          const SizedBox(height: 20,),
          _superAdminAction(),
          const SizedBox(height: 20,),
        ],
      ),
    );
  }

  Widget _buttonValidatePatient() {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            onPressed:() {
              superAdminFunctionsEnum = SuperAdminFunctionsEnum.validatePatient;
              _fillPatientWithoutValidateList();
            },
            child: const Text("Validar pacientes")
        ),
      );
  }

  Widget _buttonValidateReferenceCare() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed:() {
            superAdminFunctionsEnum = SuperAdminFunctionsEnum.validateReferenceCare;
            //_fillReferenceCareWithoutValidateList();
          },
          child: const Text("Validar cuidadores referentes")
      ),
    );
  }

  Widget _buttonValidateVolunteerPerson() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed:() {
            superAdminFunctionsEnum = SuperAdminFunctionsEnum.validateVolunteerPerson;
            _fillVolunteerPersonWithoutValidateList();
          },
          child: const Text("Validar personas voluntarias")
      ),
    );
  }

  Widget _buttonDashboard() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed:() {
            setState(() {
              superAdminFunctionsEnum = SuperAdminFunctionsEnum.dashboard;
            });
          },
          child: const Text("Resumen de datos")
      ),
    );
  }

  /*Widget _buttonValidateFormalCare() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed:() {
            superAdminFunctionsEnum = SuperAdminFunctionsEnum.validateFormalCare;
            //_fillVolunteerPersonWithoutValidateList();
          },
          child: const Text("Validar cuidadores formales")
      ),
    );
  }
   */

  Widget _superAdminAction() {
    switch (superAdminFunctionsEnum) {
      case SuperAdminFunctionsEnum.validatePatient:
        return _validatePatient();
      case SuperAdminFunctionsEnum.validateReferenceCare:
        //return _validateReferenceCare();
      case SuperAdminFunctionsEnum.validateFormalCare:
        return const SizedBox.shrink();
      case SuperAdminFunctionsEnum.validateVolunteerPerson:
        return _validateVolunteerPerson();
      default: return _dashboard();
    }
  }

  Widget _dashboard() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      padding: const EdgeInsets.only(right: 5.0),
      child: Column(
        children: [
          sectionTitle(
              themeData: Theme.of(context),
              title: "Resumen de datos semestral"
          ),
          const SizedBox(height: 20.0,),
          const Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              "Solicitudes Pacientes \u2192 Voluntarios",
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
            ),
          ),
          const PieChartPatientVolnteers(),
          const Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              "Actividades de voluntarios más contactados",
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
            ),
          ),
          const PieChartMostDemandVolunteerActivities(),
        ],
      ),
    );
  }

  Widget _validatePatient() {

    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        children: [
          sectionTitle(
              themeData: Theme.of(context),
              title: "Pacientes por validar"
          ),
          SizedBox(
            height: 400,
            child: ListView.builder(
              itemCount: _selectablePatientsList.length,
              itemBuilder: (context, index) {
                return _selectablePatientsList[index];
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _validateVolunteerPerson() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        children: [
          sectionTitle(
              themeData: Theme.of(context),
              title: "Voluntarios por validar"
          ),
          SizedBox(
            height: 400,
            child: ListView.builder(
              itemCount: _selectableVolunteerPersonList.length,
              itemBuilder: (context, index) {
                return _selectableVolunteerPersonList[index];
              },
            ),
          ),
        ],
      ),
    );
  }


  /*Widget _validateReferenceCare() {

    return SingleChildScrollView(
      child: Container(
        height: 400,
        margin: const EdgeInsets.only(left: 10.0, right: 10.0),
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: ListView.builder(
          itemCount: _selectableReferenceCareList.length,
          itemBuilder: (context, index) {
            return _selectableReferenceCareList[index];
          },
        ),
      ),
    );
  }*/

  Column _buildTitle(ColorScheme color) {
    return Column (
      children: [
        Text (
          "Super Administrador",
          style: TextStyle(
            color: color.primary,
          ),
        ),

        Text (
          "Bienvenido",
          style: TextStyle (
            color: color.secondary,
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  void _fillPatientWithoutValidateList() {
    _initializeLists();

    try {
      fetchDataObject <PatientObject> (
        uri: uriPatientWithoutValidateAndNotDeleted,
        classObject: PatientObject.empty(),
        departmentName: "DURAZNO",
        countryName: "URUGUAY",
      ).then((data) {
        setState(() {
          _patientsList.addAll(data.cast<PatientObject>()
              .map((e) =>
              PatientObject(
                  patientId: e.patientId,
                  name: e.name,
                  surname: e.surname,
                  gender: e.gender,
                  address: e.address,
                  telephone: e.telephone,
                  mail: e.mail,
                  dateBirth: e.dateBirth,
                  identificationDocument: e.identificationDocument,
                  healthProviderId: e.healthProviderId,
                  emergencyServiceId: e.emergencyServiceId,
                  residentialId: e.residentialId,
                  zone: e.zone,
                  registrationDate: e.registrationDate,
              )));
          // creo la lista seleccionable
          _selectablePatientsList = _patientsList.map((e) =>
              SelectableSuperAdminPatientListTile(
                  patient: e, isSelected: false)).toList();
        });
      });

    } catch (e) {
      floatingMessage(context, "Error de conexión");
    }
  }

  void _fillVolunteerPersonWithoutValidateList() {
    _initializeLists();

    try {
      fetchDataObject <VolunteerPersonObject> (
        uri: uriVolunteerPersonWithoutValidateAndNotDeleted,
        classObject: VolunteerPersonObject.empty(),
        departmentName: "DURAZNO",
        countryName: "URUGUAY",
      ).then((data) {
        setState(() {
          _volunteerPersonList.addAll(data.cast<VolunteerPersonObject>()
              .map((e) =>
              VolunteerPersonObject(
                id: e.id,
                name: e.name,
                surname: e.surname,
                registrationDate: e.registrationDate,
                gender: e.gender,
                address: e.address,
                dayTimeRange: e.dayTimeRange,
                dateBirth: e.dateBirth,
                identificationDocument: e.identificationDocument,
                mail: e.mail,
                telephone: e.telephone,
                contactMethods: e.contactMethods,
                interestZones: e.interestZones,
                training: e.training,
                experience: e.experience,
                reasonToVolunteer: e.reasonToVolunteer,
                volunteerActivitiesId: e.volunteerActivitiesId,
              )));
          // creo la lista seleccionable
          _selectableVolunteerPersonList = _volunteerPersonList.map((e) =>
              SelectableSuperAdminVolunteerPersonListTile(
                  volunteerPerson: e, isSelected: false)).toList();
        });
      });

    } catch (e) {
      floatingMessage(context, "Error de conexión");
    }
  }

  /*void _fillReferenceCareWithoutValidateList() {
    _referenceCareList.clear();
    _selectableReferenceCareList.clear();

    try {
      fetchDataObject <SuperAdminReferenceCareObject> (
        uri: uriVolunteerPersonWithoutValidateAndNotDeleted,
        object: SuperAdminReferenceCareObject.empty(),
        departmentName: "DURAZNO",
        countryName: "URUGUAY",
      ).then((data) {
        setState(() {
          _referenceCareList.addAll(data.cast<SuperAdminReferenceCareObject>()
              .map((e) =>
              SuperAdminReferenceCareObject(
                  id: e.id,
                  name: e.name,
                  surname: e.surname,
                  identificationDocument: e.identificationDocument
              )));
          // creo la lista seleccionable
          _selectableReferenceCareList = _referenceCareList.map((e) =>
              SelectableSuperAdminReferenceCareListTile(
                  referenceCare: e, isSelected: false)).toList();
        });
      });

    } catch (e) {
      floatingMessage(context, "Error de conexión");
    }
  }*/

  void _initializeLists() {
    _patientsList.clear();
    _selectablePatientsList.clear();
    _volunteerPersonList.clear();
    _selectableVolunteerPersonList.clear();
  }

}