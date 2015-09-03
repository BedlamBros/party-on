package util;

import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Iterator;
import java.util.Map;

public class ApiController {
	private static ApiController instance;
	final String url = "http://ec2-54-148-115-3.us-west-2.compute.amazonaws.com:8080/api/login";
	
	protected ApiController(){
		//avoid construction outside getInstance
	}
	
	public static ApiController getInstance(){
		if (instance == null){
			instance =  new ApiController();
		}
		return instance;
	}
	
	public void makeLoginRequest(String username, String password){
		DefaultHttpClient httpClient = new DefaultHttpClient();
		HttpPost httpPost = new HttpPost(url);
		//Map<String, String> params = new HashMap<String, String>();
		//params.put("username", username);
		//params.put("password", password);
		JSONObject json;
		try {
			//json = getJsonObjectFromMap(params);
			json = new JSONObject();
			json.put("username", username);
			json.put("password", password);
			try {
				StringEntity se = new StringEntity(json.toString());
				httpPost.setEntity(se);
				httpPost.setHeader("Accept", "application/json");
				httpPost.setHeader("content/type", "application/json");
				try {
					httpClient.execute(httpPost);
				} catch (IOException ex){
					
				}
			} catch (UnsupportedEncodingException e){
				e.printStackTrace();
			}
		} catch (JSONException e){
			e.printStackTrace();
		}
	}
	
	private static JSONObject getJsonObjectFromMap(Map params) throws JSONException {

	    //all the passed parameters from the post request
	    //iterator used to loop through all the parameters
	    //passed in the post request
	    Iterator iter = params.entrySet().iterator();

	    //Stores JSON
	    JSONObject holder = new JSONObject();

	    //While there is another entry
	    while (iter.hasNext()) 
	    {
	        //gets an entry in the params
	        Map.Entry pairs = (Map.Entry)iter.next();

	        //creates a key for Map
	        String key = (String)pairs.getKey();

	        //Create a new map
	        Map m = (Map)pairs.getValue();   

	        //object for storing Json
	        JSONObject data = new JSONObject();

	        //gets the value
	        Iterator iter2 = m.entrySet().iterator();
	        while (iter2.hasNext()) 
	        {
	            Map.Entry pairs2 = (Map.Entry)iter2.next();
	            data.put((String)pairs2.getKey(), pairs2.getValue());
	        }

	        //puts email and 'foo@bar.com'  together in map
	        holder.put(key, data);
	    }
	    return holder;
	}
}
