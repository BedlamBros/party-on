package receive;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import net.john.partyon.R;

import exceptions.PartyNotFoundException;
import models.Party;

/**
 * Created by John on 9/1/2015.
 */
public class ViewPartyActivity extends Activity {
    String party_extra_name;
    private Party mParty;

    public void onCreate(Bundle saved_instance){
        super.onCreate(saved_instance);
        setContentView(R.layout.activity_fullscreen_party_list_item);
    }

    private void getPartyFromExtra() throws PartyNotFoundException{
        party_extra_name = getResources().getString(R.string.party_extra_name);
        Intent intent = getIntent();
        if (intent == null) throw new PartyNotFoundException(this);
        mParty = intent.getParcelableExtra(party_extra_name);
    }
}