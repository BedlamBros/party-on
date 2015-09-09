package net.john.partyon.receive;

import android.test.ActivityInstrumentationTestCase2;

import receive.ListPartyActivity;

/**
 * Created by John on 9/8/2015.
 */
public class ApiGetPartiesOnSwipeTest extends ActivityInstrumentationTestCase2<ListPartyActivity> {
    private ListPartyActivity mListPartyActivity;

    public ApiGetPartiesOnSwipeTest(){
        super(ListPartyActivity.class);
    }

    public ApiGetPartiesOnSwipeTest(Class<ListPartyActivity> clazz){
        super(clazz);
    }

    public void setUp() throws Exception{
        super.setUp();
        mListPartyActivity = getActivity();
    }

    public void runTest() throws Exception {
        int numOfParties = mListPartyActivity.getListAdapter().getCount();
        assertTrue(numOfParties != 0);
    }

    @Override
    public void tearDown() throws Exception {
        super.tearDown();
    }
}
