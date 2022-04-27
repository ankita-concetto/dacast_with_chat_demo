package decast_player_plugin.android.src.main.java.com.example.decast_player_plugin.decast_player_plugin;

import android.content.Context;
import android.util.Log;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class DecastPlayerFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;

    public DecastPlayerFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int id, Object o) {
        return new DacastPlayer(
                context,
                "c9e6961e-40a3-2bdc-5f4f-b2a7a65bc2aa-live-4a2cf618-8ac7-fd40-1db6-01580c8a3f28" /*,
            "https://cdn.theoplayer.com/demos/preroll.xml"*/,
                messenger,id
        );
    }
}
