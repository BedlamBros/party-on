package models;

import android.os.Parcel;
import android.os.Parcelable;

import com.google.gson.Gson;

import org.json.JSONObject;

import java.util.ArrayList;

import submit.ApiObject;

/**
 * Created by John on 8/31/2015.
 */
public class Party  implements Parcelable, ApiObject{
    private String oId;
    private String title;
    private String desc; //256 char limit
    private float lat;
    private float lon;
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

    //TODO include constructors with fewer args
    public Party(String OId, String title, String desc, float lat, float lon,
                 String formatted_address, ArrayList<Flag> flag_list, int male_cost,
                 String colloq_name, boolean byob, int female_cost, long created_at,
                 University uni, long start_time, long expires_at, long ends_at){
        this.oId = oId; //auto
        this.female_cost = female_cost; //optional default 0
        this.male_cost = male_cost; //optional default 0
        this.title = title; //required, on listview
        this.desc = desc; //optional
        this.lat = lat; //auto
        this.lon = lon; //auto
        this.formatted_address = formatted_address; //auto, on listview
        //this.flag_list = new ArrayList<Flag>(flag_list); //optional
        this.colloq_name = colloq_name; //optional, on listview
        this.uni = uni; //required default user's preference
        this.byob = byob; //required default true
        this.start_time = start_time; //optional default created_at
        this.created_at = created_at; //auto
        this.expires_at = expires_at; //auto default start_time + 6 hours
        this.ends_at = ends_at;
    }

    //can also be instantiated from a Parcel
    protected Party(Parcel in) {
        oId = in.readString();
        title = in.readString();
        desc = in.readString();
        lat = in.readFloat();
        lon = in.readFloat();
        formatted_address = in.readString();
        male_cost = in.readInt();
        female_cost = in.readInt();
        colloq_name = in.readString();
        byob = in.readByte() != 0x00;
        uni = (University) in.readValue(University.class.getClassLoader());
        start_time = in.readLong();
        created_at = in.readLong();
        expires_at = in.readLong();
    }

    //partially complete constructor for wireframing
    public Party(String title, String desc, String formatted_address){
        this.title = title;
        this.desc = desc;
        this.formatted_address = formatted_address;
        this.created_at = System.currentTimeMillis();
        this.expires_at = System.currentTimeMillis() + (1000 * 60 * 60);
        //this.flag_list = new ArrayList<Flag>();
        //flag_list.add(Flag.GREEN);
    }

    public Party fromJson(JSONObject json){
        //TODO create Party constructor from JsonObject
        return null;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Party party = (Party) o;
        if (Float.compare(party.lat, lat) != 0) return false;
        if (Float.compare(party.lon, lon) != 0) return false;
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
        result = 31 * result + (lat != +0.0f ? Float.floatToIntBits(lat) : 0);
        result = 31 * result + (lon != +0.0f ? Float.floatToIntBits(lon) : 0);
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

    //implement methods required by Parcelable interface
    public int describeContents(){
        return 0;
    }

    public void writeToParcel(Parcel dest, int flags){
        dest.writeString(oId);
        dest.writeString(title);
        dest.writeString(desc);
        dest.writeFloat(lat);
        dest.writeFloat(lon);
        dest.writeString(formatted_address);
        dest.writeInt(male_cost);
        dest.writeInt(female_cost);
        dest.writeString(colloq_name);
        dest.writeByte((byte) (byob ? 0x01 : 0x00));
        dest.writeValue(uni);
        dest.writeLong(start_time);
        dest.writeLong(created_at);
        dest.writeLong(expires_at);
    }

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

    public float getLat() {
        return lat;
    }

    public float getLon() {
        return lon;
    }

    public String getformatted_address() {
        return formatted_address;
    }

    @Override
    public String toString() {
        return "Party{" +
                "oId='" + oId + '\'' +
                ", title='" + title + '\'' +
                ", desc='" + desc + '\'' +
                ", lat=" + lat +
                ", lon=" + lon +
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
        Gson mGson = new Gson();
        return mGson.toJson(this.toString());
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
}
