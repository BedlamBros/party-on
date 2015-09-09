package ui;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.facebook.login.widget.LoginButton;

import net.john.partyon.R;

/**
 * Created by John on 9/4/2015.
 */
public class ToolbarFragment extends FragmentActivity {
    LoginButton mLoginButton;

    public void onCreate(Bundle savedInstance){
        super.onCreate(savedInstance);
        mLoginButton = (LoginButton) findViewById(R.id.facebook_auth_bttn);
    }
}
