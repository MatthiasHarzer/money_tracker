import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../services/config_service.dart';
import '../theme.dart';
import 'util.dart';

/// A dialog to confirm an action with a submit and cancel button
class ConfirmDialog {
  final BuildContext context;
  final String title;
  final String confirm;
  final String cancel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  final Completer<bool> _completer = Completer();

  Future<bool> get future => _completer.future;

  ConfirmDialog(
      {required this.context,
      required this.title,
      this.cancel = "CANCEL",
      this.confirm = "CONFIRM",
      this.onCancel,
      this.onConfirm,
      Key? key});

  void _onConfirm() {
    if (onConfirm != null) onConfirm!();
    _completer.complete(true);
    Navigator.pop(context);
  }

  void _onCancel() {
    if (onCancel != null) onCancel!();
    _completer.complete(false);
    Navigator.pop(context);
  }

  Widget get widget => AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.grey[300]),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: _onCancel,
                child: Text(
                  cancel,
                ),
              ),
              TextButton(
                onPressed: _onConfirm,
                child: Text(
                  confirm,
                ),
              ),
            ],
          ),
        ],
      );

  void show() {
    showDialog(context: context, builder: (ctx) => widget);
  }
}

/// Dialog for taking an text input from the user
class UserInputDialog {
  final BuildContext context;
  final String title;
  final String placeHolder;
  final String submit;
  final String cancel;
  final Function(String)? onSubmit;
  final VoidCallback? onCancel;

  final Completer<String?> _completer = Completer();
  String _inputText = "";
  TextInputType inputType;

  Future<String?> get future => _completer.future;

  UserInputDialog(
      {required this.context,
      required this.title,
      required this.placeHolder,
      this.cancel = "CANCEL",
      this.submit = "SUBMIT",
      this.onCancel,
      this.onSubmit,
      this.inputType = TextInputType.text,
      Key? key});

  void _onSubmit() {
    if (onSubmit != null) onSubmit!(_inputText);
    _completer.complete(_inputText);
    Navigator.pop(context);
  }

  void _onCancel() {
    if (onCancel != null) onCancel!();
    _completer.complete(null);
    Navigator.pop(context);
  }

  Widget get widget => AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.grey[300]),
        ),
        content: TextFormField(
          onChanged: (text) => _inputText = text,
          keyboardType: inputType,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: placeHolder,
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: _onCancel,
                child: Text(
                  cancel,
                ),
              ),
              TextButton(
                onPressed: _onSubmit,
                child: Text(
                  submit,
                ),
              ),
            ],
          ),
        ],
      );

  void show() {
    showDialog(context: context, builder: (ctx) => widget);
  }
}

/// A dialog showing a message and containing a close button
class UserInfoDialog {
  final BuildContext context;
  final String title;
  final String? subtitle;
  final String buttonLabel;
  final VoidCallback? onClose;
  final Completer _completer = Completer();

  Future get future => _completer.future;

  UserInfoDialog({
    required this.context,
    required this.title,
    this.subtitle,
    this.buttonLabel = "CLOSE",
    this.onClose,
  });

  void _onClose() {
    if (onClose != null) onClose!();
    _completer.complete();
    Navigator.pop(context);
  }

  Widget get widget => AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.grey[300]),
        ),
        content: subtitle == null
            ? null
            : Text(subtitle!,
                style: TextStyle(
                    fontWeight: FontWeight.w400, color: Colors.grey[400])),
        actions: [
          TextButton(
            onPressed: _onClose,
            child: Text(buttonLabel),
          )
        ],
      );

  void show() {
    showDialog(context: context, builder: (ctx) => widget);
  }
}

/// An expandable list item with a title and an optional action
class ExpandableListItem extends StatefulWidget {
  final String title;
  final Widget content;
  final Widget? action;
  final bool initialExpanded;
  final bool toUpperCase;
  final ExpandableCrossSessionConfig? crossSessionConfig;

  const ExpandableListItem({
    required this.title,
    required this.content,
    this.action,
    this.initialExpanded = false,
    this.toUpperCase = true,
    this.crossSessionConfig,
    Key? key,
  }) : super(key: key);

  @override
  State<ExpandableListItem> createState() => _ExpandableListItemState();
}

class _ExpandableListItemState extends State<ExpandableListItem> {
  bool get initialExpandedValue =>
      widget.crossSessionConfig?.expanded ?? widget.initialExpanded;

  late final ExpandableController controller;

  @override
  void initState(){
    super.initState();

    controller = ExpandableController(
      initialExpanded: initialExpandedValue
    );

    controller.addListener(() {
      if(widget.crossSessionConfig != null){
        widget.crossSessionConfig!.expanded = controller.expanded;
      }
      // setState((){
      //
      // });
      // print("UPDATE ${controller.expanded}");
    });
  }

  // void onToggle
  @override
  Widget build(BuildContext context) {
    ExpandableThemeData theme = ExpandableThemeData(
      iconColor: Colors.grey[300],
      iconPlacement: ExpandablePanelIconPlacement.left,
      iconRotationAngle: Util.degToRad(90),
      collapseIcon: Icons.keyboard_arrow_right,
      expandIcon: Icons.keyboard_arrow_right,
    );



    Widget header = Text(
      widget.toUpperCase ? widget.title.toUpperCase() : widget.title,
      style: TextStyle(
        color: Colors.grey[400],
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    );

    if (widget.action != null) {
      header = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [header, widget.action!],
      );
    }

    return ExpandablePanel(
      controller: controller,
      collapsed: Container(),
      theme: theme,
      header: SizedBox(
        height: 40,
        child: Align(
          alignment: Alignment.centerLeft,
          child: header,
        ),
      ),
      expanded: widget.content,
    );
  }
}

/// Displays a given text with an aciton button
class InfoActionWidget extends StatelessWidget {
  final String label;
  final String buttonText;
  final VoidCallback onTap;

  const InfoActionWidget(
      {required this.label,
      required this.buttonText,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
        Theme(
          data: theme,
          child: TextButton(
            onPressed: onTap,
            child: Text(
              buttonText,
            ),
          ),
        ),
      ],
    );
  }
}

/// Builds a unified circular avatar from an [url] taking a [dimension] for height/width
Widget buildCircularAvatar({required String? url, required double dimension}) {
  return SizedBox.square(
    dimension: dimension,
    child: CircleAvatar(
      backgroundColor: Colors.grey[800],
      radius: 45,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: url == null ? const Icon(Icons.account_circle_outlined) : ClipOval(
            child: Image.network(
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle_outlined),
          url,
        ),
        ),
      ),
    ),
  );
}
