package models;

import android.media.Image;

import org.json.JSONObject;

import submit.ApiObject;

/**
 * Created by John on 9/2/2015.
 * This is the object that will be serialized and sent to the server when a deletion request
 * is made.
 */
public class DeletionRequest {
    private boolean mDesc_included = false;
    private boolean mImg_included = false;
    private Image mImage;
    private String mDesc;
    private String mUserOid;

    //constructor for a desc request
    public DeletionRequest(String desc, String oid){
        this.mDesc_included = true;
        this.mDesc = desc;
        this.mUserOid = oid;
    }

    //constructor for an image request
    public DeletionRequest(Image image, String oid){
        this.mImg_included = true;
        this.mImage = image;
        this.mUserOid = oid;
    }

    @Override
    public String toString() {
        return "DeletionRequest{" +
                "mDesc_included=" + mDesc_included +
                ", mImg_included=" + mImg_included +
                ", mImage=" + mImage +
                ", mDesc='" + mDesc + '\'' +
                ", mUserOid='" + mUserOid + '\'' +
                '}';
    }

    public String toJson(){
        //TODO finish this and write test
        return null;
    }

    public DeletionRequest fromJson(JSONObject json){
        //we don't actually need this model to implement this correctly
        return null;
    }

    //constructor for a hybrid request
    public DeletionRequest(String desc, Image image, String oid){
        this.mDesc_included = true;
        this.mImg_included = true;
        this.mDesc = desc;
        this.mImage = image;
        this.mUserOid = oid;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        DeletionRequest that = (DeletionRequest) o;

        if (mDesc_included != that.mDesc_included) return false;
        if (mImg_included != that.mImg_included) return false;
        if (!mImage.equals(that.mImage)) return false;
        if (!mDesc.equals(that.mDesc)) return false;
        return mUserOid.equals(that.mUserOid);

    }

    @Override
    public int hashCode() {
        int result = (mDesc_included ? 1 : 0);
        result = 31 * result + (mImg_included ? 1 : 0);
        result = 31 * result + mImage.hashCode();
        result = 31 * result + mDesc.hashCode();
        result = 31 * result + mUserOid.hashCode();
        return result;
    }

    public String getmUserOid() {

        return mUserOid;
    }

    public boolean ismDesc_included() {
        return mDesc_included;
    }

    public boolean ismImg_included() {
        return mImg_included;
    }

    public Image getmImage() {
        return mImage;
    }

    public String getmDesc() {
        return mDesc;
    }
}
