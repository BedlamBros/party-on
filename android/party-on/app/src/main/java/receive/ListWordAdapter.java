package receive;

import android.content.Context;
import android.graphics.Typeface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import net.john.partyon.R;

import java.util.ArrayList;

import models.Word;

/**
 * Created by John on 9/7/2015.
 */
public class ListWordAdapter extends ArrayAdapter<Word> {
    private Context mContext;
    private ArrayList<Word> mWordList;

    public ListWordAdapter(Context context, ArrayList<Word> wordList){
        super(context, 0, wordList);
        this.mContext = context;
        this.mWordList = wordList;
    }

    public View getView(int position, View convert_view, ViewGroup parent){
        /*
        Word mWord = mWordList.get(position);
        mWord.toString();
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
        //convert_view.setOnClickListener(mPartyItemClickListener);

        //set the typeface
        Typeface font = Typeface.createFromAsset(mContext.getAssets(),
                mContext.getResources().getString(R.string.typeface_stylish));
        mTv_title.setTypeface(font);
        */
        return convert_view;
    }
}
