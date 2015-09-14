package prefs;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.Log;

import net.john.partyon.R;

/**
 * Created by John on 9/12/2015.
 */
public class UniPrefFragment extends DialogFragment {
    Context mContext;

    public Dialog onCreateDialog(Bundle savedInstance){
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity(), R.style.dialog);
        builder.setTitle(R.string.preferences_uni_title)
                .setItems(R.array.universities, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        // The 'which' argument contains the index position
                        // of the selected item
                    }
                })
                .setNegativeButton(R.string.preferences_negative, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int id) {
                        Log.d("prefs", "canceled prefs dialog");
                    }
                });
        return builder.create();
    }
}
