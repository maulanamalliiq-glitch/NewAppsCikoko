import 'package:flutter/material.dart';
import 'premium_ui.dart';

const _headingColor = Color(0xff10375f);
const _actionColor = Color(0xff226fda);

class WarisRequirementCategory {
  final String title;
  final List<String> requirements;
  final bool allowApply;
  const WarisRequirementCategory(this.title,this.requirements,{this.allowApply=false});
}

/// Informational checklist only. No user documents are loaded or submitted.
const cikokoWarisRequirements = <WarisRequirementCategory>[
  WarisRequirementCategory('Ahli Waris',[
    'Asli dan Foto KTP Pemohon',
    'Asli dan Foto KK Pemohon',
    'Asli dan Foto Surat Pengantar RT RW',
    'Asli dan Foto Surat atau Akta Kematian',
    'Asli dan Foto Buku Nikah',
    'Asli dan Foto KTP Para Ahli Waris',
    'Asli dan Foto KK Para Ahli Waris',
    'Asli dan Foto Akta Lahir Para Ahli Waris',
    'Asli dan Foto KTP 2 Orang Saksi',
  ],allowApply:true),
  WarisRequirementCategory('Surat Permohonan Hak atas Negara',[
    'Asli dan Foto KTP Pemohon',
    'Asli dan Foto KK Pemohon',
    'Asli dan Foto Surat atau Dokumen Asal Usul Tanah',
    'Asli dan Foto Pernyataan dan Hibah Waris Jika Tanah Warisan',
    'Asli dan Foto SPPT PBB Tahun Berjalan dan Bukti Pelunasan',
    'Asli dan Foto Surat Batar Rumah Pemohon',
    'Asli dan Foto KTP 2 Orang Saksi',
  ]),
  WarisRequirementCategory('Surat Peningkatan Hak dari SHGB ke SHM',[
    'Asli dan Foto KTP Pemohon',
    'Asli dan Foto KK Pemohon',
    'Asli dan Foto Sertifikat Tanah SHGB',
    'Asli dan Foto Surat SPPT PBB Tahun Berjalan dan Bukti Pelunasan',
    'Asli dan Foto Rumah',
    'Asli dan Foto Plang Rumah',
    'Asli dan Foto Surat Kuasa Asli dan KTP Penerima Kuasa (Jika dikuasakan)',
    'Asli dan Foto KTP 2 Orang Saksi',
    'Asli dan Foto Surat Pengantar RT RW',
  ]),
];

Future<void> showCikokoWarisRequirements(
  BuildContext context, {required VoidCallback onApply}
) {
  return showGeneralDialog<void>(
    context:context,
    barrierDismissible:true,
    barrierLabel:'Tutup Persyaratan Ahli Waris',
    barrierColor:Colors.black54,
    transitionDuration:const Duration(milliseconds:260),
    pageBuilder:(popup,_,__)=>Align(
      alignment:Alignment.centerRight,
      child:ConstrainedBox(
        constraints:const BoxConstraints(maxWidth:680),
        child:SizedBox(
          width:MediaQuery.sizeOf(popup).width*.94,
          height:double.infinity,
          child:Material(
            color:Theme.of(popup).colorScheme.surface,
            elevation:14,
            child:SafeArea(child:Column(children:[
              Padding(padding:const EdgeInsets.fromLTRB(12,12,12,4),
                child:CikokoPremiumHeader(
                  title:'Persyaratan Pelayanan Surat',
                  subtitle:'Dokumen resmi sebelum mengajukan layanan.',
                  icon:Icons.fact_check_outlined,
                  trailing:IconButton(
                    tooltip:'Tutup',
                    onPressed:()=>Navigator.of(popup).pop(),
                    icon:const Icon(Icons.close_rounded,color:Colors.white)),
                )),
              Expanded(child:ListView(
                padding:const EdgeInsets.fromLTRB(12,14,12,24),
                children:[
                  Text('Siapkan dokumen yang sesuai dan terbaca sebelum mengajukan layanan.',
                    style:TextStyle(fontSize:12,
                      color:Theme.of(popup).colorScheme.onSurfaceVariant)),
                  const SizedBox(height:12),
                  for(final group in cikokoWarisRequirements)
                    Card(margin:const EdgeInsets.only(bottom:14),child:Padding(
                      padding:const EdgeInsets.all(12),child:Column(
                      crossAxisAlignment:CrossAxisAlignment.start,children:[
                        Text('Persyaratan ${group.title}',
                          style:TextStyle(fontWeight:FontWeight.w800,
                            color:Theme.of(popup).colorScheme.onSurface,fontSize:14)),
                        const SizedBox(height:10),
                        for(var i=0;i<group.requirements.length;i++)
                          Container(
                            margin:const EdgeInsets.only(bottom:7),
                            padding:const EdgeInsets.fromLTRB(9,10,9,10),
                            decoration:BoxDecoration(
                              color:Theme.of(popup).colorScheme.surfaceContainerLow,
                              borderRadius:BorderRadius.circular(12),
                              border:Border.all(
                                color:Theme.of(popup).colorScheme.outlineVariant)),
                            child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
                              Container(
                                width:25,height:25,
                                alignment:Alignment.center,
                                decoration:BoxDecoration(
                                  color:Theme.of(popup).colorScheme.primaryContainer,
                                  shape:BoxShape.circle),
                                child:Text('${i+1}',
                                  style:TextStyle(
                                    color:Theme.of(popup).colorScheme.primary,
                                    fontSize:11,fontWeight:FontWeight.w800)),
                              ),
                              const SizedBox(width:10),
                              Expanded(child:Text(group.requirements[i],
                                style:TextStyle(
                                  color:Theme.of(popup).colorScheme.onSurface,
                                  fontSize:11.8,height:1.4))),
                            ]),
                          ),
                        if(group.allowApply)...[
                          const SizedBox(height:12),
                          SizedBox(width:double.infinity,child:FilledButton.icon(
                            icon:const Icon(Icons.edit_note),
                            label:const Text('Ajukan Surat'),
                            onPressed:(){
                              Navigator.of(popup).pop();
                              WidgetsBinding.instance.addPostFrameCallback((_)=>onApply());
                            },
                          )),
                        ],
                      ]))),
                ])),
            ])),
          ),
        ),
      ),
    ),
    transitionBuilder:(ctx,animation,secondary,child)=>SlideTransition(
      position:Tween<Offset>(begin:const Offset(1,0),end:Offset.zero)
        .animate(CurvedAnimation(parent:animation,curve:Curves.easeOutCubic)),
      child:child,
    ),
  );
}
