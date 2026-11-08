import 'package:flutter/material.dart';

class CikokoChatLauncher extends StatelessWidget {
  final VoidCallback onPressed;
  final bool administrative;
  final int unreadCount;
  const CikokoChatLauncher({super.key,required this.onPressed,this.administrative=false,this.unreadCount=0});
  @override Widget build(BuildContext context)=>FloatingActionButton(
    key:const Key('floating_chat_launcher'),
    heroTag:'cikoko_chat_launcher',
    tooltip:administrative?'Chat Warga':'Hubungi Admin',
    onPressed:onPressed,
    child:Badge(isLabelVisible:unreadCount>0,label:Text(unreadCount>99?'99+':'$unreadCount'),
      child:const Icon(Icons.chat_bubble_outline_rounded)),
  );
}
