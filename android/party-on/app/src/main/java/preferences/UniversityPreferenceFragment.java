package preferences;

import android.os.Bundle;
import android.preference.Preference;
import android.preference.PreferenceFragment;

import net.john.partyon.R;

/**
 * Created by John on 9/2/2015.
 * This class implements the singleton pattern and is used to display the
 * university preference list to the user
 */
public class UniversityPreferenceFragment extends PreferenceFragment {

    private  static UniversityPreferenceFragment mInstance = null;

    public UniversityPreferenceFragment(){
        //do nothing
    }

    public static UniversityPreferenceFragment getInstance(){
        if (mInstance == null){
            mInstance = new UniversityPreferenceFragment();
        }
        return mInstance;
    }

    public void onCreate(Bundle saved_instance){
        super.onCreate(saved_instance);
        addPreferencesFromResource(R.xml.fragment_preference);
    }

}
