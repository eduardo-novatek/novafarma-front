//const String socket = "192.168.1.8:8080";       //casa
//const String socket = "192.168.43.203:8080";    //celu

const String host = 'localhost';
const int port = 8080;
const String socket = '$host:$port';
const String hostNovaDaily = 'novateksoluciones.dyndns.org';
const int portNovaDaily = 9091;
//const String uriDockerNovaDaily = ''; //Habilitar en caso de solucionar CORS en backend
const String uriProxyCORSNovaDaily = 'http://localhost:8081/'; //Habilitar en caso de no solucionar CORS en backend

//Tokens
const String novaDailyToken = "ghcP1cfRITkveIikA3v1fRLVhnoKzuXK5Al7k0qCkvNyMeZI1nH1A19CwLuSCHnT3X3DYU2DvfaKnJbp1lZEVXNV0TpjWIzZrAqOTjxcPDxaDInIsdPkLi8QGHfgrQaU3ZIa8sLapH7qgyWU8eIn5AXiXcn5cRVbfh44mljLZr5jvgmtGmvW2CMUHzdrWfxCzNoUQgP6XECm2f3ShGJjXDyjkJOLYaS9fNAamqqqVBm";

const int timeOutSecondsResponse = 15;
const int sizePageCustomerList = 20;
const int sizePageCustomerNursingReportList = 10000; // Se muestra en 1 sola pagina
const int sizePageMedicineList = 20;
const int sizePageMedicineStockMovements = 20;
const int sizePagePresentationList = 20;
const int sizePageVoucherListOfCustomer = 8;
const int sizePageVoucherListOfSupplier = 8;
const int sizePageMedicineAndPresentationList = 8;

const String defaultFirstOption = "Seleccione...";
const String defaultLastOption = "Nuevo...";
const double menuMaxHeight = 300.0;

const String imagesPath = "assets/images/";

//Credenciales SuperAdmin
const String superAdminUser = "N0v4Tek.2o24";
const String superAdminPass = "n0vaF4rm4!";

//
// EndPoints
//

//NovaDaily
const String uriNovaDailyFindPartnerDocument = '/socio/cedula';
const String uriNovaDailyFindPartnerLastname = '/socio/apellido';
const String uriNovaDailyFindDependentDocument = '/dependiente/cedula';
const String uriNovaDailyFindDependentLastname = '/dependiente/apellido';

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
const String uriUserNameExist = "/user/userNameExist";
const String uriUserLogin = "user/login";
const String uriUserChangePass = "user/changePass";

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
const String uriCustomerNursingReportPage = "/customer/nursingReport";

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
const String uriMedicineDelete = "/medicine/delete";
const String uriMedicineFindNamePage ="/medicine/findNamePage";
const String uriMedicineFindAll ="/medicine/findAll";
const String uriMedicineFindStockMovements ="/medicine/findStockMovements";

//Voucher
const String uriVoucherAdd = "/voucher/add";
const String uriVoucherFindVoucherItems = "/voucher/findVoucherItems";

//Controlled Medication
const String uriDateAuthorizationSale = "/controlledMedication/dateAuthorizationSale";
const String uriControlledMedicationAdd = "/controlledMedication/add";

//Presentations
const String uriPresentationGetId = "/presentation/getId";
const String uriPresentationFindName = "/presentation/findName";
const String uriPresentationFindNameOnly = "/presentation/findNameOnly";
const String uriPresentationFindQuantities = "/presentation/findQuantities";
const String uriPresentationFindAll = "/presentation/findAll";
const String uriPresentationAdd = "/presentation/add";
const String uriPresentationUpdate = "/presentation/update";
const String uriPresentationDelete = "/presentation/delete";

//Units
const String uriUnitFindAll = "/unit/findAll";
const String uriUnitFindNameLike = "/unit/findNameLike";
const String uriUnitAdd = "/unit/add";
const String uriUnitUpdate = "/unit/update";
const String uriUnitDelete = "/unit/delete";

