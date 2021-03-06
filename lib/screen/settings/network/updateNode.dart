import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:eosio_passid_mobile_app/utils/storage.dart';
import 'package:eosio_passid_mobile_app/constants/constants.dart';
import 'package:eosio_passid_mobile_app/utils/structure.dart';
import 'package:card_settings/card_settings.dart';
import 'package:eosio_passid_mobile_app/screen/alert.dart';

class SettingsUpdateNode extends StatelessWidget {
  Storage storage;
  NodeServer storageNode;


  //to check if any field has been updated
  NodeServer currentUpdatedValues;

  SettingsUpdateNode({@required Storage this.storage, @required NodeServer this.storageNode})
  {
    this.currentUpdatedValues = new NodeServer.clone(this.storageNode);
    //init validation fields
    this.storageNode.initValidation();
  }

  void onButtonPressedDelete() {}

  void onButtonPressedSave(BuildContext context)
  {
    //copy values to storage if there is any change
    if (!this.storageNode.compare(this.currentUpdatedValues))
      this.storageNode.clone(this.currentUpdatedValues);// = new StorageNode.clone(this.currentUpdatedValues);
    storage.save();
    showAlert(
        context: context,
        title: Text("The data have been saved successfully"),
        closeOnBackPressed: true);
  }

  Future<bool> onWillPop(BuildContext context) {
    if (!this.storageNode.compare(this.currentUpdatedValues)) {
      showAlert(
          context: context,
          title: Text("The data have been saved successfully"),
          actions: [
            PlatformDialogAction(
                child: PlatformText('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            PlatformDialogAction(
                child: PlatformText('Save and go',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  this.storageNode = new NodeServer.clone(this.currentUpdatedValues);
                  Navigator.pop(context);
                })
          ]);
      return new Future.value(false);
    } else
      return new Future.value(true);
  }



  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    Storage storage = Storage();

    List<String> chainsKeys = [];
    List<String> chainsValues = [];
    storage.nodeSet.nodes.forEach((key, value) {
      chainsKeys.add(StringUtil.getWithoutTypeName(key));
      chainsValues.add(value.toString());
    });
    return PlatformScaffold(
        material: (_,__) => MaterialScaffoldData(resizeToAvoidBottomInset: false),
        cupertino: (_,__) => CupertinoPageScaffoldData(resizeToAvoidBottomInset: false),
        appBar: PlatformAppBar(
          //automaticallyImplyLeading: true,
          title: Text("Edit", style: TextStyle(color: Colors.white)),
          trailingActions: <Widget>[
            PlatformIconButton(
                cupertino: (_,__) => CupertinoIconButtonData(
                  icon: Icon(
                      CupertinoIcons.delete,
                      color: Colors.white,
                      size: 30
                  ),
                  padding: EdgeInsets.only(right: 20),
                ),
                materialIcon: Icon(Icons.delete_outline, size: 35.0),
                material: (_,__) => MaterialIconButtonData(tooltip: 'Delete'),
                onPressed: () {
                  /*final page = Settings();
                Navigator.of(context).push(SlideToSideRoute(page));
              */
                }),
            PlatformIconButton(
                cupertino: (_,__) => CupertinoIconButtonData(
                  icon: Icon( // Save icon
                      const IconData(0xf41F, fontPackage: CupertinoIcons.iconFontPackage, fontFamily: CupertinoIcons.iconFont),
                      color: Colors.white,
                      size: 35
                  ),
                  padding: EdgeInsets.all(0),
                ),
                androidIcon: Icon(Icons.save, size: 35.0),
                material: (_, __) => MaterialIconButtonData(tooltip: 'Save'),
                onPressed: () {
                  onButtonPressedSave(context);
                  /*final page = Settings();
                Navigator.of(context).push(SlideToSideRoute(page));
              */
                })
          ],
        ),
        body: WillPopScope(
          onWillPop: () => onWillPop(context),
          child: Form(
              key: _formKey,
              child:
              CardSettings(
                  children: <CardSettingsSection>[
                    CardSettingsSection(
                      children: <CardSettingsWidget>[
                        CardSettingsText(
                            label: 'Name',
                            contentAlign: TextAlign.right,
                            initialValue: storageNode.nameWithUrl(),
                            autovalidate: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                this.storageNode.setValidationError("name", "Field 'Title' is empty.");
                                return 'Title is required.';
                              }
                              this.storageNode.setValidationCorrect("name");
                              this.currentUpdatedValues.host = value;
                              return null;
                            }
                        ),
                        CardSettingsText(
                            label: 'Host',
                            contentAlign: TextAlign.right,
                            initialValue: storageNode.host,
                            autocorrect: false,
                            autovalidate: true,
                            validator: (value) {
                              if (!(value.startsWith('http:') || value.startsWith('https:'))) {
                                this.storageNode.setValidationError("host", "Field 'Host' is not valid.");
                                return "Host must start with 'http(s)://'";
                              }
                              this.storageNode.setValidationCorrect("host");
                              this.currentUpdatedValues.host = value;
                              return null;
                            }
                        ),
                        CardSettingsInt(
                            label: 'Port',
                            contentAlign: TextAlign.right,
                            initialValue: storageNode.port,
                            //autovalidate: true,
                            validator: (value) {
                              if (value == null)
                              {
                                this.storageNode.setValidationError("port", "Field 'post' is empty.");
                                return 'There must be a value.';//cd android && ./gradlew clean


                              }
                              if (value < 0)
                              {
                                this.storageNode.setValidationError("port", "Field 'post' is negative.");
                                return 'Port need to be unsigned.';
                              }
                              this.storageNode.setValidationCorrect("port");
                              this.currentUpdatedValues.port = value;
                              return null;
                            }
                        ),
                        CardSettingsSwitch(
                          label: 'Encrypted connection',
                          contentAlign: TextAlign.right,
                          initialValue: storageNode.isEncryptedEndpoint,
                          onSaved: (value) =>
                          this.currentUpdatedValues.isEncryptedEndpoint = value,
                        ),
                        /*CardSettingsText(
                  label: 'Chain ID',
                  contentAlign: TextAlign.right,
                  initialValue: storageNode.network.chainID,
                  enabled: this.currentUpdatedValues.network.networkType == NetworkType.CUSTOM? true : false,
                  visible: this.currentUpdatedValues.network.networkType == NetworkType.CUSTOM? true : false,
                  autovalidate: true,
                  validator: (value) {
                    if (this.currentUpdatedValues.network.networkType !=
                        NetworkType.CUSTOM)
                      return "You cannot change chain id. Network type is not selected as custom.";
                    return null;
                  },
                  onSaved: (value) {
                    if (this.currentUpdatedValues.network.networkType ==
                        NetworkType.CUSTOM)
                      this.currentUpdatedValues.network.chainID = value;
                  }),*/
                      ],
                    ),
                  ]
              )
          ),
        ));
  }
}
