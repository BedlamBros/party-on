package net.john.partyon.submit;

import android.test.ActivityInstrumentationTestCase2;

import receive.ListPartyActivity;
import receive.ListPartyAdapter;

/**
 * Created by John on 9/4/2015.
 */
public class LoadApiPartyListTest extends ActivityInstrumentationTestCase2<ListPartyActivity> {
    ListPartyActivity mListPartyActivity;
    ListPartyAdapter mListPartyAdapter;

    public LoadApiPartyListTest(){
        super(ListPartyActivity.class);
    }

    public LoadApiPartyListTest(Class<ListPartyActivity> clazz){
        super(clazz);
    }

    @Override
    public void setUp(){
        mListPartyActivity = getActivity();
        mListPartyAdapter = mListPartyActivity.getListAdapter();
    }

    @Override
    public void runTest(){
        //check if the first item in the partyAdapter is null
        assertNotNull(mListPartyAdapter.getItem(0));
    }

    public void testTrue(){
        assertNotNull(mListPartyAdapter.getItem(0));
    }
}
