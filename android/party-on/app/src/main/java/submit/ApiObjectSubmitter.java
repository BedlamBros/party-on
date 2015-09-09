package submit;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import com.google.gson.JsonObject;

import net.john.partyon.R;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.IOException;
import java.io.UnsupportedEncodingException;

import models.Party;

/**
 * Created by John on 9/4/2015.
 * Implements the singleton pattern. Runnable, meant to run api thread
 * Used to fetch any
 */
public class ApiObjectSubmitter extends AsyncTask<String, Void, ApiObject> {
    final String mApiUrl = "http://ec2-52-10-210-220.us-west-2.compute.amazonaws.com/api";
    private final String ENDPOINT = "/parties";
    private static ApiObjectSubmitter mInstance;
    private Context mContext;
    private String url;
    private HttpClient mHttpClient;
    private ApiObject mApiObject;

    protected ApiObjectSubmitter(){
        //defeat instantiation
    }

    private ApiObjectSubmitter(Context context, ApiObject apiObject){
        //real constructor
        this.mContext = context;
        url = context.getResources().getString(R.string.api_url);
        mHttpClient = new DefaultHttpClient();
        this.mApiObject = apiObject;
    }

    public static ApiObjectSubmitter getInstance(Context ctx, ApiObject apiObject){
        if (mInstance == null){
            mInstance = new ApiObjectSubmitter(ctx, apiObject);
        }
        return mInstance;
    }

    public HttpClient getDefaultHttpClient(){
        return mHttpClient;
    }

    protected Party doInBackground(String... jsonObjects){
        if (mHttpClient == null) mHttpClient = new DefaultHttpClient();
        Log.d("submit", "ApiObjectSubmitter attempting to submit on new thread");
        String json = jsonObjects[0];
        Log.d("submit", "attempting to POST this json :" + json);
        HttpPost httpPost = new HttpPost(mApiUrl + ENDPOINT);
        Log.d("submit", "attempting to submit to url:" + httpPost.getURI().toString());
        try {
            StringEntity entity = new StringEntity(json);
            httpPost.setEntity(entity);
            httpPost.setHeader("Content-type", "application/json");
            httpPost.setHeader("Authentication", "login bearer");
            try {
                HttpResponse res = mHttpClient.execute(httpPost);
                Log.d("submit", "res code: " + res.getStatusLine().toString());
                Log.d("json", "res: " + res.toString());
            } catch (Exception ex){
                ex.printStackTrace();
            }
        } catch (UnsupportedEncodingException ex){
            ex.printStackTrace();
        }
        return null;
    }

    protected void onPostExecute(ApiObject mApiObject){
        if (mApiObject instanceof Party){
            Party mParty = (Party) mApiObject;
            Log.d("submit", "onpostexecute received " + mParty.toString());
        }
    }
}
