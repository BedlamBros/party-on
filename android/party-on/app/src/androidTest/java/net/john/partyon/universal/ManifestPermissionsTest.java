package net.john.partyon.universal;

import android.app.Activity;
import android.app.Application;
import android.content.pm.PackageManager;
import android.test.ApplicationTestCase;

import java.security.Permission;

/**
 * Created by John on 9/2/2015.
 */
public class ManifestPermissionsTest extends ApplicationTestCase<Application> {
    private final String INTERNET_PERMISSION = "android.permission.INTERNET";
    private final String LOCATION_FINE_PERMISSION = "android.permission.ACCESS_FINE_LOCATION";
    private final String VIBRATE_PERMISSION = "android.permission.VIBRATE";

    int res_internet;
    int res_loc;
    int res_vibrate;

    private int mValid_response;

    Application mApplication;

    public ManifestPermissionsTest() {
        super(Application.class);
    }

    protected void setUp() throws Exception{
        mApplication = getApplication();
        res_internet = getContext().checkCallingOrSelfPermission(INTERNET_PERMISSION);
        res_loc = getContext().checkCallingOrSelfPermission(LOCATION_FINE_PERMISSION);
        res_vibrate = getContext().checkCallingOrSelfPermission(VIBRATE_PERMISSION);

        mValid_response = PackageManager.PERMISSION_GRANTED;
    }

    protected void runTest(){
        assertEquals(res_internet, mValid_response);
        assertEquals(res_loc, mValid_response);
        assertEquals(res_vibrate, mValid_response);
    }
}
