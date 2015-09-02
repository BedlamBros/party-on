package models;

/**
 * Created by John on 8/31/2015.
 */
public class University {
    final private String UNI_DEFAULT = "Indiana University";
    private String oId;
    private String name;
    private float lat;
    private float lon;

    public University(String oId, float lat, float lon){
        this.oId = oId;
        this.lat = lat;
        this.lon = lon;
        this.name = UNI_DEFAULT;
    }

}
