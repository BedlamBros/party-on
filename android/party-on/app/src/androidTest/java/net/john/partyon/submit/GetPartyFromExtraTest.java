package net.john.partyon.submit;

import android.app.Activity;
import android.content.Intent;
import android.os.Parcelable;
import android.test.ActivityInstrumentationTestCase2;

import net.john.partyon.R;

import models.Party;
import receive.ListPartyActivity;
import receive.ViewPartyActivity;

/**
 * Created by John on 9/2/2015.
 */
public class GetPartyFromExtraTest extends ActivityInstrumentationTestCase2<ListPartyActivity> {
    private final int PARTY_LIST_OFFSET = 0;
    ViewPartyActivity mView_party_activity;
    ListPartyActivity mList_party_activity;
    Party mParty;

    public GetPartyFromExtraTest(Class<ListPartyActivity> activityClass){
        super(activityClass);
    }

    protected void setUp() throws Exception{
        super.setUp();
        mList_party_activity = getActivity();
        mParty = mList_party_activity.getListAdapter().getItem(PARTY_LIST_OFFSET);
        Intent mIntent = new Intent(mList_party_activity, ViewPartyActivity.class);
        mIntent.putExtra(mList_party_activity.getResources().getString(R.string.party_extra_name), (Parcelable) mParty);
        mList_party_activity.startActivity(mIntent);
    }

    protected void runTest(){
        assertNotNull(mParty);
    }
}
