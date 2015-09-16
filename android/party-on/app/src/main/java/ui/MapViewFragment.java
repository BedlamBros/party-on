package ui;

import android.app.Fragment;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.InflateException;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapFragment;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

import net.john.partyon.R;

import java.util.ArrayList;

import models.Party;

/**
 * Created by John on 9/3/2015.
 */
public class MapViewFragment extends FragmentActivity implements OnMapReadyCallback {
    private static View view;
    private ArrayList<Party> partyList;

    @Override
    public void onCreate(Bundle savedInstance){
        super.onCreate(savedInstance);
        Log.d("map", "MapViewFragment created");
        setContentView(R.layout.fragment_map_view);
        MapFragment mapFragment = (MapFragment) getFragmentManager()
                .findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);
    }

    @Override
    public void onMapReady(GoogleMap map){
        Log.d("map", "map is ready");
    }

}
