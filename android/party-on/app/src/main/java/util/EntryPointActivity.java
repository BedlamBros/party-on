package util;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;

import net.john.partyon.R;

/**
 * Created by John on 9/14/2015.
 */
public class EntryPointActivity extends Activity {

    public void onCreate(Bundle savedInstance){
        super.onCreate(savedInstance);
        if (getSharedPreferences(
                getString(R.string.preferences_cached_model_userId), Context.MODE_PRIVATE)
            .equals("")){
            //new user has started the app

        }

    }
}
