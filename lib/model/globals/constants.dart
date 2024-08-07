//const String socket = "192.168.1.8:8080";       //casa
//const String socket = "192.168.43.203:8080";    //celu

const String socket = 'localhost:8080';           //server applications
const String socketNovaDaily = 'novateksoluciones.dyndns.org:9091'; //server NovaDaily

const int timeOutSecondsResponse = 15;
const int sizePageCustomerList = 20;
const int sizePageVoucherListOfCustomer = 8;
const int sizePageVoucherListOfSupplier = 8;
const int sizePageMedicineAndPresentationList = 10;

const String defaultFirstOption = "Seleccione...";
const String defaultLastOption = "Nuevo...";
const double menuMaxHeight = 300.0;
const double menuMaxWeight = 300.0;

const String imagesPath = "assets/images/";

//Credenciales SuperAdmin
const String superAdminUser = "N0v4Tek.2o24";
const String superAdminPass = "n0vaF4rm4!";

//Tokens
const String novaDailyToken = "ghcP1cfRITkveIikA3v1fRLVhnoKzuXK5Al7k0qCkvNyMeZI1nH1A19CwLuSCHnT3X3DYU2DvfaKnJbp1lZEVXNV0TpjWIzZrAqOTjxcPDxaDInIsdPkLi8QGHfgrQaU3ZIa8sLapH7qgyWU8eIn5AXiXcn5cRVbfh44mljLZr5jvgmtGmvW2CMUHzdrWfxCzNoUQgP6XECm2f3ShGJjXDyjkJOLYaS9fNAamqqqVBm";

//
// EndPoints
//

//Role
const String uriRoleAdd = "/role/add";
const String uriRoleUpdate = "/role/update";
const String uriRoleDelete = "/role/delete";
const String uriRoleFindAll = "/role/findAll";
const String uriRoleFindId = "/role/findId";

//User
const String uriUserAdd = "/user/add";
const String uriUserFindAll = "/user/findAll";
const String uriUserFindId = "/user/findId";
const String uriUserNameExist = "user/userNameExist";

//Customer
const String uriCustomerFindAll = "/customer/findAll";
const String uriCustomerFindAllPage = "/customer/findAllPage";
const String uriCustomerFindDocument = "/customer/findDocument";
const String uriCustomerFindLastnameName = "/customer/findLastnameName";
const String uriCustomerFindPaymentNumber = "/customer/findPaymentNumber";
const String uriCustomerAdd = "/customer/add";
const String uriCustomerUpdate = "/customer/update";
const String uriCustomerDelete = "/customer/delete";
const String uriCustomerFindControlledMedications = "/customer/findControlledMedications";
const String uriCustomerFindVouchersPage = "/customer/findVouchers";

//NovaDaily
const String uriNovaDailyFindPartnerDocument = '/socio/cedula';
    //'/socio/cedula?apiToken=$novaDailyToken&cedula';
const String uriNovaDailyFindPartnerLastname = '/socio/apellido';
    //'/socio/apellido?apiToken=$novaDailyToken&apellido';

//Supplier
const String uriSupplierFindAll = "/supplier/findAll";
const String uriSupplierFindName = "/supplier/findName";
const String uriSupplierFindVouchers = "/supplier/findVouchers";
const String uriSupplierAdd = "/supplier/add";
const String uriSupplierUpdate = "/supplier/update";
const String uriSupplierDelete = "/supplier/delete";

//Medicine
const String uriMedicineFindBarCode = "/medicine/findBarCode";
const String uriMedicineAdd = "/medicine/add";
const String uriMedicineUpdate = "/medicine/update";
const String uriMedicineFindNamePage ="/medicine/findNamePage";

//Voucher
const String uriVoucherAdd = "/voucher/add";
const String uriVoucherFindVoucherItems = "/voucher/findVoucherItems";

//Controlled Medication
const String uriDateAuthorizationSale = "controlledMedication/dateAuthorizationSale";
const String uriControlledMedicationAdd = "/controlledMedication/add";

//Presentations
const String uriPresentationGetId = "/presentation/getId";
const String uriPresentationFindName = "presentation/findName";
const String uriPresentationFindAll = "presentation/findAll";
const String uriPresentationAdd = "presentation/add";
const String uriPresentationUpdate = "presentation/update";

//Units
const String uriUnitFindAll = "/unit/findAll";
const String uriUnitAdd = "/unit/add";
const String uriUnitUpdate = "unit/update";

