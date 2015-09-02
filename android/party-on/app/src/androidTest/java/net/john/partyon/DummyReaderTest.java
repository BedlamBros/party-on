package net.john.partyon;

import android.test.ActivityInstrumentationTestCase2;

import receive.ListPartyActivity;

/**
 * Created by John on 9/1/2015.
 */
public class DummyReaderTest extends ActivityInstrumentationTestCase2<ListPartyActivity> {
    private ListPartyActivity mListPartyActivity;

    public DummyReaderTest(Class<ListPartyActivity> activityClass){
        super(activityClass);
    }

    @Override
    protected void setUp() throws Exception {
        super.setUp();
        mListPartyActivity = getActivity();
    }

    @Override
    protected void runTest(){
        assertNotNull(mListPartyActivity.getListAdapter());
    }
}
