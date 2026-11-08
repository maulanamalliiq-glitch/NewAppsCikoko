import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cikoko/main.dart' as app;
import 'package:cikoko/api.dart';
import 'package:cikoko/design_system.dart';
import 'package:cikoko/rt_rw_letters.dart';
import 'package:cikoko/v211_features.dart';
import 'package:cikoko/support_chat.dart';
import 'package:cikoko/about_cikoko_page.dart';
import 'package:cikoko/notifications_page.dart';
import 'package:cikoko/document_detail.dart';
import 'package:cikoko/waris_requirements.dart';

final user=<String,dynamic>{'id':'contoh-warga','role':'warga','name':'Warga Contoh','username':'warga.contoh','phone':'08xxxxxxxxxx','email':'warga@example.com','address':'Kelurahan Cikoko, Kecamatan Pancoran','rt':'01','rw':'02','nik':'','has_photo':false,'active':true};
final event=<String,dynamic>{'id':7001,'category':'progres_surat','audience':'personal','recipient':'contoh-warga','title':'Pengajuan diterima','message':'Permohonan Ahli Waris telah diterima untuk pemeriksaan.','is_read':0,'created_at':'2026-11-08 09:00:00','object_type':'waris','object_id':101};
Map<String,dynamic> fixture(String action){
 switch(action){
  case 'permissions':return {'ok':true,'capabilities':{'waris:create':true,'report:jumantik':true}};
  case 'home_slides':return {'ok':true,'slides':[]};
  case 'v211_profile':return {'ok':true,'user':user};
  case 'events':return {'ok':true,'events':[event]};
  case 'public_letter_status':return {'ok':true,'counts':{'masuk':1,'proses':0,'selesai':0},'items':[]};
  case 'integrated_services':return {'ok':true,'items':[{'id':'ptsp','title':'PTSP','description':'Layanan perizinan dan nonperizinan.','active':true,'url':'https://ptsp.jakarta.go.id/','logo_url':''},{'id':'dukcapil','title':'Dukcapil','description':'Administrasi kependudukan.','active':true,'url':'https://kependudukancapil.jakarta.go.id/','logo_url':''}]};
  case 'content':return {'ok':true,'items':[]};
  case 'history':return {'ok':true,'items':[{'id':101,'kind':'waris','reference':'AW-CONTOH-001','title':'Ahli Waris','status':'masuk','created_at':'2026-11-08 09:00:00'},{'id':102,'kind':'report','title':'jumantik','status':'proses','created_at':'2026-11-08 08:00:00'}]};
  case 'document_detail':return {'ok':true,'kind':'waris','detail':{'id':101,'reference_no':'AW-CONTOH-001','status':'masuk','applicant_name':'Warga Contoh','applicant_nik':'','applicant_phone':'08xxxxxxxxxx','applicant_address':user['address'],'relationship':'Anak','deceased_name':'Nama Pewaris (Contoh)','children':[],'created_at':'2026-11-08 09:00:00'},'timeline':[{'new_status':'masuk','notes':'Permohonan diterima untuk pemeriksaan.','created_at':'2026-11-08 09:00:00'}],'documents':[],'corrections':[],'labels':{},'can_review':false,'is_owner':true};
  case 'rt_rw_list':return {'ok':true,'items':[],'area':{'rt':'01','rw':'02'}};
  case 'chat':return {'ok':true,'messages':[{'id':1,'sender':'warga','message':'Selamat pagi, mohon informasi persyaratan Surat Ahli Waris.','created_at':'2026-11-08 09:00:00'},{'id':2,'sender':'admin','message':'Selamat pagi. Silakan buka Menu, kemudian pilih Persyaratan Ahli Waris.','created_at':'2026-11-08 09:01:00'}]};
  case 'v211_innovations':return {'ok':true,'items':[]};
  default:return {'ok':true,'items':[],'user':user};
 }
}
class DocsApi extends CikokoApi{
 DocsApi(){profile=user;token='illustration-only';}
 @override Future<Map<String,dynamic>> call(String action,{Map<String,dynamic>? body,bool authorized=false})async=>fixture(action.split('&').first);
 @override Future<Map<String,dynamic>> callWithParams(String action,Map<String,String> params)async=>fixture(action);
}
class DocsHeaders extends Fake implements HttpHeaders{
 @override void set(String name,Object value,{bool preserveHeaderCase=false}){}
 @override void forEach(void Function(String,List<String>) action){action('content-type',['application/json']);}
 @override String? value(String name)=>name=='content-type'?'application/json':null;
}
class DocsResponse extends Stream<List<int>> implements HttpClientResponse{
 final List<int> bytes;DocsResponse(this.bytes);
 @override int get statusCode=>200;
 @override int get contentLength=>bytes.length;
 @override bool get isRedirect=>false;
 @override bool get persistentConnection=>false;
 @override String get reasonPhrase=>'OK';
 @override HttpHeaders get headers=>DocsHeaders();
 @override List<RedirectInfo> get redirects=>[];
 @override HttpClientResponseCompressionState get compressionState=>HttpClientResponseCompressionState.notCompressed;
 @override StreamSubscription<List<int>> listen(void Function(List<int>)? onData,{Function? onError,void Function()? onDone,bool? cancelOnError})=>Stream.value(bytes).listen(onData,onError:onError,onDone:onDone,cancelOnError:cancelOnError);
 @override dynamic noSuchMethod(Invocation invocation)=>super.noSuchMethod(invocation);
}
class DocsRequest extends Fake implements HttpClientRequest{
 final Uri uri;DocsRequest(this.uri);
 @override HttpHeaders get headers=>DocsHeaders();
 @override Future<void> addStream(Stream<List<int>> stream)async{await stream.drain<void>();}
 @override Future<HttpClientResponse> close()async=>DocsResponse(utf8.encode(jsonEncode(fixture(uri.queryParameters['action']??''))));
}
class DocsClient extends Fake implements HttpClient{
 @override Future<HttpClientRequest> openUrl(String method,Uri uri)async=>DocsRequest(uri);
 @override Future<HttpClientRequest> getUrl(Uri uri)async=>DocsRequest(uri);
 @override void close({bool force=false}){}
}
class DocsOverrides extends HttpOverrides{
 @override HttpClient createHttpClient(SecurityContext? context)=>DocsClient();
}
void main(){
 testWidgets('Capture real resident widgets with illustrative data only',(tester)async{
  tester.view.physicalSize=const Size(450,1000);tester.view.devicePixelRatio=1;
  HttpOverrides.global=DocsOverrides();
  await tester.runAsync(()async{
   final loader=FontLoader('Roboto');
   for(final path in ['test_assets/Roboto-Regular.ttf','test_assets/Roboto-Bold.ttf']){
    if(File(path).existsSync())loader.addFont(Future.value(ByteData.sublistView(await File(path).readAsBytes())));
   }
   await loader.load();
  });
  final key=GlobalKey();
  final fake=DocsApi();
  app.api.profile=user;app.api.token='illustration-only';
  Future<void> mount(Widget child)async{
   await tester.pumpWidget(const SizedBox());await tester.pump();
   await tester.pumpWidget(RepaintBoundary(key:key,child:MaterialApp(debugShowCheckedModeBanner:false,theme:CikokoDesign.light,home:child)));
   await tester.pumpAndSettle(const Duration(milliseconds:100));
  }
  Future<void> shot(String name)async{await expectLater(find.byKey(key),matchesGoldenFile('screens/$name.png'));}
  Future<void> scrollTo(String text)async{await tester.scrollUntilVisible(find.text(text).first,600,maxScrolls:45);await Scrollable.ensureVisible(tester.element(find.text(text).first),alignment:0);await tester.pumpAndSettle();}
  await mount(app.LoginPage(onLogin:(){}));await shot('01_masuk');
  await mount(app.LoginPage(onLogin:(){},startWithRegistration:true));await shot('02_daftar_atas');
  await tester.drag(find.byType(SingleChildScrollView).first,const Offset(0,-620));await tester.pumpAndSettle();await shot('03_daftar_bawah');
  await mount(app.HomePage(onLogout:(){},onAuthenticated:(){}));await shot('04_beranda');
  await tester.tap(find.byType(NavigationDestination).at(1));await tester.pumpAndSettle();await shot('05_menu');
  await tester.tap(find.byType(NavigationDestination).at(4));await tester.pumpAndSettle();await shot('06_profil');
  await mount(Scaffold(appBar:AppBar(title:const Text('Profil')),body:CivicProfilePage(api:fake)));
  // Open the actual edit form through its own button.
  final edit=find.text('Pengaturan profil');
  if(edit.evaluate().isNotEmpty){await tester.ensureVisible(edit.first);await tester.tap(edit.first);await tester.pumpAndSettle();}
  await shot('07_profil_data');
  await mount(Scaffold(appBar:AppBar(title:const Text('Surat Pengantar RT/RW')),body:RtRwLettersPage(api:fake)));await shot('08_surat_rt_rw');
  await tester.drag(find.byType(ListView).first,const Offset(0,-750));await tester.pumpAndSettle();await shot('09_surat_rt_rw_bawah');
  await mount(const Scaffold(body:app.WarisForm()));await shot('10_waris_identitas');
  await scrollTo('02 · Foto Persyaratan Wajib');await shot('11_waris_dokumen');
  await scrollTo('03 · Dua Orang Saksi');await shot('12_waris_saksi');
  await scrollTo('05 · Data Anak');await shot('13_waris_anak');
  await tester.drag(find.byType(ListView).first,const Offset(0,-1300));await tester.pumpAndSettle();await shot('14_waris_kirim');
  await mount(const Scaffold(body:app.ReportForm(kind:'jumantik')));await shot('15_laporan_jumantik');
  await mount(const Scaffold(body:app.HistoryPage()));await shot('16_riwayat');
  await mount(Scaffold(body:DocumentDetailSheet(api:fake,id:101,kind:'waris',reference:'AW-CONTOH-001')));await shot('17_detail_pengajuan');
  await mount(Scaffold(body:CikokoNotificationsPage(events:[event],onOpen:(_){})));await shot('18_notifikasi');
  await mount(Scaffold(body:SupportChatPage(api:fake)));await shot('19_chat');
  await mount(const Scaffold(body:CikokoAboutPage()));await shot('20_tentang_kami');
  await mount(Scaffold(body:Builder(builder:(context)=>FilledButton(onPressed:()=>showCikokoWarisRequirements(context,onApply:(){}),child:const Text('Buka')))));
  await tester.tap(find.text('Buka'));await tester.pumpAndSettle();await shot('21_persyaratan');
  await tester.pumpWidget(const SizedBox());await tester.pump();
  tester.view.resetPhysicalSize();tester.view.resetDevicePixelRatio();HttpOverrides.global=null;
 });
}
