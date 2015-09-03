package net.john.partyon.receive;

import android.hardware.camera2.params.Face;
import android.test.ActivityInstrumentationTestCase2;

import com.facebook.login.widget.LoginButton;

import net.john.partyon.R;

import java.util.List;

import receive.ListPartyActivity;

/**
 * Created by John on 9/3/2015.
 * This tests the existence as well as the functionality of the facebook login button
 */
public class FacebookLoginButtonTest extends ActivityInstrumentationTestCase2<ListPartyActivity> {
    private ListPartyActivity mListPartyActivity;
    private LoginButton mLoginButton;

    public FacebookLoginButtonTest(Class<ListPartyActivity> listPartyActivityClass){
        super(listPartyActivityClass);
    }

    @Override
    public void setUp(){
        mListPartyActivity = getActivity();
        mLoginButton = (LoginButton) mListPartyActivity.findViewById(R.id.facebook_auth_bttn);
    }

    @Override
    public void runTest(){
        assertNotNull(mLoginButton);
    }
}
