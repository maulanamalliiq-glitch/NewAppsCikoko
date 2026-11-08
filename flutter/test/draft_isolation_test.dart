import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cikoko/waris_draft.dart';

void main(){
 TestWidgetsFlutterBinding.ensureInitialized();
 test('Draft copies temporary photos, restores reference, and isolates accounts',()async{
  FlutterSecureStorage.setMockInitialValues({});
  final root=await Directory.systemTemp.createTemp('cikoko-draft-test');
  try{
   final image=File('${root.path}/selected.jpg');await image.writeAsBytes([1,2,3,4]);
   final a=WarisDraftStore('citizen/a',directory:()async=>root),b=WarisDraftStore('citizen/b',directory:()async=>root);
   await a.save({'inputs':{'name':'Contoh'},'reference':'AW-EXAMPLE'},{'saksi_1':[image.path]});
   await image.delete();final restored=await a.read();
   expect(restored!['reference'],'AW-EXAMPLE');
   expect(await File((restored['files']['saksi_1'] as List).first as String).readAsBytes(),[1,2,3,4]);
   expect(await b.read(),isNull);
   await b.save({'inputs':{'name':'Other'}},{});await a.clear();expect(await a.read(),isNull);expect((await b.read())!['inputs']['name'],'Other');
  }finally{await root.delete(recursive:true);}
 });
}
