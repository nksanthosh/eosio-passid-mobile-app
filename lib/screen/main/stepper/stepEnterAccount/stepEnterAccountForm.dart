import 'package:eosio_passid_mobile_app/constants/constants.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:eosio_passid_mobile_app/screen/main/stepper/stepEnterAccount/stepEnterAccount.dart";
import "package:eosio_passid_mobile_app/screen/main/stepper/stepper.dart";
import 'package:flutter/cupertino.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/screen/customBottomPicker.dart';
import 'package:eosio_passid_mobile_app/utils/size.dart';
import 'package:eosio_passid_mobile_app/screen/theme.dart';

class StepEnterAccountForm extends StatefulWidget {
  StepEnterAccountForm() {}

  @override
  _StepEnterAccountFormState createState() => _StepEnterAccountFormState();
}

class _StepEnterAccountFormState extends State<StepEnterAccountForm> {
  TextEditingController _accountTextController;
  var _storage;

  _StepEnterAccountFormState() {
    this._accountTextController = TextEditingController();
    this._storage = Storage();
  }

  //update fields in account form
  void updateFields() {
    var storage = Storage();
    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
    _accountTextController.text = storageStepEnterAccount.accountID != null ? storageStepEnterAccount.accountID : "";
  }

  //clear fields in account form
  void emptyFields() {
    _accountTextController.text = "";
  }

  void selectNetwork(var context, StepEnterAccountState state, var stepEnterAccountBloc) {
    var storage = Storage();
    StepDataEnterAccount storageStepEnterAccount = storage.getStorageData(0);
    BottomPickerStructure bps = BottomPickerStructure();
    bps.importNetworkList(storage.nodeSet, storageStepEnterAccount.networkType,
        "Select node", "Please select the node");
    CustomBottomPickerState cbps = CustomBottomPickerState(structure: bps);
    cbps.showPicker(context,
        //callback function to manage user click action on selection
        (BottomPickerElement returnedStorageNode) {
      //find the node with the same name as returned name
          storage.nodeSet.nodes.forEach((key, value) {
            if (key == EnumUtil.fromStringEnum(NetworkType.values, returnedStorageNode.key)) {
              storageStepEnterAccount.networkType =
                  EnumUtil.fromStringEnum(NetworkType.values, returnedStorageNode.key);
              storage.save();

              if (state is FullState) {
                stepEnterAccountBloc.add(AccountConfirmation(
                    accountID: storageStepEnterAccount.accountID,
                    networkType: storageStepEnterAccount.networkType));
              }
              if (state is DeletedState) {
                stepEnterAccountBloc.add(AccountDelete(networkType:  storageStepEnterAccount.networkType));
              }
              final stepperBloc = BlocProvider.of<StepperBloc>(context);
              stepperBloc.liveModifyHeader(0, context);
            }
          });
    });
  }

  Widget selectNetworkWithTile(var context,
      StepEnterAccountState state,
      var stepEnterAccountBloc) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Network',
              style: TextStyle(
                  fontSize: AndroidThemeST().getValues().themeValues["TILE_BAR"]
                      ["SIZE_TEXT"]),
            ),
            Text(Storage().nodeSet.networkTypeToString(state.networkType),
                style: TextStyle(
                    fontSize: AndroidThemeST()
                        .getValues()
                        .themeValues["TILE_BAR"]["SIZE_TEXT"],
                    color: AndroidThemeST().getValues().themeValues["TILE_BAR"]
                        ["COLOR_TEXT"]))
          ]),
      trailing: Icon(Icons.expand_more),
      onTap: () => selectNetwork(context, state, stepEnterAccountBloc),
    );
  }

  Widget body(BuildContext context,
      StepEnterAccountState state,
      var stepEnterAccountBloc)
  {
    if (state is DeletedState) emptyFields();
    if (state is FullState) updateFields();

    final stepperBloc = BlocProvider.of<StepperBloc>(context);
    return Form(
        autovalidate: true,
        child: Column(children: <Widget>[
          selectNetworkWithTile(context, state, stepEnterAccountBloc),
          //if (storage.selectedNode.name != "ZeroPass Server")
            TextFormField(
              controller: _accountTextController,
              decoration: InputDecoration(
                labelText: 'Account name',
              ),
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter(RegExp(r'\b[a-z1-5.]+')),
                LengthLimitingTextInputFormatter(13)
              ],
              validator: (value) =>
                  stepEnterAccountBloc.validatorFunction(value, context)
                      ? stepEnterAccountBloc.validatorText
                      : null,
              onChanged: (value) async {
                //save to storage
                StepDataEnterAccount storageStepEnterAccount =
                    _storage.getStorageData(0);
                storageStepEnterAccount.accountID = _accountTextController.text.length !=0 ? _accountTextController.text : null;
                //save storage
                _storage.save();

                stepperBloc.liveModifyHeader(0, context);
              },
            ),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final stepEnterAccountBloc = BlocProvider.of<StepEnterAccountBloc>(context);
    return BlocBuilder(
      bloc: stepEnterAccountBloc,
      builder: (BuildContext context, StepEnterAccountState state) {
        return Container(
            width: CustomSize.getMaxWidth(context, STEPPER_ICON_PADDING),
            child: body(context, state, stepEnterAccountBloc));
      },
    );
  }
}