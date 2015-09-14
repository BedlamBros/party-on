package models;

import android.os.Parcel;
import android.os.Parcelable;
import android.support.annotation.Nullable;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import org.json.JSONException;

import java.util.ArrayList;

import submit.ApiObject;

/**
 * Created by John on 8/31/2015.
 */
public class Party  implements Parcelable, ApiObject{
    private String oId;
    private String title;
    private String desc; //256 char limit
    private float latitude;
    private float longitude;
    private String formatted_address;
    //private ArrayList<Flag> flag_list;
    private int male_cost;
    private int female_cost;
    private String colloq_name;
    private boolean byob;
    private University uni;
    private long start_time;
    private long created_at; //UNIX timestamps
    private long expires_at;
    private long ends_at;
    private ArrayList<Word> theWord;

    //only one constructor exists. All instnatiation calls are made to
    //party factory
    public Party(String OId, String title, String desc, float latitudeitude, float lon,
                 String formatted_address, int male_cost, int female_cost,
                 String colloq_name, boolean byob, University uni,
                 long created_at, long start_time, long expires_at, long ends_at, ArrayList<Word> theWord){
        this.oId = OId; //auto
        this.female_cost = female_cost; //optional default 0
        this.male_cost = male_cost; //optional default 0
        this.title = title; //required, on listview
        this.desc = desc; //optional
        this.latitude = latitude; //auto
        this.longitude = lon; //auto
        this.formatted_address = formatted_address; //auto, on listview
        this.colloq_name = colloq_name; //optional, on listview
        this.uni = uni; //required default user's preference
        this.byob = byob; //required default true
        this.start_time = start_time; //optional default created_at
        this.created_at = created_at; //auto
        this.expires_at = expires_at; //auto default start_time + 6 hours
        this.ends_at = ends_at;
        this.theWord = theWord;
    }

    //partially complete constructor for wireframing
    public Party(String title, String desc, String formatted_address, float latitudeitude, float longitude, ArrayList<Word> theWord){
        this.title = title;
        this.desc = desc;
        this.formatted_address = formatted_address;
        this.created_at = System.currentTimeMillis();
        this.expires_at = System.currentTimeMillis() + (1000 * 60 * 60);
        this.latitude = latitudeitude;
        this.longitude = longitude;
        this.theWord = theWord;
    }

    public String getColloq_name() {
        return colloq_name;
    }

    //partially complete constructor for wireframing
    public Party(String title, String desc, String formatted_address, ArrayList<Word> theWord){
        this.title = title;

        this.desc = desc;
        this.formatted_address = formatted_address;
        this.created_at = System.currentTimeMillis();
        this.expires_at = System.currentTimeMillis() + (1000 * 60 * 60);
        this.theWord = theWord;
        //this.flag_list = new ArrayList<Flag>();
        //flag_list.add(Flag.GREEN);
    }

    public Party fromJson(JsonObject json){
        return new PartyFactory().create(json);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Party party = (Party) o;
        if (Float.compare(party.latitude, latitude) != 0) return false;
        if (Float.compare(party.longitude, longitude) != 0) return false;
        if (male_cost != party.male_cost) return false;
        if (female_cost != party.female_cost) return false;
        if (byob != party.byob) return false;
        if (start_time != party.start_time) return false;
        if (created_at != party.created_at) return false;
        if (expires_at != party.expires_at) return false;
        if (oId != null ? !oId.equals(party.oId) : party.oId != null) return false;
        if (title != null ? !title.equals(party.title) : party.title != null) return false;
        if (desc != null ? !desc.equals(party.desc) : party.desc != null) return false;
        if (formatted_address != null ? !formatted_address.equals(party.formatted_address) : party.formatted_address != null)
            return false;
        if (colloq_name != null ? !colloq_name.equals(party.colloq_name) : party.colloq_name != null)
            return false;
        return !(uni != null ? !uni.equals(party.uni) : party.uni != null);
    }

    @Override
    public int hashCode() {
        int result = oId != null ? oId.hashCode() : 0;
        result = 31 * result + (title != null ? title.hashCode() : 0);
        result = 31 * result + (desc != null ? desc.hashCode() : 0);
        result = 31 * result + (latitude != +0.0f ? Float.floatToIntBits(latitude) : 0);
        result = 31 * result + (longitude != +0.0f ? Float.floatToIntBits(longitude) : 0);
        result = 31 * result + (formatted_address != null ? formatted_address.hashCode() : 0);
        result = 31 * result + male_cost;
        result = 31 * result + female_cost;
        result = 31 * result + (colloq_name != null ? colloq_name.hashCode() : 0);
        result = 31 * result + (byob ? 1 : 0);
        result = 31 * result + (uni != null ? uni.hashCode() : 0);
        result = 31 * result + (int) (start_time ^ (start_time >>> 32));
        result = 31 * result + (int) (created_at ^ (created_at >>> 32));
        result = 31 * result + (int) (expires_at ^ (expires_at >>> 32));
        return result;
    }

    protected Party(Parcel in) {
        oId = in.readString();
        title = in.readString();
        desc = in.readString();
        latitude = in.readFloat();
        longitude = in.readFloat();
        formatted_address = in.readString();
        male_cost = in.readInt();
        female_cost = in.readInt();
        colloq_name = in.readString();
        byob = in.readByte() != 0x00;
        uni = (University) in.readValue(University.class.getClassLoader());
        start_time = in.readLong();
        created_at = in.readLong();
        expires_at = in.readLong();
        ends_at = in.readLong();
        if (in.readByte() == 0x01) {
            theWord = new ArrayList<Word>();
            in.readList(theWord, Word.class.getClassLoader());
        } else {
            theWord = null;
        }
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(oId);
        dest.writeString(title);
        dest.writeString(desc);
        dest.writeFloat(latitude);
        dest.writeFloat(longitude);
        dest.writeString(formatted_address);
        dest.writeInt(male_cost);
        dest.writeInt(female_cost);
        dest.writeString(colloq_name);
        dest.writeByte((byte) (byob ? 0x01 : 0x00));
        dest.writeValue(uni);
        dest.writeLong(start_time);
        dest.writeLong(created_at);
        dest.writeLong(expires_at);
        dest.writeLong(ends_at);
        if (theWord == null) {
            dest.writeByte((byte) (0x00));
        } else {
            dest.writeByte((byte) (0x01));
            dest.writeList(theWord);
        }
    }

    @SuppressWarnings("unused")
    public static final Parcelable.Creator<Party> CREATOR = new Parcelable.Creator<Party>() {
        @Override
        public Party createFromParcel(Parcel in) {
            return new Party(in);
        }

        @Override
        public Party[] newArray(int size) {
            return new Party[size];
        }
    };

    public String getTitle() {
        return title;
    }

    public String getDesc() {
        return desc;
    }

    public float getlatitude() {
        return latitude;
    }

    public float getLon() {
        return longitude;
    }

    public String getformatted_address() {
        return formatted_address;
    }

    public ArrayList<Word> getTheWord(){
        return this.theWord;
    }

    @Override
    public String toString() {
        return "Party{" +
                "oId='" + oId + '\'' +
                ", title='" + title + '\'' +
                ", desc='" + desc + '\'' +
                ", latitude=" + latitude +
                ", lon=" + longitude +
                ", formatted_address='" + formatted_address + '\'' +
                ", male_cost=" + male_cost +
                ", female_cost=" + female_cost +
                ", colloq_name='" + colloq_name + '\'' +
                ", byob=" + byob +
                ", uni=" + uni +
                ", start_time=" + start_time +
                ", created_at=" + created_at +
                ", expires_at=" + expires_at +
                ", ends_at=" + ends_at +
                '}';
    }

    public String toJson(){
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("formattedAddress", formatted_address);
        jsonObject.addProperty("user", "55ee1c874db6aa021458cf1f");
        jsonObject.addProperty("university", "Indiana University");
        return jsonObject.toString();
    }

    /*
    public ArrayList<Flag> getFlag_list() {
        return flag_list;
    }
    */

    public long getCreated_at() {
        return created_at;
    }

    public long getExpires_at() {
        return expires_at;
    }

    public long getStart_time() {
        return start_time;
    }

    public long getEnds_at() {
        return ends_at;
    }

    public boolean isByob() {
        return byob;
    }

    public int getFemale_cost() {
        return female_cost;
    }

    public int getMale_cost() {

        return male_cost;
    }

    public static class PartyFactory{
        final int UTC_MS_CONVERSION = 1000;

        @Nullable
        public static Party create(JsonObject json){
            //TODO create party from json
            //String title = json.get("_id").getAsString();
            String user = json.get("user").getAsString();
            String desc = "downloaded from api";
            String formattedAddress = json.get("formattedAddress").getAsString();
            float latitude = json.get("latitude").getAsFloat();
            float longitude = json.get("longitude").getAsFloat();
            boolean byob = json.get("byob").getAsBoolean();
            ArrayList<Word> wordList = new ArrayList<Word>();
            JsonArray theWordJsonArray = json.get("theWord").getAsJsonArray();
            Log.d("receive", "received " + theWordJsonArray.size() + " words from server");
            for (int i = 0; i < theWordJsonArray.size(); i++){
                JsonObject wordJson = theWordJsonArray.get(i).getAsJsonObject();
                Word w = Word.WordFactory.create(wordJson);
                wordList.add(w);
            }

            if (latitude != 0f && longitude != 0f){
                return new Party("apiParty", desc, formattedAddress, latitude, longitude, wordList);
            }
            return new Party("apiParty", desc, formattedAddress, wordList);
        }

        protected Party create(Parcel in){
            String oId = in.readString();
            String title = in.readString();
            String desc = in.readString();
            float latitude = in.readFloat();
            float longitude = in.readFloat();
            String formatted_address = in.readString();
            int male_cost = in.readInt();
            int female_cost = in.readInt();
            String colloq_name = in.readString();
            boolean byob = in.readByte() != 0x00;
            University uni = (University) in.readValue(University.class.getClassLoader());
            long starts_at = in.readLong(); //need to * 1000 for dates
            long created_at = in.readLong();
            long expires_at = in.readLong();
            return new Party(oId, title, desc, latitude, longitude, formatted_address, male_cost, female_cost,
                                colloq_name, byob, uni, created_at, starts_at, expires_at, 0, new ArrayList<Word>());
        }
    }
}
