package models;

import java.util.ArrayList;

/**
 * Created by John on 8/31/2015.
 */
public class Party {
    private String title;
    private String desc;
    float lat;
    float lon;
    String readable_loc;
    ArrayList<Flag> flag_list;
    long created_at;
    long expires_at;

    //TODO include constructors with fewer args
    public Party(String title, String desc, float lat, float lon,
                 String readable_loc, ArrayList<Flag> flag_list,
                 long created_at, long expires_at){
        this.title = title;
        this.desc = desc;
        this.lat = lat;
        this.lon = lon;
        this.readable_loc = readable_loc;
        this.flag_list = new ArrayList<Flag>(flag_list);
        this.created_at = created_at;
        this.expires_at = expires_at;
    }

    //partially complete constructor for wireframing
    public Party(String title, String desc, String readable_loc){
        this.title = title;
        this.desc = desc;
        this.readable_loc = readable_loc;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Party party = (Party) o;

        if (Float.compare(party.lat, lat) != 0) return false;
        if (Float.compare(party.lon, lon) != 0) return false;
        if (created_at != party.created_at) return false;
        if (expires_at != party.expires_at) return false;
        if (title != null ? !title.equals(party.title) : party.title != null) return false;
        if (desc != null ? !desc.equals(party.desc) : party.desc != null) return false;
        if (readable_loc != null ? !readable_loc.equals(party.readable_loc) : party.readable_loc != null)
            return false;
        return !(flag_list != null ? !flag_list.equals(party.flag_list) : party.flag_list != null);

    }

    @Override
    public int hashCode() {
        int result = title != null ? title.hashCode() : 0;
        result = 31 * result + (desc != null ? desc.hashCode() : 0);
        result = 31 * result + (lat != +0.0f ? Float.floatToIntBits(lat) : 0);
        result = 31 * result + (lon != +0.0f ? Float.floatToIntBits(lon) : 0);
        result = 31 * result + (readable_loc != null ? readable_loc.hashCode() : 0);
        result = 31 * result + (flag_list != null ? flag_list.hashCode() : 0);
        result = 31 * result + (int) (created_at ^ (created_at >>> 32));
        result = 31 * result + (int) (expires_at ^ (expires_at >>> 32));
        return result;
    }

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

    public String getReadable_loc() {
        return readable_loc;
    }

    public ArrayList<Flag> getFlag_list() {
        return flag_list;
    }

    public long getCreated_at() {
        return created_at;
    }

    public long getExpires_at() {
        return expires_at;
    }
}
