package submit;

import com.google.gson.JsonObject;

/**
 * Created by John on 9/2/2015.
 * All api objects must implement the toJson() method before being posted
 * and can be created by FromJson
 */
public interface ApiObject {

    String toJson();

    Object fromJson(JsonObject json);
}
