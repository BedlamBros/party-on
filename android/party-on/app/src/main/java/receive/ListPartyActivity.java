package receive;

import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.app.ListActivity;
import android.content.ContentResolver;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;

import com.facebook.FacebookSdk;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.widget.LoginButton;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import net.john.partyon.R;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;

import models.Party;
import submit.ApiObject;
import submit.SubmitPartyActivity;
import util.VibrateClickResponseListener;

/**
 * Created by John on 8/31/2015.
 */
public class ListPartyActivity extends ListActivity {
    final String DUMMY_FILENAME = "dummy.json";

    //get views and viewgrous here
    private ListView list;
    private SwipeRefreshLayout mSwipeRefreshLayout;
    private ArrayList<Party> mParty_list;
    private ListPartyAdapter mListPartyAdapter;

    //handles the vibrating response on the ic_add_party button
    VibrateClickResponseListener mVibrate_response_listener;

    @Override
    public void onCreate(Bundle saved_instance){
        super.onCreate(saved_instance);

        //initialize the Facebook sdk to get the login button
        FacebookSdk.sdkInitialize(this);

        setContentView(R.layout.party_list);

        //TODO use a FragmentManager transaction to load the toolbar

        list = (ListView) findViewById(android.R.id.list);
        mSwipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.swipe_refresh_layout);

        mParty_list = new ArrayList<Party>();
        mListPartyAdapter = new ListPartyAdapter(getApplicationContext(), mParty_list);
        //list.setAdapter(mListPartyAdapter);
        list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Log.d("receive", "clicked on listview item " + position);
                Party party = mParty_list.get(position);
                Intent mIntent = new Intent(view.getContext(), ViewPartyActivity.class);
                Log.d("party_detail", "ListPartyAdapter setting party_extra: " + party.toString());
                mIntent.putExtra(getResources().getString(R.string.party_extra_name), party);
                startActivity(mIntent);
            }

            @Override
            public String toString(){
                return "this is overriding the onItemClickListener's behavior";
            }
        });

        Log.d("receive", list.getOnItemClickListener().toString());

        //set the swipe refresh listener
        mSwipeRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                Log.d("receive", "swipe requested");
                refreshPartyList();
            }
        });

        //instantiate the response listener now while not doing anything
        mVibrate_response_listener = new VibrateClickResponseListener(this);

        refreshPartyList();
    }

    @Override
    public void onResume(){
        super.onResume();
        refreshPartyList();
        //AppEventsLogger.activateApp(this); //used for facebook analytics
    }

    @Override
    public void onPause(){
        super.onPause();
        //AppEventsLogger.deactivateApp(this); //used for facebook analytics
    }

    public void refreshPartyList() {
        mListPartyAdapter.notifyDataSetChanged();
        final AsyncLoadJson mApiObjectLoader = new AsyncLoadJson(){
           public void onResponseReceived(ArrayList<Party> apiObject){
               Log.d("receive", "response received on UI thread");
               mParty_list = apiObject;
               list.setAdapter(new ListPartyAdapter(getApplicationContext(), mParty_list));
           }

            public void onPostExecute(ArrayList<Party> partyArrayList){
                this.onResponseReceived(partyArrayList);
                mSwipeRefreshLayout.setRefreshing(false);
                Log.d("receive", "partylist size " + mParty_list.size());
                Log.d("receive", "list adapter can see " + mListPartyAdapter.getCount());
            }
        };
        mApiObjectLoader.execute();
    }

    //this interface communicates between thread
    public interface ClientIF {
        void onResponseReceived(ArrayList<Party> apiObject);
    }

    private abstract class AsyncLoadJson extends AsyncTask<Void, Void, ArrayList<Party>> implements ClientIF{
        final String ENDPOINT = "/parties/university";
        final String UNIVERSITY = "/Indiana%20University";
        final String mApiUrl = "http://ec2-52-10-210-220.us-west-2.compute.amazonaws.com/api";

        protected ArrayList<Party> doInBackground(Void... mVoid){
            ArrayList<Party> partyList;
            //this will accept lines of json as they arrive
            StringBuilder builder = new StringBuilder();
            DefaultHttpClient httpClient = new DefaultHttpClient();
            String requestUri = mApiUrl + ENDPOINT + UNIVERSITY;
            Log.d("http", "making http GET request to " + requestUri);
            HttpGet httpGet = new HttpGet(requestUri);
            try {
                HttpResponse httpResponse = httpClient.execute(httpGet);
                StatusLine statusLine = httpResponse.getStatusLine();
                if (statusLine.getStatusCode() == 200) {
                    HttpEntity entity = httpResponse.getEntity();
                    InputStream content = entity.getContent();
                    BufferedReader reader = new BufferedReader(new InputStreamReader(content));
                    String line;
                    while ((line = reader.readLine()) != null) {
                        builder.append(line);
                    }
                    Log.d("json", builder.toString());
                    JsonObject json = (JsonObject) new JsonParser().parse(builder.toString());
                    JsonArray jsonArray = (JsonArray) json.get("parties");
                    //Log.d("json", "received " + jsonArray.size() + " parties from server");
                    if (jsonArray.size() > 0){
                        partyList = new ArrayList<Party>();
                        for (int i = 0; i < jsonArray.size(); i++){
                            Party iterParty = Party.PartyFactory.create((JsonObject) jsonArray.get(i));
                            //Log.d("json", iterParty.toString());
                            partyList.add(Party.PartyFactory.create((JsonObject) jsonArray.get(i)));
                        }
                        return partyList;
                    } else {
                        Log.wtf("json", "result array was empty");
                    }
                } else {
                    return null;
                }
            } catch (IOException ex) {
                ex.printStackTrace();
            }
            return null;
        }

        protected void onPostExecute(ArrayList<Party> resPartyList){
            Log.d("receive", resPartyList.size() + " found on async call");
        }

        public abstract void onResponseReceived(ArrayList<Party> apiObject);
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
