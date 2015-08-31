package receive;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;

import models.Party;

/**
 * Created by John on 8/31/2015.
 */
public class DummyReader {
    String filename;
    Context ctx;

    public DummyReader(String file, Context context){
        this.filename = file;
        this.ctx = context;
    }

    //TODO change this sig to protected after tested
    public ArrayList<Party> getPartyList(){
        ArrayList<Party> party_list = new ArrayList<Party>();
        JSONObject json_object = parseJSON();
        Iterator<String> i = json_object.keys();
        Log.d("receive", filename + "=" + json_object.toString());
        while (i.hasNext()){
            try {
                String key = i.next();
                JSONObject sub_object = (JSONObject) json_object.get(key);
                String title = (String) sub_object.get("title"); //TODO shouldn't be hardcoded, add all values
                String desc = (String) sub_object.get("desc");
                String readable_loc = (String) sub_object.get("readable_loc");
                party_list.add(new Party(title, desc, readable_loc));
            } catch (JSONException ex){
                ex.printStackTrace();
            }
        }
        return party_list;
    }

    private JSONObject parseJSON(){
        String json;
        try {
            if (ctx == null){
                Log.wtf("receive", "instantiated DummyReader with null context");
                return null;
            }
            if (ctx.getAssets().equals(null)){
                Log.wtf("receive", "assets are null in context: " + ctx.toString());
            }
            //takee this IO out after testing
            if (ctx.getAssets().open(filename).equals(null)){
                Log.d("receive", filename + " is null");
            }
            AssetManager mAsset_manager = ctx.getResources().getAssets();
            InputStream is = mAsset_manager.open(filename);
            int size = is.available();
            byte[] buffer = new byte[size];
            is.read(buffer);
            is.close();
            json = new String(buffer, "utf-8");
        } catch (IOException ex){
            ex.printStackTrace();
            return null;
        }
        try {
            JSONObject json_object = new JSONObject(json);
            return json_object;
        } catch (JSONException ex){
            ex.printStackTrace();
            return null;
        }
    }
}
