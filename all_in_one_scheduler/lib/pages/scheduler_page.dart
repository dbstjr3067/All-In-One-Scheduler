import 'package:flutter/material.dart';

class SchedulerPage extends StatelessWidget {
  const SchedulerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 375,
          height: 812,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 5,
                top: 114,
                child: Container(
                  width: 370,
                  decoration: BoxDecoration(
                    color: Colors.white /* Backgrounds-(Grouped)-Secondary */,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 44,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 296,
                                    top: 9,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      spacing: 28,
                                      children: [
                                        SizedBox(
                                          width: 15,
                                          height: 24,
                                          child: Text(
                                            '􀆉',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF4F378B,
                                              ) /* Schemes-On-Primary-Fixed-Variant */,
                                              fontSize: 20,
                                              fontFamily: 'SF Pro',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                          height: 24,
                                          child: Text(
                                            '􀆊',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF4F378B,
                                              ) /* Schemes-On-Primary-Fixed-Variant */,
                                              fontSize: 20,
                                              fontFamily: 'SF Pro',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    left: 16,
                                    top: 10,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      spacing: 4,
                                      children: [
                                        Text(
                                          'June 2024',
                                          style: TextStyle(
                                            color: Colors
                                                .black /* Labels-Primary */,
                                            fontSize: 17,
                                            fontFamily: 'SF Pro',
                                            fontWeight: FontWeight.w600,
                                            height: 1.29,
                                            letterSpacing: -0.43,
                                          ),
                                        ),
                                        Text(
                                          '􀆊',
                                          style: TextStyle(
                                            color: const Color(
                                              0xFF4F378B,
                                            ) /* Schemes-On-Primary-Fixed-Variant */,
                                            fontSize: 17,
                                            fontFamily: 'SF Pro',
                                            fontWeight: FontWeight.w600,
                                            height: 1.29,
                                            letterSpacing: -0.50,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 20,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 17,
                                children: [
                                  SizedBox(
                                    width: 32,
                                    height: 18,
                                    child: Text(
                                      'SUN',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(
                                          0x4C3C3C43,
                                        ) /* Labels-Tertiary */,
                                        fontSize: 13,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w600,
                                        height: 1.38,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    height: 18,
                                    child: Text(
                                      'MON',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(
                                          0x4C3C3C43,
                                        ) /* Labels-Tertiary */,
                                        fontSize: 13,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w600,
                                        height: 1.38,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    height: 18,
                                    child: Text(
                                      'TUE',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(
                                          0x4C3C3C43,
                                        ) /* Labels-Tertiary */,
                                        fontSize: 13,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w600,
                                        height: 1.38,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    height: 18,
                                    child: Text(
                                      'WED',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(
                                          0x4C3C3C43,
                                        ) /* Labels-Tertiary */,
                                        fontSize: 13,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w600,
                                        height: 1.38,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    height: 18,
                                    child: Text(
                                      'THU',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(
                                          0x4C3C3C43,
                                        ) /* Labels-Tertiary */,
                                        fontSize: 13,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w600,
                                        height: 1.38,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    height: 18,
                                    child: Text(
                                      'FRI',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(
                                          0x4C3C3C43,
                                        ) /* Labels-Tertiary */,
                                        fontSize: 13,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w600,
                                        height: 1.38,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    height: 18,
                                    child: Text(
                                      'SAT',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(
                                          0x4C3C3C43,
                                        ) /* Labels-Tertiary */,
                                        fontSize: 13,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w600,
                                        height: 1.38,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(top: 3),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 7,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '2',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '3',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '4',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '5',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '6',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '7',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '8',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 44,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '9',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '10',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xFF4F378B,
                                                      ) /* Schemes-On-Primary-Fixed-Variant */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '11',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '12',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '13',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '14',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '15',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 44,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '16',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '17',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '18',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '19',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '20',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '21',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '22',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 44,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '23',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '24',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '25',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: Opacity(
                                                  opacity: 0.12,
                                                  child: Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: ShapeDecoration(
                                                      color: const Color(
                                                        0xFF4F378B,
                                                      ) /* Schemes-On-Primary-Fixed-Variant */,
                                                      shape: OvalBorder(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '26',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xFF4F378B,
                                                      ) /* Schemes-On-Primary-Fixed-Variant */,
                                                      fontSize: 24,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 1.04,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '27',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '28',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '29',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 44,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: Text(
                                                    '30',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors
                                                          .black /* Labels-Primary */,
                                                      fontSize: 20,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.25,
                                                      letterSpacing: -0.45,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(width: 44, height: 44),
                                        Container(width: 44, height: 44),
                                        Container(width: 44, height: 44),
                                        Container(width: 44, height: 44),
                                        Container(width: 44, height: 44),
                                        Container(width: 44, height: 44),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 11,
                                          decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.33,
                                                color: const Color(
                                                  0x56545456,
                                                ) /* Separators-Non-opaque */,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Ends',
                              style: TextStyle(
                                color: Colors.black /* Labels-Primary */,
                                fontSize: 17,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w400,
                                height: 1.29,
                                letterSpacing: -0.43,
                              ),
                            ),
                            Container(
                              height: 44,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 6,
                                    ),
                                    decoration: ShapeDecoration(
                                      color: const Color(
                                        0x1E787880,
                                      ) /* Fills-Tertiary */,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '8:00 AM',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors
                                                .black /* Labels-Primary */,
                                            fontSize: 17,
                                            fontFamily: 'SF Pro',
                                            fontWeight: FontWeight.w400,
                                            height: 1.29,
                                            letterSpacing: -0.43,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 0.33,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.33,
                                    color: const Color(
                                      0x56545456,
                                    ) /* Separators-Non-opaque */,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 742,
                child: Container(
                  width: 375, 
                  height: 70,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF3EDF7,
                    ) /* Schemes-Surface-Container */,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(color: Colors.white),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 4,
                            children: [
                              Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: const Color(
                                    0xFFE8DEF8,
                                  ) /* Schemes-Secondary-Container */,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 32,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 16,
                                            top: 4,
                                            child: Opacity(
                                              opacity: 0,
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Stack(),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 24,
                                            height: 24,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Stack(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 75,
                                child: Text(
                                  '홈',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF625B71,
                                    ) /* Schemes-Secondary */,
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    height: 1.33,
                                    letterSpacing: 0.50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 4,
                            children: [
                              Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 32,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 16,
                                            top: 4,
                                            child: Opacity(
                                              opacity: 0,
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Stack(),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 24,
                                            height: 24,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Stack(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 75,
                                child: Text(
                                  '캘린더',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF49454F,
                                    ) /* Schemes-On-Surface-Variant */,
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    height: 1.33,
                                    letterSpacing: 0.50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(color: Colors.white),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 4,
                            children: [
                              Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 32,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 16,
                                            top: 4,
                                            child: Opacity(
                                              opacity: 0,
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Stack(),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 24,
                                            height: 24,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Stack(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 75,
                                child: Text(
                                  '알람',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF49454F,
                                    ) /* Schemes-On-Surface-Variant */,
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    height: 1.33,
                                    letterSpacing: 0.50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 4,
                            children: [
                              Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 32,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 16,
                                            top: 4,
                                            child: Opacity(
                                              opacity: 0,
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Stack(),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 24,
                                            height: 24,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Stack(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 75,
                                child: Text(
                                  '목표',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF49454F,
                                    ) /* Schemes-On-Surface-Variant */,
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    height: 1.33,
                                    letterSpacing: 0.50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 4,
                            children: [
                              Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 32,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 16,
                                            top: 4,
                                            child: Opacity(
                                              opacity: 0,
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Stack(),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 24,
                                            height: 24,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Stack(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 75,
                                child: Text(
                                  '설정',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF49454F,
                                    ) /* Schemes-On-Surface-Variant */,
                                    fontSize: 12,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    height: 1.33,
                                    letterSpacing: 0.50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 13,
                top: 69,
                child: Text(
                  '캘린더',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    height: 1.26,
                    letterSpacing: 1.57,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
