///
/// [Author] Alex (https://github.com/Alex525)
/// [Date] 2020/3/31 16:27
///
import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/constants.dart';

class AssetPickerViewer<Asset, Path> extends StatefulWidget {
  const AssetPickerViewer({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final AssetPickerViewerBuilderDelegate<Asset, Path> builder;

  @override
  AssetPickerViewerState<Asset, Path> createState() =>
      AssetPickerViewerState<Asset, Path>();

  /// Static method to push with the navigator.
  /// 跳转至选择预览的静态方法
  static Future<List<AssetEntity>?> pushToViewer(
      BuildContext context, {
        int currentIndex = 0,
        required List<AssetEntity> previewAssets,
        required ThemeData themeData,
        DefaultAssetPickerProvider? selectorProvider,
        List<int>? previewThumbSize,
        List<AssetEntity>? selectedAssets,
        SpecialPickerType? specialPickerType,
        int? maxAssets,
        bool shouldReversePreview = false,
        AssetSelectPredicate<AssetEntity>? selectPredicate,
        //===============lxy==0324========start====
        ValueChanged<String>? downLoads,
        //===============lxy==0324========end====
        //===============zq==0412========start====
        ValueChanged<String>? switchVideoPlayerAction,//用于播放视频有问题时使用其他播放器播放
        //===============zq==0412========end====
      }) async {
    await AssetPicker.permissionCheck();
    final Widget viewer = AssetPickerViewer<AssetEntity, AssetPathEntity>(
      builder: DefaultAssetPickerViewerBuilderDelegate(
        currentIndex: currentIndex,
        previewAssets: previewAssets,
        provider: selectedAssets != null
            ? AssetPickerViewerProvider<AssetEntity>(selectedAssets)
            : null,
        themeData: themeData,
        previewThumbSize: previewThumbSize,
        specialPickerType: specialPickerType,
        selectedAssets: selectedAssets,
        selectorProvider: selectorProvider,
        maxAssets: maxAssets,
        shouldReversePreview: shouldReversePreview,
        selectPredicate: selectPredicate,
        //===============lxy==0324========start====
        downLoad:downLoads==null?null:(e){
          if(downLoads != null){
            downLoads(e);
          }
        },
        //===============lxy==0324========end====
        // ===============zq==0412========start====
        switchVideoPlayer:switchVideoPlayerAction==null?null:(e){
          if(switchVideoPlayerAction != null){
            switchVideoPlayerAction(e);
          }
        },
        //===============zq==0412========end====
      ),
    );
    final PageRouteBuilder<List<AssetEntity>> pageRoute =
    PageRouteBuilder<List<AssetEntity>>(
      pageBuilder: (_, __, ___) => viewer,
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
    final List<AssetEntity>? result =
    await Navigator.of(context).push<List<AssetEntity>>(pageRoute);
    return result;
  }

  /// Call the viewer with provided delegate and provider.
  /// 通过指定的 [delegate] 调用查看器
  static Future<List<A>?> pushToViewerWithDelegate<A, P>(
      BuildContext context, {
        required AssetPickerViewerBuilderDelegate<A, P> delegate,
      }) async {
    await AssetPicker.permissionCheck();
    final Widget viewer = AssetPickerViewer<A, P>(builder: delegate);
    final PageRouteBuilder<List<A>> pageRoute = PageRouteBuilder<List<A>>(
      pageBuilder: (_, __, ___) => viewer,
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
    final List<A>? result = await Navigator.of(context).push<List<A>>(
      pageRoute,
    );
    return result;
  }
}

class AssetPickerViewerState<Asset, Path>
    extends State<AssetPickerViewer<Asset, Path>>
    with TickerProviderStateMixin {
  AssetPickerViewerBuilderDelegate<Asset, Path> get builder => widget.builder;

  @override
  void initState() {
    super.initState();
    builder.initStateAndTicker(this, this);
  }

  @override
  void dispose() {
    builder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return builder.build(context);
  }
}
