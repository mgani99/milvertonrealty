
import 'package:flutter/cupertino.dart';
import 'package:googleapis/cloudsearch/v1.dart';
import 'package:intl/intl.dart';
import 'package:milvertonrealty/common/domain/common.dart';
import 'package:milvertonrealty/common/model/common_model.dart';
import 'package:milvertonrealty/propertysetup/model/property_and_unit.dart';

class PropertySetupController with ChangeNotifier {
  //property setup
  TextEditingController propNameController = TextEditingController();
  TextEditingController propAddressController = TextEditingController();

//unit setup
  TextEditingController bedroomController = TextEditingController();
  TextEditingController bathroomController = TextEditingController();
  TextEditingController sqrFeetController = TextEditingController();
  PropertyUnitModel model = PropertyUnitModel();
  List<Map<String, dynamic>> unitData= [];
  DateFormat dateFormat = DateFormat("dd-MM-yyyy");
  @override
  void dispose() {
    propNameController.dispose();
    propAddressController.dispose();
    bedroomController.dispose();
    bathroomController.dispose();
    sqrFeetController.dispose();
    super.dispose();
  }

  void saveProperty(List<Map<String, dynamic>> _unitsData, BuildContext context) {

    // 'unitNumber': '',
    // 'tenantName': '',
    // 'rent': '',
    // 'isVacant': false,
    // 'isMonthToMonth' : false,
    // 'isYearly' : true


    List<int> unitIds = [];

    _unitsData.forEach((element) {
      String unitNumber = element['unitNumber'];
      var tenantName = element['tenantName'];
      bool isVacant = element['isVacant'] ?? false;
      double rent = element['rent'] ?? 0.0;
      String leaseStartDate = element['leaseStartDate'] ?? dateFormat.format(DateTime.now());
      String leaseEndDate = element['leaseEndDate'] ??dateFormat.format(DateTime.now());
      //bool isVacant = element['isVacant'] ?? false;
      bool isMonthToMonth = element['isMonthToMonth'] ?? false;
      bool isYearly = element['isYearly'] ?? !isMonthToMonth;



      int tenantId =0;
      if(isVacant) {
        leaseStartDate = dateFormat.format(DateTime(2025, 4, 14));//closing date
        leaseEndDate = dateFormat.format(DateTime(2030, 4,1));
        rent = 0.0;

      }
      else {
        tenantId = tenantName
            .toString()
            .hashCode + unitNumber
            .toString()
            .hashCode + DateTime
            .now()
            .hashCode;
        Tenant tenant = Tenant(tenantId, element['tenantName'], "", "", "");
        model.addObject(tenant);
      }

      LeaseDetails ld = LeaseDetails(unitNumber.hashCode + rent.hashCode + DateTime.now().hashCode, leaseStartDate,
          leaseEndDate, [tenantId], rent, 0.0);
       // leaseId= ld.id;
        ld.isYearly = isYearly;
        ld.isVacant = isVacant;
        model.addObject(ld);

      Unit aUnit = Unit(unitNumber.hashCode, "Apartment", [], ld.id, unitNumber);

      model.addObject(aUnit);
      unitIds.add(aUnit.id);


    });
    Property prop = Property(propNameController.text.trim().hashCode,name: propNameController.text.trim(),
        address: propAddressController.text.trim(), unitIds: unitIds, propertyType: "Apartment");
    model.addObject(prop);
  }

  Future<void> getProperty()  async{
     unitData = await model.getAllUnitsInJson();
    notifyListeners();
  }

}