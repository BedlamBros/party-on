package ui;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.login.LoginResult;
import com.facebook.login.widget.LoginButton;

import net.john.partyon.R;

/**
 * Created by John on 9/4/2015.
 */
public class ToolbarFragment extends Fragment {
    LoginButton mLoginButton;

    @Override
    public View onCreateView(
            LayoutInflater inflater,
            ViewGroup container,
            Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_toolbar, container, false);

        mLoginButton = (LoginButton) view.findViewById(R.id.login_button);
        mLoginButton.setReadPermissions("user_friends");
        // If using in a fragment
        mLoginButton.setFragment(this);
        // Other app specific specialization

        CallbackManager callbackManager = CallbackManager.Factory.create();

        // Callback registration
        mLoginButton.registerCallback(callbackManager, new FacebookCallback<LoginResult>() {
            @Override
            public void onSuccess(LoginResult loginResult) {
                // App code
            }

            @Override
            public void onCancel() {
                // App code
            }

            @Override
            public void onError(FacebookException exception) {
                // App code
            }
        });

        return inflater.inflate(R.layout.fragment_toolbar, container, false);
    }
}
