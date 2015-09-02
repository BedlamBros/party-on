package exceptions;

import android.content.Context;
import android.util.Log;

/**
 * Created by John on 9/1/2015.
 */
public class PartyNotFoundException extends Exception {
    private Context mExceptionContext;

    public PartyNotFoundException(String string){
        super();
        Log.wtf("PartyNotFound", "messaged provided: " + string);
    }

    public PartyNotFoundException(Context context){
        super();
        mExceptionContext = context;
        Log.wtf("PartyNotFound", "context of exception is " + context.toString());
    }
}
