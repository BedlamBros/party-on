package receive;

import android.app.ListActivity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ListView;

import com.facebook.FacebookSdk;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.widget.LoginButton;

import net.john.partyon.R;

import java.util.ArrayList;

import models.Party;
import submit.SubmitPartyActivity;
import util.VibrateClickResponseListener;

/**
 * Created by John on 8/31/2015.
 */
public class ListPartyActivity extends ListActivity {
    final String DUMMY_FILENAME = "dummy.json";
    private ListView list;
    private ArrayList<Party> mParty_list;
    private ListPartyAdapter mListPartyAdapter;

    ApiPartyListReader mApiPartyListReader;

    //handles the vibrating response on the ic_add_party button
    VibrateClickResponseListener mVibrate_response_listener;

    @Override
    public void onCreate(Bundle saved_instance){
        super.onCreate(saved_instance);

        //initialize the Facebook sdk to get the login button
        FacebookSdk.sdkInitialize(this);

        setContentView(R.layout.party_list);

        list = (ListView) findViewById(android.R.id.list);
        Log.d("receive", "list to string = " + list.toString());

        new Thread(ApiPartyListReader.getInstance(getApplicationContext())).start();

        //used only for testing w/o server
       // DummyReader mDummy_reader = new DummyReader(DUMMY_FILENAME, this);
       // mParty_list = new ArrayList<Party>(mDummy_reader.getPartyList());

        //set the adapter to propagate list from party_list
        //mListPartyAdapter = new ListPartyAdapter(getApplicationContext(), mParty_list);
       // list.setAdapter(mListPartyAdapter);

        //instantiate the response listener now while not doing anything
        mVibrate_response_listener = new VibrateClickResponseListener(this);
    }

    @Override
    public void onResume(){
        super.onResume();
        //AppEventsLogger.activateApp(this); //used for facebook analytics
    }

    @Override
    public void onPause(){
        super.onPause();
        //AppEventsLogger.deactivateApp(this); //used for facebook analytics
    }

    public void onAddPartyClick(View view){
        //call the vibrating response
        mVibrate_response_listener.getVibratingClickListener().onClick(view);

        //start the SubmitPartyActivity
        Intent i = new Intent(ListPartyActivity.this, SubmitPartyActivity.class);
        ListPartyActivity.this.startActivity(i);
    }

    public void onHamburgerClick(View view){
        //TODO start the preference fragment here
    }

    public ListPartyAdapter getListAdapter(){
        return mListPartyAdapter;
    }
}
