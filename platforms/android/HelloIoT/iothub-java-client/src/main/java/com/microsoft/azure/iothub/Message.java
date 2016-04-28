// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.microsoft.azure.iothub;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class Message
{
    // ----- Constants -----

    public static final Charset DEFAULT_IOTHUB_MESSAGE_CHARSET = StandardCharsets.UTF_8;


    // ----- Data Fields -----

    /**
     * [Required for two way requests] Used to correlate two-way communication.
     * Format: A case-sensitive string (up to 128 char long) of ASCII 7-bit alphanumeric chars
     * plus {'-', ':', '/', '\', '.', '+', '%', '_', '#', '*', '?', '!', '(', ')', ',', '=', '@', ';', '$', '''}.
     * Non-alphanumeric characters are from URN RFC.
     */
    private String messageId;

    /// <summary>
    /// Destination of the message
    /// </summary>
    private String to;

    /// <summary>
    /// Expiry time in UTC Interpreted by hub on C2D messages. Ignored in other cases.
    /// </summary>
    private Date expiryTimeUtc;

    /// <summary>
    /// Used by receiver to Abandon, Reject or Complete the message
    /// </summary>
    private String lockToken;

    /// <summary>
    /// Used in message responses and feedback
    /// </summary>
    private String correlationId;

    /// <summary>
    /// [Required in feedback messages] Used to specify the entity creating the message.
    /// </summary>
    private String userId;

    /// <summary>
    /// [Optional] On C2D messages it is interpreted by hub to specify the expected feedback messages. Ignored in other cases.
    /// </summary>
    private FeedbackStatusCodeEnum ack;

    /// <summary>
    /// [Optional] Used when batching on HTTP Default: false.
    /// </summary>
    private Boolean httpBatchSerializeAsString;

    /// <summary>
    /// [Optional] Used when batching on HTTP Default: UTF-8.
    /// </summary>
    private StandardCharsets httpBatchEncoding;

    /// <summary>
    /// [Stamped on servicebound messages by IoT Hub] The authenticated id used to send this message.
    /// </summary>
    private String connectionDeviceId;

    /// <summary>
    /// [Stamped on servicebound messages by IoT Hub] The generationId of the authenticated device used to send this message.
    /// </summary>
    private String connectionDeviceGenerationId;

    /// <summary>
    /// [Stamped on servicebound messages by IoT Hub] The authentication type used to send this message, format as in IoT Hub Specs
    /// </summary>
    private String connectionAuthenticationMethod;

    /// <summary>
    /// [Required in feedback messages] Used in feedback messages generated by IoT Hub.
    /// 0 = success 1 = message expired 2 = max delivery count exceeded 3 = message rejected
    /// </summary>
    private FeedbackStatusCodeEnum feedbackStatusCode;

    /// <summary>
    /// [Required in feedback messages] Used in feedback messages generated by IoT Hub. "success", "Message expired", "Max delivery count exceeded", "Message rejected"
    /// </summary>
    private String feedbackDescription;

    /// <summary>
    /// [Required in feedback messages] Used in feedback messages generated by IoT Hub.
    /// </summary>
    private String feedbackDeviceId;

    /// <summary>
    /// [Required in feedback messages] Used in feedback messages generated by IoT Hub.
    /// </summary>
    private String feedbackDeviceGenerationId;

    /**
     * User-defined properties.
     */
    private ArrayList<MessageProperty> properties;

    /// <summary>
    /// The message body
    /// </summary>
    private byte[] body;

    /**
     * Stream that will provide the bytes for the body of the
     */
    private ByteArrayInputStream bodyStream;


    // ----- Constructors -----

    /**
     * Constructor.
     */
    public Message() {
         initialize();
    }

    /**
     * Constructor.
     * @param stream A stream to provide the body of the new Message instance.
     */
    public Message(ByteArrayInputStream stream)
    {
        initialize();
    }

    /**
     * Constructor.
     * @param body The body of the new Message instance.
     */
    public Message(byte[] body) {
        // Codes_SRS_MESSAGE_11_025: [If the message body is null, the constructor shall throw an IllegalArgumentException.]
        if (body == null) {
            throw new IllegalArgumentException("Message body cannot be 'null'.");
        }

        initialize();

        // Codes_SRS_MESSAGE_11_024: [The constructor shall save the message body.]
        this.body = body;
    }

    /**
     * Constructor.
     * @param body The body of the new Message instance. It is internally serialized to a byte array using UTF-8 encoding.
     */
    public Message(String body) {
        if (body == null) {
            throw new IllegalArgumentException("Message body cannot be 'null'.");
        }

        initialize();

        this.body = body.getBytes(DEFAULT_IOTHUB_MESSAGE_CHARSET);
    }


    // ----- Public Methods -----

    /// <summary>
    /// The stream content of the body.
    /// </summary>
    public ByteArrayOutputStream getBodyStream() {
        return null;
    }

    /**
     * The byte content of the body.
     * @return A copy of this Message body, as a byte array.
     */
    public byte[] getBytes()
    {
        // Codes_SRS_MESSAGE_11_002: [The function shall return the message body.]
        byte[] bodyClone = null;

        if (this.body != null) {
            bodyClone = Arrays.copyOf(this.body, this.body.length);
        }

        return bodyClone;
    }

    /**
     * Gets the values of user-defined properties of this Message.
     * @param name Name of the user-defined property to search for.
     * @return The value of the property if it is set, or null otherwise.
     */
    public String getProperty(String name) {

        MessageProperty messageProperty = null;

        for (MessageProperty currentMessageProperty: this.properties) {
            if (currentMessageProperty.hasSameName(name)) {
                messageProperty = currentMessageProperty;
                break;
            }
        }

        // Codes_SRS_MESSAGE_11_034: [If no value associated with the property name is found, the function shall throw an IllegalArgumentException.]
        if (messageProperty == null) {
            throw new IllegalArgumentException("Message does not contain a property with name '" + name + "'.");
        }

        // Codes_SRS_MESSAGE_11_032: [The function shall return the value associated with the message property name, where the name can be either the HTTPS or AMQPS property name.]
        return messageProperty.getValue();
    }

    /**
     * Adds or sets user-defined properties of this Message.
     * @param name Name of the property to be set.
     * @param value Value of the property to be set.
     * @exception IllegalArgumentException If any of the arguments provided is null.
     */
    public void setProperty(String name, String value) {
        // Codes_SRS_MESSAGE_11_028: [If name is null, the function shall throw an IllegalArgumentException.]
        if (name == null) {
            throw new IllegalArgumentException("Property name cannot be 'null'.");
        }

        // Codes_SRS_MESSAGE_11_029: [If value is null, the function shall throw an IllegalArgumentException.]
        if (value == null) {
            throw new IllegalArgumentException("Property value cannot be 'null'.");
        }

        // Codes_SRS_MESSAGE_11_026: [The function shall set the message property to the given value.]
        MessageProperty messageProperty = null;

        for (MessageProperty currentMessageProperty: this.properties) {
            if (currentMessageProperty.hasSameName(name)) {
                messageProperty = currentMessageProperty;
                break;
            }
        }

        if (messageProperty != null) {
            this.properties.remove(messageProperty);
        }

        this.properties.add(new MessageProperty(name, value));
    }

    /**
     * Returns a copy of the message properties.
     *
     * @return a copy of the message properties.
     */
    public MessageProperty[] getProperties() {
        // Codes_SRS_MESSAGE_11_033: [The function shall return a copy of the message properties.]
        return properties.toArray(new MessageProperty[this.properties.size()]);
    }

    // ----- Private Methods -----

    /**
     * Internal initializer method for a new Message instance.
     */
    private void initialize() {
        this.lockToken = UUID.randomUUID().toString();
        this.messageId = generateId(127); // 1 in 2.03035346985252E-242 chances of collision. Might be safe enough...
        this.correlationId = generateId(127);
        this.feedbackStatusCode = FeedbackStatusCodeEnum.none;
        this.ack = FeedbackStatusCodeEnum.none;
        this.properties = new ArrayList<MessageProperty>();
    }

    /**
     * Generates a random ID string.
     * @param length Length of the string to be generated.
     * @return A string containing valid ID chars.
     */
    private String generateId(int length)
    {
        String validCharacters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-:.+%_#*?!(),=@;$'";

        char[] charSequence = new char[length];

        Random random = new Random();

        for (int i = 0; i < length; i++)
        {
            charSequence[i] = validCharacters.charAt(random.nextInt(validCharacters.length()));
        }

        return new String(charSequence);
    }

    /**
     * Getter for the messageId property
     * @return The property value
     */
    public String getMessageId()
    {
        return messageId;
    }

    /**
     * Setter for the messageId property
     * @param messageId The string containing the property value
     */
    public void setMessageId(String messageId)
    {
        this.messageId = messageId;
    }

    /**
     * Getter for the correlationId property
     * @return The property value
     */
    public String getCorrelationId()
    {
        return correlationId;
    }

    /**
     * Setter for the expiryTimeUtc property
     * @param correlationId The string containing the property value
     */
    public void setCorrelationId(String correlationId)
    {
        this.correlationId = correlationId;
    }
}