﻿// Code generated by Microsoft (R) AutoRest Code Generator 0.9.7.0
// Changes may cause incorrect behavior and will be lost if the code is regenerated.

using System;
using System.Linq;
using Argonne.Common.ArgonneService.Models;
using Newtonsoft.Json.Linq;

namespace Argonne.Common.ArgonneService.Models
{
    public partial class BiasesForDevices
    {
        private double? _angerBias;
        
        /// <summary>
        /// Optional.
        /// </summary>
        public double? AngerBias
        {
            get { return this._angerBias; }
            set { this._angerBias = value; }
        }
        
        private double? _contemptBias;
        
        /// <summary>
        /// Optional.
        /// </summary>
        public double? ContemptBias
        {
            get { return this._contemptBias; }
            set { this._contemptBias = value; }
        }
        
        private double? _countBias;
        
        /// <summary>
        /// Optional.
        /// </summary>
        public double? CountBias
        {
            get { return this._countBias; }
            set { this._countBias = value; }
        }
        
        private Devices _device;
        
        /// <summary>
        /// Optional.
        /// </summary>
        public Devices Device
        {
            get { return this._device; }
            set { this._device = value; }
        }
        
        private string _deviceId;
        
        /// <summary>
        /// Optional.
        /// </summary>
        public string DeviceId
        {
            get { return this._deviceId; }
            set { this._deviceId = value; }
        }
        
        private double? _disgustBias;
        
        /// <summary>
        /// Optional.
        /// </summary>
        public double? DisgustBias
        {
            get { return this._disgustBias; }
            set { this._disgustBias = value; }
        }
        
        private double? _fearBias;
        
        /// <summary>
        /// Optional.
        /// </summary>
        public double? FearBias
        {
            get { return this._fearBias; }
            set { this._fearBias = value; }
        }
        
        private double? _happinessBias;
        
        /// <summary>
        /// Optional.
        /// </summary>
        public double? HappinessBias
        {
            get { return this._happinessBias; }
            set { this._happinessBias = value; }
        }
        
        private double? _neutralBias;
        
        /// <summary>
        /// Optional.
        /// </summary>
        public double? NeutralBias
        {
            get { return this._neutralBias; }
            set { this._neutralBias = value; }
        }
        
        private double? _sadnessBias;
        
        /// <summary>
        /// Optional.
        /// </summary>
        public double? SadnessBias
        {
            get { return this._sadnessBias; }
            set { this._sadnessBias = value; }
        }
        
        private string _shadowName;
        
        /// <summary>
        /// Optional.
        /// </summary>
        public string ShadowName
        {
            get { return this._shadowName; }
            set { this._shadowName = value; }
        }
        
        private double? _surpriseBias;
        
        /// <summary>
        /// Optional.
        /// </summary>
        public double? SurpriseBias
        {
            get { return this._surpriseBias; }
            set { this._surpriseBias = value; }
        }
        
        /// <summary>
        /// Initializes a new instance of the BiasesForDevices class.
        /// </summary>
        public BiasesForDevices()
        {
        }
        
        /// <summary>
        /// Deserialize the object
        /// </summary>
        public virtual void DeserializeJson(JToken inputObject)
        {
            if (inputObject != null && inputObject.Type != JTokenType.Null)
            {
                JToken angerBiasValue = inputObject["angerBias"];
                if (angerBiasValue != null && angerBiasValue.Type != JTokenType.Null)
                {
                    this.AngerBias = ((double)angerBiasValue);
                }
                JToken contemptBiasValue = inputObject["contemptBias"];
                if (contemptBiasValue != null && contemptBiasValue.Type != JTokenType.Null)
                {
                    this.ContemptBias = ((double)contemptBiasValue);
                }
                JToken countBiasValue = inputObject["countBias"];
                if (countBiasValue != null && countBiasValue.Type != JTokenType.Null)
                {
                    this.CountBias = ((double)countBiasValue);
                }
                JToken deviceValue = inputObject["device"];
                if (deviceValue != null && deviceValue.Type != JTokenType.Null)
                {
                    Devices devices = new Devices();
                    devices.DeserializeJson(deviceValue);
                    this.Device = devices;
                }
                JToken deviceIdValue = inputObject["deviceId"];
                if (deviceIdValue != null && deviceIdValue.Type != JTokenType.Null)
                {
                    this.DeviceId = ((string)deviceIdValue);
                }
                JToken disgustBiasValue = inputObject["disgustBias"];
                if (disgustBiasValue != null && disgustBiasValue.Type != JTokenType.Null)
                {
                    this.DisgustBias = ((double)disgustBiasValue);
                }
                JToken fearBiasValue = inputObject["fearBias"];
                if (fearBiasValue != null && fearBiasValue.Type != JTokenType.Null)
                {
                    this.FearBias = ((double)fearBiasValue);
                }
                JToken happinessBiasValue = inputObject["happinessBias"];
                if (happinessBiasValue != null && happinessBiasValue.Type != JTokenType.Null)
                {
                    this.HappinessBias = ((double)happinessBiasValue);
                }
                JToken neutralBiasValue = inputObject["neutralBias"];
                if (neutralBiasValue != null && neutralBiasValue.Type != JTokenType.Null)
                {
                    this.NeutralBias = ((double)neutralBiasValue);
                }
                JToken sadnessBiasValue = inputObject["sadnessBias"];
                if (sadnessBiasValue != null && sadnessBiasValue.Type != JTokenType.Null)
                {
                    this.SadnessBias = ((double)sadnessBiasValue);
                }
                JToken shadowNameValue = inputObject["shadowName"];
                if (shadowNameValue != null && shadowNameValue.Type != JTokenType.Null)
                {
                    this.ShadowName = ((string)shadowNameValue);
                }
                JToken surpriseBiasValue = inputObject["surpriseBias"];
                if (surpriseBiasValue != null && surpriseBiasValue.Type != JTokenType.Null)
                {
                    this.SurpriseBias = ((double)surpriseBiasValue);
                }
            }
        }
    }
}
