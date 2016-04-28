package com.redcley.helloiot;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.View;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Toast;

import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.redcley.helloiot.services.IoTHubService;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Date;

public class MainActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener {

    Button btnStop, btnStart;
    ListView lsvEvents;
    ArrayList<String> eventList = new ArrayList<String>();
    ArrayAdapter<String> adapter;

    // handler for received Intents for the "my-event" event
    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // Extract data included in the Intent
            String status = intent.getStringExtra(IoTHubService.STATUS);

            if(IoTHubService.STATUS_TELEMETRY_STARTED.equalsIgnoreCase(status)) {
                btnStart.setEnabled(false);
                btnStop.setEnabled(true);
                Toast.makeText(MainActivity.this, "Received start", Toast.LENGTH_SHORT).show();
            } else if(IoTHubService.STATUS_TELEMETRY_STOPPED.equalsIgnoreCase(status)) {
                btnStart.setEnabled(true);
                btnStop.setEnabled(false);
                Toast.makeText(MainActivity.this, "Received stopped", Toast.LENGTH_SHORT).show();
            } else if(IoTHubService.STATUS_TELEMETRY_RECEIVED.equalsIgnoreCase(status)) {
                // Get the telemetry data
                JsonObject parameter = new GsonBuilder().create().fromJson(intent.getStringExtra(IoTHubService.PARAMETER), JsonObject.class);

                String loggedData = String.format("%s: Temp: %d, Hum: %d, Ext Temp: %d", new Date().toString(), parameter.get("Temperature").getAsInt(), parameter.get("Humidity").getAsInt(), parameter.get("ExternalTemperature").getAsInt());
                eventList.add(loggedData);
                adapter.notifyDataSetChanged();
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        final Context selfThis = this;

        LocalBroadcastManager.getInstance(this).registerReceiver(mMessageReceiver, new IntentFilter(IoTHubService.EVENT_NAME));

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.setDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);

        btnStart = (Button) findViewById(R.id.btnStartTelemetry);
        btnStart.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                IoTHubService.startTelemetry(selfThis);
            }
        });

        btnStop = (Button) findViewById(R.id.btnStopTelemetry);
        btnStop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                IoTHubService.stopTelemetry(selfThis);

                /*Intent intent = new Intent(IoTHubService.EVENT_NAME);
                // add data
                intent.putExtra("message", "data");
                LocalBroadcastManager.getInstance(selfThis).sendBroadcast(intent);*/
            }
        });

        lsvEvents = (ListView) findViewById(R.id.lsvEvents);

        adapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_list_item_1,
                eventList);
        lsvEvents.setAdapter(adapter);

        IoTHubService.start(selfThis);
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();

        if (id == R.id.nav_camera) {
            // Handle the camera action
        } else if (id == R.id.nav_gallery) {

        } else if (id == R.id.nav_slideshow) {

        } else if (id == R.id.nav_manage) {

        } else if (id == R.id.nav_share) {

        } else if (id == R.id.nav_send) {

        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }
}
