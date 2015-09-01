package receive;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import java.util.ArrayList;

import models.Party;

/**
 * Created by John on 8/31/2015.
 */
public class ListPartyAdapter extends ArrayAdapter<Party> {
    ArrayList<Party> party_list;
    Context mContext;

    public ListPartyAdapter(Context context, ArrayList<Party> party_list){
        super(context, 0, party_list);
        this.party_list = new ArrayList<Party>(party_list);
        this.mContext = context;
    }

    //TODO create RelativeLayout with correct fields
    public View getView(int position, View convert_view, ViewGroup parent){

        return null;
    }
}
