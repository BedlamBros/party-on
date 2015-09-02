package net.john.partyon;

import android.app.Activity;
import android.test.ActivityInstrumentationTestCase2;

import receive.ViewPartyActivity;

/**
 * Created by John on 9/2/2015.
 */
public class ParseStringForUriTest extends ActivityInstrumentationTestCase2<ViewPartyActivity>{
    private ViewPartyActivity mView_party_activity;

    private final String IN = "123 N Jefferson st.";
    private final String OUT = "123+N+Jefferson+st";

    public ParseStringForUriTest(Class<ViewPartyActivity> activityClass){
        super(activityClass);
    }

    @Override
    protected void setUp() throws Exception {
        super.setUp();
        mView_party_activity = getActivity();
    }

    @Override
    protected void runTest(){
        assertEquals(mView_party_activity.parseStringForUri(mView_party_activity.parseStringForUri(IN)), OUT);
    }
}
