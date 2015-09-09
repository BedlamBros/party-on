package submit;

import android.content.Context;
import android.util.Log;

import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.login.LoginResult;

/**
 * Created by John on 9/8/2015.
 */
public class FacebookLoginCallback implements FacebookCallback<LoginResult> {
    private Context mContext;

    public FacebookLoginCallback(Context ctx){
        super();
        mContext = ctx;
    }

    public void onSuccess(LoginResult loginResult){
        Log.d("auth", "succesful login returned this token " + loginResult.toString());
    }

    public void onCancel(){
        Log.wtf("auth", "facebook login lifecycle was canceled");
    }

    public void onError(FacebookException ex){
        ex.printStackTrace();
    }
}
