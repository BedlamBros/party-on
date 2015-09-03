package receive;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Parcel;
import android.util.Log;
import android.widget.TextView;

import net.john.partyon.R;

import java.util.Date;

import exceptions.PartyNotFoundException;
import models.Party;

/**
 * Created by John on 9/1/2015.
 */
public class ViewPartyActivity extends Activity {
    String party_extra_name;
    private Party mParty;

    private TextView mTv_title;
    private TextView mTv_readable_loc;
    private TextView mTv_desc;
    private TextView mTv_starts_at;
    private TextView mTv_ends_at;

    public void onCreate(Bundle saved_instance){
        super.onCreate(saved_instance);
        setContentView(R.layout.activity_fullscreen_party_list_item);

        //set views by R.id
        mTv_title = (TextView) findViewById(R.id.fullscreen_party_item_title);
        mTv_readable_loc = (TextView) findViewById(R.id.fullscreen_party_item_readable_loc);
        mTv_desc = (TextView) findViewById(R.id.fullscreen_party_item_desc);
        mTv_starts_at = (TextView) findViewById(R.id.fullscreen_party_item_starts_at);
        mTv_ends_at = (TextView) findViewById(R.id.fullscreen_party_item_ends_at);

        try {
            getPartyFromExtra();
            fillViewFromParty();
        } catch (PartyNotFoundException ex){
            ex.printStackTrace();
        }
    }

    private void getPartyFromExtra() throws PartyNotFoundException{
        party_extra_name = getResources().getString(R.string.party_extra_name);
        Intent intent = getIntent();
        if (intent == null) throw new PartyNotFoundException(this);

        //returns Parcelable, so typecast
        mParty = intent.getParcelableExtra(party_extra_name);
        if (mParty == null){
            Log.d("party_detail", "party is null");
        }
        Log.d("party_detail", mParty.toString());
    }

    private void fillViewFromParty(){
        mTv_title.setText(mParty.getTitle());
        mTv_readable_loc.setText(mParty.getformatted_address());
        mTv_desc.setText(mParty.getDesc());
        Date mDate_starts_at = new Date(mParty.getStart_time());
        mTv_starts_at.setText(mDate_starts_at.toString());
        Date mDate_ends_at = new Date(mParty.getEnds_at());
        mTv_ends_at.setText(mDate_ends_at.toString());

    }

    public Party getParty(){
        return mParty;
    }

    private void launchLocUri(String readable_loc){
        //TODO parse this correctly
        Intent intent = new Intent(android.content.Intent.ACTION_VIEW,
                Uri.parse("google.navigation:q=an+address+city"));
    }

    public String parseStringForUri(String raw){
        raw.replaceAll(" ", "+");
        while (raw.substring(0, 1).equals("+")){
            raw = raw.substring(1, raw.length());
        }
        while (raw.substring(raw.length() - 2, raw.length() - 1).equals("+")){
            raw = raw.substring(1, raw.length() - 2);
        }
        return raw;
    }
}