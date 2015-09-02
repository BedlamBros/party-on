package util;

import android.content.Context;
import android.os.Vibrator;
import android.view.View;

/**
 * Created by John on 8/20/2015.
 */
public class VibrateClickResponseListener {
    final int VIBE_MILLIS = 50;
    private Vibrator vibe;

    public VibrateClickResponseListener(Context ctx){
        //make available to all packages
        vibe = (Vibrator) ctx.getSystemService(Context.VIBRATOR_SERVICE);
    }

    public boolean hasVibrator(){
        return vibe.hasVibrator();
    }

    public View.OnClickListener getVibratingClickListener(){
        return new View.OnClickListener(){
            public void onClick(View v){
                vibe.vibrate(VIBE_MILLIS);
            }
        };
    }
}
