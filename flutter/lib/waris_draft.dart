import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Account-scoped draft; metadata is in encrypted storage and photos stay in
/// application-private storage, excluded from Android backups.
class WarisDraftStore {
  final String accountId;
  final FlutterSecureStorage storage;
  final Future<Directory> Function() directory;
  WarisDraftStore(this.accountId,{this.storage=const FlutterSecureStorage(),this.directory=getApplicationSupportDirectory});
  String get key=>'waris_draft_${base64Url.encode(utf8.encode(accountId))}';
  Future<Map<String,dynamic>?> read() async {
    if(accountId.isEmpty)return null;
    final raw=await storage.read(key:key);
    if(raw==null)return null;
    return Map<String,dynamic>.from(jsonDecode(raw) as Map);
  }
  Future<void> save(Map<String,dynamic> values,Map<String,List<String>> files) async {
    if(accountId.isEmpty)return;
    final folder=Directory('${(await directory()).path}/$key');
    await folder.create(recursive:true);
    final copied=<String,List<String>>{};
    for(final entry in files.entries){
      if(!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(entry.key))continue;
      final paths=<String>[];
      for(var i=0;i<entry.value.length;i++){
        final source=File(entry.value[i]);if(!await source.exists())continue;
        final target='${folder.path}/${entry.key}_$i.photo';
        if(source.path!=target){
          final pending=await source.copy('$target.pending');
          await pending.rename(target);
        }
        paths.add(target);
      }
      copied[entry.key]=paths;
    }
    await storage.write(key:key,value:jsonEncode({...values,'files':copied,'saved_at':DateTime.now().toIso8601String()}));
  }
  Future<void> clear() async {
    await storage.delete(key:key);
    final folder=Directory('${(await directory()).path}/$key');
    if(await folder.exists())await folder.delete(recursive:true);
  }
}
