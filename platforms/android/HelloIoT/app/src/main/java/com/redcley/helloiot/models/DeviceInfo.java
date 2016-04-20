package com.redcley.helloiot.models;

import android.util.JsonWriter;

import com.google.gson.Gson;

import org.json.JSONObject;

import java.util.List;

/**
 * Created by rashi on 4/18/2016.
 */
public class DeviceInfo {
    public String ObjectType;
    public String Version;
    public boolean IsSimulatedDevice;
    public DeviceProperties DeviceProperties;
    public List<DeviceCommand> Commands;

    public String serialize() {
        Gson gson = new Gson();

        return gson.toJson(this);
    }
}
