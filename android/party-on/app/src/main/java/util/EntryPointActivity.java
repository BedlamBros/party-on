package util;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.Log;

import net.john.partyon.R;

import java.util.ArrayList;

import ui.EulaFragment;

/**
 * Created by John on 9/14/2015.
 */
public class EntryPointActivity extends FragmentActivity {
    //used for the device login
    private boolean isFirstTimeUser;
    private final int NUM_PAGES = 4;
    private final FragmentManager mFragmentManager = getSupportFragmentManager();

    public void onCreate(Bundle savedInstance) {
        super.onCreate(savedInstance);
        setContentView(R.layout.activity_entry_point);
        isFirstTimeUser = (getSharedPreferences(
                getString(R.string.preferences_cached_model_userId), Context.MODE_PRIVATE)
                .equals(""));

        ViewPager mViewPager = (ViewPager) findViewById(R.id.pager);
        mFragmentManager.beginTransaction().add(R.id.pager, new EulaFragment()).commit();
    }
}

