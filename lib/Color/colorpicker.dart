import 'package:flutter/material.dart';
class Colorpicker extends StatefulWidget {
  const Colorpicker({super.key});

  @override
  State<Colorpicker> createState() => _ColorpickerState();
}

class _ColorpickerState extends State<Colorpicker> {

  List<Color>_colorCollection = <Color>[
    const Color(0xFF0F8644),
    const Color(0xFF8B1FA9),
    const Color(0xFFD20100),
    const Color(0xFFFC571D),
    const Color(0xFF85461E),
    const Color(0xFFFF00FF),
    const Color(0xFF3D4FB5),
    const Color(0xFFE47C73),
    const Color(0xFF63636),
  ];
  List<String> _colorNames = <String>[
    'Green'
    'Purple'
        'Red'
        'Orange'
        'Caramel'
        'Magenta'
        'Blue'
        'Peach'
        'Gray'
  ];
  int _selectedColorIndex = -1;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
          width: double.maxFinite,
          child: ListView.builder(
              itemBuilder:(context, index){
                return ListTile(
                  title: Text(_colorNames[index]),
                    contentPadding:  const EdgeInsets.all(0),
                    leading: Icon(
                      index == _selectedColorIndex ? Icons.lens : Icons.trip_origin,
                      color: _colorCollection[index],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedColorIndex = index;
                      });
                      Future.delayed(const Duration(milliseconds: 200), () {
                        Navigator.pop(context, _colorCollection[index]);
                      });
                      });}

     )
    )
    );
  }
}
