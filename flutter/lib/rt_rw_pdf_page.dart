import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'api.dart';

class RtRwPdfPage extends StatefulWidget {
  final CikokoApi api;
  final int id;
  const RtRwPdfPage({super.key,required this.api,required this.id});
  @override State<RtRwPdfPage> createState()=>_RtRwPdfPageState();
}
class _RtRwPdfPageState extends State<RtRwPdfPage> {
  late Future<Uint8List> file;
  String get fileName=>'Surat-Pengantar-Cikoko-${widget.id}.pdf';
  @override void initState(){super.initState();file=fetch();}
  Future<Uint8List> fetch() async {
    final url=Uri.parse('${CikokoApi.root}?action=rt_rw_pdf&id=${widget.id}');
    final response=await http.get(url,headers:widget.api.authHeaders())
      .timeout(const Duration(seconds:45));
    if(response.statusCode!=200 || !(response.headers['content-type']??'').contains('application/pdf')) {
      String message='Surat PDF belum dapat dibuka. Pastikan verifikasi RT dan RW telah selesai.';
      try{final data=jsonDecode(utf8.decode(response.bodyBytes));if(data is Map && data['error']!=null)message='${data['error']}';}catch(_){}
      throw ApiError(message);
    }
    final bytes=response.bodyBytes;
    if(bytes.length<100 || utf8.decode(bytes.take(4).toList())!='%PDF')
      throw ApiError('Isi berkas bukan PDF yang valid.');
    return bytes;
  }
  Future<void> savePdf(BuildContext context) async {
    try {
      final bytes=await file;
      final directory=await getDownloadsDirectory();
      if(directory==null)throw const FileSystemException('Folder unduhan tidak tersedia');
      final output=File('${directory.path}/$fileName');
      await output.writeAsBytes(bytes,flush:true);
      if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:const Text('Dokumen PDF berhasil disimpan.')));
    }catch(_) {
      if(!context.mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:Text('Penyimpanan langsung tidak tersedia. Pilih Simpan melalui menu berbagi PDF.')));
      try{await Printing.sharePdf(bytes:await file,filename:fileName);}catch(_){}
    }
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Surat Pengantar PDF')),
    body:FutureBuilder<Uint8List>(future:file,builder:(ctx,s){
      if(!s.hasData) {
        if(s.hasError)return Center(child:Padding(padding:const EdgeInsets.all(18),child:Column(
          mainAxisSize:MainAxisSize.min,children:[
            Text(cikokoFormalMessage(s.error),textAlign:TextAlign.center),
            const SizedBox(height:12),
            FilledButton(onPressed:()=>setState(()=>file=fetch()),
              child:const Text('Muat Ulang')),
          ])));
        return const Center(child:CircularProgressIndicator());
      }
      return PdfPreview(
        build:(format)async=>s.data!,
        initialPageFormat:PdfPageFormat.a4,
        canChangeOrientation:false,
        canChangePageFormat:false,
        allowPrinting:false,
        allowSharing:true,
        pdfFileName:fileName,
        actions:[
          IconButton(
            tooltip:'Simpan berkas PDF',
            onPressed:()=>savePdf(context),
            icon:const Icon(Icons.download_outlined),
          ),
        ],
      );
    }),
  );
}
