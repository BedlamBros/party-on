package ui;

import android.content.Context;
import android.widget.Button;

/**
 * Created by John on 9/2/2015.
 */
public class SubmitButton extends Button{

    public SubmitButton(Context ctx){
        super(ctx);
    }

    @Override
    public boolean onSetAlpha(int alpha){
        //TODO get hex colors with alpha values
        return true;
    }
}
