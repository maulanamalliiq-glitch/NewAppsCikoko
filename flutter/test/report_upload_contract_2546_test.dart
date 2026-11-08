import 'package:flutter_test/flutter_test.dart';
import 'package:cikoko/api.dart';

void main(){
  test('Existing non-report photo and document uploads do not require an ID',(){
    final slide=cikokoGenericUploadResponse(200,'{"ok":true,"name":"photo.jpg"}');
    expect(slide['name'],'photo.jpg');
    final waris=cikokoGenericUploadResponse(200,'{"ok":true,"reference":"AW-123"}');
    expect(waris['reference'],'AW-123');
    expect(()=>cikokoGenericUploadResponse(500,'<html>Failure</html>'),throwsA(isA<ApiError>()));
  });
  group('Cikoko photo report upload 2546',(){
    test('real JSON confirmed database ID is the only success',(){
      final r=cikokoReportUploadResponse(200,'{"ok":true,"id":320,"stored":true}');
      expect(r['id'],320);
    });
    test('HTTP 403 Apache HTML cannot be treated as sent report',(){
      expect(()=>cikokoReportUploadResponse(403,'<html>Forbidden</html>'),
        throwsA(isA<ApiError>().having((e)=>e.statusCode,'status',403)));
    });
    test('HTTP 500 empty response does not crash on FormatException',(){
      expect(()=>cikokoReportUploadResponse(500,''),
        throwsA(isA<ApiError>().having((e)=>e.statusCode,'status',500)));
    });
    test('HTTP 413 is handled as upload limit',(){
      expect(()=>cikokoReportUploadResponse(413,'<html>413</html>'),
        throwsA(isA<ApiError>().having((e)=>e.statusCode,'status',413)));
    });
    test('HTTP 200 with invalid JSON cannot show successful toast',(){
      expect(()=>cikokoReportUploadResponse(200,'<html>Broken</html>'),throwsA(isA<ApiError>()));
    });
    test('JSON ok true without persisted ID must be rejected',(){
      expect(()=>cikokoReportUploadResponse(200,'{"ok":true}'),throwsA(isA<ApiError>()));
      expect(()=>cikokoReportUploadResponse(200,'{"ok":true,"id":0}'),throwsA(isA<ApiError>()));
    });
    test('backend rejects and errors are wrapped',(){
      expect(()=>cikokoReportUploadResponse(503,'{"ok":false,"error":"Layanan mengalami kendala."}'),
        throwsA(isA<ApiError>().having((e)=>e.statusCode,'status',503)));
      expect(()=>cikokoReportUploadResponse(401,'{"ok":false,"error":"expired"}'),
        throwsA(isA<ApiError>().having((e)=>e.statusCode,'status',401)));
    });
    test('array shape and null are invalid',(){
      expect(()=>cikokoReportUploadResponse(200,'[]'),throwsA(isA<ApiError>()));
      expect(()=>cikokoReportUploadResponse(200,'null'),throwsA(isA<ApiError>()));
    });
  });
}
