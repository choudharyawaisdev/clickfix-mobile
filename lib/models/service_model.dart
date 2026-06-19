import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String title;
  final String category;
  final IconData iconData;
  final String description;
  final double basePrice;
  final String rating;
  final String activeWorkers;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.iconData,
    required this.description,
    required this.basePrice,
    this.rating = '4.9',
    this.activeWorkers = '15+',
  });

  static const List<ServiceModel> services = [
    ServiceModel(
      id: 'electrician',
      title: 'Electrician',
      category: 'Maintenance',
      iconData: Icons.electrical_services_rounded,
      description: 'Professional wiring, fan repairs, switchboard installations, UPS setup, and short-circuit troubleshooting.',
      basePrice: 500,
    ),
    ServiceModel(
      id: 'plumbing',
      title: 'Plumbing',
      category: 'Maintenance',
      iconData: Icons.plumbing_rounded,
      description: 'Leakage fixes, tap installations, pipe repairs, geyser servicing, washroom fittings, and water pump repair.',
      basePrice: 600,
    ),
    ServiceModel(
      id: 'ac_repair',
      title: 'AC Repair',
      category: 'Appliances',
      iconData: Icons.ac_unit_rounded,
      description: 'AC installation, gas charging, master cleaning, service inspection, compressor repairs, and inverter board fixing.',
      basePrice: 1500,
    ),
    ServiceModel(
      id: 'carpenter',
      title: 'Carpenter',
      category: 'Maintenance',
      iconData: Icons.handyman_rounded,
      description: 'Door repairs, lock installations, furniture assembly, kitchen cabinet work, and wooden polishing services.',
      basePrice: 800,
    ),
    ServiceModel(
      id: 'cleaning',
      title: 'Deep Cleaning',
      category: 'Cleaning',
      iconData: Icons.cleaning_services_rounded,
      description: 'Home deep cleaning, sofa washing, carpet cleaning, water tank disinfection, and washroom sanitization.',
      basePrice: 1200,
    ),
    ServiceModel(
      id: 'painter',
      title: 'Painter',
      category: 'Renovation',
      iconData: Icons.format_paint_rounded,
      description: 'Interior and exterior house paint, wall putty, weather-sheet coating, feature wall design, and damp repair.',
      basePrice: 2000,
    ),
    ServiceModel(
      id: 'solar_panels',
      title: 'Solar Panels',
      category: 'Energy',
      iconData: Icons.solar_power_rounded,
      description: 'Solar panel installation, net metering integration, inverter setup, battery replacement, and solar plate cleaning.',
      basePrice: 3500,
    ),
    ServiceModel(
      id: 'cctv_cam',
      title: 'CCTV Camera',
      category: 'Security',
      iconData: Icons.videocam_rounded,
      description: 'CCTV camera installation, DVR config, mobile viewing integration, wire layouts, and security system repairs.',
      basePrice: 1000,
    ),
    ServiceModel(
      id: 'auto_care',
      title: 'Auto Care',
      category: 'Vehicle',
      iconData: Icons.directions_car_rounded,
      description: 'Mobile car mechanic, battery jumpstart, oil changes, engine tuning, brake repairs, and roadside assistance.',
      basePrice: 1200,
    ),
    ServiceModel(
      id: 'it_support',
      title: 'IT Support',
      category: 'Tech Support',
      iconData: Icons.computer_rounded,
      description: 'Wi-Fi configuration, router setup, laptop/PC repairs, OS installation, and local area network planning.',
      basePrice: 1000,
    ),
    ServiceModel(
      id: 'pest_control',
      title: 'Pest Control',
      category: 'Cleaning',
      iconData: Icons.bug_report_rounded,
      description: 'Termite proofing, general fumigation, bedbug treatment, cockroach spray, and rodent control.',
      basePrice: 1800,
    ),
    ServiceModel(
      id: 'appliances_repair',
      title: 'Appliances Repair',
      category: 'Appliances',
      iconData: Icons.kitchen_rounded,
      description: 'Refrigerator repair, microwave oven fixing, washing machine servicing, and dispenser maintenance.',
      basePrice: 800,
    ),
    ServiceModel(
      id: 'gardening',
      title: 'Gardening',
      category: 'Maintenance',
      iconData: Icons.yard_rounded,
      description: 'Lawn mowing, grass trimming, pesticide spraying, weed extraction, plant soil replacement, and landscaping.',
      basePrice: 700,
    ),
    ServiceModel(
      id: 'masonry',
      title: 'Masonry',
      category: 'Renovation',
      iconData: Icons.foundation_rounded,
      description: 'Wall brickwork, concrete plastering, tile and marble installation, washroom renovation, and flooring repairs.',
      basePrice: 1500,
    ),
    ServiceModel(
      id: 'moving_packing',
      title: 'Moving & Packing',
      category: 'Vehicle',
      iconData: Icons.local_shipping_rounded,
      description: 'Safe home shifting, packing service, loading/unloading, transport trucks, and furniture dismantling/reassembly.',
      basePrice: 4000,
    ),
  ];
}
