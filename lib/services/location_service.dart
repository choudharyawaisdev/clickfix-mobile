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

  static const Map<String, List<String>> cityColonies = {
    'Faisalabad': [
      'Peoples Colony No. 1',
      'Peoples Colony No. 2',
      'D-Ground',
      'Samanabad',
      'Gulistan Colony',
      'Ghulam Muhammad Abad',
      'Madina Town',
      'Mansoorabad',
      'Batala Colony',
      'Canal Road',
      'Saeedabad',
      'Jinnah Colony',
      'Eden Garden',
      'Kohinoor City',
      'FDA City',
      'Wapda Town',
      'Millat Town',
      'Susan Road',
    ],
    'Lahore': [
      'Gulberg I',
      'Gulberg II',
      'Gulberg III',
      'DHA Phase 1',
      'DHA Phase 2',
      'DHA Phase 3',
      'DHA Phase 4',
      'DHA Phase 5',
      'DHA Phase 6',
      'DHA Phase 7',
      'DHA Phase 8',
      'Johar Town',
      'Model Town',
      'Bahria Town',
      'Samanabad',
      'Shadman',
      'Allama Iqbal Town',
      'Wapda Town',
      'Faisal Town',
      'Cavalry Ground',
      'Garhi Shahu',
      'Sabzazar',
      'Green Town',
      'Township',
    ],
    'Karachi': [
      'Clifton',
      'DHA Phase 1',
      'DHA Phase 2',
      'DHA Phase 4',
      'DHA Phase 5',
      'DHA Phase 6',
      'DHA Phase 7',
      'DHA Phase 8',
      'Gulshan-e-Iqbal',
      'North Nazimabad',
      'Federal B Area',
      'PECHS',
      'Korangi',
      'Gulistan-e-Jauhar',
      'Saddar',
      'Malir',
      'Lyari',
      'Liaquatabad',
      'Orangi Town',
      'Bahria Town Karachi',
      'Defense',
      'Tariq Road',
    ],
    'Islamabad': [
      'Sector F-6',
      'Sector F-7',
      'Sector F-8',
      'Sector F-10',
      'Sector F-11',
      'Sector G-6',
      'Sector G-7',
      'Sector G-8',
      'Sector G-9',
      'Sector G-10',
      'Sector G-11',
      'Sector I-8',
      'Sector I-9',
      'Sector I-10',
      'Sector H-9',
      'Sector E-7',
      'Sector D-12',
      'Blue Area',
      'Bahria Town',
      'DHA Phase 1',
      'DHA Phase 2',
      'Bani Gala',
    ],
    'Rawalpindi': [
      'Saddar',
      'Satellite Town',
      'Bahria Town',
      'DHA',
      'Lalazar',
      'Westridge',
      'Tench Bhata',
      'Commercial Market',
      'Adiala Road',
      'Chaklala Scheme 1',
      'Chaklala Scheme 2',
      'Chaklala Scheme 3',
      'Peshawar Road',
    ],
    'Peshawar': [
      'Hayatabad Phase 1',
      'Hayatabad Phase 2',
      'Hayatabad Phase 3',
      'Hayatabad Phase 4',
      'Hayatabad Phase 5',
      'Hayatabad Phase 6',
      'Hayatabad Phase 7',
      'Cantonment',
      'University Town',
      'Warsak Road',
      'Ring Road',
      'GT Road',
    ],
    'Multan': [
      'Bosan Road',
      'Gulgasht Colony',
      'Shah Rukn-e-Alam Colony',
      'Multan Cantt',
      'Shalimar Colony',
      'Mumtazabad',
      'Officers Colony',
      'Wapda Town',
      'New Multan',
    ],
    'Quetta': [
      'Cantonment',
      'Satellite Town',
      'Jinnah Road',
      'Shahbaz Town',
      'Samungli Road',
      'Double Road',
    ],
    'Gujranwala': [
      'Satellite Town',
      'DC Road',
      'Model Town',
      'Wapda Town',
      'People\'s Colony',
      'Gujranwala Cantt',
      'Garden Town',
    ],
    'Sialkot': [
      'Sialkot Cantt',
      'Model Town',
      'Shahabpura',
      'Paris Road',
      'Sialkot Fort',
    ],
  };

  /// Fetches colonies/areas for a specific city.
  static Future<List<String>> fetchColoniesForCity(String city) async {
    final normalizedCity = city.trim();
    if (cityColonies.containsKey(normalizedCity)) {
      final List<String> list = List<String>.from(cityColonies[normalizedCity]!);
      list.sort();
      return list;
    }
    
    // Generic fallback colonies list for smaller/other cities
    return [
      'Cantonment',
      'Saddar',
      'Model Town',
      'Main Bazaar',
      'People\'s Colony',
      'City Center',
      'Civil Lines',
      'Railway Scheme',
      'Housing Society',
    ];
  }

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
