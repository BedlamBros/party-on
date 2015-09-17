package receive;

import android.app.ListFragment;
import android.os.Bundle;

import net.john.partyon.R;

import java.util.ArrayList;

import models.Party;

/**
 * Created by John on 9/15/2015.
 */
public class PartyListFragment extends ListFragment {
    private ArrayList<Party> partyList;

    public void onActivityCreated(Bundle savedInstanceState){
        super.onActivityCreated(savedInstanceState);

        partyList = ((ListPartyActivity) getActivity()).getPartyList();

        ListPartyAdapter mListPartyAdapter = new ListPartyAdapter(getActivity(), partyList);
        setListAdapter(mListPartyAdapter);
    }
}