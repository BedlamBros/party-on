package net.john.partyon.submit;

import android.app.Activity;
import android.test.ActivityInstrumentationTestCase2;

import junit.framework.TestCase;

import java.util.List;

import receive.ListPartyActivity;

/**
 * Created by John on 9/3/2015.
 */
public class SubmitHttpGetPartiesTest extends ActivityInstrumentationTestCase2<ListPartyActivity> {
    private ListPartyActivity mListPartyActivity;

    public SubmitHttpGetPartiesTest(Class<ListPartyActivity> listPartyActivityClass){
        super(listPartyActivityClass);
    }

    @Override
    protected void setUp(){
        mListPartyActivity = getActivity();
    }

    protected void runTest(){
        assertNotNull(mListPartyActivity.getListAdapter().getItem(0));
    }
}
