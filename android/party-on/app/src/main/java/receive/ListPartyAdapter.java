package receive;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import net.john.partyon.R;

import java.util.ArrayList;

import exceptions.PartyNotFoundException;
import models.Party;

/**
 * Created by John on 8/31/2015.
 */
public class ListPartyAdapter extends ArrayAdapter<Party> {
    private ArrayList<Party> mParty_list;
    private Context mContext;

    public ListPartyAdapter(Context context, ArrayList<Party> party_list){
        super(context, 0, party_list);
        this.mParty_list = new ArrayList<Party>(party_list);
        this.mContext = context;
        Log.d("receive", "listpartyadapter instantiated succesffuly with party_list of " + party_list.size());
    }

    @Override
    public int getCount(){
        return mParty_list.size();
    }

    @Override
    public Party getItem(int position){
        return mParty_list.get(position);
    }

    @Override
    public long getItemId(int position){
        return position; //this may not be correct
    }


    //TODO create RelativeLayout with correct fields
    public View getView(int position, View convert_view, ViewGroup parent){
        Party mParty = mParty_list.get(position);
        mParty.toString();
        if (convert_view == null){
            convert_view = LayoutInflater.from(mContext)
                    .inflate(R.layout.party_list_item, parent, false);
        }
        TextView mTv_title = (TextView) convert_view.findViewById(R.id.party_title);
        mTv_title.setText(mParty_list.get(position).getTitle());
        TextView mTv_desc = (TextView) convert_view.findViewById(R.id.party_desc);
        mTv_desc.setText(mParty_list.get(position).getDesc());
        TextView mTv_readable_loc = (TextView) convert_view.findViewById(R.id.party_readable_loc);
        mTv_readable_loc.setText(mParty_list.get(position).getformatted_address());
        convert_view.setOnClickListener(mPartyItemClickListener);
        return convert_view;
    }

    private View.OnClickListener mPartyItemClickListener = new View.OnClickListener(){
        @Override
        public void onClick(View view) {
            int id = view.getId();
            Party party;
            boolean party_found = false;
            //TODO jesus fuck, change this soon
            for (int i = 0; i < mParty_list.size(); i++){
                ViewGroup parent = (ViewGroup) view.getParent();
                if (parent.getChildAt(i).getId() == id){
                    party = mParty_list.get(i);
                    party_found = true;
                    //now start the PartyFullscreenActivity
                }
            }
            if (!party_found){
                //throw new PartyNotFoundException("mPartyClickListener");
            }
        }
    };
}
