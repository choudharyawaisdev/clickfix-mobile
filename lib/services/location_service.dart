import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _apiUrl =
      'https://gist.githubusercontent.com/ahmedali5530/a4f090da89989ca9e0ca04e202036c48/raw/pakistan_cities.json';

  // Comprehensive fallback list of Pakistan cities to ensure offline compatibility and completeness
  static const List<String> fallbackCities = [
    'Karachi',
    'Lahore',
    'Faisalabad',
    'Rawalpindi',
    'Gujranwala',
    'Peshawar',
    'Multan',
    'Hyderabad',
    'Islamabad',
    'Quetta',
    'Bahawalpur',
    'Sargodha',
    'Sialkot',
    'Sukkur',
    'Larkana',
    'Sheikhupura',
    'Rahim Yar Khan',
    'Jhang',
    'Dera Ghazi Khan',
    'Gujrat',
    'Sahiwal',
    'Wah Cantonment',
    'Mardan',
    'Kasur',
    'Okara',
    'Mingora',
    'Nawabshah',
    'Chiniot',
    'Kotri',
    'Kamanke',
    'Hafizabad',
    'Sadiqabad',
    'Mirpur Khas',
    'Burewala',
    'Kohat',
    'Khanewal',
    'Dera Ismail Khan',
    'Turbat',
    'Muzaffargarh',
    'Abbottabad',
    'Mandi Bahauddin',
    'Shikarpur',
    'Jacobabad',
    'Jhelum',
    'Khanpur',
    'Khairpur',
    'Khuzdar',
    'Pakpattan',
    'Hub',
    'Daska',
    'Gojra',
    'Dadu',
    'Muridke',
    'Bahawalnagar',
    'Samundri',
    'Tando Allahyar',
    'Tando Adam',
    'Jaranwala',
    'Chishtian',
    'Muzaffarabad',
    'Attock',
    'Vehari',
    'Kot Abdul Malik',
    'Ferozewala',
    'Chakwal',
    'Guiranwala Cantonment',
    'Kamalia',
    'Umerkot',
    'Ahmedpur East',
    'Kot Addu',
    'Wazirabad',
    'Mansehra',
    'Layyah',
    'Mirpur',
    'Sawabee',
    'Chaman',
    'Taxila',
    'Nowshera',
    'Khushab',
    'Shahdadkot',
    'Mianwali',
    'Kabal',
    'Lodhran',
    'Hasilpur',
    'Charsadda',
    'Bhakkar',
    'Badin',
    'Arif Wala',
    'Ghotki',
    'Sambrial',
    'Jatoi',
    'Haroonabad',
    'Daharki',
    'Narowal',
    'Tando Muhammad Khan',
    'Kamber Ali Khan',
    'Mirpur Mathelo',
    'Kandhkot',
    'Depalpur',
    'Zhob',
    'Pattoki',
    'Okara Cantonment',
    'Gujar Khan',
    'Mailsi',
    'Rawalakot',
    'Skardu',
    'Gilgit',
    'Gwadar',
  ];

  /// Fetches Pakistan cities from the API.
  /// Dynamically parses flat lists or map structures, falling back to local list on failure.
  static Future<List<String>> fetchCities() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        
        List<String> fetchedList = [];
        
        if (decoded is List) {
          for (var item in decoded) {
            if (item is String) {
              fetchedList.add(item);
            } else if (item is Map && item.containsKey('name')) {
              fetchedList.add(item['name'].toString());
            } else if (item is Map && item.containsKey('city')) {
              fetchedList.add(item['city'].toString());
            }
          }
        } else if (decoded is Map) {
          // If the JSON is wrapped in a map under some keys (e.g. 'cities' or 'data')
          final citiesData = decoded['cities'] ?? decoded['data'] ?? decoded['list'];
          if (citiesData is List) {
            for (var item in citiesData) {
              if (item is String) {
                fetchedList.add(item);
              } else if (item is Map && item.containsKey('name')) {
                fetchedList.add(item['name'].toString());
              }
            }
          }
        }

        if (fetchedList.isNotEmpty) {
          // Remove duplicates, sort alphabetically, and return
          final uniqueCities = fetchedList.map((c) => c.trim()).toSet().toList();
          uniqueCities.sort();
          return uniqueCities;
        }
      }
    } catch (e) {
      // Return fallback list if network fails or times out
      print('LocationService: Error fetching cities, using fallback list. Error: $e');
    }
    
    // Sort fallback list and return it
    final sortedFallback = List<String>.from(fallbackCities);
    sortedFallback.sort();
    return sortedFallback;
  }
}
