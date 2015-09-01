package receive;

import android.app.ListActivity;
import android.os.Bundle;
import android.widget.ListView;

import net.john.partyon.R;

/**
 * Created by John on 8/31/2015.
 */
public class ListPartyActivity extends ListActivity {
    private ListView list;

    @Override
    public void onCreate(Bundle saved_instance){
        super.onCreate(saved_instance);
        list = (ListView) findViewById(R.id.list);
    }
}
