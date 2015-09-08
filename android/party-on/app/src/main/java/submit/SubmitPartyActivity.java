package submit;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.TimePicker;

import com.google.gson.JsonObject;

import net.john.partyon.R;

import java.text.SimpleDateFormat;
import java.util.Date;

import models.Party;

/**
 * Created by John on 9/2/2015.
 */
public class SubmitPartyActivity extends Activity {
    // these vals are packaged in the json
    //private String mTitle;
    private String mDesc;
    private float mLat;
    private float mLon;

    private ApiObjectSubmitter mApiObjectSubmitter;
    private long ms_end_offset;

    private Party apiParty;

    //helpful for iterating through required views
    private final int REQUIRED_ETS = 2;
    private final int REQUIRED_TPS = 1;

    private EditText mColloq_name_et;
    private EditText mDesc_et;
    private EditText mAddress_et;
    private TimePicker mTimePicker_start;
    private TimePicker mTimePicker_end;

    private View[] required_views = new View[4];
    private boolean submittable = false;

    private Button mSubmit_button;

    @Override
    public void onCreate(Bundle saved_instance){
        super.onCreate(saved_instance);
        setContentView(R.layout.activity_submit_party);

        //get all relevant views from the layout
        mColloq_name_et = (EditText) findViewById(R.id.submit_form_edit_title);
        mDesc_et = (EditText) findViewById(R.id.submit_form_edit_desc);
        mAddress_et = (EditText) findViewById(R.id.submit_form_edit_loc);
        mTimePicker_start = (TimePicker) findViewById(R.id.submit_form_edit_starts_at);
        mTimePicker_end = (TimePicker) findViewById(R.id.submit_form_edit_ends_at);

        //get the submit button
        mSubmit_button = (Button) findViewById(R.id.submit_button);

        //add a listener to the textview
        mColloq_name_et.setOnEditorActionListener(mEditorListener);
        mDesc_et.setOnEditorActionListener(mEditorListener);

        //enumerate required views
        required_views[0] = mColloq_name_et;
        required_views[1] = mDesc_et;
        required_views[2] = mTimePicker_start;

        //first item requests focus
        required_views[0].requestFocus();

        //get hours offset
        ms_end_offset = getResources().getInteger(R.integer.ends_at_offset_hours) * 1000 * 60 + 60;
        setTimePickerOffsets();
    }

    private void drawSubmitButton(){
        for (int i = 0; i < required_views.length; i++){
            if (i < REQUIRED_ETS){
                //check required edittexts
                //TODO load strings at onCreate
                submittable = !(((TextView) required_views[i]).getText().equals("") ||
                        ((TextView) required_views[i]).getText().equals(getResources().getString(R.string.party_title_default)));
            } else {
                //check required timepickers
                submittable = required_views[i].isDirty();
            }
        }
    }

    public void onSubmitButtonClick(View view){
        Log.d("submit", "submit button clicked");
        mApiObjectSubmitter = new ApiObjectSubmitter();
        Party mParty = new Party(mColloq_name_et.getText().toString(), mDesc_et.getText().toString(), "420 N Jefferson");
        String jsonObject = mParty.toJson();
        mApiObjectSubmitter.execute(jsonObject);
    }

    public void onGetLocationClick(View view){
        //TODO use device LOCATION_FINE api to get last loc

    }

    public View[] getRequiredView(){
        return this.required_views;
    }

    //anonymous editor listener
    private TextView.OnEditorActionListener mEditorListener = new TextView.OnEditorActionListener(){
        @Override
        public boolean onEditorAction(TextView v, int actionId, KeyEvent event){
            if (actionId == EditorInfo.IME_ACTION_DONE){
                drawSubmitButton();
                //return true to indicate action taken
                return true;
            }
            return false;
        }
    };

    private void setTimePickerOffsets(){
        Date mSimple_curr_date = new Date(System.currentTimeMillis() + ms_end_offset);
        mTimePicker_end.setCurrentHour(mSimple_curr_date.getHours());
    }
}
