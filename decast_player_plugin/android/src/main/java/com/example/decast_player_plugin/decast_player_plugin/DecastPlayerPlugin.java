package decast_player_plugin.android.src.main.java.com.example.decast_player_plugin.decast_player_plugin;

import io.flutter.plugin.common.PluginRegistry;

/** DecastPlayerPlugin */
public class DecastPlayerPlugin {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  /*private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "dacast_player_view");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }*/

  public static void registerWith(PluginRegistry.Registrar registrar) {
    registrar
            .platformViewRegistry()
            .registerViewFactory(
                    "dacast_player_view", new DecastPlayerFactory(registrar.messenger()));
  }
}
