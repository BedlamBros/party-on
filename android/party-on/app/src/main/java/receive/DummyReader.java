package receive;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;

import models.Party;
import models.University;

/**
 * Created by John on 8/31/2015.
 */
public class DummyReader implements PartyListLoadable{
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
        while (i.hasNext()) try {
            String key = i.next();
            JSONArray mJson_array = (JSONArray) json_object.get(key);
            for (int inc = 0; inc < mJson_array.length(); inc++) {
                JSONObject mJson_sub_object = (JSONObject) mJson_array.get(inc);
                String title = (String) mJson_sub_object.get("title"); //TODO shouldn't be hardcoded, add all values
                String desc = (String) mJson_sub_object.get("desc");
                String readable_loc = (String) mJson_sub_object.get("readable_loc");
                University uni = new University("001", 170.06f, 80.004f);
                party_list.add(new Party("000001", title, desc, 170.006f, 80.004f,
                        "123 N Jefferson st.", 5, 0, "The House", true, uni, System.currentTimeMillis(),
                        (System.currentTimeMillis() + (1000 * 60 * 60)), (System.currentTimeMillis() + (1000 * 60 * 60)),
                        (System.currentTimeMillis() + (1000 * 60 * 60))));
            }
        } catch (JSONException ex) {
            ex.printStackTrace();
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
