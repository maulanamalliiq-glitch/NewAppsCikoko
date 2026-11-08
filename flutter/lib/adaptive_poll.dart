import 'dart:async';

/// One request at a time; quiet pages and failures back off to reduce traffic.
class AdaptivePoller {
 final Future<bool> Function() check;
 final Duration minimum,maximum;
 Timer? _timer;bool _cancelled=false,_running=false;int _quiet=0;
 AdaptivePoller(this.check,{this.minimum=const Duration(seconds:3),this.maximum=const Duration(seconds:30)});
 Duration get delay=>Duration(milliseconds:(minimum.inMilliseconds*(1<<_quiet)).clamp(minimum.inMilliseconds,maximum.inMilliseconds));
 void start({bool immediate=true}){_cancelled=false;_schedule(immediate?Duration.zero:minimum);}
 void cancel(){_cancelled=true;_timer?.cancel();}
 void _schedule(Duration d){_timer?.cancel();if(!_cancelled)_timer=Timer(d,_tick);}
 Future<void> _tick()async{
  if(_cancelled||_running)return;_running=true;
  try{final changed=await check();_quiet=changed?0:(_quiet+1).clamp(0,5);}
  catch(_){_quiet=(_quiet+1).clamp(0,5);}
  finally{_running=false;if(!_cancelled)_schedule(delay);}
 }
}
