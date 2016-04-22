package com.redcley.helloiot.models;

/**
 * Created by rashi on 4/18/2016.
 */
public class CommandParameter {
    public String Name;
    public String Type;

    public CommandParameter() {

    }

    public CommandParameter(String name, String type) {
        this.Name = name;
        this.Type = type;
    }
}
