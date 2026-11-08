import 'package:flutter/material.dart';

/// Status is emitted by the authenticated API, not guessed from message age.
enum CikokoChatDelivery { pending, sent, delivered, read, legacyRead, failed }

CikokoChatDelivery cikokoChatDelivery(String? value) => switch (value) {
  'pending' => CikokoChatDelivery.pending,
  'delivered' => CikokoChatDelivery.delivered,
  'read' => CikokoChatDelivery.read,
  'read_legacy' => CikokoChatDelivery.legacyRead,
  'failed' => CikokoChatDelivery.failed,
  _ => CikokoChatDelivery.sent,
};

class CikokoChatReceiptIndicator extends StatelessWidget {
  final String status;
  const CikokoChatReceiptIndicator({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    final value=cikokoChatDelivery(status);
    if(value==CikokoChatDelivery.failed) {
      return Tooltip(message:'Pesan gagal dikirim',child:Icon(
        Icons.error_outline_rounded,size:15,color:Theme.of(context).colorScheme.error));
    }
    final isRead=value==CikokoChatDelivery.read || value==CikokoChatDelivery.legacyRead;
    final isDouble=value==CikokoChatDelivery.delivered || value==CikokoChatDelivery.read;
    final color=isRead?Colors.green.shade700:Theme.of(context).colorScheme.outline;
    final tooltip=switch(value){
      CikokoChatDelivery.pending=>'Sedang mengirim',
      CikokoChatDelivery.sent=>'Terkirim ke server',
      CikokoChatDelivery.delivered=>'Tersampaikan ke aplikasi penerima',
      CikokoChatDelivery.legacyRead=>'Dibaca (konfirmasi lama)',
      CikokoChatDelivery.read=>'Dibaca penerima',
      CikokoChatDelivery.failed=>'Gagal dikirim',
    };
    return Tooltip(
      message:tooltip,
      child:Semantics(
        label:tooltip,
        child:Row(mainAxisSize:MainAxisSize.min,children:List.generate(isDouble?2:1,
          (_)=>Padding(padding:const EdgeInsets.only(left:3),
            child:Container(width:6,height:6,
              decoration:BoxDecoration(color:color,shape:BoxShape.circle))))),
      ),
    );
  }
}
