package receive;

import android.app.ProgressDialog;
import android.content.AsyncQueryHandler;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
import android.widget.ListView;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import net.john.partyon.R;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;

import models.Party;
import util.ApiController;

/**
 * Created by John on 9/2/2015.
 */
public class ApiPartyListReader implements PartyListLoadable {
    private final String ENDPOINT = "/parties/university";
    private final String UNIVERSITY = "/Indiana%20University";

    private String mApiUrl;
    private Context mContext;
    private static ApiPartyListReader mInstance;
    private ListView listView;
    ApiController mApiController;

    private boolean hasRun = false;

    //should this be volatile?
    ListPartyAdapter listPartyAdapter;

    protected ApiPartyListReader(){
        //defeat instantiation
    }

    private ApiPartyListReader(Context ctx, ListPartyAdapter listPartyAdapter, ListView listView){
        this.mContext = ctx;
        mApiUrl = ctx.getResources().getString(R.string.api_url);
        this.listPartyAdapter = listPartyAdapter;
        this.listView = listView;
    }

    //returns listPartyAdapter asynchronously
    public static ApiPartyListReader getInstance(Context ctx, ListPartyAdapter listPartyAdapter, ListView listView){
        if (mInstance == null){
            mInstance = new ApiPartyListReader(ctx, listPartyAdapter, listView);
        }
        return mInstance;
    }

    //this method is what implements the interface getPartyList pattern
    //all the try/catch blocks make this difficult to read
    //TODO split up actions into separate functions for unit tests
    private ArrayList<Party> getPartyList() {
        //this object will be returned
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
                    Log.d("json", "received " + jsonArray.size() + " parties from server");
                    if (jsonArray.size() > 0){
                        partyList = new ArrayList<Party>();
                        for (int i = 0; i < jsonArray.size(); i++){
                            Party iterParty = Party.PartyFactory.create((JsonObject) jsonArray.get(i));
                            Log.d("json", iterParty.toString());
                            partyList.add(Party.PartyFactory.create((JsonObject) jsonArray.get(i)));
                        }
                        //after creating the party_list, set it as the adapter's list or notify changed
                        if (!hasRun){
                            listPartyAdapter = new ListPartyAdapter(mContext, partyList);
                            listView.setAdapter(listPartyAdapter);
                            hasRun = true;
                        } else {
                            ((ListPartyActivity) mContext).getListAdapter().notifyDataSetChanged();
                        }
                    } else {
                        Log.wtf("json", "result array was empty");
                    }
                } else {
                    Log.e(ApiPartyListReader.class.toString(), "Failed JSON object");
                }
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        return null;
    }
}
