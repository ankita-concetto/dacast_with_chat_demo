package decast_player_plugin.android.src.main.java.com.example.decast_player_plugin.decast_player_plugin;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.theoplayer.android.api.THEOplayerConfig;
import com.theoplayer.android.api.THEOplayerView;
import com.theoplayer.android.api.player.track.texttrack.TextTrackKind;
import com.theoplayer.android.api.source.SourceDescription;
import com.theoplayer.android.api.source.TextTrackDescription;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.ref.WeakReference;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

class DownloadImageTask extends AsyncTask<String, Void, Bitmap> {
    private final WeakReference<ImageView> bmImage;

    public DownloadImageTask(ImageView bmImage) {
        this.bmImage = new WeakReference<>(bmImage);
    }

    protected Bitmap doInBackground(String... urls) {
        try {
            InputStream in = new URL(urls[0]).openStream();
            return BitmapFactory.decodeStream(in);
        } catch (Exception e) {
            Log.e("Error", e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    protected void onPostExecute(Bitmap result) {
        bmImage.get().setImageBitmap(result);
    }
}

class ContentInfoResponse {
    ContentInfo contentInfo;
}

class ContentInfo {
    String splashscreenUrl;
    Features features;
}

class Features {
    Watermark watermark;
    ArrayList<Subtitle> subtitles;
}

class Subtitle {
    String languageLongName;
    String languageShortName;
    String sourceVtt;
}

class Watermark {
    String imageUrl;
}

class PlaybackUrlResponse {
    String hls;
    String mp4;
}

class ContentInfoBlob {
    PlaybackUrlResponse playback;
    ContentInfo info;

    ContentInfoBlob(PlaybackUrlResponse playback, ContentInfo info){
        this.playback = playback;
        this.info = info;
    }
}

public class DacastPlayer implements PlatformView, MethodChannel.MethodCallHandler {
    private final MethodChannel methodChannel;
    private static final String URL_BASE = "https://playback.dacast.com";

    private final THEOplayerView theoplayer;
    private final RelativeLayout layout;
    private final ImageView watermarkImage;

    public DacastPlayer(Context activity, String contentIdStr, BinaryMessenger messenger, int id) {
        this(activity, contentIdStr, null,messenger,id);
    }

    public DacastPlayer(Context activity, String contentId, String adUrl, BinaryMessenger messenger, int id) {
        theoplayer = new THEOplayerView(activity, (AttributeSet) null);
        methodChannel = new MethodChannel(messenger, "dacast_player_view_" + id);
        methodChannel.setMethodCallHandler(this);
        watermarkImage = new ImageView(activity);
        layout = new RelativeLayout(activity);

        watermarkImage.setClickable(false);
        watermarkImage.setFocusable(false);

        RelativeLayout.LayoutParams paramsPlayer = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);
        paramsPlayer.leftMargin = 0;
        paramsPlayer.topMargin = 0;
        layout.addView(theoplayer, paramsPlayer);

        RelativeLayout.LayoutParams paramsImage = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);
        paramsImage.leftMargin = 50;
        paramsImage.topMargin = 10;
        layout.addView(watermarkImage, paramsImage);
        watermarkImage.setImageAlpha(90);

        fetchVideoInfo(contentId, adUrl);
    }

    public View getView(){
        return layout;
    }

    @Override
    public void dispose() {

    }

    public THEOplayerView getTHEOplayer(){
        return theoplayer;
    }

    public void onPause() {
        theoplayer.onPause();
    }

    public void onResume() {
        theoplayer.onResume();
    }

    public void onDestroy() {
        theoplayer.onDestroy();
    }

    private void fetchVideoInfo(final String contentId, final String adUrl){
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    String rawContentInfo = httpGet( URL_BASE + "/content/info?provider=universe&contentId=" + contentId);
                    String rawPlaybackUrl = httpGet(URL_BASE + "/content/access?provider=universe&contentId=" + contentId);

                    Gson gson = new Gson();
                    ContentInfoResponse contentInfoResp = gson.fromJson(rawContentInfo, ContentInfoResponse.class);
                    PlaybackUrlResponse playbackUrl = gson.fromJson(rawPlaybackUrl, PlaybackUrlResponse.class);

                    Handler handler = new Handler(Looper.getMainLooper(), message -> {
                        ContentInfoBlob blob = (ContentInfoBlob)message.obj;

                        String sourceUrl = blob.playback.hls;
                        if (sourceUrl == null) {
                            sourceUrl = blob.playback.mp4;
                        }

                        SourceDescription.Builder sourceDescription = SourceDescription.Builder
                            .sourceDescription(sourceUrl)
                            .poster(blob.info.splashscreenUrl);

                        if(adUrl != null){
                            sourceDescription.ads(adUrl);
                        }

                        TextTrackDescription[] subtitleArray = new TextTrackDescription[blob.info.features.subtitles.size()];
                        for (int i = 0; i < blob.info.features.subtitles.size(); i++) {
                            Subtitle sub = blob.info.features.subtitles.get(i);
                            TextTrackDescription textTrack = new TextTrackDescription(
                                sub.sourceVtt,
                                false,
                                TextTrackKind.SUBTITLES,
                                sub.languageShortName,
                                sub.languageLongName
                            );
                            subtitleArray[i] = textTrack;
                        }
                        if(subtitleArray.length != 0) {
                            sourceDescription.textTracks(subtitleArray);
                        }

                        theoplayer.getPlayer().setSource(sourceDescription.build());

                        return true;
                    });

                    handler.sendMessage(handler.obtainMessage(0, new ContentInfoBlob(playbackUrl, contentInfoResp.contentInfo)));

                    if(contentInfoResp.contentInfo.features.watermark != null && contentInfoResp.contentInfo.features.watermark.imageUrl != null){
                        new DownloadImageTask(watermarkImage).execute(contentInfoResp.contentInfo.features.watermark.imageUrl);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    private static String httpGet(String urlToRead) throws Exception {
        StringBuilder result = new StringBuilder();
        URL url = new URL(urlToRead);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        BufferedReader rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        String line;
        while ((line = rd.readLine()) != null) {
            result.append(line);
        }
        rd.close();
        return result.toString();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {

    }
}
