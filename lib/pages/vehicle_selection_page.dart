import 'package:flutter/material.dart';

import 'pilih_kursi_page.dart';



class VehicleOption {
  final String name;
  final String imagePath;
  final int pricePerPax;
  final String departureTime;
  final String arrivalTime;
  final int availableSeats;

  const VehicleOption({
    required this.name,
    required this.imagePath,
    required this.pricePerPax,
    required this.departureTime,
    required this.arrivalTime,
    required this.availableSeats,
  });
}



class VehicleSelectionPage extends StatefulWidget {
  final String originCity; // contoh: 'Malang'
  final String originCode; // contoh: 'MLG'
  final String destinationCity; // contoh: 'Surabaya'
  final String destinationCode; // contoh: 'SBY'

  const VehicleSelectionPage({
    super.key,
    this.originCity = 'Malang',
    this.originCode = 'MLG',
    this.destinationCity = 'Surabaya',
    this.destinationCode = 'SBY',
  });

  @override
  State<VehicleSelectionPage> createState() =>
      _VehicleSelectionPageState();
}

class _VehicleSelectionPageState
    extends State<VehicleSelectionPage> {


  static const Color primaryBlue = Color(0xFF1769C2);
  static const Color backgroundColor = Color(0xFFF5F7FA);



  final List<VehicleOption> _vehicles = const [
    VehicleOption(
      name: 'HiAce Premio (CS)',
      imagePath: 'assets/images/hiace_premio.png',
      pricePerPax: 170000,
      departureTime: '07.00',
      arrivalTime: '09.00',
      availableSeats: 4,
    ),
    VehicleOption(
      name: 'Elf Isuzu Long',
      imagePath: 'assets/images/elf_isuzu_long.png',
      pricePerPax: 100000,
      departureTime: '12.15',
      arrivalTime: '14.15',
      availableSeats: 9,
    ),
    VehicleOption(
      name: 'Alphard Deluxe',
      imagePath: 'assets/images/alphard_deluxe.png',
      pricePerPax: 500000,
      departureTime: '07.00',
      arrivalTime: '09.00',
      availableSeats: 2,
    ),
    VehicleOption(
      name: 'Innova Reborn',
      imagePath: 'assets/images/innova_reborn.png',
      pricePerPax: 165000,
      departureTime: '13.00',
      arrivalTime: '14.30',
      availableSeats: 6,
    ),
  ];



  int? _selectedIndex;



  bool _isXs(double width) => width < 360;
  bool _isTablet(double width) => width >= 600 && width < 1000;
  bool _isDesktop(double width) => width >= 1000;



  void _onVehicleTap(int index, VehicleOption vehicle) {
    setState(() {
      _selectedIndex = index;
    });

    final bool isHiAce = vehicle.name.toLowerCase().contains('hiace');

    if (isHiAce) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PilihKursiPage(
            originCity: widget.originCity,
            destinationCity: widget.destinationCity,
            vehicleName: vehicle.name,
            pricePerPax: vehicle.pricePerPax,
            departureTime: vehicle.departureTime,
            arrivalTime: vehicle.arrivalTime,
          ),
        ),
      );
    }
  }



  String _formatPrice(int price) {
    final String raw = price.toString();
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < raw.length; i++) {
      final int posFromRight = raw.length - i;

      buffer.write(raw[i]);

      if (posFromRight > 1 && posFromRight % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString()}';
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;

            return Column(
              children: [



                _buildTopBar(width),



                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 700,
                      ),

                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: _isDesktop(width)
                              ? 24
                              : _isTablet(width)
                                  ? 20
                                  : 14,
                          vertical: 14,
                        ),

                        itemCount: _vehicles.length,

                        separatorBuilder:
                            (context, index) => SizedBox(
                          height: _isDesktop(width)
                              ? 16
                              : 12,
                        ),

                        itemBuilder: (context, index) {
                          return _buildVehicleCard(
                            _vehicles[index],
                            width,
                            isSelected:
                                _selectedIndex == index,
                            onTap: () =>
                                _onVehicleTap(index, _vehicles[index]),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }



  Widget _buildTopBar(double width) {
    final bool desktop = _isDesktop(width);

    return Container(
      width: double.infinity,

      padding: EdgeInsets.symmetric(
        horizontal: desktop ? 20 : 12,
        vertical: desktop ? 18 : 14,
      ),

      decoration: const BoxDecoration(
        color: Colors.white,

        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E5E5),
            width: 0.7,
          ),
        ),
      ),

      child: Row(
        children: [



          InkWell(
            borderRadius: BorderRadius.circular(20),

            onTap: () {
              Navigator.of(context).maybePop();
            },

            child: Padding(
              padding: const EdgeInsets.all(6),

              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.black87,
                size: desktop ? 24 : 21,
              ),
            ),
          ),



          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,

                children: [

                  _buildCityLabel(
                    city: widget.originCity,
                    code: widget.originCode,
                    desktop: desktop,
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: desktop ? 18 : 12,
                    ),

                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black54,
                      size: desktop ? 24 : 20,
                    ),
                  ),

                  _buildCityLabel(
                    city: widget.destinationCity,
                    code: widget.destinationCode,
                    desktop: desktop,
                  ),
                ],
              ),
            ),
          ),



          SizedBox(
            width: desktop ? 36 : 33,
          ),
        ],
      ),
    );
  }

  Widget _buildCityLabel({
    required String city,
    required String code,
    required bool desktop,
  }) {
    return Column(
      children: [

        Text(
          city,

          style: TextStyle(
            color: Colors.black87,

            fontSize: desktop ? 22 : 18,

            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          '($code)',

          style: TextStyle(
            color: Colors.grey.shade500,

            fontSize: desktop ? 14 : 12.5,

            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }



  Widget _buildVehicleCard(
    VehicleOption vehicle,
    double width, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bool desktop = _isDesktop(width);

    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding: EdgeInsets.all(
          desktop ? 16 : 12,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(
            desktop ? 16 : 14,
          ),



          border: Border.all(
            color: isSelected
                ? primaryBlue
                : Colors.transparent,
            width: 2,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [



          Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [



              Container(
                width: desktop ? 130 : 108,
                height: desktop ? 98 : 82,

                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3F7),

                  borderRadius: BorderRadius.circular(
                    desktop ? 12 : 10,
                  ),
                ),

                clipBehavior: Clip.antiAlias,

                child: Image.asset(
                  vehicle.imagePath,

                  width: double.infinity,
                  height: double.infinity,

                  fit: BoxFit.cover,

                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Icon(
                      Icons.directions_car_filled_rounded,
                      color: primaryBlue.withOpacity(0.4),
                      size: desktop ? 40 : 32,
                    );
                  },
                ),
              ),

              SizedBox(width: desktop ? 14 : 10),



              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      vehicle.name,

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: Colors.black87,

                        fontSize: desktop ? 16 : 14,

                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: desktop ? 6 : 4),

                    Text(
                      '${_formatPrice(vehicle.pricePerPax)}/pax',

                      style: TextStyle(
                        color: primaryBlue,

                        fontSize: desktop ? 15 : 13,

                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: desktop ? 8 : 6),



                    Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [

                        Icon(
                          Icons.event_seat_outlined,

                          color: Colors.grey.shade500,

                          size: desktop ? 15 : 13,
                        ),

                        SizedBox(width: desktop ? 5 : 4),

                        Text(
                          '${vehicle.availableSeats} kursi tersedia',

                          style: TextStyle(
                            color: Colors.grey.shade600,

                            fontSize: desktop ? 12.5 : 11,

                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: desktop ? 14 : 10),

          const Divider(
            height: 1,
            color: Color(0xFFEDEDED),
          ),

          SizedBox(height: desktop ? 12 : 10),



          Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [



              Row(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  _buildTimeInfo(
                    time: vehicle.departureTime,
                    city: widget.destinationCity,
                    desktop: desktop,
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: desktop ? 10 : 7,
                    ),

                    child: Padding(
                      padding: EdgeInsets.only(
                        top: desktop ? 2 : 1,
                      ),

                      child: Text(
                        '—  Sampai  —',

                        style: TextStyle(
                          color: Colors.grey.shade500,

                          fontSize: desktop ? 11 : 9.5,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  _buildTimeInfo(
                    time: vehicle.arrivalTime,
                    city: widget.originCity,
                    desktop: desktop,
                  ),
                ],
              ),



              const Spacer(),



              ElevatedButton(
                onPressed: () {
               

                  // Contoh:
                  //
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => VehicleDetailPage(
                  //       vehicle: vehicle,
                  //     ),
                  //   ),
                  // );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,

                  elevation: 0,

                  padding: EdgeInsets.symmetric(
                    horizontal: desktop ? 22 : 16,
                    vertical: desktop ? 12 : 9,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      desktop ? 10 : 8,
                    ),
                  ),
                ),

                child: Text(
                  'Detail',

                  style: TextStyle(
                    fontSize: desktop ? 13 : 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo({
    required String time,
    required String city,
    required bool desktop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(
          time,

          style: TextStyle(
            color: Colors.black87,

            fontSize: desktop ? 14 : 12.5,

            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          city,

          maxLines: 1,
          overflow: TextOverflow.ellipsis,

          style: TextStyle(
            color: Colors.grey.shade500,

            fontSize: desktop ? 11 : 9.5,

            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
