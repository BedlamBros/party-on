package models;

import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;

import com.google.gson.JsonObject;

import java.util.Date;

import submit.ApiObject;

/**
 * Created by John on 9/7/2015.
 */
public class Word implements ApiObject, Parcelable{
    private String body;
    private Date created;

    public Word(String body, Date created){
        this.body = body;
        this.created = created;
    }

    public Date getCreated() {
        return created;
    }

    public String getBody() {
        return body;
    }

    public Word fromJson(JsonObject json){
        return WordFactory.create(json);
    }

    public String toJson(){
        return this.body + this.created.toString();
    }

    protected Word(Parcel in) {
        body = in.readString();
        long tmpCreated = in.readLong();
        created = tmpCreated != -1 ? new Date(tmpCreated) : null;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(body);
        dest.writeLong(created != null ? created.getTime() : -1L);
    }

    @SuppressWarnings("unused")
    public static final Parcelable.Creator<Word> CREATOR = new Parcelable.Creator<Word>() {
        @Override
        public Word createFromParcel(Parcel in) {
            return new Word(in);
        }

        @Override
        public Word[] newArray(int size) {
            return new Word[size];
        }
    };

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Word word = (Word) o;

        if (body != null ? !body.equals(word.body) : word.body != null) return false;
        return !(created != null ? !created.equals(word.created) : word.created != null);

    }

    @Override
    public int hashCode() {
        int result = body != null ? body.hashCode() : 0;
        result = 31 * result + (created != null ? created.hashCode() : 0);
        return result;
    }

    public static class WordFactory {
        public static Word create(JsonObject json){
            String jsonBody = json.get("body").getAsString();
            long createdAt = json.get("created").getAsLong();
            Date date = new Date(createdAt);
            Log.d("receive", " body from Word: " + jsonBody);
            Word w = new Word(jsonBody, date);
            Log.d("receive", w.toString());
            return w;
        }
    }
}
