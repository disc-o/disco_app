import 'package:flutter/material.dart';
import 'package:groovin_widgets/modal_drawer_handle.dart';

List<Widget> _verificationContent(
    BuildContext context, String clientName, String certificate) {
  return [
    ListTile(
      leading: Icon(Icons.call_received),
      title: Text(
        'Requesting client',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(clientName),
    ),
    ListTile(
        leading: Icon(Icons.verified_user),
        title: Text(
          'Certificate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(certificate)),
    MaterialButton(
      child: Text('hello'),
      color: Colors.redAccent,
      onPressed: () {
        Navigator.pop(context, 'hello');
      },
    )
  ];
}

Future openVerificationDrawer(
    BuildContext context, String clientName, String certificate) {
  return openDrawer(
      context, _verificationContent(context, clientName, certificate));
}

Future openDrawer(BuildContext context, List<Widget> content) {
  List<Widget> _children = List();
  _children.add(Padding(
    padding: const EdgeInsets.all(8.0),
    child: ModalDrawerHandle(),
  ));
  _children.addAll(content);
  return showModalBottomSheet(
    context: context,
    builder: (builder) {
      return Container(
        height: 350.0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10.0),
                  topRight: const Radius.circular(10.0))),
          child: Column(mainAxisSize: MainAxisSize.min, children: _children),
        ),
      );
    },
  );
}