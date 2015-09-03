package util;

import android.content.Context;
import android.os.Vibrator;
import android.view.View;

import net.john.partyon.R;

/**
 * Created by John on 8/20/2015.
 */
public class VibrateClickResponseListener {
    private int vibe_millis;
    private Vibrator vibe;

    public VibrateClickResponseListener(Context ctx){
        //make available to all packages
        vibe = (Vibrator) ctx.getSystemService(Context.VIBRATOR_SERVICE);
        vibe_millis = ctx.getResources().getInteger(R.integer.vibrate_ms_length);
    }

    public boolean hasVibrator(){
        return vibe.hasVibrator();
    }

    public View.OnClickListener getVibratingClickListener(){
        return new View.OnClickListener(){
            public void onClick(View v){
                vibe.vibrate(vibe_millis);
            }
        };
    }
}
