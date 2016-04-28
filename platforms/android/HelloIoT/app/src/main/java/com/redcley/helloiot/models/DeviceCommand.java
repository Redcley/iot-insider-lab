package com.redcley.helloiot.models;

import com.google.gson.Gson;

import java.util.Date;
import java.util.List;

/**
 * Created by rashi on 4/18/2016.
 */
public class DeviceCommand {
    public String Name;
    public String MessageId;
    public Date CreatedTime;
    public List<CommandParameter> Parameters;

    public static DeviceCommand fromJSON(String json){
        Gson gson = new Gson();

        return gson.fromJson(json, DeviceCommand.class);
    }
}
