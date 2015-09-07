package receive;

import android.content.Context;
import android.util.Log;

import net.john.partyon.R;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONException;
import org.json.JSONObject;

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
public class ApiPartyListReader implements PartyListLoadable, Runnable {
    private final String ENDPOINT = "/parties/university";
    private final String UNIVERSITY = "/Indiana%20University";

    private String mApiUrl;
    private Context mContext;
    private static ApiPartyListReader mInstance;
    ApiController mApiController;

    protected ApiPartyListReader(){
        //defeat instantiation
    }

    private ApiPartyListReader(Context ctx){
        this.mContext = ctx;
        mApiUrl = ctx.getResources().getString(R.string.api_url);
    }

    public static ApiPartyListReader getInstance(Context ctx){
        if (mInstance == null){
            mInstance = new ApiPartyListReader(ctx);
        }
        return mInstance;
    }

    public ArrayList<Party> getPartyList() {
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
                } else {
                    Log.e(ApiPartyListReader.class.toString(), "Failed JSON object");
                }
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        return null;
    }

    public void run(){
        getPartyList();
    }
}
