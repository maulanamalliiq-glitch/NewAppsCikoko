import 'package:flutter/material.dart';

/// Shown only while restoring the authenticated session.
/// Citizens without a session proceed to the standalone Login screen.
class CikokoStartupSplash extends StatelessWidget {
  const CikokoStartupSplash({super.key});

  @override
  Widget build(BuildContext context)=>Scaffold(
    body:DecoratedBox(
      decoration:const BoxDecoration(
        gradient:LinearGradient(
          begin:Alignment.topLeft,end:Alignment.bottomRight,
          colors:[Color(0xFF092C60),Color(0xFF146AC7),Color(0xFF063C89)])),
      child:SafeArea(
        child:Center(child:Column(
          mainAxisSize:MainAxisSize.min,
          children:[
            Container(
              width:120,height:120,
              padding:const EdgeInsets.all(12),
              decoration:BoxDecoration(
                color:Colors.white,
                borderRadius:BorderRadius.circular(30),
                boxShadow:const [
                  BoxShadow(color:Color(0x3B00163B),blurRadius:22,
                    offset:Offset(0,10)),
                ]),
              child:Image.asset('assets/logo.png',
                key:const Key('kelurahan_cikoko_splash_logo'),
                fit:BoxFit.contain),
            ),
            const SizedBox(height:22),
            const Text('CIKOKO SMARTAPP',
              style:TextStyle(color:Colors.white,fontSize:23,
                fontWeight:FontWeight.w900,letterSpacing:.55)),
            const SizedBox(height:8),
            const Text('Layanan Digital Kelurahan Cikoko',
              textAlign:TextAlign.center,
              style:TextStyle(color:Color(0xFFE4F0FF),fontSize:12.5)),
            const SizedBox(height:28),
            const SizedBox(width:26,height:26,
              child:CircularProgressIndicator(color:Colors.white,
                strokeWidth:2.5)),
          ],
        )),
      ),
    ),
  );
}
