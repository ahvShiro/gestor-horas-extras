import 'package:dio/dio.dart';
import 'package:gestor_horas_extras/core/exceptions/api_exception.dart';

class HolidayService {
  static const _apiUrl = 'https://brasilapi.com.br/api/feriados/v1';
  final _dio = Dio();

  Future<bool> isHoliday(DateTime date) async {
    final holidayList = await fetchHolidaysFromAPI(date.year);

    if (holidayList == null) return false;

    for (Map<String, dynamic> item in holidayList) {
      var holiday = DateTime.parse(item['date']);
      if (holiday.isAtSameMomentAs(date)) {
        return true;
      }
    }

    return false;
  }

  bool isWeekend(DateTime date) {
    return date.weekday == 6 || date.weekday == 7; // six seveeeeeen
  }

  Future<List<dynamic>?> fetchHolidaysFromAPI(int year) async {
    try {
      final response = await _dio.get('$_apiUrl/$year');
      return response.data as List;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
