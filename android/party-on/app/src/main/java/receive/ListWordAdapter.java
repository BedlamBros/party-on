package receive;

import android.content.Context;
import android.graphics.Typeface;
import android.util.Log;
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
        Word mWord = mWordList.get(position);
        if (convert_view == null){
            convert_view = LayoutInflater.from(mContext)
                    .inflate(R.layout.word_list_item, parent, false);
        }
        TextView mTv_body = (TextView) convert_view.findViewById(R.id.word_body);
        TextView mTv_created = (TextView) convert_view.findViewById(R.id.word_created);

        mTv_body.setText(mWordList.get(position).getBody());

        //set the typeface
        Typeface font = Typeface.createFromAsset(mContext.getAssets(),
                mContext.getResources().getString(R.string.typeface_stylish));
        mTv_body.setTypeface(font);

        return convert_view;
    }
}
